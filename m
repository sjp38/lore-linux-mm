Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA00896
	for <linux-mm@kvack.org>; Sun, 7 Feb 1999 17:46:20 -0500
Date: Mon, 8 Feb 1999 17:51:36 GMT
Message-Id: <199902081751.RAA03584@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] Re: swapcache bug?
In-Reply-To: <Pine.LNX.3.95.990208092701.31153B-100000@penguin.transmeta.com>
References: <199902081639.QAA03290@dax.scot.redhat.com>
	<Pine.LNX.3.95.990208092701.31153B-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, masp0008@stud.uni-sb.de, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 8 Feb 1999 09:32:24 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> It _may_ be that the hash function is always called with a page-aligned
> offset, but that was not how it was strictly meant to be: the way the
> thing was envisioned you could just find the page at "offset" by doing

> 	page_hash(inode,offset)

It does appear to be: we enforce it pretty much everywhere I can see,
with one possible exception: filemap_nopage(), which assumes
area->vm_offset is already page-aligned.  I think we can still violate
that internally if we are mapping a ZMAGIC binary (urgh), but the VM
breaks anyway if we do that: update_vm_cache cannot deal with such
pages, for a start.

The assumption that we might have flexible offsets will break
__find_page massively anyway, because we _always_ lookup the struct page
by exact match on the offset; __find_page never tries to align things
itself.

Linus, I know Matti Aarnio has been working on supporting >32bit offsets
on Intel, and for that we really do need to start using the low bits in
the page offset for something more useful than MBZ padding.  If there is
a long-term desire to keep those bits in the offset insignificant then
that will really hurt his work; otherwise, I can't see mixing in the
low-order bits to the page hash breaking anything new.

> If anything, maybe the swap cache should just use the high bits in the
> "offset" field 

Yes, we can certainly do that to fix the current has collision problems,
but since there are long term reasons for using more bits of
significance in the page cache offset, it would be good to know whether
you'd be willing to entertain that possibility.  If so, we'll need a
hash function which observes the low bits anyway.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
