Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A72BF6B026F
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 05:01:01 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e12so7485998edd.16
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 02:01:01 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j7si2835652eda.326.2018.11.14.02.01.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 02:01:00 -0800 (PST)
Date: Wed, 14 Nov 2018 11:00:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181114100058.GK23419@dhcp22.suse.cz>
References: <20181114070909.GB2653@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114070909.GB2653@MiWiFi-R3L-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, david@redhat.com, Vladimir Davydov <vdavydov.dev@gmail.com>

[Cc Vladimir]

On Wed 14-11-18 15:09:09, Baoquan He wrote:
> Hi,
> 
> Tested memory hotplug on a bare metal system, hot removing always
> trigger a lock. Usually need hot plug/unplug several times, then the hot
> removing will hang there at the last block. Surely with memory pressure
> added by executing "stress -m 200".
> 
> Will attach the log partly. Any idea or suggestion, appreciated. 
> 
[...]
> [  +0.007169]       Not tainted 4.20.0-rc2+ #4
> [  +0.004630] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [  +0.008001] kworker/181:1   D    0  1187      2 0x80000000
> [  +0.005711] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
> [  +0.006467] Call Trace:
> [  +0.002591]  ? __schedule+0x24e/0x880
> [  +0.004995]  schedule+0x28/0x80
> [  +0.003380]  rwsem_down_read_failed+0x103/0x190
> [  +0.006528]  call_rwsem_down_read_failed+0x14/0x30
> [  +0.004937]  __percpu_down_read+0x4f/0x80
> [  +0.004204]  get_online_mems+0x2d/0x30
> [  +0.003871]  memcg_create_kmem_cache+0x1b/0x120
> [  +0.004740]  memcg_kmem_cache_create_func+0x1b/0x60
> [  +0.004986]  process_one_work+0x1a1/0x3a0
> [  +0.004255]  worker_thread+0x30/0x380
> [  +0.003764]  ? drain_workqueue+0x120/0x120
> [  +0.004238]  kthread+0x112/0x130
> [  +0.003320]  ? kthread_park+0x80/0x80
> [  +0.003796]  ret_from_fork+0x35/0x40

For a quick context. We do hold the exclusive mem hotplug lock
throughout the whole offlining and that can take quite some time.
So I am wondering whether we absolutely have to take the shared lock
in this path (introduced by 03afc0e25f7f ("slab: get_online_mems for
kmem_cache_{create,destroy,shrink}")). Is there any way to relax this
requirement? E.g. nodes stay around even when they are completely
offline. Does that help?
-- 
Michal Hocko
SUSE Labs
