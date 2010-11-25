Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A62396B0089
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 20:18:53 -0500 (EST)
Date: Wed, 24 Nov 2010 17:18:48 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: Re: Sudden and massive page cache eviction
Message-ID: <20101125011848.GB29511@hostway.ca>
References: <AANLkTikg-sR97tkG=ST9kjZcHe6puYSvMGh-eA3cnH7X@mail.gmail.com> <20101122161158.02699d10.akpm@linux-foundation.org> <1290501502.2390.7029.camel@nimitz> <AANLkTik2Fn-ynUap2fPcRxRdKA=5ZRYG0LJTmqf80y+q@mail.gmail.com> <1290529171.2390.7994.camel@nimitz> <AANLkTikCn-YvORocXSJ1Z+ovYNMhKF7TaX=BHWKwrQup@mail.gmail.com> <AANLkTi=mgTHPEYFsryDYnxPa78f-Nr+H7i4+0KPZbxh3@mail.gmail.com> <AANLkTimo1BR=mSJ6wPQwrL4FDNv=_TfanPPTT7uWx7hQ@mail.gmail.com> <AANLkTi=yV02oY5AmNAYr+ZF0RUgVv8gkeP+D9_CcOfLi@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTi=yV02oY5AmNAYr+ZF0RUgVv8gkeP+D9_CcOfLi@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Peter Sch??ller <scode@spotify.com>
Cc: Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mattias de Zalenski <zalenski@spotify.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 24, 2010 at 04:32:39PM +0100, Peter Sch??ller wrote:

> >> I forgot to address the second part of this question: How would I best
> >> inspect whether the kernel is doing that?
> >
> > You can, for example, record
> >
> > ??cat /proc/meminfo | grep Huge
> >
> > for large page allocations.
> 
> Those show zero a per my other post. However I got the impression Dave
> was asking about regular but larger-than-one-page allocations internal
> to the kernel, while the Huge* lines in /proc/meminfo refers to
> allocations specifically done by userland applications doing huge page
> allocation on a system with huge pages enabled - or am I confused?

Your page cache dents don't seem quite as big, so it may be something
else, but if it's the same problem we're seeing here, it seems to have to
do with when an order=3 new_slab allocation comes in to grows the kmalloc
slab cache for an __alloc_skb (network packet).  This is normal even
without jumbo frames now.  When there are no zones with order=3
zone_watermark_ok(), kswapd is woken, which frees things all over the
place to try to get zone_watermark_ok(order=3) to be happy.

We're seeing this throw out a huge number of pages, and we're seeing it
happen even with lots of memory free in the zone.  CONFIG_COMPACTION also
currently does not help because try_to_compact_pages() returns early with
COMPACT_SKIPPED if order <= PAGE_ALLOC_COSTLY_ORDER, and, you guessed it,
PAGE_ALLOC_COSTLY_ORDER is set to 3.

I reimplemented zone_pages_ok(order=3) in userspace, and I can see it
happen:

Code here: http://0x.ca/sim/ref/2.6.36/buddyinfo_scroll

  Zone order:0      1     2     3    4 5 6 7 8 9 A nr_free state

 DMA32   19026  33652  4897    13    5 1 2 0 0 0 0  106262 337 <= 256
Normal     450      0     0     0    0 0 0 0 0 0 0     450 -7 <= 238
 DMA32   19301  33869  4665    12    5 1 2 0 0 0 0  106035 329 <= 256
Normal     450      0     0     0    0 0 0 0 0 0 0     450 -7 <= 238
 DMA32   19332  33931  4603     9    5 1 2 0 0 0 0  105918 305 <= 256
Normal     450      0     0     0    0 0 0 0 0 0 0     450 -7 <= 238
 DMA32   19467  34057  4468     6    5 1 2 0 0 0 0  105741 281 <= 256
Normal     450      0     0     0    0 0 0 0 0 0 0     450 -7 <= 238
 DMA32   19591  34181  4344     5    5 1 2 0 0 0 0  105609 273 <= 256
Normal     450      0     0     0    0 0 0 0 0 0 0     450 -7 <= 238
 DMA32   19856  34348  4109     2    5 1 2 0 0 0 0  105244 249 <= 256 !!!
Normal     450      0     0     0    0 0 0 0 0 0 0     450 -7 <= 238
 DMA32   24088  36476  5437   144    5 1 2 0 0 0 0  120180 1385 <= 256
Normal    1024      1     0     0    0 0 0 0 0 0 0    1026 -5 <= 238
 DMA32   26453  37440  6676   623   53 1 2 0 0 0 0  134029 5985 <= 256
Normal    8700    100     0     0    0 0 0 0 0 0 0    8900 193 <= 238
 DMA32   48881  38161  7142   966   81 1 2 0 0 0 0  162955 9177 <= 256
Normal    8936    102     0     1    0 0 0 0 0 0 0    9148 205 <= 238
 DMA32   66046  40051  7871  1409  135 2 2 0 0 0 0  191256 13617 <= 256
Normal    9019     18     0     0    0 0 0 0 0 0 0    9055 29 <= 238
 DMA32   67133  48671  8231  1578  143 2 2 0 0 0 0  212503 15097 <= 256

So, kswapd was woken up at the line that ends in "!!!" there, because
free_pages(249) <= min(256), and so zone_watermark_ok() returned 0, when
an order=3 allocation came in.

Maybe try out that script and see if you see something similar.

Simon-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
