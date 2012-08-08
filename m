Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 611826B0068
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 18:50:48 -0400 (EDT)
Date: Wed, 08 Aug 2012 15:50:46 -0700 (PDT)
Message-Id: <20120808.155046.820543563969484712.davem@davemloft.net>
Subject: Re: [PATCH] netvm: check for page == NULL when propogating the
 skb->pfmemalloc flag
From: David Miller <davem@davemloft.net>
In-Reply-To: <20120807085554.GF29814@suse.de>
References: <20120807085554.GF29814@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, xen-devel@lists.xensource.com, konrad@darnok.org, Ian.Campbell@eu.citrix.com, akpm@linux-foundation.org

From: Mel Gorman <mgorman@suse.de>
Date: Tue, 7 Aug 2012 09:55:55 +0100

> Commit [c48a11c7: netvm: propagate page->pfmemalloc to skb] is responsible
> for the following bug triggered by a xen network driver
 ...
> The problem is that the xenfront driver is passing a NULL page to
> __skb_fill_page_desc() which was unexpected. This patch checks that
> there is a page before dereferencing.
> 
> Reported-and-Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

That call to __skb_fill_page_desc() in xen-netfront.c looks completely bogus.
It's the only driver passing NULL here.

That whole song and dance figuring out what to do with the head
fragment page, depending upon whether the length is greater than the
RX_COPY_THRESHOLD, is completely unnecessary.

Just use something like a call to __pskb_pull_tail(skb, len) and all
that other crap around that area can simply be deleted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
