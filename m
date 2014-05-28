Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9F36B0036
	for <linux-mm@kvack.org>; Wed, 28 May 2014 07:31:11 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id gl10so7346455lab.11
        for <linux-mm@kvack.org>; Wed, 28 May 2014 04:31:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g8si31357861wjf.122.2014.05.28.04.31.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 May 2014 04:31:09 -0700 (PDT)
Date: Wed, 28 May 2014 13:31:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 6/9] mm: memcontrol: remove ordering between
 pc->mem_cgroup and PageCgroupUsed
Message-ID: <20140528113107.GF9895@dhcp22.suse.cz>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
 <1398889543-23671-7-git-send-email-hannes@cmpxchg.org>
 <20140523132043.GB22135@dhcp22.suse.cz>
 <20140527194500.GC2878@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140527194500.GC2878@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 27-05-14 15:45:00, Johannes Weiner wrote:
> On Fri, May 23, 2014 at 03:20:43PM +0200, Michal Hocko wrote:
> > On Wed 30-04-14 16:25:40, Johannes Weiner wrote:
> > > There is a write barrier between setting pc->mem_cgroup and
> > > PageCgroupUsed, which was added to allow LRU operations to lookup the
> > > memcg LRU list of a page without acquiring the page_cgroup lock.  But
> > > ever since 38c5d72f3ebe ("memcg: simplify LRU handling by new rule"),
> > > pages are ensured to be off-LRU while charging, so nobody else is
> > > changing LRU state while pc->mem_cgroup is being written.
> > 
> > This is quite confusing. Why do we have the lrucare path then?
> 
> Some charge paths start with the page on the LRU, lrucare makes sure
> it's off during the charge.

Yeah, I know I just wanted to point that the changelog might be
confusing and so mentioning this aspect would be nice...

> > The code is quite tricky so this deserves a more detailed explanation
> > IMO.
> > 
> > There are only 3 paths which check both the flag and mem_cgroup (
> > without page_cgroup_lock) get_mctgt_type* and mem_cgroup_page_lruvec AFAICS.
> > None of them have rmb so there was no guarantee about ordering anyway.
> 
> Yeah, exactly.  As per the changelog, this is a remnant of the way it
> used to work but it's no longer needed because of guaranteed off-LRU
> state.
> 
> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > 
> > Anyway, the change is welcome
> > Acked-by: Michal Hocko <mhocko@suse.cz>
> 
> Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
