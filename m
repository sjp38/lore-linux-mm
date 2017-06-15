Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4656B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 22:05:00 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 48so847439qts.7
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 19:05:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g2si1589151qke.317.2017.06.14.19.04.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 19:04:59 -0700 (PDT)
Date: Wed, 14 Jun 2017 22:04:55 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM-CDM 4/5] mm/memcontrol: support MEMORY_DEVICE_PRIVATE and
 MEMORY_DEVICE_PUBLIC
Message-ID: <20170615020454.GA4666@redhat.com>
References: <20170614201144.9306-1-jglisse@redhat.com>
 <20170614201144.9306-5-jglisse@redhat.com>
 <20170615114159.11a1eece@firefly.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170615114159.11a1eece@firefly.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org

On Thu, Jun 15, 2017 at 11:41:59AM +1000, Balbir Singh wrote:
> On Wed, 14 Jun 2017 16:11:43 -0400
> Jerome Glisse <jglisse@redhat.com> wrote:
> 
> > HMM pages (private or public device pages) are ZONE_DEVICE page and
> > thus need special handling when it comes to lru or refcount. This
> > patch make sure that memcontrol properly handle those when it face
> > them. Those pages are use like regular pages in a process address
> > space either as anonymous page or as file back page. So from memcg
> > point of view we want to handle them like regular page for now at
> > least.
> > 
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> > Cc: cgroups@vger.kernel.org
> > ---
> >  kernel/memremap.c |  2 ++
> >  mm/memcontrol.c   | 58 ++++++++++++++++++++++++++++++++++++++++++++++++++-----
> >  2 files changed, 55 insertions(+), 5 deletions(-)
> > 
> > diff --git a/kernel/memremap.c b/kernel/memremap.c
> > index da74775..584984c 100644
> > --- a/kernel/memremap.c
> > +++ b/kernel/memremap.c
> > @@ -479,6 +479,8 @@ void put_zone_device_private_or_public_page(struct page *page)
> >  		__ClearPageActive(page);
> >  		__ClearPageWaiters(page);
> >  
> > +		mem_cgroup_uncharge(page);
> > +
> 
> A zone device page could have a mem_cgroup charge if
> 
> 1. The old page was charged to a cgroup and the new page from ZONE_DEVICE then
> gets the charge that we need to drop here
> 
> And should not be charged
> 
> 2. If the driver allowed mmap based allocation (these pages are not on LRU
> 
> 
> Since put_zone_device_private_or_public_page() is called from release_pages(),
> I think the assumption is that 2 is not a problem? I've not tested the mmap
> bits yet.

Well that is one of the big question. Do we care about memory cgroup despite
page not being on lru and thus not being reclaimable through the usual path ?

I believe we do want to keep charging ZONE_DEVICE page against memory cgroup
so that userspace limit are enforced. This is important especialy for device
private when migrating back to system memory due to CPU page fault. We do not
want the migration back to fail because of memory cgroup limit.

Hence why i do want to charge ZONE_DEVICE page just like regular page. If we
have people that run into OOM because of this then we can start thinking about
how to account those pages slightly differently inside the memory cgroup.

For now i believe we do want this patch.


[...]

> > @@ -4610,6 +4637,9 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
> >  		 */
> >  		if (page->mem_cgroup == mc.from) {
> >  			ret = MC_TARGET_PAGE;
> > +			if (is_device_private_page(page) ||
> > +			    is_device_public_page(page))
> > +				ret = MC_TARGET_DEVICE;
> >  			if (target)
> >  				target->page = page;
> >  		}
> > @@ -4669,6 +4699,11 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
> >  
> >  	ptl = pmd_trans_huge_lock(pmd, vma);
> >  	if (ptl) {
> > +		/*
> > +		 * Note their can not be MC_TARGET_DEVICE for now as we do not
>                         there
> > +		 * support transparent huge page with MEMORY_DEVICE_PUBLIC or
> > +		 * MEMORY_DEVICE_PRIVATE but this might change.
> 
> I am trying to remind myself why THP and MEMORY_DEVICE_* pages don't work well
> together today, the driver could allocate a THP size set of pages and migrate it.
> There are patches to do THP migration, not upstream yet. Could you remind me
> of any other limitations?

No there is nothing that would be problematic AFAICT. Persistent memory already
use huge page so we should be in the clear. But i would rather enable that as
a separate patchset alltogether and have proper testing specificaly for such
scenario.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
