Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8DJphnA001142
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 15:51:43 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8DJphw3417454
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 13:51:43 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8DJphGV008226
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 13:51:43 -0600
Subject: Re: 2.6.23-rc4-mm1 memory controller BUG_ON()
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1189712083.17236.1626.camel@localhost>
References: <1189712083.17236.1626.camel@localhost>
Content-Type: text/plain
Date: Thu, 13 Sep 2007 12:51:41 -0700
Message-Id: <1189713102.17236.1647.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@in.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-09-13 at 12:34 -0700, Dave Hansen wrote:
> Looks like somebody is holding a lock while trying to do a
> mem_container_charge(), and the mem_container_charge() call is doing an
> allocation.  Naughty.
> 
> I'm digging into it a bit more, but thought I'd report it, first.
> 
> .config: http://sr71.net/~dave/linux/memory-controller-bug.config

I'm now thinking this is because the add_to_page_cache() functions have
a gfp_mask passed in, and the mem_container_charge() functions don't
take that mask.  So, even if the add_to_page_cache() user specified !
__GFP_WAIT, the mem_container_charge() function can sleep on its
kmalloc.

I'll try passing gfp_flags through to it and see what happens.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
