Date: Fri, 10 Oct 2008 10:05:35 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [patch 4/8] mm: write_cache_pages type overflow fix
Message-ID: <20081010140535.GD16353@mit.edu>
References: <20081009155039.139856823@suse.de> <20081009174822.516911376@suse.de> <20081009082336.GB6637@infradead.org> <20081010131030.GB16353@mit.edu> <20081010131325.GA16246@infradead.org> <20081010133719.GC16353@mit.edu> <1223646482.25004.13.camel@quoit>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1223646482.25004.13.camel@quoit>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Whitehouse <steve@chygwyn.com>
Cc: Christoph Hellwig <hch@infradead.org>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 10, 2008 at 02:48:02PM +0100, Steven Whitehouse wrote:
> I've not looked at ext4's copy of write_cache_pages, but there is also a
> copy in GFS2. Its used only for journaled data, and it is pretty much a
> direct copy of write_cache_pages except that its split into two so that
> a transaction can be opened in the "middle".
> 
> Perhaps it would be possible to make some changes so that we can both
> share the "core" version of write_cache_pages. My plan was to wait until
> Nick's patches have made it to Linus, and then to look into what might
> be done,

To be clear; ext4 doesn't have its own copy of write_cache_pages (at
least not yet); there is a patch that creates our own copy, mainly to
disable updates to writeback_index, range_start, and nr_to_write in
the wbc structure.

Christoph has suggested a patch which modifies write_cache_pages() so
that a filesystem could set a flag which disables those updates,
instead of just making a copy of write_cache_pages.  (Maybe eventually
we would get rid of those updates unconditionally; it's not clear to
me though that this makes sense for all filesystems.)

So we have three choices as far as getting the 10x for (large)
streaming write performance into 2.6.28:

1) Aneesh's first patch, which called write_cache_pages()
and then undid the effects of the updates to the relevant wbc fields.
(http://lkml.org/lkml/2008/10/6/61)

2) Aneesh's second version of the patch, which copied
write_cache_pages() into ext4_write_cache_pages() and then removed the
updates; resulting in a large patch, but one that might be easier to
understand, although harder to maintain in the long term.
(http://lkml.org/lkml/2008/10/7/52)

3) A version which (optionally via a flag in the wbc structure)
instructs write_cache_pages() to not pursue those updates.  This has
not been written yet.

For why we need to do this, see Aneesh's explanation here: 

    http://lkml.org/lkml/2008/10/7/78

If we don't think the Nick's patches are going to be stable enough for
merging in time for 2.6.28, it's possible we could pursue (1) or (2),
and if there's -mm concurrence, even (3).  (1) might be the best if
the goal is to wait for Nick's patches to hit mainline first, and then
we can try to sort and merge our per-filesystems unique hacks (or
copies of write_cache_pages or whatever) back to the upstream version.

All of this being said, I'll confess that I have *not* had time to
look deeply at Nick's full patchset yet.  Which has been another
reason why I haven't queued up any of Aneesh's patches in this area
yet; all of this hit just right before the merge window opened up, and
I've been insanely busy as of late.

							- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
