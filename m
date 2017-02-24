Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 328396B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 09:10:33 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id j30so12026872qta.2
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 06:10:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f15si4960355qtg.29.2017.02.24.06.10.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 06:10:32 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [RFC PATCH] memory-hotplug: Use dev_online for memhp_auto_offline
References: <20170221172234.8047.33382.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
	<878toy1sgd.fsf@vitty.brq.redhat.com>
	<20170223125643.GA29064@dhcp22.suse.cz>
	<87bmttyqxf.fsf@vitty.brq.redhat.com>
	<20170223150920.GB29056@dhcp22.suse.cz>
	<877f4gzz4d.fsf@vitty.brq.redhat.com>
	<20170223161241.GG29056@dhcp22.suse.cz>
	<8737f4zwx5.fsf@vitty.brq.redhat.com>
	<20170223174106.GB13822@dhcp22.suse.cz>
	<87tw7kydto.fsf@vitty.brq.redhat.com>
	<20170224133714.GH19161@dhcp22.suse.cz>
Date: Fri, 24 Feb 2017 15:10:29 +0100
In-Reply-To: <20170224133714.GH19161@dhcp22.suse.cz> (Michal Hocko's message
	of "Fri, 24 Feb 2017 14:37:14 +0100")
Message-ID: <87efyny90q.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>, linux-mm@kvack.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, mdroth@linux.vnet.ibm.com, kys@microsoft.com

Michal Hocko <mhocko@kernel.org> writes:

> On Thu 23-02-17 19:14:27, Vitaly Kuznetsov wrote:
>> Michal Hocko <mhocko@kernel.org> writes:
>> 
>> > On Thu 23-02-17 17:36:38, Vitaly Kuznetsov wrote:
>> >> Michal Hocko <mhocko@kernel.org> writes:
>> > [...]
>> >> > Is a grow from 256M -> 128GB really something that happens in real life?
>> >> > Don't get me wrong but to me this sounds quite exaggerated. Hotmem add
>> >> > which is an operation which has to allocate memory has to scale with the
>> >> > currently available memory IMHO.
>> >> 
>> >> With virtual machines this is very real and not exaggerated at
>> >> all. E.g. Hyper-V host can be tuned to automatically add new memory when
>> >> guest is running out of it. Even 100 blocks can represent an issue.
>> >
>> > Do you have any reference to a bug report. I am really curious because
>> > something really smells wrong and it is not clear that the chosen
>> > solution is really the best one.
>> 
>> Unfortunately I'm not aware of any publicly posted bug reports (CC:
>> K. Y. - he may have a reference) but I think I still remember everything
>> correctly. Not sure how deep you want me to go into details though...
>
> As much as possible to understand what was really going on...
>
>> Virtual guests under stress were getting into OOM easily and the OOM
>> killer was even killing the udev process trying to online the
>> memory.
>
> Do you happen to have any OOM report? I am really surprised that udev
> would be an oom victim because that process is really small. Who is
> consuming all the memory then?

It's been a while since I worked on this and unfortunatelly I don't have
a log. From what I remember, the kernel itself was consuming all memory
so *all* processes were victims.

>
> Have you measured how much memory do we need to allocate to add one
> memblock?

No, it's actually a good idea if we decide to do some sort of pre-allocation.

Just did a quick (and probably dirty) test, increasing guest memory from
4G to 8G (32 x 128mb blocks) require 68Mb of memory, so it's roughly 2Mb
per block. It's really easy to trigger OOM for small guests.

>
>> There was a workaround for the issue added to the hyper-v driver
>> doing memory add:
>> 
>> hv_mem_hot_add(...) {
>> ...
>>  add_memory(....);
>>  wait_for_completion_timeout(..., 5*HZ);
>>  ...
>> }
>
> I can still see 
> 		/*
> 		 * Wait for the memory block to be onlined when memory onlining
> 		 * is done outside of kernel (memhp_auto_online). Since the hot
> 		 * add has succeeded, it is ok to proceed even if the pages in
> 		 * the hot added region have not been "onlined" within the
> 		 * allowed time.
> 		 */
> 		if (dm_device.ha_waiting)
> 			wait_for_completion_timeout(&dm_device.ol_waitevent,
> 						    5*HZ);
>

See 

 dm_device.ha_waiting = !memhp_auto_online;

30 lines above. The workaround is still there for udev case and it is
still equaly bad.

>> the completion was done by observing for the MEM_ONLINE event. This, of
>> course, was slowing things down significantly and waiting for a
>> userspace action in kernel is not a nice thing to have (not speaking
>> about all other memory adding methods which had the same issue). Just
>> removing this wait was leading us to the same OOM as the hypervisor was
>> adding more and more memory and eventually even add_memory() was
>> failing, udev and other processes were killed,...
>
> Yes, I agree that waiting on a user action from the kernel is very far
> from ideal.
>
>> With the feature in place we have new memory available right after we do
>> add_memory(), everything is serialized.
>
> What prevented you from onlining the memory explicitly from
> hv_mem_hot_add path? Why do you need a user visible policy for that at
> all? You could also add a parameter to add_memory that would do the same
> thing. Or am I missing something?

We have different mechanisms for adding memory, I'm aware of at least 3:
ACPI, Xen, Hyper-V. The issue I'm addressing is general enough, I'm
pretty sure I can reproduce the issue on Xen, for example - just boot a
small guest and try adding tons of memory. Why should we have different
defaults for different technologies? 

And, BTW, the link to the previous discussion:
https://groups.google.com/forum/#!msg/linux.kernel/AxvyuQjr4GY/TLC-K0sL_NEJ

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
