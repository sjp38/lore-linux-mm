Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id DA17F6B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:18:18 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id v74so14506605qkb.21
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:18:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a103si11611033qkh.5.2018.11.14.00.18.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 00:18:17 -0800 (PST)
Subject: Re: Memory hotplug softlock issue
References: <20181114070909.GB2653@MiWiFi-R3L-srv>
From: David Hildenbrand <david@redhat.com>
Message-ID: <5a6c6d6b-ebcd-8bfa-d6e0-4312bfe86586@redhat.com>
Date: Wed, 14 Nov 2018 09:18:09 +0100
MIME-Version: 1.0
In-Reply-To: <20181114070909.GB2653@MiWiFi-R3L-srv>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mhocko@suse.com, akpm@linux-foundation.org, aarcange@redhat.com

On 14.11.18 08:09, Baoquan He wrote:
> Hi,
> 
> Tested memory hotplug on a bare metal system, hot removing always
> trigger a lock. Usually need hot plug/unplug several times, then the hot
> removing will hang there at the last block. Surely with memory pressure
> added by executing "stress -m 200".
> 
> Will attach the log partly. Any idea or suggestion, appreciated. 
> 
> Thanks
> Baoquan
> 

Code seems to be waiting for the mem_hotplug_lock in read.
We hold mem_hotplug_lock in write whenever we online/offline/add/remove
memory. There are two ways to trigger offlining of memory:

1. Offlining via "cat offline > /sys/devices/system/memory/memory0/state"

This always properly took the mem_hotplug_lock. Nothing changed

2. Offlining via "cat 0 > /sys/devices/system/memory/memory0/online"

This didn't take the mem_hotplug_lock and I fixed that for this release.

So if you were testing with 1., you should have seen the same error
before this release (unless there is something else now broken in this
release).


The real question is, however, why offlining of the last block doesn't
succeed. In __offline_pages() we basically have an endless loop (while
holding the mem_hotplug_lock in write). Now I consider this piece of
code very problematic (we should automatically fail after X
attempts/after X seconds, we should not ignore -ENOMEM), and we've had
other BUGs whereby we would run into an endless loop here (e.g. related
to hugepages I guess).

You mentioned memory pressure, if our host is under memory pressure we
can easily trigger running into an endless loop there, because we
basically ignore -ENOMEM e.g. when we cannot get a page to migrate some
memory to be offlined. I assume this is the case here.
do_migrate_range() could be the bad boy if it keeps failing forever and
we keep retrying.

-- 

Thanks,

David / dhildenb
