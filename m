Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2A86B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 11:42:02 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id v9so11454813oif.15
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:42:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r72sor535877oie.121.2017.10.20.08.42.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 08:42:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1508504726.5572.41.camel@kernel.org>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150846720244.24336.16885325309403883980.stgit@dwillia2-desk3.amr.corp.intel.com>
 <1508504726.5572.41.camel@kernel.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 20 Oct 2017 08:42:00 -0700
Message-ID: <CAPcyv4hXCJYTkUKs6NiOp=8kgExu+bgZnVn_v+Os7fVUc2NxFg@mail.gmail.com>
Subject: Re: [PATCH v3 12/13] dax: handle truncate of dma-busy pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-xfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Fri, Oct 20, 2017 at 6:05 AM, Jeff Layton <jlayton@kernel.org> wrote:
> On Thu, 2017-10-19 at 19:40 -0700, Dan Williams wrote:
>> get_user_pages() pins file backed memory pages for access by dma
>> devices. However, it only pins the memory pages not the page-to-file
>> offset association. If a file is truncated the pages are mapped out of
>> the file and dma may continue indefinitely into a page that is owned by
>> a device driver. This breaks coherency of the file vs dma, but the
>> assumption is that if userspace wants the file-space truncated it does
>> not matter what data is inbound from the device, it is not relevant
>> anymore.
>>
>> The assumptions of the truncate-page-cache model are broken by DAX where
>> the target DMA page *is* the filesystem block. Leaving the page pinned
>> for DMA, but truncating the file block out of the file, means that the
>> filesytem is free to reallocate a block under active DMA to another
>> file!
>>
>> Here are some possible options for fixing this situation ('truncate' and
>> 'fallocate(punch hole)' are synonymous below):
>>
>>     1/ Fail truncate while any file blocks might be under dma
>>
>>     2/ Block (sleep-wait) truncate while any file blocks might be under
>>        dma
>>
>>     3/ Remap file blocks to a "lost+found"-like file-inode where
>>        dma can continue and we might see what inbound data from DMA was
>>        mapped out of the original file. Blocks in this file could be
>>        freed back to the filesystem when dma eventually ends.
>>
>>     4/ Disable dax until option 3 or another long term solution has been
>>        implemented. However, filesystem-dax is still marked experimental
>>        for concerns like this.
>>
>> Option 1 will throw failures where userspace has never expected them
>> before, option 2 might hang the truncating process indefinitely, and
>> option 3 requires per filesystem enabling to remap blocks from one inode
>> to another.  Option 2 is implemented in this patch for the DAX path with
>> the expectation that non-transient users of get_user_pages() (RDMA) are
>> disallowed from setting up dax mappings and that the potential delay
>> introduced to the truncate path is acceptable compared to the response
>> time of the page cache case. This can only be seen as a stop-gap until
>> we can solve the problem of safely sequestering unallocated filesystem
>> blocks under active dma.
>>
>
> FWIW, I like #3 a lot more than #2 here. I get that it's quite a bit
> more work though, so no objection to this as a stop-gap fix.

I agree, but it needs quite a bit more thought and restructuring of
the truncate path. I also wonder how we reclaim those stranded
filesystem blocks, but a first approximation is wait for the
administrator to delete them or auto-delete them at the next mount.
XFS seems well prepared to reflink-swap these DMA blocks around, but
I'm not sure about EXT4.

>
>
>> The solution introduces a new FL_ALLOCATED lease to pin the allocated
>> blocks in a dax file while dma might be accessing them. It behaves
>> identically to an FL_LAYOUT lease save for the fact that it is
>> immediately sheduled to be reaped, and that the only path that waits for
>> its removal is the truncate path. We can not reuse FL_LAYOUT directly
>> since that would deadlock in the case where userspace did a direct-I/O
>> operation with a target buffer backed by an mmap range of the same file.
>>
>> Credit / inspiration for option 3 goes to Dave Hansen, who proposed
>> something similar as an alternative way to solve the problem that
>> MAP_DIRECT was trying to solve.
>>
>> Cc: Jan Kara <jack@suse.cz>
>> Cc: Jeff Moyer <jmoyer@redhat.com>
>> Cc: Dave Chinner <david@fromorbit.com>
>> Cc: Matthew Wilcox <mawilcox@microsoft.com>
>> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
>> Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
>> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>> Cc: Jeff Layton <jlayton@poochiereds.net>
>> Cc: "J. Bruce Fields" <bfields@fieldses.org>
>> Cc: Dave Hansen <dave.hansen@linux.intel.com>
>> Reported-by: Christoph Hellwig <hch@lst.de>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> ---
>>  fs/Kconfig          |    1
>>  fs/dax.c            |  188 +++++++++++++++++++++++++++++++++++++++++++++++++++
>>  fs/locks.c          |   17 ++++-
>>  include/linux/dax.h |   23 ++++++
>>  include/linux/fs.h  |   22 +++++-
>>  mm/gup.c            |   27 ++++++-
>>  6 files changed, 268 insertions(+), 10 deletions(-)
>>
>> diff --git a/fs/Kconfig b/fs/Kconfig
>> index 7aee6d699fd6..a7b31a96a753 100644
>> --- a/fs/Kconfig
>> +++ b/fs/Kconfig
>> @@ -37,6 +37,7 @@ source "fs/f2fs/Kconfig"
>>  config FS_DAX
>>       bool "Direct Access (DAX) support"
>>       depends on MMU
>> +     depends on FILE_LOCKING
>>       depends on !(ARM || MIPS || SPARC)
>>       select FS_IOMAP
>>       select DAX
>> diff --git a/fs/dax.c b/fs/dax.c
>> index b03f547b36e7..e0a3958fc5f2 100644
>> --- a/fs/dax.c
>> +++ b/fs/dax.c
>> @@ -22,6 +22,7 @@
>>  #include <linux/genhd.h>
>>  #include <linux/highmem.h>
>>  #include <linux/memcontrol.h>
>> +#include <linux/file.h>
>>  #include <linux/mm.h>
>>  #include <linux/mutex.h>
>>  #include <linux/pagevec.h>
>> @@ -1481,3 +1482,190 @@ int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
>>       }
>>  }
>>  EXPORT_SYMBOL_GPL(dax_iomap_fault);
>> +
>> +enum dax_lease_flags {
>> +     DAX_LEASE_PAGES,
>> +     DAX_LEASE_BREAK,
>> +};
>> +
>> +struct dax_lease {
>> +     struct page **dl_pages;
>> +     unsigned long dl_nr_pages;
>> +     unsigned long dl_state;
>> +     struct file *dl_file;
>> +     atomic_t dl_count;
>> +     /*
>> +      * Once the lease is taken and the pages have references we
>> +      * start the reap_work to poll for lease release while acquiring
>> +      * fs locks that synchronize with truncate. So, either reap_work
>> +      * cleans up the dax_lease instances or truncate itself.
>> +      *
>> +      * The break_work sleepily polls for DMA completion and then
>> +      * unlocks/removes the lease.
>> +      */
>> +     struct delayed_work dl_reap_work;
>> +     struct delayed_work dl_break_work;
>> +};
>> +
>> +static void put_dax_lease(struct dax_lease *dl)
>> +{
>> +     if (atomic_dec_and_test(&dl->dl_count)) {
>> +             fput(dl->dl_file);
>> +             kfree(dl);
>> +     }
>> +}
>
> Any reason not to use the new refcount_t type for dl_count? Seems like a
> good place for it.

I'll take a look.

>> +
>> +static void dax_lease_unlock_one(struct work_struct *work)
>> +{
>> +     struct dax_lease *dl = container_of(work, typeof(*dl),
>> +                     dl_break_work.work);
>> +     unsigned long i;
>> +
>> +     /* wait for the gup path to finish recording pages in the lease */
>> +     if (!test_bit(DAX_LEASE_PAGES, &dl->dl_state)) {
>> +             schedule_delayed_work(&dl->dl_break_work, HZ);
>> +             return;
>> +     }
>> +
>> +     /* barrier pairs with dax_lease_set_pages() */
>> +     smp_mb__after_atomic();
>> +
>> +     /*
>> +      * If we see all pages idle at least once we can remove the
>> +      * lease. If we happen to race with someone else taking a
>> +      * reference on a page they will have their own lease to protect
>> +      * against truncate.
>> +      */
>> +     for (i = 0; i < dl->dl_nr_pages; i++)
>> +             if (page_ref_count(dl->dl_pages[i]) > 1) {
>> +                     schedule_delayed_work(&dl->dl_break_work, HZ);
>> +                     return;
>> +             }
>> +     vfs_setlease(dl->dl_file, F_UNLCK, NULL, (void **) &dl);
>> +     put_dax_lease(dl);
>> +}
>> +
>> +static void dax_lease_reap_all(struct work_struct *work)
>> +{
>> +     struct dax_lease *dl = container_of(work, typeof(*dl),
>> +                     dl_reap_work.work);
>> +     struct file *file = dl->dl_file;
>> +     struct inode *inode = file_inode(file);
>> +     struct address_space *mapping = inode->i_mapping;
>> +
>> +     if (mapping->a_ops->dax_flush_dma) {
>> +             mapping->a_ops->dax_flush_dma(inode);
>> +     } else {
>> +             /* FIXME: dax-filesystem needs to add dax-dma support */
>> +             break_allocated(inode, true);
>> +     }
>> +     put_dax_lease(dl);
>> +}
>> +
>> +static bool dax_lease_lm_break(struct file_lock *fl)
>> +{
>> +     struct dax_lease *dl = fl->fl_owner;
>> +
>> +     if (!test_and_set_bit(DAX_LEASE_BREAK, &dl->dl_state)) {
>> +             atomic_inc(&dl->dl_count);
>> +             schedule_delayed_work(&dl->dl_break_work, HZ);
>> +     }
>> +
>
> I haven't gone over this completely, but what prevents you from doing a
> 0->1 transition on the dl_count here, and possibly doing a use-after
> free?
>
> Ahh ok...I guess we know that we hold a reference since this is on the
> flc_lease list? Fair enough. Still, might be worth a comment there as to
> why that's safe.

Right, we hold a reference count at the beginning of time that is only
dropped when the lease is unlocked. If the break happens before unlock
we take this reference while the break_work is running. I'll add this
as a comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
