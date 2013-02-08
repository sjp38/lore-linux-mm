Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id C6C966B0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 18:16:30 -0500 (EST)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 8 Feb 2013 16:16:30 -0700
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 7487D19D8042
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 16:16:27 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r18NGPAo198766
	for <linux-mm@kvack.org>; Fri, 8 Feb 2013 16:16:27 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r18NGLo5023057
	for <linux-mm@kvack.org>; Fri, 8 Feb 2013 16:16:23 -0700
Message-ID: <51158742.4030803@linux.vnet.ibm.com>
Date: Fri, 08 Feb 2013 15:16:18 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] add helper for highmem checks
References: <20130208202813.62965F25@kernel.stglabs.ibm.com> <51156507.50900@zytor.com>
In-Reply-To: <51156507.50900@zytor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, bp@alien8.de, mingo@kernel.org, tglx@linutronix.de

On 02/08/2013 12:50 PM, H. Peter Anvin wrote:
> On 02/08/2013 12:28 PM, Dave Hansen wrote:
>> +static inline phys_addr_t last_lowmem_phys_addr(void)
>> +{
>> +    /*
>> +     * 'high_memory' is not a pointer that can be dereferenced, so
>> +     * avoid calling __pa() on it directly.
>> +     */
>> +    return __pa(high_memory - 1);
>> +}
>> +static inline bool phys_addr_is_highmem(phys_addr_t addr)
>> +{
>> +    return addr > last_lowmem_paddr();
>> +}
>> +
> 
> Are we sure that high_memory - 1 is always a valid reference?  Consider
> especially the case where there is MMIO beyond end of memory on a system
> which has less RAM than the HIGHMEM boundary...

Yeah, I think it is.  "high_memory" should point at either the end of
RAM, or the end of the linear map, whichever is lower.  See setup_arch():

        max_pfn = e820_end_of_ram_pfn();
	...
        high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;

or in the highmem init code:

        high_memory = (void *) __va(max_low_pfn * PAGE_SIZE - 1) + 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
