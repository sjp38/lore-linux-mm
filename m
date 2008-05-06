Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m46HNfHo012833
	for <linux-mm@kvack.org>; Tue, 6 May 2008 13:23:41 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m46HNfim195380
	for <linux-mm@kvack.org>; Tue, 6 May 2008 13:23:41 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m46HNfpT004245
	for <linux-mm@kvack.org>; Tue, 6 May 2008 13:23:41 -0400
Subject: Re: [RFC][PATCH 1/2] Add shared and reserve control to
	hugetlb_file_setup
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080505105826.GA11027@csn.ul.ie>
References: <1209693089.8483.22.camel@grover.beaverton.ibm.com>
	 <1209744977.7763.29.camel@nimitz.home.sr71.net>
	 <20080505105826.GA11027@csn.ul.ie>
Content-Type: text/plain
Date: Tue, 06 May 2008 10:23:39 -0700
Message-Id: <1210094619.4747.41.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: ebmunson@us.ibm.com, linux-mm@kvack.org, nacc <nacc@linux.vnet.ibm.com>, andyw <andyw@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-05-05 at 11:58 +0100, Mel Gorman wrote:
> On (02/05/08 09:16), Dave Hansen didst pronounce:
> > On Thu, 2008-05-01 at 18:51 -0700, Eric B Munson wrote:
> > > In order to back stacks with huge pages, we will want to make hugetlbfs
> > > files to back them; these will be used to back private mappings.
> > > Currently hugetlb_file_setup creates files to back shared memory segments.
> > > Modify this to create both private and shared files,
> > 
> > Hugetlbfs can currently have private mappings, right?  Why not just use
> > the existing ones instead of creating a new variety with
> > hugetlb_file_setup()?
> > 
> 
> hugetlb_file_setup() uses an internal mount to create files just for
> SHM. However, it does the work necessary for MAP_SHARED mappings,
> particularly reserve pages. The account is currently all fouled up to
> deal with a private mapping that has reserves. Teaching
> hugetlb_file_setup() to deal with private and shared mappings does
> appear the most straight-forward route.

I agree that this is the most straightforward route, especially for a
proof of concept like this.  However, I worry that it is not a good
route for merging since it doesn't really put us on the road to a more
comprehensive solution.  How easy is it to extend this code for stack
growth or randomization, for instance?  Can we make this solve any other
problems?  Is there any way (or reason) to do generic file-backed
stacks?

Does anybody know of any important cases of applications changing their
rlimits after exec()?

In any case, it looks like I'm the only one objecting to it, so let's
try to get it a better changelog.  How about this for a summary?

There are two kinds of "Shared" hugetlbfs mappings:
1. using internal vfsmount use ipc/shm.c and shmctl()
2. mmap() of /hugetlbfs/file with MAP_SHARED

There is one kind of private: mmap() of /hugetlbfs/file file with
MAP_PRIVATE

(Eric could you fill in what the current reservation and prefaulting
rules are and what you expect from the new code?)

This patch adds a second class of "private" hugetlb-backed mapping.  But
we do it by sharing code with the ipc shm.  This is mostly because we
need to do our stack setup at execve() time and can't go opening files
from hugetlbfs.  The kernel-internal vfsmount for shm lets us get around
this.  We truly want anonymous memory, but MAP_PRIVATE is close enough
for now.

The hugetlb stack VMA is set up at execve() time and is fixed in size.
We derive the size from looking at the stack ulimit.  The stack pages
are faulted in as needed, but the stack VMA stays fixed in size.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
