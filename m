Received: from funky.monkey.org (smtp@funky.monkey.org [152.160.231.196])
	by kvack.org (8.8.7/8.8.7) with ESMTP id XAA16369
	for <linux-mm@kvack.org>; Sat, 24 Apr 1999 23:22:56 -0400
Date: Sat, 24 Apr 1999 23:22:32 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <14091.20289.68799.79898@dukat.scot.redhat.com>
Message-ID: <Pine.BSF.4.03.9904242317090.21947-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Apr 1999, Stephen C. Tweedie wrote:
> On Wed, 7 Apr 1999 00:27:21 +0200 (CEST), Andrea Arcangeli
> <andrea@e-mind.com> said:
> 
> > It's not so obvious to me. I sure agree that an O(n) insertion/deletion is
> > far too slow but a O(log(n)) for everything could be rasonable to me. And
> > trees don't worry about unluky hash behavior.
> 
> Trees are O(log n) for insert/delete, with a high constant of
> proportionality (ie. there can be quite a lot of work to be done even
> for small log n).  Trees also occupy more memory per node.  Hashes are
> O(1) for insert and delete, and are a _fast_ O(1).  The page cache needs
> fast insert and delete.

i had a few minutes the other day, so i extracted just the rb-tree part of
2.2.5-arca10, and benchmarked it against 2.2.5 and against the hash tuning
patch i'm working on.  i ran this on our 512M 4-way Dell PowerEdge 6300.

ref - 2.2.5 kernel with 4000 process slots and b_state fix

rbt - 2.2.5 kernel with 4000 process slots and rbtree patch applied
        (b_state fix *not* applied)
hash - 2.2.5 kernel with an older version of my hash tuning patch applied
        (b_state fix applied)

160 concurrent scripts.  all of the benchmark fits in memory.

ref:  3725.8 s=15.23
rbt:  3893.3 s=9.82
hash: 4007.3 s=15.95

"hash" tunes the page cache, the buffer cache, the dentry cache, and the
inode cache.  "rbt" just replaces the page cache with per-inode rbtrees.
i think the rbtree patch compares pretty favorably for very large memory
machines.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
