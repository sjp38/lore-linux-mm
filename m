Date: Tue, 24 Feb 1998 09:45:50 GMT
Message-Id: <199802240945.JAA03090@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: PATCH: Swap shared pages (was: How to read-protect a vm_area?)
In-Reply-To: <Pine.LNX.3.95.980223184015.28517B-100000@as200.spellcast.com>
References: <199802232317.XAA06136@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.95.980223184015.28517B-100000@as200.spellcast.com>
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ben,

On Mon, 23 Feb 1998 19:08:59 -0500 (U), "Benjamin C.R. LaHaise"
<blah@kvack.org> said:

> Hello,
> On Mon, 23 Feb 1998, Stephen C. Tweedie wrote:
> ...
>> The patch below, against 2.1.88, adds a bunch of new functionality to
>> the swapper.  The main changes are:
>> 
>> * All swapping goes through the swap cache (aka. page cache) now.
> ...

> I noticed you're using just one inode for the swapper/page cache...  What
> I've been working on is a slightly different approach:  Create inodes for
> each anonymous mapping.  

It's not a different approach to the same problem --- it's a different
problem entirely!  The swapper_inode is *only* used as a root for the
page cache.  Its job is to identify pages by their swap entry, rather
than by their vma.  Its purpose is really more to do with the management
of swap pages on disk than in memory.

> The actual implementation uses one inode per mm_struct, with the
> virtual address within the process providing the offset.  This has the
> advantage of giving us an easy way to find all ptes that use an
> anonymous page.  Anonymous mappings end up looking more like shared
> mappings, which gives us some interesting possibilities - it becomes
> almost trivial to implement a MAP_SHARED on another process' address
> space.  What do you think of this approach?  

I'm not sure --- one inode per mm might have problems if we ever change
the virtual address of a physical page (and mremap() does exactly that).
However, that's not an insurmountable problem, and the remap-vma code
will probably get it right.  In fact, the more I think of it the more I
am convinced that this is a good way to go.

I am actually planning a different but very similar approach for the
final MAP_SHARED | MAP_ANONYMOUS code, which is to have one inode per
new vma for anonymous shared regions.  The primary reason for that is
for lookup, so that when we initialise a demand-zero page, we can
rapidly locate any other processes sharing this vma and update their
pte's too.

> My main goal is to reimplement the page-oriented swapping my pte-list
> patch performed, which makes the running time try_to_free_page
> drastically shorter, even predictable... (at most 1 pass over mem_map
> to find a page using the old style aging, or just one list operation
> using the inactive list approach)

Yep.  I was thinking along similar lines a while back.  Doing this will
also make it easier to unify the handling of shrink_mmap() and
try_to_free_page(), which is something we desparately need (we've
already unified the page and buffer shrinking, and I think we can unify
shm swapout too with the new swap cache code).

The changes you are proposing overlap a lot of my current patches, but
that's not a problem --- the two sets of changes doing fundamentally
orthogonal things; there's just an overlap in the middle.  The code I'm
working on right now is targetted at getting MAP_SHARED | MAP_ANONYMOUS
in place, and I reckon it's now pretty close.  

However, the new swap cache mechanism is a lot more generic than that,
and its real flexibility lies in the way its underlying mechanism works
--- the ability to do swap read-ahead and to proactively write-ahead
swap pages will allow us to do some major performance enhancements.
Your changes to the vmscan code are really concerned with policy ---
rapidly locating what to swap, where and when --- than the mechanics of
getting pages to and from disk, synchronously or asynchronously.  In
other words, I'm keen to integrate the two diffs, since I see a lot more
complimentary than overlapping progress here.

Cheers,
 Stephen.
