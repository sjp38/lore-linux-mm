Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4A56B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 12:28:02 -0500 (EST)
Received: by wgha1 with SMTP id a1so34906428wgh.5
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 09:28:02 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id dh7si1942450wjc.45.2015.03.02.09.28.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 09:28:00 -0800 (PST)
Date: Mon, 2 Mar 2015 12:27:50 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150302172750.GA24379@phnom.home.cmpxchg.org>
References: <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150302151832.GE26334@dhcp22.suse.cz>
 <20150302160537.GA23072@phnom.home.cmpxchg.org>
 <20150302171058.GI26334@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150302171058.GI26334@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Mon, Mar 02, 2015 at 06:10:58PM +0100, Michal Hocko wrote:
> On Mon 02-03-15 11:05:37, Johannes Weiner wrote:
> > On Mon, Mar 02, 2015 at 04:18:32PM +0100, Michal Hocko wrote:
> [...]
> > > Typical busy system won't be very far away from the high watermark
> > > so there would be a reclaim performed during increased watermaks
> > > (aka reservation) and that might lead to visible performance
> > > degradation. This might be acceptable but it also adds a certain level
> > > of unpredictability when performance characteristics might change
> > > suddenly.
> > 
> > There is usually a good deal of clean cache.  As Dave pointed out
> > before, clean cache can be considered re-allocatable from NOFS
> > contexts, and so we'd only have to maintain this invariant:
> > 
> > 	min_wmark + private_reserves < free_pages + clean_cache
> 
> Do I understand you correctly that we do not have to reclaim clean pages
> as per the above invariant?
> 
> If yes, how do you reflect overcommit on the clean_cache from multiple
> requestor (who are doing reservations)?
> My point was that if we keep clean pages on the LRU rather than forcing
> to reclaim them via increased watermarks then it might happen that
> different callers with access to reserves wouldn't get promissed amount
> of reserved memory because clean_cache is basically a shared resource.

The sum of all private reservations has to be accounted globally, we
obviously can't overcommit the available resources in order to solve
problems stemming from overcommiting the available resources.

The page allocator can't hand out free pages and page reclaim can not
reclaim clean cache unless that invariant is met.  They both have to
consider them consumed.  It's the same as pre-allocation, the only
thing we save is having to actually reclaim the pages and take them
off the freelist at reservation time - which is a good optimization
since the filesystem might not actually need them all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
