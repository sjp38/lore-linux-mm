Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k3QJkLHK004720
	for <linux-mm@kvack.org>; Wed, 26 Apr 2006 15:46:21 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3QJkL5Q201170
	for <linux-mm@kvack.org>; Wed, 26 Apr 2006 15:46:21 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k3QJkLWK013465
	for <linux-mm@kvack.org>; Wed, 26 Apr 2006 15:46:21 -0400
Received: from mpk2005.rchland.ibm.com (mpk2005.rchland.ibm.com [9.10.86.58] (may be forged))
	by d01av04.pok.ibm.com (8.12.11/8.12.11) with ESMTP id k3QJkLEx013432
	for <linux-mm@kvack.org>; Wed, 26 Apr 2006 15:46:21 -0400
Subject: [RFC] Hugetlb fallback to normal pages
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Wed, 26 Apr 2006 14:46:20 -0500
Message-Id: <1146080780.3872.69.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks to the latest hugetlb accounting patches, we now have reliable
shared mappings.  Private mappings are much more difficult because there
is no way to know up-front how many huge pages will be required (we may
have forking combined with unknown copy-on-write activity).  So private
mappings currently get full overcommit semantics and when a fault cannot
be handled, the apps get SIGBUS.

The problem: Random SIGBUS crashes for applications using large pages
are not acceptable.  We need a way to handle the fault without giving up
and killing the process.

So I've been mulling it over and as I see it, we either 1) Swap out huge
pages, or 2) Demote huge pages.  In either case we need to be willing to
accept the performance penalty to gain stability.  At this point, I
think swapping is too intrusive and way too slow so I am considering
demotion options.  To simplify things at first, I am only considering
i386 (and demoting only private mappings of course).

Here's my idea:  When we fail to instantiate a new page at fault time,
split the affected vma such that we have a new vma to cover the 1 huge
page we are demoting.  Allocate HPAGE_SIZE/PAGE_SIZE normal pages.  Use
the page table to locate any populated hugetlb pages.  Copy the data
into the normal pages and install them in the page table.  Do any other
fixup required to make the new VMA anonymous.  Return.

Any general opinions on the idea (flame retardant suit is equipped)?  As
far as I can tell, we don't split vmas during fault anywhere else.  Is
there inherent problems with doing so?  What about the conversion
process to an anonymous VMA?  Since we are dealing with private mappings
only, divorcing the vma from the hugetlbfs file should be okay afaics.

I know code speaks louder than words, but talk is cheap and that's why
I'm starting with it :)  Thanks for your comments.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
