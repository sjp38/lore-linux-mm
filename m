Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 71D629000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 16:43:44 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p8MKhgel016966
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 13:43:42 -0700
Received: from gyf1 (gyf1.prod.google.com [10.243.50.65])
	by wpaz13.hot.corp.google.com with ESMTP id p8MKgf4B004016
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 13:43:41 -0700
Received: by gyf1 with SMTP id 1so2146960gyf.9
        for <linux-mm@kvack.org>; Thu, 22 Sep 2011 13:43:40 -0700 (PDT)
Date: Thu, 22 Sep 2011 13:43:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH] show page size in /proc/$pid/numa_maps
In-Reply-To: <20110921221329.5B7EE5C5@kernel>
Message-ID: <alpine.DEB.2.00.1109221339520.31548@chino.kir.corp.google.com>
References: <20110921221329.5B7EE5C5@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 21 Sep 2011, Dave Hansen wrote:

> 
> The output of /proc/$pid/numa_maps is in terms of number of pages
> like anon=22 or dirty=54.  Here's some output:
> 
> 7f4680000000 default file=/hugetlb/bigfile anon=50 dirty=50 N0=50
> 7f7659600000 default file=/anon_hugepage\040(deleted) anon=50 dirty=50 N0=50
> 7fff8d425000 default stack anon=50 dirty=50 N0=50
> 
> Looks like we have a stack and a couple of anonymous hugetlbfs
> areas page which both use the same amount of memory.  They don't.
> 
> The 'bigfile' uses 1GB pages and takes up ~50GB of space.  The
> anon_hugepage uses 2MB pages and takes up ~100MB of space while
> the stack uses normal 4k pages.  You can go over to smaps to
> figure out what the page size _really_ is with KernelPageSize
> or MMUPageSize.  But, I think this is a pretty nasty and
> counterintuitive interface as it stands.
> 
> The following patch adds a pagemult= field.  It is placed only
> in cases where the VMA's page size differs from the base kernel
> page size.  I'm calling it pagemult to emphasize that it is
> indended to modify the statistics output rather than _really_
> show the page size that the kernel or MMU is using.
> 

Why not just add a pagesize={4K,2M,1G,...} field for every output?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
