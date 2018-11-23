Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2F866B3034
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 03:42:05 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id q64so3841756pfa.18
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 00:42:05 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t19si36339301pgk.163.2018.11.23.00.42.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 00:42:04 -0800 (PST)
Date: Fri, 23 Nov 2018 09:42:01 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2] mm, hotplug: move init_currently_empty_zone() under
 zone_span_lock protection
Message-ID: <20181123084201.GA8625@dhcp22.suse.cz>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181122101241.7965-1-richard.weiyang@gmail.com>
 <18088694-22c8-b09b-f500-4932b6199004@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <18088694-22c8-b09b-f500-4932b6199004@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu 22-11-18 16:26:40, David Hildenbrand wrote:
> On 22.11.18 11:12, Wei Yang wrote:
> > During online_pages phase, pgdat->nr_zones will be updated in case this
> > zone is empty.
> > 
> > Currently the online_pages phase is protected by the global lock
> > mem_hotplug_begin(), which ensures there is no contention during the
> > update of nr_zones. But this global lock introduces scalability issues.
> > 
> > This patch is a preparation for removing the global lock during
> > online_pages phase. Also this patch changes the documentation of
> > node_size_lock to include the protectioin of nr_zones.
> 
> I looked into locking recently, and there is more to it.
> 
> Please read:
> 
> commit dee6da22efac451d361f5224a60be2796d847b51
> Author: David Hildenbrand <david@redhat.com>
> Date:   Tue Oct 30 15:10:44 2018 -0700
> 
>     memory-hotplug.rst: add some details about locking internals
>     
>     Let's document the magic a bit, especially why device_hotplug_lock is
>     required when adding/removing memory and how it all play together with
>     requests to online/offline memory from user space.
> 
> Short summary: Onlining/offlining of memory requires the device_hotplug_lock
> as of now.

Well, I would tend to disagree here. You might be describing the current
state of art but the device_hotplug_lock doesn't make much sense for the
memory hotplug in principle. There is absolutely nothing in the core MM
that would require this lock. The current state just uses a BKL in some
sense and we really want to get rid of that longterm. This patch is a tiny
step in that direction and I suspect many more will need to come on the
way. We really want to end up with a clear scope of each lock being
taken. A project for a brave soul...

-- 
Michal Hocko
SUSE Labs
