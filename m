Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E28806B000D
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 07:17:15 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id q12-v6so7285395plr.17
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 04:17:15 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0101.outbound.protection.outlook.com. [104.47.2.101])
        by mx.google.com with ESMTPS id k6si1821018pgo.689.2018.04.03.04.17.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 04:17:14 -0700 (PDT)
Subject: Re: general protection fault in __mem_cgroup_free
References: <001a113fe4c0a623b10568bb75ea@google.com>
 <20180403093733.GI5501@dhcp22.suse.cz> <20180403094329.GJ5501@dhcp22.suse.cz>
 <20180403105048.GK5501@dhcp22.suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <a91a520d-f56d-56bf-d784-89fb4562ef3c@virtuozzo.com>
Date: Tue, 3 Apr 2018 14:18:00 +0300
MIME-Version: 1.0
In-Reply-To: <20180403105048.GK5501@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, syzbot <syzbot+8a5de3cce7cdc70e9ebe@syzkaller.appspotmail.com>
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com

On 04/03/2018 01:50 PM, Michal Hocko wrote:
> Here we go
> 
> From 38f0f08a3f9f19c106ae53350e43dc97e2e3a4d8 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Tue, 3 Apr 2018 12:40:41 +0200
> Subject: [PATCH] memcg: fix per_node_info cleanup
> 
> syzbot has triggered a NULL ptr dereference when allocation fault
> injection enforces a failure and alloc_mem_cgroup_per_node_info
> initializes memcg->nodeinfo only half way through. __mem_cgroup_free
> still tries to free all per-node data and dereferences pn->lruvec_stat_cpu
> unconditioanlly even if the specific per-node data hasn't been
> initialized.
> 
> The bug is quite unlikely to hit because small allocations do not fail
> and we would need quite some numa nodes to make struct mem_cgroup_per_node
> large enough to cross the costly order.
> 
> Reported-by: syzbot+8a5de3cce7cdc70e9ebe@syzkaller.appspotmail.com
> Fixes: 00f3ca2c2d66 ("mm: memcontrol: per-lruvec stats infrastructure")
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

> ---
>  mm/memcontrol.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e3d5a0a7917f..0a9c4d5194f3 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4340,6 +4340,9 @@ static void free_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
>  {
>  	struct mem_cgroup_per_node *pn = memcg->nodeinfo[node];
>  
> +	if (!pn)
> +		return;
> +
>  	free_percpu(pn->lruvec_stat_cpu);
>  	kfree(pn);
>  }
> 
