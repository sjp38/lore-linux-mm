Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B7176B038A
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 10:52:20 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id x195so23752844oia.0
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 07:52:20 -0800 (PST)
Received: from mail-ot0-x22a.google.com (mail-ot0-x22a.google.com. [2607:f8b0:4003:c0f::22a])
        by mx.google.com with ESMTPS id m129si2287484oig.188.2017.03.01.07.52.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 07:52:19 -0800 (PST)
Received: by mail-ot0-x22a.google.com with SMTP id k4so32394787otc.0
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 07:52:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170301125105.GA5208@osiris>
References: <alpine.LFD.2.20.1702261231580.3067@schleppi.fritz.box>
 <20170227162031.GA27937@dhcp22.suse.cz> <20170228115729.GB13872@osiris> <20170301125105.GA5208@osiris>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 1 Mar 2017 07:52:18 -0800
Message-ID: <CAPcyv4ghK3GWUD0qBNigfQvPM6qUWLMwmfgT5THcDcjuYrjSSQ@mail.gmail.com>
Subject: Re: [PATCH] mm, add_memory_resource: hold device_hotplug lock over
 mem_hotplug_{begin, done}
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ben Hutchings <ben@decadent.org.uk>

On Wed, Mar 1, 2017 at 4:51 AM, Heiko Carstens
<heiko.carstens@de.ibm.com> wrote:
> On Tue, Feb 28, 2017 at 12:57:29PM +0100, Heiko Carstens wrote:
>> On Mon, Feb 27, 2017 at 05:20:31PM +0100, Michal Hocko wrote:
>> > [CC Rafael]
>> >
>> > I've got lost in the acpi indirection (again). I can see
>> > acpi_device_hotplug calling lock_device_hotplug() but i cannot find a
>> > path down to add_memory() which might call add_memory_resource. But the
>> > patch below sounds suspicious to me. Is it possible that this could lead
>> > to a deadlock. I would suspect that it is the s390 code which needs to
>> > do the locking. But I would have to double check - it is really easy to
>> > get lost there.
>>
>> To me it rather looks like bfc8c90139eb ("mem-hotplug: implement
>> get/put_online_mems") introduced quite subtle and probably wrong locking
>> rules.
>>
>> The patch introduced mem_hotplug_begin() in order to have something like
>> cpu_hotplug_begin() for memory. Note that for cpu hotplug all
>> cpu_hotplug_begin() calls are serialized by cpu_maps_update_begin().
>>
>> Especially this makes sure that active_writer can only be changed by one
>> process. (See also Dan's commit which introduced the lock_device_hotplug()
>> calls: https://marc.info/?l=linux-kernel&m=148693912419972&w=2 )
>>
>> If you look at the above commit bfc8c90139eb: there is nothing like
>> cpu_maps_update_begin() for memory. And therefore it's possible to have
>> concurrent writers to active_writer.
>>
>> It looks like now lock_device_hotplug() is supposed to be the new
>> cpu_maps_update_begin() for memory. But.. this looks like a mess, unless I
>> read the code completely wrong ;)
>
> [Full quote since I now hopefully use a non-bouncing email address from
> Vladimir]
>
> Since it is anything but obvious why Dan wrote in changelog of b5d24fda9c3d
> ("mm, devm_memremap_pages: hold device_hotplug lock over
> mem_hotplug_{begin, done}") that write accesses to
> mem_hotplug.active_writer are coordinated via lock_device_hotplug() I'd
> rather propose a new private memory_add_remove_lock which has similar
> semantics like the cpu_add_remove_lock for cpu hotplug (see patch below).
>
> However instead of sprinkling locking/unlocking of that new lock around all
> calls of mem_hotplug_begin() and mem_hotplug_end() simply include locking
> and unlocking into these two functions.
>
> This still allows get_online_mems() and put_online_mems() to work, while at
> the same time preventing mem_hotplug.active_writer corruption.
>
> Any opinions?

Sorry, yes, I didn't make it clear that I derived that locking
requirement from store_mem_state() and its usage of
lock_device_hotplug_sysfs().

That routine is trying very hard not trip the soft-lockup detector. It
seems like that wants to be an interruptible wait.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
