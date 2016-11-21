Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2C927280260
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 07:27:49 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id b123so55016383itb.3
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 04:27:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 125si13754637iou.236.2016.11.21.04.27.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 04:27:48 -0800 (PST)
Date: Mon, 21 Nov 2016 07:27:40 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v13 01/18] mm/memory/hotplug: convert device parameter bool
 to set of flags
Message-ID: <20161121122740.GB2392@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-2-git-send-email-jglisse@redhat.com>
 <5832972E.1050405@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5832972E.1050405@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Mon, Nov 21, 2016 at 12:11:50PM +0530, Anshuman Khandual wrote:
> On 11/18/2016 11:48 PM, Jerome Glisse wrote:

[...]

> > @@ -956,7 +963,7 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
> >  	remove_pagetable(start, end, true);
> >  }
> >  
> > -int __ref arch_remove_memory(u64 start, u64 size)
> > +int __ref arch_remove_memory(u64 start, u64 size, int flags)
> >  {
> >  	unsigned long start_pfn = start >> PAGE_SHIFT;
> >  	unsigned long nr_pages = size >> PAGE_SHIFT;
> > @@ -965,6 +972,12 @@ int __ref arch_remove_memory(u64 start, u64 size)
> >  	struct zone *zone;
> >  	int ret;
> >  
> > +	/* Need to add support for device and unaddressable memory if needed */
> > +	if (flags & MEMORY_UNADDRESSABLE) {
> > +		BUG();
> > +		return -EINVAL;
> > +	}
> > +
> >  	/* With altmap the first mapped page is offset from @start */
> >  	altmap = to_vmem_altmap((unsigned long) page);
> >  	if (altmap)
> 
> So with this patch none of the architectures support un-addressable
> memory but then support will be added through later patches ?
> zone_for_memory function's flag now takes MEMORY_DEVICE parameter.
> Then we need to change all the previous ZONE_DEVICE changes which
> ever took "for_device" to accommodate this new flag ? just curious.

Yes correct.


> > diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> > index 01033fa..ba9b12e 100644
> > --- a/include/linux/memory_hotplug.h
> > +++ b/include/linux/memory_hotplug.h
> > @@ -103,7 +103,7 @@ extern bool memhp_auto_online;
> >  
> >  #ifdef CONFIG_MEMORY_HOTREMOVE
> >  extern bool is_pageblock_removable_nolock(struct page *page);
> > -extern int arch_remove_memory(u64 start, u64 size);
> > +extern int arch_remove_memory(u64 start, u64 size, int flags);
> >  extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
> >  	unsigned long nr_pages);
> >  #endif /* CONFIG_MEMORY_HOTREMOVE */
> > @@ -275,7 +275,20 @@ extern int add_memory(int nid, u64 start, u64 size);
> >  extern int add_memory_resource(int nid, struct resource *resource, bool online);
> >  extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
> >  		bool for_device);
> > -extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
> > +
> > +/*
> > + * For device memory we want more informations than just knowing it is device
> > + * memory. We want to know if we can migrate it (ie it is not storage memory
> > + * use by DAX). Is it addressable by the CPU ? Some device memory like GPU
> > + * memory can not be access by CPU but we still want struct page so that we
> > + * can use it like regular memory.
> 
> Some typos here. Needs to be cleaned up as well. But please have a
> look at comment below over the classification itself.
> 
> > + */
> > +#define MEMORY_FLAGS_NONE 0
> > +#define MEMORY_DEVICE (1 << 0)
> > +#define MEMORY_MOVABLE (1 << 1)
> > +#define MEMORY_UNADDRESSABLE (1 << 2)
> 
> It should be DEVICE_MEMORY_* instead of MEMORY_* as we are trying to
> classify device memory (though they are represented with struct page)
> not regular system ram memory. This should attempt to classify device
> memory which is backed by struct pages. arch_add_memory/arch_remove
> _memory does not come into play if it's traditional device memory
> which is just PFN and does not have struct page associated with it.

Good idea i will change that.


> Broadly they are either CPU accessible or in-accessible. Storage
> memory like persistent memory represented though ZONE_DEVICE fall
> under the accessible (coherent) category. IIUC right now they are
> not movable because page->pgmap replaces page->lru in struct page
> hence its inability to be on standard LRU lists as one of the
> reasons. As there was a need to have struct page to exploit more
> core VM features on these memory going forward it will have to be
> migratable one way or the other to accommodate features like
> compaction, HW poison etc in these storage memory. Hence my point
> here is lets not classify any of these memories as non-movable.
> Just addressable or not should be the only classification.

Being on the lru or not is not and issue in respect to migration. Being
on the lru was use as an indication that the page is manage through the
standard mm code and thus that many assumptions hold which in turn do
allow migration. But if one use device memory following all rules of
regular memory then migration can be done to no matter if page is on
lru or not.

I still think that the MOVABLE is an important distinction as i am pretty
sure that the persistent folks do not want to see their page migrated in
anyway. I might rename it to DEVICE_MEMORY_ALLOW_MIGRATION.

Cheers,
Jerome 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
