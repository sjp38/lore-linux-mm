Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D89D16B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 10:06:42 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r202so1080857wmd.1
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 07:06:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i6sor3580969wrc.86.2017.10.02.07.06.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Oct 2017 07:06:41 -0700 (PDT)
Date: Mon, 2 Oct 2017 16:06:33 +0200
From: Alexandru Moise <00moses.alexander00@gmail.com>
Subject: Re: [PATCH] mm,hugetlb,migration: don't migrate kernelcore hugepages
Message-ID: <20171002140632.GA12673@gmail.com>
References: <20171001225111.GA16432@gmail.com>
 <20171002125432.xiszy6xlvfb2jv67@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171002125432.xiszy6xlvfb2jv67@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: corbet@lwn.net, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@kernel.org, cdall@linaro.org, mchehab@kernel.org, zohar@linux.vnet.ibm.com, marc.zyngier@arm.com, rientjes@google.com, hannes@cmpxchg.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, punit.agrawal@arm.com, aarcange@redhat.com, gerald.schaefer@de.ibm.com, jglisse@redhat.com, kirill.shutemov@linux.intel.com, will.deacon@arm.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 02, 2017 at 02:54:32PM +0200, Michal Hocko wrote:
> On Mon 02-10-17 00:51:11, Alexandru Moise wrote:
> > This attempts to bring more flexibility to how hugepages are allocated
> > by making it possible to decide whether we want the hugepages to be
> > allocated from ZONE_MOVABLE or to the zone allocated by the "kernelcore="
> > boot parameter for non-movable allocations.
> > 
> > A new boot parameter is introduced, "hugepages_movable=", this sets the
> > default value for the "hugepages_treat_as_movable" sysctl. This allows
> > us to determine the zone for hugepages allocated at boot time. It only
> > affects 2M hugepages allocated at boot time for now because 1G
> > hugepages are allocated much earlier in the boot process and ignore
> > this sysctl completely.
> > 
> > The "hugepages_treat_as_movable" sysctl is also turned into a mandatory
> > setting that all hugepage allocations at runtime must respect (both
> > 2M and 1G sized hugepages). The default value is changed to "1" to
> > preserve the existing behavior that if hugepage migration is supported,
> > then the pages will be allocated from ZONE_MOVABLE.
> > 
> > Note however if not enough contiguous memory is present in ZONE_MOVABLE
> > then the allocation will fallback to the non-movable zone and those
> > pages will not be migratable.
> 
> This changelog doesn't explain _why_ we would need something like that.
> 

So people shouldn't be able to choose whether their hugepages should be
migratable or not? Maybe they consider some of their applications more
important than others.

Say:
You have a large number of correctable errors on a subpage of a compound
page. So you copy the contents of the page to another hugepage, break the
original page and offline the subpage. But maybe you'd rather that some of
your hugepages not be broken and moved because you're not that worried about
memory corruption, but more about availability.

Without this patch even if hugepages are in the non-movable zone, they move.

> > The implementation is a bit dirty so obviously I'm open to suggestions
> > for a better way to implement this behavior, or comments whether the whole
> > idea is fundamentally __wrong__.
> 
> To be honest I think this is just a wrong approach. hugepages_treat_as_movable
> is quite questionable to be honest because it breaks the basic semantic
> of the movable zone if the hugetlb pages are not really migratable which
> should be the only criterion. Hugetlb pages are no different from other
> migratable pages in that regards.

Shouldn't hugepages allocated to unmovable zone, by definition, not be able
to be migrated? With this patch, hugepages in the movable zone do move, but
hugepages in the non-movable zone don't. Or am I misunderstanding the semantics
completely?

../Alex
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
