Date: Wed, 23 Feb 2000 10:58:41 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: mmap/munmap semantics
In-Reply-To: <Pine.LNX.4.10.10002231137450.5002-100000@linux14.zdv.uni-tuebingen.de>
Message-ID: <Pine.LNX.3.96.1000223104315.3536A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Guenther <richard.guenther@student.uni-tuebingen.de>
Cc: Linux Kernel List <linux-kernel@vger.rutgers.edu>, glame-devel@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Feb 2000, Richard Guenther wrote:

> No, I do not want to extend the file. I want to do a mmap of a _part_
> (in the middle) of an existing and have this part automagically zeroed
> regardless if there was a hole (already zeroed) or some other data.
> With the mmap & read(/dev/zero) approach I can achieve this, but I do not
> know if it is portably (wrt to effectvieness).

It should be portable, but it still isn't as efficient as just dumping the
pages since it generates io.

> > > So for the first case we could add a flag to mmap like MAP_ZERO to
> > > indicate a zero-map (dirty).
> > 
> > Or teach truncate about preallocation.
> 
> ?? I do not understand this. Truncate does not operate on ranges in the
> middle of a file, no?

I think I see what you're trying to do now, so just ignore this part =)

> So how can I throw away a dirty (shared) mapping of a file without
> generating disk io? Remember, I do not care about the contents of the file
> at the mmap place.
> A possible solution would be to be able to convert a shared mapping to
> a private one? If I'm the only user of the shared mapping (so its a
> virtually private one) this should be easy - just "disconnect" it. In the
> other case I do not really know how to handle this.

The most portable and easiest way to achieve this behaviour right now is
to use individual files or shm segments for the shared mappings.  Using
SysV shared memory will get you the most performance since it won't get
written back to disk early (like mmaped files).  If that doesn't give you
enough space, I strongly recommend using 1 file per shared "segment",
since the semantics you get by truncating and then extending the mapping
are exactly what you want.  As a bonus, this technique works on
filesystems that don't support files with holes =)

		-ben


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
