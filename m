Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 493A76B0038
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 12:15:07 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b189so3717799wmd.5
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 09:15:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s7si2209774wrb.284.2017.10.02.09.15.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Oct 2017 09:15:05 -0700 (PDT)
Date: Mon, 2 Oct 2017 18:15:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,hugetlb,migration: don't migrate kernelcore hugepages
Message-ID: <20171002161431.kmsrwtta7bwxn63q@dhcp22.suse.cz>
References: <20171001225111.GA16432@gmail.com>
 <20171002125432.xiszy6xlvfb2jv67@dhcp22.suse.cz>
 <20171002140632.GA12673@gmail.com>
 <20171002142717.xwe2xymsr3oocxmg@dhcp22.suse.cz>
 <20171002150637.GA14321@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171002150637.GA14321@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandru Moise <00moses.alexander00@gmail.com>
Cc: corbet@lwn.net, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@kernel.org, cdall@linaro.org, mchehab@kernel.org, zohar@linux.vnet.ibm.com, marc.zyngier@arm.com, rientjes@google.com, hannes@cmpxchg.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, punit.agrawal@arm.com, aarcange@redhat.com, gerald.schaefer@de.ibm.com, jglisse@redhat.com, kirill.shutemov@linux.intel.com, will.deacon@arm.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 02-10-17 17:06:38, Alexandru Moise wrote:
> On Mon, Oct 02, 2017 at 04:27:17PM +0200, Michal Hocko wrote:
> > On Mon 02-10-17 16:06:33, Alexandru Moise wrote:
> > > On Mon, Oct 02, 2017 at 02:54:32PM +0200, Michal Hocko wrote:
> > > > On Mon 02-10-17 00:51:11, Alexandru Moise wrote:
> > > > > This attempts to bring more flexibility to how hugepages are allocated
> > > > > by making it possible to decide whether we want the hugepages to be
> > > > > allocated from ZONE_MOVABLE or to the zone allocated by the "kernelcore="
> > > > > boot parameter for non-movable allocations.
> > > > > 
> > > > > A new boot parameter is introduced, "hugepages_movable=", this sets the
> > > > > default value for the "hugepages_treat_as_movable" sysctl. This allows
> > > > > us to determine the zone for hugepages allocated at boot time. It only
> > > > > affects 2M hugepages allocated at boot time for now because 1G
> > > > > hugepages are allocated much earlier in the boot process and ignore
> > > > > this sysctl completely.
> > > > > 
> > > > > The "hugepages_treat_as_movable" sysctl is also turned into a mandatory
> > > > > setting that all hugepage allocations at runtime must respect (both
> > > > > 2M and 1G sized hugepages). The default value is changed to "1" to
> > > > > preserve the existing behavior that if hugepage migration is supported,
> > > > > then the pages will be allocated from ZONE_MOVABLE.
> > > > > 
> > > > > Note however if not enough contiguous memory is present in ZONE_MOVABLE
> > > > > then the allocation will fallback to the non-movable zone and those
> > > > > pages will not be migratable.
> > > > 
> > > > This changelog doesn't explain _why_ we would need something like that.
> > > > 
> > > 
> > > So people shouldn't be able to choose whether their hugepages should be
> > > migratable or not?
> > 
> > How are hugetlb pages any different from THP wrt. migrateability POV? Or
> > any other mapped memory to the userspace in general?
> 
> THP shares more with regular userspace mapped memory than with hugetlbfs pages.
> They have separate codepaths in migrate_pages().

That is a mere implementation detail. You are right that THP shares more
with regular userspace memory because it is transparent from the
configuration POV but that has nothing to do with page migration AFAICS.

> And no one ever sets the movable
> flag on a hugetlbfs mapping, so even though __PageMovable(hpage) on a hugetlbfs
> page returns false, it will still move.

__PageMovable is a completely unrelated thing. It is for pages which are
!LRU but still movable.

> 
> > 
> > > Maybe they consider some of their applications more important than
> > > others.
> > 
> > I do not understand this part.
> > 
> > > Say:
> > > You have a large number of correctable errors on a subpage of a compound
> > > page. So you copy the contents of the page to another hugepage, break the
> > > original page and offline the subpage. 
> > 
> > I suspect you have HWPoisoning in mind right?
> 
> No, rather soft offlining. 

I thought this is the same thing.

> > > But maybe you'd rather that some of
> > > your hugepages not be broken and moved because you're not that worried about
> > > memory corruption, but more about availability.
> > 
> > Could you be more specific please?
> 
> You can have a platform with reliable DIMM modules and a platform with less reliable
> DIMM modules. So you would prefer to inhibit hugepage migration on the platform with
> reliable DIMM modules that you know will behave ok even under a high number of 
> correctable memory errors. tools like mcelog however are not hugepage aware and
> cannot be told "if this PFN is part of a hugepage, don't try to soft offline it",
> rather deciding which PFNs should be unmovable should be done in the kernel,
> but it should still be controllable by the administrator.

This sounds like a userspace policy that should be handled outside of
the kernel.

> For hugetlbfs pages in particular, this behavior is not present, without this patch.
> 
> > 
> > > Without this patch even if hugepages are in the non-movable zone, they move.
> > 
> > which is ok. This is very same with any other movable allocations.
> 
> So you can have movable pages in the non-movable kernel zone?

yes. Most configuration even do not have any movable zone unless
explicitly configured.

> > > > > The implementation is a bit dirty so obviously I'm open to suggestions
> > > > > for a better way to implement this behavior, or comments whether the whole
> > > > > idea is fundamentally __wrong__.
> > > > 
> > > > To be honest I think this is just a wrong approach. hugepages_treat_as_movable
> > > > is quite questionable to be honest because it breaks the basic semantic
> > > > of the movable zone if the hugetlb pages are not really migratable which
> > > > should be the only criterion. Hugetlb pages are no different from other
> > > > migratable pages in that regards.
> > > 
> > > Shouldn't hugepages allocated to unmovable zone, by definition, not be able
> > > to be migrated? With this patch, hugepages in the movable zone do move, but
> > > hugepages in the non-movable zone don't. Or am I misunderstanding the semantics
> > > completely?
> > 
> > yes. movable zone is only about a guarantee to move memory around.
> > Movable allocations are still allowed to use kernel zones (aka
> > non-movable). The main reason for the movable zone these days is memory
> > hotplug which needs a semi-guarantee that the memory used can be
> > migrated elsewhere to free up the offlined memory.
> 
> But isn't kernel-zone memory guaranteed not to migrate?

No.

> I agree that movable allocations are allowed to fallback to kernel zones.
> i.e. This is behavior is correct:
> Page A is in ZONE_MOVABLE, page B is in kernel zone.
> Page A gets soft-offlined, the contents are moved to page B.
> 
> This behavior is not correct:
> Page C is in kernel zone, page D is also in kernel zone.
> Page C gets soft offlined, contents of page C get moved to page D.

Why is this incorrect?

> With hugepages, there is no check for whereto the migration goes because
> the pages are pre-allocated and simply dequeued from the hstate freelist.

true

> Thus hugepages will end up being unreserved and moved to a different
> reserved hugepage, and the administrator has no control over this behavior,
> even if they're kernel zone pages.

I really fail to see why kernel vs. movable zones play any role here.
Zones should be mostly an implementation detail which userspace
shouldn't really care about.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
