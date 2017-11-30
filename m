Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9325F6B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 10:45:33 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id p188so6148829iof.15
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 07:45:33 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0088.hostedemail.com. [216.40.44.88])
        by mx.google.com with ESMTPS id s31si3323656ioi.146.2017.11.30.07.45.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 07:45:32 -0800 (PST)
Message-ID: <1512056726.19952.100.camel@perches.com>
Subject: Re: [PATCHv2 0/4] x86: 5-level related changes into decompression
 code
From: Joe Perches <joe@perches.com>
Date: Thu, 30 Nov 2017 07:45:26 -0800
In-Reply-To: <20171130073130.afualycggltkvl6s@black.fi.intel.com>
References: <20171110220645.59944-1-kirill.shutemov@linux.intel.com>
	 <20171129154908.6y4st6xc7hbsey2v@pd.tnic>
	 <20171129161349.d7ksuhwhdamloty6@node.shutemov.name>
	 <alpine.DEB.2.20.1711291740050.1825@nanos>
	 <20171129170831.2iqpop2u534mgrbc@node.shutemov.name>
	 <20171129174851.jk2ai37uumxve6sg@pd.tnic>
	 <20171130073130.afualycggltkvl6s@black.fi.intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Borislav Petkov <bp@suse.de>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H.
 Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2017-11-30 at 10:31 +0300, Kirill A. Shutemov wrote:
> On Wed, Nov 29, 2017 at 05:48:51PM +0000, Borislav Petkov wrote:
> > On Wed, Nov 29, 2017 at 08:08:31PM +0300, Kirill A. Shutemov wrote:
> > > We're really early in the boot -- startup_64 in decompression code -- and
> > > I don't know a way print a message there. Is there a way?
> > > 
> > > no_longmode handled by just hanging the machine. Is it enough for no_la57
> > > case too?
> > 
> > Patch pls.
> 
> The patch below on top of patch 2/4 from this patch would do the trick.
> 
> Please give it a shot.
> 
> From 95b5489d1f4ea03c6226d13eb6797825234489d6 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Thu, 30 Nov 2017 10:23:53 +0300
> Subject: [PATCH] x86/boot/compressed/64: Print error if 5-level paging is not
>  supported
> 
> We cannot proceed booting if the machine doesn't support the paging mode
> kernel was compiled for.
> 
> Getting error the usual way -- via validate_cpu() -- is not going to
> work. We need to enable appropriate paging mode before that, otherwise
> kernel would triple-fault during KASLR setup.
> 
> This code will go away once we get support for boot-time switching
> between paging modes.

trivia:

> diff --git a/arch/x86/boot/compressed/misc.c b/arch/x86/boot/compressed/misc.c
[]
> @@ -362,6 +364,13 @@ asmlinkage __visible void *extract_kernel(void *rmode, memptr heap,
>  	console_init();
>  	debug_putstr("early console in extract_kernel\n");
>  
> +	if (IS_ENABLED(CONFIG_X86_5LEVEL) && !l5_paging_required()) {
> +		error("The kernel is compiled with 5-level paging enabled, "
> +				"but the CPU doesn't support la57\n"

la57 is lanthanum, perhaps something less obscure or more
readily searchable?  Maybe cr4.la57?  it?

Maybe something like:

"This linux kernel as configured requires 5-level paging\n"
"This CPU does not support the required 'cr4.la57' feature\n"
"Unable to boot - please use a kernel appropriate for your CPU\n"

And please use complete coalesced single lines.

> +				"Unable to boot - please use "
> +				"a kernel appropriate for your CPU.\n");

Here too.  Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
