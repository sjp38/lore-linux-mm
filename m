Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 605E5280260
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 07:42:23 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id m203so36883137iom.6
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 04:42:23 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a184si10094291itg.100.2016.11.21.04.42.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 04:42:22 -0800 (PST)
Date: Mon, 21 Nov 2016 07:42:19 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v13 06/18] mm/ZONE_DEVICE/unaddressable: add special swap
 for unaddressable
Message-ID: <20161121124218.GF2392@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-7-git-send-email-jglisse@redhat.com>
 <5832D33C.6030403@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5832D33C.6030403@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, Nov 21, 2016 at 04:28:04PM +0530, Anshuman Khandual wrote:
> On 11/18/2016 11:48 PM, Jerome Glisse wrote:
> > To allow use of device un-addressable memory inside a process add a
> > special swap type. Also add a new callback to handle page fault on
> > such entry.
> 
> IIUC this swap type is required only for the mirror cases and its
> not a requirement for migration. If it's required for mirroring
> purpose where we intercept each page fault, the commit message
> here should clearly elaborate on that more.

It is only require for un-addressable memory. The mirroring has nothing to do
with it. I will clarify commit message.

[...]

> > diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> > index b6f03e9..d584c74 100644
> > --- a/include/linux/memremap.h
> > +++ b/include/linux/memremap.h
> > @@ -47,6 +47,11 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
> >   */
> >  struct dev_pagemap {
> >  	void (*free_devpage)(struct page *page, void *data);
> > +	int (*fault)(struct vm_area_struct *vma,
> > +		     unsigned long addr,
> > +		     struct page *page,
> > +		     unsigned flags,
> > +		     pmd_t *pmdp);
> 
> We are extending the dev_pagemap once again to accommodate device driver
> specific fault routines for these pages. Wondering if this extension and
> the new swap type should be in the same patch.

It make sense to have it in one single patch as i also change page fault code
path to deal with the new special swap entry and those make use of this new
callback.


> > +int device_entry_fault(struct vm_area_struct *vma,
> > +		       unsigned long addr,
> > +		       swp_entry_t entry,
> > +		       unsigned flags,
> > +		       pmd_t *pmdp)
> > +{
> > +	struct page *page = device_entry_to_page(entry);
> > +
> 
> A BUG_ON() if page->pgmap->fault has not been populated by the driver.
> 

Ok

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
