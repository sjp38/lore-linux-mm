Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E044C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:48:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB9782083B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:48:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Q6QDxp4g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB9782083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EB636B0005; Thu, 20 Jun 2019 11:48:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69BFA8E0002; Thu, 20 Jun 2019 11:48:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B1F08E0001; Thu, 20 Jun 2019 11:48:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3C28A6B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 11:48:14 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id b75so3338284ywh.8
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 08:48:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=iCLF3w7Rvl9XKP5ezt5wuQDWbrChP9wAnz7WglcxIZM=;
        b=fFZZP7cPlZ8c2UYoOmNqb1tHOn5BqGmYbTiSMx71gZnxTqtkzOuVAoJTw/s907Df4D
         2fadQVHUQG9jGdVd0CjdKXmrpd2Q7ZJz7Q5qB5s00wnQu7B8CjSeVA48Zsv+1EpNYJkx
         H4LKfst8iOgFlTYLSvGauUrBUD05yrX8UJarlinsw6wBQ1C05TmdFFNrnp8CyTHRicc/
         JOGyocEyICsc8j6o2RwHIFwsSaLgoUodAI7IlfGsIlaJmXzvvB/xANXnA26AJL4KPHzM
         lBhEMy4eyPVbwfa2FNk3f07ngFguqfjdK636vbrU1d58KyyPm4aBcRRJUEYigiv2HrwR
         EGkA==
X-Gm-Message-State: APjAAAVoJvUZelsczLlE4uMKlXaIFJQ4MHJTKycn7QmTI+iPp1HCG7oU
	ifN5KlsLcN+hw/kc8TP3H3wRkDIwcFbtl74mcHf7z5vmGcXnHERWdrhE5HNO6l0VqxOM4+bV2Xp
	ZGRAaKW6N7HGnWurFpHT0z82HrayP8eDEBYNvrdGybbYNPx0klDgiphhx+9ZYapa8HA==
X-Received: by 2002:a81:52c8:: with SMTP id g191mr5301254ywb.262.1561045693893;
        Thu, 20 Jun 2019 08:48:13 -0700 (PDT)
X-Received: by 2002:a81:52c8:: with SMTP id g191mr5301221ywb.262.1561045693070;
        Thu, 20 Jun 2019 08:48:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561045693; cv=none;
        d=google.com; s=arc-20160816;
        b=o8u+ZzTsqP7ngMJ4LdpuzKReHpSsUXrD1vtkHb3ERsmRRVsTHnlHsnL94Yb5jy+ggV
         VMZUWp25/0DAv4H8ap0l76KsdKXfvBDGF8sNGhMH5iMWV33BgIoujoiFoU8hq5sYibal
         AqLn+da6yU5sfuS51Tsl5Mr3323TEv/78UHRfnDDPjzqQw6O8/ea00f+DHBxHu5vRlao
         8SaEzHUxFyddHfDv8JyM+uDsG1LmH67HO1hdibWr/yFD/jyiwIRnztId+vgtXCi0rKsB
         ce9Jygdd03wTvZpvkYBCtwag/F/+rfP/f39W1G56uFUBQbhjUM7hQteHdLVjcoQbPukT
         BKcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=iCLF3w7Rvl9XKP5ezt5wuQDWbrChP9wAnz7WglcxIZM=;
        b=NURXzJ7yf7INnyfBzlAIM7hyEyxvm+vFCRqVNX6fNvLmA9/YzBHwBVeUHC9GIU92pY
         njDk5HFy+vIufr5TijtrCQjLZfW58GUnY0rZ29UEA6Aq0eNpjf8YTRSgAwE5hybAAyiY
         WDKq6kdcRO4e4LkU+e1lQH3dagwU0r21SlG+BK5vM5t2CkDqgLQQNKqs/FDUUoWjyfiW
         eGokMIednGVOeQQuZ2mz5pE4ij0kg2NcIdfkN2WiC0Bu/7MCf3L7LNHx/EnFf7Z1An8K
         lBlDNbkL3CF98WTkAuKD/tJoXnVZCulXd5rcY+5L+jWjefBex8P9LYwkgW8lQFcSeiyL
         DYrw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Q6QDxp4g;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 81sor939739yws.82.2019.06.20.08.48.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 08:48:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Q6QDxp4g;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=iCLF3w7Rvl9XKP5ezt5wuQDWbrChP9wAnz7WglcxIZM=;
        b=Q6QDxp4gp/spAAY1x6Si9KfHY3KLyGGQmfOr0fRfZFp00TC0d65nROUC5a7YBUN8Qw
         7HS034aNDgyD3FwthRpiDcOFgBXxardG+/rIAzg0tYNNvj21W7c5GcQRRgjnqT/Akoex
         evDrhEdkqCvBhHwUbFsjCQb1Ulub+cK2qAI6R7g8aOjPFrSww8kjIuixDgkoCRx7bCOB
         VY4DpHgIoYkJJUAOzDC06eakRdCp+BX7NBeRIeKUQerccMdCTe0NsAms+yCAhENa5a6r
         ZhO9pby6MQ8Xmo6Won0/3Padf7waqlezL7Ik1ky1nm/OixVN2DscttKVKgwfJwyjPjK4
         jjAA==
X-Google-Smtp-Source: APXvYqycBkM3JbJwuXx7GyrkR4kR1O3Tg5R2peMGdSnGcGwIaVGmgpHpUZhpezQ+nTO2od6oR6jsisdDUWt7A+16WAY=
X-Received: by 2002:a81:4c44:: with SMTP id z65mr5090029ywa.4.1561045691785;
 Thu, 20 Jun 2019 08:48:11 -0700 (PDT)
MIME-Version: 1.0
References: <20190620015554.1888119-1-guro@fb.com>
In-Reply-To: <20190620015554.1888119-1-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 20 Jun 2019 08:48:00 -0700
Message-ID: <CALvZod6MzPvX67AxrGddNWhr99oVY7_v6tXh_7yXdf-g24b6nQ@mail.gmail.com>
Subject: Re: [PATCH] mm: memcg/slab: properly handle kmem_caches reparented to root_mem_cgroup
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Kernel Team <kernel-team@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Waiman Long <longman@redhat.com>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 6:57 PM Roman Gushchin <guro@fb.com> wrote:
>
> As a result of reparenting a kmem_cache might belong to the root
> memory cgroup. It happens when a top-level memory cgroup is removed,
> and all associated kmem_caches are reparented to the root memory
> cgroup.
>
> The root memory cgroup is special, and requires a special handling.
> Let's make sure that we don't try to charge or uncharge it,
> and we handle system-wide vmstats exactly as for root kmem_caches.
>
> Note, that we still need to alter the kmem_cache reference counter,
> so that the kmem_cache can be released properly.
>
> The issue was discovered by running CRIU tests; the following warning
> did appear:
>
> [  381.345960] WARNING: CPU: 0 PID: 11655 at mm/page_counter.c:62
> page_counter_cancel+0x26/0x30
> [  381.345992] Modules linked in:
> [  381.345998] CPU: 0 PID: 11655 Comm: kworker/0:8 Not tainted
> 5.2.0-rc5-next-20190618+ #1
> [  381.346001] Hardware name: Google Google Compute Engine/Google
> Compute Engine, BIOS Google 01/01/2011
> [  381.346010] Workqueue: memcg_kmem_cache kmemcg_workfn
> [  381.346013] RIP: 0010:page_counter_cancel+0x26/0x30
> [  381.346017] Code: 1f 44 00 00 0f 1f 44 00 00 48 89 f0 53 48 f7 d8
> f0 48 0f c1 07 48 29 f0 48 89 c3 48 89 c6 e8 61 ff ff ff 48 85 db 78
> 02 5b c3 <0f> 0b 5b c3 66 0f 1f 44 00 00 0f 1f 44 00 00 48 85 ff 74 41
> 41 55
> [  381.346019] RSP: 0018:ffffb3b34319f990 EFLAGS: 00010086
> [  381.346022] RAX: fffffffffffffffc RBX: fffffffffffffffc RCX: 0000000000000004
> [  381.346024] RDX: 0000000000000000 RSI: fffffffffffffffc RDI: ffff9c2cd7165270
> [  381.346026] RBP: 0000000000000004 R08: 0000000000000000 R09: 0000000000000001
> [  381.346028] R10: 00000000000000c8 R11: ffff9c2cd684e660 R12: 00000000fffffffc
> [  381.346030] R13: 0000000000000002 R14: 0000000000000006 R15: ffff9c2c8ce1f200
> [  381.346033] FS:  0000000000000000(0000) GS:ffff9c2cd8200000(0000)
> knlGS:0000000000000000
> [  381.346039] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  381.346041] CR2: 00000000007be000 CR3: 00000001cdbfc005 CR4: 00000000001606f0
> [  381.346043] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  381.346045] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> [  381.346047] Call Trace:
> [  381.346054]  page_counter_uncharge+0x1d/0x30
> [  381.346065]  __memcg_kmem_uncharge_memcg+0x39/0x60
> [  381.346071]  __free_slab+0x34c/0x460
> [  381.346079]  deactivate_slab.isra.80+0x57d/0x6d0
> [  381.346088]  ? add_lock_to_list.isra.36+0x9c/0xf0
> [  381.346095]  ? __lock_acquire+0x252/0x1410
> [  381.346106]  ? cpumask_next_and+0x19/0x20
> [  381.346110]  ? slub_cpu_dead+0xd0/0xd0
> [  381.346113]  flush_cpu_slab+0x36/0x50
> [  381.346117]  ? slub_cpu_dead+0xd0/0xd0
> [  381.346125]  on_each_cpu_mask+0x51/0x70
> [  381.346131]  ? ksm_migrate_page+0x60/0x60
> [  381.346134]  on_each_cpu_cond_mask+0xab/0x100
> [  381.346143]  __kmem_cache_shrink+0x56/0x320
> [  381.346150]  ? ret_from_fork+0x3a/0x50
> [  381.346157]  ? unwind_next_frame+0x73/0x480
> [  381.346176]  ? __lock_acquire+0x252/0x1410
> [  381.346188]  ? kmemcg_workfn+0x21/0x50
> [  381.346196]  ? __mutex_lock+0x99/0x920
> [  381.346199]  ? kmemcg_workfn+0x21/0x50
> [  381.346205]  ? kmemcg_workfn+0x21/0x50
> [  381.346216]  __kmemcg_cache_deactivate_after_rcu+0xe/0x40
> [  381.346220]  kmemcg_cache_deactivate_after_rcu+0xe/0x20
> [  381.346223]  kmemcg_workfn+0x31/0x50
> [  381.346230]  process_one_work+0x23c/0x5e0
> [  381.346241]  worker_thread+0x3c/0x390
> [  381.346248]  ? process_one_work+0x5e0/0x5e0
> [  381.346252]  kthread+0x11d/0x140
> [  381.346255]  ? kthread_create_on_node+0x60/0x60
> [  381.346261]  ret_from_fork+0x3a/0x50
> [  381.346275] irq event stamp: 10302
> [  381.346278] hardirqs last  enabled at (10301): [<ffffffffb2c1a0b9>]
> _raw_spin_unlock_irq+0x29/0x40
> [  381.346282] hardirqs last disabled at (10302): [<ffffffffb2182289>]
> on_each_cpu_mask+0x49/0x70
> [  381.346287] softirqs last  enabled at (10262): [<ffffffffb2191f4a>]
> cgroup_idr_replace+0x3a/0x50
> [  381.346290] softirqs last disabled at (10260): [<ffffffffb2191f2d>]
> cgroup_idr_replace+0x1d/0x50
> [  381.346293] ---[ end trace b324ba73eb3659f0 ]---
>
> Reported-by: Andrei Vagin <avagin@gmail.com>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Shakeel Butt <shakeelb@google.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Waiman Long <longman@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> ---
>  mm/slab.h | 17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
>
> diff --git a/mm/slab.h b/mm/slab.h
> index a4c9b9d042de..c02e7f44268b 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -294,8 +294,12 @@ static __always_inline int memcg_charge_slab(struct page *page,
>                 memcg = parent_mem_cgroup(memcg);
>         rcu_read_unlock();
>
> -       if (unlikely(!memcg))
> +       if (unlikely(!memcg || mem_cgroup_is_root(memcg))) {
> +               mod_node_page_state(page_pgdat(page), cache_vmstat_idx(s),
> +                                   (1 << order));
> +               percpu_ref_get_many(&s->memcg_params.refcnt, 1 << order);
>                 return true;

Should the above be "return 0;" instead of true?

> +       }
>
>         ret = memcg_kmem_charge_memcg(page, gfp, order, memcg);
>         if (ret)
> @@ -324,9 +328,14 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
>
>         rcu_read_lock();
>         memcg = READ_ONCE(s->memcg_params.memcg);
> -       lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
> -       mod_lruvec_state(lruvec, cache_vmstat_idx(s), -(1 << order));
> -       memcg_kmem_uncharge_memcg(page, order, memcg);
> +       if (likely(!mem_cgroup_is_root(memcg))) {
> +               lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
> +               mod_lruvec_state(lruvec, cache_vmstat_idx(s), -(1 << order));
> +               memcg_kmem_uncharge_memcg(page, order, memcg);
> +       } else {
> +               mod_node_page_state(page_pgdat(page), cache_vmstat_idx(s),
> +                                   -(1 << order));
> +       }
>         rcu_read_unlock();
>
>         percpu_ref_put_many(&s->memcg_params.refcnt, 1 << order);
> --
> 2.21.0
>

