Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6286B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 12:17:18 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so67878590wic.0
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 09:17:18 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id d2si4533123wjw.157.2015.08.11.09.17.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Aug 2015 09:17:16 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so67877331wic.0
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 09:17:16 -0700 (PDT)
Message-ID: <55CA2008.7070702@plexistor.com>
Date: Tue, 11 Aug 2015 19:17:12 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH, RFC 2/2] dax: use range_lock instead of i_mmap_lock
References: <1439219664-88088-1-git-send-email-kirill.shutemov@linux.intel.com> <1439219664-88088-3-git-send-email-kirill.shutemov@linux.intel.com> <20150811081909.GD2650@quack.suse.cz> <20150811093708.GB906@dastard> <20150811135004.GC2659@quack.suse.cz> <55CA0728.7060001@plexistor.com> <20150811152850.GA2608@node.dhcp.inet.fi>
In-Reply-To: <20150811152850.GA2608@node.dhcp.inet.fi>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, Theodore Ts'o <tytso@mit.edu>

On 08/11/2015 06:28 PM, Kirill A. Shutemov wrote:
<>
>> Hi Jan. So you got me confused above. You say:
>> 	"DAX which needs exclusive access to the page given range in the page cache"
>>
>> but DAX and page-cache are mutually exclusive. I guess you meant the VMA
>> range, or the inode->mapping range (which one is it)
> 
> The second -- pgoff range within the inode->mapping.
> 

So yes this is what I do not understand with DAX the inode->mapping radix-tree is
empty.

>> Actually I do not understand this race you guys found at all. (Please bear with
>> me sorry for being slow)
>>
>> If two threads of the same VMA fault on the same pte
>> (I'm not sure how you call it I mean a single 4k entry at each VMAs page-table)
>> then the mm knows how to handle this just fine.
> 
> It does. But only if we have struct page. See lock_page_or_retry() in
> filemap_fault(). Without lock_page() it's problematic.
> 
>> If two processes, ie two VMAs fault on the same inode->mapping. Then an inode
>> wide lock like XFS's to protect against i_size-change / truncate is more than
>> enough.
> 
> We also used lock_page() to make sure we shoot out all pages as we don't
> exclude page faults during truncate. Consider this race:
> 
> 	<fault>			<truncate>
> 	get_block
> 	check i_size
>     				update i_size
> 				unmap
> 	setup pte
> 

Please consider this senario then:

 	<fault>			<truncate>
	read_lock(inode)

 	get_block
 	check i_size
	
	read_unlock(inode)

				write_lock(inode)

     				update i_size
				* remove allocated blocks
 				unmap

				write_unlock(inode)

 	setup pte

IS what you suppose to do in xfs

> With normal page cache we make sure that all pages beyond i_size is
> dropped using lock_page() in truncate_inode_pages_range().
> 

Yes there is no truncate_inode_pages_range() in DAX again radix tree is
empty.

Please do you have a reproducer I would like to see this race and also
experiment with xfs (I guess you saw it in ext4)

> For DAX we need a way to stop all page faults to the pgoff range before
> doing unmap.
> 

Why ?

>> Because with DAX there is no inode->mapping "mapping" at all. You have the call
>> into the FS with get_block() to replace "holes" (zero pages) with real allocated
>> blocks, on WRITE faults, but this conversion should be protected inside the FS
>> already. Then there is the atomic exchange of the PTE which is fine.
>> (And vis versa with holes mapping and writes)
> 
> Having unmap_mapping_range() in PMD fault handling is very unfortunate.
> Go to rmap just to solve page fault is very wrong.
> BTW, we need to do it in write path too.
> 

Only the write path and only when we exchange a zero-page (hole) with
a new allocated (written to) page. Both write fault and/or write-path

> I'm not convinced that all these "let's avoid backing storage allocation"
> in DAX code is not layering violation. I think the right place to solve
> this is filesystem. And we have almost all required handles for this in
> place.  We only need to change vm_ops->page_mkwrite() interface to be able
> to return different page than what was given on input.
> 

What? there is no page returned for DAX page_mkwrite(), it is all insert_mixed
with direct pmd.

Ha I think I see what you are tumbling on. Maybe it is the zero-pages when
read-mapping holes.

A solution I have, (And is working for a year now) is have only a single
zero-page per inode->mapping, inserted at all the holes. and again radix-tree
is kept clean always. This both saves memory and avoids the race on the
(always empty) radix tree.

Tell me if you want that I send a patch there is a small trick I do
at vm_ops->page_mkwrite():

	/* our zero page doesn't really hold the correct offset to the file in
	 * page->index so vmf->pgoff is incorrect, lets fix that */
	vmf->pgoff = vma->vm_pgoff + (((unsigned long)vmf->virtual_address -
			vma->vm_start) >> PAGE_SHIFT);

	/* call fault handler to get a real page for writing */
	return __page_fault(vma, vmf);

Again the return from page_mkwrite() && __page_fault(WRITE_CASE) is always
VM_FAULT_NOPAGE, right?

>>> So regardless whether the lock will be a fs-private one or in
>>> address_space, DAX needs something like the range lock Kirill suggested.
>>> Having the range lock in fs-private part of inode has the advantage that
>>> only filesystems supporting DAX / punch hole will pay the memory overhead.
>>> OTOH most major filesystems need it so the savings would be IMO noticeable
>>
>> punch-hole is truncate for me. With the xfs model of read-write lock where
>> truncate takes write, any fault taking read before executing the fault looks
>> good for the FS side of things. I guess you mean the optimization of the
>> radix-tree lock. But you see DAX does not have a radix-tree, ie it is empty.
> 
> Hm. Where does XFS take this read-write lock in fault path?
> 
> IIUC, truncation vs. page fault serialization relies on i_size being
> updated before doing truncate_pagecache() and checking i_size under
> page_lock() on fault side. We don't have i_size fence for punch hole.
> 

again truncate_pagecache() is NONE.
And yes the read-write locking will protect punch-hole just as truncate
see my locking senario above.

> BTW, how things like ext4_collapse_range() can be safe wrt parallel page
> fault? Ted? 
> 

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
