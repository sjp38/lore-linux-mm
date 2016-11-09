Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B19F26B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 06:06:32 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y68so92637392pfb.6
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 03:06:32 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u2si21394557pau.333.2016.11.09.03.06.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 03:06:31 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.8 041/138] x86/microcode/AMD: Fix more fallout from CONFIG_RANDOMIZE_MEMORY=y
Date: Wed,  9 Nov 2016 11:45:24 +0100
Message-Id: <20161109102846.562244037@linuxfoundation.org>
In-Reply-To: <20161109102844.808685475@linuxfoundation.org>
References: <20161109102844.808685475@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, Borislav Petkov <bp@suse.de>, Andreas Gruenbacher <agruenba@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Steven Whitehouse <swhiteho@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>

4.8-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Borislav Petkov <bp@suse.de>

commit 1c27f646b18fb56308dff82784ca61951bad0b48 upstream.

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
Link: http://lkml.kernel.org/r/20161027123623.j2jri5bandimboff@pd.tnic
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/kernel/cpu/microcode/amd.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/arch/x86/kernel/cpu/microcode/amd.c
+++ b/arch/x86/kernel/cpu/microcode/amd.c
@@ -429,7 +429,7 @@ int __init save_microcode_in_initrd_amd(
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
