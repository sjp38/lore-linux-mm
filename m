Message-ID: <41330349.5040202@yahoo.com.au>
Date: Mon, 30 Aug 2004 20:36:57 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: OOM-killer for zone DMA?
References: <s5hoekwjz00.wl@alsa2.suse.de>	<413021BA.3090908@yahoo.com.au> <s5h8ybxj76x.wl@alsa2.suse.de>
In-Reply-To: <s5h8ybxj76x.wl@alsa2.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Takashi Iwai <tiwai@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Takashi Iwai wrote:
> At Sat, 28 Aug 2004 16:10:02 +1000,
> Nick Piggin wrote:
> 

>>
>>You at least need __GFP_NORETRY to achieve what you want.
> 
> 
> Yes, with that flag it can be avoided.
> 

Great.

> But it *should* retry.

That is precisely the opposite of what you want.

>  It's an allocation of single page, and the
> caller of dma_alloc_coherent() doesn't know whether it's allocated
> from zone DMA or zone normal.  It sets just the coherent_dma_mask to a
> value less than 32 bit.
> 
> This situation may happen even after applying my patch.
> If you have more RAM than mask, allocation in the zone NORMAL may hit
> the outside of mask, and tries the zone DMA as fallback, although
> there are pretty enough free RAM in the zone NORMAL.
> 
> So, triggering oom-killer for zone DMA is non-sense, IMO.
> 

AFAIKS your patch tries ZONE_NORMAL, then falls back to ZONE_DMA, in
which case you possibly do want the oom-killer for ZONE_DMA. Although
if ZONE_DMA gets filled with pinned memory it will take down the system
due to the continual oom-killing :(

If the interface is allowed to fail, it may be an idea to allow it.
I'm not really sure... the other thing might be to do the retries in
the caller (ie. your code).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
