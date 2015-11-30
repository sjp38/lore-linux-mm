Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 05A386B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 04:05:10 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so178843729pac.3
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 01:05:09 -0800 (PST)
Received: from cmccmta1.chinamobile.com (cmccmta1.chinamobile.com. [221.176.66.79])
        by mx.google.com with ESMTP id c4si1316920pfd.43.2015.11.30.01.05.08
        for <linux-mm@kvack.org>;
        Mon, 30 Nov 2015 01:05:08 -0800 (PST)
Date: Mon, 30 Nov 2015 17:04:44 +0800
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: Re: [PATCH] mm: vmscan: Obey indeed proportional scanning for kswapd
 and memcg
Message-ID: <20151130090444.GA2520@yaowei-K42JY>
References: <1448426900-2907-1-git-send-email-baiyaowei@cmss.chinamobile.com>
 <20151125112851.GP19677@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151125112851.GP19677@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: akpm@linux-foundation.org, riel@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, jslaby@suse.cz, Valdis.Kletnieks@vt.edu, zcalusic@bitsync.net, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 25, 2015 at 11:28:51AM +0000, Mel Gorman wrote:
> On Wed, Nov 25, 2015 at 12:48:20PM +0800, Yaowei Bai wrote:
> > Commit e82e0561dae9f3ae5 ("mm: vmscan: obey proportional scanning
> > requirements for kswapd") intended to preserve the proportional scanning
> > and reclaim what was requested by get_scan_count() for kswapd and memcg
> > by stopping reclaiming one type(anon or file) LRU and reducing the other's
> > amount of scanning proportional to the original scan target.
> > 
> > So the way to determine which LRU should be stopped reclaiming should be
> > comparing scanned/unscanned percentages to the original scan target of two
> > lru types instead of absolute values what implemented currently, because
> > larger absolute value doesn't mean larger percentage, there shall be
> > chance that larger absolute value with smaller percentage, for instance:
> > 
> > 	target_file = 1000
> > 	target_anon = 500
> > 	nr_file = 500
> > 	nr_anon = 400
> > 
> > in this case, because nr_file > nr_anon, according to current implement,
> > we will stop scanning anon lru and shrink file lru. This breaks
> > proportional scanning intent and makes more unproportional.
> > 
> > This patch changes to compare percentage to the original scan target to
> > determine which lru should be shrunk.
> > 
> > Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
> 
> This one has gone back and forth a few times in the past. It really was

Sorry for reply late. Yes, I noticed Johannes Weiner has recommended this in
the discussion thread about commit e82e0561dae9f3ae5 ("mm: vmscan: obey
proportional scanning requirements for kswapd"):

 http://marc.info/?l=linux-kernel&m=136397130117394&w=2

and you thought it was out of scope of that series at that moment.
But i didn't see this in the upstream git history.

> deliberate that the scanning was proportional to the scan target. While

Yes, i see the evolvement of the source code and do believe that the scanning
was proportional to the scan target is the right direction and we're already in
that direction with current implementation. At the very beginning, you wanted
to subtract min from all of LRUs to perform proportional scan and i think that
is a very good start and simple and useful enough approxiamtion. And then Johannes
Weiner suggersted that swappiness is about page types and comparing the sum of
file pages with the sum of anon pages and then knocking out the smaller pair would
be better.You agreed and implemented it with applying scanned percentage of the
smaller pair to the remaining LRUs. But considering the example case mentioned
above we will scan even more unproportionally as we cann't guarantee scanning
all LRUs 100% evenly.

> I see what your concern is, it's unclear what the actual impact is. Have
> you done any testing to check if the proposed new behaviour is actually
> better?

I didn't test this patch. Maybe it's difficult to catch this situation of
the example case because mostly we scan LRUs evenly. but i think it's advantage
is also obvious because it covers the case mentioned above to achieve indeed
proportional without introducing extra overhead and makes the code match with
the comments and more understandable to reduce people's confusion.

Did i miss something?

> 
> -- 
> Mel Gorman
> SUSE Labs


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
