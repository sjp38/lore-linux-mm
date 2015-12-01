Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id EB97D6B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 06:52:28 -0500 (EST)
Received: by wmww144 with SMTP id w144so169411927wmw.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 03:52:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n10si58096634wjb.164.2015.12.01.03.52.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 01 Dec 2015 03:52:27 -0800 (PST)
Date: Tue, 1 Dec 2015 11:52:20 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: vmscan: Obey indeed proportional scanning for kswapd
 and memcg
Message-ID: <20151201115220.GZ19677@suse.de>
References: <1448426900-2907-1-git-send-email-baiyaowei@cmss.chinamobile.com>
 <20151125112851.GP19677@suse.de>
 <20151130090444.GA2520@yaowei-K42JY>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20151130090444.GA2520@yaowei-K42JY>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: akpm@linux-foundation.org, riel@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, jslaby@suse.cz, Valdis.Kletnieks@vt.edu, zcalusic@bitsync.net, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 30, 2015 at 05:04:44PM +0800, Yaowei Bai wrote:
> On Wed, Nov 25, 2015 at 11:28:51AM +0000, Mel Gorman wrote:
> > On Wed, Nov 25, 2015 at 12:48:20PM +0800, Yaowei Bai wrote:
> > > Commit e82e0561dae9f3ae5 ("mm: vmscan: obey proportional scanning
> > > requirements for kswapd") intended to preserve the proportional scanning
> > > and reclaim what was requested by get_scan_count() for kswapd and memcg
> > > by stopping reclaiming one type(anon or file) LRU and reducing the other's
> > > amount of scanning proportional to the original scan target.
> > > 
> > > So the way to determine which LRU should be stopped reclaiming should be
> > > comparing scanned/unscanned percentages to the original scan target of two
> > > lru types instead of absolute values what implemented currently, because
> > > larger absolute value doesn't mean larger percentage, there shall be
> > > chance that larger absolute value with smaller percentage, for instance:
> > > 
> > > 	target_file = 1000
> > > 	target_anon = 500
> > > 	nr_file = 500
> > > 	nr_anon = 400
> > > 
> > > in this case, because nr_file > nr_anon, according to current implement,
> > > we will stop scanning anon lru and shrink file lru. This breaks
> > > proportional scanning intent and makes more unproportional.
> > > 
> > > This patch changes to compare percentage to the original scan target to
> > > determine which lru should be shrunk.
> > > 
> > > Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
> > 
> > This one has gone back and forth a few times in the past. It really was
> 
> Sorry for reply late. Yes, I noticed Johannes Weiner has recommended this in
> the discussion thread about commit e82e0561dae9f3ae5 ("mm: vmscan: obey
> proportional scanning requirements for kswapd"):
> 
>  http://marc.info/?l=linux-kernel&m=136397130117394&w=2
> 
> and you thought it was out of scope of that series at that moment.
> But i didn't see this in the upstream git history.
> 

It was out of scope for the series at the time. The idea is still
interesting but it really needs to be quantified in some manner.

> > <SNIP>
> >
> > I see what your concern is, it's unclear what the actual impact is. Have
> > you done any testing to check if the proposed new behaviour is actually
> > better?
> 
> I didn't test this patch. Maybe it's difficult to catch this situation of
> the example case because mostly we scan LRUs evenly. but i think it's advantage
> is also obvious because it covers the case mentioned above to achieve indeed
> proportional without introducing extra overhead and makes the code match with
> the comments and more understandable to reduce people's confusion.
> 
> Did i miss something?
> 

It really needs to be tested and have some sort of supporting data
showing that it at least does no harm and ideally helps something
worthwhile.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
