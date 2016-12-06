Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 38C806B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 12:26:02 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id p66so31387459pga.4
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 09:26:02 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e6si20267371plj.245.2016.12.06.09.26.01
        for <linux-mm@kvack.org>;
        Tue, 06 Dec 2016 09:26:01 -0800 (PST)
Date: Tue, 6 Dec 2016 17:25:12 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv4 08/10] mm/kasan: Switch to using __pa_symbol and
 lm_alias
Message-ID: <20161206172512.GF24177@leverpostej>
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
 <1480445729-27130-9-git-send-email-labbott@redhat.com>
 <2f3ac043-c4cc-5c5a-8ac7-1396b6bb193f@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2f3ac043-c4cc-5c5a-8ac7-1396b6bb193f@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Laura Abbott <labbott@redhat.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com

On Thu, Dec 01, 2016 at 02:36:05PM +0300, Andrey Ryabinin wrote:
> On 11/29/2016 09:55 PM, Laura Abbott wrote:
> > __pa_symbol is the correct API to find the physical address of symbols.
> > Switch to it to allow for debugging APIs to work correctly.
> 
> But __pa() is correct for symbols. I see how __pa_symbol() might be a little
> faster than __pa(), but there is nothing wrong in using __pa() on symbols.

While it's true today that __pa() works on symbols, this is for
pragmatic reasons (allowing existing code to work until it is all
cleaned up), and __pa_symbol() is the correct API to use.

Relying on this means that __pa() can't be optimised for the (vastly
common) case of translating linear map addresses.

Consistent use of __pa_symbol() will allow for subsequent optimisation
of __pa() in the common case, in adition to being necessary for arm64's
DEBUG_VIRTUAL.

> > Other functions such as p*d_populate may call __pa internally.
> > Ensure that the address passed is in the linear region by calling
> > lm_alias.
> 
> Why it should be linear mapping address? __pa() translates kernel
> image address just fine.

As above, while that's true today, but is something that we wish to
change. 

> Generated code is probably worse too.

Even if that is the case, given this is code run once at boot on a debug
build, I think it's outweighed by the gain from DEBUG_VIRTUAL, and as a
step towards optimising __pa().

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
