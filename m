Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4FC3F6B0038
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 12:49:46 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bj1so6065055pad.23
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 09:49:46 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id e3si28741710pdf.48.2014.09.10.09.49.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 09:49:45 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id kq14so4956749pab.25
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 09:49:44 -0700 (PDT)
Message-ID: <54108124.9030707@gmail.com>
Date: Wed, 10 Sep 2014 19:49:40 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 20/21] ext4: Add DAX functionality
References: <cover.1409110741.git.matthew.r.wilcox@intel.com> <5422062f87eb5606f4632fd06575254379f40ddc.1409110741.git.matthew.r.wilcox@intel.com> <20140903111302.GG20473@dastard>
In-Reply-To: <20140903111302.GG20473@dastard>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, willy@linux.intel.com

On 09/03/2014 02:13 PM, Dave Chinner wrote:
<>
> 
> When direct IO fails ext4 falls back to buffered IO, right? And
> dax_do_io() can return partial writes, yes?
> 

There is no buffered writes with DAX. .I.E buffered writes are always
direct as well. (No page cache)

> So that means if you get, say, ENOSPC part way through a DAX write,
> ext4 can start dirtying the page cache from
> __generic_file_write_iter() because the DAX write didn't wholly
> complete? And say this ENOSPC races with space being freed from
> another inode, then the buffered write will succeed and we'll end up
> with coherency issues, right?
> 
> This is not an idle question - XFS if firing asserts all over the
> place when doing ENOSPC testing because DAX is returning partial
> writes and the XFS direct IO code is expecting them to either wholly
> complete or wholly fail. I can make the DAX variant do allow partial
> writes, but I'm not going to add a useless fallback to buffered IO
> for XFS when the (fully featured) direct allocation fails.
> 

Right, no fall back. Because a fallback is just a retry, because in any
way DAX assumes there is never a page_cache_page for a written data

> Indeed, I note that in the dax_fault code, any page found in the
> page cache is explicitly removed and released, and the direct mapped
> block replaces that page in the vma. IOWs, this code expects pages
> to be clean as we're only supposed to have regions covered by holes
> using cached pages (dax_load_hole()). 

Exactly, page_cache_page are only/always "regions covered by holes"

Once there is a real block allocated for an offset it will be directly
mapped to the vm without a page_cache_page.

> So if we've done a buffered
> write, we're going to toss out dirty pages the moment there is a
> page fault on the range and map the unmodified backing store in
> instead.
> 

No! There is never "buffered write" with DAX. That is: there is never
a page_cache_page that holds data which will belong to the storage
later. DAX means zero-page-cache

> That just seems wrong. Maybe I've forgotten something, but this
> looks like a wart that we don't need and shouldn't bake into this
> interface as both ext4 and XFS can allocate into holes and extend
> files from from the direct IO interfaces. Of course, correct me if
> I'm wrong about ext4 capabilities...
> 

Yes you have misread the patchset, all writes are always done directly
to bdev->direct_access(..) memory *never* via a copy to page_cache.

Currently The only existence of radix-tree pages is for ZERO pages that
cover holes, which get thrown out as clean or COWed on mkwrite

BTW Matthew: It took me a while to figure out the VFS/VMA api but
I managed to map a single ZERO page to all holes and COW them to
real blocks on mkwrite. It needed a combination of flags but the
main trick is that at mkwrite I do:

	/* our zero page doesn't really hold the correct offset to the file in
	 * page->index so vmf->pgoff is incorrect, lets fix that */
	vmf->pgoff = vma->vm_pgoff + (((unsigned long)vmf->virtual_address -
			vma->vm_start) >> PAGE_SHIFT);
	/* call fault handler to get a real page for writing */
	ret = _xip_file_fault(vma, vmf);
	/* invalidate all other mappings to that location */
	unmap_mapping_range(mapping, vmf->pgoff << PAGE_SHIFT, PAGE_SIZE, 1);

	/* mkwrite must lock the original page and return VM_FAULT_LOCKED */
	if (ret == VM_FAULT_NOPAGE) {
		lock_page(m1fs_zero_page);
		ret = VM_FAULT_LOCKED;
	}
	return ret;

At _xip_file_fault() also called from .fault I do in the case of a hole:
	if (!(vmf->flags & FAULT_FLAG_WRITE)) {
		...
		block = _find_data_block(inode, vmf->pgoff);
		if (!block) {
			vmf->page = g_zero_page;
			err = vm_insert_page(vma,
					(unsigned long)vmf->virtual_address,
					vmf->page);
			goto after_insert;
		}
	} else {

Above g_zero_page is my own global zero page, PAGE_ZERO will not work.
_find_data_block() is like your get_buffer but only for the read case,
the write case uses a different _get_block_create().

Please tell me if it is interesting for you? I can try to patch your DAX
patchset to do the same. This can always be done later as an optimization.

> Cheers,
> Dave.
> 

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
