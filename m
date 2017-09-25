Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0F1EC6B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 19:38:47 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id x85so10190754oix.3
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 16:38:47 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w8sor311595oti.478.2017.09.25.16.38.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Sep 2017 16:38:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170925231404.32723-7-ross.zwisler@linux.intel.com>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com> <20170925231404.32723-7-ross.zwisler@linux.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 25 Sep 2017 16:38:45 -0700
Message-ID: <CAPcyv4jtO028KeZK7SdkOUsgMLGqgttLzBCYgH0M+RP3eAXf4A@mail.gmail.com>
Subject: Re: [PATCH 6/7] mm, fs: introduce file_operations->post_mmap()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-xfs@vger.kernel.org

On Mon, Sep 25, 2017 at 4:14 PM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> When mappings are created the vma->vm_flags that they use vary based on
> whether the inode being mapped is using DAX or not.  This setup happens in
> XFS via mmap_region()=>call_mmap()=>xfs_file_mmap().
>
> For us to be able to safely use the DAX per-inode flag we need to prevent
> S_DAX transitions when any mappings are present, and we will do that by
> looking at the address_space->i_mmap tree and returning -EBUSY if any
> mappings are present.
>
> Unfortunately at the time that the filesystem's file_operations->mmap()
> entry point is called the mapping has not yet been added to the
> address_space->i_mmap tree.  This means that at that point in time we
> cannot determine whether or not the mapping will be set up to support DAX.
>
> Fix this by adding a new file_operations entry called post_mmap() which is
> called after the mapping has been added to the address_space->i_mmap tree.
> This post_mmap() op now happens at a time when we can be sure whether the
> mapping will use DAX or not, and we can set up the vma->vm_flags
> appropriately.
>
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  fs/xfs/xfs_file.c  | 15 ++++++++++++++-
>  include/linux/fs.h |  1 +
>  mm/mmap.c          |  2 ++
>  3 files changed, 17 insertions(+), 1 deletion(-)
>
> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> index 2816858..9d66aaa 100644
> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -1087,9 +1087,21 @@ xfs_file_mmap(
>  {
>         file_accessed(filp);
>         vma->vm_ops = &xfs_file_vm_ops;
> +       return 0;
> +}
> +
> +/* This call happens during mmap(), after the vma has been inserted into the
> + * inode->i_mapping->i_mmap tree.  At this point the decision on whether or
> + * not to use DAX for this mapping has been set and will not change for the
> + * duration of the mapping.
> + */
> +STATIC void
> +xfs_file_post_mmap(
> +       struct file     *filp,
> +       struct vm_area_struct *vma)
> +{
>         if (IS_DAX(file_inode(filp)))
>                 vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;

It's not clear to me what this is actually protecting? vma_is_dax()
returns true regardless of the vm_flags state , so what is the benefit
to delaying the vm_flags setting to ->post_mmap()?

Also, why is this a file_operation and not a vm_operation?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
