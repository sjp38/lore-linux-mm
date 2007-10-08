From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH -mm -v4 1/3] i386/x86_64 boot: setup data
Date: Tue, 9 Oct 2007 01:25:26 +1000
References: <1191912010.9719.18.camel@caritas-dev.intel.com>
In-Reply-To: <1191912010.9719.18.camel@caritas-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710090125.27263.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org
Cc: "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@suse.de>, "Eric W. Biederman" <ebiederm@xmission.com>, akpm@linux-foundation.org, Yinghai Lu <yhlu.kernel@gmail.com>, Chandramouli Narayanan <mouli@linux.intel.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 09 October 2007 16:40, Huang, Ying wrote:

> +unsigned long copy_from_phys(void *to, unsigned long from_phys,
> +			     unsigned long n)
> +{
> +	struct page *page;
> +	void *from;
> +	unsigned long remain = n, offset, trunck;
> +
> +	while (remain) {
> +		page = pfn_to_page(from_phys >> PAGE_SHIFT);
> +		from = kmap_atomic(page, KM_USER0);
> +		offset = from_phys & ~PAGE_MASK;
> +		if (remain > PAGE_SIZE - offset)
> +			trunck = PAGE_SIZE - offset;
> +		else
> +			trunck = remain;
> +		memcpy(to, from + offset, trunck);
> +		kunmap_atomic(from, KM_USER0);
> +		to += trunck;
> +		from_phys += trunck;
> +		remain -= trunck;
> +	}
> +	return n;
> +}


I suppose that's not unreasonable to put in mm/memory.c, although
it's not really considered a problem to do this kind of stuff in
a low level arch file...

You have no kernel virtual mapping for the source data?

Should it be __init?

Care to add a line of documentation if you keep it in mm/memory.c?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
