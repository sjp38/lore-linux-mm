Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id A466C6B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 16:26:43 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so192122824wic.1
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 13:26:43 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id tc5si7056267wic.21.2015.08.11.13.26.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Aug 2015 13:26:41 -0700 (PDT)
Received: by wijp15 with SMTP id p15so191591052wij.0
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 13:26:41 -0700 (PDT)
Date: Tue, 11 Aug 2015 23:26:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH, RFC 2/2] dax: use range_lock instead of i_mmap_lock
Message-ID: <20150811202639.GA1408@node.dhcp.inet.fi>
References: <1439219664-88088-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439219664-88088-3-git-send-email-kirill.shutemov@linux.intel.com>
 <20150811081909.GD2650@quack.suse.cz>
 <20150811093708.GB906@dastard>
 <20150811135004.GC2659@quack.suse.cz>
 <55CA0728.7060001@plexistor.com>
 <20150811152850.GA2608@node.dhcp.inet.fi>
 <55CA2008.7070702@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55CA2008.7070702@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, Theodore Ts'o <tytso@mit.edu>

On Tue, Aug 11, 2015 at 07:17:12PM +0300, Boaz Harrosh wrote:
> On 08/11/2015 06:28 PM, Kirill A. Shutemov wrote:
> > We also used lock_page() to make sure we shoot out all pages as we don't
> > exclude page faults during truncate. Consider this race:
> > 
> > 	<fault>			<truncate>
> > 	get_block
> > 	check i_size
> >     				update i_size
> > 				unmap
> > 	setup pte
> > 
> 
> Please consider this senario then:
> 
>  	<fault>			<truncate>
> 	read_lock(inode)
> 
>  	get_block
>  	check i_size
> 	
> 	read_unlock(inode)
> 
> 				write_lock(inode)
> 
>      				update i_size
> 				* remove allocated blocks
>  				unmap
> 
> 				write_unlock(inode)
> 
>  	setup pte
> 
> IS what you suppose to do in xfs

Do you realize that you describe a race? :-P

Exactly in this scenario pfn your pte point to is not belong to the file
anymore. Have fun.

> > With normal page cache we make sure that all pages beyond i_size is
> > dropped using lock_page() in truncate_inode_pages_range().
> > 
> 
> Yes there is no truncate_inode_pages_range() in DAX again radix tree is
> empty.
> 
> Please do you have a reproducer I would like to see this race and also
> experiment with xfs (I guess you saw it in ext4)

I don't. And I don't see how race like above can be FS-specific. All
critical points in generic code.
 
> > For DAX we need a way to stop all page faults to the pgoff range before
> > doing unmap.
> > 
> 
> Why ?

Because you can end up with ptes pointing to pfns which fs consider not be
part of the file.

	<truncate>		<fault>
	unmap..
				fault in pfn which unmap already unmapped
	..continue unmap

> >> Because with DAX there is no inode->mapping "mapping" at all. You have the call
> >> into the FS with get_block() to replace "holes" (zero pages) with real allocated
> >> blocks, on WRITE faults, but this conversion should be protected inside the FS
> >> already. Then there is the atomic exchange of the PTE which is fine.
> >> (And vis versa with holes mapping and writes)
> > 
> > Having unmap_mapping_range() in PMD fault handling is very unfortunate.
> > Go to rmap just to solve page fault is very wrong.
> > BTW, we need to do it in write path too.
> > 
> 
> Only the write path and only when we exchange a zero-page (hole) with
> a new allocated (written to) page. Both write fault and/or write-path

No. Always on new BH. We don't have anything (except rmap) to find out if
any other process have zero page for the pgoff.
 
> > I'm not convinced that all these "let's avoid backing storage allocation"
> > in DAX code is not layering violation. I think the right place to solve
> > this is filesystem. And we have almost all required handles for this in
> > place.  We only need to change vm_ops->page_mkwrite() interface to be able
> > to return different page than what was given on input.
> > 
> 
> What? there is no page returned for DAX page_mkwrite(), it is all insert_mixed
> with direct pmd.

That was bogus idea, please ignore.

> > Hm. Where does XFS take this read-write lock in fault path?
> > 
> > IIUC, truncation vs. page fault serialization relies on i_size being
> > updated before doing truncate_pagecache() and checking i_size under
> > page_lock() on fault side. We don't have i_size fence for punch hole.
> > 
> 
> again truncate_pagecache() is NONE.
> And yes the read-write locking will protect punch-hole just as truncate
> see my locking senario above.

Do you mean as racy as your truncate scenario? ;-P

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
