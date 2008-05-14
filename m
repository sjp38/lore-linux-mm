Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4EIXGRo021393
	for <linux-mm@kvack.org>; Wed, 14 May 2008 14:33:16 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4EIXG5x149632
	for <linux-mm@kvack.org>; Wed, 14 May 2008 14:33:16 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4EIXF0G031434
	for <linux-mm@kvack.org>; Wed, 14 May 2008 14:33:16 -0400
Subject: Re: [patch 2/2]: introduce fast_gup
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
In-Reply-To: <20080422094629.GC23770@wotan.suse.de>
References: <20080328025455.GA8083@wotan.suse.de>
	 <20080328030023.GC8083@wotan.suse.de> <1208857356.7115.218.camel@twins>
	 <20080422094629.GC23770@wotan.suse.de>
Content-Type: text/plain
Date: Wed, 14 May 2008 13:33:14 -0500
Message-Id: <1210789994.6377.21.camel@norville.austin.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, axboe@kernel.dk, linux-mm@kvack.org, linux-arch@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-04-22 at 11:46 +0200, Nick Piggin wrote:
> On Tue, Apr 22, 2008 at 11:42:36AM +0200, Peter Zijlstra wrote:
> > On Fri, 2008-03-28 at 04:00 +0100, Nick Piggin wrote:
> > 
> > > +static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
> > > +		unsigned long end, int write, struct page **pages, int *nr)
> > > +{
> > > +	unsigned long mask, result;
> > > +	pte_t *ptep;
> > > +
> > > +	result = _PAGE_PRESENT|_PAGE_USER;
> > > +	if (write)
> > > +		result |= _PAGE_RW;
> > > +	mask = result | _PAGE_SPECIAL;
> > > +
> > > +	ptep = pte_offset_map(&pmd, addr);
> > > +	do {
> > > +		/*
> > > +		 * XXX: careful. On 3-level 32-bit, the pte is 64 bits, and
> > > +		 * we need to make sure we load the low word first, then the
> > > +		 * high. This means _PAGE_PRESENT should be clear if the high
> > > +		 * word was not valid. Currently, the C compiler can issue
> > > +		 * the loads in any order, and I don't know of a wrapper
> > > +		 * function that will do this properly, so it is broken on
> > > +		 * 32-bit 3-level for the moment.
> > > +		 */
> > > +		pte_t pte = *ptep;
> > > +		struct page *page;
> > > +
> > > +		if ((pte_val(pte) & mask) != result)
> > > +			return 0;
> > 
> > This return path fails to unmap the pmd.
> 
> Ah good catch. As you can see I haven't done any highmem testing ;)
> Which I will do so before sending upstream.

Which will be when?  We'd really like to see this in mainline as soon as
possible and in -mm in the meanwhile.

Thanks,
Shaggy
-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
