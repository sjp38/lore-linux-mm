Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 30DD76B0006
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 08:38:41 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id r6so2214448pfk.9
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 05:38:41 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u14si1226581pgo.695.2018.02.08.05.38.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Feb 2018 05:38:39 -0800 (PST)
Date: Thu, 8 Feb 2018 05:38:35 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [LSF/MM TOPIC] lru_lock scalability
Message-ID: <20180208133835.GB15846@bombadil.infradead.org>
References: <2a16be43-0757-d342-abfb-d4d043922da9@oracle.com>
 <20180201094431.GA20742@bombadil.infradead.org>
 <af831ebd-6acf-1f83-c531-39895ab2eddb@oracle.com>
 <20180202170003.GA16840@bombadil.infradead.org>
 <20180206153359.GA31089@bombadil.infradead.org>
 <d33748d8-6bba-638d-46b6-5c074821d516@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d33748d8-6bba-638d-46b6-5c074821d516@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, steven.sistare@oracle.com, pasha.tatashin@oracle.com, yossi.lev@oracle.com, Dave.Dice@oracle.com, akpm@linux-foundation.org, mhocko@kernel.org, ldufour@linux.vnet.ibm.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ak@linux.intel.com, mgorman@suse.de, Peter Zijlstra <peterz@infradead.org>

On Thu, Feb 08, 2018 at 08:33:56AM -0500, Daniel Jordan wrote:
> On 02/06/2018 10:33 AM, Matthew Wilcox wrote:
> > static inline void xas_maybe_lock_irq(struct xa_state *xas, void *entry)
> > {
> > 	if (entry) {
> > 		rcu_read_lock();
> > 		xas_start(&xas);
> > 		if (!xas_bounds(&xas))
> > 			return;
> > 	}
> 
> Trying to understand what's going on here.
> 
> xas_bounds isn't in your latest two XArray branches (xarray-4.16 or
> xarray-2018-01-09).  Isn't it checking whether 'entry' falls inside the
> currently allocated range of the XArray?  So that it should tell us whether
> a new xa_node needs to be allocated for 'entry'?
> 
> If that's true, I guess it should take 'entry' as well as '&xas'.

Oh, sorry about that.  xas_bounds() doesn't exist yet ... it would simply be:

static inline bool xas_bounds(struct xa_state *xas)
{
	return xas.xa_node == XAS_BOUNDS;
}

xas_start() sets xas.xa_node to XAS_BOUNDS if xas.xa_index falls outside
the range representable by the current top of the tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
