Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id E14EC6B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 22:25:24 -0400 (EDT)
Date: Tue, 9 Oct 2012 19:25:23 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB v3
Message-ID: <20121010022523.GE2095@tassilo.jf.intel.com>
References: <1349303063-12766-1-git-send-email-andi@firstfloor.org>
 <1349303063-12766-2-git-send-email-andi@firstfloor.org>
 <20121009151907.3f61ebca.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121009151907.3f61ebca.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>


Thanks for the review.

> > I also exported the new flags to the user headers
> > (they were previously under __KERNEL__). Right now only symbols
> > for x86 and some other architecture for 1GB and 2MB are defined.
> > The interface should already work for all other architectures
> > though.
> 
> So some manpages need updating.  I'm not sure which - mmap(2) surely,
> but which for the IPC change?

mmap and shmget. Was already planned.

> 
> > v2: Port to new tree. Fix unmount.
> > v3: Ported to latest tree.
> > Acked-by: Rik van Riel <riel@redhat.com>
> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> > ---
> >  arch/x86/include/asm/mman.h |    3 ++
> >  fs/hugetlbfs/inode.c        |   63 ++++++++++++++++++++++++++++++++++---------
> >  include/asm-generic/mman.h  |   13 +++++++++
> >  include/linux/hugetlb.h     |   12 +++++++-
> >  include/linux/shm.h         |   19 +++++++++++++
> >  ipc/shm.c                   |    3 +-
> >  mm/mmap.c                   |    5 ++-
> 
> Alas, include/asm-generic/mman.h doesn't exist now.
> 
> Does this change touch all the hugetlb-capable architectures?

Right now only symbols
for x86 and some other architecture for 1GB and 2MB are defined.
The interface should already work for all other architectures
though.

So they can add new symbols for their page sizes at their leisure.

> >  	return capable(CAP_IPC_LOCK) || in_group_p(shm_group);
> >  }
> >  
> > +static int get_hstate_idx(int page_size_log)
> 
> nitlet: "page_size_order" would be more kernely.  Or just "page_order".

It's not really an order, just the index.  I think I would prefer the current name,
order would be misleading.

For x86 it's only 0 and 1

> > +		if (IS_ERR(hugetlbfs_vfsmount[i])) {
> > +				pr_err(
> > +			"hugetlb: Cannot mount internal hugetlbfs for page size %uK",
> > +			       ps_kb);
> > +			error = PTR_ERR(hugetlbfs_vfsmount[i]);
> > +		}
> > +		i++;
> > +	}
> > +	/* Non default hstates are optional */
> > +	if (hugetlbfs_vfsmount[default_hstate_idx])
> > +		return 0;
> 
> hm, so if I'm understanding this, the patch mounts hugetlbfs N times,
> once for each page size.  And presumably the shm code somehow selects
> one of these mounts, based on incoming flags.  And presumably if those
> flags are all-zero, the behaviour is unaltered.

Yes.

> 
> Please update the changelog to describe all this - the overview of how
> the patch actually operates.

Ok.

> 
> Also, all this affects the /proc/mounts contents, yes?  Let's changelog
> that very-slightly-non-back-compatible user-visible change as well.

AFAIK not. The internal mounts are not visible. At least my laptop
doesn't show them.

> There's some overhead to doing all those additional mounts.  Can we
> quantify it?

On x86 it's one more mount (1GB). AFAIK it's just the sb structure, there's
nothing else preallocated. Maybe a couple hundred bytes per page size.

The number of huge page sizes is normally small, I don't think any architecture
has a large number.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
