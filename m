Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 39FF06B005A
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 14:49:19 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id h37so5985075iak.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 11:49:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <507DAB0F.30000@am.sony.com>
References: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com>
	<m27gqwtyu9.fsf@firstfloor.org>
	<alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com>
	<m2391ktxjj.fsf@firstfloor.org>
	<CALF0-+WLZWtwYY4taYW9D7j-abCJeY90JzcTQ2hGK64ftWsdxw@mail.gmail.com>
	<alpine.DEB.2.00.1210130252030.7462@chino.kir.corp.google.com>
	<CALF0-+Xp_P_NjZpifzDSWxz=aBzy_fwaTB3poGLEJA8yBPQb_Q@mail.gmail.com>
	<alpine.DEB.2.00.1210151745400.31712@chino.kir.corp.google.com>
	<CALF0-+WgfnNOOZwj+WLB397cgGX7YhNuoPXAK5E0DZ5v_BxxEA@mail.gmail.com>
	<1350392160.3954.986.camel@edumazet-glaptop>
	<507DA245.9050709@am.sony.com>
	<CALF0-+VLVqy_uE63_jL83qh8MqBQAE3vYLRX1mRQURZ4a1M20g@mail.gmail.com>
	<507DAB0F.30000@am.sony.com>
Date: Tue, 16 Oct 2012 15:49:18 -0300
Message-ID: <CALF0-+VfyNmnkwc97EEMjByQBTStvpoNVeEJMeQDn2fynQhHMw@mail.gmail.com>
Subject: Re: [Q] Default SLAB allocator
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Bird <tim.bird@am.sony.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "celinux-dev@lists.celinuxforum.org" <celinux-dev@lists.celinuxforum.org>

On Tue, Oct 16, 2012 at 3:44 PM, Tim Bird <tim.bird@am.sony.com> wrote:
> On 10/16/2012 11:27 AM, Ezequiel Garcia wrote:
>> On Tue, Oct 16, 2012 at 3:07 PM, Tim Bird <tim.bird@am.sony.com> wrote:
>>> On 10/16/2012 05:56 AM, Eric Dumazet wrote:
>>>> On Tue, 2012-10-16 at 09:35 -0300, Ezequiel Garcia wrote:
>>>>
>>>>> Now, returning to the fragmentation. The problem with SLAB is that
>>>>> its smaller cache available for kmalloced objects is 32 bytes;
>>>>> while SLUB allows 8, 16, 24 ...
>>>>>
>>>>> Perhaps adding smaller caches to SLAB might make sense?
>>>>> Is there any strong reason for NOT doing this?
>>>>
>>>> I would remove small kmalloc-XX caches, as sharing a cache line
>>>> is sometime dangerous for performance, because of false sharing.
>>>>
>>>> They make sense only for very small hosts.
>>>
>>> That's interesting...
>>>
>>> It would be good to measure the performance/size tradeoff here.
>>> I'm interested in very small systems, and it might be worth
>>> the tradeoff, depending on how bad the performance is.  Maybe
>>> a new config option would be useful (I can hear the groans now... :-)
>>>
>>> Ezequiel - do you have any measurements of how much memory
>>> is wasted by 32-byte kmalloc allocations for smaller objects,
>>> in the tests you've been doing?
>>
>> Yes, we have some numbers:
>>
>> http://elinux.org/Kernel_dynamic_memory_analysis#Kmalloc_objects
>>
>> Are they too informal? I can add some details...
>
>
>> They've been measured on a **very** minimal setup, almost every option
>> is stripped out, except from initramfs, sysfs, and trace.
>>
>> On this scenario, strings allocated for file names and directories
>> created by sysfs
>> are quite noticeable, being 4-16 bytes, and produce a lot of fragmentation from
>> that 32 byte cache at SLAB.
>
> The detail I'm interested in is the amount of wastage for a
> "common" workload, for each of the SLxB systems.  Are we talking a
> few K, or 10's or 100's of K?  It sounds like it's all from short strings.
> Are there other things using the 32-byte kmalloc cache, that waste
> a lot of memory (in aggregate) as well?
>

A more "Common" workload is one of the next items on my queue.


> Does your tool indicate a specific callsite (or small set of callsites)
> where these small allocations are made?  It sounds like it's in the filesystem
> and would be content-driven (by the length of filenames)?
>

That's right. And, IMHO, the problem is precisely that the allocation
size is content-driven.


    Ezequiel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
