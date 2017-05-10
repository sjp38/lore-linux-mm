Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4F18A6B02F4
	for <linux-mm@kvack.org>; Wed, 10 May 2017 14:00:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 191so2139863pfb.8
        for <linux-mm@kvack.org>; Wed, 10 May 2017 11:00:33 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id y184si3674650pfy.166.2017.05.10.11.00.30
        for <linux-mm@kvack.org>;
        Wed, 10 May 2017 11:00:30 -0700 (PDT)
Date: Wed, 10 May 2017 14:00:26 -0400 (EDT)
Message-Id: <20170510.140026.1367439672848112283.davem@davemloft.net>
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
From: David Miller <davem@davemloft.net>
In-Reply-To: <20170510171703.GC1590@bombadil.infradead.org>
References: <20170510145726.GM31466@dhcp22.suse.cz>
	<20170510.111943.1940354761418085760.davem@davemloft.net>
	<20170510171703.GC1590@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org
Cc: mhocko@kernel.org, pasha.tatashin@oracle.com, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com

From: Matthew Wilcox <willy@infradead.org>
Date: Wed, 10 May 2017 10:17:03 -0700

> On Wed, May 10, 2017 at 11:19:43AM -0400, David Miller wrote:
>> From: Michal Hocko <mhocko@kernel.org>
>> Date: Wed, 10 May 2017 16:57:26 +0200
>> 
>> > Have you measured that? I do not think it would be super hard to
>> > measure. I would be quite surprised if this added much if anything at
>> > all as the whole struct page should be in the cache line already. We do
>> > set reference count and other struct members. Almost nobody should be
>> > looking at our page at this time and stealing the cache line. On the
>> > other hand a large memcpy will basically wipe everything away from the
>> > cpu cache. Or am I missing something?
>> 
>> I guess it might be clearer if you understand what the block
>> initializing stores do on sparc64.  There are no memory accesses at
>> all.
>> 
>> The cpu just zeros out the cache line, that's it.
>> 
>> No L3 cache line is allocated.  So this "wipe everything" behavior
>> will not happen in the L3.
> 
> There's either something wrong with your explanation or my reading
> skills :-)
> 
> "There are no memory accesses"
> "No L3 cache line is allocated"
> 
> You can have one or the other ... either the CPU sends a cacheline-sized
> write of zeroes to memory without allocating an L3 cache line (maybe
> using the store buffer?), or the CPU allocates an L3 cache line and sets
> its contents to zeroes, probably putting it in the last way of the set
> so it's the first thing to be evicted if not touched.

There is no conflict in what I said.

Only an L2 cache line is allocated and cleared.  L3 is left alone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
