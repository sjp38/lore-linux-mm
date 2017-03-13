Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7451F6B038A
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 11:10:41 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o135so241879090qke.3
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 08:10:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l66si629937qkd.4.2017.03.13.08.10.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 08:10:40 -0700 (PDT)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
References: <20170303082723.GB31499@dhcp22.suse.cz>
	<20170303183422.6358ee8f@nial.brq.redhat.com>
	<20170306145417.GG27953@dhcp22.suse.cz>
	<20170307134004.58343e14@nial.brq.redhat.com>
	<20170309125400.GI11592@dhcp22.suse.cz>
	<20170313115554.41d16b1f@nial.brq.redhat.com>
	<20170313122825.GO31518@dhcp22.suse.cz>
	<87a88pgwv0.fsf@vitty.brq.redhat.com>
	<20170313131924.GP31518@dhcp22.suse.cz>
	<87pohlfg36.fsf@vitty.brq.redhat.com>
	<20170313143206.GQ31518@dhcp22.suse.cz>
Date: Mon, 13 Mar 2017 16:10:34 +0100
In-Reply-To: <20170313143206.GQ31518@dhcp22.suse.cz> (Michal Hocko's message
	of "Mon, 13 Mar 2017 15:32:06 +0100")
Message-ID: <87h92xfc0l.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Igor Mammedov <imammedo@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz

Michal Hocko <mhocko@kernel.org> writes:

> On Mon 13-03-17 14:42:37, Vitaly Kuznetsov wrote:
>> >
>> > What is the API those guests ask for the memory? And who is actually
>> > responsible to ask for that memory? Is it a kernel or userspace
>> > solution?
>> 
>> Whatever, this can even be a system administrator running
>> 'free'.
>
> I am pretty sure that 'free' will not give you additional memory but
> let's be serious here... 
> If this is solely about monitoring from
> userspace and requesting more memory from the userspace then I would
> consider arguing about timely hotplug operation as void because there is
> absolutely no guarantee to do the request itself in a timely fashion.
>
>> Hyper-V driver sends si_mem_available() and
>> vm_memory_committed() metrics to the host every second and this can be
>> later queried by any tool (e.g. powershell script).
>
> And how exactly is this related to the acpi hotplug which you were
> arguing needs the timely handling as well?
>

What I meant to say is that there is no single 'right' way to get memory
usage from a VM, make a decision somewhere (in the hypervisor, on some
other host or even in someone's head) and issue a command to add more
memory. I don't know what particular tools people use with ESX/KVM VMs
but I think that multiple options are available.

>> >> With udev-style memory onlining they should be aware of page
>> >> tables and other in-kernel structures which require allocation so they
>> >> need to add memory slowly and gradually or they risk running into OOM
>> >> (at least getting some processes killed and these processes may be
>> >> important). With in-kernel memory hotplug everything happens
>> >> synchronously and no 'slowly and gradually' algorithm is required in
>> >> all tools which may trigger memory hotplug.
>> >
>> > What prevents those APIs being used reasonably and only asks so much
>> > memory as they can afford? I mean 1.5% available memory necessary for
>> > the hotplug is not all that much. Or more precisely what prevents to ask
>> > for this additional memory in a synchronous way?
>> 
>> The knowledge about the fact that we need to add memory slowly and
>> wait till it gets onlined is not obvious.
>
> yes it is and we cannot afford to give a better experience with the
> implementation that requires to have memory to online a memory.

Actually, we need memory to add memory, not to online it. And as I said
before, this is a real issue which requires addressing, it should always
be possible to add more memory (and to online already added memory if
these events are separated).

>
>> AFAIR when you hotplug memory
>> to Windows VMs there is no such thing as 'onlining', and no brain is
>> required, a simple script 'low memory -> add mory memory' always
>> works. Asking all these script writers to think twice before issuing a
>> memory add command memory sounds like too much (to me).
>
> Pardon me, but not requiring a brain while doing something on Windows
> VMs is not really an argument...

Why? Windows (or any other OS) is just an example that things can be
done in a different way, otherwise we'll end up with arguments like "it
was always like that in Linux so it's good".

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
