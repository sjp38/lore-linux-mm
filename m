Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 006A26B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 14:05:34 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id q1so3327344lam.8
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 11:05:34 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id jw6si24294155lbc.101.2014.10.22.11.05.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Oct 2014 11:05:33 -0700 (PDT)
Date: Wed, 22 Oct 2014 14:05:27 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: fix missed end-writeback accounting
Message-ID: <20141022180527.GA18998@phnom.home.cmpxchg.org>
References: <1413915550-5651-1-git-send-email-hannes@cmpxchg.org>
 <20141022163051.GH30802@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141022163051.GH30802@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 22, 2014 at 06:30:51PM +0200, Michal Hocko wrote:
> On Tue 21-10-14 14:19:10, Johannes Weiner wrote:
> > 0a31bc97c80c ("mm: memcontrol: rewrite uncharge API") changed page
> > migration to uncharge the old page right away.  The page is locked,
> > unmapped, truncated, and off the LRU.  But it could race with a
> > finishing writeback, which then doesn't get unaccounted properly:
> > 
> > test_clear_page_writeback()              migration
> >   acquire pc->mem_cgroup->move_lock
> >                                            wait_on_page_writeback()
> >   TestClearPageWriteback()
> >                                            mem_cgroup_migrate()
> >                                              clear PCG_USED
> >   if (PageCgroupUsed(pc))
> >     decrease memcg pages under writeback
> >   release pc->mem_cgroup->move_lock
> > 
> > One solution for this would be to simply remove the PageCgroupUsed()
> > check, as RCU protects the memcg anyway.
> > 
> > However, it's more robust to acknowledge that migration is really
> > modifying the charge state of alive pages in this case, and so it
> > should participate in the protocol specifically designed for this.
> 
> It's been a long day so I might be missing something really obvious
> here. But how can move_lock help here when the fast path (no task
> migration is going on) takes only RCU read lock?

Argh, I actually noticed this issue while working on the page stat
simplification and thought I could break out a more isolated fix.  But
you are right, that won't be enough, and I can't possibly put a RCU
grace period in mem_cgroup_migration().

I also just realized that we can't remove the PageCgroupUsed() check
when updating the page stat, either, because the "fast path" start of
the transaction does not verify the memcg for us - we can't tell
whether it's gone stale before or during the transaction.  Grrr.

Andrew, please scratch this patch and the next 4-part series that
reworks the page stat updates.  I'll send a reduced version of it
that's marked for 3.17-stable.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
