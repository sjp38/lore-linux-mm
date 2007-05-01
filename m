Date: Mon, 30 Apr 2007 17:38:06 -0700 (PDT)
Message-Id: <20070430.173806.112621225.davem@davemloft.net>
Subject: Re: vm changes from linux-2.6.14 to linux-2.6.15
From: David Miller <davem@davemloft.net>
In-Reply-To: <1177977619.24962.6.camel@localhost.localdomain>
References: <20070430145414.88fda272.akpm@linux-foundation.org>
	<20070430.150407.07642146.davem@davemloft.net>
	<1177977619.24962.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 01 May 2007 10:00:19 +1000
Return-Path: <owner-linux-mm@kvack.org>
To: benh@kernel.crashing.org
Cc: akpm@linux-foundation.org, mark@mtfhpc.demon.co.uk, linuxppc-dev@ozlabs.org, wli@holomorphy.com, linux-mm@kvack.org, andrea@suse.de, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> 
> > > Interesting - thanks for working that out.  Let's keep linux-mm on cc please.
> > 
> > You can't elide the update_mmu_cache() call on sun4c because that will
> > miss some critical TLB setups which are performed there.
> > 
> > The sun4c TLB has two tiers of entries:
> > 
> > 1) segment maps, these hold ptes for a range of addresses
> > 2) ptes, mapped into segment maps
> > 
> > update_mmu_cache() on sun4c take care of allocating and setting
> > up the segment maps, so if you elide the call this never happens
> > and we fault forever.
> 
> Maybe we can move that logic to ptep_set_access_flags()... in fact, the
> tlb flush logic should be done there too imho.
>
> There would still be the update_mmu_cache() that we don't want on
> powerpc in all cases I suppose. That can be done by having
> ptep_set_access_flags() return a boolean indicating wether
> update_mmu_cache() shall be called or not ...

Always doing ptep_set_access_flags() and returning a boolean like
that might be a good idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
