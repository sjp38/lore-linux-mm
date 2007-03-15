Date: Thu, 15 Mar 2007 17:44:01 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
In-Reply-To: <20070315162944.GI8321@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0703151719380.32335@blonde.wat.veritas.com>
References: <Pine.GSO.4.64.0703081612290.1080@cpu102.cs.uwaterloo.ca>
 <20070312142012.GH30777@atrey.karlin.mff.cuni.cz> <20070312143900.GB6016@wotan.suse.de>
 <20070312151355.GB23532@duck.suse.cz> <Pine.GSO.4.64.0703121247210.7679@cpu102.cs.uwaterloo.ca>
 <20070312173500.GF23532@duck.suse.cz> <Pine.GSO.4.64.0703131438580.8193@cpu102.cs.uwaterloo.ca>
 <20070313185554.GA5105@duck.suse.cz> <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca>
 <45F96CCB.4000709@redhat.com> <20070315162944.GI8321@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Chuck Ebbert <cebbert@redhat.com>, Ashif Harji <asharji@cs.uwaterloo.ca>, Miquel van Smoorenburg <miquels@cistron.nl>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Mar 2007, Nick Piggin wrote:
> On Thu, Mar 15, 2007 at 11:56:59AM -0400, Chuck Ebbert wrote:
> > Ashif Harji wrote:
> > > 
> > > This patch unconditionally calls mark_page_accessed to prevent pages,
> > > especially for small files, from being evicted from the page cache
> > > despite frequent access.
> > > 
> > > Signed-off-by: Ashif Harji <asharji@beta.uwaterloo.ca>

Yeah, yeah, I'm not a real mman, I don't have my own patch and
website for this ;) but I'm old, let me mumble some history...

Ashif's patch would take us back to 2.4.10 when mark_page_accessed
was introduced: in 2.4.11 someone (probably Andrea) immediately
added a !offset || !filp->f_reada condition on it there, which
remains in 2.4 to this day.  That _probably_ means that Ashif's
patch is suboptimal, and that your !offset patch is good.

f_reada went away in 2.5.8, and the !offset condition remained
until 2.6.11, when Miquel (CC'ed) replaced it by today's prev_index
condition.  His changelog entry appended below.  Since it's Miquel
who removed the !offset condition, he should be consulted on its
reintroduction.

Hugh

> > 
> > I like mine better -- it leaves the comment:
> 
> How about this? It also doesn't break the use-once heuristic.
> 
> --
> A change to make database style random read() workloads perform better, by
> calling mark_page_accessed for some non-page-aligned reads broke the case of
> < PAGE_CACHE_SIZE files, which will not get their prev_index moved past the
> first page.
> 
> Combine both heuristics for marking the page accessed.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> Index: linux-2.6/mm/filemap.c
> ===================================================================
> --- linux-2.6.orig/mm/filemap.c
> +++ linux-2.6/mm/filemap.c
> @@ -929,7 +929,7 @@ page_ok:
>  		 * When (part of) the same page is read multiple times
>  		 * in succession, only mark it as accessed the first time.
>  		 */
> -		if (prev_index != index)
> +		if (prev_index != index || !offset)
>  			mark_page_accessed(page);
>  		prev_index = index;
>  

Miquel's patch comment from ChangeLog-2.6.11:

[PATCH] mark_page_accessed() for read()s on non-page boundaries

When reading a (partial) page from disk using read(), the kernel only marks
the page as "accessed" if the read started at a page boundary.  This means
that files that are accessed randomly at non-page boundaries (usually
database style files) will not be cached properly.

The patch below uses the readahead state instead.  If a page is read(), it
is marked as "accessed" if the previous read() was for a different page,
whatever the offset in the page.

Testing results:


- Boot kernel with mem=128M

- create a testfile of size 8 MB on a partition. Unmount/mount.

- then generate about 10 MB/sec streaming writes

	for i in `seq 1 1000`
	do
		dd if=/dev/zero of=junkfile.$i bs=1M count=10
		sync
		cat junkfile.$i > /dev/null
		sleep 1
	done

- use an application that reads 128 bytes 64000 times from a
  random offset in the 64 MB testfile.

1. Linux 2.6.10-rc3 vanilla, no streaming writes:

# time ~/rr testfile
Read 128 bytes 64000 times
~/rr testfile  0.03s user 0.22s system 5% cpu 4.456 total

2. Linux 2.6.10-rc3 vanilla, streaming writes:

# time ~/rr testfile
Read 128 bytes 64000 times
~/rr testfile  0.03s user 0.16s system 2% cpu 7.667 total
# time ~/rr testfile
Read 128 bytes 64000 times
~/rr testfile  0.03s user 0.37s system 1% cpu 23.294 total
# time ~/rr testfile
Read 128 bytes 64000 times
~/rr testfile  0.02s user 0.99s system 1% cpu 1:11.52 total
# time ~/rr testfile
Read 128 bytes 64000 times
~/rr testfile  0.03s user 0.21s system 2% cpu 10.273 total

3. Linux 2.6.10-rc3 with read-page-access.patch , streaming writes:

# time ~/rr testfile
Read 128 bytes 64000 times
~/rr testfile  0.02s user 0.21s system 3% cpu 7.634 total
# time ~/rr testfile
Read 128 bytes 64000 times
~/rr testfile  0.04s user 0.22s system 2% cpu 9.588 total
# time ~/rr testfile
Read 128 bytes 64000 times
~/rr testfile  0.02s user 0.12s system 24% cpu 0.563 total
# time ~/rr testfile
Read 128 bytes 64000 times
~/rr testfile  0.03s user 0.13s system 98% cpu 0.163 total

As expected, with the read-page-access.patch, the kernel keeps the 8 MB
testfile cached as expected, while without it, it doesn't.

So this is useful for workloads where one smallish (wrt RAM) file is read
randomly over and over again (like heavily used database indexes), while
other I/O is going on.  Plain 2.6 caches those files poorly, if the app
uses plain read().

Signed-Off-By: Miquel van Smoorenburg <miquels@cistron.nl>
Signed-off-by: Andrew Morton <akpm@osdl.org>
Signed-off-by: Linus Torvalds <torvalds@osdl.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
