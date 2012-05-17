Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 78F086B00F0
	for <linux-mm@kvack.org>; Thu, 17 May 2012 18:50:32 -0400 (EDT)
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Thu, 17 May 2012 18:50:31 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 24D9C38C8059
	for <linux-mm@kvack.org>; Thu, 17 May 2012 18:50:26 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4HMoQCK152412
	for <linux-mm@kvack.org>; Thu, 17 May 2012 18:50:26 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4I4LH2h027275
	for <linux-mm@kvack.org>; Fri, 18 May 2012 00:21:18 -0400
Message-ID: <4FB580A9.6020305@linux.vnet.ibm.com>
Date: Thu, 17 May 2012 15:50:17 -0700
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: Huge pages: Memory leak on mmap failure
References: <alpine.DEB.2.00.1205171605001.19076@router.home>
In-Reply-To: <alpine.DEB.2.00.1205171605001.19076@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>

On 05/17/2012 02:07 PM, Christoph Lameter wrote:
> 
> On 2.6.32 and 3.4-rc6 mmap failure of a huge page causes a memory
> leak. The 32 byte kmalloc cache grows by 10 mio entries if running
> the following code:

When called for anonymous (non-shared) mappings, hugetlb_reserve_pages()
does a resv_map_alloc().  It depends on code in hugetlbfs's
vm_ops->close() to release that allocation.

However, in the mmap() failure path, we do a plain unmap_region()
without the remove_vma() which actually calls vm_ops->close().

As the code stands today, I think we can fix this by just making sure we
release the resv_map after hugetlb_acct_memory() fails.  But, this seems
like a bit of a superficial fix and if we end up with another path or
two that can return -ESOMETHING, this might get reintroduced.  The
assumption that vm_ops->close() will get called on all VMAs passed in to
hugetlbfs_file_mmap() seems like something that needs to get corrected.

I'll take a look, but I'm really curious what Mel thinks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
