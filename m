Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id B4B336B0431
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 01:26:47 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id a12so78809685ota.1
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 22:26:47 -0800 (PST)
Received: from mail-ot0-x22b.google.com (mail-ot0-x22b.google.com. [2607:f8b0:4003:c0f::22b])
        by mx.google.com with ESMTPS id r50si2542189otc.287.2017.03.08.22.26.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 22:26:46 -0800 (PST)
Received: by mail-ot0-x22b.google.com with SMTP id o24so50163075otb.1
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 22:26:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170306082221.GA4572@osiris>
References: <alpine.LFD.2.20.1702261231580.3067@schleppi.fritz.box>
 <20170227162031.GA27937@dhcp22.suse.cz> <20170228115729.GB13872@osiris>
 <20170301125105.GA5208@osiris> <CAPcyv4ghK3GWUD0qBNigfQvPM6qUWLMwmfgT5THcDcjuYrjSSQ@mail.gmail.com>
 <20170301170429.GB5208@osiris> <CAPcyv4iUzC_rN4mg5c5ShLAoFxam7Jiek4q8dDaHTi44cxB=Aw@mail.gmail.com>
 <20170306082221.GA4572@osiris>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 8 Mar 2017 22:26:46 -0800
Message-ID: <CAPcyv4jr5BQTSinNechQr5Zt93NwXh9R5F2ppM=yPG2rHdWwEA@mail.gmail.com>
Subject: Re: [PATCH] mm, add_memory_resource: hold device_hotplug lock over
 mem_hotplug_{begin, done}
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ben Hutchings <ben@decadent.org.uk>

On Mon, Mar 6, 2017 at 12:22 AM, Heiko Carstens
<heiko.carstens@de.ibm.com> wrote:
> Hello Dan,
>
>> > If you look at commit 5e33bc4165f3 ("driver core / ACPI: Avoid device hot
>> > remove locking issues") then lock_device_hotplug_sysfs() was introduced to
>> > avoid a different subtle deadlock, but it also sleeps uninterruptible, but
>> > not for more than 5ms ;)
>> >
>> > However I'm not sure if the device hotplug lock should also be used to fix
>> > an unrelated bug that was introduced with the get_online_mems() /
>> > put_online_mems() interface. Should it?
>>
>> No, I don't think it should.
>>
>> I like your proposed direction of creating a new lock internal to
>> mem_hotplug_begin() to protect active_writer, and stop relying on
>> lock_device_hotplug to serve this purpose.
>>
>> > If so, we need to sprinkle around a couple of lock_device_hotplug() calls
>> > near mem_hotplug_begin() calls, like Sebastian already started, and give it
>> > additional semantics (protecting mem_hotplug.active_writer), and hope it
>> > doesn't lead to deadlocks anywhere.
>>
>> I'll put your proposed patch through some testing.
>
> On s390 it _seems_ to work. Did it pass your testing too?
> If so I would send a patch with proper patch description for inclusion.

Looks ok here. No lockdep warnings running it through it paces with
the persistent memory use case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
