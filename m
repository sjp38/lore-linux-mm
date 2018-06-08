Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 191BC6B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 13:09:29 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g78-v6so1256597wmg.9
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 10:09:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o20-v6sor544727wmc.74.2018.06.08.10.09.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Jun 2018 10:09:27 -0700 (PDT)
MIME-Version: 1.0
References: <20180608170607.29120-1-guro@fb.com>
In-Reply-To: <20180608170607.29120-1-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 8 Jun 2018 10:09:14 -0700
Message-ID: <CALvZod5Ci-eNjp0y+tN-GF-B_Nsknjtv_mdm4QZJYh1P9Y7Oqg@mail.gmail.com>
Subject: Re: [PATCH] mm: fix null pointer dereference in mem_cgroup_protected
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, kernel-team@fb.com, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Fri, Jun 8, 2018 at 10:06 AM Roman Gushchin <guro@fb.com> wrote:
>
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
> Reported-by: Shakeel Butt <shakeelb@google.com>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Tested-by: Shakeel Butt <shakeelb@google.com>

> ---
>  mm/memcontrol.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6c9fb4e47be3..6205ba512928 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5750,6 +5750,9 @@ enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
>         elow = memcg->memory.low;
>
>         parent = parent_mem_cgroup(memcg);
> +       if (!parent)
> +               return MEMCG_PROT_NONE;
> +
>         if (parent == root_mem_cgroup)
>                 goto exit;
>
> --
> 2.14.3
>
