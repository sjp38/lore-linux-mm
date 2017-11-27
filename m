Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1EAE56B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 00:16:47 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id d86so12379131pfk.19
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 21:16:47 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id s10si24578502pfi.394.2017.11.26.21.16.45
        for <linux-mm@kvack.org>;
        Sun, 26 Nov 2017 21:16:45 -0800 (PST)
Date: Mon, 27 Nov 2017 14:16:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/vmscan: make do_shrink_slab more robust.
Message-ID: <20171127051643.GA27449@bbox>
References: <20171127023912.GB27255@bbox>
 <201711271246270445123@zte.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711271246270445123@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jiang.biao2@zte.com.cn
Cc: akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, linux-mm@kvack.org, mgorman@techsingularity.net, linux-kernel@vger.kernel.org, zhong.weidong@zte.com.cn

On Mon, Nov 27, 2017 at 12:46:27PM +0800, jiang.biao2@zte.com.cn wrote:
> On Mon, Nov 27, 2017 at 09:37:30AM +0800, Jiang Biao wrote:> >
> > > This patch make do_shrink_slab more robust when
> > > shrinker->count_objects return negative freeable.
> > 
> > Shrinker.h says count_objects should return 0 if there are no
> > freeable objects, not -1.
> > 
> > So if something returns -1, changing it with returning 0 would
> > be more proper fix.
> > 
> Hi,
> Indeed it's not a bug of vmscan, but there are many shrinkers
> out there, which may return negative value unwillingly(in some 
> rare cases, such as decreasing cocurrently). It's unlikely and 
> should be avioded, but not impossible, this patch may make it 
> more robust and could not hurt :).

Yub, I'm not strong against of your claim. However, let's think
from different point of view.

API says it should return 0 unless shrinker cannot find freeable
object any more but with your change, implmentation handles
although a shrinker return minus value by mistake.

In future, MM guys might want to extend count_objects returning
-ERR_SOMETHING to propagate error, for example but we cannot.
Because some of shrinkers already rely on the implementation so
if we start to support minus value return, some of shrinker might
be broken.

Yes, it's the imaginary scenario but wanted why such changes
makes us trouble in future, API PoV.

Other way is you can change the description so that count_scan
API can return any value if it's less or equal to zero but not
sure it's worth. Anyway, maintainer will judge but my opinion
is not worth to do at this moment. We have been happy for a
long time without that.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
