Date: Sat, 8 Jan 2005 13:56:36 -0800
From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Prezeroing V3 [1/4]: Allow request for zeroed memory
Message-Id: <20050108135636.6796419a.davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
References: <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
	<Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: clameter@sgi.com, akpm@osdl.org, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 8 Jan 2005 21:12:10 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> Christoph, a late comment: doesn't this effectively replace
> do_anonymous_page's clear_user_highpage by clear_highpage, which would
> be a bad idea (inefficient? or corrupting?) on those few architectures
> which actually do something with that user addr?

Good catch, it probably does.  We really do need to use
the page clearing routines that pass in the user virtual
address when preparing new anonymous pages or else we'll
get cache aliasing problems on sparc, sparc64, and mips
at the very least.  That is what the virtual address argument
was added for to begin with.

The other way to deal with this is to make whatever routine
the kscrubd thing invokes do all the cache flushing et al.
magic so that the above works when taking pages from the
pre-zero'd pool (only, if no pre-zero'd pages are available
we sill need to invoke clear_user_highpage() with the proper
virtual address).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
