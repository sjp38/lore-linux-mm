Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id D9B2B6B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 16:45:59 -0400 (EDT)
Date: Tue, 22 May 2012 13:45:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugetlb: fix resv_map leak in error path
Message-Id: <20120522134558.49255899.akpm@linux-foundation.org>
In-Reply-To: <20120521202814.E01F0FE1@kernel>
References: <20120521202814.E01F0FE1@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: cl@linux.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com, kosaki.motohiro@jp.fujitsu.com, hughd@google.com, rientjes@google.com, adobriyan@gmail.com, mel@csn.ul.ie

On Mon, 21 May 2012 13:28:14 -0700
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

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

How far back does this bug go?  The patch applies to 3.4 but gets
rejects in 3.3 and earlier.

> This hasn't been extensively tested.  Pretty much compile and
> boot tested along with Christoph's test case:
> 
> 	http://marc.info/?l=linux-mm&m=133728900729735

That isn't my favoritest ever changelog text :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
