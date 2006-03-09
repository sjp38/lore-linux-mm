Message-Id: <200603091231.k29CV9g20079@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [patch] hugetlb strict commit accounting
Date: Thu, 9 Mar 2006 04:31:11 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20060309120631.GC9479@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: wli@holomorphy.com, 'Andrew Morton' <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Gibson wrote on Thursday, March 09, 2006 4:07 AM
> > Well, the reservation is already done at mmap time for shared mapping. Why
> > does kernel need to do anything at fault time?  Doing it at fault time is
> > an indication of weakness (or brokenness) - you already promised at mmap
> > time that there will be a page available for faulting.  Why check them
> > again at fault time?
> 
> You can't know (or bound) at mmap() time how many pages a PRIVATE
> mapping will take (because of fork()).  So unless you have a test at
> fault time (essentialy deciding whether to draw from "reserved" and
> "unreserved" hugepage pool) a supposedly reserved SHARED mapping will
> OOM later if there have been enough COW faults to use up all the
> hugepages before it's instantiated.

I see. But that is easy to fix.  I just need to do exactly the same
thing as what you did to alloc_huge_page.  I will then need to change
definition of 'reservation' to needs-in-the future (also an easy thing
to change).

The real question or discussion I want to bring up is whether kernel
should do it's own accounting or relying on traversing the page cache. 
My opinion is that kernel should do it's own accounting because it is
simpler: you just need to do that at mmap and ftruncate time.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
