Date: Thu, 19 Oct 2006 00:22:37 -0700 (PDT)
Message-Id: <20061019.002237.130236131.davem@davemloft.net>
Subject: Re: [PATCH] mm:D-cache aliasing issue in cow_user_page
From: David Miller <davem@davemloft.net>
In-Reply-To: <20061019001747.7da58920.akpm@osdl.org>
References: <20061018233302.a067d1e7.akpm@osdl.org>
	<20061019.000027.41635681.davem@davemloft.net>
	<20061019001747.7da58920.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Andrew Morton <akpm@osdl.org>
Date: Thu, 19 Oct 2006 00:17:47 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: dmonakhov@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, 19 Oct 2006 00:00:27 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > Unfortunately, the kernel has just touched the page and thus there are
> > active cache lines for the kernel side mapping.  When we map this into
> > user space, userspace might see stale cachelines instead of the
> > memset() stores.
> 
> hm.  Has it always been that way or did something change?

Always.

> > Architectures typically take care of this in copy_user_page() and
> > clear_user_page().  The absolutely depend upon those two routines
> > being used for anonymous pages, and handle the D-cache issues there.
> 
> Only anonymous pages?  There are zillions of places where we modify
> pagecache without a flush, especially against the blockdev mapping (fs
> metadata).

It's cpu stores that matter, not device DMA and the like, and we have
flush_dcache_page() calls in the correct spots.  You can see that
we take care of this even in places such as the loop driver :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
