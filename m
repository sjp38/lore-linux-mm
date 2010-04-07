Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 035626B01E3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 14:21:20 -0400 (EDT)
Message-ID: <4BBCCD03.1020105@cray.com>
Date: Wed, 07 Apr 2010 13:20:51 -0500
From: Andrew Hastings <abh@cray.com>
MIME-Version: 1.0
Subject: Re: BUG: Use after free in free_huge_page()
References: <201003222028.o2MKSDsD006611@pogo.us.cray.com> <4BA8C9E0.2090300@us.ibm.com> <20100323175639.GA5870@csn.ul.ie> <4BAAF20D.1050705@cray.com> <20100330111855.GC15466@csn.ul.ie>
In-Reply-To: <20100330111855.GC15466@csn.ul.ie>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Adam Litke <agl@us.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On Thu, Mar 25, 2010 at 12:18:05AM -0500, Andrew Hastings wrote:
>> It seems to me that hugetlbfs ought to take an extra reference on the vma
>> or vm_file or f_mapping or _something_ if vma->vm_file->f_mapping is needed
>> by free_huge_page().
> 
> Again, I haven't looked closely at this but a reference count on the VMA
> wouldn't help. After all, the VMAs have already been cleared up and the
> page tables. As far as the code is concerned, that file is no longer in
> use. I'd also not try reference counting during get_user_pages and
> someohw releasing that count later. Too much mess.
> 
> The most likely avenue is to store a reference to the superblock instead
> of the mapping in page->private which is what put_quota is really
> interested in. There might still be a race there if hugetlbfs managed to
> get unmounted before the pages were freed though - not 100% sure.

The hugetlbfs_sb_info struct that holds the quota is allocated separately from
the superblock.  Would it make sense for page->private to point directly to
hugetlbfs_sb_info, and reference count hugetlbfs_sb_info instead?  Seems like
this would avoid the unmount race.

-Andrew Hastings
 Cray Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
