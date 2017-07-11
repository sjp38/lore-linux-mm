Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 05D7E6B050D
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 10:57:50 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u71so1504714qkl.8
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 07:57:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d78si116670qkc.297.2017.07.11.07.57.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 07:57:49 -0700 (PDT)
Date: Tue, 11 Jul 2017 10:57:44 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 2/5] mm/device-public-memory: device memory cache
 coherent with CPU v2
Message-ID: <20170711145744.GA5347@redhat.com>
References: <20170703211415.11283-1-jglisse@redhat.com>
 <20170703211415.11283-3-jglisse@redhat.com>
 <20170711141215.4fd1a972@firefly.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170711141215.4fd1a972@firefly.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <balbirs@au1.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, Jul 11, 2017 at 02:12:15PM +1000, Balbir Singh wrote:
> On Mon,  3 Jul 2017 17:14:12 -0400
> Jerome Glisse <jglisse@redhat.com> wrote:
> 
> > Platform with advance system bus (like CAPI or CCIX) allow device
> > memory to be accessible from CPU in a cache coherent fashion. Add
> > a new type of ZONE_DEVICE to represent such memory. The use case
> > are the same as for the un-addressable device memory but without
> > all the corners cases.
> >
> 
> Looks good overall, some comments inline.
>  

[...]

> >  /*
> > @@ -92,6 +100,8 @@ enum memory_type {
> >   * The page_free() callback is called once the page refcount reaches 1
> >   * (ZONE_DEVICE pages never reach 0 refcount unless there is a refcount bug.
> >   * This allows the device driver to implement its own memory management.)
> > + *
> > + * For MEMORY_DEVICE_CACHE_COHERENT only the page_free() callback matter.
> 
> Correct, but I wonder if we should in the long term allow for minor faults
> (due to coherency) via this interface?

This is something we can explore latter on.

[...]

> > diff --git a/kernel/memremap.c b/kernel/memremap.c
> > index e82456c39a6a..da74775f2247 100644
> > --- a/kernel/memremap.c
> > +++ b/kernel/memremap.c
> > @@ -466,7 +466,7 @@ struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
> >  
> >  
> >  #ifdef CONFIG_DEVICE_PRIVATE
> 
> Does the #ifdef above need to go as well?

Good catch i should make that conditional on DEVICE_PUBLIC or whatever
the name endup to be. I will make sure i test without DEVICE_PRIVATE
config before posting again.

[...]

> > @@ -2541,11 +2551,21 @@ static void migrate_vma_insert_page(struct migrate_vma *migrate,
> >  	 */
> >  	__SetPageUptodate(page);
> >  
> > -	if (is_zone_device_page(page) && is_device_private_page(page)) {
> > -		swp_entry_t swp_entry;
> > +	if (is_zone_device_page(page)) {
> > +		if (is_device_private_page(page)) {
> > +			swp_entry_t swp_entry;
> >  
> > -		swp_entry = make_device_private_entry(page, vma->vm_flags & VM_WRITE);
> > -		entry = swp_entry_to_pte(swp_entry);
> > +			swp_entry = make_device_private_entry(page, vma->vm_flags & VM_WRITE);
> > +			entry = swp_entry_to_pte(swp_entry);
> > +		}
> > +#if IS_ENABLED(CONFIG_DEVICE_PUBLIC)
> 
> Do we need this #if check? is_device_public_page(page)
> will return false if the config is disabled

pte_mkdevmap() is not define if ZONE_DEVICE is not enabled hence
i had to protect this with #if/#endif to avoid build error.

> 
> > +		else if (is_device_public_page(page)) {
> > +			entry = pte_mkold(mk_pte(page, READ_ONCE(vma->vm_page_prot)));
> > +			if (vma->vm_flags & VM_WRITE)
> > +				entry = pte_mkwrite(pte_mkdirty(entry));
> > +			entry = pte_mkdevmap(entry);
> > +		}
> > +#endif /* IS_ENABLED(CONFIG_DEVICE_PUBLIC) */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
