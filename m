Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j03Jbtm4172908
	for <linux-mm@kvack.org>; Mon, 3 Jan 2005 14:37:55 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j03Jbt8Y445112
	for <linux-mm@kvack.org>; Mon, 3 Jan 2005 12:37:55 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j03JbtDS002192
	for <linux-mm@kvack.org>; Mon, 3 Jan 2005 12:37:55 -0700
Subject: Re: page migration
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <41D99743.5000601@sgi.com>
References: <41D98556.8050605@sgi.com> <1104776733.25994.11.camel@localhost>
	 <41D99743.5000601@sgi.com>
Content-Type: text/plain
Date: Mon, 03 Jan 2005 11:37:41 -0800
Message-Id: <1104781061.25994.19.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Marcello Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-01-03 at 13:04 -0600, Ray Bryant wrote:
> Once we get that done I'd like to pursure getting the migration patches 
> proposed for -mm and then mainline.  Does that make sense?

Yep.

> (perhaps it will make the hotplug patch easier to accept if we can get the 
> memory migration stuff in first).

I was going to do hotplug first only because it created a requirement
for migration.  Since you have a separate requirement for it, I have no
objection to doing migration first.  

> Of course, the "standalone" memory migration stuff makes most sense on NUMA, 
> and there is some minor interface changes there to support that (i. e. consider:
> 
> migrate_onepage(page);
> 
> vs
> 
> migrate_onepage_node(page, node);
> 
> what the latter does is to call alloc_pages_node() instead of
> page_cache_alloc() to get the new page.)

We might as well just change all of the users over to the NUMA version
from the start.  Having 2 different functions just causes confusion.  

> This is all to support NUMA process and memory migration, where the
> required function is to move a process >>and<< its memory from one
> set of nodes to another.  (I should have a patch for these initial
> interface changes later this week.)

Well, moving the process itself isn't very hard, right?  That's just a
schedule().  

> But the real question I am wrestling with at the moment is the following:
> 
> "Which approach to a NUMA process and memory migration facility would be more 
> likely to get into the mainline kernel:
> 
> (1)  One based on the existing memory migration patches, or
> 
> (2)  something simpler just written for the NUMA process and memory
>       migration case."
>
> My preference would be to build on top of the existing code
> from the hotplug project.  But the key goal here is to get the code
> into the mainline.  I am a little concerned that the hotlug memory migration
> code will be regarded as too complicated to get in, and I don't want that
> to hold up the NUMA process and memory migration facility, which is what I am
> working on and we (well, SGI) specifically need.

Are there any particular parts that you think are overly complicated?

Yes, it's complicated, but I'm not convinced that it can be implemented
much better than it has been.  This is another classic problem where 99%
of the work can be solved with 50% of the code.  It's getting it that
last 1% of the way and making it complete and *correct* that takes a lot
of work. 

Anyway, I'd love to see a simpler version if it's possible.  I'd just
keep Marcello and Hirokazu in the loop if you're going to try. 

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
