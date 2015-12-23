Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id C747882F97
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 16:45:19 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id k90so162901170qge.0
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 13:45:19 -0800 (PST)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com. [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id 205si14815956qhr.99.2015.12.23.13.45.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Dec 2015 13:45:19 -0800 (PST)
Received: by mail-qg0-x230.google.com with SMTP id 6so8376654qgy.1
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 13:45:19 -0800 (PST)
Date: Wed, 23 Dec 2015 16:45:16 -0500 (EST)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v2] ARM: mm: flip priority of CONFIG_DEBUG_RODATA
In-Reply-To: <20151223212911.GR2793@atomide.com>
Message-ID: <alpine.LFD.2.20.1512231637110.3603@knanqh.ubzr>
References: <20151202202725.GA794@www.outflux.net> <20151223195129.GP2793@atomide.com> <567B04AB.6010906@redhat.com> <20151223212911.GR2793@atomide.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Lindgren <tony@atomide.com>
Cc: Laura Abbott <labbott@redhat.com>, Kees Cook <keescook@chromium.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel-hardening@lists.openwall.com, linux-arm-kernel@lists.infradead.org, Laura Abbott <labbott@fedoraproject.org>

On Wed, 23 Dec 2015, Tony Lindgren wrote:

> Hi,
> 
> * Laura Abbott <labbott@redhat.com> [151223 12:31]:
> > 
> > Looks like a case similar to Geert's
> > 
> >         adr     r7, kick_counter
> > wait_dll_lock_timed:
> >         ldr     r4, wait_dll_lock_counter
> >         add     r4, r4, #1
> >         str     r4, [r7, #wait_dll_lock_counter - kick_counter]
> >         ldr     r4, sdrc_dlla_status
> >         /* Wait 20uS for lock */
> >         mov     r6, #8
> > 
> > 
> > kick_counter and wait_dll_lock_counter are in the text section which is marked read only.
> > They need to be moved to the data section along with a few other variables from what I
> > can tell (maybe those are read only?).
> 
> Thanks for looking, yeah so it seem.
> 
> > I suspect this is going to be a common issue with suspend/resume code paths since those
> > are hand written assembly.
> 
> Yes I suspect we have quite a few cases like this.

We fixed a bunch of similar issues where code was located in the .data 
section for ease of use from assembly code.  See commit b4e61537 and 
d0776aff for example.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
