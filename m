Received: from westrelay01.boulder.ibm.com (westrelay01.boulder.ibm.com [9.17.195.10])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j2AHbw4I119024
	for <linux-mm@kvack.org>; Thu, 10 Mar 2005 12:37:58 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay01.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2AHbwax166304
	for <linux-mm@kvack.org>; Thu, 10 Mar 2005 10:37:58 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j2AHbvUZ026951
	for <linux-mm@kvack.org>; Thu, 10 Mar 2005 10:37:58 -0700
Subject: Re: [PATCH] 0/2 Buddy allocator with placement policy (Version 9)
	+ prezeroing (Version 4)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0503101421260.2105@skynet>
References: <20050307193938.0935EE594@skynet.csn.ul.ie>
	 <1110239966.6446.66.camel@localhost>
	 <Pine.LNX.4.58.0503101421260.2105@skynet>
Content-Type: text/plain
Date: Thu, 10 Mar 2005 09:37:47 -0800
Message-Id: <1110476267.16432.27.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-03-10 at 14:31 +0000, Mel Gorman wrote: 
> > > There are 2 kinds of sections: user and kernel.  The traditional
> > > ZONE_HIGHMEM is full of user sections (except for vmalloc).
> 
> And PTEs if configured to be allocated from high memory. I have not double
> checked but I don't think they can be trivially reclaimed.

We've run into a couple of these pieces of highmem that can't be
reclaimed.  The latest one are pages for the new pipe buffers.  We could
code these up with a flag something like __GFP_HIGHMEM_NORCLM, that is
__GFP_HIGHMEM in the normal case, but 0 in the hotplug case (at least
for now).

> > > Any
> > > section which has slab pages or any kernel caller to alloc_pages() is
> > > a kernel section.
> 
> Slab pages could be moved to the user section as long as the cache owner
> was able to reclaim the slabs on demand.

At least for the large consumers of slab (dentry/inode caches), they
can't quite reclaim on demand.  I was picking Dipankar's brain about
this one day, and there are going to be particularly troublesome
dentries, like "/", that are going to need some serious rethinking to be
able to forcefully free.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
