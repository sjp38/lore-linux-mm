Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77F39C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 15:25:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20B392064A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 15:25:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="NRDDaciC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20B392064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4E138E0006; Fri, 28 Jun 2019 11:25:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFF228E0002; Fri, 28 Jun 2019 11:25:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AECB18E0006; Fri, 28 Jun 2019 11:25:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6278E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:25:14 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id s22so6361975qtb.22
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 08:25:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=T6Egj8bd3FQf5cgQJqXb3ke+fkvsG+q7H88Nz1kVqhw=;
        b=T9Nv2U+JpPw7fbOUZ4lUJ4nbigzVe0IPW/E4FGsjV67AvE1h7zZYQmaP92FvVKsQCM
         q66ixLSkvUOziQlL/WLNP9SmGzcM/5LkwOuJTGbKv99785Gow9FXKUvfHaP5OT4uP+xa
         S/669rLOFTyq2er73ZlPd8Xw3U/jqBYaPaNLCqD/lV9x0X/GiVb+hTThttXXE9X9RwTZ
         V8I6a/mpk4aKX8Oh4AZk+6ZJyJaw/ZpyiVmWzq0vngij3G+kT1msF+17bzG69xLfeNEK
         focPQrSnW6YWM6qBMM/MFHvBmTHTddifVW8tIXtl5l74P4R/F6Va29/H0/FLelIGRUxH
         Ojng==
X-Gm-Message-State: APjAAAU7PRuym7KRwjbX8Gfc4mxt9hLjzkpQXdHdiowqA4CBxhMpfeeJ
	ZnA+823bLI2c+oEFezqPAu39PoT5Ko0Sfv3iSq1XBJKxt6o+dVf62LjuaSPBxv3lMWcYjdARlYH
	3EFofQYvU54BwwOJjGBHjw9kmna/lSf7HjOzLrEPN1UGIecsveYITxZiQaHXTGIQ2Ag==
X-Received: by 2002:ac8:36b9:: with SMTP id a54mr8789835qtc.300.1561735514253;
        Fri, 28 Jun 2019 08:25:14 -0700 (PDT)
X-Received: by 2002:ac8:36b9:: with SMTP id a54mr8789743qtc.300.1561735513153;
        Fri, 28 Jun 2019 08:25:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561735513; cv=none;
        d=google.com; s=arc-20160816;
        b=pwylvZWnvcpGK/k3uiPU0vOicFBm7y+eF5ufGP/IiAQdxrTTRcPsk7l+wC05qqJPif
         /eUFjQeV6sN0N5p/8fam4dxildHsyYF36vkfSeePj3GnJ2VoUPlwaDhZeC+ylgoF2pMm
         xIEtZwFJmE7LgmbDi09F55HCoCRAAHV6wB7BRMmhm8AWB0RToZJvE+0aL4ltg7JTRD4i
         zMMUjJZp00yuHcN+ky+PNFTr8fvdt93QajhRdWWW9I+aTv0aQ56op8Wp1CHi3pCb4nxl
         2x1dfL1lzhdVzO2YzeOXnX+2I6aznkEHmBnmM3x2+joqS2aD96/ERcHNYQ7Z7v+M9Bw1
         45gA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=T6Egj8bd3FQf5cgQJqXb3ke+fkvsG+q7H88Nz1kVqhw=;
        b=OSDkoW8xm5dRn6sM64Na+Ju0CNAStqyqoTvOOW2zK6U4M0f+VVZcZLsCd5XRlEbxw/
         C44omcYN5OKi8q2482dO49e3Y8ngM8sl12xs/xbK6sTwzjF5BUAuGputSSCtEinHIao+
         oh2quS41ECec3aDTv1emcM3e5VQ5lQtHYO2ef5QNJCzUUSlo31ck56FnpbTtcczALhXn
         cf/2410965aUYSKyNsb56ONTHoRvp2zWpDw0KkawaWrP5VLyh1ec6iGzuCZNtsExaZVs
         ly6vABrowJUoAYRKXeaBj+QBG9hy72aYqr6HnClXGK+tLWlpa8clsRkB/3A/VK6B7jiM
         myTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NRDDaciC;
       spf=pass (google.com: domain of 3wdewxqgkcamvkdnhhoejrrjoh.frpolqx0-ppnydfn.ruj@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3WDEWXQgKCAMvkdnhhoejrrjoh.frpolqx0-ppnydfn.ruj@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id j123sor1732239qkd.156.2019.06.28.08.25.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 08:25:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3wdewxqgkcamvkdnhhoejrrjoh.frpolqx0-ppnydfn.ruj@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NRDDaciC;
       spf=pass (google.com: domain of 3wdewxqgkcamvkdnhhoejrrjoh.frpolqx0-ppnydfn.ruj@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3WDEWXQgKCAMvkdnhhoejrrjoh.frpolqx0-ppnydfn.ruj@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=T6Egj8bd3FQf5cgQJqXb3ke+fkvsG+q7H88Nz1kVqhw=;
        b=NRDDaciC2K9HkQoNqDTIiPWrPDmsFURh+YXAm9/Ic3cvJ4z+RkrrZHHu+r/91MT7wA
         Qp+CUhv83wB867Zc+nZS0LIKp67i7upv4ecrjtYsQNktL8nOragF0XPCf6KsvXntdoTq
         Gl+H86PTSK+COlERiF82cbw8jOR56HlQA7euFt7cB70grIOI2Gj2iZVYb1qVBYujvHVH
         GdLvuLDWE+wQuImpAxMLOTVjXI4SAR19BWkSj8p4D269UD3LffAb/9xPN0QsY38A+FP/
         Kf/A3p4+5jqBRUS6+gkur902psLGPrj53wlmxDqwRTxzCj+qF3q66wEAJWehVFVJg5Uc
         9GOQ==
X-Google-Smtp-Source: APXvYqzmecZ2pT9n7DZDTuxERplpng+TH0Vx10pqYyj7v0knzbz97H4tqwPkjz3joCgD2lCWA5SAtzg9idXWZw==
X-Received: by 2002:a37:a0d:: with SMTP id 13mr9089376qkk.273.1561735512733;
 Fri, 28 Jun 2019 08:25:12 -0700 (PDT)
Date: Fri, 28 Jun 2019 08:24:21 -0700
In-Reply-To: <20190628152421.198994-1-shakeelb@google.com>
Message-Id: <20190628152421.198994-3-shakeelb@google.com>
Mime-Version: 1.0
References: <20190628152421.198994-1-shakeelb@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v4 3/3] oom: decouple mems_allowed from oom_unkillable_task
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
	David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>, syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com, 
	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@gmail.com>, 
	Paul Jackson <pj@sgi.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ef08e3b4981a ("[PATCH] cpusets: confine oom_killer to mem_exclusive
cpuset") introduces a heuristic where a potential oom-killer victim is
skipped if the intersection of the potential victim and the current (the
process triggered the oom) is empty based on the reason that killing such
victim most probably will not help the current allocating process.
However the commit 7887a3da753e ("[PATCH] oom: cpuset hint") changed the
heuristic to just decrease the oom_badness scores of such potential victim
based on the reason that the cpuset of such processes might have changed
and previously they may have allocated memory on mems where the current
allocating process can allocate from.

Unintentionally 7887a3da753e ("[PATCH] oom: cpuset hint") introduced a
side effect as the oom_badness is also exposed to the user space through
/proc/[pid]/oom_score, so, readers with different cpusets can read
different oom_score of the same process.

Later 6cf86ac6f36b ("oom: filter tasks not sharing the same cpuset") fixed
the side effect introduced by 7887a3da753e by moving the cpuset
intersection back to only oom-killer context and out of oom_badness.
However the combination of ab290adbaf8f ("oom: make oom_unkillable_task()
helper function") and 26ebc984913b ("oom: /proc/<pid>/oom_score treat
kernel thread honestly") unintentionally brought back the cpuset
intersection check into the oom_badness calculation function.

Other than doing cpuset/mempolicy intersection from oom_badness, the memcg
oom context is also doing cpuset/mempolicy intersection which is quite
wrong and is caught by syzcaller with the following report:

kasan: CONFIG_KASAN_INLINE enabled
kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] PREEMPT SMP KASAN
CPU: 0 PID: 28426 Comm: syz-executor.5 Not tainted 5.2.0-rc3-next-20190607
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
Google 01/01/2011
RIP: 0010:__read_once_size include/linux/compiler.h:194 [inline]
RIP: 0010:has_intersects_mems_allowed mm/oom_kill.c:84 [inline]
RIP: 0010:oom_unkillable_task mm/oom_kill.c:168 [inline]
RIP: 0010:oom_unkillable_task+0x180/0x400 mm/oom_kill.c:155
Code: c1 ea 03 80 3c 02 00 0f 85 80 02 00 00 4c 8b a3 10 07 00 00 48 b8 00
00 00 00 00 fc ff df 4d 8d 74 24 10 4c 89 f2 48 c1 ea 03 <80> 3c 02 00 0f
85 67 02 00 00 49 8b 44 24 10 4c 8d a0 68 fa ff ff
RSP: 0018:ffff888000127490 EFLAGS: 00010a03
RAX: dffffc0000000000 RBX: ffff8880a4cd5438 RCX: ffffffff818dae9c
RDX: 100000000c3cc602 RSI: ffffffff818dac8d RDI: 0000000000000001
RBP: ffff8880001274d0 R08: ffff888000086180 R09: ffffed1015d26be0
R10: ffffed1015d26bdf R11: ffff8880ae935efb R12: 8000000061e63007
R13: 0000000000000000 R14: 8000000061e63017 R15: 1ffff11000024ea6
FS:  00005555561f5940(0000) GS:ffff8880ae800000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000607304 CR3: 000000009237e000 CR4: 00000000001426f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Call Trace:
  oom_evaluate_task+0x49/0x520 mm/oom_kill.c:321
  mem_cgroup_scan_tasks+0xcc/0x180 mm/memcontrol.c:1169
  select_bad_process mm/oom_kill.c:374 [inline]
  out_of_memory mm/oom_kill.c:1088 [inline]
  out_of_memory+0x6b2/0x1280 mm/oom_kill.c:1035
  mem_cgroup_out_of_memory+0x1ca/0x230 mm/memcontrol.c:1573
  mem_cgroup_oom mm/memcontrol.c:1905 [inline]
  try_charge+0xfbe/0x1480 mm/memcontrol.c:2468
  mem_cgroup_try_charge+0x24d/0x5e0 mm/memcontrol.c:6073
  mem_cgroup_try_charge_delay+0x1f/0xa0 mm/memcontrol.c:6088
  do_huge_pmd_wp_page_fallback+0x24f/0x1680 mm/huge_memory.c:1201
  do_huge_pmd_wp_page+0x7fc/0x2160 mm/huge_memory.c:1359
  wp_huge_pmd mm/memory.c:3793 [inline]
  __handle_mm_fault+0x164c/0x3eb0 mm/memory.c:4006
  handle_mm_fault+0x3b7/0xa90 mm/memory.c:4053
  do_user_addr_fault arch/x86/mm/fault.c:1455 [inline]
  __do_page_fault+0x5ef/0xda0 arch/x86/mm/fault.c:1521
  do_page_fault+0x71/0x57d arch/x86/mm/fault.c:1552
  page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1156
RIP: 0033:0x400590
Code: 06 e9 49 01 00 00 48 8b 44 24 10 48 0b 44 24 28 75 1f 48 8b 14 24 48
8b 7c 24 20 be 04 00 00 00 e8 f5 56 00 00 48 8b 74 24 08 <89> 06 e9 1e 01
00 00 48 8b 44 24 08 48 8b 14 24 be 04 00 00 00 8b
RSP: 002b:00007fff7bc49780 EFLAGS: 00010206
RAX: 0000000000000001 RBX: 0000000000760000 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 000000002000cffc RDI: 0000000000000001
RBP: fffffffffffffffe R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000075 R11: 0000000000000246 R12: 0000000000760008
R13: 00000000004c55f2 R14: 0000000000000000 R15: 00007fff7bc499b0
Modules linked in:
---[ end trace a65689219582ffff ]---
RIP: 0010:__read_once_size include/linux/compiler.h:194 [inline]
RIP: 0010:has_intersects_mems_allowed mm/oom_kill.c:84 [inline]
RIP: 0010:oom_unkillable_task mm/oom_kill.c:168 [inline]
RIP: 0010:oom_unkillable_task+0x180/0x400 mm/oom_kill.c:155
Code: c1 ea 03 80 3c 02 00 0f 85 80 02 00 00 4c 8b a3 10 07 00 00 48 b8 00
00 00 00 00 fc ff df 4d 8d 74 24 10 4c 89 f2 48 c1 ea 03 <80> 3c 02 00 0f
85 67 02 00 00 49 8b 44 24 10 4c 8d a0 68 fa ff ff
RSP: 0018:ffff888000127490 EFLAGS: 00010a03
RAX: dffffc0000000000 RBX: ffff8880a4cd5438 RCX: ffffffff818dae9c
RDX: 100000000c3cc602 RSI: ffffffff818dac8d RDI: 0000000000000001
RBP: ffff8880001274d0 R08: ffff888000086180 R09: ffffed1015d26be0
R10: ffffed1015d26bdf R11: ffff8880ae935efb R12: 8000000061e63007
R13: 0000000000000000 R14: 8000000061e63017 R15: 1ffff11000024ea6
FS:  00005555561f5940(0000) GS:ffff8880ae800000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000001b2f823000 CR3: 000000009237e000 CR4: 00000000001426f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600

The fix is to decouple the cpuset/mempolicy intersection check from
oom_unkillable_task() and make sure cpuset/mempolicy intersection check is
only done in the global oom context.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
Reported-by: syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Roman Gushchin <guro@fb.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: Paul Jackson <pj@sgi.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
Changelog since v3:
- Changed function name and update comment.

Changelog since v2:
- Further divided the patch into two patches.
- More cleaned version.

Changelog since v1:
- Divide the patch into two patches.

 fs/proc/base.c      |  3 +--
 include/linux/oom.h |  1 -
 mm/oom_kill.c       | 57 +++++++++++++++++++++++++--------------------
 3 files changed, 33 insertions(+), 28 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 5eacce5e924a..57b7a0d75ef5 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -532,8 +532,7 @@ static int proc_oom_score(struct seq_file *m, struct pid_namespace *ns,
 	unsigned long totalpages = totalram_pages() + total_swap_pages;
 	unsigned long points = 0;
 
-	points = oom_badness(task, NULL, totalpages) *
-					1000 / totalpages;
+	points = oom_badness(task, totalpages) * 1000 / totalpages;
 	seq_printf(m, "%lu\n", points);
 
 	return 0;
diff --git a/include/linux/oom.h b/include/linux/oom.h
index b75104690311..c696c265f019 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -108,7 +108,6 @@ static inline vm_fault_t check_stable_address_space(struct mm_struct *mm)
 bool __oom_reap_task_mm(struct mm_struct *mm);
 
 extern unsigned long oom_badness(struct task_struct *p,
-		const nodemask_t *nodemask,
 		unsigned long totalpages);
 
 extern bool out_of_memory(struct oom_control *oc);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index eff879acc886..95872bdfec4e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -64,21 +64,33 @@ int sysctl_oom_dump_tasks = 1;
  */
 DEFINE_MUTEX(oom_lock);
 
+static inline bool is_memcg_oom(struct oom_control *oc)
+{
+	return oc->memcg != NULL;
+}
+
 #ifdef CONFIG_NUMA
 /**
- * has_intersects_mems_allowed() - check task eligiblity for kill
+ * oom_cpuset_eligible() - check task eligiblity for kill
  * @start: task struct of which task to consider
  * @mask: nodemask passed to page allocator for mempolicy ooms
  *
  * Task eligibility is determined by whether or not a candidate task, @tsk,
  * shares the same mempolicy nodes as current if it is bound by such a policy
  * and whether or not it has the same set of allowed cpuset nodes.
+ *
+ * This function is assuming oom-killer context and 'current' has triggered
+ * the oom-killer.
  */
-static bool has_intersects_mems_allowed(struct task_struct *start,
-					const nodemask_t *mask)
+static bool oom_cpuset_eligible(struct task_struct *start,
+				struct oom_control *oc)
 {
 	struct task_struct *tsk;
 	bool ret = false;
+	const nodemask_t *mask = oc->nodemask;
+
+	if (is_memcg_oom(oc))
+		return true;
 
 	rcu_read_lock();
 	for_each_thread(start, tsk) {
@@ -105,8 +117,7 @@ static bool has_intersects_mems_allowed(struct task_struct *start,
 	return ret;
 }
 #else
-static bool has_intersects_mems_allowed(struct task_struct *tsk,
-					const nodemask_t *mask)
+static bool oom_cpuset_eligible(struct task_struct *tsk, struct oom_control *oc)
 {
 	return true;
 }
@@ -146,24 +157,13 @@ static inline bool is_sysrq_oom(struct oom_control *oc)
 	return oc->order == -1;
 }
 
-static inline bool is_memcg_oom(struct oom_control *oc)
-{
-	return oc->memcg != NULL;
-}
-
 /* return true if the task is not adequate as candidate victim task. */
-static bool oom_unkillable_task(struct task_struct *p,
-				const nodemask_t *nodemask)
+static bool oom_unkillable_task(struct task_struct *p)
 {
 	if (is_global_init(p))
 		return true;
 	if (p->flags & PF_KTHREAD)
 		return true;
-
-	/* p may not have freeable memory in nodemask */
-	if (!has_intersects_mems_allowed(p, nodemask))
-		return true;
-
 	return false;
 }
 
@@ -190,19 +190,17 @@ static bool is_dump_unreclaim_slabs(void)
  * oom_badness - heuristic function to determine which candidate task to kill
  * @p: task struct of which task we should calculate
  * @totalpages: total present RAM allowed for page allocation
- * @nodemask: nodemask passed to page allocator for mempolicy ooms
  *
  * The heuristic for determining which task to kill is made to be as simple and
  * predictable as possible.  The goal is to return the highest value for the
  * task consuming the most memory to avoid subsequent oom failures.
  */
-unsigned long oom_badness(struct task_struct *p,
-			  const nodemask_t *nodemask, unsigned long totalpages)
+unsigned long oom_badness(struct task_struct *p, unsigned long totalpages)
 {
 	long points;
 	long adj;
 
-	if (oom_unkillable_task(p, nodemask))
+	if (oom_unkillable_task(p))
 		return 0;
 
 	p = find_lock_task_mm(p);
@@ -313,7 +311,11 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	struct oom_control *oc = arg;
 	unsigned long points;
 
-	if (oom_unkillable_task(task, oc->nodemask))
+	if (oom_unkillable_task(task))
+		goto next;
+
+	/* p may not have freeable memory in nodemask */
+	if (!is_memcg_oom(oc) && !oom_cpuset_eligible(task, oc))
 		goto next;
 
 	/*
@@ -337,7 +339,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 		goto select;
 	}
 
-	points = oom_badness(task, oc->nodemask, oc->totalpages);
+	points = oom_badness(task, oc->totalpages);
 	if (!points || points < oc->chosen_points)
 		goto next;
 
@@ -380,7 +382,11 @@ static int dump_task(struct task_struct *p, void *arg)
 	struct oom_control *oc = arg;
 	struct task_struct *task;
 
-	if (oom_unkillable_task(p, oc->nodemask))
+	if (oom_unkillable_task(p))
+		return 0;
+
+	/* p may not have freeable memory in nodemask */
+	if (!is_memcg_oom(oc) && !oom_cpuset_eligible(p, oc))
 		return 0;
 
 	task = find_lock_task_mm(p);
@@ -1078,7 +1084,8 @@ bool out_of_memory(struct oom_control *oc)
 	check_panic_on_oom(oc);
 
 	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
-	    current->mm && !oom_unkillable_task(current, oc->nodemask) &&
+	    current->mm && !oom_unkillable_task(current) &&
+	    oom_cpuset_eligible(current, oc) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
 		get_task_struct(current);
 		oc->chosen = current;
-- 
2.22.0.410.gd8fdbe21b5-goog

