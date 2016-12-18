Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 57BBD6B0253
	for <linux-mm@kvack.org>; Sun, 18 Dec 2016 11:37:30 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i131so15930152wmf.3
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 08:37:30 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id l66si11708379wml.44.2016.12.18.08.37.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Dec 2016 08:37:28 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id g23so14498476wme.1
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 08:37:28 -0800 (PST)
Date: Sun, 18 Dec 2016 17:37:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
Message-ID: <20161218163727.GC8440@dhcp22.suse.cz>
References: <20161216073941.GA26976@dhcp22.suse.cz>
 <20161216155808.12809-1-mhocko@kernel.org>
 <20161216155808.12809-3-mhocko@kernel.org>
 <20161216173151.GA23182@cmpxchg.org>
 <20161216221202.GE7645@dhcp22.suse.cz>
 <18652e94-8f5c-dcf1-16e6-0deab6c642ec@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <18652e94-8f5c-dcf1-16e6-0deab6c642ec@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Nils Holland <nholland@tisys.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Sat 17-12-16 20:17:07, Tetsuo Handa wrote:
[...]
> I feel that allowing access to memory reserves based on __GFP_NOFAIL might not
> make sense. My understanding is that actual I/O operation triggered by I/O
> requests by filesystem code are processed by other threads. Even if we grant
> access to memory reserves to GFP_NOFS | __GFP_NOFAIL allocations by fs code,
> I think that it is possible that memory allocations by underlying bio code
> fails to make a further progress unless memory reserves are granted as well.

IO layer should rely on mempools to guarantee a forward progress.

> Below is a typical trace which I observe under OOM lockuped situation (though
> this trace is from an OOM stress test using XFS).
> 
> ----------------------------------------
> [ 1845.187246] MemAlloc: kworker/2:1(14498) flags=0x4208060 switches=323636 seq=48 gfp=0x2400000(GFP_NOIO) order=0 delay=430400 uninterruptible
> [ 1845.187248] kworker/2:1     D12712 14498      2 0x00000080
> [ 1845.187251] Workqueue: events_freezable_power_ disk_events_workfn
> [ 1845.187252] Call Trace:
> [ 1845.187253]  ? __schedule+0x23f/0xba0
> [ 1845.187254]  schedule+0x38/0x90
> [ 1845.187255]  schedule_timeout+0x205/0x4a0
> [ 1845.187256]  ? del_timer_sync+0xd0/0xd0
> [ 1845.187257]  schedule_timeout_uninterruptible+0x25/0x30
> [ 1845.187258]  __alloc_pages_nodemask+0x1035/0x10e0
> [ 1845.187259]  ? alloc_request_struct+0x14/0x20
> [ 1845.187261]  alloc_pages_current+0x96/0x1b0
> [ 1845.187262]  ? bio_alloc_bioset+0x20f/0x2e0
> [ 1845.187264]  bio_copy_kern+0xc4/0x180
> [ 1845.187265]  blk_rq_map_kern+0x6f/0x120
> [ 1845.187268]  __scsi_execute.isra.23+0x12f/0x160
> [ 1845.187270]  scsi_execute_req_flags+0x8f/0x100
> [ 1845.187271]  sr_check_events+0xba/0x2b0 [sr_mod]
> [ 1845.187274]  cdrom_check_events+0x13/0x30 [cdrom]
> [ 1845.187275]  sr_block_check_events+0x25/0x30 [sr_mod]
> [ 1845.187276]  disk_check_events+0x5b/0x150
> [ 1845.187277]  disk_events_workfn+0x17/0x20
> [ 1845.187278]  process_one_work+0x1fc/0x750
> [ 1845.187279]  ? process_one_work+0x167/0x750
> [ 1845.187279]  worker_thread+0x126/0x4a0
> [ 1845.187280]  kthread+0x10a/0x140
> [ 1845.187281]  ? process_one_work+0x750/0x750
> [ 1845.187282]  ? kthread_create_on_node+0x60/0x60
> [ 1845.187283]  ret_from_fork+0x2a/0x40
> ----------------------------------------
> 
> I think that this GFP_NOIO allocation request needs to consume more memory reserves
> than GFP_NOFS allocation request to make progress. 

AFAIU, this is an allocation path which doesn't block a forward progress
on a regular IO. It is merely a check whether there is a new medium in
the CDROM (aka regular polling of the device). I really fail to see any
reason why this one should get any access to memory reserves at all.

I actually do not see any reason why it should be NOIO in the first
place but I am not familiar with this code much so there might be some
reasons for that. The fact that it might stall under a heavy memory
pressure is sad but who actually cares?

> Do we want to add __GFP_NOFAIL to this GFP_NOIO allocation request
> in order to allow access to memory reserves as well as GFP_NOFS |
> __GFP_NOFAIL allocation request?

Why?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
