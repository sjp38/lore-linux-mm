Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id C91F96B0031
	for <linux-mm@kvack.org>; Sat, 11 Jan 2014 13:39:00 -0500 (EST)
Received: by mail-bk0-f47.google.com with SMTP id mx12so1954254bkb.20
        for <linux-mm@kvack.org>; Sat, 11 Jan 2014 10:38:58 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id lk6si6438131bkb.132.2014.01.11.10.38.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 11 Jan 2014 10:38:58 -0800 (PST)
Date: Sat, 11 Jan 2014 13:38:55 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Help] Question about vm: fair zone allocator policy
Message-ID: <20140111183855.GA4407@cmpxchg.org>
References: <CANwX7LTkb3v6Aq9nqFWN-cykX08+fuAntFMDRu7DM_pcyK9iSw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANwX7LTkb3v6Aq9nqFWN-cykX08+fuAntFMDRu7DM_pcyK9iSw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yvxiang <linyvxiang@gmail.com>
Cc: linux-mm@kvack.org

On Tue, Jan 07, 2014 at 09:37:01AM +0800, yvxiang wrote:
> Hi, Johannes
> 
>      I'm a new comer to vm. And I read your commit 81c0a2bb about fair zone
> allocator policy,  but I don't quite understand your opinion, especially
> the words that
> 
>    "the allocator may keep kswapd running while kswapd reclaim
>     ensures that the page allocator can keep allocating from the first zone
> in
>     the zonelist for extended periods of time. "
> 
>     Could you or someone else explain me what does this mean in more
> details? Or could you give me a example?

The page allocator tries to allocate from all zones in order of
preference: Normal, DMA32, DMA.  If they are all at their low
watermark, kswapd is woken up and it will reclaim each zone until it's
back to the high watermark.

But as kswapd reclaims the Normal zone, the page allocator can
continue allocating from it.  If that happens at roughly the same
pace, the Normal zone's watermark will hover somewhere between the low
and high watermark.  Kswapd will not go to sleep and the page
allocator will not use the other zones.

The whole workload's memory will be allocated and reclaimed using only
the Normal zone, which might be only a few (hundred) megabytes, while
the 4G DMA32 zone is unused.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
