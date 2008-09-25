Message-ID: <48DBB0B3.2010500@tungstengraphics.com>
Date: Thu, 25 Sep 2008 17:39:31 +0200
From: =?UTF-8?B?VGhvbWFzIEhlbGxzdHLDtm0=?= <thomas@tungstengraphics.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: pageable memory allocator (for DRM-GEM?)
References: <20080923091017.GB29718@wotan.suse.de>	 <48D8C326.80909@tungstengraphics.com>	 <20080925001856.GB23494@wotan.suse.de>	 <48DB3B88.7080609@tungstengraphics.com> <1222353487.4343.205.camel@koto.keithp.com>
In-Reply-To: <1222353487.4343.205.camel@koto.keithp.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Keith Packard <keithp@keithp.com>
Cc: Nick Piggin <npiggin@suse.de>, "eric@anholt.net" <eric@anholt.net>, "hugh@veritas.com" <hugh@veritas.com>, "hch@infradead.org" <hch@infradead.org>, "airlied@linux.ie" <airlied@linux.ie>, "jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>, "dri-devel@lists.sourceforge.net" <dri-devel@lists.sourceforge.net>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Keith Packard wrote:
> On Thu, 2008-09-25 at 00:19 -0700, Thomas HellstrA?m wrote:
>   
>>  If data is
>> dirtied in VRAM or the page(s) got discarded
>>  we need new pages and to set up a copy operation.
>>     
>
> Note that this can occur as a result of a suspend-to-memory transition
> at which point *all* of the objects in VRAM will need to be preserved in
> main memory, and so the pages aren't really 'freed', they just don't
> need to have valid contents, but the system should be aware that the
> space may be needed at some point in the future.
>
>   
Actually, I think the pages must be allowed to be freed, and that we 
don't put a requirement on "pageable"  to keep
swap-space slots for these pages. If we hit an OOM-condition during 
suspend-to-memory that's bad, but let's say we
required "pageable" to keep swap space slots for us, the result would 
perhaps be that another device wasn't able to suspend, or a user-space 
program was killed due to lack of swap-space prior to suspend.

I'm not really sure what's the worst situation, but my feeling is that 
we should not require swap-space to be reserved for VRAM, and abort the 
suspend operation if we hit OOM. That would, in the worst case, mean 
that people with non-UMA laptops and a too small swap partition would 
see their battery run out much quicker than they expected...

/Thomas



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
