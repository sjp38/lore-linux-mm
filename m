Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B00DC44043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 16:45:29 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id z34so2108282wrz.0
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 13:45:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m10si3820926edi.44.2017.11.08.13.45.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 13:45:28 -0800 (PST)
Date: Wed, 8 Nov 2017 22:45:22 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [PATCH] x86/mm: Unbreak modules that rely on external
 PAGE_KERNEL availability
Message-ID: <20171108214522.n5ewoijugodmmiec@pd.tnic>
References: <nycvar.YFH.7.76.1711082103320.6470@cbobk.fhfr.pm>
 <alpine.DEB.2.20.1711082133410.1962@nanos>
 <CA+55aFz5Z8dfLp1swfOaEomH21mvCFEy=4w6L0cWska=He45FQ@mail.gmail.com>
 <20171108211525.4kxwj5ygg3kvfl2a@pd.tnic>
 <CA+55aFwNgm9qkptXTwVbN6Krwki+zvJD1M9UiGppX+Eb1yvfoQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFwNgm9qkptXTwVbN6Krwki+zvJD1M9UiGppX+Eb1yvfoQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Jiri Kosina <jikos@kernel.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Greg KH <greg@kroah.com>

On Wed, Nov 08, 2017 at 01:23:37PM -0800, Linus Torvalds wrote:
> I was thinking that maybe we could have a fixed "encrypt" bit in our
> PTE, and then replace that "software bit" with whatever the real
> hardware mask is (if any).

Right, I don't think that should be hard, unless I'm missing anything.
We read that bit from CPUID and that's bit 47 of the physical address
right now.

Do you think we could reuse one of those _PAGE_BIT_SOFTW*?

Right, and then set the proper *hardware* bit everytime we set a
pteval_t.

> Because it's nasty to have these constants that _used_ to be
> constants, and still _look_ like constants, suddely do stupid memory
> reads from random kernel data.
> 
> So _this_ is the underflying problem:
> 
>   #define _PAGE_ENC  (_AT(pteval_t, sme_me_mask))
> 
> because that is simply not how the _PAGE_xyz macros should work!

Yeah, I still have a funny feeling when looking at that but modulo
better solutions... :-\

> So it should have been a fixed bit to begin with, and the dynamic part
> should have been elsewhere.

Right, Tom, whaddya think? Do you see any issues with doing a software,
"mirror" bit of sorts and then converting to the C-bit when needed?

> The whole EXPORT_SYMBOL() thing is just a symptom of that fundamental
> error. Modules - GPL or not - should _never_ have to know or care
> about this _PAGE_ENC bit madness, simply because it shouldn't have
> been there.

Right, so every user of the PAGE_* macros needs to set the C-bit when
SME is enabled and everytime it creates a PTE so that the memory
controller knows how to do the access. I certainly like your idea but
we'd have to audit all the places where we need to convert to the C-bit
from the software encryption bit and how ugly that would get.

Btw, this is the other reason why the _PAGE_ENC bit is in the PAGE_*
macros: for full encryption, everything that deals with PTEs needs to
set the C-bit.

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
