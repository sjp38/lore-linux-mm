Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 25A316B01F0
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 01:06:53 -0400 (EDT)
From: Nikanth Karthikesan <knikanth@suse.de>
Subject: Re: [RFC][PATCH] Per file dirty limit throttling
Date: Tue, 17 Aug 2010 10:39:23 +0530
References: <201008160949.51512.knikanth@suse.de> <1281956742.1926.1217.camel@laptop>
In-Reply-To: <1281956742.1926.1217.camel@laptop>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201008171039.23701.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Bill Davidsen <davidsen@tmr.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

On Monday 16 August 2010 16:35:42 Peter Zijlstra wrote:
> On Mon, 2010-08-16 at 09:49 +0530, Nikanth Karthikesan wrote:
> > When the total dirty pages exceed vm_dirty_ratio, the dirtier is made to
> > do the writeback. But this dirtier may not be the one who took the system
> > to this state. Instead, if we can track the dirty count per-file, we
> > could throttle the dirtier of a file, when the file's dirty pages exceed
> > a certain limit. Even though this dirtier may not be the one who dirtied
> > the other pages of this file, it is fair to throttle this process, as it
> > uses that file.
> >
> > This patch
> > 1. Adds dirty page accounting per-file.
> > 2. Exports the number of pages of this file in cache and no of pages
> > dirty via proc-fdinfo.
> > 3. Adds a new tunable, /proc/sys/vm/file_dirty_bytes. When a files dirty
> > data exceeds this limit, the writeback of that inode is done by the
> > current dirtier.
> >
> > This certainly will affect the throughput of certain heavy-dirtying
> > workloads, but should help for interactive systems.
> 
> I'm not really charmed by this.. it adds another random variable to prod
> at. Nor does it really tell me why you're wanting to do this. We already
> have per-task invluence on the dirty limits, a task that sporadically
> dirties pages (your vi) will already end up with a higher dirty limit
> than a task that only dirties pages (your dd).
> 

Oh, nice.  Per-task limit is an elegant solution, which should help during 
most of the common cases.

But I just wonder what happens, when
1. The dirtier is multiple co-operating processes
2. Some app like a shell script, that repeatedly calls dd with seek and skip? 
People do this for data deduplication, sparse skipping etc..
3. The app dies and comes back again. Like a VM that is rebooted, and 
continues writing to a disk backed by a file on the host.

Do you think, in those cases this might still be useful?

> > diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> > index b606c2c..4f8bc06 100644
> > --- a/Documentation/sysctl/vm.txt
> > +++ b/Documentation/sysctl/vm.txt
> > @@ -133,6 +133,15 @@ Setting this to zero disables periodic writeback
> > altogether.
> >
> >  ==============================================================
> >
> > +file_dirty_bytes
> > +
> > +When a files total dirty data exceeds file_dirty_bytes, the current
> > generator +of dirty data would be made to do the writeback of dirty pages
> > of that file. +
> > +0 disables this behaviour.
> > +
> > +==============================================================
> > +
> >  drop_caches
> >
> >  Writing to this will cause the kernel to drop clean caches, dentries and
> >
> > diff --git a/fs/read_write.c b/fs/read_write.c
> > index 74e3658..8881b7d 100644
> > --- a/fs/read_write.c
> > +++ b/fs/read_write.c
> > @@ -16,6 +16,8 @@
> >  #include <linux/syscalls.h>
> >  #include <linux/pagemap.h>
> >  #include <linux/splice.h>
> > +#include <linux/buffer_head.h>
> > +#include <linux/writeback.h>
> >  #include "read_write.h"
> >
> >  #include <asm/uaccess.h>
> > @@ -414,9 +416,19 @@ SYSCALL_DEFINE3(write, unsigned int, fd, const char
> > __user *, buf,
> >
> >  	file = fget_light(fd, &fput_needed);
> >  	if (file) {
> > +		struct address_space *as = file->f_mapping;
> > +		unsigned long file_dirty_pages;
> >  		loff_t pos = file_pos_read(file);
> > +
> >  		ret = vfs_write(file, buf, count, &pos);
> >  		file_pos_write(file, pos);
> > +		/* Start write-out ? */
> > +		if (file_dirty_bytes) {
> > +			file_dirty_pages = file_dirty_bytes / PAGE_SIZE;
> > +			if (as->nrdirty > file_dirty_pages)
> > +				write_inode_now(as->host, 0);
> > +		}
> > +
> >  		fput_light(file, fput_needed);
> >  	}
> 
> This seems wrong, wth are you doing it here and not in the generic
> balance_dirty_pages thing called by set_page_dirty()?
> 

Yes, this should be moved to the single site, inside generic 
balance_dirty_pages().

> > diff --git a/mm/memory.c b/mm/memory.c
> > index 9606ceb..0961f70 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2873,6 +2873,7 @@ static int __do_fault(struct mm_struct *mm, struct
> > vm_area_struct *vma, struct vm_fault vmf;
> >  	int ret;
> >  	int page_mkwrite = 0;
> > +	unsigned long file_dirty_pages;
> >
> >  	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
> >  	vmf.pgoff = pgoff;
> > @@ -3024,6 +3025,13 @@ out:
> >  		/* file_update_time outside page_lock */
> >  		if (vma->vm_file)
> >  			file_update_time(vma->vm_file);
> > +
> > +		/* Start write-back ? */
> > +		if (mapping && file_dirty_bytes) {
> > +			file_dirty_pages = file_dirty_bytes / PAGE_SIZE;
> > +			if (mapping->nrdirty > file_dirty_pages)
> > +				write_inode_now(mapping->host, 0);
> > +		}
> >  	} else {
> >  		unlock_page(vmf.page);
> >  		if (anon)
> 
> Idem, replicating that code at every site that can dirty a page is just
> wrong, hook into the regular set_page_dirty()->balance_dirty_pages()
> code.
> 
> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > index 20890d8..1cabd7f 100644
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -87,6 +87,13 @@ int vm_dirty_ratio = 20;
> >  unsigned long vm_dirty_bytes;
> >
> >  /*
> > + * When a files total dirty data exceeds file_dirty_bytes, the current
> > generator + * of dirty data would be made to do the writeback of dirty
> > pages of that file. + * 0 disables this behaviour.
> > + */
> > +unsigned long file_dirty_bytes = 0;
> 
> So you're adding a extra cacheline to dirty even though its not used by
> default, that seems like suckage..
> 

Right, this could be avoided. Some f(vm_dirty_ratio) should be used. I just 
wanted to provide a way to disable this behaviour at run-time.

Thanks
Nikanth

> > @@ -1126,6 +1137,7 @@ void account_page_dirtied(struct page *page, struct
> > address_space *mapping) {
> >  	if (mapping_cap_account_dirty(mapping)) {
> >  		__inc_zone_page_state(page, NR_FILE_DIRTY);
> > +		mapping->nrdirty++;
> >  		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
> >  		task_dirty_inc(current);
> >  		task_io_account_write(PAGE_CACHE_SIZE);
> > @@ -1301,6 +1313,7 @@ int clear_page_dirty_for_io(struct page *page)
> >  		 */
> >  		if (TestClearPageDirty(page)) {
> >  			dec_zone_page_state(page, NR_FILE_DIRTY);
> > +			mapping->nrdirty--;
> >  			dec_bdi_stat(mapping->backing_dev_info,
> >  					BDI_RECLAIMABLE);
> >  			return 1;
> > diff --git a/mm/truncate.c b/mm/truncate.c
> > index ba887bf..5846d6a 100644
> > --- a/mm/truncate.c
> > +++ b/mm/truncate.c
> > @@ -75,6 +75,7 @@ void cancel_dirty_page(struct page *page, unsigned int
> > account_size) struct address_space *mapping = page->mapping;
> >  		if (mapping && mapping_cap_account_dirty(mapping)) {
> >  			dec_zone_page_state(page, NR_FILE_DIRTY);
> > +			mapping->nrdirty--;
> >  			dec_bdi_stat(mapping->backing_dev_info,
> >  					BDI_RECLAIMABLE);
> >  			if (account_size)
> 
> Preferably we don't add any extra fields under tree_lock so that we can
> easily split it up if/when we decide to use a fine-grain locked radix
> tree.
> 
> Also, like mentioned, you just added a whole new cacheline to dirty.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
