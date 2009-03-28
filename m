Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E046D6B003D
	for <linux-mm@kvack.org>; Sat, 28 Mar 2009 01:01:12 -0400 (EDT)
Message-ID: <49CDAF17.5060207@goop.org>
Date: Fri, 27 Mar 2009 22:01:11 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] x86/mm: maintain a percpu "in get_user_pages_fast"
 flag
References: <49CD37B8.4070109@goop.org> <49CD9E25.2090407@redhat.com>
In-Reply-To: <49CD9E25.2090407@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

Avi Kivity wrote:
> Jeremy Fitzhardinge wrote:
>> get_user_pages_fast() relies on cross-cpu tlb flushes being a barrier
>> between clearing and setting a pte, and before freeing a pagetable page.
>> It usually does this by disabling interrupts to hold off IPIs, but
>> some tlb flush implementations don't use IPIs for tlb flushes, and
>> must use another mechanism.
>>
>> In this change, add in_gup_cpumask, which is a cpumask of cpus currently
>> performing a get_user_pages_fast traversal of a pagetable.  A cross-cpu
>> tlb flush function can use this to determine whether it should hold-off
>> on the flush until the gup_fast has finished.
>>
>> @@ -255,6 +260,10 @@ int get_user_pages_fast(unsigned long start, int 
>> nr_pages, int write,
>>      * address down to the the page and take a ref on it.
>>      */
>>     local_irq_disable();
>> +
>> +    cpu = smp_processor_id();
>> +    cpumask_set_cpu(cpu, in_gup_cpumask);
>> +
>
> This will bounce a cacheline, every time.  Please wrap in CONFIG_XEN 
> and skip at runtime if Xen is not enabled.

Every time?  Only when running successive gup_fasts on different cpus, 
and only twice per gup_fast. (What's the typical page count?  I see that 
kvm and lguest are page-at-a-time users, but presumably direct IO has 
larger batches.)

Alternatively, it could have per-cpu flags and the other side could 
construct the mask (I originally had that, but this was simpler).

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
