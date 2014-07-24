Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 36C016B0035
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 09:16:01 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id w61so2699271wes.11
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 06:15:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mu3si11982488wic.38.2014.07.24.06.15.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 06:15:46 -0700 (PDT)
Date: Thu, 24 Jul 2014 15:15:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [Bug 80881] New: Memory cgroup OOM leads to BUG: unable to
 handle kernel paging request at ffffffffffffffd8
Message-ID: <20140724131535.GD14578@dhcp22.suse.cz>
References: <bug-80881-27@https.bugzilla.kernel.org/>
 <20140722130741.ca2f6c24d06fffc7d7549e95@linux-foundation.org>
 <20140724120959.GC14578@dhcp22.suse.cz>
 <20140724123456.GJ1725@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140724123456.GJ1725@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Paul Furtado <paulfurtado91@gmail.com>

On Thu 24-07-14 08:34:56, Johannes Weiner wrote:
[...]
> Would it be better to move mem_cgroup_oom_notify() directly into the
> trylock function while the memcg_oom_lock is still held?

I don't know. It sounds like mixing two things together. I would rather
keep them separate unless we have a good reason to do otherwise. Sharing
the same lock is just a coincidence mostly required for the registration
code to not miss event.

> > Let's go with simpler route for now as this is not a hot path, though.
> > ---
> > >From 2c2642dbfb3f7d8c9f20f7793850426daa770078 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Thu, 24 Jul 2014 14:00:39 +0200
> > Subject: [PATCH] memcg: oom_notify use-after-free fix
> > 
> > Paul Furtado has reported the following GPF:
> > general protection fault: 0000 [#1] SMP
> > Modules linked in: ipv6 dm_mod xen_netfront coretemp hwmon x86_pkg_temp_thermal crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel ablk_helper cryptd lrw gf128mul glue_helper aes_x86_64 microcode pcspkr ext4 jbd2 mbcache raid0 xen_blkfront
> > CPU: 3 PID: 3062 Comm: java Not tainted 3.16.0-rc5 #1
> > task: ffff8801cfe8f170 ti: ffff8801d2ec4000 task.ti: ffff8801d2ec4000
> > RIP: e030:[<ffffffff811c0b80>]  [<ffffffff811c0b80>] mem_cgroup_oom_synchronize+0x140/0x240
> > RSP: e02b:ffff8801d2ec7d48  EFLAGS: 00010283
> > RAX: 0000000000000001 RBX: ffff88009d633800 RCX: 000000000000000e
> > RDX: fffffffffffffffe RSI: ffff88009d630200 RDI: ffff88009d630200
> > RBP: ffff8801d2ec7da8 R08: 0000000000000012 R09: 00000000fffffffe
> > R10: 0000000000000000 R11: 0000000000000000 R12: ffff88009d633800
> > R13: ffff8801d2ec7d48 R14: dead000000100100 R15: ffff88009d633a30
> > FS:  00007f1748bb4700(0000) GS:ffff8801def80000(0000) knlGS:0000000000000000
> > CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
> > CR2: 00007f4110300308 CR3: 00000000c05f7000 CR4: 0000000000002660
> > Stack:
> >  ffff88009d633800 0000000000000000 ffff8801cfe8f170 ffffffff811bae10
> >  ffffffff81ca73f8 ffffffff81ca73f8 ffff8801d2ec7dc8 0000000000000006
> >  00000000e3b30000 00000000e3b30000 ffff8801d2ec7f58 0000000000000001
> > Call Trace:
> >  [<ffffffff811bae10>] ? mem_cgroup_wait_acct_move+0x110/0x110
> >  [<ffffffff81159628>] pagefault_out_of_memory+0x18/0x90
> >  [<ffffffff8105cee9>] mm_fault_error+0xa9/0x1a0
> >  [<ffffffff8105d488>] __do_page_fault+0x478/0x4c0
> >  [<ffffffff81004f00>] ? xen_mc_flush+0xb0/0x1b0
> >  [<ffffffff81003ab3>] ? xen_write_msr_safe+0xa3/0xd0
> >  [<ffffffff81012a40>] ? __switch_to+0x2d0/0x600
> >  [<ffffffff8109e273>] ? finish_task_switch+0x53/0xf0
> >  [<ffffffff81643b0a>] ? __schedule+0x37a/0x6d0
> >  [<ffffffff8105d5dc>] do_page_fault+0x2c/0x40
> >  [<ffffffff81649858>] page_fault+0x28/0x30
> > Code: 44 00 00 48 89 df e8 40 ca ff ff 48 85 c0 49 89 c4 74 35 4c 8b b0 30 02 00 00 4c 8d b8 30 02 00 00 4d 39 fe 74 1b 0f 1f 44 00 00 <49> 8b 7e 10 be 01 00 00 00 e8 42 d2 04 00 4d 8b 36 4d 39 fe 75
> > RIP  [<ffffffff811c0b80>] mem_cgroup_oom_synchronize+0x140/0x240
> >  RSP <ffff8801d2ec7d48>
> > ---[ end trace 050b00c5503ce96a ]---
> > 
> > fb2a6fc56be6 (mm: memcg: rework and document OOM waiting and wakeup) has
> > moved mem_cgroup_oom_notify outside of memcg_oom_lock assuming it is
> > protected by the hierarchical OOM-lock. Although this is true for the
> > notification part the protection doesn't cover unregistration of event
> > which can happen in parallel now so mem_cgroup_oom_notify can see
> > already unlinked and/or freed mem_cgroup_eventfd_list.
> > 
> > Fix this by using memcg_oom_lock also in mem_cgroup_oom_notify.
> > 
> > Reported-by: Paul Furtado <paulfurtado91@gmail.com>
> > Fixes: fb2a6fc56be6 (mm: memcg: rework and document OOM waiting and wakeup)
> > Cc: stable@vger.kernel.org # 3.12+
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
