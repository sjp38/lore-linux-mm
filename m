Date: Tue, 1 Feb 2005 11:18:06 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/2] Helping prezoring with reduced fragmentation allocation
In-Reply-To: <20050201171641.CC15EE5E8@skynet.csn.ul.ie>
Message-ID: <Pine.LNX.4.58.0502011110560.3436@schroedinger.engr.sgi.com>
References: <20050201171641.CC15EE5E8@skynet.csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Feb 2005, Mel Gorman wrote:

> This is a patch that makes a step towards tieing the modified allocator
> for reducing fragmentation with the prezeroing of pages that is based
> on a discussion with Christoph. When a block has to be split to satisfy a
> zero-page, both buddies are zero'd, one is allocated and the other is placed
> on the free-list for the USERZERO pool. Care is taken to make sure the pools
> are not accidently fragmented.

Thanks for integrating the page zero stuff. If you are zeroing pages
before their are fragmented then we may not need scrubd anymore. On the
other hand, larger than necessary zeroing may be performaned in the hot
code paths which may result in sporadically longer delays during
allocation (well but then the page_allocator can generate these delays for
a number of reasons).

> I would expect that a scrubber daemon would go through the KERNNORCLM pool,
> remove pages, scrub them and move them to USERZERO. It is important that pages
> not be moved from the USERRCLM or KERNRCLM pools as it'll cause fragmentation
> problems over time.

Would it not be better to zero the global 2^MAX_ORDER pages by the scrub
daemon and have a global zeroed page list? That way you may avoid zeroing
when splitting pages?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
