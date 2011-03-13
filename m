Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 102268D003B
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 20:22:45 -0500 (EST)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p2D1MfYq010969
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 17:22:41 -0800
Received: from pvf33 (pvf33.prod.google.com [10.241.210.97])
	by wpaz1.hot.corp.google.com with ESMTP id p2D1MaxW020664
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 17:22:39 -0800
Received: by pvf33 with SMTP id 33so924317pvf.24
        for <linux-mm@kvack.org>; Sat, 12 Mar 2011 17:22:39 -0800 (PST)
Date: Sat, 12 Mar 2011 17:22:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 00/25]: Propagating GFP_NOFS inside __vmalloc()
In-Reply-To: <AANLkTiniwDx0wjYT439JSBuT=DA12OF_eAVQ782GfJ7W@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1103121717500.10317@chino.kir.corp.google.com>
References: <AANLkTimU2QGc_BVxSWCN8GEhr8hCOi1Zp+eaA20_pE-w@mail.gmail.com> <alpine.DEB.2.00.1103111258340.31216@chino.kir.corp.google.com> <AANLkTiniwDx0wjYT439JSBuT=DA12OF_eAVQ782GfJ7W@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anand Mitra <anand.mitra@gmail.com>
Cc: Prasad Joshi <prasadjoshi124@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, 11 Mar 2011, Anand Mitra wrote:

> I'll repeat my understanding of the scenario you have pointed out to
> make sure we have understood you correctly.
> 
> On the broad level the changes will cause a __GFP_NOFS flag to be
> present in pte allocation which were earlier absent. The impact of
> this is serious when both __GFP_REPEAT and __GFP_NOFS is set because
> 
> 1) __GFP_NOFS will result in very few pages being reclaimed (can't go
>    to the filesystems)
> 2) __GFP_REPEAT will cause both the reclaim and allocation to retry
>    more aggressively if not indefinitely based on the influence the
>    flag in functions should_alloc_retry & should_continue_reclaim
> 

Yes, __GFP_REPEAT will loop in the page allocator forever if no pages can 
be reclaimed, probably as the result of being !__GFP_FS -- the oom killer 
also won't kill any processes to free memory because it requires __GFP_FS 
(to ensure we don't kill something unnecessarily just because this 
allocation is !__GFP_FS and direct reclaim has a high liklihood of 
failure).

> Effectively we need memory for use by the filesystem but we can't go
> back to the filesystem to claim it. Without the suggested patch we
> would actually try to claim space from the filesystem which would work
> most of the times but would deadlock occasionally. With the suggested
> patch as you have pointed out we can possibly get into a low memory
> hang. I am not sure there is a way out of this, should this be
> considered as genuinely low memory condition out of which the system
> might or might not crawl out of ?
> 

As suggested in my email, I think you should pass "GFP_KERNEL | 
__GFP_REPEAT" into the lower level functions in this patchset instead of 
just GFP_KERNEL and not hard-wire __GFP_REPEAT into the lower level 
functions.  GFP_NOFS | __GFP_REPEAT is a very risky combination that 
shouldn't be used anywhere in the kernel because it risks infinitely 
looping in the page allocator when memory is low.  The callers passing 
only GFP_NOFS should handle the possiblity of returning NULL 
appropraitely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
