Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 818766B027A
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 04:40:08 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id r13so39511000pag.1
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 01:40:08 -0700 (PDT)
Received: from terminus.zytor.com (torg.zytor.com. [2001:1868:205::12])
        by mx.google.com with ESMTPS id 5si8869379pgb.324.2016.10.28.01.40.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Oct 2016 01:40:07 -0700 (PDT)
Date: Fri, 28 Oct 2016 01:37:49 -0700
From: tip-bot for Borislav Petkov <tipbot@zytor.com>
Message-ID: <tip-1c27f646b18fb56308dff82784ca61951bad0b48@git.kernel.org>
Reply-To: rpeterso@redhat.com, peterz@infradead.org, mingo@kernel.org,
        brgerst@gmail.com, mgorman@techsingularity.net, swhiteho@redhat.com,
        bp@alien8.de, linux-kernel@vger.kernel.org, tglx@linutronix.de,
        luto@kernel.org, dvlasenk@redhat.com, luto@amacapital.net, bp@suse.de,
        hpa@zytor.com, torvalds@linux-foundation.org, jpoimboe@redhat.com,
        agruenba@redhat.com, linux-mm@kvack.org
In-Reply-To: <20161027123623.j2jri5bandimboff@pd.tnic>
References: <20161027123623.j2jri5bandimboff@pd.tnic>
Subject: [tip:x86/urgent] x86/microcode/AMD: Fix more fallout from
 CONFIG_RANDOMIZE_MEMORY=y
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: bp@suse.de, luto@amacapital.net, hpa@zytor.com, dvlasenk@redhat.com, jpoimboe@redhat.com, agruenba@redhat.com, torvalds@linux-foundation.org, linux-mm@kvack.org, mingo@kernel.org, rpeterso@redhat.com, peterz@infradead.org, brgerst@gmail.com, bp@alien8.de, mgorman@techsingularity.net, swhiteho@redhat.com, luto@kernel.org, linux-kernel@vger.kernel.org, tglx@linutronix.de

Commit-ID:  1c27f646b18fb56308dff82784ca61951bad0b48
Gitweb:     http://git.kernel.org/tip/1c27f646b18fb56308dff82784ca61951bad0b48
Author:     Borislav Petkov <bp@suse.de>
AuthorDate: Thu, 27 Oct 2016 14:36:23 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Fri, 28 Oct 2016 10:29:59 +0200

x86/microcode/AMD: Fix more fallout from CONFIG_RANDOMIZE_MEMORY=y

We needed the physical address of the container in order to compute the
offset within the relocated ramdisk. And we did this by doing __pa() on
the virtual address.

However, __pa() does checks whether the physical address is within
PAGE_OFFSET and __START_KERNEL_map - see __phys_addr() - which fail
if we have CONFIG_RANDOMIZE_MEMORY enabled: we feed a virtual address
which *doesn't* have the randomization offset into a function which uses
PAGE_OFFSET which *does* have that offset.

This makes this check fire:

	VIRTUAL_BUG_ON((x > y) || !phys_addr_valid(x));
			^^^^^^

due to the randomization offset.

The fix is as simple as using __pa_nodebug() because we do that
randomization offset accounting later in that function ourselves.

Reported-by: Bob Peterson <rpeterso@redhat.com>
Tested-by: Bob Peterson <rpeterso@redhat.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Steven Whitehouse <swhiteho@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm <linux-mm@kvack.org>
Cc: stable@vger.kernel.org # 4.9
Link: http://lkml.kernel.org/r/20161027123623.j2jri5bandimboff@pd.tnic
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/kernel/cpu/microcode/amd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kernel/cpu/microcode/amd.c b/arch/x86/kernel/cpu/microcode/amd.c
index 620ab06..017bda1 100644
--- a/arch/x86/kernel/cpu/microcode/amd.c
+++ b/arch/x86/kernel/cpu/microcode/amd.c
@@ -429,7 +429,7 @@ int __init save_microcode_in_initrd_amd(void)
 	 * We need the physical address of the container for both bitness since
 	 * boot_params.hdr.ramdisk_image is a physical address.
 	 */
-	cont    = __pa(container);
+	cont    = __pa_nodebug(container);
 	cont_va = container;
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
