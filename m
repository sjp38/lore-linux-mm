Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 02AB66B04B7
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 19:43:31 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id d12so133722506pgt.8
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 16:43:30 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id w12si4157287pge.639.2017.08.18.16.43.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 16:43:29 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id 83so17114922pgb.4
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 16:43:29 -0700 (PDT)
Date: Sat, 19 Aug 2017 07:43:48 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v8 09/14] lockdep: Apply crossrelease to completions
Message-ID: <20170818234348.GE11771@tardis>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-10-git-send-email-byungchul.park@lge.com>
 <CAK8P3a3ABsxTaS7ZdcWNbTx7j5wFRc0h=ZVWAC_h-E+XbFv+8Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK8P3a3ABsxTaS7ZdcWNbTx7j5wFRc0h=ZVWAC_h-E+XbFv+8Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Byungchul Park <byungchul.park@lge.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, walken@google.com, kirill@shutemov.name, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, willy@infradead.org, Nicholas Piggin <npiggin@gmail.com>, kernel-team@lge.com

Hi Arnd,

On Mon, Aug 14, 2017 at 10:50:24AM +0200, Arnd Bergmann wrote:
> On Mon, Aug 7, 2017 at 9:12 AM, Byungchul Park <byungchul.park@lge.com> wrote:
> > Although wait_for_completion() and its family can cause deadlock, the
> > lock correctness validator could not be applied to them until now,
> > because things like complete() are usually called in a different context
> > from the waiting context, which violates lockdep's assumption.
> >
> > Thanks to CONFIG_LOCKDEP_CROSSRELEASE, we can now apply the lockdep
> > detector to those completion operations. Applied it.
> >
> > Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> 
> This patch introduced a significant growth in kernel stack usage for a small
> set of functions. I see two new warnings for functions that get tipped over the
> 1024 or 2048 byte frame size limit in linux-next (with a few other patches
> applied):
> 
> Before:
> 
> drivers/md/dm-integrity.c: In function 'write_journal':
> drivers/md/dm-integrity.c:827:1: error: the frame size of 504 bytes is
> larger than xxx bytes [-Werror=frame-larger-than=]
> drivers/mmc/core/mmc_test.c: In function 'mmc_test_area_io_seq':
> drivers/mmc/core/mmc_test.c:1491:1: error: the frame size of 680 bytes
> is larger than 104 bytes [-Werror=frame-larger-than=]
> 
> After:
> 
> drivers/md/dm-integrity.c: In function 'write_journal':
> drivers/md/dm-integrity.c:827:1: error: the frame size of 1280 bytes
> is larger than 1024 bytes [-Werror=frame-larger-than=]
> drivers/mmc/core/mmc_test.c: In function 'mmc_test_area_io_seq':
> drivers/mmc/core/mmc_test.c:1491:1: error: the frame size of 1072
> bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
> 
> I have not checked in detail why this happens, but I'm guessing that
> there is an overall increase in stack usage with
> CONFIG_LOCKDEP_COMPLETE in functions using completions,
> and I think it would be good to try to come up with a version that doesn't
> add as much.
> 

So I have been staring at this for a while, and below is what I found:

(BTW, Arnd, may I know your compiler version? Mine is 7.1.1)

In write_journal(), I can see the code generated like this on x86:

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

Those two "rep movsq"s are very suspicious, because
COMPLETION_INITIALIZER_ONSTACK() should initialize the data in-place,
rather than move it to some temporary variable and copy it back.

I tried to reduce the size of completion struct, and the "rep movsq" did
go away, however it seemed the compiler still allocated the memory for
the temporary variables on the stack, because whenever I
increased/decreased  the size of completion, the stack size of
write_journal() got increased/decreased *7* times, but there are only
3 journal_completion structures in write_journal(). So the *4* callsites
of COMPLETION_INITIALIZER_ONSTACK() looked very suspicous.

So I come up with the following patch, trying to teach the compiler not
to do the unnecessary allocation, could you give it a try?

Besides, I could also observe the stack size reduction of
write_journal() even for !LOCKDEP kernel.

-------------------------->8
Subject: [PATCH] completion: Avoid unnecessary stack allocation for
 COMPLETION_INITIALIZER_ONSTACK()

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
