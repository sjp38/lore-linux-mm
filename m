Message-ID: <20040619031536.61508.qmail@web10902.mail.yahoo.com>
Date: Fri, 18 Jun 2004 20:15:36 -0700 (PDT)
From: Ashwin Rao <ashwin_s_rao@yahoo.com>
Subject: Atomic operation for physically moving a page (for memory defragmentation)
In-Reply-To: <200406190103.i5J13WWr010687@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Valdis.Kletnieks@vt.edu, haveblue@us.ibm.com
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--- Valdis.Kletnieks@vt.edu wrote:
> On Fri, 18 Jun 2004 17:37:12 PDT, Ashwin Rao
>said:
> > I want to copy a page from one physical location
> to
> > another (taking the appr. locks).
> 
> At the risk of sounding stupid, what problem are you
> trying to solve by copying
> a page? Not only (as you note) could the page be
> referenced by multiple
> processes, it could (conceivably) belong to a kernel
> slab or something, or be a
> buffer for an in-flight I/O request, or any number
> of other possibly-racy
> situations.
> 

The problem is the memory fragmentation. The code i am
writing is for the memory defragmentation as proposed
by Daniel Phillips, my project partner Alok mooley has
given mailed a simple prototype in the mid of feb.

> If it's only a specific *type* of page, or
> explaining why you're trying to do
> it, or what timing/etc constraints you have (if it's
> a sufficiently rare(*) case,
> it might make sense to just grab the BKL and copy
> the page with a memcpy().)
> 

The pages in the LRU list are selected. As these pages
can be swapped they can moved to another location in
the memory.

> (*) Yes, I know the BKL isn't something you want to
> grab if you can help it.

Isnt it a bad idea to take the BKL, the performance of
SMP systems will drastically be hampered.

> However, if we're on an unlikely error path or
> similar and other options aren't suitable...
The way we work is as follows
Initially a block is selected which can be moved i.e
pages on lru or free and the pages are moved to a
suitable free pages. The main problem arises during
the copying and updation process. All the ptes are to
updates. a method similar to try_to_unmap_one  is used
to identify the ptes and the physical address is
updated.

Maintaining atomicity in uniprocessor systems is easy
by preempt_enable and preempt_disable during the
operation. This implementation cannot be used for SMP
systems. 
Now during the time a page is copied/updatede if a
page is accessed the copied contents become invalid,
as updation is not done. Also during updation a
similar situation might arise.
The problem we are facing is to maintain the atomicity
of this operation on SMP boxes.

Ashwin


	
		
__________________________________
Do you Yahoo!?
New and Improved Yahoo! Mail - 100MB free storage!
http://promotions.yahoo.com/new_mail 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
