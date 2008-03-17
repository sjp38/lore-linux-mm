Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2HFxLGK028619
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 11:59:21 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2HFvKUE205530
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 11:57:20 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2HFvJjl008933
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 11:57:20 -0400
Subject: Re: [PATCH] [0/18] GB pages hugetlb support
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080317153314.GD5578@one.firstfloor.org>
References: <20080317258.659191058@firstfloor.org>
	 <1205766307.10849.38.camel@localhost.localdomain>
	 <20080317153314.GD5578@one.firstfloor.org>
Content-Type: text/plain
Date: Mon, 17 Mar 2008 10:59:06 -0500
Message-Id: <1205769546.10849.43.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Mon, 2008-03-17 at 16:33 +0100, Andi Kleen wrote:
> > I bet copy_hugetlb_page_range() is causing your complaints.  It takes
> > the dest_mm->page_table_lock followed by src_mm->page_table_lock inside
> > a loop and hasn't yet been converted to call spin_lock_nested().  A
> > harmless false positive.
> 
> Yes. Looking at the warning I'm not sure why lockdep doesn't filter
> it out automatically. I cannot think of a legitimate case where
> a "possible recursive lock" with different lock addresses would be 
> a genuine bug.
> 
> So instead of a false positive, it's more like a "always false" :)
> 
> > 
> > > - hugemmap04 from LTP fails. Cause unknown currently
> > 
> > I am not sure how well LTP is tracking mainline development in this
> > area.  How do these patches do with the libhugetlbfs test suite?  We are
> 
> I wasn't aware of that one.

Libhugetlbfs comes with a rigorous functional test suite.  It has test
cases for specific bugs that have since been fixed.  I ran it on your
patches and got an oops around hugetlb_overcommit_handler() when running
the 'counters' test.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
