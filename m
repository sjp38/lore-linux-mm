Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6410A6B0072
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 05:45:34 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id b13so34452254wgh.0
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 02:45:33 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id bz1si28200306wjc.179.2015.02.17.02.45.31
        for <linux-mm@kvack.org>;
        Tue, 17 Feb 2015 02:45:32 -0800 (PST)
Date: Tue, 17 Feb 2015 11:44:43 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v2] x86, kaslr: propagate base load address calculation
Message-ID: <20150217104443.GC9784@pd.tnic>
References: <alpine.LNX.2.00.1502101411280.10719@pobox.suse.cz>
 <CAGXu5jJzs9Ve9so96f6n-=JxP+GR3xYFQYBtZ=mUm+Q7bMAgBw@mail.gmail.com>
 <alpine.LNX.2.00.1502110001480.10719@pobox.suse.cz>
 <alpine.LNX.2.00.1502110010190.10719@pobox.suse.cz>
 <alpine.LNX.2.00.1502131602360.2423@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1502131602360.2423@pobox.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>, Kees Cook <keescook@chromium.org>
Cc: "H. Peter Anvin" <hpa@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, live-patching@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

On Fri, Feb 13, 2015 at 04:04:55PM +0100, Jiri Kosina wrote:
> Commit e2b32e678 ("x86, kaslr: randomize module base load address") makes 
> the base address for module to be unconditionally randomized in case when 
> CONFIG_RANDOMIZE_BASE is defined and "nokaslr" option isn't present on the 
> commandline.
> 
> This is not consistent with how choose_kernel_location() decides whether 
> it will randomize kernel load base.
> 
> Namely, CONFIG_HIBERNATION disables kASLR (unless "kaslr" option is 
> explicitly specified on kernel commandline), which makes the state space 
> larger than what module loader is looking at. IOW CONFIG_HIBERNATION && 
> CONFIG_RANDOMIZE_BASE is a valid config option, kASLR wouldn't be applied 
> by default in that case, but module loader is not aware of that.
> 
> Instead of fixing the logic in module.c, this patch takes more generic 
> aproach. It introduces a new bootparam setup data_type SETUP_KASLR and 
> uses that to pass the information whether kaslr has been applied during 
> kernel decompression, and sets a global 'kaslr_enabled' variable 
> accordingly, so that any kernel code (module loading, livepatching, ...) 
> can make decisions based on its value.
> 
> x86 module loader is converted to make use of this flag.
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> ---
> 
> v1 -> v2:
> 
> Originally I just calculated the fact on the fly from difference between 
> __START_KERNEL and &text, but Kees correctly pointed out that this doesn't 
> properly catch the case when the offset is randomized to zero. I don't see 

Yeah, about that. I think we want to do the thing in addition so that
we don't have the misleading "Kernel Offset:..." line in splats in case
kaslr is off.

Right?

---
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index ab4734e5411d..a203da9cc445 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1275,6 +1275,9 @@ static struct notifier_block kernel_offset_notifier = {
 
 static int __init register_kernel_offset_dumper(void)
 {
+	if (!kaslr_enabled)
+		return 0;
+
 	atomic_notifier_chain_register(&panic_notifier_list,
 					&kernel_offset_notifier);
 	return 0;

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
