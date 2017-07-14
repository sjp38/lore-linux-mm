Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9E207440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 05:59:35 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g46so10890758wrd.3
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 02:59:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p14si1860937wma.78.2017.07.14.02.59.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 02:59:34 -0700 (PDT)
Date: Fri, 14 Jul 2017 10:59:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 7/9] mm, page_alloc: remove stop_machine from
 build_all_zonelists
Message-ID: <20170714095932.jihl6h3y77hxyyiu@suse.de>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-8-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170714080006.7250-8-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Fri, Jul 14, 2017 at 10:00:04AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> build_all_zonelists has been (ab)using stop_machine to make sure that
> zonelists do not change while somebody is looking at them. This is
> is just a gross hack because a) it complicates the context from which
> we can call build_all_zonelists (see 3f906ba23689 ("mm/memory-hotplug:
> switch locking to a percpu rwsem")) and b) is is not really necessary
> especially after "mm, page_alloc: simplify zonelist initialization".
> 
> Updates of the zonelists happen very seldom, basically only when a zone
> becomes populated during memory online or when it loses all the memory
> during offline. A racing iteration over zonelists could either miss a
> zone or try to work on one zone twice. Both of these are something we
> can live with occasionally because there will always be at least one
> zone visible so we are not likely to fail allocation too easily for
> example.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

This patch is contingent on the last patch which updates in place
instead of zeroing the early part of the zonelist first but needs to fix
the stack usage issues. I think it's also worth pointing out in the
changelog that stop_machine never gave the guarantees it claimed as a
process iterating through the zonelist can be stopped so when it resumes
the zonelist has changed underneath it. Doing it online is roughly
equivalent in terms of safety.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
