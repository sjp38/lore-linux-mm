Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id BEFB46B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 12:26:32 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 6 Feb 2012 12:26:31 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 42AD36E804D
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 12:26:29 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q16HQTGp193786
	for <linux-mm@kvack.org>; Mon, 6 Feb 2012 12:26:29 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q16HQSDF007581
	for <linux-mm@kvack.org>; Mon, 6 Feb 2012 15:26:28 -0200
Message-ID: <4F300D41.5050105@linux.vnet.ibm.com>
Date: Mon, 06 Feb 2012 11:26:25 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] staging: zsmalloc: zsmalloc memory allocation library
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com> <1326149520-31720-2-git-send-email-sjenning@linux.vnet.ibm.com> <4F21A5AF.6010605@linux.vnet.ibm.com>
In-Reply-To: <4F21A5AF.6010605@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Brian King <brking@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 01/26/2012 01:12 PM, Dave Hansen wrote:
> On 01/09/2012 02:51 PM, Seth Jennings wrote:
>> +	area = &get_cpu_var(zs_map_area);
>> +	if (off + class->size <= PAGE_SIZE) {
>> +		/* this object is contained entirely within a page */
>> +		area->vm_addr = kmap_atomic(page);
>> +	} else {
>> +		/* this object spans two pages */
>> +		struct page *nextp;
>> +
>> +		nextp = get_next_page(page);
>> +		BUG_ON(!nextp);
>> +
>> +
>> +		set_pte(area->vm_ptes[0], mk_pte(page, PAGE_KERNEL));
>> +		set_pte(area->vm_ptes[1], mk_pte(nextp, PAGE_KERNEL));
>> +
>> +		/* We pre-allocated VM area so mapping can never fail */
>> +		area->vm_addr = area->vm->addr;
>> +	}
> 
> This bit appears to be trying to make kmap_atomic() variant that can map
> two pages in to contigious virtual addresses.  Instead of open-coding it
> in a non-portable way like this, should we just make a new kmap_atomic()
> variant that does this?
> 
> From the way it's implemented, I _think_ you're guaranteed to get two
> contiguous addresses if you do two adjacent kmap_atomics() on the same CPU:
> 
> void *kmap_atomic_prot(struct page *page, pgprot_t prot)
> {
> ...
>         type = kmap_atomic_idx_push();
>         idx = type + KM_TYPE_NR*smp_processor_id();
>         vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
> 
> I think if you do a get_cpu()/put_cpu() or just a preempt_disable()
> across the operations you'll be guaranteed to get two contiguous addresses.

I'm not quite following here.  kmap_atomic() only does this for highmem pages.
For normal pages (all pages for 64-bit), it doesn't do any mapping at all.  It
just returns the virtual address of the page since it is in the kernel's address
space.

For this design, the pages _must_ be mapped, even if the pages are directly
reachable in the address space, because they must be virtually contiguous.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
