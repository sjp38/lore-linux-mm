Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id B86DB6B0273
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 10:01:45 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j2so5595658qtl.1
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 07:01:45 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k11si7563546qtb.3.2018.04.13.07.01.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 07:01:44 -0700 (PDT)
Subject: Re: [PATCH RFC 0/8] mm: online/offline 4MB chunks controlled by
 device driver
References: <20180413131632.1413-1-david@redhat.com>
 <20180413134414.GS17484@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <3545ef32-14db-25ab-bf1a-56044402add3@redhat.com>
Date: Fri, 13 Apr 2018 16:01:43 +0200
MIME-Version: 1.0
In-Reply-To: <20180413134414.GS17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On 13.04.2018 15:44, Michal Hocko wrote:
> [If you choose to not CC the same set of people on all patches - which
> is sometimes a legit thing to do - then please cc them to the cover
> letter at least.]
> 
> On Fri 13-04-18 15:16:24, David Hildenbrand wrote:
>> I am right now working on a paravirtualized memory device ("virtio-mem").
>> These devices control a memory region and the amount of memory available
>> via it. Memory will not be indicated via ACPI and friends, the device
>> driver is responsible for it.
> 
> How does this compare to other ballooning solutions? And why your driver
> cannot simply use the existing sections and maintain subsections on top?
> 

(further down in this mail is a small paragraph about that)

All existing balloon implementations work on all memory available in the
system. Some of them are able to add memory later on (XEN, Hyper-V),
others are not (virtio-balloon). Having this model allows to plug/unplug
memory NUMA aware on a fine granularity (e.g. 4MB), while making the
implementation in the hypervisor a level of magnitudes easier.

We could have multiple paravirtualized memory devices, e.g. one for each
NUMA node.

E.g. when rebooting we don't have to resize any initial system memory
(a820, ACPI ...), but only care about the memory region of this one
device. By adding memory by the device driver, we can actually remove
the memory blocks again, freeing up the struct pages.

Also, I tend to not call the solution a balloon driver, rather
"paravirtualized memory". It is something like a balloon, but we are not
going to start fragmenting on a page level.

There is more to it, but this should cover the basics.


"And why your driver cannot simply use the existing sections and
maintain subsections on top?"

Can you elaborate how that is going to work? What I do as of now, is to
remember for each memory block (basically a section because I want to
make it as small as possible) which chunks ("subsections") are
online/offline. This works just fine. Is this what you are referring to?

However when it comes to marking a section finally offline or telling
kdump to not touch offline pages, I need the PG_offline.

(I had a prototype where I marked the sections manually offline once I
knew everything in it was offline, but that looked rather hackish)

Thanks for having a look!

-- 

Thanks,

David / dhildenb
