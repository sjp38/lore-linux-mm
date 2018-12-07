Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 031558E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 12:12:16 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 4so3141066plc.5
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 09:12:15 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w17si3189426pgl.6.2018.12.07.09.12.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Dec 2018 09:12:14 -0800 (PST)
Date: Fri, 7 Dec 2018 09:11:16 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 1/9] mm: Introduce new vm_insert_range API
Message-ID: <20181207171116.GA29923@bombadil.infradead.org>
References: <20181206183945.GA20932@jordon-HP-15-Notebook-PC>
 <53bbc095-c9f5-5d6a-6e50-6e060d17eb68@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53bbc095-c9f5-5d6a-6e50-6e060d17eb68@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, riel@surriel.com, sfr@canb.auug.org.au, rppt@linux.vnet.ibm.com, peterz@infradead.org, linux@armlinux.org.uk, iamjoonsoo.kim@lge.com, treding@nvidia.com, keescook@chromium.org, m.szyprowski@samsung.com, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, heiko@sntech.de, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, kyungmin.park@samsung.com, mchehab@kernel.org, boris.ostrovsky@oracle.com, jgross@suse.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org

On Fri, Dec 07, 2018 at 03:34:56PM +0000, Robin Murphy wrote:
> > +int vm_insert_range(struct vm_area_struct *vma, unsigned long addr,
> > +			struct page **pages, unsigned long page_count)
> > +{
> > +	unsigned long uaddr = addr;
> > +	int ret = 0, i;
> 
> Some of the sites being replaced were effectively ensuring that vma and
> pages were mutually compatible as an initial condition - would it be worth
> adding something here for robustness, e.g.:
> 
> +	if (page_count != vma_pages(vma))
> +		return -ENXIO;

I think we want to allow this to be used to populate part of a VMA.
So perhaps:

	if (page_count > vma_pages(vma))
		return -ENXIO;
