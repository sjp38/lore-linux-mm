Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0042F44043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 15:48:02 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r68so2979161wmr.4
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 12:48:01 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id t22si4186187wrc.346.2017.11.08.12.48.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 12:48:00 -0800 (PST)
Date: Wed, 8 Nov 2017 21:47:45 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] x86/mm: Unbreak modules that rely on external PAGE_KERNEL
 availability
In-Reply-To: <nycvar.YFH.7.76.1711082103320.6470@cbobk.fhfr.pm>
Message-ID: <alpine.DEB.2.20.1711082133410.1962@nanos>
References: <nycvar.YFH.7.76.1711082103320.6470@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Borislav Petkov <bp@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, x86@kernel.org, Greg KH <greg@kroah.com>

On Wed, 8 Nov 2017, Jiri Kosina wrote:

> From: Jiri Kosina <jkosina@suse.cz>
> 
> Commit
> 
>   7744ccdbc16f0 ("x86/mm: Add Secure Memory Encryption (SME) support")
> 
> as a side-effect made PAGE_KERNEL all of a sudden unavailable to modules 
> which can't make use of EXPORT_SYMBOL_GPL() symbols.
> 
> This is because once SME is enabled, sme_me_mask (which is introduced as 
> EXPORT_SYMBOL_GPL) makes its way to PAGE_KERNEL through _PAGE_ENC, causing 
> imminent build failure for all the modules which make use of all the 
> EXPORT-SYMBOL()-exported API (such as vmap(), __vmalloc(), 
> remap_pfn_range(), ...).
> 
> Exporting (as EXPORT_SYMBOL()) interfaces (and having done so for ages) 
> that take pgprot_t argument, while making it impossible to -- all of a 
> sudden -- pass PAGE_KERNEL to it, feels rather incosistent.
> 
> Restore the original behavior and make it possible to pass PAGE_KERNEL to 
> all its EXPORT_SYMBOL() consumers.

To be honest, I fundamentaly hate this, because proprietary crap out there
more or less holds the kernel hostage in its decisions of marking new
functionality GPL only. You have already a choice by disabling SME, but
sure you want to get everything: new features and proprietary stuff.

I fear, that I can't prevent this from being applied, but whoever picks up
that patch, please add:

Despised-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
