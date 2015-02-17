Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id CB03B6B0072
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 07:21:25 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id r20so32499346wiv.2
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 04:21:23 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s2si28619557wjs.198.2015.02.17.04.21.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Feb 2015 04:21:22 -0800 (PST)
Date: Tue, 17 Feb 2015 13:21:20 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH v2] x86, kaslr: propagate base load address calculation
In-Reply-To: <20150217104443.GC9784@pd.tnic>
Message-ID: <alpine.LNX.2.00.1502171319040.2279@pobox.suse.cz>
References: <alpine.LNX.2.00.1502101411280.10719@pobox.suse.cz> <CAGXu5jJzs9Ve9so96f6n-=JxP+GR3xYFQYBtZ=mUm+Q7bMAgBw@mail.gmail.com> <alpine.LNX.2.00.1502110001480.10719@pobox.suse.cz> <alpine.LNX.2.00.1502110010190.10719@pobox.suse.cz>
 <alpine.LNX.2.00.1502131602360.2423@pobox.suse.cz> <20150217104443.GC9784@pd.tnic>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Kees Cook <keescook@chromium.org>, "H. Peter Anvin" <hpa@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, live-patching@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

On Tue, 17 Feb 2015, Borislav Petkov wrote:

> > Commit e2b32e678 ("x86, kaslr: randomize module base load address") makes 
> > the base address for module to be unconditionally randomized in case when 
> > CONFIG_RANDOMIZE_BASE is defined and "nokaslr" option isn't present on the 
> > commandline.
> > 
> > This is not consistent with how choose_kernel_location() decides whether 
> > it will randomize kernel load base.
> > 
> > Namely, CONFIG_HIBERNATION disables kASLR (unless "kaslr" option is 
> > explicitly specified on kernel commandline), which makes the state space 
> > larger than what module loader is looking at. IOW CONFIG_HIBERNATION && 
> > CONFIG_RANDOMIZE_BASE is a valid config option, kASLR wouldn't be applied 
> > by default in that case, but module loader is not aware of that.
> > 
> > Instead of fixing the logic in module.c, this patch takes more generic 
> > aproach. It introduces a new bootparam setup data_type SETUP_KASLR and 
> > uses that to pass the information whether kaslr has been applied during 
> > kernel decompression, and sets a global 'kaslr_enabled' variable 
> > accordingly, so that any kernel code (module loading, livepatching, ...) 
> > can make decisions based on its value.
> > 
> > x86 module loader is converted to make use of this flag.
> > 
> > Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> > ---
> > 
> > v1 -> v2:
> > 
> > Originally I just calculated the fact on the fly from difference between 
> > __START_KERNEL and &text, but Kees correctly pointed out that this doesn't 
> > properly catch the case when the offset is randomized to zero. I don't see 
> 
> Yeah, about that. I think we want to do the thing in addition so that
> we don't have the misleading "Kernel Offset:..." line in splats in case
> kaslr is off.
> 
> Right?

I don't have strong feelings either way. It seems slightly nicer to have a 
predictable oops output format no matter the CONFIG_ options and 
command-line contents, but if you feel like seeing the 'Kernel offset: 0' 
in 'nokaslr' and !CONFIG_RANDOMIZE_BASE cases is unnecessary noise, feel 
free to make this change to my patch.

Thanks,

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
