Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9A67E6B0031
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 15:29:04 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id n3so6761430wiv.17
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 12:29:04 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id bd1si411063wjc.5.2014.07.16.12.29.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 12:29:03 -0700 (PDT)
Received: by mail-wi0-f172.google.com with SMTP id n3so6761391wiv.17
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 12:29:02 -0700 (PDT)
Date: Wed, 16 Jul 2014 21:28:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/3] mm: memcontrol: rewrite uncharge API fix - double
 migration
Message-ID: <20140716192859.GA28105@dhcp22.suse.cz>
References: <1404759133-29218-1-git-send-email-hannes@cmpxchg.org>
 <1404759133-29218-3-git-send-email-hannes@cmpxchg.org>
 <alpine.LSU.2.11.1407141246340.17669@eggly.anvils>
 <20140715144539.GR29639@cmpxchg.org>
 <20140716083456.GC7121@dhcp22.suse.cz>
 <20140716160414.GA29639@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140716160414.GA29639@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 16-07-14 12:04:14, Johannes Weiner wrote:
> On Wed, Jul 16, 2014 at 10:34:56AM +0200, Michal Hocko wrote:
> > [Sorry I have missed this thread]
> > 
> > On Tue 15-07-14 10:45:39, Johannes Weiner wrote:
> > [...]
> > > From 274b94ad83b38fe7dc1707a8eb4015b3ab1673c5 Mon Sep 17 00:00:00 2001
> > > From: Johannes Weiner <hannes@cmpxchg.org>
> > > Date: Thu, 10 Jul 2014 01:02:11 +0000
> > > Subject: [patch] mm: memcontrol: rewrite uncharge API fix - double migration
> > > 
> > > Hugh reports:
> > > 
> > > VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM))
> > > mm/memcontrol.c:6680!
> > > page had count 1 mapcount 0 mapping anon index 0x196
> > > flags locked uptodate reclaim swapbacked, pcflags 1, memcg not root
> > > mem_cgroup_migrate < move_to_new_page < migrate_pages < compact_zone <
> > > compact_zone_order < try_to_compact_pages < __alloc_pages_direct_compact <
> > > __alloc_pages_nodemask < alloc_pages_vma < do_huge_pmd_anonymous_page <
> > > handle_mm_fault < __do_page_fault
> > > 
> > > mem_cgroup_migrate() assumes that a page is only migrated once and
> > > then freed immediately after.
> > > 
> > > However, putting the page back on the LRU list and dropping the
> > > isolation refcount is not done atomically.  This allows a PFN-based
> > > migrator like compaction to isolate the page, see the expected
> > > anonymous page refcount of 1, and migrate the page once more.
> > > 
> > > Furthermore, once the charges are transferred to the new page, the old
> > > page no longer has a pin on the memcg, which might get released before
> > > the page itself now.  pc->mem_cgroup is invalid at this point, but
> > > PCG_USED suggests otherwise, provoking use-after-free.
> > 
> > The same applies to to the new page because we are transferring only
> > statistics. The old page with PCG_USED would uncharge the res_counter
> > and so the new page is not backed by any and so memcg can go away.
> > This sounds like a more probable scenario to me because old page should
> > go away quite early after successful migration.
> 
> No, the charges are carried by PCG_MEM and PCG_MEMSW, not PCG_USED.

Dang. I am blind. Sorry about the noise...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
