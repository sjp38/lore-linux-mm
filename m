Received: from mea.tmt.tele.fi (mea.tmt.tele.fi [194.252.70.2])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA02901
	for <linux-mm@kvack.org>; Mon, 8 Feb 1999 16:14:45 -0500
Subject: Re: [PATCH] Re: swapcache bug?
In-Reply-To: <Pine.LNX.3.95.990208104249.606M-100000@penguin.transmeta.com> from Linus Torvalds at "Feb 8, 99 10:48:06 am"
Date: Mon, 8 Feb 1999 23:13:55 +0200 (EET)
From: Matti Aarnio <matti.aarnio@sonera.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <19990208211402Z92298-868+220@mea.tmt.tele.fi>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: sct@redhat.com, masp0008@stud.uni-sb.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@transmeta.com> wrote:
...
> > Linus, I know Matti Aarnio has been working on supporting >32bit offsets
> > on Intel, and for that we really do need to start using the low bits in
> > the page offset for something more useful than MBZ padding. 
> 
> Yes. The page offset will become a "sector offset" (I'd actually like to
> make it a page number, but then I'd have to break ZMAGIC dynamic loading
> due to the fractional page offsets, so it's not worth it for three extra
> bits), and that gives you 41 bits of addressing even on a 32-bit machine.
> Which is plenty - considering that by the time you need more than that
> you'd _really_ better be running on a larger machine anyway. 

	I forgot (didn't log), who sent me a patch to my L-F-S stuff
	for ZMAGIC page mis-alignment report.  (It was somebody here
	at linux-mm list)  His comment was that only *very old* systems
	contain ZMAGIC files with alignments not already in page
	granularity.

	Given certain limitations in low-level block drivers, using that
	'sector index' idea might be worthy.  It gives us essentially up
	to 512 * 4GB or 2 TB file sizes, which matches current low-level
	limitations.

	However, now doing page offset work, we might need to mask the low
	bits of the sector index to do page cache searches.  (Unless the
	alignment is always guaranteed ?)

> Note that some patches I saw (I think by Matti) made "page->offset" a long
> long, and that is never going to happen. That's just a stupid waste of
> time and memory.

	Good heavens! No!  That can't have been mine.

	In my patches the 'page->offset' became ADT called 'pgoff_t'
	which I used to do compile time trapping of missing convertions.
	When simplified ("#if 1" -> "#if 0" in <linux/mm.h> header file),
	the type is just 'u_long'.

	I don't think you have seen my patches, I have posted the URL,
	but not the patches themselves.

	With recent talks in linux-kernel about internal VFS ABI stability
	being an issue, my current L-F-S patch is *not* ready for 2.2.*.
	It changes one thing, and adds another in the inode_operations
	structure, plus adds a field into 'struct task'.

	I would wait a bit until 2.3 opens, collect a bit of experience
	of it there, and then backport (without doing VFS ABI changes) to
	2.2.*.    Otherwise: "Damn the torpedoes!  Full steam ahead!".
	(And we would hear lots of noicy torpedoes...)

... 
> 		Linus

/Matti Aarnio <matti.aarnio@sonera.fi>
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
