Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 180906B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 12:53:44 -0500 (EST)
Received: by qcsd16 with SMTP id d16so560218qcs.14
        for <linux-mm@kvack.org>; Wed, 08 Feb 2012 09:53:43 -0800 (PST)
Message-ID: <4F32B6A4.8030702@vflare.org>
Date: Wed, 08 Feb 2012 12:53:40 -0500
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] staging: zsmalloc: zsmalloc memory allocation library
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com> <1326149520-31720-2-git-send-email-sjenning@linux.vnet.ibm.com> <4F21A5AF.6010605@linux.vnet.ibm.com> <4F300D41.5050105@linux.vnet.ibm.com> <4F32A55E.8010401@linux.vnet.ibm.com>
In-Reply-To: <4F32A55E.8010401@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>, Dan Magenheimer <dan.magenheimer@oracle.com>, Brian King <brking@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 02/08/2012 11:39 AM, Dave Hansen wrote:

> On 02/06/2012 09:26 AM, Seth Jennings wrote:
>> On 01/26/2012 01:12 PM, Dave Hansen wrote:
>>> void *kmap_atomic_prot(struct page *page, pgprot_t prot)
>>> {
>>> ...
>>>         type = kmap_atomic_idx_push();
>>>         idx = type + KM_TYPE_NR*smp_processor_id();
>>>         vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
>>>
>>> I think if you do a get_cpu()/put_cpu() or just a preempt_disable()
>>> across the operations you'll be guaranteed to get two contiguous addresses.
>>
>> I'm not quite following here.  kmap_atomic() only does this for highmem pages.
>> For normal pages (all pages for 64-bit), it doesn't do any mapping at all.  It
>> just returns the virtual address of the page since it is in the kernel's address
>> space.
>>
>> For this design, the pages _must_ be mapped, even if the pages are directly
>> reachable in the address space, because they must be virtually contiguous.
> 
> I guess you could use vmap() for that.  It's just going to be slower
> than kmap_atomic().  I'm really not sure it's worth all the trouble to
> avoid order-1 allocations, though.
> 


vmap() is not just slower but also does memory allocations at various
places. Under memory pressure, this may cause failure in reading a
stored object just because we failed to map it. Also, it allocates VA
region each time its called which is a real big waste when we can simply
pre-allocate 2 * PAGE_SIZE'ed VA regions (per-cpu).

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
