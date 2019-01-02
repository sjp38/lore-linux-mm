Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 28ACE8E0002
	for <linux-mm@kvack.org>; Tue,  1 Jan 2019 20:02:00 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id f69so31791468pff.5
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 17:02:00 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id z19si8060447pfc.95.2019.01.01.17.01.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jan 2019 17:01:58 -0800 (PST)
Date: Wed, 2 Jan 2019 08:59:37 +0800
From: Yuan Yao <yuan.yao@linux.intel.com>
Subject: Re: [RFC][PATCH v2 11/21] kvm: allocate page table pages from DRAM
Message-ID: <20190102005936.GA12352@yy-desk-7060>
References: <20181226131446.330864849@intel.com>
 <20181226133351.703380444@intel.com>
 <87pntg7mv8.fsf@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87pntg7mv8.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Yao Yuan <yuan.yao@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Tue, Jan 01, 2019 at 02:53:07PM +0530, Aneesh Kumar K.V wrote:
> Fengguang Wu <fengguang.wu@intel.com> writes:
> 
> > From: Yao Yuan <yuan.yao@intel.com>
> >
> > Signed-off-by: Yao Yuan <yuan.yao@intel.com>
> > Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> > ---
> > arch/x86/kvm/mmu.c |   12 +++++++++++-
> > 1 file changed, 11 insertions(+), 1 deletion(-)
> >
> > --- linux.orig/arch/x86/kvm/mmu.c	2018-12-26 20:54:48.846720344 +0800
> > +++ linux/arch/x86/kvm/mmu.c	2018-12-26 20:54:48.842719614 +0800
> > @@ -950,6 +950,16 @@ static void mmu_free_memory_cache(struct
> >  		kmem_cache_free(cache, mc->objects[--mc->nobjs]);
> >  }
> >  
> > +static unsigned long __get_dram_free_pages(gfp_t gfp_mask)
> > +{
> > +       struct page *page;
> > +
> > +       page = __alloc_pages(GFP_KERNEL_ACCOUNT, 0, numa_node_id());
> > +       if (!page)
> > +	       return 0;
> > +       return (unsigned long) page_address(page);
> > +}
> > +
> 
> May be it is explained in other patches. What is preventing the
> allocation from pmem here? Is it that we are not using the memory
> policy prefered node id and hence the zone list we built won't have the
> PMEM node?

That because the PMEM nodes are memory-only node in the patchset,
so numa_node_id() will always return the node id from DRAM nodes.

About the zone list, yes in patch 10/21 we build the PMEM nodes to
seperate zonelist, so DRAM nodes will not fall back to PMEM nodes.

> 
> >  static int mmu_topup_memory_cache_page(struct kvm_mmu_memory_cache *cache,
> >  				       int min)
> >  {
> > @@ -958,7 +968,7 @@ static int mmu_topup_memory_cache_page(s
> >  	if (cache->nobjs >= min)
> >  		return 0;
> >  	while (cache->nobjs < ARRAY_SIZE(cache->objects)) {
> > -		page = (void *)__get_free_page(GFP_KERNEL_ACCOUNT);
> > +		page = (void *)__get_dram_free_pages(GFP_KERNEL_ACCOUNT);
> >  		if (!page)
> >  			return cache->nobjs >= min ? 0 : -ENOMEM;
> >  		cache->objects[cache->nobjs++] = page;
> 
> -aneesh
> 
