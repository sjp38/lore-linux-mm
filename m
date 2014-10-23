Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0E8E4900019
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 10:52:00 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id z11so982772lbi.13
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 07:51:59 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xc4si2945636lbb.82.2014.10.23.07.51.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Oct 2014 07:51:58 -0700 (PDT)
Date: Thu, 23 Oct 2014 16:51:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2] mm: memcontrol: fix missed end-writeback page
 accounting
Message-ID: <20141023145156.GG23011@dhcp22.suse.cz>
References: <1414002568-21042-1-git-send-email-hannes@cmpxchg.org>
 <1414002568-21042-3-git-send-email-hannes@cmpxchg.org>
 <20141023130331.GC23011@dhcp22.suse.cz>
 <20141023141443.GA20526@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141023141443.GA20526@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 23-10-14 10:14:43, Johannes Weiner wrote:
> On Thu, Oct 23, 2014 at 03:03:31PM +0200, Michal Hocko wrote:
> > On Wed 22-10-14 14:29:28, Johannes Weiner wrote:
> > > 0a31bc97c80c ("mm: memcontrol: rewrite uncharge API") changed page
> > > migration to uncharge the old page right away.  The page is locked,
> > > unmapped, truncated, and off the LRU, but it could race with writeback
> > > ending, which then doesn't unaccount the page properly:
> > > 
> > > test_clear_page_writeback()              migration
> > >   acquire pc->mem_cgroup->move_lock
> > 
> > I do not think that mentioning move_lock is important/helpful here
> > because the hot path which is taken all the time (except when there is a
> > task move in progress) doesn't take it.
> > Besides that it is not even relevant for the race.
> 
> You're right.  It's not worth mentioning the transaction setup/finish
> at all, because migration does not participate in that protocol.  How
> about this?  Andrew, could you please copy-paste this into the patch?
> 
> test_clear_page_writeback()              migration
>                                            wait_on_page_writeback()
>   TestClearPageWriteback()
>                                            mem_cgroup_migrate()
>                                              clear PCG_USED
>   mem_cgroup_update_page_stat()
>     if (PageCgroupUsed(pc))
>       decrease memcg pages under writeback

Yes, much better! Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
