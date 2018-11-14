Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 92C4F6B0284
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 04:01:37 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x1-v6so7748546edh.8
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 01:01:37 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i59-v6si24500edc.292.2018.11.14.01.01.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 01:01:35 -0800 (PST)
Date: Wed, 14 Nov 2018 10:01:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181114090134.GG23419@dhcp22.suse.cz>
References: <20181114070909.GB2653@MiWiFi-R3L-srv>
 <5a6c6d6b-ebcd-8bfa-d6e0-4312bfe86586@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5a6c6d6b-ebcd-8bfa-d6e0-4312bfe86586@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Baoquan He <bhe@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com

On Wed 14-11-18 09:18:09, David Hildenbrand wrote:
> On 14.11.18 08:09, Baoquan He wrote:
> > Hi,
> > 
> > Tested memory hotplug on a bare metal system, hot removing always
> > trigger a lock. Usually need hot plug/unplug several times, then the hot
> > removing will hang there at the last block. Surely with memory pressure
> > added by executing "stress -m 200".
> > 
> > Will attach the log partly. Any idea or suggestion, appreciated. 
> > 
> > Thanks
> > Baoquan
> > 
> 
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

This discrepancy should go.

> So if you were testing with 1., you should have seen the same error
> before this release (unless there is something else now broken in this
> release).
> 
> 
> The real question is, however, why offlining of the last block doesn't
> succeed. In __offline_pages() we basically have an endless loop (while
> holding the mem_hotplug_lock in write). Now I consider this piece of
> code very problematic (we should automatically fail after X
> attempts/after X seconds, we should not ignore -ENOMEM), and we've had
> other BUGs whereby we would run into an endless loop here (e.g. related
> to hugepages I guess).

We used to have number of retries previous and it was too fragile. If
you need a timeout then you can easily do that from userspace. Just do
timeout $TIME echo 0 > $MEM_PATH/online

I have seen an issue when the migration cannot make a forward progress
because of a glibc page with a reference count bumping up and down. Most
probable explanation is the faultaround code. I am working on this and
will post a patch soon. In any case the migration should converge and if
it doesn't do then there is a bug lurking somewhere.

Failing on ENOMEM is a questionable thing. I haven't seen that happening
wildly but if it is a case then I wouldn't be opposed.

> You mentioned memory pressure, if our host is under memory pressure we
> can easily trigger running into an endless loop there, because we
> basically ignore -ENOMEM e.g. when we cannot get a page to migrate some
> memory to be offlined. I assume this is the case here.
> do_migrate_range() could be the bad boy if it keeps failing forever and
> we keep retrying.

My hotplug debugging patches [1] should help to tell us.

[1] http://lkml.kernel.org/r/20181107101830.17405-1-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs
