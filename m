Received: from westrelay01.boulder.ibm.com (westrelay01.boulder.ibm.com [9.17.195.10])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j27Nxbua507336
	for <linux-mm@kvack.org>; Mon, 7 Mar 2005 18:59:37 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay01.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j27NxbWY147858
	for <linux-mm@kvack.org>; Mon, 7 Mar 2005 16:59:37 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j27NxbqZ005803
	for <linux-mm@kvack.org>; Mon, 7 Mar 2005 16:59:37 -0700
Subject: Re: [PATCH] 0/2 Buddy allocator with placement policy (Version 9)
	+ prezeroing (Version 4)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050307193938.0935EE594@skynet.csn.ul.ie>
References: <20050307193938.0935EE594@skynet.csn.ul.ie>
Content-Type: text/plain
Date: Mon, 07 Mar 2005 15:59:26 -0800
Message-Id: <1110239966.6446.66.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-03-07 at 19:39 +0000, Mel Gorman wrote:
> The placement policy patch should now be more Hotplug-friendly and I
> would like to hear from the Hotplug people if they have more
> requirements of this patch.

It looks like most of what we need is there already.  There are two
things that come to mind.  We'll likely need some modifications that
will deal with committing memory areas that are larger than MAX_ORDER to
the different allocation pools.  That's because a hotplug area (memory
section) might be larger than a single MAX_ORDER area, and each section
may need to be limited to a single allocation type.

The other thing is that we'll probably have to be a lot more strict
about how the allocations fall back.  Some users will probably prefer to
kill an application rather than let a kernel allocation fall back into a
user memory area.

But, those are things that can be relatively easily grafted on to your
current code.  I'm not horribly concerned about that, and merging
something like that is months and months away.

BTW, I wrote some requirements about how these section divisions might
be dealt with.  Note that this is a completely hotplug-centric view of
the whole problem, I didn't discern between reclaimable and
unreclaimable kernel memory as your patch does.  This is probably waaaay
more than you wanted to hear, but I thought I'd share anyway. :)

> There are 2 kinds of sections: user and kernel.  The traditional 
> ZONE_HIGHMEM is full of user sections (except for vmalloc).  Any
> section which has slab pages or any kernel caller to alloc_pages() is
> a kernel section.
> 
> Some properties of these sections:
> a. User sections are easily removed.
> b. Kernel sections are hard to remove. (considered impossible)
> c. User sections may *NOT* be used for kernel pages if all user
>    sections are full. (but, see f.)
> d. Kernel sections may be used for user pages if all user sections are
>    full.
> e. A transition from a kernel section to a user section is hard, and
>    requires that it be empty of all kernel users.
> f. A transition from a user section to a kernel section is easy.
>    (although easy, this should be avoided because it's hard to turn it
>    _back_ into a user section)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
