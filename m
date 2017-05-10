Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 412696B0038
	for <linux-mm@kvack.org>; Wed, 10 May 2017 17:11:37 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id o25so6685916pgc.1
        for <linux-mm@kvack.org>; Wed, 10 May 2017 14:11:37 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x5si118835pfk.191.2017.05.10.14.11.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 May 2017 14:11:36 -0700 (PDT)
Date: Wed, 10 May 2017 14:11:31 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
Message-ID: <20170510211131.GD1590@bombadil.infradead.org>
References: <20170510145726.GM31466@dhcp22.suse.cz>
 <20170510.111943.1940354761418085760.davem@davemloft.net>
 <20170510171703.GC1590@bombadil.infradead.org>
 <20170510.140026.1367439672848112283.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170510.140026.1367439672848112283.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: mhocko@kernel.org, pasha.tatashin@oracle.com, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com

On Wed, May 10, 2017 at 02:00:26PM -0400, David Miller wrote:
> From: Matthew Wilcox <willy@infradead.org>
> Date: Wed, 10 May 2017 10:17:03 -0700
> > On Wed, May 10, 2017 at 11:19:43AM -0400, David Miller wrote:
> >> I guess it might be clearer if you understand what the block
> >> initializing stores do on sparc64.  There are no memory accesses at
> >> all.
> >> 
> >> The cpu just zeros out the cache line, that's it.
> >> 
> >> No L3 cache line is allocated.  So this "wipe everything" behavior
> >> will not happen in the L3.
> > 
> > There's either something wrong with your explanation or my reading
> > skills :-)
> > 
> > "There are no memory accesses"
> > "No L3 cache line is allocated"
> > 
> > You can have one or the other ... either the CPU sends a cacheline-sized
> > write of zeroes to memory without allocating an L3 cache line (maybe
> > using the store buffer?), or the CPU allocates an L3 cache line and sets
> > its contents to zeroes, probably putting it in the last way of the set
> > so it's the first thing to be evicted if not touched.
> 
> There is no conflict in what I said.
> 
> Only an L2 cache line is allocated and cleared.  L3 is left alone.

I thought SPARC had inclusive caches.  So allocating an L2 cacheline
would necessitate allocating an L3 cacheline.  Or is this an exception
to the normal order of things?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
