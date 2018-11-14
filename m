Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6BBF66B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 04:00:52 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id c84so36738094qkb.13
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 01:00:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y5si5613888qvk.5.2018.11.14.01.00.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 01:00:51 -0800 (PST)
Date: Wed, 14 Nov 2018 17:00:42 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181114090042.GD2653@MiWiFi-R3L-srv>
References: <20181114070909.GB2653@MiWiFi-R3L-srv>
 <5a6c6d6b-ebcd-8bfa-d6e0-4312bfe86586@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5a6c6d6b-ebcd-8bfa-d6e0-4312bfe86586@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com, akpm@linux-foundation.org, aarcange@redhat.com

Hi David,

On 11/14/18 at 09:18am, David Hildenbrand wrote:
> Code seems to be waiting for the mem_hotplug_lock in read.
> We hold mem_hotplug_lock in write whenever we online/offline/add/remove
> memory. There are two ways to trigger offlining of memory:
> 
> 1. Offlining via "cat offline > /sys/devices/system/memory/memory0/state"
> 
> This always properly took the mem_hotplug_lock. Nothing changed
> 
> 2. Offlining via "cat 0 > /sys/devices/system/memory/memory0/online"
> 
> This didn't take the mem_hotplug_lock and I fixed that for this release.
> 
> So if you were testing with 1., you should have seen the same error
> before this release (unless there is something else now broken in this
> release).

Thanks a lot for looking into this.

I triggered sysrq+t to check threads' state. You can see that we use
firmware to trigger ACPI event to go to acpi_bus_offline(), it truly
didn't take mem_hotplug_lock() and has taken it with your fix in
commit 381eab4a6ee mm/memory_hotplug: fix online/offline_pages called w.o. mem_hotplug_lock

[  +0.007062] Workqueue: kacpi_hotplug acpi_hotplug_work_fn
[  +0.005398] Call Trace:
[  +0.002476]  ? page_vma_mapped_walk+0x307/0x710
[  +0.004538]  ? page_remove_rmap+0xa2/0x340
[  +0.004104]  ? ptep_clear_flush+0x54/0x60
[  +0.004027]  ? enqueue_entity+0x11c/0x620
[  +0.005904]  ? schedule+0x28/0x80
[  +0.003336]  ? rmap_walk_file+0xf9/0x270
[  +0.003940]  ? try_to_unmap+0x9c/0xf0
[  +0.003695]  ? migrate_pages+0x2b0/0xb90
[  +0.003959]  ? try_offline_node+0x160/0x160
[  +0.004214]  ? __offline_pages+0x6ce/0x8e0
[  +0.004134]  ? memory_subsys_offline+0x40/0x60
[  +0.004474]  ? device_offline+0x81/0xb0
[  +0.003867]  ? acpi_bus_offline+0xdb/0x140
[  +0.004117]  ? acpi_device_hotplug+0x21c/0x460
[  +0.004458]  ? acpi_hotplug_work_fn+0x1a/0x30
[  +0.004372]  ? process_one_work+0x1a1/0x3a0
[  +0.004195]  ? worker_thread+0x30/0x380
[  +0.003851]  ? drain_workqueue+0x120/0x120
[  +0.004117]  ? kthread+0x112/0x130
[  +0.003411]  ? kthread_park+0x80/0x80
[  +0.005325]  ? ret_from_fork+0x35/0x40


> 
> 
> The real question is, however, why offlining of the last block doesn't
> succeed. In __offline_pages() we basically have an endless loop (while
> holding the mem_hotplug_lock in write). Now I consider this piece of
> code very problematic (we should automatically fail after X
> attempts/after X seconds, we should not ignore -ENOMEM), and we've had
> other BUGs whereby we would run into an endless loop here (e.g. related
> to hugepages I guess).

Hmm, even though memory hotplug stalled there, there are still much
memory. E.g in this system, it has 8 nodes and each node has 64 GB
memory, it's 512 GB in all. Now I run "stress -m 200" to trigger 200
processes to malloc then free 256 MB contiously, and it's eating 50 GB
in all. In theory, it still has much memory for migrating to.

> 
> You mentioned memory pressure, if our host is under memory pressure we
> can easily trigger running into an endless loop there, because we
> basically ignore -ENOMEM e.g. when we cannot get a page to migrate some
> memory to be offlined. I assume this is the case here.
> do_migrate_range() could be the bad boy if it keeps failing forever and
> we keep retrying.

Not sure what other people think about this. If failed the memory removing
when still much free memory left, I worry customer will complain.

Yeah, it stoped at do_migrate_range() when try to migrate the last
memory block. And each time it's the last memory block which can't be
offlined and hang.

If any message or information needed, I can provide.

Thanks
Baoquan
