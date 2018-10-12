Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0733A6B0006
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 08:09:03 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g28-v6so6870985edc.18
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 05:09:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d7-v6si1021072edq.144.2018.10.12.05.09.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 05:09:01 -0700 (PDT)
Date: Fri, 12 Oct 2018 14:08:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] memcg, oom: throttle dump_header for memcg ooms
 without eligible tasks
Message-ID: <20181012120858.GX5873@dhcp22.suse.cz>
References: <000000000000dc48d40577d4a587@google.com>
 <20181010151135.25766-1-mhocko@kernel.org>
 <20181012112008.GA27955@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181012112008.GA27955@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, penguin-kernel@i-love.sakura.ne.jp, rientjes@google.com, yang.s@alibaba-inc.com

On Fri 12-10-18 07:20:08, Johannes Weiner wrote:
> On Wed, Oct 10, 2018 at 05:11:35PM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > syzbot has noticed that it can trigger RCU stalls from the memcg oom
> > path:
> > RIP: 0010:dump_stack+0x358/0x3ab lib/dump_stack.c:118
> > Code: 74 0c 48 c7 c7 f0 f5 31 89 e8 9f 0e 0e fa 48 83 3d 07 15 7d 01 00 0f
> > 84 63 fe ff ff e8 1c 89 c9 f9 48 8b bd 70 ff ff ff 57 9d <0f> 1f 44 00 00
> > e8 09 89 c9 f9 48 8b 8d 68 ff ff ff b8 ff ff 37 00
> > RSP: 0018:ffff88017d3a5c70 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff13
> > RAX: 0000000000040000 RBX: 1ffffffff1263ebe RCX: ffffc90001e5a000
> > RDX: 0000000000040000 RSI: ffffffff87b4e0f4 RDI: 0000000000000246
> > RBP: ffff88017d3a5d18 R08: ffff8801d7e02480 R09: fffffbfff13da030
> > R10: fffffbfff13da030 R11: 0000000000000003 R12: 1ffff1002fa74b96
> > R13: 00000000ffffffff R14: 0000000000000200 R15: 0000000000000000
> >   dump_header+0x27b/0xf72 mm/oom_kill.c:441
> >   out_of_memory.cold.30+0xf/0x184 mm/oom_kill.c:1109
> >   mem_cgroup_out_of_memory+0x15e/0x210 mm/memcontrol.c:1386
> >   mem_cgroup_oom mm/memcontrol.c:1701 [inline]
> >   try_charge+0xb7c/0x1710 mm/memcontrol.c:2260
> >   mem_cgroup_try_charge+0x627/0xe20 mm/memcontrol.c:5892
> >   mem_cgroup_try_charge_delay+0x1d/0xa0 mm/memcontrol.c:5907
> >   shmem_getpage_gfp+0x186b/0x4840 mm/shmem.c:1784
> >   shmem_fault+0x25f/0x960 mm/shmem.c:1982
> >   __do_fault+0x100/0x6b0 mm/memory.c:2996
> >   do_read_fault mm/memory.c:3408 [inline]
> >   do_fault mm/memory.c:3531 [inline]
> > 
> > The primary reason of the stall lies in an expensive printk handling
> > of oom report flood because a misconfiguration on the syzbot side
> > caused that there is simply no eligible task because they have
> > OOM_SCORE_ADJ_MIN set. This generates the oom report for each allocation
> > from the memcg context.
> > 
> > While normal workloads should be much more careful about potential heavy
> > memory consumers that are OOM disabled it makes some sense to rate limit
> > a potentially expensive oom reports for cases when there is no eligible
> > victim found. Do that by moving the rate limit logic inside dump_header.
> > We no longer rely on the caller to do that. It was only oom_kill_process
> > which has been throttling. Other two call sites simply didn't have to
> > care because one just paniced on the OOM when configured that way and
> > no eligible task would panic for the global case as well. Memcg changed
> > the picture because we do not panic and we might have multiple sources
> > of the same event.
> > 
> > Once we are here, make sure that the reason to trigger the OOM is
> > printed without ratelimiting because this is really valuable to
> > debug what happened.
> > 
> > Reported-by: syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com
> > Cc: guro@fb.com
> > Cc: hannes@cmpxchg.org
> > Cc: kirill.shutemov@linux.intel.com
> > Cc: linux-kernel@vger.kernel.org
> > Cc: penguin-kernel@i-love.sakura.ne.jp
> > Cc: rientjes@google.com
> > Cc: yang.s@alibaba-inc.com
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> So not more than 10 dumps in each 5s interval. That looks reasonable
> to me. By the time it starts dropping data you have more than enough
> information to go on already.

Yeah. Unless we have a storm coming from many different cgroups in
parallel. But even then we have the allocation context for each OOM so
we are not losing everything. Should we ever tune this, it can be done
later with some explicit examples.

> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks! I will post the patch to Andrew early next week.
-- 
Michal Hocko
SUSE Labs
