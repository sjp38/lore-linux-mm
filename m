Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 06BA76B0271
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 05:04:10 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id n32-v6so7938664edc.17
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 02:04:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z13-v6si2201047ejw.113.2018.11.14.02.04.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 02:04:08 -0800 (PST)
Date: Wed, 14 Nov 2018 11:04:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181114100407.GL23419@dhcp22.suse.cz>
References: <20181114070909.GB2653@MiWiFi-R3L-srv>
 <5a6c6d6b-ebcd-8bfa-d6e0-4312bfe86586@redhat.com>
 <20181114090042.GD2653@MiWiFi-R3L-srv>
 <8c03f925-8ca4-688c-569a-a7a449612782@redhat.com>
 <20181114094104.GJ23419@dhcp22.suse.cz>
 <9bb86c98-e062-b045-7c22-6f037bd56f36@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9bb86c98-e062-b045-7c22-6f037bd56f36@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Baoquan He <bhe@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com

On Wed 14-11-18 10:48:09, David Hildenbrand wrote:
> On 14.11.18 10:41, Michal Hocko wrote:
> > On Wed 14-11-18 10:25:57, David Hildenbrand wrote:
> >> On 14.11.18 10:00, Baoquan He wrote:
> >>> Hi David,
> >>>
> >>> On 11/14/18 at 09:18am, David Hildenbrand wrote:
> >>>> Code seems to be waiting for the mem_hotplug_lock in read.
> >>>> We hold mem_hotplug_lock in write whenever we online/offline/add/remove
> >>>> memory. There are two ways to trigger offlining of memory:
> >>>>
> >>>> 1. Offlining via "cat offline > /sys/devices/system/memory/memory0/state"
> >>>>
> >>>> This always properly took the mem_hotplug_lock. Nothing changed
> >>>>
> >>>> 2. Offlining via "cat 0 > /sys/devices/system/memory/memory0/online"
> >>>>
> >>>> This didn't take the mem_hotplug_lock and I fixed that for this release.
> >>>>
> >>>> So if you were testing with 1., you should have seen the same error
> >>>> before this release (unless there is something else now broken in this
> >>>> release).
> >>>
> >>> Thanks a lot for looking into this.
> >>>
> >>> I triggered sysrq+t to check threads' state. You can see that we use
> >>> firmware to trigger ACPI event to go to acpi_bus_offline(), it truly
> >>> didn't take mem_hotplug_lock() and has taken it with your fix in
> >>> commit 381eab4a6ee mm/memory_hotplug: fix online/offline_pages called w.o. mem_hotplug_lock
> >>>
> >>> [  +0.007062] Workqueue: kacpi_hotplug acpi_hotplug_work_fn
> >>> [  +0.005398] Call Trace:
> >>> [  +0.002476]  ? page_vma_mapped_walk+0x307/0x710
> >>> [  +0.004538]  ? page_remove_rmap+0xa2/0x340
> >>> [  +0.004104]  ? ptep_clear_flush+0x54/0x60
> >>> [  +0.004027]  ? enqueue_entity+0x11c/0x620
> >>> [  +0.005904]  ? schedule+0x28/0x80
> >>> [  +0.003336]  ? rmap_walk_file+0xf9/0x270
> >>> [  +0.003940]  ? try_to_unmap+0x9c/0xf0
> >>> [  +0.003695]  ? migrate_pages+0x2b0/0xb90
> >>> [  +0.003959]  ? try_offline_node+0x160/0x160
> >>> [  +0.004214]  ? __offline_pages+0x6ce/0x8e0
> >>> [  +0.004134]  ? memory_subsys_offline+0x40/0x60
> >>> [  +0.004474]  ? device_offline+0x81/0xb0
> >>> [  +0.003867]  ? acpi_bus_offline+0xdb/0x140
> >>> [  +0.004117]  ? acpi_device_hotplug+0x21c/0x460
> >>> [  +0.004458]  ? acpi_hotplug_work_fn+0x1a/0x30
> >>> [  +0.004372]  ? process_one_work+0x1a1/0x3a0
> >>> [  +0.004195]  ? worker_thread+0x30/0x380
> >>> [  +0.003851]  ? drain_workqueue+0x120/0x120
> >>> [  +0.004117]  ? kthread+0x112/0x130
> >>> [  +0.003411]  ? kthread_park+0x80/0x80
> >>> [  +0.005325]  ? ret_from_fork+0x35/0x40
> >>>
> >>
> >> Yes, this is indeed another code path that was fixed (and I didn't
> >> actually realize it ;) ). Thanks for the callchain. Before my fix
> >> hotplug still would have never succeeded (offline_pages would have
> >> silently looped forever) as far as I can tell.
> > 
> > I haven't studied your patch yet so I am not really sure why you have
> > added the lock into this path. The memory hotplug locking is certainly
> > far from great but I believe we should really rething the scope of the
> > lock. There shouldn't be any fundamental reason to use the global lock
> > for the full offlining. So rather than moving the lock from one place to
> > another we need a range locking I believe.
> See the patches for details, the lock was removed on this path by
> mistake not by design.

OK, so I guess we should plug that hole first I guess.

> Replacing the lock by some range lock can now be done. The tricky part
> will be get_online_mems(), we'll have to indicate a range somehow. For
> online/offline/add/remove, we have the range.

I would argue that get_online_mems() needs some rethinking. Callers
shouldn't really care that a node went offline. If they care about the
specific pfn range of the node to not go away then the range locking
should work just fine for them.
-- 
Michal Hocko
SUSE Labs
