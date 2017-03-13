Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E853B6B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 08:55:06 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v125so223536762qkh.5
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 05:55:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x188si351777qkd.12.2017.03.13.05.55.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 05:55:06 -0700 (PDT)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
References: <20170227154304.GK26504@dhcp22.suse.cz>
	<1488462828-174523-1-git-send-email-imammedo@redhat.com>
	<20170302142816.GK1404@dhcp22.suse.cz>
	<20170302180315.78975d4b@nial.brq.redhat.com>
	<20170303082723.GB31499@dhcp22.suse.cz>
	<20170303183422.6358ee8f@nial.brq.redhat.com>
	<20170306145417.GG27953@dhcp22.suse.cz>
	<20170307134004.58343e14@nial.brq.redhat.com>
	<20170309125400.GI11592@dhcp22.suse.cz>
	<20170313115554.41d16b1f@nial.brq.redhat.com>
	<20170313122825.GO31518@dhcp22.suse.cz>
Date: Mon, 13 Mar 2017 13:54:59 +0100
In-Reply-To: <20170313122825.GO31518@dhcp22.suse.cz> (Michal Hocko's message
	of "Mon, 13 Mar 2017 13:28:25 +0100")
Message-ID: <87a88pgwv0.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Igor Mammedov <imammedo@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz

Michal Hocko <mhocko@kernel.org> writes:

> On Mon 13-03-17 11:55:54, Igor Mammedov wrote:
>> > > 
>> > >        - suggested RFC is not acceptable from virt point of view
>> > >          as it regresses guests on top of x86 kvm/vmware which
>> > >          both use ACPI based memory hotplug.
>> > > 
>> > >        - udev/userspace solution doesn't work in practice as it's
>> > >          too slow and unreliable when system is under load which
>> > >          is quite common in virt usecase. That's why auto online
>> > >          has been introduced in the first place.  
>> > 
>> > Please try to be more specific why "too slow" is a problem. Also how
>> > much slower are we talking about?
>>
>> In virt case on host with lots VMs, userspace handler
>> processing could be scheduled late enough to trigger a race
>> between (guest memory going away/OOM handler) and memory
>> coming online.
>
> Either you are mixing two things together or this doesn't really make
> much sense. So is this a balloning based on memory hotplug (aka active
> memory hotadd initiated between guest and host automatically) or a guest
> asking for additional memory by other means (pay more for memory etc.)?
> Because if this is an administrative operation then I seriously question
> this reasoning.

I'm probably repeating myself but it seems this point was lost:

This is not really a 'ballooning', it is just a pure memory
hotplug. People may have any tools monitoring their VM memory usage and
when a VM is running low on memory they may want to hotplug more memory
to it. With udev-style memory onlining they should be aware of page
tables and other in-kernel structures which require allocation so they
need to add memory slowly and gradually or they risk running into OOM
(at least getting some processes killed and these processes may be
important). With in-kernel memory hotplug everything happens
synchronously and no 'slowly and gradually' algorithm is required in
all tools which may trigger memory hotplug.

It's not about slowness, it's about being synchronous or
asynchronous. This is not related to the virtualization technology used,
the use-case is the same for all of them which support memory hotplug.

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
