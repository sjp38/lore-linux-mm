Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF9776B04C2
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 13:21:26 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id m35so5657509qte.1
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 10:21:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 5si866486qkm.538.2017.09.05.10.21.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Sep 2017 10:21:25 -0700 (PDT)
Date: Tue, 5 Sep 2017 13:21:21 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM-v25 10/19] mm/memcontrol: support MEMORY_DEVICE_PRIVATE v4
Message-ID: <20170905172120.GB19397@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
 <20170817000548.32038-11-jglisse@redhat.com>
 <f239d1c2-7006-5ce4-7848-7d82e67533a9@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <f239d1c2-7006-5ce4-7848-7d82e67533a9@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org

On Tue, Sep 05, 2017 at 07:13:15PM +0200, Laurent Dufour wrote:
> On 17/08/2017 02:05, Jerome Glisse wrote:
> > HMM pages (private or public device pages) are ZONE_DEVICE page and
> > thus need special handling when it comes to lru or refcount. This
> > patch make sure that memcontrol properly handle those when it face
> > them. Those pages are use like regular pages in a process address
> > space either as anonymous page or as file back page. So from memcg
> > point of view we want to handle them like regular page for now at
> > least.
> > 
> > Changed since v3:
> >   - remove public support and move those chunk to separate patch
> > Changed since v2:
> >   - s/host/public
> > Changed since v1:
> >   - s/public/host
> >   - add comments explaining how device memory behave and why
> > 
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Acked-by: Balbir Singh <bsingharora@gmail.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> > Cc: cgroups@vger.kernel.org
> > ---
> >  kernel/memremap.c |  1 +
> >  mm/memcontrol.c   | 52 ++++++++++++++++++++++++++++++++++++++++++++++++----
> >  2 files changed, 49 insertions(+), 4 deletions(-)
> > 
> > diff --git a/kernel/memremap.c b/kernel/memremap.c
> > index 398630c1fba3..f42d7483e886 100644
> > --- a/kernel/memremap.c
> > +++ b/kernel/memremap.c
> > @@ -492,6 +492,7 @@ void put_zone_device_private_page(struct page *page)
> >  		__ClearPageWaiters(page);
> > 
> >  		page->mapping = NULL;
> > +		mem_cgroup_uncharge(page);
> > 
> >  		page->pgmap->page_free(page, page->pgmap->data);
> >  	} else if (!count)
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 604fb3ca8028..977d1cf3493a 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -4407,12 +4407,13 @@ enum mc_target_type {
> >  	MC_TARGET_NONE = 0,
> >  	MC_TARGET_PAGE,
> >  	MC_TARGET_SWAP,
> > +	MC_TARGET_DEVICE,
> >  };
> > 
> >  static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
> >  						unsigned long addr, pte_t ptent)
> >  {
> > -	struct page *page = vm_normal_page(vma, addr, ptent);
> > +	struct page *page = _vm_normal_page(vma, addr, ptent, true);
> 
> Hi Jerome,
> 
> As _vm_normal_page() is defined later in the patch 18, so this patch should
>  break the bisectability.

Correct, it seems i miss that when re-org patch order. The vm_normal_page()
changes can be move to patch 18 as it would be more logical to change call
site with the patch that adds the new special function.

Dunno if patch can be edited now ?

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
