Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 0E4456B0062
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 06:48:05 -0400 (EDT)
Date: Mon, 13 Aug 2012 11:47:45 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] netvm: check for page == NULL when propogating the
 skb->pfmemalloc flag
Message-ID: <20120813104745.GE4177@suse.de>
References: <20120807085554.GF29814@suse.de>
 <20120808.155046.820543563969484712.davem@davemloft.net>
 <20120813102604.GC4177@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120813102604.GC4177@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, xen-devel@lists.xensource.com, konrad@darnok.org, Ian.Campbell@eu.citrix.com, David Miller <davem@davemloft.net>, akpm@linux-foundation.org

Resending to correct Jeremy's address.

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
> 
> That whole song and dance figuring out what to do with the head
> fragment page, depending upon whether the length is greater than the
> RX_COPY_THRESHOLD, is completely unnecessary.
> 
> Just use something like a call to __pskb_pull_tail(skb, len) and all
> that other crap around that area can simply be deleted.

I looked at this for a while but I did not see how __pskb_pull_tail()
could be used sensibly but I'm simily not familiar with writing network
device drivers or Xen.

This messing with RX_COPY_THRESHOLD seems to be related to how the frontend
and backend communicate (maybe some fixed limitation of the xenbus). The
existing code looks like it is trying to take the fragments received and
pass them straight to the backend without copying by passing the fragments
to the backend without copying. I worry that if I try converting this to
__pskb_pull_tail() that it would either hit the limitation of xenbus or
introduce copying where it is not wanted.

I'm going to have to punt this to Jeremy and the other Xen folk as I'm not
sure what the original intention was and I don't have a Xen setup anywhere
to test any patch. Jeremy, xen folk? 


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
