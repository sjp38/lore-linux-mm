Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id C1DA66B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 12:01:30 -0400 (EDT)
Received: by qgh3 with SMTP id 3so37689202qgh.2
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 09:01:30 -0700 (PDT)
Received: from mail-qg0-x22e.google.com (mail-qg0-x22e.google.com. [2607:f8b0:400d:c04::22e])
        by mx.google.com with ESMTPS id b136si2578119qka.31.2015.03.25.09.01.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 09:01:24 -0700 (PDT)
Received: by qgf60 with SMTP id 60so35547475qgf.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 09:01:23 -0700 (PDT)
Date: Wed, 25 Mar 2015 12:01:15 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET 1/3 v2 block/for-4.1/core] writeback: cgroup writeback
 support
Message-ID: <20150325160115.GR3880@htj.duckdns.org>
References: <1427086499-15657-1-git-send-email-tj@kernel.org>
 <20150325154022.GC29728@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150325154022.GC29728@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

Hello, Vivek.

On Wed, Mar 25, 2015 at 11:40:22AM -0400, Vivek Goyal wrote:
> I have 32G of RAM on my system and I setup a write bandwidth of 1MB/s
> on the disk and allowed a dd to run. That dd quickly consumed 5G of
> page cache before it reached to a steady state. Sounds like too much
> of cache consumption which will be drained at a speed of 1MB/s. Not
> sure if this is expected or bdi back-pressure is not being applied soon
> enough.

Ooh, the system will happily dirty certain amount of memory regardless
of the writeback speed.  The default is bg_thresh 10% and thresh 20%
which puts the target ratio at 15%.  On a 32G system this is ~4.8G, so
sounds about right.  This is intentional as otherwise we may end up
threshing worloads which can perfectly fit in the memory due to slow
backing device.  e.g. a workload which has 4G dirty footprint would
work perfectly fine in the above setup regardless of the speed of the
backing device.  If we capped dirty memory at, say, 120s of write
bandwidth, which is 120MB in this case, that workload would suffer
horribly for no good reason.

The proportional distribution of dirty pages is really just
proportional.  If you don't have higher bw backing device active on
the system, whatever is active, however slow that may be, get to
consume the entirety of the allowable dirty memory.  This doesn't
necessarily make sense for things like USB sticks, so we have per-bdi
max_ratio which can be set from userland for devices which aren't
supposed to host those sort of workloads (as you aren't gonna run a DB
workload on your thumbdrive).

So, that's where that 5G amount came from, but while you're
excercising cgroup writeback path, it isn't really doing anything
differently from before if you don't configure memcg limits.  This is
the same behavior which would happen in the global case.  Try to
configure different cgroups w/ different memory limits and write to
devices with differing write speeds.  They all will converge to ~15%
of the allowable memory in each cgroup and the dirty pages in each
cgroup will be distributed according to each device's writeback speed
in that cgroup.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
