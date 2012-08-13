Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id CED546B002B
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 11:51:45 -0400 (EDT)
Date: Mon, 13 Aug 2012 11:41:44 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH] netvm: check for page == NULL when
 propogating the skb->pfmemalloc flag
Message-ID: <20120813154144.GA24868@phenom.dumpdata.com>
References: <20120807085554.GF29814@suse.de>
 <20120808.155046.820543563969484712.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120808.155046.820543563969484712.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, Ian Campbell <Ian.Campbell@eu.citrix.com>
Cc: mgorman@suse.de, xen-devel@lists.xensource.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, konrad@darnok.org, akpm@linux-foundation.org

On Wed, Aug 08, 2012 at 03:50:46PM -0700, David Miller wrote:
> From: Mel Gorman <mgorman@suse.de>
> Date: Tue, 7 Aug 2012 09:55:55 +0100
> 
> > Commit [c48a11c7: netvm: propagate page->pfmemalloc to skb] is responsible
> > for the following bug triggered by a xen network driver
>  ...
> > The problem is that the xenfront driver is passing a NULL page to
> > __skb_fill_page_desc() which was unexpected. This patch checks that
> > there is a page before dereferencing.
> > 
> > Reported-and-Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> That call to __skb_fill_page_desc() in xen-netfront.c looks completely bogus.
> It's the only driver passing NULL here.

It looks to be passing a valid page pointer (at least by looking
at the code) so I am not sure how it got turned in a NULL.

But let me double-check by instrumenting the driver..
> 
> That whole song and dance figuring out what to do with the head
> fragment page, depending upon whether the length is greater than the
> RX_COPY_THRESHOLD, is completely unnecessary.
> 
> Just use something like a call to __pskb_pull_tail(skb, len) and all
> that other crap around that area can simply be deleted.

It looks like an overkill - it does a lot more than just allocate an SKB
and a page.

Deleting of extra code would be nice - however I am not going to be able
to do that for the next two weeks sadly - as my plate if full of debugging
some other stuff.

Lets see if Ian has some time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
