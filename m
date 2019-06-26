Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36FE6C4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:55:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E24EE2086D
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:55:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E24EE2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E5E08E0003; Wed, 26 Jun 2019 02:55:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76ECD8E0002; Wed, 26 Jun 2019 02:55:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60F678E0003; Wed, 26 Jun 2019 02:55:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07AFC8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:55:58 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a5so1691174edx.12
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:55:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OOfRGHhL0Lxleb+XumFQ1nv2d/Fy1HZVWW+NmdXngpw=;
        b=apFUA6P7DPThKHQ+qrb+8TlV0PW8B59CEcvNUTkglqxZicMSxnOWEbcysKOUPfbVl3
         QtO3O9MWd7JP1bzf4yJg36N0wVQqiWm5rXvNzt2N8aLGmqeZ1QbRbOo0XY/1pOl8pENt
         OKexsIlkKs2KroRsnombKdVGHbboOmiwXvK/xS7kFEUMtrKW7rRZqmbTNRHnyGl+OtoJ
         P7U7Mim4LELyTt+HGr1qGAU/04deVOGM0bYswTwktJ9Brhz5yjvj8mDBFTKuU24Mmr7R
         7gJV5MvyJ6I1A3iLxgEs6zV+Bm3roNogsjJi+kwrpURHywIjh6Xtho9uDRwzi0BXBHbB
         njEw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVZGeJ811xfgJ4kiL1EmRokP1pI89btBA22rsXkLOYj37wHx8iu
	te5LD1yR9v1fvNLj52flCAB02fZDwJUkqijqdq1xJNuGP73muIbSF3mTcNBoJj2Cudn2j+/YXm4
	BhbgQru3JtuRSgEXq2Lbysu7JXTDvJOoPn4uB3mwFeBiYW0c/MKTOikw/ut+bcP4=
X-Received: by 2002:aa7:d4d8:: with SMTP id t24mr3111052edr.213.1561532157453;
        Tue, 25 Jun 2019 23:55:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwE4HCF7VA+TKgeM4HqKCPYPnVpF4ulj+Wmhzse3MACft46ggVJIF8Wtkjkpm2LB/eMknTA
X-Received: by 2002:aa7:d4d8:: with SMTP id t24mr3110983edr.213.1561532156459;
        Tue, 25 Jun 2019 23:55:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561532156; cv=none;
        d=google.com; s=arc-20160816;
        b=Bj6XAZRDTZvd3//YRC1X/BMDozcXsdheH40IGVKHVzVQkB5sq6ttIfvPIgYwdpDH4H
         d7LDo7fpXGlBV3AKaNVWnNepcy6Mc6l6npLUi4CXdtHCQetE4e4YhgWJdAN45sFHCsJa
         4yG8OIKWOfTn6hkVguK5mv6ycJ0uteWLZ5KIqhJ00l9VbeGb+G0iRaOVkF1nfZoIUF3i
         Kg556Uygbzo5ElriCes1OgunW7PSk+hQ15fnTlufzGawew7ATWw1436Lmf6XQhXpMB9/
         eSgqfhkGh3Q+OgyEat5MkVAHLs0UQO06mKiCy7CLl6CwX26YJ42WsipAeGP952eMlly3
         uOzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OOfRGHhL0Lxleb+XumFQ1nv2d/Fy1HZVWW+NmdXngpw=;
        b=IQ3WKXVhBr76f5BXeSnpze1LVjlo4ku+9k16COyLeqiF1jTKbLS2wG/3dZhUreqM3P
         27MMHQ9O3xMp69rd83pN3paVBzKv7sBDMQ0kZ3PtyXYh3lYvy01NiproO7bf6f3A7d1D
         aIsnnljsrKTopZwUxy8c4FvGrJGWdp7xUtunUVgMBpfUfMggYDdsk4vXtO8yMHF+N6C+
         Ru0EVgR9Kz/FrZ9L0FeqEm9Mpv49R78EmypYgugfABO7/Xq1VO6dijHVIEqcGNHN3zpg
         /ENs9vROksOO2QwIzXHkkcZ5x1q5Oh5a++Ci5EeckP8JJDGqf40YXPb9bje285baoTY1
         KqJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s49si2542909eda.99.2019.06.25.23.55.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 23:55:56 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9F364AC83;
	Wed, 26 Jun 2019 06:55:55 +0000 (UTC)
Date: Wed, 26 Jun 2019 08:55:54 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>,
	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Paul Jackson <pj@sgi.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com
Subject: Re: [PATCH v3 3/3] oom: decouple mems_allowed from
 oom_unkillable_task
Message-ID: <20190626065118.GJ17798@dhcp22.suse.cz>
References: <20190624212631.87212-1-shakeelb@google.com>
 <20190624212631.87212-3-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190624212631.87212-3-shakeelb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 24-06-19 14:26:31, Shakeel Butt wrote:
> The commit ef08e3b4981a ("[PATCH] cpusets: confine oom_killer to
> mem_exclusive cpuset") introduces a heuristic where a potential
> oom-killer victim is skipped if the intersection of the potential victim
> and the current (the process triggered the oom) is empty based on the
> reason that killing such victim most probably will not help the current
> allocating process. However the commit 7887a3da753e ("[PATCH] oom:
> cpuset hint") changed the heuristic to just decrease the oom_badness
> scores of such potential victim based on the reason that the cpuset of
> such processes might have changed and previously they might have
> allocated memory on mems where the current allocating process can
> allocate from.
> 
> Unintentionally commit 7887a3da753e ("[PATCH] oom: cpuset hint")
> introduced a side effect as the oom_badness is also exposed to the
> user space through /proc/[pid]/oom_score, so, readers with different
> cpusets can read different oom_score of th same process.
> 
> Later the commit 6cf86ac6f36b ("oom: filter tasks not sharing the same
> cpuset") fixed the side effect introduced by 7887a3da753e by moving the
> cpuset intersection back to only oom-killer context and out of
> oom_badness. However the combination of the commit ab290adbaf8f ("oom:
> make oom_unkillable_task() helper function") and commit 26ebc984913b
> ("oom: /proc/<pid>/oom_score treat kernel thread honestly")
> unintentionally brought back the cpuset intersection check into the
> oom_badness calculation function.

Thanks for this excursion into the history. I think it is very useful.

> Other than doing cpuset/mempolicy intersection from oom_badness, the
> memcg oom context is also doing cpuset/mempolicy intersection which is
> quite wrong and is caught by syzcaller with the following report:
> 
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] PREEMPT SMP KASAN
> CPU: 0 PID: 28426 Comm: syz-executor.5 Not tainted 5.2.0-rc3-next-20190607
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:__read_once_size include/linux/compiler.h:194 [inline]
> RIP: 0010:has_intersects_mems_allowed mm/oom_kill.c:84 [inline]
> RIP: 0010:oom_unkillable_task mm/oom_kill.c:168 [inline]
> RIP: 0010:oom_unkillable_task+0x180/0x400 mm/oom_kill.c:155
> Code: c1 ea 03 80 3c 02 00 0f 85 80 02 00 00 4c 8b a3 10 07 00 00 48 b8 00
> 00 00 00 00 fc ff df 4d 8d 74 24 10 4c 89 f2 48 c1 ea 03 <80> 3c 02 00 0f
> 85 67 02 00 00 49 8b 44 24 10 4c 8d a0 68 fa ff ff
> RSP: 0018:ffff888000127490 EFLAGS: 00010a03
> RAX: dffffc0000000000 RBX: ffff8880a4cd5438 RCX: ffffffff818dae9c
> RDX: 100000000c3cc602 RSI: ffffffff818dac8d RDI: 0000000000000001
> RBP: ffff8880001274d0 R08: ffff888000086180 R09: ffffed1015d26be0
> R10: ffffed1015d26bdf R11: ffff8880ae935efb R12: 8000000061e63007
> R13: 0000000000000000 R14: 8000000061e63017 R15: 1ffff11000024ea6
> FS:  00005555561f5940(0000) GS:ffff8880ae800000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000607304 CR3: 000000009237e000 CR4: 00000000001426f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
> Call Trace:
>   oom_evaluate_task+0x49/0x520 mm/oom_kill.c:321
>   mem_cgroup_scan_tasks+0xcc/0x180 mm/memcontrol.c:1169
>   select_bad_process mm/oom_kill.c:374 [inline]
>   out_of_memory mm/oom_kill.c:1088 [inline]
>   out_of_memory+0x6b2/0x1280 mm/oom_kill.c:1035
>   mem_cgroup_out_of_memory+0x1ca/0x230 mm/memcontrol.c:1573
>   mem_cgroup_oom mm/memcontrol.c:1905 [inline]
>   try_charge+0xfbe/0x1480 mm/memcontrol.c:2468
>   mem_cgroup_try_charge+0x24d/0x5e0 mm/memcontrol.c:6073
>   mem_cgroup_try_charge_delay+0x1f/0xa0 mm/memcontrol.c:6088
>   do_huge_pmd_wp_page_fallback+0x24f/0x1680 mm/huge_memory.c:1201
>   do_huge_pmd_wp_page+0x7fc/0x2160 mm/huge_memory.c:1359
>   wp_huge_pmd mm/memory.c:3793 [inline]
>   __handle_mm_fault+0x164c/0x3eb0 mm/memory.c:4006
>   handle_mm_fault+0x3b7/0xa90 mm/memory.c:4053
>   do_user_addr_fault arch/x86/mm/fault.c:1455 [inline]
>   __do_page_fault+0x5ef/0xda0 arch/x86/mm/fault.c:1521
>   do_page_fault+0x71/0x57d arch/x86/mm/fault.c:1552
>   page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1156
> RIP: 0033:0x400590
> Code: 06 e9 49 01 00 00 48 8b 44 24 10 48 0b 44 24 28 75 1f 48 8b 14 24 48
> 8b 7c 24 20 be 04 00 00 00 e8 f5 56 00 00 48 8b 74 24 08 <89> 06 e9 1e 01
> 00 00 48 8b 44 24 08 48 8b 14 24 be 04 00 00 00 8b
> RSP: 002b:00007fff7bc49780 EFLAGS: 00010206
> RAX: 0000000000000001 RBX: 0000000000760000 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: 000000002000cffc RDI: 0000000000000001
> RBP: fffffffffffffffe R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000075 R11: 0000000000000246 R12: 0000000000760008
> R13: 00000000004c55f2 R14: 0000000000000000 R15: 00007fff7bc499b0
> Modules linked in:
> ---[ end trace a65689219582ffff ]---
> RIP: 0010:__read_once_size include/linux/compiler.h:194 [inline]
> RIP: 0010:has_intersects_mems_allowed mm/oom_kill.c:84 [inline]
> RIP: 0010:oom_unkillable_task mm/oom_kill.c:168 [inline]
> RIP: 0010:oom_unkillable_task+0x180/0x400 mm/oom_kill.c:155
> Code: c1 ea 03 80 3c 02 00 0f 85 80 02 00 00 4c 8b a3 10 07 00 00 48 b8 00
> 00 00 00 00 fc ff df 4d 8d 74 24 10 4c 89 f2 48 c1 ea 03 <80> 3c 02 00 0f
> 85 67 02 00 00 49 8b 44 24 10 4c 8d a0 68 fa ff ff
> RSP: 0018:ffff888000127490 EFLAGS: 00010a03
> RAX: dffffc0000000000 RBX: ffff8880a4cd5438 RCX: ffffffff818dae9c
> RDX: 100000000c3cc602 RSI: ffffffff818dac8d RDI: 0000000000000001
> RBP: ffff8880001274d0 R08: ffff888000086180 R09: ffffed1015d26be0
> R10: ffffed1015d26bdf R11: ffff8880ae935efb R12: 8000000061e63007
> R13: 0000000000000000 R14: 8000000061e63017 R15: 1ffff11000024ea6
> FS:  00005555561f5940(0000) GS:ffff8880ae800000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000001b2f823000 CR3: 000000009237e000 CR4: 00000000001426f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
> 
> The fix is to decouple the cpuset/mempolicy intersection check from
> oom_unkillable_task() and make sure cpuset/mempolicy intersection check
> is only done in the global oom context.

Thanks for the changelog update. This looks really great to me.

> Reported-by: syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

I think that VM_BUG_ON in has_intersects_mems_allowed is over protective
and it makes the rest of the code a bit more convoluted than necessary.
Is there any reason we just do the check and return true there? Btw.
has_intersects_mems_allowed sounds like a misnomer to me. It suggests
to be a more generic function while it has some memcg implications which
are not trivial to spot without digging deeper. I would go with
oom_cpuset_eligible or something along those lines.

Anyway
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> Changelog since v2:
> - Further divided the patch into two patches.
> - More cleaned version.
> 
> Changelog since v1:
> - Divide the patch into two patches.
> 
>  fs/proc/base.c      |  3 +--
>  include/linux/oom.h |  1 -
>  mm/oom_kill.c       | 51 ++++++++++++++++++++++++++-------------------
>  3 files changed, 30 insertions(+), 25 deletions(-)
> 
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index 5eacce5e924a..57b7a0d75ef5 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -532,8 +532,7 @@ static int proc_oom_score(struct seq_file *m, struct pid_namespace *ns,
>  	unsigned long totalpages = totalram_pages() + total_swap_pages;
>  	unsigned long points = 0;
>  
> -	points = oom_badness(task, NULL, totalpages) *
> -					1000 / totalpages;
> +	points = oom_badness(task, totalpages) * 1000 / totalpages;
>  	seq_printf(m, "%lu\n", points);
>  
>  	return 0;
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index b75104690311..c696c265f019 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -108,7 +108,6 @@ static inline vm_fault_t check_stable_address_space(struct mm_struct *mm)
>  bool __oom_reap_task_mm(struct mm_struct *mm);
>  
>  extern unsigned long oom_badness(struct task_struct *p,
> -		const nodemask_t *nodemask,
>  		unsigned long totalpages);
>  
>  extern bool out_of_memory(struct oom_control *oc);
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index e0cdcbd58b0b..9f91cb7036fb 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -64,6 +64,11 @@ int sysctl_oom_dump_tasks = 1;
>   */
>  DEFINE_MUTEX(oom_lock);
>  
> +static inline bool is_memcg_oom(struct oom_control *oc)
> +{
> +	return oc->memcg != NULL;
> +}
> +
>  #ifdef CONFIG_NUMA
>  /**
>   * has_intersects_mems_allowed() - check task eligiblity for kill
> @@ -73,12 +78,18 @@ DEFINE_MUTEX(oom_lock);
>   * Task eligibility is determined by whether or not a candidate task, @tsk,
>   * shares the same mempolicy nodes as current if it is bound by such a policy
>   * and whether or not it has the same set of allowed cpuset nodes.
> + *
> + * Only call in the global oom context (i.e. not in memcg oom). This function
> + * is assuming 'current' has triggered the oom-killer.
>   */
>  static bool has_intersects_mems_allowed(struct task_struct *start,
> -					const nodemask_t *mask)
> +					struct oom_control *oc)
>  {
>  	struct task_struct *tsk;
>  	bool ret = false;
> +	const nodemask_t *mask = oc->nodemask;
> +
> +	VM_BUG_ON(is_memcg_oom(oc));
>  
>  	rcu_read_lock();
>  	for_each_thread(start, tsk) {
> @@ -106,7 +117,7 @@ static bool has_intersects_mems_allowed(struct task_struct *start,
>  }
>  #else
>  static bool has_intersects_mems_allowed(struct task_struct *tsk,
> -					const nodemask_t *mask)
> +					struct oom_control *oc)
>  {
>  	return true;
>  }
> @@ -146,24 +157,13 @@ static inline bool is_sysrq_oom(struct oom_control *oc)
>  	return oc->order == -1;
>  }
>  
> -static inline bool is_memcg_oom(struct oom_control *oc)
> -{
> -	return oc->memcg != NULL;
> -}
> -
>  /* return true if the task is not adequate as candidate victim task. */
> -static bool oom_unkillable_task(struct task_struct *p,
> -				const nodemask_t *nodemask)
> +static bool oom_unkillable_task(struct task_struct *p)
>  {
>  	if (is_global_init(p))
>  		return true;
>  	if (p->flags & PF_KTHREAD)
>  		return true;
> -
> -	/* p may not have freeable memory in nodemask */
> -	if (!has_intersects_mems_allowed(p, nodemask))
> -		return true;
> -
>  	return false;
>  }
>  
> @@ -190,19 +190,17 @@ static bool is_dump_unreclaim_slabs(void)
>   * oom_badness - heuristic function to determine which candidate task to kill
>   * @p: task struct of which task we should calculate
>   * @totalpages: total present RAM allowed for page allocation
> - * @nodemask: nodemask passed to page allocator for mempolicy ooms
>   *
>   * The heuristic for determining which task to kill is made to be as simple and
>   * predictable as possible.  The goal is to return the highest value for the
>   * task consuming the most memory to avoid subsequent oom failures.
>   */
> -unsigned long oom_badness(struct task_struct *p,
> -			  const nodemask_t *nodemask, unsigned long totalpages)
> +unsigned long oom_badness(struct task_struct *p, unsigned long totalpages)
>  {
>  	long points;
>  	long adj;
>  
> -	if (oom_unkillable_task(p, nodemask))
> +	if (oom_unkillable_task(p))
>  		return 0;
>  
>  	p = find_lock_task_mm(p);
> @@ -313,7 +311,11 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
>  	struct oom_control *oc = arg;
>  	unsigned long points;
>  
> -	if (oom_unkillable_task(task, oc->nodemask))
> +	if (oom_unkillable_task(task))
> +		goto next;
> +
> +	/* p may not have freeable memory in nodemask */
> +	if (!is_memcg_oom(oc) && !has_intersects_mems_allowed(task, oc))
>  		goto next;
>  
>  	/*
> @@ -337,7 +339,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
>  		goto select;
>  	}
>  
> -	points = oom_badness(task, oc->nodemask, oc->totalpages);
> +	points = oom_badness(task, oc->totalpages);
>  	if (!points || points < oc->chosen_points)
>  		goto next;
>  
> @@ -385,7 +387,11 @@ static int dump_task(struct task_struct *p, void *arg)
>  	struct oom_control *oc = arg;
>  	struct task_struct *task;
>  
> -	if (oom_unkillable_task(p, oc->nodemask))
> +	if (oom_unkillable_task(p))
> +		return 0;
> +
> +	/* p may not have freeable memory in nodemask */
> +	if (!is_memcg_oom(oc) && !has_intersects_mems_allowed(p, oc))
>  		return 0;
>  
>  	task = find_lock_task_mm(p);
> @@ -1085,7 +1091,8 @@ bool out_of_memory(struct oom_control *oc)
>  	check_panic_on_oom(oc, constraint);
>  
>  	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
> -	    current->mm && !oom_unkillable_task(current, oc->nodemask) &&
> +	    current->mm && !oom_unkillable_task(current) &&
> +	    has_intersects_mems_allowed(current, oc) &&
>  	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
>  		get_task_struct(current);
>  		oc->chosen = current;
> -- 
> 2.22.0.410.gd8fdbe21b5-goog

-- 
Michal Hocko
SUSE Labs

