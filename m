Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 2BB996B004D
	for <linux-mm@kvack.org>; Mon, 21 May 2012 18:00:44 -0400 (EDT)
Message-ID: <4FBABB30.9090300@jp.fujitsu.com>
Date: Mon, 21 May 2012 18:01:20 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] hugetlb: fix resv_map leak in error path
References: <20120521202814.E01F0FE1@kernel>
In-Reply-To: <20120521202814.E01F0FE1@kernel>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@linux.vnet.ibm.com
Cc: cl@linux.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com, kosaki.motohiro@jp.fujitsu.com, hughd@google.com, rientjes@google.com, adobriyan@gmail.com, akpm@linux-foundation.org, mel@csn.ul.ie

On 5/21/2012 4:28 PM, Dave Hansen wrote:
> When called for anonymous (non-shared) mappings,
> hugetlb_reserve_pages() does a resv_map_alloc().  It depends on
> code in hugetlbfs's vm_ops->close() to release that allocation.
> 
> However, in the mmap() failure path, we do a plain unmap_region()
> without the remove_vma() which actually calls vm_ops->close().
> 
> This is a decent fix.  This leak could get reintroduced if
> new code (say, after hugetlb_reserve_pages() in
> hugetlbfs_file_mmap()) decides to return an error.  But, I think
> it would have to unroll the reservation anyway.
> 
> This hasn't been extensively tested.  Pretty much compile and
> boot tested along with Christoph's test case:
> 
> 	http://marc.info/?l=linux-mm&m=133728900729735
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> ecked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

typo. ;-)

> Reported/tested-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
