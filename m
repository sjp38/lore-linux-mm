Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24BAE6B0033
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 20:53:35 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id h18so1240694pfi.2
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 17:53:35 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id o33si406819plb.588.2017.11.28.17.53.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Nov 2017 17:53:33 -0800 (PST)
Date: Wed, 29 Nov 2017 09:52:29 +0800
From: joeyli <jlee@suse.com>
Subject: Re: [PATCH v2 2/5] mm: memory_hotplug: Remove assumption on memory
 state before hotremove
Message-ID: <20171129015229.GD1469@linux-l9pv.suse>
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
 <4e21a27570f665793debf167c8567c6752116d0a.1511433386.git.ar@linux.vnet.ibm.com>
 <20171129004913.GB1469@linux-l9pv.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171129004913.GB1469@linux-l9pv.suse>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Reale <ar@linux.vnet.ibm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, catalin.marinas@arm.com, mhocko@suse.com, rafael.j.wysocki@intel.com, linux-acpi@vger.kernel.org

On Wed, Nov 29, 2017 at 08:49:13AM +0800, joeyli wrote:
> Hi Andrea, 
> 
> On Fri, Nov 24, 2017 at 10:22:35AM +0000, Andrea Reale wrote:
> > Resending the patch adding linux-acpi in CC, as suggested by Rafael.
> > Everyone else: apologies for the noise.
> > 
> > Commit 242831eb15a0 ("Memory hotplug / ACPI: Simplify memory removal")
> > introduced an assumption whereas when control
> > reaches remove_memory the corresponding memory has been already
> > offlined. In that case, the acpi_memhotplug was making sure that
> > the assumption held.
> > This assumption, however, is not necessarily true if offlining
> > and removal are not done by the same "controller" (for example,
> > when first offlining via sysfs).
> > 
> > Removing this assumption for the generic remove_memory code
> > and moving it in the specific acpi_memhotplug code. This is
> > a dependency for the software-aided arm64 offlining and removal
> > process.
> > 
> > Signed-off-by: Andrea Reale <ar@linux.vnet.ibm.com>
> > Signed-off-by: Maciej Bielski <m.bielski@linux.vnet.ibm.com>
> > ---
> >  drivers/acpi/acpi_memhotplug.c |  2 +-
> >  include/linux/memory_hotplug.h |  9 ++++++---
> >  mm/memory_hotplug.c            | 13 +++++++++----
> >  3 files changed, 16 insertions(+), 8 deletions(-)
> > 
> > diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> > index 6b0d3ef..b0126a0 100644
> > --- a/drivers/acpi/acpi_memhotplug.c
> > +++ b/drivers/acpi/acpi_memhotplug.c
> > @@ -282,7 +282,7 @@ static void acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
> >  			nid = memory_add_physaddr_to_nid(info->start_addr);
> >  
> >  		acpi_unbind_memory_blocks(info);
> > -		remove_memory(nid, info->start_addr, info->length);
> > +		BUG_ON(remove_memory(nid, info->start_addr, info->length));
> >  		list_del(&info->list);
> >  		kfree(info);
> >  	}
> > diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> > index 58e110a..1a9c7b2 100644
> > --- a/include/linux/memory_hotplug.h
> > +++ b/include/linux/memory_hotplug.h
> > @@ -295,7 +295,7 @@ static inline bool movable_node_is_enabled(void)
> >  extern bool is_mem_section_removable(unsigned long pfn, unsigned long nr_pages);
> >  extern void try_offline_node(int nid);
> >  extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
> > -extern void remove_memory(int nid, u64 start, u64 size);
> > +extern int remove_memory(int nid, u64 start, u64 size);
> >  
> >  #else
> >  static inline bool is_mem_section_removable(unsigned long pfn,
> > @@ -311,7 +311,10 @@ static inline int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
> >  	return -EINVAL;
> >  }
> >  
> > -static inline void remove_memory(int nid, u64 start, u64 size) {}
> > +static inline int remove_memory(int nid, u64 start, u64 size)
> > +{
> > +	return -EINVAL;
> > +}
> >  #endif /* CONFIG_MEMORY_HOTREMOVE */
> >  
> >  extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
> > @@ -323,7 +326,7 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
> >  		unsigned long nr_pages);
> >  extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
> >  extern bool is_memblock_offlined(struct memory_block *mem);
> > -extern void remove_memory(int nid, u64 start, u64 size);
> > +extern int remove_memory(int nid, u64 start, u64 size);
> >  extern int sparse_add_one_section(struct pglist_data *pgdat, unsigned long start_pfn);
> >  extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
> >  		unsigned long map_offset);
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index d4b5f29..d5f15af 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -1892,7 +1892,7 @@ EXPORT_SYMBOL(try_offline_node);
> >   * and online/offline operations before this call, as required by
> >   * try_offline_node().
> >   */
> > -void __ref remove_memory(int nid, u64 start, u64 size)
> > +int __ref remove_memory(int nid, u64 start, u64 size)
> >  {
> >  	int ret;
> >  
> > @@ -1908,18 +1908,23 @@ void __ref remove_memory(int nid, u64 start, u64 size)
> >  	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
> >  				check_memblock_offlined_cb);
> >  	if (ret)
> > -		BUG();
> > +		goto end_remove;
> > +
> > +	ret = arch_remove_memory(start, size);

Should not include arch_remove_memory() to BUG().

> > +
> > +	if (ret)
> > +		goto end_remove;
> 
> The original code triggers BUG() when any memblock is not offlined. Why
> the new logic includes the result of arch_remove_memory()?
> 
> But I agreed the we don't need BUG(). Returning a error is better.

Actually, I lost one thing.

The BUG() have caught a issue about the offline state doesn't sync between
memory_block and device object. like:
        mem->dev.offline != (mem->state == MEM_OFFLINE)

So, the BUG() is useful to capture state issue in memory subsystem. But, I
understood your concern about the two steps offline/remove from userland. 

Maybe we should move the BUG() to somewhere but not just remove it. Or if
we think that the BUG() is too intense, at least we should print out a error
message, and ACPI should checks the return value from subsystem to
interrupt memory-hotplug process.

Thanks a lot!
Joey Lee 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
