Date: Mon, 19 Apr 2004 15:23:55 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: numa api comments
Message-ID: <295360000.1082413435@flay>
In-Reply-To: <20040419195447.GA5900@lst.de>
References: <20040419195447.GA5900@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>, ak@suse.de
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>  - the
> 
> 	if (unlikely(order >= MAX_ORDER))
> 	       return NULL;
> 
>    in alloc_pages_node and your new alloc_pages should probably move
>    into __alloc_pages, thus making alloc_pages_current as an entinity
>    of it's own superflous.  It's naming is rather strange anyway.

This comes up again and again, it probably needs a big fat comment to 
explain itself (I know I've asked the same before at least once ;-)). 
The alloc_pages wrapper bit is inlined, as order is normally a constant,
and thus that check will compile away 99% of the time. If we move it
into the main __alloc_pages function, it'll be another check in the
fastpath that we don't need most of the time.

>  - can we please have a for_each_node() instead of mess like
> 
> 	for (nd = find_first_bit(nodes, MAX_NUMNODES);
>              nd < MAX_NUMNODES;
>              nd = find_next_bit(nodes, MAX_NUMNODES, 1+nd)) {

I'd swear we had one of those already to iterate over 1 .. numnodes,
but I can't find it. Grrr.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
