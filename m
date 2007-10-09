Subject: Re: [PATCH -mm -v4 1/3] i386/x86_64 boot: setup data
From: "Huang, Ying" <ying.huang@intel.com>
In-Reply-To: <200710090125.27263.nickpiggin@yahoo.com.au>
References: <1191912010.9719.18.camel@caritas-dev.intel.com>
	 <200710090125.27263.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Tue, 09 Oct 2007 16:22:19 +0800
Message-Id: <1191918139.9719.47.camel@caritas-dev.intel.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@suse.de>, "Eric W. Biederman" <ebiederm@xmission.com>, akpm@linux-foundation.org, Yinghai Lu <yhlu.kernel@gmail.com>, Chandramouli Narayanan <mouli@linux.intel.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-10-09 at 01:25 +1000, Nick Piggin wrote:
> On Tuesday 09 October 2007 16:40, Huang, Ying wrote:
> 
> > +unsigned long copy_from_phys(void *to, unsigned long from_phys,
> > +			     unsigned long n)
> > +{
> > +	struct page *page;
> > +	void *from;
> > +	unsigned long remain = n, offset, trunck;
> > +
> > +	while (remain) {
> > +		page = pfn_to_page(from_phys >> PAGE_SHIFT);
> > +		from = kmap_atomic(page, KM_USER0);
> > +		offset = from_phys & ~PAGE_MASK;
> > +		if (remain > PAGE_SIZE - offset)
> > +			trunck = PAGE_SIZE - offset;
> > +		else
> > +			trunck = remain;
> > +		memcpy(to, from + offset, trunck);
> > +		kunmap_atomic(from, KM_USER0);
> > +		to += trunck;
> > +		from_phys += trunck;
> > +		remain -= trunck;
> > +	}
> > +	return n;
> > +}
> 
> 
> I suppose that's not unreasonable to put in mm/memory.c, although
> it's not really considered a problem to do this kind of stuff in
> a low level arch file...
> 
> You have no kernel virtual mapping for the source data?
> 

On 32-bit platform such as i386. Some memory zones have no kernel
virtual mapping (highmem region etc). So I think this may be useful as a
universal way to access physical memory. But it can be more efficient to
implement it in arch file for some arch. Should this implementation be
used as a fall back implementation with attribute "weak"?

> Should it be __init?
> 
> Care to add a line of documentation if you keep it in mm/memory.c?
> 

OK, I will add the document in the next version.

Best Regards,
Huang Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
