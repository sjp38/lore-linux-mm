Date: Mon, 9 Sep 2002 10:29:50 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] slabasap-mm5_A2
Message-ID: <20020909102950.A2765@redhat.com>
References: <200209071006.18869.tomlins@cam.org> <200209081142.02839.tomlins@cam.org> <3D7BB97A.6B6E4CA5@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D7BB97A.6B6E4CA5@digeo.com>; from akpm@digeo.com on Sun, Sep 08, 2002 at 01:56:26PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Ed Tomlinson <tomlins@cam.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, Sep 08, 2002 at 01:56:26PM -0700, Andrew Morton wrote:

> Right.  There remains the issue that we're ripping away constructed
> objects from slabs which have constructors, as Stephen points out.
> 
> I doubt if that matters.  slab constructors just initialise stuff.
> If the memory is in cache then the initialisation is negligible.
> If the memory is not in cache then the initialisation will pull
> it into cache, which is something which we needed to do anyway.  And
> unless the slab's access pattern is extremely LIFO, chances are that
> most allocations will come in from part-filled slab pages anyway.

I'm not sure this was right back when cache lines were 32 or 64 bytes:
the constructor stuff really could have helped to avoid pulling the
whole object into cache, especially for largish data structures like
buffer_heads where initialisation often only touches a few header
cache lines, and the rest is only needed once we submit it for IO.
(Of course, the bh lifespan was never sufficiently well examined for
anyone to actuall code that: to many places left fields in undefined
states so we all just assumed that bhes would be zeroed on allocation
all the time.)

But now that cache lines are typically at least 128 bytes on modern
CPUs, the gain from constructors is much less obvious.  There's so
much false aliasing in the cache that we'll probably need the whole
object in cache on allocation most of the time.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
