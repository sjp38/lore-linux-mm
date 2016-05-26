Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id DAA9C6B0261
	for <linux-mm@kvack.org>; Wed, 25 May 2016 20:32:22 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id m124so55352221itg.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 17:32:22 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 34si13531268iot.168.2016.05.25.17.32.21
        for <linux-mm@kvack.org>;
        Wed, 25 May 2016 17:32:21 -0700 (PDT)
Date: Thu, 26 May 2016 09:32:41 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 11/12] zsmalloc: page migration support
Message-ID: <20160526003241.GA9661@bbox>
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-12-git-send-email-minchan@kernel.org>
 <20160524052824.GA496@swordfish>
 <20160524062801.GB29094@bbox>
 <20160525051438.GA14786@bbox>
 <20160525152345.GA515@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160525152345.GA515@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Sergey,

On Thu, May 26, 2016 at 12:23:45AM +0900, Sergey Senozhatsky wrote:
> Hello Minchan,
> 
> On (05/25/16 14:14), Minchan Kim wrote:
> [..]
> > > > do you also want to kick the deferred page release from the shrinker
> > > > callback, for example?
> > > 
> > > Yeb, it can be. I will do it at next revision. :)
> > > Thanks!
> > > 
> > 
> > I tried it now but I feel strongly we want to fix shrinker first.
> > Now, shrinker doesn't consider VM's request(i.e., sc->nr_to_scan) but
> > shrink all objects which could make latency huge.
> 
> hm... may be.
> 
> I only briefly thought about it a while ago; and have no real data on
> hands. it was something as follows:
> between zs_shrinker_count() and zs_shrinker_scan() a lot can change;
> and _theoretically_ attempting to zs_shrinker_scan() even a smaller
> sc->nr_to_scan still may result in a "full" pool scan, taking all of
> the classes ->locks one by one just because classes are not the same
> as a moment ago. which is even more probable, I think, once the system
> is getting low on memory and begins to swap out, for instance. because
> in the latter case we increase the number of writes to zspool and,
> thus, reduce its chances to be compacted. if the system would still
> demand free memory, then it'd keep calling zs_shrinker_count() and
> zs_shrinker_scan() on us; at some point, I think, zs_shrinker_count()
> would start returning 0. ...if some of the classes would have huge
> fragmentation then we'd keep these class' ->locks for some time,
> moving objects. other than that we probably would just iterate the
> classes.
> 
> purely theoretical.
> 
> do you have any numbers?

Unfortunately, I don't have now. However, I don't feel we need a data for
that because *unbounded work* within VM interaction context is bad. ;-)

> 
> hm, probably it makes sense to change it. but if the change will
> replace "1 full pool scan" to "2 scans of 1/2 of pool's classes",
> then I'm less sure.

Other shrinker is on same page. They have *cache* which is helpful for
performance but if it's not hot, it can lose performance if memory
pressure is severe. For the balance, comprimise approach is shrinker.

We can see fragement space in zspage as wasted memory which is bad
on the other hand we can see it as cache to store upcoming compressed
page. So, too much freeing can hurt the performance so, let's obey
VM's rule. If memory pressure goes severe, they want to reclaim more
pages with proportional of memory pressure.

> 
> > I want to fix it as another issue and then adding ZS_EMPTY pool pages
> > purging logic based on it because many works for zsmalloc stucked
> > with this patchset now which churns old code heavily. :(
> 
> 	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
