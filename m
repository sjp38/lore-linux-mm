Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 570726B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 16:32:47 -0400 (EDT)
Received: by mail-yk0-f174.google.com with SMTP id 9so8804129ykp.5
        for <linux-mm@kvack.org>; Wed, 28 May 2014 13:32:47 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id m5si33648429yha.135.2014.05.28.13.32.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 28 May 2014 13:32:46 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nfont@linux.vnet.ibm.com>;
	Wed, 28 May 2014 14:32:45 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 717B23E4003B
	for <linux-mm@kvack.org>; Wed, 28 May 2014 14:32:43 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.ahe.boulder.ibm.com [9.17.195.167])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4SITNtg10748274
	for <linux-mm@kvack.org>; Wed, 28 May 2014 20:29:23 +0200
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4SKWgMR003635
	for <linux-mm@kvack.org>; Wed, 28 May 2014 14:32:43 -0600
Message-ID: <538647E9.9020408@linux.vnet.ibm.com>
Date: Wed, 28 May 2014 15:32:41 -0500
From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: memory hot-add: the kernel can notify udev daemon before creating
 the sys file state?
References: <CAJm7N84L7fVJ5x_zPbcYhWm1KMtz3dGA=G9EW=XwBbSKMwxPnw@mail.gmail.com> <CAJm7N87bRrP6cFhQaEp9kj2rNJhAKvLAFioh5VBx2jjDGn1DWw@mail.gmail.com> <CAJm7N85kM7h_=ovhxutbh_rR1tukDSKcfjFA4zPWKuVtqUH0eg@mail.gmail.com>
In-Reply-To: <CAJm7N85kM7h_=ovhxutbh_rR1tukDSKcfjFA4zPWKuVtqUH0eg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: DX Cui <rijcos@gmail.com>, linux-mm@kvack.org
Cc: Matt Tolentino <matthew.e.tolentino@intel.com>, Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 05/25/2014 10:41 AM, DX Cui wrote:
> On Fri, May 23, 2014 at 8:27 PM, DX Cui <rijcos@gmail.com> wrote:
>> Hi all,
>> I think I found out the root cause: when memory hotplug was introduced in 2005:
>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=3947be1969a9ce455ec30f60ef51efb10e4323d1
>> there was a race condition in:
>>
>> + static int add_memory_block(unsigned long node_id, struct
>> mem_section *section,
>> + unsigned long state, int phys_device)
>> +{
>> ...
>> + ret = register_memory(mem, section, NULL);
>> + if (!ret)
>> +        ret = mem_create_simple_file(mem, phys_index);
>> + if (!ret)
>> +        ret = mem_create_simple_file(mem, state);
>>
>> Here, first, add_memory_block() invokes register_memory() ->
>> sysdev_register() -> sysdev_add()->
>> kobject_uevent(&sysdev->kobj, KOBJ_ADD) to notify udev daemon, then
>> invokes mem_create_simple_file(). If the current execution is preempted
>> between the 2 steps, the issue I reported in the previous mail can happen.
>>
>> Luckily a commit in 2013 has fixed this issue undesignedly:
>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=96b2c0fc8e74a615888e2bedfe55b439aa4695e1
>>
>> It looks the new "register_memory() --> ... -> device_add()" path has the
>> correct order for sysfs creation and notification udev.
>>

Correct. that patch does fix this issue, though that was not the primary reason
for doing the patch. Always nice when a patch has unintended positive side affects.
 
>> It would be great if you can confirm my analysis. :-)
> 
> Any comments?
> I think we need to backport the patch
> 96b2c0fc8e74a615888e2bedfe55b439aa4695e1 to <=3.9 stable kernels.
> 

Although I have seen any issues because of this issue I agree that the fix
should be backported. Best to get rid of a known race condition before it
jumps up and bites us.

-Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
