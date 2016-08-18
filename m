Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8C03A6B026E
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 05:48:48 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e7so9092079lfe.0
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 02:48:48 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id e126si29238107wmd.17.2016.08.18.02.48.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 02:48:47 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id o80so4545275wme.0
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 02:48:47 -0700 (PDT)
Date: Thu, 18 Aug 2016 11:48:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 06/11] mm, compaction: more reliably increase direct
 compaction priority
Message-ID: <20160818094844.GG30162@dhcp22.suse.cz>
References: <20160810091226.6709-1-vbabka@suse.cz>
 <20160810091226.6709-7-vbabka@suse.cz>
 <20160818091036.GF30162@dhcp22.suse.cz>
 <1f761527-ed12-ba16-0565-c64d14e200eb@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1f761527-ed12-ba16-0565-c64d14e200eb@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 18-08-16 11:44:00, Vlastimil Babka wrote:
> On 08/18/2016 11:10 AM, Michal Hocko wrote:
> > On Wed 10-08-16 11:12:21, Vlastimil Babka wrote:
> > > During reclaim/compaction loop, compaction priority can be increased by the
> > > should_compact_retry() function, but the current code is not optimal. Priority
> > > is only increased when compaction_failed() is true, which means that compaction
> > > has scanned the whole zone. This may not happen even after multiple attempts
> > > with a lower priority due to parallel activity, so we might needlessly
> > > struggle on the lower priorities and possibly run out of compaction retry
> > > attempts in the process.
> > > 
> > > After this patch we are guaranteed at least one attempt at the highest
> > > compaction priority even if we exhaust all retries at the lower priorities.
> > 
> > I expect we will tend to do some special handling at the highest
> > priority so guaranteeing at least one run with that prio seems sensible to me. The only
> > question is whether we really want to enforce the highest priority for
> > costly orders as well. I think we want to reserve the highest (maybe add
> > one more) prio for !costly orders as those invoke the OOM killer and the
> > failure are quite disruptive.
> 
> Costly orders are already ruled out of reaching the highest priority unless
> they are __GFP_REPEAT, so I assumed that if they are allocations with
> __GFP_REPEAT, they really would like to succeed, so let them use the highest
> priority.

But even when __GFP_REPEAT is set then we do not want to be too
aggressive. E.g. hugetlb pages are better to fail than the cause
excessive reclaim or cause some long term fragmentation issues which
might be a result of the skipped heuristics. costly orders are IMHO
simply second class citizens even with they ask to try harder with
__GFP_REPEAT.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
