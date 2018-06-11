Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21A196B0003
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 03:35:02 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d20-v6so9840784pfn.16
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 00:35:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c6-v6si21196069plr.398.2018.06.11.00.35.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jun 2018 00:35:00 -0700 (PDT)
Date: Mon, 11 Jun 2018 09:34:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fix null pointer dereference in mem_cgroup_protected
Message-ID: <20180611073458.GD13364@dhcp22.suse.cz>
References: <20180608170607.29120-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180608170607.29120-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>

On Fri 08-06-18 18:06:07, Roman Gushchin wrote:
> Shakeel reported a crash in mem_cgroup_protected(), which
> can be triggered by memcg reclaim if the legacy cgroup v1
> use_hierarchy=0 mode is used:
> 
> [  226.060572] BUG: unable to handle kernel NULL pointer dereference
> at 0000000000000120
> [  226.068310] PGD 8000001ff55da067 P4D 8000001ff55da067 PUD 1fdc7df067 PMD 0
> [  226.075191] Oops: 0000 [#4] SMP PTI
> [  226.078637] CPU: 0 PID: 15581 Comm: bash Tainted: G      D
>  4.17.0-smp-clean #5
> [  226.086635] Hardware name: ...
> [  226.094546] RIP: 0010:mem_cgroup_protected+0x54/0x130
> [  226.099533] Code: 4c 8b 8e 00 01 00 00 4c 8b 86 08 01 00 00 48 8d
> 8a 08 ff ff ff 48 85 d2 ba 00 00 00 00 48 0f 44 ca 48 39 c8 0f 84 cf
> 00 00 00 <48> 8b 81 20 01 00 00 4d 89 ca 4c 39 c8 4c 0f 46 d0 4d 85 d2
> 74 05
> [  226.118194] RSP: 0000:ffffabe64dfafa58 EFLAGS: 00010286
> [  226.123358] RAX: ffff9fb6ff03d000 RBX: ffff9fb6f5b1b000 RCX: 0000000000000000
> [  226.130406] RDX: 0000000000000000 RSI: ffff9fb6f5b1b000 RDI: ffff9fb6f5b1b000
> [  226.137454] RBP: ffffabe64dfafb08 R08: 0000000000000000 R09: 0000000000000000
> [  226.144503] R10: 0000000000000000 R11: 000000000000c800 R12: ffffabe64dfafb88
> [  226.151551] R13: ffff9fb6f5b1b000 R14: ffffabe64dfafb88 R15: ffff9fb77fffe000
> [  226.158602] FS:  00007fed1f8ac700(0000) GS:ffff9fb6ff400000(0000)
> knlGS:0000000000000000
> [  226.166594] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  226.172270] CR2: 0000000000000120 CR3: 0000001fdcf86003 CR4: 00000000001606f0
> [  226.179317] Call Trace:
> [  226.181732]  ? shrink_node+0x194/0x510
> [  226.185435]  do_try_to_free_pages+0xfd/0x390
> [  226.189653]  try_to_free_mem_cgroup_pages+0x123/0x210
> [  226.194643]  try_charge+0x19e/0x700
> [  226.198088]  mem_cgroup_try_charge+0x10b/0x1a0
> [  226.202478]  wp_page_copy+0x134/0x5b0
> [  226.206094]  do_wp_page+0x90/0x460
> [  226.209453]  __handle_mm_fault+0x8e3/0xf30
> [  226.213498]  handle_mm_fault+0xfe/0x220
> [  226.217285]  __do_page_fault+0x262/0x500
> [  226.221158]  do_page_fault+0x28/0xd0
> [  226.224689]  ? page_fault+0x8/0x30
> [  226.228048]  page_fault+0x1e/0x30
> [  226.231323] RIP: 0033:0x485b72
> 
> The problem happens because parent_mem_cgroup() returns a NULL
> pointer, which is dereferenced later without a check.
> 
> As cgroup v1 has no memory guarantee support, let's make
> mem_cgroup_protected() immediately return MEMCG_PROT_NONE,
> if the given cgroup has no parent (non-hierarchical mode is used).
> 

Fixes: bf8d5d52ffe8 ("memcg: introduce memory.min")

I guess.

> Reported-by: Shakeel Butt <shakeelb@google.com>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Michal Hocko <mhocko@suse.com>

I really do not see why the whole min limit thing had to be rushed into
mainline. It has clearly not been tested for all configurations. Sigh...

> ---
>  mm/memcontrol.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6c9fb4e47be3..6205ba512928 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5750,6 +5750,9 @@ enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
>  	elow = memcg->memory.low;
>  
>  	parent = parent_mem_cgroup(memcg);
> +	if (!parent)
> +		return MEMCG_PROT_NONE;
> +

This deserves a comment.
	/* No parent means a non-hierarchical mode on v1 memcg */

>  	if (parent == root_mem_cgroup)
>  		goto exit;
>  
> -- 
> 2.14.3

-- 
Michal Hocko
SUSE Labs
