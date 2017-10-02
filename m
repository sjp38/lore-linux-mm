Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3DBFB6B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 11:07:03 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p10so1624207wrc.14
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 08:07:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 32sor3847607wrm.75.2017.10.02.08.07.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Oct 2017 08:07:01 -0700 (PDT)
Date: Mon, 2 Oct 2017 17:06:38 +0200
From: Alexandru Moise <00moses.alexander00@gmail.com>
Subject: Re: [PATCH] mm,hugetlb,migration: don't migrate kernelcore hugepages
Message-ID: <20171002150637.GA14321@gmail.com>
References: <20171001225111.GA16432@gmail.com>
 <20171002125432.xiszy6xlvfb2jv67@dhcp22.suse.cz>
 <20171002140632.GA12673@gmail.com>
 <20171002142717.xwe2xymsr3oocxmg@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171002142717.xwe2xymsr3oocxmg@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: corbet@lwn.net, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@kernel.org, cdall@linaro.org, mchehab@kernel.org, zohar@linux.vnet.ibm.com, marc.zyngier@arm.com, rientjes@google.com, hannes@cmpxchg.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, punit.agrawal@arm.com, aarcange@redhat.com, gerald.schaefer@de.ibm.com, jglisse@redhat.com, kirill.shutemov@linux.intel.com, will.deacon@arm.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 02, 2017 at 04:27:17PM +0200, Michal Hocko wrote:
> On Mon 02-10-17 16:06:33, Alexandru Moise wrote:
> > On Mon, Oct 02, 2017 at 02:54:32PM +0200, Michal Hocko wrote:
> > > On Mon 02-10-17 00:51:11, Alexandru Moise wrote:
> > > > This attempts to bring more flexibility to how hugepages are allocated
> > > > by making it possible to decide whether we want the hugepages to be
> > > > allocated from ZONE_MOVABLE or to the zone allocated by the "kernelcore="
> > > > boot parameter for non-movable allocations.
> > > > 
> > > > A new boot parameter is introduced, "hugepages_movable=", this sets the
> > > > default value for the "hugepages_treat_as_movable" sysctl. This allows
> > > > us to determine the zone for hugepages allocated at boot time. It only
> > > > affects 2M hugepages allocated at boot time for now because 1G
> > > > hugepages are allocated much earlier in the boot process and ignore
> > > > this sysctl completely.
> > > > 
> > > > The "hugepages_treat_as_movable" sysctl is also turned into a mandatory
> > > > setting that all hugepage allocations at runtime must respect (both
> > > > 2M and 1G sized hugepages). The default value is changed to "1" to
> > > > preserve the existing behavior that if hugepage migration is supported,
> > > > then the pages will be allocated from ZONE_MOVABLE.
> > > > 
> > > > Note however if not enough contiguous memory is present in ZONE_MOVABLE
> > > > then the allocation will fallback to the non-movable zone and those
> > > > pages will not be migratable.
> > > 
> > > This changelog doesn't explain _why_ we would need something like that.
> > > 
> > 
> > So people shouldn't be able to choose whether their hugepages should be
> > migratable or not?
> 
> How are hugetlb pages any different from THP wrt. migrateability POV? Or
> any other mapped memory to the userspace in general?

THP shares more with regular userspace mapped memory than with hugetlbfs pages.
They have separate codepaths in migrate_pages(). And no one ever sets the movable
flag on a hugetlbfs mapping, so even though __PageMovable(hpage) on a hugetlbfs
page returns false, it will still move.

> 
> > Maybe they consider some of their applications more important than
> > others.
> 
> I do not understand this part.
> 
> > Say:
> > You have a large number of correctable errors on a subpage of a compound
> > page. So you copy the contents of the page to another hugepage, break the
> > original page and offline the subpage. 
> 
> I suspect you have HWPoisoning in mind right?

No, rather soft offlining. 

> 
> > But maybe you'd rather that some of
> > your hugepages not be broken and moved because you're not that worried about
> > memory corruption, but more about availability.
> 
> Could you be more specific please?

You can have a platform with reliable DIMM modules and a platform with less reliable
DIMM modules. So you would prefer to inhibit hugepage migration on the platform with
reliable DIMM modules that you know will behave ok even under a high number of 
correctable memory errors. tools like mcelog however are not hugepage aware and
cannot be told "if this PFN is part of a hugepage, don't try to soft offline it",
rather deciding which PFNs should be unmovable should be done in the kernel,
but it should still be controllable by the administrator.

For hugetlbfs pages in particular, this behavior is not present, without this patch.

> 
> > Without this patch even if hugepages are in the non-movable zone, they move.
> 
> which is ok. This is very same with any other movable allocations.

So you can have movable pages in the non-movable kernel zone?

>  
> > > > The implementation is a bit dirty so obviously I'm open to suggestions
> > > > for a better way to implement this behavior, or comments whether the whole
> > > > idea is fundamentally __wrong__.
> > > 
> > > To be honest I think this is just a wrong approach. hugepages_treat_as_movable
> > > is quite questionable to be honest because it breaks the basic semantic
> > > of the movable zone if the hugetlb pages are not really migratable which
> > > should be the only criterion. Hugetlb pages are no different from other
> > > migratable pages in that regards.
> > 
> > Shouldn't hugepages allocated to unmovable zone, by definition, not be able
> > to be migrated? With this patch, hugepages in the movable zone do move, but
> > hugepages in the non-movable zone don't. Or am I misunderstanding the semantics
> > completely?
> 
> yes. movable zone is only about a guarantee to move memory around.
> Movable allocations are still allowed to use kernel zones (aka
> non-movable). The main reason for the movable zone these days is memory
> hotplug which needs a semi-guarantee that the memory used can be
> migrated elsewhere to free up the offlined memory.

But isn't kernel-zone memory guaranteed not to migrate?

I agree that movable allocations are allowed to fallback to kernel zones.
i.e. This is behavior is correct:
Page A is in ZONE_MOVABLE, page B is in kernel zone.
Page A gets soft-offlined, the contents are moved to page B.

This behavior is not correct:
Page C is in kernel zone, page D is also in kernel zone.
Page C gets soft offlined, contents of page C get moved to page D.

With hugepages, there is no check for whereto the migration goes because
the pages are pre-allocated and simply dequeued from the hstate freelist.

Thus hugepages will end up being unreserved and moved to a different
reserved hugepage, and the administrator has no control over this behavior,
even if they're kernel zone pages.

> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
