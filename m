Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id B1C526B0039
	for <linux-mm@kvack.org>; Sun, 27 Apr 2014 00:13:52 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id k14so617374wgh.9
        for <linux-mm@kvack.org>; Sat, 26 Apr 2014 21:13:52 -0700 (PDT)
Received: from mail-wg0-x229.google.com (mail-wg0-x229.google.com [2a00:1450:400c:c00::229])
        by mx.google.com with ESMTPS id jp8si5429083wjc.117.2014.04.26.21.13.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 26 Apr 2014 21:13:51 -0700 (PDT)
Received: by mail-wg0-f41.google.com with SMTP id y10so2437754wgg.24
        for <linux-mm@kvack.org>; Sat, 26 Apr 2014 21:13:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAL1ERfMPcfyUeACnmZ2QF5WxJUQ2PaKbtRzis8sPbQsjnvf_GQ@mail.gmail.com>
References: <1397922764-1512-1-git-send-email-ddstreet@ieee.org>
 <1397922764-1512-3-git-send-email-ddstreet@ieee.org> <CAL1ERfMPcfyUeACnmZ2QF5WxJUQ2PaKbtRzis8sPbQsjnvf_GQ@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Sun, 27 Apr 2014 00:13:30 -0400
Message-ID: <CALZtONB4j=yd=cGBnkHy0+H0nyUCwG3PGb4K6XYCyRHA=mqt-g@mail.gmail.com>
Subject: Re: [PATCH 2/4] mm: zpool: implement zsmalloc shrinking
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Weijie Yang <weijie.yang@samsung.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Sat, Apr 26, 2014 at 4:37 AM, Weijie Yang <weijie.yang.kh@gmail.com> wrote:
> On Sat, Apr 19, 2014 at 11:52 PM, Dan Streetman <ddstreet@ieee.org> wrote:
>> Add zs_shrink() and helper functions to zsmalloc.  Update zsmalloc
>> zs_create_pool() creation function to include ops param that provides
>> an evict() function for use during shrinking.  Update helper function
>> fix_fullness_group() to always reinsert changed zspages even if the
>> fullness group did not change, so they are updated in the fullness
>> group lru.  Also update zram to use the new zsmalloc pool creation
>> function but pass NULL as the ops param, since zram does not use
>> pool shrinking.
>>
>
> I only review the code without test, however, I think this patch is
> not acceptable.
>
> The biggest problem is it will call zswap_writeback_entry() under lock,
> zswap_writeback_entry() may sleep, so it is a bug. see below

thanks for catching that!

>
> The 3/4 patch has a lot of #ifdef, I don't think it's a good kind of
> abstract way.

it has the #ifdef's because there's no point in compiling in code to
use zbud/zsmalloc if zbud/zsmalloc isn't compiled...what alternative
to #ifdef's would you suggest?  Or are there just specific #ifdefs you
suggest to remove?

>
> What about just disable zswap reclaim when using zsmalloc?
> There is a long way to optimize writeback reclaim(both zswap and zram) ,
> Maybe a small and simple step forward is better.

I think it's possible to just remove the zspage from the class while
under lock, then unlock and reclaim it.  As long as there's a
guarantee that zswap (or any zpool/zsmalloc reclaim user) doesn't
map/access the handle after evict() completes successfully, that
should work.  There does need to be some synchronization between
zs_free() and each handle's eviction though, similar to zbud's
under_reclaim flag.  I'll work on a v2 patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
