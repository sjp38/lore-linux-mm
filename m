Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 085AA6B0419
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 13:10:33 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id 126so98393972oig.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 10:10:33 -0800 (PST)
Received: from mail-ot0-x231.google.com (mail-ot0-x231.google.com. [2607:f8b0:4003:c0f::231])
        by mx.google.com with ESMTPS id w82si218021oig.47.2017.03.09.10.10.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 10:10:32 -0800 (PST)
Received: by mail-ot0-x231.google.com with SMTP id o24so61558019otb.1
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 10:10:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1625096.urmnZ9bKn4@aspire.rjw.lan>
References: <20170309130616.51286-1-heiko.carstens@de.ibm.com>
 <20170309130616.51286-2-heiko.carstens@de.ibm.com> <1625096.urmnZ9bKn4@aspire.rjw.lan>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 9 Mar 2017 10:10:31 -0800
Message-ID: <CAPcyv4jXmxjVaR=sGfqjy2QP_Yq4ALfTQb9_QMZ3tk0ntxfTFA@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: add private lock to serialize memory hotplug operations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ben Hutchings <ben@decadent.org.uk>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Thu, Mar 9, 2017 at 5:39 AM, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
> On Thursday, March 09, 2017 02:06:15 PM Heiko Carstens wrote:
>> Commit bfc8c90139eb ("mem-hotplug: implement get/put_online_mems")
>> introduced new functions get/put_online_mems() and
>> mem_hotplug_begin/end() in order to allow similar semantics for memory
>> hotplug like for cpu hotplug.
>>
>> The corresponding functions for cpu hotplug are get/put_online_cpus()
>> and cpu_hotplug_begin/done() for cpu hotplug.
>>
>> The commit however missed to introduce functions that would serialize
>> memory hotplug operations like they are done for cpu hotplug with
>> cpu_maps_update_begin/done().
>>
>> This basically leaves mem_hotplug.active_writer unprotected and allows
>> concurrent writers to modify it, which may lead to problems as
>> outlined by commit f931ab479dd2 ("mm: fix devm_memremap_pages crash,
>> use mem_hotplug_{begin, done}").
>>
>> That commit was extended again with commit b5d24fda9c3d ("mm,
>> devm_memremap_pages: hold device_hotplug lock over mem_hotplug_{begin,
>> done}") which serializes memory hotplug operations for some call
>> sites by using the device_hotplug lock.
>>
>> In addition with commit 3fc21924100b ("mm: validate device_hotplug is
>> held for memory hotplug") a sanity check was added to
>> mem_hotplug_begin() to verify that the device_hotplug lock is held.
>
> Admittedly, I haven't looked at all of the code paths involved in detail yet,
> but there's one concern regarding lock/unlock_device_hotplug().
>
> The actual main purpose of it is to ensure safe removal of devices in cases
> when they cannot be removed separately, like when a whole CPU package
> (including possibly an entire NUMA node with memory and all) is removed.
>
> One of the code paths doing that is acpi_scan_hot_remove() which first
> tries to offline devices slated for removal and then finally removes them.
>
> The reason why this needs to be done in two stages is because the offlining
> can fail, in which case we will fail the entire operation, while the final
> removal step is, well, final (meaning that the devices are gone after it no
> matter what).
>
> This is done under device_hotplug_lock, so that the devices that were taken
> offline in stage 1 cannot be brought back online before stage 2 is carried
> out entirely, which surely would be bad if it happened.
>
> Now, I'm not sure if removing lock/unlock_device_hotplug() from the code in
> question actually affects this mechanism, but this in case it does, it is one
> thing to double check before going ahead with this patch.
>

I *think* we're ok in this case because unplugging the CPU package
that contains a persistent memory device will trigger
devm_memremap_pages() to call arch_remove_memory(). Removing a pmem
device can't fail. It may be held off while pages are pinned for DMA
memory, but it will eventually complete.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
