Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 57F256B038B
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 10:49:10 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id v73so35443836qkv.7
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 07:49:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n62si3481554qkf.156.2017.02.23.07.49.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 07:49:09 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [RFC PATCH] memory-hotplug: Use dev_online for memhp_auto_offline
References: <20170221172234.8047.33382.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
	<878toy1sgd.fsf@vitty.brq.redhat.com>
	<20170223125643.GA29064@dhcp22.suse.cz>
	<87bmttyqxf.fsf@vitty.brq.redhat.com>
	<20170223150920.GB29056@dhcp22.suse.cz>
Date: Thu, 23 Feb 2017 16:49:06 +0100
In-Reply-To: <20170223150920.GB29056@dhcp22.suse.cz> (Michal Hocko's message
	of "Thu, 23 Feb 2017 16:09:20 +0100")
Message-ID: <877f4gzz4d.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>, linux-mm@kvack.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, mdroth@linux.vnet.ibm.com

Michal Hocko <mhocko@kernel.org> writes:

> On Thu 23-02-17 14:31:24, Vitaly Kuznetsov wrote:
>> Michal Hocko <mhocko@kernel.org> writes:
>> 
>> > On Wed 22-02-17 10:32:34, Vitaly Kuznetsov wrote:
>> > [...]
>> >> > There is a workaround in that a user could online the memory or have
>> >> > a udev rule to online the memory by using the sysfs interface. The
>> >> > sysfs interface to online memory goes through device_online() which
>> >> > should updated the dev->offline flag. I'm not sure that having kernel
>> >> > memory hotplug rely on userspace actions is the correct way to go.
>> >> 
>> >> Using udev rule for memory onlining is possible when you disable
>> >> memhp_auto_online but in some cases it doesn't work well, e.g. when we
>> >> use memory hotplug to address memory pressure the loop through userspace
>> >> is really slow and memory consuming, we may hit OOM before we manage to
>> >> online newly added memory.
>> >
>> > How does the in-kernel implementation prevents from that?
>> >
>> 
>> Onlining memory on hot-plug is much more reliable, e.g. if we were able
>> to add it in add_memory_resource() we'll also manage to online it.
>
> How does that differ from initiating online from the users?
>
>> With
>> udev rule we may end up adding many blocks and then (as udev is
>> asynchronous) failing to online any of them.
>
> Why would it fail?
>
>> In-kernel operation is synchronous.
>
> which doesn't mean anything as the context is preemptible AFAICS.
>

It actually does,

imagine the following example: you run a small guest (256M of memory)
and now there is a request to add 1000 128mb blocks to it. In case you
do it the old way you're very likely to get OOM somewhere in the middle
as you keep adding blocks which requere kernel memory and nobody is
onlining it (or, at least you're racing with the onliner). With
in-kernel implementation we're going to online the first block when it's
added and only then go to the second.

>> >> In addition to that, systemd/udev folks
>> >> continuosly refused to add this udev rule to udev calling it stupid as
>> >> it actually is an unconditional and redundant ping-pong between kernel
>> >> and udev.
>> >
>> > This is a policy and as such it doesn't belong to the kernel. The whole
>> > auto-enable in the kernel is just plain wrong IMHO and we shouldn't have
>> > merged it.
>> 
>> I disagree.
>> 
>> First of all it's not a policy, it is a default. We have many other
>> defaults in kernel. When I add a network card or a storage, for example,
>> I don't need to go anywhere and 'enable' it before I'm able to use
>> it from userspace. An for memory (and CPUs) we, for some unknown reason
>> opted for something completely different. If someone is plugging new
>> memory into a box he probably wants to use it, I don't see much value in
>> waiting for a special confirmation from him. 
>
> This was not my decision so I can only guess but to me it makes sense.
> Both memory and cpus can be physically present and offline which is a
> perfectly reasonable state. So having a two phase physicall hotadd is
> just built on top of physical vs. logical distinction. I completely
> understand that some usecases will really like to online the whole node
> as soon as it appears present. But an automatic in-kernel implementation
> has its down sites - e.g. if this operation fails in the middle you will
> not know about that unless you check all the memblocks in sysfs. This is
> really a poor interface.

And how do you know that some blocks failed to online with udev? Who
handles these failures and how? And, the last but not least, why do
these failures happen?

>
>> Second, this feature is optional. If you want to keep old behavior just
>> don't enable it.
>
> It just adds unnecessary configuration noise as well
>

For any particular user everything he doesn't need is 'noise'...

>> Third, this solves real world issues. With Hyper-V it is very easy to
>> show udev failing on stress. 
>
> What is the reason for this failures. Do you have any link handy?
>

The reason is going out of memory, swapping and being slow in
general. Again, think about the example I give above: there is a request
to add many memory blocks and if we try to handle them all before any of
them get online we will get OOM and may even kill the udev process.

>> No other solution to the issue was ever suggested.
>
> you mean like using ballooning for the memory overcommit like other more
> reasonable virtualization solutions?

Not sure how ballooning is related here. Hyper-V uses memory hotplug to
add memory to domains, I don't think we have any other solutions for
that. From hypervisor's point of view the memory was added when the
particular request succeeded, it is not aware of our 'logical/physical'
separation.

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
