Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 113946B0022
	for <linux-mm@kvack.org>; Sun,  3 Feb 2013 18:50:53 -0500 (EST)
Date: Mon, 4 Feb 2013 08:50:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: Fix TLB coherency and build problem
Message-ID: <20130203235052.GB2688@blaptop>
References: <1359334808-19794-1-git-send-email-minchan@kernel.org>
 <20130201140218.GN23505@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130201140218.GN23505@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Matt Sealey <matt@genesi-usa.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>

On Fri, Feb 01, 2013 at 02:02:18PM +0000, Russell King - ARM Linux wrote:
> On Mon, Jan 28, 2013 at 10:00:08AM +0900, Minchan Kim wrote:
> > @@ -663,7 +661,7 @@ static inline void __zs_unmap_object(struct mapping_area *area,
> >  
> >  	flush_cache_vunmap(addr, end);
> >  	unmap_kernel_range_noflush(addr, PAGE_SIZE * 2);
> > -	local_flush_tlb_kernel_range(addr, end);
> > +	flush_tlb_kernel_range(addr, end);
> 
> void unmap_kernel_range_noflush(unsigned long addr, unsigned long size)
> {
>         vunmap_page_range(addr, addr + size);
> }
> 
> void unmap_kernel_range(unsigned long addr, unsigned long size)
> {
>         unsigned long end = addr + size;
> 
>         flush_cache_vunmap(addr, end);
>         vunmap_page_range(addr, end);
>         flush_tlb_kernel_range(addr, end);
> }
> 
> So, given the above, what would be different between:
> 
> 	unsigned long end = addr + (PAGE_SIZE * 2);
> 
> 	flush_cache_vunmap(addr, end);
> 	unmap_kernel_range_noflush(addr, PAGE_SIZE * 2);
> 	flush_tlb_kernel_range(addr, end);
> 
> (which is what it becomes after your change) and
> 
> 	unmap_kernel_range(addr, PAGE_SIZE * 2);
> 
> ?

Good point. I will clean it up.
Thanks.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
