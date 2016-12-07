Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B19466B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 12:35:09 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id i131so39733404wmf.3
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 09:35:09 -0800 (PST)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id d10si25365253wjc.187.2016.12.07.09.35.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Dec 2016 09:35:08 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id E8E7598DBF
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 17:35:07 +0000 (UTC)
Date: Wed, 7 Dec 2016 17:35:07 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
Message-ID: <20161207173507.abvj3tp3vh6es3yz@techsingularity.net>
References: <20161207101228.8128-1-mgorman@techsingularity.net>
 <alpine.DEB.2.20.1612070849260.8398@east.gentwo.org>
 <20161207155750.yfsizliaoodks5k4@techsingularity.net>
 <alpine.DEB.2.20.1612071037480.11056@east.gentwo.org>
 <20161207164554.b73qjfxy2w3h3ycr@techsingularity.net>
 <alpine.DEB.2.20.1612071109160.11056@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1612071109160.11056@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, Dec 07, 2016 at 11:11:08AM -0600, Christoph Lameter wrote:
> On Wed, 7 Dec 2016, Mel Gorman wrote:
> 
> > 3.0-era kernels had better fragmentation control, higher success rates at
> > allocation etc. I vaguely recall that it had fewer sources of high-order
> > allocations but I don't remember specifics and part of that could be the
> > lack of THP at the time. The overhead was massive due to massive stalls
> > and excessive reclaim -- hours to complete some high-allocation stress
> > tests even if the success rate was high.
> 
> There were a couple of high order page reclaim improvements implemented
> at that time that were later abandoned. I think higher order pages were
> more available than now.

There were, the cost was high -- lumpy reclaim was a major source of the
cost but not the only one. The cost of allocation offset any benefit of
having them. At least for hugepages it did, I don't know about SLUB because
I didn't quantify if the benefit of SLUB using huge pages was offset by
the allocation cost (I doubt it). The cost later became intolerable when
THP started hitting those paths routinely.

It's not simply a case of going back to how fragmentation control was
managed then because it'll simply reintroduce excessive stalls in
allocation paths.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
