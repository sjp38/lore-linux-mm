Date: Mon, 8 Jul 2002 17:08:41 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <20020708170841.Q13063@redhat.com>
References: <3D28042E.B93A318C@zip.com.au> <Pine.LNX.4.44.0207071128170.3271-100000@home.transmeta.com> <3D293E19.2AD24982@zip.com.au> <20020708080953.GC1350@dualathlon.random> <3D29F868.1338ACF3@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D29F868.1338ACF3@zip.com.au>; from akpm@zip.com.au on Mon, Jul 08, 2002 at 01:39:04PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, "Martin J. Bligh" <fletch@aracnet.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 08, 2002 at 01:39:04PM -0700, Andrew Morton wrote:
> I think I'll just go for pinning the damn page.  It's a spinlock and
> maybe three cachelines but the kernel is about to do a 4k memcpy
> anyway.  And get_user_pages() doesn't show up much on O_DIRECT
> profiles and it'll be a net win and we need to do SOMETHING, dammit.

Pinning the page costs too much (remember, it's only a win with a 
reduced copy of more that 512 bytes).  The right way of doing it is 
letting copy_*_user fail on a page fault for places like this where 
we need to drop locks before going into the page fault handler.

		-ben
-- 
"You will be reincarnated as a toad; and you will be much happier."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
