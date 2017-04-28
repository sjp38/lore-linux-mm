Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2CCF36B02EE
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 04:05:50 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id z67so20321084itb.8
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 01:05:50 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id l30si2085957otb.202.2017.04.28.01.05.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Apr 2017 01:05:49 -0700 (PDT)
Subject: Generic approach to customizable zones - was: Re: [PATCH v7 0/7]
 Introduce ZONE_CMA
References: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20170411181519.GC21171@dhcp22.suse.cz>
 <20170412013503.GA8448@js1304-desktop>
 <20170413115615.GB11795@dhcp22.suse.cz>
 <20170417020210.GA1351@js1304-desktop> <20170424130936.GB1746@dhcp22.suse.cz>
 <20170425034255.GB32583@js1304-desktop>
 <20170427150636.GM4706@dhcp22.suse.cz>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <d3c0d01c-ef3f-56f8-2701-a32f8be2d13b@huawei.com>
Date: Fri, 28 Apr 2017 11:04:27 +0300
MIME-Version: 1.0
In-Reply-To: <20170427150636.GM4706@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura
 Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek
 Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On 27/04/17 18:06, Michal Hocko wrote:
> On Tue 25-04-17 12:42:57, Joonsoo Kim wrote:

[...]

>> Yes, it requires one more bit for a new zone and it's handled by the patch.
> 
> I am pretty sure that you are aware that consuming new page flag bits
> is usually a no-go and something we try to avoid as much as possible
> because we are in a great shortage there. So there really have to be a
> _strong_ reason if we go that way. My current understanding that the
> whole zone concept is more about a more convenient implementation rather
> than a fundamental change which will solve unsolvable problems with the
> current approach. More on that below.

Since I am in a similar situation, I think it's better if I join this
conversation instead of going through the same in a separate thread.

In this regard, I have a few observations (are they correct?):

* not everyone seems to be interested in having all the current
  zones active simultaneously

* some zones are even not so meaningful on certain architectures or
  platforms

* some architectures/platforms that are 64 bits would have no penalty
  in dealing with a larger data type.

So I wonder, would anybody be against this:

* within the 32bits constraint, define some optional zones

* decouple the specific position of a bit from the zone it represents;
  iow: if the zone is enabled, ensure that it gets a bit in the mask,
  but do not make promises about which one it is, provided that the
  corresponding macros work properly

* ensure that if one selects more optional zones than there are bits
  available (in the case of a 32bits mask), an error is produced at
  compile time

* if one is happy to have a 64bits type, allow for as many zones as
  it's possible to fit, or anyway more than what is possible with
  the 32 bit mask.

I think I can re-factor the code so that there is no runtime performance
degradation, if there is no immediate objection to what I described. Or
maybe I failed to notice some obvious pitfall?

>From what I see, there seems to be a lot of interest in using functions
like Kmalloc / vmalloc, with the ability of specifying pseudo-custom
areas from where they should tap into.

Why not, as long as those who do not need it are not negatively impacted?

I understand that if the association between bits and zones is fixed,
then suddenly bits become very precious stuff, but if they could be used
in a more efficient way, then maybe they could be used more liberally.

The alternative is to keep getting requests about new zones and turning
them away because they do not pass the bar of being extremely critical,
even if indeed they would simplify people's life.


The change shouldn't be too ugly, if I do something along these lines of
the pseudo code below.
Note: the #ifdefs would be mainly concentrated in the declaration part.

enum gfp_zone_shift {
#if IS_ENABLED(CONFIG_ZONE_DMA)
/*I haven't checked if this is the correct name, but it gives the idea*/
        ZONE_DMA_SHIFT = 0,
#endif
#if IS_ENABLED(CONFIG_ZONE_HIGHMEM)
        ZONE_HIGHMEM_SHIFT,
#endif
#if IS_ENABLED(CONFIG_ZONE_DMA32)
        ZONE_DMA32_SHIFT,
#endif
#if IS_ENABLED(CONFIG_ZONE_xxx)
        ZONE_xxx,
#endif
       NON_OPTIONAL_ZONE_SHIFT,
       ...
       USED_ZONES_NUMBER,
       ZONE_MOVABLE_SHIFT = USED_ZONES_NUMBER,
       ...
};

#if USED_ZONES_NUMBER < MAX_ZONES_32BITS
typedef gfp_zones_t uint32_t
#elif IS_ENABLED(CONFIG_ZONES_64BITS
typedef gfp_zones_t uint64_t
#else
#error
#endif

The type should be adjusted in other places where it is used, but I
didn't find too many occurrences.

#define __ZONE_DMA \
          (((gfp_zones_t)IS_ENABLED(CONFIG_ZONE_DMA)) << \
           (ZONE_DMA_SHIFT - 0))

[rinse and repeat]

Code referring to these optional zones can be sandboxed in

#if IS_ENABLED(CONFIG_ZONE_DMA)

inline function do_something_dma() {
   ....
}

#else
#define do_something_dma()
#endif


Or equivalent, effectively removing many #ifdefs from the main code of
functions like those called by kmalloc.


So, would this approach stand a chance?


thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
