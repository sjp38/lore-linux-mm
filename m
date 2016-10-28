Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id CBEB36B027D
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 12:09:05 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id d33so53011230uad.2
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 09:09:05 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id 78si4974249ual.48.2016.10.28.09.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Oct 2016 09:09:04 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id x11so5106517qka.0
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 09:09:04 -0700 (PDT)
Date: Fri, 28 Oct 2016 12:08:54 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC 0/8] Define coherent device memory node
Message-ID: <20161028160854.GA11920@gmail.com>
References: <877f8xaurp.fsf@linux.vnet.ibm.com>
 <20161025153256.GB6131@gmail.com>
 <87shrkjpyb.fsf@linux.vnet.ibm.com>
 <20161025185247.GA7188@gmail.com>
 <58108FC6.5070701@linux.vnet.ibm.com>
 <20161026160226.GA13371@gmail.com>
 <581184C2.4000903@linux.vnet.ibm.com>
 <5811A6A9.8080802@linux.vnet.ibm.com>
 <20161027150509.GA2288@gmail.com>
 <5812E673.7050907@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5812E673.7050907@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, bsingharora@gmail.com

On Fri, Oct 28, 2016 at 11:17:31AM +0530, Anshuman Khandual wrote:
> On 10/27/2016 08:35 PM, Jerome Glisse wrote:
> > On Thu, Oct 27, 2016 at 12:33:05PM +0530, Anshuman Khandual wrote:
> >> On 10/27/2016 10:08 AM, Anshuman Khandual wrote:
> >>> On 10/26/2016 09:32 PM, Jerome Glisse wrote:
> >>>> On Wed, Oct 26, 2016 at 04:43:10PM +0530, Anshuman Khandual wrote:
> >>>>> On 10/26/2016 12:22 AM, Jerome Glisse wrote:
> >>>>>> On Tue, Oct 25, 2016 at 11:01:08PM +0530, Aneesh Kumar K.V wrote:
> >>>>>>> Jerome Glisse <j.glisse@gmail.com> writes:
> >>>>>>>> On Tue, Oct 25, 2016 at 10:29:38AM +0530, Aneesh Kumar K.V wrote:
> >>>>>>>>> Jerome Glisse <j.glisse@gmail.com> writes:
> >>>>>>>>>> On Mon, Oct 24, 2016 at 10:01:49AM +0530, Anshuman Khandual wrote:
> > 
> > [...]
> > 
> >>>> In my patchset there is no policy, it is all under device driver control which
> >>>> decide what range of memory is migrated and when. I think only device driver as
> >>>> proper knowledge to make such decision. By coalescing data from GPU counters and
> >>>> request from application made through the uppler level programming API like
> >>>> Cuda.
> >>>>
> >>>
> >>> Right, I understand that. But what I pointed out here is that there are problems
> >>> now migrating user mapped pages back and forth between LRU system RAM memory and
> >>> non LRU device memory which is yet to be solved. Because you are proposing a non
> >>> LRU based design with ZONE_DEVICE, how we are solving/working around these
> >>> problems for bi-directional migration ?
> >>
> >> Let me elaborate on this bit more. Before non LRU migration support patch series
> >> from Minchan, it was not possible to migrate non LRU pages which are generally
> >> driver managed through migrate_pages interface. This was affecting the ability
> >> to do compaction on platforms which has a large share of non LRU pages. That series
> >> actually solved the migration problem and allowed compaction. But it still did not
> >> solve the migration problem for non LRU *user mapped* pages. So if the non LRU pages
> >> are mapped into a process's page table and being accessed from user space, it can
> >> not be moved using migrate_pages interface.
> >>
> >> Minchan had a draft solution for that problem which is still hosted here. On his
> >> suggestion I had tried this solution but still faced some other problems during
> >> mapped pages migration. (NOTE: IIRC this was not posted in the community)
> >>
> >> git://git.kernel.org/pub/scm/linux/kernel/git/minchan/linux.git with the following
> >> branch (non-lru-mapped-v1r2-v4.7-rc4-mmotm-2016-06-24-15-53) 
> >>
> >> As I had mentioned earlier, we intend to support all possible migrations between
> >> system RAM (LRU) and device memory (Non LRU) for user space mapped pages.
> >>
> >> (1) System RAM (Anon mapping) --> Device memory, back and forth many times
> >> (2) System RAM (File mapping) --> Device memory, back and forth many times
> > 
> > I achieve this 2 objective in HMM, i sent you the additional patches for file
> > back page migration. I am not done working on them but they are small.
> 
> Sure, will go through them. Thanks !
> 
> > 
> > 
> >> This is not happening now with non LRU pages. Here are some of reasons but before
> >> that some notes.
> >>
> >> * Driver initiates all the migrations
> >> * Driver does the isolation of pages
> >> * Driver puts the isolated pages in a linked list
> >> * Driver passes the linked list to migrate_pages interface for migration
> >> * IIRC isolation of non LRU pages happens through page->as->aops->isolate_page call
> >> * If migration fails, call page->as->aops->putback_page to give the page back to the
> >>   device driver
> >>
> >> 1. queue_pages_range() currently does not work with non LRU pages, needs to be fixed
> >>
> >> 2. After a successful migration from non LRU device memory to LRU system RAM, the non
> >>    LRU will be freed back. Right now migrate_pages releases these pages to buddy, but
> >>    in this situation we need the pages to be given back to the driver instead. Hence
> >>    migrate_pages needs to be changed to accommodate this.
> >>
> >> 3. After LRU system RAM to non LRU device migration for a mapped page, does the new
> >>    page (which came from device memory) will be part of core MM LRU either for Anon
> >>    or File mapping ?
> >>
> >> 4. After LRU (Anon mapped) system RAM to non LRU device migration for a mapped page,
> >>    how we are going to store "address_space->address_space_operations" and "Anon VMA
> >>    Chain" reverse mapping information both on the page->mapping element ?
> >>
> >> 5. After LRU (File mapped) system RAM to non LRU device migration for a mapped page,
> >>    how we are going to store "address_space->address_space_operations" of the device
> >>    driver and radix tree based reverse mapping information for the existing file
> >>    mapping both on the same page->mapping element ?
> >>
> >> 6. IIRC, it was not possible to retain the non LRU identify (page->as->aops which will
> >>    defined inside the device driver) and the reverse mapping information (either anon
> >>    or file mapping) together after first round of migration. This non LRU identity needs
> >>    to be retained continuously if we ever need to return this page to device driver after
> >>    successful migration to system RAM or for isolation/putback purpose or something else.
> >>
> >> All the reasons explained above was preventing a continuous ping-pong scheme of migration
> >> between system RAM LRU buddy pages and device memory non LRU pages which is one of the
> >> primary requirements for exploiting coherent device memory. Do you think we can solve these
> >> problems with ZONE_DEVICE and HMM framework ?
> > 
> > Well HMM already achieve migration but design is slightly different :
> >  * Device driver initiate migration by calling hmm_migrate(mm, start, end, pfn_array);
> >    It must provide a pfn_array that is big enough to have one entry per page for the
> >    range (so ((end - start) >> PAGE_SHIFT) entries). With this array no list of page.
> 
> If we are not going to use standard core migrate_pages() interface, there is no need
> of building a linked list of isolated source pages for migration. Though I see a
> different hmm_migrate() function in the V13 tree which involves hmm_migrate structure,
> lets focus on hmm_migrate(mm, start, end, pfn_array) format. I guess (mm, start, end)
> describes the virtual range of a process which needs to be migrated and pfn_array[]
> is the destination array of PFNs for the migration ?

The hmm_migrate struct is just a place holder for all the argument (vma, start, end,
pfn_arrays ptr, flags, ...). I can hide it inside the migrate function, it is easier
to pass around for sub-functions that always having a long list of arg.

> 
> * I assume pfn_array[] can contain either system RAM PFN or device memory PFN ? It
>   will support migration in both directions ?

Correct both direction are supported.

> 
> * Device memory PFN can have struct pages (If ZONE_DEVICE based) or it may not have
>   struct pages ?

Memory must have a struct page, this is needed so that anon_vma and mapping for file
back page are properly being track.

> > 
> >  * hmm_migrate() collect source pages from the process. Right now it will only migrate
> >    thing that have been faulted ie with a valid CPU page table entry and will ignore
> >    swap entry, or any other special CPU page table entry. Those source pages are store
> >    in the pfn array (using their pfn value with flag like write permission)
> 
> So source PFNs go into pfn_array[], I was thinking it contains destination PFNs.

In first pass it contains source pfn so driver don't have to walk CPU page table,
it can be ignore by driver that use CPU page table directly. It is only after device
driver callback that the device populate the array with destination memory.


> > 
> >  * hmm_migrate() isolate all lru pages collected in previous step. For ZONE_DEVICE pages
> >    it does nothing. Non lru page can be migrated only if it is a ZONE_DEVICE page. Any
> >    non lru page that is not ZONE_DEVICE is ignored.
> 
> Hmm, may be because it does not have either page->pgmap (which you have extended to
> contain some driver specific callbacks) or page->as->aops (Minchan Kim's framework).
> Therefore any other kind of non LRU pages cannot migrate.
> 
> > 
> >  * hmm_migrate() unmap all the pages and check the refcount. If there a page is pin then
> >    it restore CPU page table, put back the page on lru (if it is not a ZONE_DEVICE page)
> >    and clear the associated entry inside the pfn_array.
> 
> Got it. pfn_array[] at the end will contain all PFNs which need to be migrated.

Yup

> 
> > 
> >  * hmm_migrate() use device driver callback alloc_and_copy() this device driver callback
> >    will allocate destination device page and copy from the source page. It uses the pfn
> 
> So if the migration is from device to system RAM, alloc_and_copy() will allocate the
> destination system RAM pages and at that time pfn_array[] contains source device memory
> PFNs ? I am just trying see if it works both ways.

Yes, inside hmm_devmem* there is actualy an helper that do just that so device driver don't
have to worry about the device to system RAM direction. But device driver can choose to not
use hmm_devmem* and handle thing on their own (i would rather have device driver use common
helpers to avoid each device driver making different mistakes).


> >    array to know which page can be migrated in the range (there is a flag). The callback
> >    must also update the pfn_array and replace any entry that was successfully allocated
> >    and copied with the pfn of the device page (and flag).
> > 
> >  * hmm_migrate() do the final struct page meta-data migration which might fail in case of
> >    file back page (buffer head migration fails or radix tree fails ...)
> > 
> >  * hmm_migrate() update the CPU page table ie remove migration special entry to point
> >    to new page if migration successfull or restore to old page otherwise. It also unlock
> >    page and call put_page() on them either through lru put back or directly for
> >    ZONE_DEVICE pages.
> 
> If it's a ZONE_DEVICE page, the registered device driver also gets notified about it ?
> So that it can update it's own accounting regarding the allocated and free memory pages
> that it owns through a hot plugged ZONE_DEVICE zone ?
> 
> > 
> >  * hmm_migrate() call cleanup() only now device driver can update its page table
> 
> Though I still need to understand the page table mirroring part, I can clearly see
> that hmm_migrate() attempts to implement a parallel migrate_pages() kind of interface
> which can work with non LRU pages (right now ZONE_DEVICE based only) and a device
> driver. We will have to see whether this hmm_migrate() interface can accommodate all
> kind and direction of migration.
> 
> Minchan Kim's framework enabled non LRU page migration in a different way. The device
> driver is suppose to create a stand alone struct address_space_operation and struct
> address_space and load them into each struct page with a call. Now all non LRU pages
> contains the stand alone struct address_space_operations as page->as->aops based
> callbacks.
> 
> Now we have a different way of enabling non LRU device page migration by extending
> ZONE_DEVICE framework, does it overlap with the functionality already supported
> by the previous framework ? I am just curious.

I think Minchan is trying to allow migration for device driver kernel allocated memory
ie not memory that end inside a regular vma (non special vma) but only inside a device
driver file vma if at all. So we are targetting different problem.

Me i only care about "regular" process memory is private anonymous, or share memory
(either back by regular file or pure share memory). I do not want to mess with any of
the device driver vma or any special vma that are under control of an unknown device
driver. Trying to migrate any such special memory is just not going to work. Moreover
i believe it is not something we care in the first place. GPU will work on either the
regular process memory or some GPU specific memory but won't try to mess with other
device vma.

> 
> > 
> > 
> > I slightly changing the last 2 step, it would be call device driver callback first
> > and then restore CPU page table and device driver callback would be rename to
> > finalize_and_map().
> > 
> > So with this design:
> >  1. is a non-issue (use of pfn array and not list of page).
> 
> Right.
> 
> > 
> >  2. is a non-issue successfull migration from ZONE_DEVICE (GPU memory) to system
> >     memory call put_page() which in turn will call inside the device driver
> >     to inform the device driver that page is free (assuming refcount on page
> >     reach 1)
> 
> Right.
> 
> > 
> >  3. New page is not part of the LRU if it is a device page. Assumption is that the
> >     device driver wants to manage its memory by itself and LRU would interfer with
> >     that. Moreover this is a device page and thus it is not something that should be
> >     use for emergency memory allocation or any regular allocation. So it is pointless
> >     for kernel to try to keep aging those pages to see when they can be reclaim.
> 
> If the driver manages everything, these device memory pages need not be on the LRU after
> migration. But not being on any LRU makes it difficult for other core MM features to work
> on these pages any more. Almost all core mm interfaces expect the pages to be on LRU, IIUC.
> Though they all can be changed to accommodate non LRU pages but dont you think that can be
> a lot of work ? Just curious.

There is no code that assume that page is on lru. There is code that assume new page must
go on lru (the file system page read for instance). But all code path i went through (i try
to go over all of it but i might have miss thing) will gracefully handle a page that is not
on the lru. In all cases i have been through this just meant ignore the page. Which is what
i wanted in the first place :) for device memory to be left alone.

My hope is that at one point hardware will have enough commonality that implementing a
generic per device lru might make sense. Same for other kernel mm functionality.

> 
> > 
> >  4. I do not store address_space operation of a device, i extended struct dev_pagemap
> >     to have more callback and this can be access through struct page->pgmap
> >     So the for ZONE_DEVICE page the page->mapping point to the expected page->mapping
> >     ie for anonymous page it points to the anon vma chain and for file back page it
> >     points to the address space of the filesystem on which the file is.
> 
> Right.
> 
> > 
> >  5. See 4 above
> 
> Right.
> 
> > 
> >  6. I do not store any device driver specific address space operation inside struct
> >     page. I do not see the need for that and doing so would require major changes to
> >     kernel mm code. All the device driver cares about is being told when a page is
> >     free (as i am assuming device does the allocation in the first place).
> > 
> 
> Minchan's work introduced the idea of PageMovable (IIUC, it just says its a movable
> non LRU page with page->mapping->aops and some struct page flags) and changed parts
> of the core MM migration and compaction functions to accommodate MovablePage.

Like i said above i think he is targeting device driver allocated page that are not
part of regular vma (private anonymous or share file) but are use by device driver.

> 
> > It seems you want to rely on following struct address_space_operations callback:
> >   void (*putback_page)(struct page *);
> >   bool (*isolate_page)(struct page *, isolate_mode_t);
> >   int (*migratepage) (...);
> > 
> > For putback_page i added a free_page() to struct dev_pagemap which does the job.
> 
> Right, sounds correct from this ZONE_DEVICE based framework.
> 
> > I do not see need for isolate_page() and it would be bad as some filesystem do
> > special thing in that callback. If you update the CPU page table the device should
> 
> It was a dummy device driver specific address_space_operations, hence its not related
> to any file system as such.
> 
> > see that and i do not think you would need any special handling inside the device
> > driver code.
> 
> I need to understand this part. How a call back from CPU page table update comes to
> the device driver, will go through HMM V13 for that.

It goes through the update() callback of hmm_mirror_ops which is part of hmm_mirror
struct. So device driver register an hmm_mirror against an mm which bind the device
to the given mm. Any update to CPU page table calls mmu_notifier and hmm forward those
call to device driver through hmm_mirror_ops.update().

Device driver does not use mmu_notifier directly because HMM provide a way to snapshot
CPU page table safely without worry from concurrent CPU page table update and without
locking CPU page table directory.

But all this is separate from migration or devmem, so i doubt it could be usefull with
CAPI bus. hmm_mirror is just really mmu_notifier with some sugar coating :)

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
