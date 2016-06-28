Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 363086B0005
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 12:48:46 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id at7so43863718obd.1
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 09:48:46 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0132.outbound.protection.outlook.com. [157.56.112.132])
        by mx.google.com with ESMTPS id k20si16996102otb.178.2016.06.28.09.48.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 28 Jun 2016 09:48:45 -0700 (PDT)
Date: Tue, 28 Jun 2016 19:48:34 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm, vmscan: set shrinker to the left page count
Message-ID: <20160628164834.GB30658@esperanza>
References: <1467025335-6748-1-git-send-email-puck.chen@hisilicon.com>
 <20160627165723.GW21652@esperanza>
 <57725364.60307@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <57725364.60307@hisilicon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, labbott@redhat.com, suzhuangluan@hisilicon.com, oliver.fu@hisilicon.com, puck.chen@foxmail.com, dan.zhao@hisilicon.com, saberlily.xia@hisilicon.com, xuyiping@hisilicon.com

On Tue, Jun 28, 2016 at 06:37:24PM +0800, Chen Feng wrote:
> Thanks for you reply.
> 
> On 2016/6/28 0:57, Vladimir Davydov wrote:
> > On Mon, Jun 27, 2016 at 07:02:15PM +0800, Chen Feng wrote:
> >> In my platform, there can be cache a lot of memory in
> >> ion page pool. When shrink memory the nr_to_scan to ion
> >> is always to little.
> >> to_scan: 395  ion_pool_cached: 27305
> > 
> > That's OK. We want to shrink slabs gradually, not all at once.
> > 
> 
> OKi 1/4 ? But my question there are a lot of memory waiting for free.
> But the to_scan is too little.

Small value of 'total_scan' in comparison to 'freeable' (in shrink_slab)
means that memory pressure is not really high and so there's no need to
scan all cached objects yet.

> 
> So, the lowmemorykill may kill the wrong process.
> >>
> >> Currently, the shrinker nr_deferred is set to total_scan.
> >> But it's not the real left of the shrinker.
> > 
> > And it shouldn't. The idea behind nr_deferred is following. A shrinker
> > may return SHRINK_STOP if the current allocation context doesn't allow
> > to reclaim its objects (e.g. reclaiming inodes under GFP_NOFS is
> > deadlock prone). In this case we can't call the shrinker right now, but
> > if we just forget about the batch we are supposed to reclaim at the
> > current iteration, we can wind up having too many of these objects so
> > that they start to exert unfairly high pressure on user memory. So we
> > add the amount that we wanted to scan but couldn't to nr_deferred, so
> > that we can catch up when we get to shrink_slab() with a proper context.
> > 
> I am confused with your comments. If the shrinker return STOP this time.
> It also can return STOP next time.

There's always kswapd running in background which calls reclaim with
GFP_KERNEL. So even if a process issues a lot of successive GFP_NOFS,
which makes fs shrinkers abort scan, their objects will still be scanned
and reclaimed by kswapd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
