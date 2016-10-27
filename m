Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 882A16B0270
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 08:36:26 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y138so9566690wme.7
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 05:36:26 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id cw8si8251334wjb.50.2016.10.27.05.36.25
        for <linux-mm@kvack.org>;
        Thu, 27 Oct 2016 05:36:25 -0700 (PDT)
Date: Thu, 27 Oct 2016 14:36:23 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
Message-ID: <20161027123623.j2jri5bandimboff@pd.tnic>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com>
 <CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com>
 <CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com>
 <CA+55aFyRv0YttbLUYwDem=-L5ZAET026umh6LOUQ6hWaRur_VA@mail.gmail.com>
 <996124132.13035408.1477505043741.JavaMail.zimbra@redhat.com>
 <CA+55aFzVmppmua4U0pesp2moz7vVPbH1NP264EKeW3YqOzFc3A@mail.gmail.com>
 <1731570270.13088320.1477515684152.JavaMail.zimbra@redhat.com>
 <20161026231358.36jysz2wycdf4anf@pd.tnic>
 <624629879.13118306.1477528645189.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <624629879.13118306.1477528645189.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Peterson <rpeterso@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 26, 2016 at 08:37:25PM -0400, Bob Peterson wrote:
> Attached, but as Linus suggested, I turned off the AMD microcode driver,
> so it should be the same if you turn it back on. If you want, I can
> do it and re-send so you have a more pristine .config. Let me know.

Thanks, but I was able to reproduce in a VM.

Here's a fix which works here - I'd appreciate it if you ran it and
checked the microcode was applied correctly, i.e.:

$ dmesg | grep -i microcode

before and after the patch. Please paste that output in a mail too.

Thanks!

---
From: Borislav Petkov <bp@suse.de>
Date: Thu, 27 Oct 2016 14:03:59 +0200
Subject: [PATCH] x86/microcode/AMD: Fix more fallout from CONFIG_RANDOMIZE_MEMORY

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
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: stable@vger.kernel.org # 4.9
---
 arch/x86/kernel/cpu/microcode/amd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kernel/cpu/microcode/amd.c b/arch/x86/kernel/cpu/microcode/amd.c
index 620ab06bcf45..017bda12caae 100644
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
2.10.0

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
