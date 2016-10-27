Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 372ED6B027A
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 11:05:27 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id h7so31144528uab.6
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 08:05:27 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id o131si3473853vkf.18.2016.10.27.08.05.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 08:05:25 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id n189so2729021qke.1
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 08:05:25 -0700 (PDT)
Date: Thu, 27 Oct 2016 11:05:10 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC 0/8] Define coherent device memory node
Message-ID: <20161027150509.GA2288@gmail.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <20161024170902.GA5521@gmail.com>
 <877f8xaurp.fsf@linux.vnet.ibm.com>
 <20161025153256.GB6131@gmail.com>
 <87shrkjpyb.fsf@linux.vnet.ibm.com>
 <20161025185247.GA7188@gmail.com>
 <58108FC6.5070701@linux.vnet.ibm.com>
 <20161026160226.GA13371@gmail.com>
 <581184C2.4000903@linux.vnet.ibm.com>
 <5811A6A9.8080802@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5811A6A9.8080802@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, bsingharora@gmail.com

On Thu, Oct 27, 2016 at 12:33:05PM +0530, Anshuman Khandual wrote:
> On 10/27/2016 10:08 AM, Anshuman Khandual wrote:
> > On 10/26/2016 09:32 PM, Jerome Glisse wrote:
> >> On Wed, Oct 26, 2016 at 04:43:10PM +0530, Anshuman Khandual wrote:
> >>> On 10/26/2016 12:22 AM, Jerome Glisse wrote:
> >>>> On Tue, Oct 25, 2016 at 11:01:08PM +0530, Aneesh Kumar K.V wrote:
> >>>>> Jerome Glisse <j.glisse@gmail.com> writes:
> >>>>>> On Tue, Oct 25, 2016 at 10:29:38AM +0530, Aneesh Kumar K.V wrote:
> >>>>>>> Jerome Glisse <j.glisse@gmail.com> writes:
> >>>>>>>> On Mon, Oct 24, 2016 at 10:01:49AM +0530, Anshuman Khandual wrote:

[...]

> >> In my patchset there is no policy, it is all under device driver control which
> >> decide what range of memory is migrated and when. I think only device driver as
> >> proper knowledge to make such decision. By coalescing data from GPU counters and
> >> request from application made through the uppler level programming API like
> >> Cuda.
> >>
> > 
> > Right, I understand that. But what I pointed out here is that there are problems
> > now migrating user mapped pages back and forth between LRU system RAM memory and
> > non LRU device memory which is yet to be solved. Because you are proposing a non
> > LRU based design with ZONE_DEVICE, how we are solving/working around these
> > problems for bi-directional migration ?
> 
> Let me elaborate on this bit more. Before non LRU migration support patch series
> from Minchan, it was not possible to migrate non LRU pages which are generally
> driver managed through migrate_pages interface. This was affecting the ability
> to do compaction on platforms which has a large share of non LRU pages. That series
> actually solved the migration problem and allowed compaction. But it still did not
> solve the migration problem for non LRU *user mapped* pages. So if the non LRU pages
> are mapped into a process's page table and being accessed from user space, it can
> not be moved using migrate_pages interface.
> 
> Minchan had a draft solution for that problem which is still hosted here. On his
> suggestion I had tried this solution but still faced some other problems during
> mapped pages migration. (NOTE: IIRC this was not posted in the community)
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/minchan/linux.git with the following
> branch (non-lru-mapped-v1r2-v4.7-rc4-mmotm-2016-06-24-15-53) 
> 
> As I had mentioned earlier, we intend to support all possible migrations between
> system RAM (LRU) and device memory (Non LRU) for user space mapped pages.
> 
> (1) System RAM (Anon mapping) --> Device memory, back and forth many times
> (2) System RAM (File mapping) --> Device memory, back and forth many times

I achieve this 2 objective in HMM, i sent you the additional patches for file
back page migration. I am not done working on them but they are small.


> This is not happening now with non LRU pages. Here are some of reasons but before
> that some notes.
> 
> * Driver initiates all the migrations
> * Driver does the isolation of pages
> * Driver puts the isolated pages in a linked list
> * Driver passes the linked list to migrate_pages interface for migration
> * IIRC isolation of non LRU pages happens through page->as->aops->isolate_page call
> * If migration fails, call page->as->aops->putback_page to give the page back to the
>   device driver
> 
> 1. queue_pages_range() currently does not work with non LRU pages, needs to be fixed
> 
> 2. After a successful migration from non LRU device memory to LRU system RAM, the non
>    LRU will be freed back. Right now migrate_pages releases these pages to buddy, but
>    in this situation we need the pages to be given back to the driver instead. Hence
>    migrate_pages needs to be changed to accommodate this.
> 
> 3. After LRU system RAM to non LRU device migration for a mapped page, does the new
>    page (which came from device memory) will be part of core MM LRU either for Anon
>    or File mapping ?
> 
> 4. After LRU (Anon mapped) system RAM to non LRU device migration for a mapped page,
>    how we are going to store "address_space->address_space_operations" and "Anon VMA
>    Chain" reverse mapping information both on the page->mapping element ?
> 
> 5. After LRU (File mapped) system RAM to non LRU device migration for a mapped page,
>    how we are going to store "address_space->address_space_operations" of the device
>    driver and radix tree based reverse mapping information for the existing file
>    mapping both on the same page->mapping element ?
> 
> 6. IIRC, it was not possible to retain the non LRU identify (page->as->aops which will
>    defined inside the device driver) and the reverse mapping information (either anon
>    or file mapping) together after first round of migration. This non LRU identity needs
>    to be retained continuously if we ever need to return this page to device driver after
>    successful migration to system RAM or for isolation/putback purpose or something else.
> 
> All the reasons explained above was preventing a continuous ping-pong scheme of migration
> between system RAM LRU buddy pages and device memory non LRU pages which is one of the
> primary requirements for exploiting coherent device memory. Do you think we can solve these
> problems with ZONE_DEVICE and HMM framework ?

Well HMM already achieve migration but design is slightly different :
 * Device driver initiate migration by calling hmm_migrate(mm, start, end, pfn_array);
   It must provide a pfn_array that is big enough to have one entry per page for the
   range (so ((end - start) >> PAGE_SHIFT) entries). With this array no list of page.

 * hmm_migrate() collect source pages from the process. Right now it will only migrate
   thing that have been faulted ie with a valid CPU page table entry and will ignore
   swap entry, or any other special CPU page table entry. Those source pages are store
   in the pfn array (using their pfn value with flag like write permission)

 * hmm_migrate() isolate all lru pages collected in previous step. For ZONE_DEVICE pages
   it does nothing. Non lru page can be migrated only if it is a ZONE_DEVICE page. Any
   non lru page that is not ZONE_DEVICE is ignored.

 * hmm_migrate() unmap all the pages and check the refcount. If there a page is pin then
   it restore CPU page table, put back the page on lru (if it is not a ZONE_DEVICE page)
   and clear the associated entry inside the pfn_array.

 * hmm_migrate() use device driver callback alloc_and_copy() this device driver callback
   will allocate destination device page and copy from the source page. It uses the pfn
   array to know which page can be migrated in the range (there is a flag). The callback
   must also update the pfn_array and replace any entry that was successfully allocated
   and copied with the pfn of the device page (and flag).

 * hmm_migrate() do the final struct page meta-data migration which might fail in case of
   file back page (buffer head migration fails or radix tree fails ...)

 * hmm_migrate() update the CPU page table ie remove migration special entry to point
   to new page if migration successfull or restore to old page otherwise. It also unlock
   page and call put_page() on them either through lru put back or directly for
   ZONE_DEVICE pages.

 * hmm_migrate() call cleanup() only now device driver can update its page table


I slightly changing the last 2 step, it would be call device driver callback first
and then restore CPU page table and device driver callback would be rename to
finalize_and_map().

So with this design:
 1. is a non-issue (use of pfn array and not list of page).

 2. is a non-issue successfull migration from ZONE_DEVICE (GPU memory) to system
    memory call put_page() which in turn will call inside the device driver
    to inform the device driver that page is free (assuming refcount on page
    reach 1)

 3. New page is not part of the LRU if it is a device page. Assumption is that the
    device driver wants to manage its memory by itself and LRU would interfer with
    that. Moreover this is a device page and thus it is not something that should be
    use for emergency memory allocation or any regular allocation. So it is pointless
    for kernel to try to keep aging those pages to see when they can be reclaim.

 4. I do not store address_space operation of a device, i extended struct dev_pagemap
    to have more callback and this can be access through struct page->pgmap
    So the for ZONE_DEVICE page the page->mapping point to the expected page->mapping
    ie for anonymous page it points to the anon vma chain and for file back page it
    points to the address space of the filesystem on which the file is.

 5. See 4 above

 6. I do not store any device driver specific address space operation inside struct
    page. I do not see the need for that and doing so would require major changes to
    kernel mm code. All the device driver cares about is being told when a page is
    free (as i am assuming device does the allocation in the first place).

It seems you want to rely on following struct address_space_operations callback:
  void (*putback_page)(struct page *);
  bool (*isolate_page)(struct page *, isolate_mode_t);
  int (*migratepage) (...);

For putback_page i added a free_page() to struct dev_pagemap which does the job.
I do not see need for isolate_page() and it would be bad as some filesystem do
special thing in that callback. If you update the CPU page table the device should
see that and i do not think you would need any special handling inside the device
driver code.

For migratepage() again i do not see the use for it. Some fs have special callback
and that should be the one use.


So i really don't think we need to have an address_space for page that are coming
from device. I think we can add thing to struct dev_pagemap if needed.

Did i miss something ? :)

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
