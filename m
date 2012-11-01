Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 2A46C6B0062
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 14:43:57 -0400 (EDT)
Message-ID: <5092C2CE.7070209@panasas.com>
Date: Thu, 1 Nov 2012 11:43:26 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] fs: Fix remaining filesystems to wait for stable
 page writeback
References: <20121101075805.16153.64714.stgit@blackbox.djwong.org> <20121101075829.16153.92036.stgit@blackbox.djwong.org>
In-Reply-To: <20121101075829.16153.92036.stgit@blackbox.djwong.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: axboe@kernel.dk, lucho@ionkov.net, tytso@mit.edu, sage@inktank.com, ericvh@gmail.com, mfasheh@suse.com, dedekind1@gmail.com, adrian.hunter@intel.com, dhowells@redhat.com, sfrench@samba.org, jlbec@evilplan.org, rminnich@sandia.gov, linux-cifs@vger.kernel.org, jack@suse.cz, martin.petersen@oracle.com, neilb@suse.de, david@fromorbit.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, v9fs-developer@lists.sourceforge.net, ceph-devel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-afs@lists.infradead.org, ocfs2-devel@oss.oracle.com

On 11/01/2012 12:58 AM, Darrick J. Wong wrote:
> Fix up the filesystems that provide their own ->page_mkwrite handlers to
> provide stable page writes if necessary.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
>  fs/9p/vfs_file.c |    1 +
>  fs/afs/write.c   |    4 ++--
>  fs/ceph/addr.c   |    1 +
>  fs/cifs/file.c   |    1 +
>  fs/ocfs2/mmap.c  |    1 +
>  fs/ubifs/file.c  |    4 ++--
>  6 files changed, 8 insertions(+), 4 deletions(-)
> 
> 
> diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
> index c2483e9..aa253f0 100644
> --- a/fs/9p/vfs_file.c
> +++ b/fs/9p/vfs_file.c
> @@ -620,6 +620,7 @@ v9fs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
>  	lock_page(page);
>  	if (page->mapping != inode->i_mapping)
>  		goto out_unlock;
> +	wait_on_stable_page_write(page);
>  

Good god thanks, yes please ;-)

>  	return VM_FAULT_LOCKED;
>  out_unlock:
> diff --git a/fs/afs/write.c b/fs/afs/write.c
> index 9aa52d9..39eb2a4 100644
> --- a/fs/afs/write.c
> +++ b/fs/afs/write.c
> @@ -758,7 +758,7 @@ int afs_page_mkwrite(struct vm_area_struct *vma, struct page *page)

afs, is it not a network filesystem? which means that it has it's own emulated none-block-device
BDI, registered internally. So if you do need stable pages someone should call
bdi_require_stable_pages()

But again since it is a network filesystem I don't see how it is needed, and/or it might be
taken care of already.

>  #ifdef CONFIG_AFS_FSCACHE
>  	fscache_wait_on_page_write(vnode->cache, page);
>  #endif
> -
> +	wait_on_stable_page_write(page);
>  	_leave(" = 0");
> -	return 0;
> +	return VM_FAULT_LOCKED;
>  }
> diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c

CEPH for sure has it's own "emulated none-block-device BDI". This one is also
a pure networking filesystem.

And it already does what it needs to do with wait_on_writeback().

So i do not think you should touch CEPH

> index 6690269..e9734bf 100644
> --- a/fs/ceph/addr.c
> +++ b/fs/ceph/addr.c
> @@ -1208,6 +1208,7 @@ static int ceph_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
>  		set_page_dirty(page);
>  		up_read(&mdsc->snap_rwsem);
>  		ret = VM_FAULT_LOCKED;
> +		wait_on_stable_page_write(page);
>  	} else {
>  		if (ret == -ENOMEM)
>  			ret = VM_FAULT_OOM;
> diff --git a/fs/cifs/file.c b/fs/cifs/file.c

Cifs also self-BDI network filesystem, but

> index edb25b4..a8770bf 100644
> --- a/fs/cifs/file.c
> +++ b/fs/cifs/file.c
> @@ -2997,6 +2997,7 @@ cifs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
>  	struct page *page = vmf->page;
>  
>  	lock_page(page);

It waits by locking the page, that's cifs naive way of waiting for writeback

> +	wait_on_stable_page_write(page);

Instead it could do better and not override page_mkwrite at all, and all it needs
to do is call bdi_require_stable_pages() at it's own registered BDI

>  	return VM_FAULT_LOCKED;
>  }
>  
> diff --git a/fs/ocfs2/mmap.c b/fs/ocfs2/mmap.c
> index 47a87dd..a0027b1 100644
> --- a/fs/ocfs2/mmap.c
> +++ b/fs/ocfs2/mmap.c
> @@ -124,6 +124,7 @@ static int __ocfs2_page_mkwrite(struct file *file, struct buffer_head *di_bh,
>  				     fsdata);
>  	BUG_ON(ret != len);
>  	ret = VM_FAULT_LOCKED;
> +	wait_on_stable_page_write(page);
>  out:
>  	return ret;
>  }
> diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
> index 5bc7781..cb0d3aa 100644
> --- a/fs/ubifs/file.c
> +++ b/fs/ubifs/file.c
> @@ -1522,8 +1522,8 @@ static int ubifs_vm_page_mkwrite(struct vm_area_struct *vma,
>  			ubifs_release_dirty_inode_budget(c, ui);
>  	}
>  
> -	unlock_page(page);
> -	return 0;
> +	wait_on_stable_page_write(page);

ubifs has it's special ubi block device. So someone needs to call bdi_require_stable_pages()
for this to work.

I think that here too. The existing code, like cifs, calls page_lock, as a way of
waiting for writeback.

So this is certainly not finished.

> +	return VM_FAULT_LOCKED;
>  
>  out_unlock:
>  	unlock_page(page);
> 

Cheers
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
