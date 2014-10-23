Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id E08356B007B
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 10:14:49 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id pv20so912699lab.20
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 07:14:49 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 8si2787179las.83.2014.10.23.07.14.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 07:14:48 -0700 (PDT)
Date: Thu, 23 Oct 2014 10:14:43 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/2] mm: memcontrol: fix missed end-writeback page
 accounting
Message-ID: <20141023141443.GA20526@phnom.home.cmpxchg.org>
References: <1414002568-21042-1-git-send-email-hannes@cmpxchg.org>
 <1414002568-21042-3-git-send-email-hannes@cmpxchg.org>
 <20141023130331.GC23011@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141023130331.GC23011@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 23, 2014 at 03:03:31PM +0200, Michal Hocko wrote:
> On Wed 22-10-14 14:29:28, Johannes Weiner wrote:
> > 0a31bc97c80c ("mm: memcontrol: rewrite uncharge API") changed page
> > migration to uncharge the old page right away.  The page is locked,
> > unmapped, truncated, and off the LRU, but it could race with writeback
> > ending, which then doesn't unaccount the page properly:
> > 
> > test_clear_page_writeback()              migration
> >   acquire pc->mem_cgroup->move_lock
> 
> I do not think that mentioning move_lock is important/helpful here
> because the hot path which is taken all the time (except when there is a
> task move in progress) doesn't take it.
> Besides that it is not even relevant for the race.

You're right.  It's not worth mentioning the transaction setup/finish
at all, because migration does not participate in that protocol.  How
about this?  Andrew, could you please copy-paste this into the patch?

test_clear_page_writeback()              migration
                                           wait_on_page_writeback()
  TestClearPageWriteback()
                                           mem_cgroup_migrate()
                                             clear PCG_USED
  mem_cgroup_update_page_stat()
    if (PageCgroupUsed(pc))
      decrease memcg pages under writeback

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
