Message-ID: <3D28042E.B93A318C@zip.com.au>
Date: Sun, 07 Jul 2002 02:04:46 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
References: <1048271645.1025997192@[10.10.2.3]> <Pine.LNX.4.44.0207070041260.2262-100000@home.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Martin J. Bligh" <fletch@aracnet.com>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> ...
> The _performance_ scalability concerns should be fairly easily solvable
> (as far as I can tell - feel free to correct me) by making the persistent
> array bigger and finding things where persistency isn't needed (and
> possibly doesn't even help due to lack of locality), and just making those
> places use the per-cpu atomic ones.
> 
> Eh?

You mean just tune up the existing code, basically.

There's certainly plenty of opportunity to do that.

Probably the biggest offenders are generic_file_read/write.  In
generic_file_write() we're already faulting in the user page(s)
beforehand (somewhat racily, btw).  We could formalise that into
a pin_user_page_range() or whatever and use an atomic kmap
in there.

Use the same thing in file_read_actor.

The fs/buffer.c code is very profilgate.  It kmaps the page
unconditionally, but in the great majority of cases, it
never uses that kmap.

Plus we're still kmapping pages twice on the prepare_write/commit_write
path.  That doesn't use another kmap.  But.

clear_user_highpage() is using atomic kmap already.

Networking uses kmaps, but from a quick peek it seems that it's mostly
using kmap_atomic already, and a pin_user_page_range()/unpin_user_page_range()
API could be dropped in there quite easily if needed.

ext2 directories will require some thought.

Martin, what sort of workload were you seeing the problems with?


I can fix the buffer.c and filemap.c stuff and then we can take
another look at it.

I'm just not too sure about the pin_user_page() thing.  How
expensive is a page table walk in there likely to be?

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
