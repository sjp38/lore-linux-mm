Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A5BEC6B003D
	for <linux-mm@kvack.org>; Sat, 28 Mar 2009 05:53:51 -0400 (EDT)
Message-ID: <49CDF3CB.8070000@redhat.com>
Date: Sat, 28 Mar 2009 12:54:19 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] x86/mm: maintain a percpu "in get_user_pages_fast"
 flag
References: <49CD37B8.4070109@goop.org> <49CD9E25.2090407@redhat.com> <49CDAF17.5060207@goop.org>
In-Reply-To: <49CDAF17.5060207@goop.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge wrote:
>>> @@ -255,6 +260,10 @@ int get_user_pages_fast(unsigned long start, 
>>> int nr_pages, int write,
>>>      * address down to the the page and take a ref on it.
>>>      */
>>>     local_irq_disable();
>>> +
>>> +    cpu = smp_processor_id();
>>> +    cpumask_set_cpu(cpu, in_gup_cpumask);
>>> +
>>
>> This will bounce a cacheline, every time.  Please wrap in CONFIG_XEN 
>> and skip at runtime if Xen is not enabled.
>
> Every time?  Only when running successive gup_fasts on different cpus, 
> and only twice per gup_fast. (What's the typical page count?  I see 
> that kvm and lguest are page-at-a-time users, but presumably direct IO 
> has larger batches.)

Databases will often issue I/Os of 1 or 2 pages.  But not regressing kvm 
should be sufficient motivation.


-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
