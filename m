Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE6B280396
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 11:25:53 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a2so3048713pfj.12
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 08:25:53 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id z11si1217636pge.66.2017.08.23.08.25.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 08:25:52 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id c15so313722pfm.3
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 08:25:51 -0700 (PDT)
From: Boqun Feng <boqun.feng@gmail.com>
Subject: [PATCH 2/2] completion: Avoid unnecessary stack allocation for COMPLETION_INITIALIZER_ONSTACK()
Date: Wed, 23 Aug 2017 23:25:38 +0800
Message-Id: <20170823152542.5150-3-boqun.feng@gmail.com>
In-Reply-To: <20170823152542.5150-1-boqun.feng@gmail.com>
References: <20170823152542.5150-1-boqun.feng@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, walken@google.com, Byungchul Park <byungchul.park@lge.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, willy@infradead.org, Nicholas Piggin <npiggin@gmail.com>, kernel-team@lge.com, Boqun Feng <boqun.feng@gmail.com>

In theory, COMPLETION_INITIALIZER_ONSTACK() should never affect the
stack allocation of the caller. However, on some compilers, a temporary
structure was allocated for the return value of
COMPLETION_INITIALIZER_ONSTACK(), for example in write_journal() with
LOCKDEP_COMPLETIONS=y(gcc is 7.1.1):

	io_comp.comp = COMPLETION_INITIALIZER_ONSTACK(io_comp.comp);
	    2462:       e8 00 00 00 00          callq  2467 <write_journal+0x47>
	    2467:       48 8d 85 80 fd ff ff    lea    -0x280(%rbp),%rax
	    246e:       48 c7 c6 00 00 00 00    mov    $0x0,%rsi
	    2475:       48 c7 c2 00 00 00 00    mov    $0x0,%rdx
		x->done = 0;
	    247c:       c7 85 90 fd ff ff 00    movl   $0x0,-0x270(%rbp)
	    2483:       00 00 00
		init_waitqueue_head(&x->wait);
	    2486:       48 8d 78 18             lea    0x18(%rax),%rdi
	    248a:       e8 00 00 00 00          callq  248f <write_journal+0x6f>
		if (commit_start + commit_sections <= ic->journal_sections) {
	    248f:       41 8b 87 a8 00 00 00    mov    0xa8(%r15),%eax
		io_comp.comp = COMPLETION_INITIALIZER_ONSTACK(io_comp.comp);
	    2496:       48 8d bd e8 f9 ff ff    lea    -0x618(%rbp),%rdi
	    249d:       48 8d b5 90 fd ff ff    lea    -0x270(%rbp),%rsi
	    24a4:       b9 17 00 00 00          mov    $0x17,%ecx
	    24a9:       f3 48 a5                rep movsq %ds:(%rsi),%es:(%rdi)
		if (commit_start + commit_sections <= ic->journal_sections) {
	    24ac:       41 39 c6                cmp    %eax,%r14d
		io_comp.comp = COMPLETION_INITIALIZER_ONSTACK(io_comp.comp);
	    24af:       48 8d bd 90 fd ff ff    lea    -0x270(%rbp),%rdi
	    24b6:       48 8d b5 e8 f9 ff ff    lea    -0x618(%rbp),%rsi
	    24bd:       b9 17 00 00 00          mov    $0x17,%ecx
	    24c2:       f3 48 a5                rep movsq %ds:(%rsi),%es:(%rdi)

We can obviously see the temporary structure allocated, and the compiler
also does two meaningless memcpy with "rep movsq".

And according to:

	https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html#Statement-Exprs

The return value of a statement expression is returned by value, so the
temporary variable is created in COMPLETION_INITIALIZER_ONSTACK(), and
that's why the temporary structures are allocted.

To fix this, make the brace block in COMPLETION_INITIALIZER_ONSTACK()
return a pointer and dereference it outside the block rather than return
the whole structure, in this way, we are able to teach the compiler not
to do the unnecessary stack allocation.

This could also reduce the stack size even if !LOCKDEP, for example in
write_journal(), compiled with gcc 7.1.1, the result of command:

	 objdump -d drivers/md/dm-integrity.o | ./scripts/checkstack.pl x86

before:

	0x0000246a write_journal [dm-integrity.o]:              696

after:

	0x00002b7a write_journal [dm-integrity.o]:              296

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Boqun Feng <boqun.feng@gmail.com>
---
 include/linux/completion.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/completion.h b/include/linux/completion.h
index 791f053f28b7..cae5400022a3 100644
--- a/include/linux/completion.h
+++ b/include/linux/completion.h
@@ -74,7 +74,7 @@ static inline void complete_release_commit(struct completion *x) {}
 #endif
 
 #define COMPLETION_INITIALIZER_ONSTACK(work) \
-	({ init_completion(&work); work; })
+	(*({ init_completion(&work); &work; }))
 
 /**
  * DECLARE_COMPLETION - declare and initialize a completion structure
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
