Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id E59146B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 10:40:45 -0400 (EDT)
Date: Fri, 20 Jul 2012 16:40:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: hugetlbfs: Close race during teardown of hugetlbfs
 shared page tables V2 (resend)
Message-ID: <20120720144041.GG12434@tiehlicka.suse.cz>
References: <20120720134937.GG9222@suse.de>
 <20120720141108.GH9222@suse.de>
 <20120720142920.GD12434@tiehlicka.suse.cz>
 <20120720143753.GI9222@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120720143753.GI9222@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 20-07-12 15:37:53, Mel Gorman wrote:
> On Fri, Jul 20, 2012 at 04:29:20PM +0200, Michal Hocko wrote:
> > > <SNIP>
> > > 
> > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > 
> > Yes this looks correct. mmap_sem will make sure that unmap_vmas and
> > free_pgtables are executed atomicaly wrt. huge_pmd_share so it doesn't
> > see non-NULL spte on the way out.
> 
> Yes.
> 
> > I am just wondering whether we need
> > the page_table_lock as well. It is not harmful but I guess we can drop
> > it because both exit_mmap and shmdt are not taking it and mmap_sem is
> > sufficient for them.
> 
> While it is true that we don't *really* need page_table_lock here, we are
> still updating page tables and it's in line with the the ordinary locking
> rules.  There are other cases in hugetlb.c where we do pte_same() checks even
> though we are protected from the related races by the instantiation_mutex.
> 
> page_table_lock is actually a bit useless for shared page tables. If shared
> page tables were every to be a general thing then I think we'd have to
> revisit how PTE update locking is done but I doubt anyone wants to dive
> down that rat-hole.
> 
> For now, I'm going to keep taking it even if strictly speaking it's not
> necessary.

Fair enough

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
