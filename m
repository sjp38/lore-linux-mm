Received: from funky.monkey.org (smtp@funky.monkey.org [152.160.231.196])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA14130
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 11:38:55 -0400
Date: Tue, 6 Apr 1999 11:38:52 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <14090.5138.562574.858572@dukat.scot.redhat.com>
Message-ID: <Pine.BSF.4.03.9904061133580.8679-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Apr 1999, Stephen C. Tweedie wrote:
> On Mon, 5 Apr 1999 17:31:43 -0400 (EDT), Chuck Lever <cel@monkey.org>
> said:
> 
> > hmmm.  wouldn't you think that hashing with the low order bits in the
> > offset would cause two different offsets against the same page to result
> > in the hash function generating different output?  
> 
> We always, always use page-aligned lookups for the page cache.
> (Actually there is one exception: certain obsolete a.out binaries, which
> are demand paged with the pages beginning at offset 1K into the binary.
> We don't support cache coherency for those and we don't support them at
> all on filesystems with a >1k block size.  It doesn't impact on the hash
> issue.)

i guess i'm confused then.  what good does this change do:

2.2.5 pagemap.h:
#define i (((unsigned long) inode)/(sizeof(struct inode) &
~ (sizeof(struct inode) - 1)))
#define o (offset >> PAGE_SHIFT)
#define s(x) ((x)+((x)>>PAGE_HASH_BITS))
	return s(i+o) & (PAGE_HASH_SIZE-1);

2.2.5-arca pagemap.h:
	return s(i+o+offset) & (PAGE_HASH_SIZE-1);
                    ^^^^^^^

btw, do you know if there is a special reason why PAGE_HASH_BITS is 11?

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/citi-netscape/

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
