Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0B56B025E
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 08:59:38 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id n6so10260742qtd.4
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 05:59:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q71si16449933qka.66.2016.11.22.05.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 05:59:37 -0800 (PST)
Date: Tue, 22 Nov 2016 08:59:33 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v13 06/18] mm/ZONE_DEVICE/unaddressable: add special swap
 for unaddressable
Message-ID: <20161122135933.GA5684@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-7-git-send-email-jglisse@redhat.com>
 <3f759fff-fe8d-89c4-5c86-c9f27403bf3b@gmail.com>
 <20161121050518.GC7872@redhat.com>
 <0c55d239-b2f6-c515-6268-94a97fde8c81@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0c55d239-b2f6-c515-6268-94a97fde8c81@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, Nov 22, 2016 at 01:19:42PM +1100, Balbir Singh wrote:
> 
> 
> On 21/11/16 16:05, Jerome Glisse wrote:
> > On Mon, Nov 21, 2016 at 01:06:45PM +1100, Balbir Singh wrote:
> >>
> >>
> >> On 19/11/16 05:18, Jerome Glisse wrote:
> >>> To allow use of device un-addressable memory inside a process add a
> >>> special swap type. Also add a new callback to handle page fault on
> >>> such entry.
> >>>
> >>> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> >>> Cc: Dan Williams <dan.j.williams@intel.com>
> >>> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> >>> ---
> >>>  fs/proc/task_mmu.c       | 10 +++++++-
> >>>  include/linux/memremap.h |  5 ++++
> >>>  include/linux/swap.h     | 18 ++++++++++---
> >>>  include/linux/swapops.h  | 67 ++++++++++++++++++++++++++++++++++++++++++++++++
> >>>  kernel/memremap.c        | 14 ++++++++++
> >>>  mm/Kconfig               | 12 +++++++++
> >>>  mm/memory.c              | 24 +++++++++++++++++
> >>>  mm/mprotect.c            | 12 +++++++++
> >>>  8 files changed, 158 insertions(+), 4 deletions(-)
> >>>
> >>> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> >>> index 6909582..0726d39 100644
> >>> --- a/fs/proc/task_mmu.c
> >>> +++ b/fs/proc/task_mmu.c
> >>> @@ -544,8 +544,11 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
> >>>  			} else {
> >>>  				mss->swap_pss += (u64)PAGE_SIZE << PSS_SHIFT;
> >>>  			}
> >>> -		} else if (is_migration_entry(swpent))
> >>> +		} else if (is_migration_entry(swpent)) {
> >>>  			page = migration_entry_to_page(swpent);
> >>> +		} else if (is_device_entry(swpent)) {
> >>> +			page = device_entry_to_page(swpent);
> >>> +		}
> >>
> >>
> >> So the reason there is a device swap entry for a page belonging to a user process is
> >> that it is in the middle of migration or is it always that a swap entry represents
> >> unaddressable memory belonging to a GPU device, but its tracked in the page table
> >> entries of the process.
> > 
> > For page being migrated i use the existing special migration pte entry. This new device
> > special swap entry is only for unaddressable memory belonging to a device (GPU or any
> > else). We need to keep track of those inside the CPU page table. Using a new special
> > swap entry is the easiest way with the minimum amount of change to core mm.
> > 
> 
> Thanks, makes sense
> 
> > [...]
> > 
> >>> +#ifdef CONFIG_DEVICE_UNADDRESSABLE
> >>> +static inline swp_entry_t make_device_entry(struct page *page, bool write)
> >>> +{
> >>> +	return swp_entry(write?SWP_DEVICE_WRITE:SWP_DEVICE, page_to_pfn(page));
> >>
> >> Code style checks
> > 
> > I was trying to balance against 79 columns break rule :)
> > 
> > [...]
> > 
> >>> +		} else if (is_device_entry(entry)) {
> >>> +			page = device_entry_to_page(entry);
> >>> +
> >>> +			get_page(page);
> >>> +			rss[mm_counter(page)]++;
> >>
> >> Why does rss count go up?
> > 
> > I wanted the device page to be treated like any other page. There is an argument
> > to be made against and for doing that. Do you have strong argument for not doing
> > this ?
> > 
> 
> Yes, It will end up confusing rss accounting IMHO. If a task is using a lot of
> pages on the GPU, should be it a candidate for OOM based on it's RSS for example?
> 
> > [...]
> > 
> >>> @@ -2536,6 +2557,9 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
> >>>  	if (unlikely(non_swap_entry(entry))) {
> >>>  		if (is_migration_entry(entry)) {
> >>>  			migration_entry_wait(vma->vm_mm, fe->pmd, fe->address);
> >>> +		} else if (is_device_entry(entry)) {
> >>> +			ret = device_entry_fault(vma, fe->address, entry,
> >>> +						 fe->flags, fe->pmd);
> >>
> >> What does device_entry_fault() actually do here?
> > 
> > Well it is a special fault handler, it must migrate the memory back to some place
> > where the CPU can access it. It only matter for unaddressable memory.
> 
> So effectively swap the page back in, chances are it can ping pong ...but I was wondering if we can
> tell the GPU that the CPU is accessing these pages as well. I presume any operation that causes
> memory access - core dump will swap back in things from the HMM side onto the CPU side.

Well it is up to device driver to gather statistic on what can/should be inside device memory.
My expectation is that they will detect ping pong and stop asking to migrate a given address/
range to device memory.

> 
> > 
> >>>  		} else if (is_hwpoison_entry(entry)) {
> >>>  			ret = VM_FAULT_HWPOISON;
> >>>  		} else {
> >>> diff --git a/mm/mprotect.c b/mm/mprotect.c
> >>> index 1bc1eb3..70aff3a 100644
> >>> --- a/mm/mprotect.c
> >>> +++ b/mm/mprotect.c
> >>> @@ -139,6 +139,18 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> >>>  
> >>>  				pages++;
> >>>  			}
> >>> +
> >>> +			if (is_write_device_entry(entry)) {
> >>> +				pte_t newpte;
> >>> +
> >>> +				make_device_entry_read(&entry);
> >>> +				newpte = swp_entry_to_pte(entry);
> >>> +				if (pte_swp_soft_dirty(oldpte))
> >>> +					newpte = pte_swp_mksoft_dirty(newpte);
> >>> +				set_pte_at(mm, addr, pte, newpte);
> >>> +
> >>> +				pages++;
> >>> +			}
> >>
> >> Does it make sense to call mprotect() on device memory ranges?
> > 
> > There is nothing special about vma that containt device memory. They can be
> > private anonymous, share, file back ... So any existing memory syscall must
> > behave as expected. This is really just like any other page except that CPU
> > can not access it.
> 
> I understand that, but what would marking it as R/O when the GPU is in the middle
> of write mean? I would also worry about passing "executable" pages over to the
> other side.
> 

Any memory protection change will trigger an mmu_notifier calls which in turn will
update the device page table accordingly. So R/O status will also happen on the GPU.

We assume here that the device driver is not doing evil thing and that device driver
obey memory protection for all range it mirrors. Upstream driver are easy to check.
Close driver might be more problematic, in NVidia case this part if open source and
is easily checkable.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
