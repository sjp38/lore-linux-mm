Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 3955E6B0044
	for <linux-mm@kvack.org>; Mon, 21 May 2012 10:21:41 -0400 (EDT)
Date: Mon, 21 May 2012 15:21:37 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Huge pages: Memory leak on mmap failure
Message-ID: <20120521142137.GE28631@csn.ul.ie>
References: <alpine.DEB.2.00.1205171605001.19076@router.home>
 <4FB580A9.6020305@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4FB580A9.6020305@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, May 17, 2012 at 03:50:17PM -0700, Dave Hansen wrote:
> On 05/17/2012 02:07 PM, Christoph Lameter wrote:
> > 
> > On 2.6.32 and 3.4-rc6 mmap failure of a huge page causes a memory
> > leak. The 32 byte kmalloc cache grows by 10 mio entries if running
> > the following code:
> 
> When called for anonymous (non-shared) mappings, hugetlb_reserve_pages()
> does a resv_map_alloc().  It depends on code in hugetlbfs's
> vm_ops->close() to release that allocation.
> 
> However, in the mmap() failure path, we do a plain unmap_region()
> without the remove_vma() which actually calls vm_ops->close().
> 
> As the code stands today, I think we can fix this by just making sure we
> release the resv_map after hugetlb_acct_memory() fails. 

This appears to be the most practical solution.

> But, this seems
> like a bit of a superficial fix and if we end up with another path or
> two that can return -ESOMETHING, this might get reintroduced.  The
> assumption that vm_ops->close() will get called on all VMAs passed in to
> hugetlbfs_file_mmap() seems like something that needs to get corrected.
> 

It does not look practical to move the allocation to somewhere like
hugetlb_vm_op_open() as minimally that operation is never expected to
fail. That leaves no sane way to communicate that a kmalloc() failed
for example.  ->close() will get called once hugetlb_reserve_pages()
returns successfully so right now, I'm not seeing a better fix than the
superficial fix.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
