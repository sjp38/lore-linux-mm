Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1DA7C6B29A6
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:51:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y18-v6so4277499wma.9
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 03:51:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n24-v6sor1001237wmh.66.2018.08.23.03.51.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 03:51:32 -0700 (PDT)
Date: Thu, 23 Aug 2018 12:51:30 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH] mm: Fix comment for NODEMASK_ALLOC
Message-ID: <20180823105130.GB14924@techadventures.net>
References: <20180820085516.9687-1-osalvador@techadventures.net>
 <20180820142440.1f9ccbebefc5d617c881b41e@linux-foundation.org>
 <20180821121734.GA29735@dhcp22.suse.cz>
 <20180821123024.GA9489@techadventures.net>
 <20180821135159.63b77492f44c21ad203cd7b1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180821135159.63b77492f44c21ad203cd7b1@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, tglx@linutronix.de, joe@perches.com, arnd@arndb.de, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Tue, Aug 21, 2018 at 01:51:59PM -0700, Andrew Morton wrote:
> On Tue, 21 Aug 2018 14:30:24 +0200 Oscar Salvador <osalvador@techadventures.net> wrote:
> 
> > On Tue, Aug 21, 2018 at 02:17:34PM +0200, Michal Hocko wrote:
> > > We do have CONFIG_NODES_SHIFT=10 in our SLES kernels for quite some
> > > time (around SLE11-SP3 AFAICS).
> > > 
> > > Anyway, isn't NODES_ALLOC over engineered a bit? Does actually even do
> > > larger than 1024 NUMA nodes? This would be 128B and from a quick glance
> > > it seems that none of those functions are called in deep stacks. I
> > > haven't gone through all of them but a patch which checks them all and
> > > removes NODES_ALLOC would be quite nice IMHO.
> > 
> > No, maximum we can get is 1024 NUMA nodes.
> > I checked this when writing another patch [1], and since having gone
> > through all archs Kconfigs, CONFIG_NODES_SHIFT=10 is the limit.
> > 
> > NODEMASK_ALLOC gets only called from:
> > 
> > - unregister_mem_sect_under_nodes() (not anymore after [1])
> > - __nr_hugepages_store_common (This does not seem to have a deep stack, we could use a normal nodemask_t)
> > 
> > But is also used for NODEMASK_SCRATCH (mainly used for mempolicy):
> > 
> > struct nodemask_scratch {
> > 	nodemask_t	mask1;
> > 	nodemask_t	mask2;
> > };
> > 
> > that would make 256 bytes in case CONFIG_NODES_SHIFT=10.
> 
> And that sole site could use an open-coded kmalloc.

It is not really one single place, but four:

- do_set_mempolicy()
- do_mbind()
- kernel_migrate_pages()
- mpol_shared_policy_init()

They get called in:

- do_set_mempolicy()
	- From set_mempolicy syscall
	- From numa_policy_init()
	- From numa_default_policy()

	* All above do not look like they have a deep stack, so it should
	  be possible to get rid of NODEMASK_SCRATCH there.

- do_mbind
	- From mbind syscall

	* Should be feasible here as well.

- kernel_migrate_pages()

	- From migrate_pages syscall
	
	* Again, this should be doable.

- mpol_shared_policy_init()

	- From hugetlbfs_alloc_inode()
	- shmem_get_inode()
	
	* Seems doable for hugetlbfs_alloc_inode as well. 
	  I only got to check hugetlbfs_alloc_inode, because shmem_get_inode


So it seems that this can be done in most of the places.
The only tricky function might be mpol_shared_policy_init because of shmem_get_inode.
But in that case, we could use an open-coded kmalloc there.

Thanks
-- 
Oscar Salvador
SUSE L3
