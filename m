Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A8F946B025E
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 15:19:23 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p126so14438524oih.2
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 12:19:23 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v189sor4056225oig.153.2017.09.26.12.19.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Sep 2017 12:19:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170926185751.GB31146@linux.intel.com>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
 <20170925231404.32723-7-ross.zwisler@linux.intel.com> <CAPcyv4jtO028KeZK7SdkOUsgMLGqgttLzBCYgH0M+RP3eAXf4A@mail.gmail.com>
 <20170926185751.GB31146@linux.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 26 Sep 2017 12:19:21 -0700
Message-ID: <CAPcyv4iVc9y8PE24ZvkiBYdp4Die0Q-K5S6QexW_6YQ_M0F4QA@mail.gmail.com>
Subject: Re: [PATCH 6/7] mm, fs: introduce file_operations->post_mmap()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-xfs@vger.kernel.org

On Tue, Sep 26, 2017 at 11:57 AM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> On Mon, Sep 25, 2017 at 04:38:45PM -0700, Dan Williams wrote:
>> On Mon, Sep 25, 2017 at 4:14 PM, Ross Zwisler
>> <ross.zwisler@linux.intel.com> wrote:
>> > When mappings are created the vma->vm_flags that they use vary based on
>> > whether the inode being mapped is using DAX or not.  This setup happens in
>> > XFS via mmap_region()=>call_mmap()=>xfs_file_mmap().
>> >
>> > For us to be able to safely use the DAX per-inode flag we need to prevent
>> > S_DAX transitions when any mappings are present, and we will do that by
>> > looking at the address_space->i_mmap tree and returning -EBUSY if any
>> > mappings are present.
>> >
>> > Unfortunately at the time that the filesystem's file_operations->mmap()
>> > entry point is called the mapping has not yet been added to the
>> > address_space->i_mmap tree.  This means that at that point in time we
>> > cannot determine whether or not the mapping will be set up to support DAX.
>> >
>> > Fix this by adding a new file_operations entry called post_mmap() which is
>> > called after the mapping has been added to the address_space->i_mmap tree.
>> > This post_mmap() op now happens at a time when we can be sure whether the
>> > mapping will use DAX or not, and we can set up the vma->vm_flags
>> > appropriately.
>> >
>> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
>> > ---
>> >  fs/xfs/xfs_file.c  | 15 ++++++++++++++-
>> >  include/linux/fs.h |  1 +
>> >  mm/mmap.c          |  2 ++
>> >  3 files changed, 17 insertions(+), 1 deletion(-)
>> >
>> > diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
>> > index 2816858..9d66aaa 100644
>> > --- a/fs/xfs/xfs_file.c
>> > +++ b/fs/xfs/xfs_file.c
>> > @@ -1087,9 +1087,21 @@ xfs_file_mmap(
>> >  {
>> >         file_accessed(filp);
>> >         vma->vm_ops = &xfs_file_vm_ops;
>> > +       return 0;
>> > +}
>> > +
>> > +/* This call happens during mmap(), after the vma has been inserted into the
>> > + * inode->i_mapping->i_mmap tree.  At this point the decision on whether or
>> > + * not to use DAX for this mapping has been set and will not change for the
>> > + * duration of the mapping.
>> > + */
>> > +STATIC void
>> > +xfs_file_post_mmap(
>> > +       struct file     *filp,
>> > +       struct vm_area_struct *vma)
>> > +{
>> >         if (IS_DAX(file_inode(filp)))
>> >                 vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
>>
>> It's not clear to me what this is actually protecting? vma_is_dax()
>> returns true regardless of the vm_flags state , so what is the benefit
>> to delaying the vm_flags setting to ->post_mmap()?
>
> Right, but the point is that until the vma has been inserted into the
> inode->i_mapping->i_mmap tree, the results of IS_DAX() don't matter because it
> can still change.  Until this insertion happens we cannot know whether or not
> we should set up the vma->vm_flags to support DAX mappings (i.e. have
> VM_MIXEDMAP and VM_HUGEPAGE set).

Those flags are not DAX flags. The side effect of these being set on
non-DAX mappings is that we effectively auto madvise(MADV_HUGEPAGE)
and enable some page-less insertion paths. Both of those are
effectively no-ops for normal mappings since normal mappings always
have an associated struct page and the THP policy these days is
usually "always".

> This decision can only be made (in this
> proposed scheme) *after* the inode->i_mapping->i_mmap  tree has been
> populated, which means we need another call into the filesystem after this
> insertion has happened.

I get that, but it seems over-engineered and something that can also
be safely cleaned up after the fact by the code path that is disabling
DAX.

> We don't want to mess with the existing file_operations->mmap() call because
> in many filesystems that does sanity checking and setup that you really want
> to have happen *before* the mapping is completed and inserted into the
> inode->i_mapping->i_mmap tree.
>
>> Also, why is this a file_operation and not a vm_operation?
>
> Because ->mmap() is also a file_operation, and this is an analogous call from
> the mmap code that needs to happen at a different time.  Or are you suggesting
> that file_operations->mmap() should be moved to be a vm_operation?  If not,
> why would one be in one operations table and one in another?

Growing something as widely used as file_operations for this one-off
fixup feels like overkill. vm_operations is not much better, but it at
least constrains the data structure growth to something closer to the
problem space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
