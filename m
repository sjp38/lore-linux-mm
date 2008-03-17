Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2HF3gLR019714
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 11:03:42 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2HF3UYi240920
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 09:03:31 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2HF3Lko008658
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 09:03:21 -0600
Subject: Re: [PATCH] [0/18] GB pages hugetlb support
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080317258.659191058@firstfloor.org>
References: <20080317258.659191058@firstfloor.org>
Content-Type: text/plain
Date: Mon, 17 Mar 2008 10:05:07 -0500
Message-Id: <1205766307.10849.38.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Mon, 2008-03-17 at 02:58 +0100, Andi Kleen wrote:
<snip>
> - lockdep sometimes complains about recursive page_table_locks
> for shared hugetlb memory, but as far as I can see I didn't
> actually change this area. Looks a little dubious, might
> be a false positive too.

I bet copy_hugetlb_page_range() is causing your complaints.  It takes
the dest_mm->page_table_lock followed by src_mm->page_table_lock inside
a loop and hasn't yet been converted to call spin_lock_nested().  A
harmless false positive.

> - hugemmap04 from LTP fails. Cause unknown currently

I am not sure how well LTP is tracking mainline development in this
area.  How do these patches do with the libhugetlbfs test suite?  We are
adding support for ginormous pages (1GB, 16GB, etc) but it is not
complete.  Should run fine with 2M pages though.

Before you ask, here is the link:
http://libhugetlbfs.ozlabs.org/snapshots/libhugetlbfs-dev-20080310.tar.gz

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
