Message-ID: <452A7AD3.5050006@yahoo.com.au>
Date: Tue, 10 Oct 2006 02:37:39 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Driver-driven paging?
References: <452A68E9.3000707@tungstengraphics.com>
In-Reply-To: <452A68E9.3000707@tungstengraphics.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Hellstrom <thomas@tungstengraphics.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thomas Hellstrom wrote:
> Hi!
> 
> While trying to put together an improved graphics memory manager in the 
> DRM kernel module, I've identified a need to swap out backing store 
> pages which haven't been in use for a while, and I was wondering if 
> there is a kernel mm API to do that?
> 
> Basically when a graphics object is created, space is allocated either 
> in on-card video RAM or in a backup object in system RAM. That backup 
> object can optionally be flipped into the AGP aperture for fast and 
> linear graphics card access.
> 
> What I want to do is to be able to release backup object pages while 
> maintaining the contents. Basically hand them over to the swapping 
> system and get a handle back that can be used for later retrieval. The 
> driver will unmap all mappings referencing the page before handing it 
> over to the swapping system.
> 
> Is there an API for this and is there any chance of getting it exported?

I suspect you will run into a few troubles trying to do it all in kernel.
It might be possible, but probably not with the current code, and it
isn't clear we'd want to make the required changes to support such a
thing.

Your best bet might be to have a userspace "memory manager" process, which
allocates pages (anonymous or file backed), and has your device driver
access them with get_user_pages. The get_user_pages takes care of faulting
the pages back in, and when they are released, the memory manager will
swap them out on demand.

If you need for the driver to *then* export these pages out to be mapped
by other processes in userspace, I think you run into problems if trying
to use nopage. You'll need to go the nopfn route (and thus your mappings
must disallow PROT_WRITE && MAP_PRIVATE).

But I think that might just work?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
