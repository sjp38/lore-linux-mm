Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA11498
	for <linux-mm@kvack.org>; Wed, 22 Apr 1998 17:29:44 -0400
Subject: Re: (reiserfs) Re: Maybe we can do 40 bits in June/July. (fwd)
References: <Pine.LNX.3.95.980422140626.9664A-100000@as200.spellcast.com>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 22 Apr 1998 16:08:28 -0500
In-Reply-To: "Benjamin C.R. LaHaise"'s message of Wed, 22 Apr 1998 14:29:18 -0400 (EDT)
Message-ID: <m1u37lo983.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "\"Benjamin C.R. LaHaise\" <blah@kvack.org>
	  linux-mm" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "BL" == Benjamin C R LaHaise <blah@kvack.org> writes:

BL> On 22 Apr 1998, Eric W. Biederman wrote:
BL> ...
>> My design:
>> As I understand it the buffer cache is fine, so it is just a matter
>> getting the page cache and the vma and the glue working.

BL> The buffer cache is currently fine, but we do want to get rid of it...

We already don't use it for reading files.  
We just need to get the writing working better.  Hopefully there can
come a merger between my write dirty pages in the page cache, and the
revamp of the current swapping code.  Resulting in good write
performance. 

Demand clearing of writes from the page cache when we need the page
works but it would be better to write the page first.

We probably also need a filesystem sync system call...

>> My thought is to make the page cache use generic keys. 
>> This should help support things like the swapper inode a little
>> better.  Still need a bit somewhere so we can coallese VMA's that have
>> an inode but don't need continous keys.  That's for later.

BL> Hmmm, if you've seen my rev_pte patch then you'll notice that *all* vmas
BL> will soon need continuous keys... 

I was recalling something about not putting an inode in private shared
mappings so the VMA's can be merged...  That would be my definition of
non-continous keys.  The keys don't have to be continous.

It would also be worth checking on your patch to see what happens when
someone calls mremap on a private shared area.  I think you may have
key assignment problems...

This is from memory so I may be a little off.  I think I also read an
older patch so I may be mixing my memories.

>> For the common case of inodes have the those keys:
page-> key == page->offset >> PAGE_SHIFT.

BL> Not a good idea unless support for a.out is dropped completely -- a better
BL> choice would be to use 512 as a divisor; then pages can at least be at the
BL> block offset as needed by a.out.

How is a.out read in?  Private mapping of any alignment can still 
(theoretically) be handled.  Sharing private mappings is more
complicated, we need a COW scheme (for the page cache).  Currently
generic_file_mmap is broken with regard to private mappings...

BL> Something else to keep in mind is that we also need a mechanism to keep
BL> metadata in the page cache (rather, per-inode metadata; fixed metadata can
BL> just use its own inode).

In the short run for large file support I'd like to keep the changes
as small as possible. 

In the long run I want a generic backing store object (which an inode
could be a superset of) being the backing store for the page cache.

per-inode metada...  The indirect blocks... ACL.. Got it.

Eric
