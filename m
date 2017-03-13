Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 54FDB6B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 09:42:45 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id a189so239820374qkc.4
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 06:42:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y184si442209qkc.101.2017.03.13.06.42.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 06:42:44 -0700 (PDT)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
References: <20170302142816.GK1404@dhcp22.suse.cz>
	<20170302180315.78975d4b@nial.brq.redhat.com>
	<20170303082723.GB31499@dhcp22.suse.cz>
	<20170303183422.6358ee8f@nial.brq.redhat.com>
	<20170306145417.GG27953@dhcp22.suse.cz>
	<20170307134004.58343e14@nial.brq.redhat.com>
	<20170309125400.GI11592@dhcp22.suse.cz>
	<20170313115554.41d16b1f@nial.brq.redhat.com>
	<20170313122825.GO31518@dhcp22.suse.cz>
	<87a88pgwv0.fsf@vitty.brq.redhat.com>
	<20170313131924.GP31518@dhcp22.suse.cz>
Date: Mon, 13 Mar 2017 14:42:37 +0100
In-Reply-To: <20170313131924.GP31518@dhcp22.suse.cz> (Michal Hocko's message
	of "Mon, 13 Mar 2017 14:19:25 +0100")
Message-ID: <87pohlfg36.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Igor Mammedov <imammedo@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz

Michal Hocko <mhocko@kernel.org> writes:

> On Mon 13-03-17 13:54:59, Vitaly Kuznetsov wrote:
>> Michal Hocko <mhocko@kernel.org> writes:
>> 
>> > On Mon 13-03-17 11:55:54, Igor Mammedov wrote:
>> >> > > 
>> >> > >        - suggested RFC is not acceptable from virt point of view
>> >> > >          as it regresses guests on top of x86 kvm/vmware which
>> >> > >          both use ACPI based memory hotplug.
>> >> > > 
>> >> > >        - udev/userspace solution doesn't work in practice as it's
>> >> > >          too slow and unreliable when system is under load which
>> >> > >          is quite common in virt usecase. That's why auto online
>> >> > >          has been introduced in the first place.  
>> >> > 
>> >> > Please try to be more specific why "too slow" is a problem. Also how
>> >> > much slower are we talking about?
>> >>
>> >> In virt case on host with lots VMs, userspace handler
>> >> processing could be scheduled late enough to trigger a race
>> >> between (guest memory going away/OOM handler) and memory
>> >> coming online.
>> >
>> > Either you are mixing two things together or this doesn't really make
>> > much sense. So is this a balloning based on memory hotplug (aka active
>> > memory hotadd initiated between guest and host automatically) or a guest
>> > asking for additional memory by other means (pay more for memory etc.)?
>> > Because if this is an administrative operation then I seriously question
>> > this reasoning.
>> 
>> I'm probably repeating myself but it seems this point was lost:
>> 
>> This is not really a 'ballooning', it is just a pure memory
>> hotplug. People may have any tools monitoring their VM memory usage and
>> when a VM is running low on memory they may want to hotplug more memory
>> to it.
>
> What is the API those guests ask for the memory? And who is actually
> responsible to ask for that memory? Is it a kernel or userspace
> solution?

Whatever, this can even be a system administrator running
'free'. Hyper-V driver sends si_mem_available() and
vm_memory_committed() metrics to the host every second and this can be
later queried by any tool (e.g. powershell script).

>
>> With udev-style memory onlining they should be aware of page
>> tables and other in-kernel structures which require allocation so they
>> need to add memory slowly and gradually or they risk running into OOM
>> (at least getting some processes killed and these processes may be
>> important). With in-kernel memory hotplug everything happens
>> synchronously and no 'slowly and gradually' algorithm is required in
>> all tools which may trigger memory hotplug.
>
> What prevents those APIs being used reasonably and only asks so much
> memory as they can afford? I mean 1.5% available memory necessary for
> the hotplug is not all that much. Or more precisely what prevents to ask
> for this additional memory in a synchronous way?

The knowledge about the fact that we need to add memory slowly and
wait till it gets onlined is not obvious. AFAIR when you hotplug memory
to Windows VMs there is no such thing as 'onlining', and no brain is
required, a simple script 'low memory -> add mory memory' always
works. Asking all these script writers to think twice before issuing a
memory add command memory sounds like too much (to me).

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
