Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21B94C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 22:20:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88E7E2083D
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 22:20:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="SlGmb8rv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88E7E2083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 357278E0004; Fri,  1 Mar 2019 17:20:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 306648E0001; Fri,  1 Mar 2019 17:20:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CEC78E0004; Fri,  1 Mar 2019 17:20:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE7E28E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 17:20:14 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id d18so24058108ywb.2
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 14:20:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=BxTcn8OQ0OnijbnSQJFibQ0Pk5Nx9G5mNEIzIFag6zk=;
        b=XBVd2C4RzDSKOj8K6dokhPzXdzscIuXYpu5S2WI2/0kSSeGmDu/YXzfVC+DRWlTe0z
         GVsboYnNYLegCl8rXlOHLujiBmqAx6RaLsiIu1loec/rmTqPu0jRGhsApEr0HNEyWy97
         cVcPvbfPuJIUjABLtUp2i0+vBqYhwashyJKKI4Vxsvo5GqmyljiJtQo4gh4K7QFcOTi4
         I4p9HV0nxEsVRUpmMQTZJs8afhP7z7uHIoK4lJGhDOmKWMAtHlhxFcYNiIkPeLoEh82U
         fKLZf9dNRRxDTELbQNkKfv5e6hcI9NT1xIt/RqYk31ufl45dKA0pHt1EwzeHHuSUUkNT
         jA/w==
X-Gm-Message-State: APjAAAXFdgUsVO4eYAsARodTKRKhA4kA74hPXhVdnCTpuPh75Jny5ZgA
	UmvyZcH+5c+R1qsWOV/KsO3bpjnM8SLYqNkxFugXIXsz4nKi+QUeznCQZwK+Ak447BHOAE1gYxD
	KzDiM8iSUGPlMk4x7LoargtHbUviTBO9HOS2fboawh8e4TU23GLQcJF29Jp+IptQBL9U2/yqk75
	+mQPwFKN+HKZ1A5DKIOq8GkikpHA0w+itknNxnQOQyslTo3WqvamRGMNu5JWnMx+vouguUSHz9s
	6sJLvLn+nFXnfhjEU1RsO0e+ZrwvibEVb7UBmQo1UxhYGowVfvdsnrmbZkU0lRJoEtOyImVswUU
	mRzwmyTZ/ebQTVnpFLY/8Mm44nNoj7a/rAcnpk5HIYCM+2004C/mt7J/tHGDqnWlLJz1EkwD4y4
	W
X-Received: by 2002:a25:dac6:: with SMTP id n189mr5977063ybf.201.1551478814604;
        Fri, 01 Mar 2019 14:20:14 -0800 (PST)
X-Received: by 2002:a25:dac6:: with SMTP id n189mr5977013ybf.201.1551478813630;
        Fri, 01 Mar 2019 14:20:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551478813; cv=none;
        d=google.com; s=arc-20160816;
        b=q0VmtXy2O8Porp3KNTzT+YLbpHHJXoTZN43X6xbIKUwkPYsafsRficD58e1VTM6M4c
         6eRlWDMmGUyrVlZlEf/DIUp35M4QGhESLpqkZnUb4ULM9en/hlWw6RnkMtlpFpqR3xWh
         X/uVQT0CRzuPqSrZYZoVbfos1f3Cu96SJSddhGFLfxCSx+Wzn8fcCHf+ZlbSe1BaRG17
         V7aDU/qLdT0XfmAFj8bj77lrD2pZWZQzIu4dS5MFwri5Fc8qlBAMV2aMvrDyaMXb4o4T
         Flc63OjF7qbd3eJqc7ZP0qBDIdvgddEISauiEfbk1dvs/0KXSdrPdtVWBUe1XOMTw+e/
         Oy8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=BxTcn8OQ0OnijbnSQJFibQ0Pk5Nx9G5mNEIzIFag6zk=;
        b=Yk/a7YIYbn3JU4c/xrFKdA9g7UD/01VKkd+txrQtQnTHmRRDleO5ZTyMd4yvjhwkEB
         cc+OkyqGO/1FIbXPyivNxfbFDjEj9XtYo1+YPa/RnHkE9XhXLffXQucOLOvOUqwVwkrm
         A82uatZisPHdnlVWVx7qxoeb5LJU+F1jrn37B/0ZLVubcRW4RbN2f/GvL5Qyh7uWPCYt
         8Rl+edEmP5l2pppv7sm5smPvmBqKQfM2TVcJQfDen3j9+pYLbJsqwNHs6bFHvXdEv2Ob
         S0NpeHSet7CR9+GNrhiOBbJvQX5o3lgkS45MOYLfnkkZs8axCG4uuDd2i3Q1CQCgd1lz
         QzPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=SlGmb8rv;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y15sor3343011ywy.42.2019.03.01.14.20.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 14:20:13 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=SlGmb8rv;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=BxTcn8OQ0OnijbnSQJFibQ0Pk5Nx9G5mNEIzIFag6zk=;
        b=SlGmb8rv4kcp/AuNrkYgRhaNnvVL9uXX3R2Roa3cvhO+jgEIT7mhfDi8Oqbp2zEdMj
         M4oai/yld6NP4oVNtKBpOL/DheU6HYcUoGAXWJ9KszUhK8cO+LMYhhje6Ez6hE5GQSkO
         AJyVa7kVRbcRlvr1yRUckYgR/KaKuQor/+h+6mY3Ua7+2Majk63XueogAzSinUsPtcF6
         JIuFJI9tniRZNCU1ZMTRPF89A545j6ooWGtSQ+ztxbcDCrUTIg0KXdPGH7LrCA8+N+pK
         qDgDi7U91AjBwI52CimVJvqm2G1/gdGq7wHU4YRBgY6OlcvuImg8jQgM2q4i+NEG2pyP
         0LEA==
X-Google-Smtp-Source: APXvYqwyPE2gQ+vZOoUSkgtTCllS03utbSx7ymOu/GXpNgdCbrfiwm0L2wkORz3sM6HjAM3D5ys/9w==
X-Received: by 2002:a81:2f94:: with SMTP id v142mr5571580ywv.104.1551478812930;
        Fri, 01 Mar 2019 14:20:12 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::3:5a5b])
        by smtp.gmail.com with ESMTPSA id 130sm7838085ywp.54.2019.03.01.14.20.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 14:20:11 -0800 (PST)
Date: Fri, 1 Mar 2019 17:20:11 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@surriel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>
Subject: Re: [PATCH RFC] mm/vmscan: try to protect active working set of
 cgroup from reclaim.
Message-ID: <20190301222010.GA9215@cmpxchg.org>
References: <20190222175825.18657-1-aryabinin@virtuozzo.com>
 <20190222191552.GA15922@cmpxchg.org>
 <f752c208-599c-9b5a-bc42-e4282df43616@virtuozzo.com>
 <7c915942-6f52-e7a4-b879-e4c99dd65968@virtuozzo.com>
 <20190301174907.GA2375@cmpxchg.org>
 <51ac7aaa-6890-c674-854d-1e2d132b83f9@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51ac7aaa-6890-c674-854d-1e2d132b83f9@virtuozzo.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 01, 2019 at 10:46:34PM +0300, Andrey Ryabinin wrote:
> On 3/1/19 8:49 PM, Johannes Weiner wrote:
> > On Fri, Mar 01, 2019 at 01:38:26PM +0300, Andrey Ryabinin wrote:
> >> On 2/26/19 3:50 PM, Andrey Ryabinin wrote:
> >>> On 2/22/19 10:15 PM, Johannes Weiner wrote:
> >>>> On Fri, Feb 22, 2019 at 08:58:25PM +0300, Andrey Ryabinin wrote:
> >>>>> In a presence of more than 1 memory cgroup in the system our reclaim
> >>>>> logic is just suck. When we hit memory limit (global or a limit on
> >>>>> cgroup with subgroups) we reclaim some memory from all cgroups.
> >>>>> This is sucks because, the cgroup that allocates more often always wins.
> >>>>> E.g. job that allocates a lot of clean rarely used page cache will push
> >>>>> out of memory other jobs with active relatively small all in memory
> >>>>> working set.
> >>>>>
> >>>>> To prevent such situations we have memcg controls like low/max, etc which
> >>>>> are supposed to protect jobs or limit them so they to not hurt others.
> >>>>> But memory cgroups are very hard to configure right because it requires
> >>>>> precise knowledge of the workload which may vary during the execution.
> >>>>> E.g. setting memory limit means that job won't be able to use all memory
> >>>>> in the system for page cache even if the rest the system is idle.
> >>>>> Basically our current scheme requires to configure every single cgroup
> >>>>> in the system.
> >>>>>
> >>>>> I think we can do better. The idea proposed by this patch is to reclaim
> >>>>> only inactive pages and only from cgroups that have big
> >>>>> (!inactive_is_low()) inactive list. And go back to shrinking active lists
> >>>>> only if all inactive lists are low.
> >>>>
> >>>> Yes, you are absolutely right.
> >>>>
> >>>> We shouldn't go after active pages as long as there are plenty of
> >>>> inactive pages around. That's the global reclaim policy, and we
> >>>> currently fail to translate that well to cgrouped systems.
> >>>>
> >>>> Setting group protections or limits would work around this problem,
> >>>> but they're kind of a red herring. We shouldn't ever allow use-once
> >>>> streams to push out hot workingsets, that's a bug.
> >>>>
> >>>>> @@ -2489,6 +2491,10 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
> >>>>>  
> >>>>>  		scan >>= sc->priority;
> >>>>>  
> >>>>> +		if (!sc->may_shrink_active && inactive_list_is_low(lruvec,
> >>>>> +						file, memcg, sc, false))
> >>>>> +			scan = 0;
> >>>>> +
> >>>>>  		/*
> >>>>>  		 * If the cgroup's already been deleted, make sure to
> >>>>>  		 * scrape out the remaining cache.
> >>>>> @@ -2733,6 +2739,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
> >>>>>  	struct reclaim_state *reclaim_state = current->reclaim_state;
> >>>>>  	unsigned long nr_reclaimed, nr_scanned;
> >>>>>  	bool reclaimable = false;
> >>>>> +	bool retry;
> >>>>>  
> >>>>>  	do {
> >>>>>  		struct mem_cgroup *root = sc->target_mem_cgroup;
> >>>>> @@ -2742,6 +2749,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
> >>>>>  		};
> >>>>>  		struct mem_cgroup *memcg;
> >>>>>  
> >>>>> +		retry = false;
> >>>>> +
> >>>>>  		memset(&sc->nr, 0, sizeof(sc->nr));
> >>>>>  
> >>>>>  		nr_reclaimed = sc->nr_reclaimed;
> >>>>> @@ -2813,6 +2822,13 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
> >>>>>  			}
> >>>>>  		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
> >>>>>  
> >>>>> +		if ((sc->nr_scanned - nr_scanned) == 0 &&
> >>>>> +		     !sc->may_shrink_active) {
> >>>>> +			sc->may_shrink_active = 1;
> >>>>> +			retry = true;
> >>>>> +			continue;
> >>>>> +		}
> >>>>
> >>>> Using !scanned as the gate could be a problem. There might be a cgroup
> >>>> that has inactive pages on the local level, but when viewed from the
> >>>> system level the total inactive pages in the system might still be low
> >>>> compared to active ones. In that case we should go after active pages.
> >>>>
> >>>> Basically, during global reclaim, the answer for whether active pages
> >>>> should be scanned or not should be the same regardless of whether the
> >>>> memory is all global or whether it's spread out between cgroups.
> >>>>
> >>>> The reason this isn't the case is because we're checking the ratio at
> >>>> the lruvec level - which is the highest level (and identical to the
> >>>> node counters) when memory is global, but it's at the lowest level
> >>>> when memory is cgrouped.
> >>>>
> >>>> So IMO what we should do is:
> >>>>
> >>>> - At the beginning of global reclaim, use node_page_state() to compare
> >>>>   the INACTIVE_FILE:ACTIVE_FILE ratio and then decide whether reclaim
> >>>>   can go after active pages or not. Regardless of what the ratio is in
> >>>>   individual lruvecs.
> >>>>
> >>>> - And likewise at the beginning of cgroup limit reclaim, walk the
> >>>>   subtree starting at sc->target_mem_cgroup, sum up the INACTIVE_FILE
> >>>>   and ACTIVE_FILE counters, and make inactive_is_low() decision on
> >>>>   those sums.
> >>>>
> >>>
> >>> Sounds reasonable.
> >>>
> >>
> >> On the second thought it seems to be better to keep the decision on lru level.
> >> There are couple reasons for this:
> >>
> >> 1) Using bare node_page_state() (or sc->targe_mem_cgroup's total_[in]active counters) would be wrong.
> >>  Because some cgroups might have protection set (memory.low) and we must take it into account. Also different
> >> cgroups have different available swap space/memory.swappiness and it must be taken into account as well to.
> >>
> >> So it has to be yet another full memcg-tree iteration.
> > 
> > It should be possible to take that into account on the first iteration
> > and adjust the inactive/active counters in proportion to how much of
> > the cgroup's total memory is exempt by memory.low or min, right?
> > 
> 
> Should be possible, more complexity though to this subtle code.
> 
> 
> >> 2) Let's consider simple case. Two cgroups, one with big 'active' set of pages the other allocates one-time used pages.
> >> So the total inactive is low, thus checking inactive ratio on higher level will result in reclaiming pages.
> >> While with check on lru-level only inactive will be reclaimed.
> > 
> > It's the other way around. Let's say you have two cgroups, A and B:
> > 
> >         A:  500M inactive   10G active -> inactive is low
> >         B:   10G inactive  500M active -> inactive is NOT low
> >    ----------------------------------------------------------
> >    global: 10.5G inactive 10.5G active -> inactive is NOT low
> > 
> > Checking locally will scan active pages from A.
> 
> No, checking locally will not scan active from A. Initial state of
> sc->may_shrink_active = 0, so A group will be skipped completely,
> and will reclaim from B. Since overall reclaim was successful,
> sc->may_shrink_active remain 0 and A will be protected as long as B
> supply enough inactive pages.

Oh, this was a misunderstanding. When you wrote "on second thought it
seems to be better to keep the decision at the lru level", I assumed
you were arguing for keeping the current code as-is and abandoning
your patch.

But that leaves my questions from above unanswered. Consider the
following situation:

  A: 50M inactive   0 active
  B:   0 inactive 20G active

If the processes in A and B were not cgrouped, these pages would be on
a single LRU and we'd go after B's active pages.

But with your patches, we'd reclaim only A's inactive pages.

What's the justification for that unfairness?

Keep in mind that users also enable the memory controller on cgroups
simply to keep track of how much memory different process groups are
using.  Merely enabling the controller without otherwise configuring
any protections shouldn't change the aging behavior for that memory.

And that USED to be the case. We USED to have a physical global LRU
list that held all the cgroup pages, and then a per-cgroup LRU list
that was only for limit reclaim.

We got rid of the physical global LRU list for cgrouped memory with
the idea that we can emulate the global aging. Hence the round-robin
tree iteration in shrink_node().

We just need to fix the inactive_list_is_low() check to also emulate
the global LRU behavior.

That would fix your problem of scanning active pages when there are
already plenty of inactive pages in the system, but without the risk
of severely overreclaiming the inactive pages of a small group.

