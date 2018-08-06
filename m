Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4736B0008
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 16:06:40 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c2-v6so4577479edi.20
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 13:06:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f5-v6si1455967edj.330.2018.08.06.13.06.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 13:06:39 -0700 (PDT)
Date: Mon, 6 Aug 2018 22:06:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: memcg: update memcg OOM messages on cgroup2
Message-ID: <20180806200637.GJ10003@dhcp22.suse.cz>
References: <20180803175743.GW1206094@devbig004.ftw2.facebook.com>
 <20180806161529.GA410235@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180806161529.GA410235@devbig004.ftw2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Mon 06-08-18 09:15:29, Tejun Heo wrote:
> mem_cgroup_print_oom_info() currently prints the same info for cgroup1
> and cgroup2 OOMs.  It doesn't make much sense on cgroup2, which
> doesn't use memsw or separate kmem accounting - the information
> reported is both superflous and insufficient.  This patch updates the
> memcg OOM messages on cgroup2 so that
> 
> * It prints memory and swap usages and limits used on cgroup2.
> 
> * It shows the same information as memory.stat.
> 
> I took out the recursive printing for cgroup2 because the amount of
> output could be a lot and the benefits aren't clear.  An example dump
> follows.
> 
> [   40.854197] stress invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oo0
> [   40.855239] stress cpuset=/ mems_allowed=0
> [   40.855665] CPU: 6 PID: 1990 Comm: stress Not tainted 4.18.0-rc7-work+ #281
> [   40.856260] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.0-2.el7 04/01/2014
> [   40.857000] Call Trace:
> [   40.857222]  dump_stack+0x5e/0x8b
> [   40.857517]  dump_header+0x74/0x2fc
> [   40.859106]  oom_kill_process+0x225/0x490
> [   40.859449]  out_of_memory+0x111/0x530
> [   40.859780]  mem_cgroup_out_of_memory+0x4b/0x80
> [   40.860161]  mem_cgroup_oom_synchronize+0x3ff/0x450
> [   40.861334]  pagefault_out_of_memory+0x2f/0x74
> [   40.861718]  __do_page_fault+0x3de/0x460
> [   40.862347]  page_fault+0x1e/0x30
> [   40.862636] RIP: 0033:0x5566cd5aadd0
> [   40.862940] Code: 0f 84 3c 02 00 00 8b 54 24 0c 31 c0 85 d2 0f 94 c0 89 04 24 41 83 fd 02 0f 8f f6
> [   40.864558] RSP: 002b:00007ffd979ced40 EFLAGS: 00010206
> [   40.865005] RAX: 0000000001f4f000 RBX: 00007f3a397d8010 RCX: 00007f3a397d8010
> [   40.865615] RDX: 0000000000000000 RSI: 0000000004001000 RDI: 0000000000000000
> [   40.866220] RBP: 00005566cd5abbb4 R08: 00000000ffffffff R09: 0000000000000000
> [   40.866845] R10: 0000000000000022 R11: 0000000000000246 R12: ffffffffffffffff
> [   40.867452] R13: 0000000000000002 R14: 0000000000001000 R15: 0000000004000000
> [   40.868091] Task in /test-cgroup killed as a result of limit of /test-cgroup
> [   40.868726] memory 33554432 (max 33554432)
> [   40.869096] swap 0
> [   40.869280] anon 32845824
> [   40.869519] file 0
> [   40.869730] kernel_stack 0
> [   40.869966] slab 163840
> [   40.870191] sock 0
> [   40.870374] shmem 0
> [   40.870566] file_mapped 0
> [   40.870801] file_dirty 0
> [   40.871039] file_writeback 0
> [   40.871292] inactive_anon 0
> [   40.871542] active_anon 32944128
> [   40.871821] inactive_file 0
> [   40.872077] active_file 0
> [   40.872309] unevictable 0
> [   40.872543] slab_reclaimable 0
> [   40.872806] slab_unreclaimable 163840
> [   40.873136] pgfault 8085
> [   40.873358] pgmajfault 0
> [   40.873589] pgrefill 0
> [   40.873800] pgscan 0
> [   40.873991] pgsteal 0
> [   40.874202] pgactivate 0
> [   40.874424] pgdeactivate 0
> [   40.874663] pglazyfree 0
> [   40.874881] pglazyfreed 0
> [   40.875121] workingset_refault 0
> [   40.875401] workingset_activate 0
> [   40.875689] workingset_nodereclaim 0

Is there really any reason to have each couner on a seprate line? This
is just too much of an output for a single oom report. I do get why you
are not really thrilled by the hierarchical numbers but can we keep
counters in a single line please?
-- 
Michal Hocko
SUSE Labs
