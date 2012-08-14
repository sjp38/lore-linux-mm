Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 58E636B002B
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 09:38:04 -0400 (EDT)
Date: Tue, 14 Aug 2012 09:28:03 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH] netvm: check for page == NULL when
 propogating the skb->pfmemalloc flag
Message-ID: <20120814132803.GC10880@phenom.dumpdata.com>
References: <20120807085554.GF29814@suse.de>
 <20120808.155046.820543563969484712.davem@davemloft.net>
 <20120813154144.GA24868@phenom.dumpdata.com>
 <20120814100522.GL4177@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120814100522.GL4177@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Miller <davem@davemloft.net>, Ian Campbell <Ian.Campbell@eu.citrix.com>, xen-devel@lists.xensource.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, konrad@darnok.org, akpm@linux-foundation.org

On Tue, Aug 14, 2012 at 11:05:22AM +0100, Mel Gorman wrote:
> On Mon, Aug 13, 2012 at 11:41:44AM -0400, Konrad Rzeszutek Wilk wrote:
> > On Wed, Aug 08, 2012 at 03:50:46PM -0700, David Miller wrote:
> > > From: Mel Gorman <mgorman@suse.de>
> > > Date: Tue, 7 Aug 2012 09:55:55 +0100
> > > 
> > > > Commit [c48a11c7: netvm: propagate page->pfmemalloc to skb] is responsible
> > > > for the following bug triggered by a xen network driver
> > >  ...
> > > > The problem is that the xenfront driver is passing a NULL page to
> > > > __skb_fill_page_desc() which was unexpected. This patch checks that
> > > > there is a page before dereferencing.
> > > > 
> > > > Reported-and-Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > > 
> > > That call to __skb_fill_page_desc() in xen-netfront.c looks completely bogus.
> > > It's the only driver passing NULL here.
> > 
> > It looks to be passing a valid page pointer (at least by looking
> > at the code) so I am not sure how it got turned in a NULL.
> > 
> 
> Are we looking at different code bases? I see this and I was assuming it
> was the source of the bug.
> 
> 	__skb_fill_page_desc(skb, 0, NULL, 0, 0);

Yes! Well, that is embarrassing. I was looking at the first invocation of 
__skb_fill_page_desc (which is in xennet_alloc_rx_buffers) <sigh>

> 
> -- 
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
