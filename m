Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA13132
	for <linux-mm@kvack.org>; Thu, 23 Apr 1998 00:54:48 -0400
Subject: Fixing private mappings
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 23 Apr 1998 00:06:31 -0500
Message-ID: <m1ra2pnn3c.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Please excuse me for thinking out loud but private mappings seems to be
a hard problem that has not been correctly implemented in the linux
kernel.

Definition of Private Mappings:
 A private mapping is a copy-on-write mapping of a file.  

 That is if the file is written to after the mapping is established,
 the contents of the mapping will always remain what the contents of
 the file was at the time of the private mapping.

 Further if another private mapping is established after one
 private mapping has been established it should have the file contents
 of the file at the time the mapping is established.  Not at the time
 any previous private mapping was established.

A few ideas occur to me for specific problems, but the whole problem
is a challenge.

What I do know is that we need some kind of write barrier that we
check to see if we have made a copy of a page for any private mappings
that may exist before we write to it.

How should we find those private mappings?

Wait.  That would be follow inode->i_mmap whenver we read in a page.
And then have code in generic_file_write, and update_vm_cache, to make
sure the copies are made at the appropriate times.

How should we maximize sharing of private mappings?

The simplest solution would be to continue with the current solution,
and just restrict mappings 512 byte boundaries.

A slightly more generic solution would be to introduce a new ``inode''
that new it was a copy of the old inode but at a different offset.  If
these new ``inodes'' would then have a linked list of their own, that
could be followed for update purposes.  

--
Extra inodes for files could also be extended to allow an offset at
say 4TB or so into a file so that we can handle any sized file.
Though obviously you can't cache it all at once, but you could cache
any piece ;)  

There is a possibility there for per-inode metadata too but I'm not
certain about that one.

I think since my initial goal was large file support with the common
case on intel being restricted to 32bit integers, I'll play with the
extra inodes approach.

It will probably be smart to restrict ourselves to still only allowing
mappings on fs block boundaries.  There are some efficiency gained
there (on reading pages that are totally not in memory in) but
otherwise we should be fine.

Eric
