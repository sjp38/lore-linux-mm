Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id E92B66B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 17:55:56 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id i1so46439598ota.0
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 14:55:56 -0800 (PST)
Received: from mail-ot0-x22f.google.com (mail-ot0-x22f.google.com. [2607:f8b0:4003:c0f::22f])
        by mx.google.com with ESMTPS id s111si2662987ota.79.2017.03.01.14.55.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 14:55:55 -0800 (PST)
Received: by mail-ot0-x22f.google.com with SMTP id i1so40746865ota.3
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 14:55:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170301170429.GB5208@osiris>
References: <alpine.LFD.2.20.1702261231580.3067@schleppi.fritz.box>
 <20170227162031.GA27937@dhcp22.suse.cz> <20170228115729.GB13872@osiris>
 <20170301125105.GA5208@osiris> <CAPcyv4ghK3GWUD0qBNigfQvPM6qUWLMwmfgT5THcDcjuYrjSSQ@mail.gmail.com>
 <20170301170429.GB5208@osiris>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 1 Mar 2017 14:55:55 -0800
Message-ID: <CAPcyv4iUzC_rN4mg5c5ShLAoFxam7Jiek4q8dDaHTi44cxB=Aw@mail.gmail.com>
Subject: Re: [PATCH] mm, add_memory_resource: hold device_hotplug lock over
 mem_hotplug_{begin, done}
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ben Hutchings <ben@decadent.org.uk>

On Wed, Mar 1, 2017 at 9:04 AM, Heiko Carstens
<heiko.carstens@de.ibm.com> wrote:
> On Wed, Mar 01, 2017 at 07:52:18AM -0800, Dan Williams wrote:
>> On Wed, Mar 1, 2017 at 4:51 AM, Heiko Carstens
>> <heiko.carstens@de.ibm.com> wrote:
>> > Since it is anything but obvious why Dan wrote in changelog of b5d24fda9c3d
>> > ("mm, devm_memremap_pages: hold device_hotplug lock over
>> > mem_hotplug_{begin, done}") that write accesses to
>> > mem_hotplug.active_writer are coordinated via lock_device_hotplug() I'd
>> > rather propose a new private memory_add_remove_lock which has similar
>> > semantics like the cpu_add_remove_lock for cpu hotplug (see patch below).
>> >
>> > However instead of sprinkling locking/unlocking of that new lock around all
>> > calls of mem_hotplug_begin() and mem_hotplug_end() simply include locking
>> > and unlocking into these two functions.
>> >
>> > This still allows get_online_mems() and put_online_mems() to work, while at
>> > the same time preventing mem_hotplug.active_writer corruption.
>> >
>> > Any opinions?
>>
>> Sorry, yes, I didn't make it clear that I derived that locking
>> requirement from store_mem_state() and its usage of
>> lock_device_hotplug_sysfs().
>>
>> That routine is trying very hard not trip the soft-lockup detector. It
>> seems like that wants to be an interruptible wait.
>
> If you look at commit 5e33bc4165f3 ("driver core / ACPI: Avoid device hot
> remove locking issues") then lock_device_hotplug_sysfs() was introduced to
> avoid a different subtle deadlock, but it also sleeps uninterruptible, but
> not for more than 5ms ;)
>
> However I'm not sure if the device hotplug lock should also be used to fix
> an unrelated bug that was introduced with the get_online_mems() /
> put_online_mems() interface. Should it?

No, I don't think it should.

I like your proposed direction of creating a new lock internal to
mem_hotplug_begin() to protect active_writer, and stop relying on
lock_device_hotplug to serve this purpose.

> If so, we need to sprinkle around a couple of lock_device_hotplug() calls
> near mem_hotplug_begin() calls, like Sebastian already started, and give it
> additional semantics (protecting mem_hotplug.active_writer), and hope it
> doesn't lead to deadlocks anywhere.

I'll put your proposed patch through some testing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
