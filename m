Date: Fri, 2 Apr 2004 22:35:14 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040402203514.GR21341@dualathlon.random>
References: <20040402001535.GG18585@dualathlon.random> <Pine.LNX.4.44.0404020145490.2423-100000@localhost.localdomain> <20040402011627.GK18585@dualathlon.random> <20040401173649.22f734cd.akpm@osdl.org> <20040402020022.GN18585@dualathlon.random> <20040402104334.A871@infradead.org> <20040402164634.GF21341@dualathlon.random> <20040402195927.A6659@infradead.org> <20040402192941.GP21341@dualathlon.random> <20040402205410.A7194@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040402205410.A7194@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@osdl.org>, hugh@veritas.com, vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 02, 2004 at 08:54:10PM +0100, Christoph Hellwig wrote:
> On Fri, Apr 02, 2004 at 09:29:41PM +0200, Andrea Arcangeli wrote:
> > page->private indicates:
> > 
> > >>> (0xc0772380L-0xc07721ffL)/32
> > 12L
> > 
> > that's the 12th page in the array.
> > 
> > can you check in the asm (you should look at address c0048c7c) if it's
> > the first bug that triggers?
> > 
> > 	if (page[1].index != order)
> > 		bad_page(__FUNCTION__, page);
> 
> No, it's the second one (and yes, I get lots of theses backtraces, unless
> I counted wrongly 19 this time)

how can that be the second one? (I deduced it was the first one because
it cannot be the second one and the offset didn't look at the very end
of the function). This is the second one:

		if (!PageCompound(p))
			bad_page(__FUNCTION__, p);

but bad_page shows p->flags == 0x00080008 and 1<<PG_compound ==
0x80000.

So PG_compound is definitely set for "p" and it can't be the second one
triggering.

Can you double check? Maybe we should double check the asm. Something
sounds fundamentally wrong in the asm, sounds like a miscompilation,
which compiler are you using?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
