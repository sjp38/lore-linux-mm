Date: Sun, 7 Jul 2002 00:53:22 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
In-Reply-To: <1048271645.1025997192@[10.10.2.3]>
Message-ID: <Pine.LNX.4.44.0207070041260.2262-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <fletch@aracnet.com>
Cc: Andrew Morton <akpm@zip.com.au>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Sat, 6 Jul 2002, Martin J. Bligh wrote:
>
> I think that might have been when Andrea was using persistent kmap
> for highpte (since fixed), so we were really kicking the **** out
> of it. Nonetheless, your point is perfectly correct, it's the
> global invalidate that's really the expensive thing.

I suspect that there really aren't that many places that care about the
persistent mappings, and the atomic per-cpu stuff is inherently scalable
(but due to being harder to cache, slower). So I wonder how much of a
problem the kmap stuff really is.

So if the main problem ends up being that some paths (a) really want the
persistent version _and_ (b) you can make the paths hold them for long
times (by writing to a blocking pipe/socket or similar) we may just have
much simpler approaches - like a per-user kmap count.

It's not hard to make kmap() do something the equivalent of

	down(current->user->kmap_max);

and make kunmap() just do the "up()", and then just initialize the user
kmap_max semaphore to something simple like 100.

Which just guarantees that any user at any time can only hold 100
concurrent persistent kmap's open. Problem solved.

(and yeah, you can make it configurable on a per-user level or something,
so that if it turns out that oracle really has 100 threads all blocking on
a socket at the same time, you can admin up the oracle count).

The _performance_ scalability concerns should be fairly easily solvable
(as far as I can tell - feel free to correct me) by making the persistent
array bigger and finding things where persistency isn't needed (and
possibly doesn't even help due to lack of locality), and just making those
places use the per-cpu atomic ones.

Eh?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
