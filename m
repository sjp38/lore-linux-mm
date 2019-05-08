Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62FB0C04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 01:43:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1ECD205ED
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 01:43:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="O8tU0NT/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1ECD205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E2426B0003; Tue,  7 May 2019 21:43:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36C4C6B0005; Tue,  7 May 2019 21:43:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E5766B0007; Tue,  7 May 2019 21:43:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id DFDCA6B0003
	for <linux-mm@kvack.org>; Tue,  7 May 2019 21:43:42 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id 19so3404163oiq.17
        for <linux-mm@kvack.org>; Tue, 07 May 2019 18:43:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=NduO8ogfu84h+oAWfquIvduxd06JrUFONyQu1hpKcT0=;
        b=i3nUm4XHokpuLsJa8qG5rXrnw1YkvzEJJU+3fTytCcmdjmJtBWtoTKMpDmtw1dup87
         OaXY16SUudrNZWi4oMFfJuphJGTOSq5oOv0v0/01HMdLXESnf90JMTsRyTT1Ok6asewp
         ha1DW6MxqNZ2FqYGdMTMrZDW1HN4ld5PXzaliWtNxli/FrVfnudqvgAVrExInhCmM7s8
         Dv+bogGLPqDMHMQUaCuz7LRfVYYEJnkERFZh1Vujk3YzJi1My/Q13IuOlztAPhbxqoOW
         F/C+IuXi6ZbT6wX2eAuqezOnPrfTuJA5mY3DWlw7hBILcWQOj0+w2aw+/XH06NSFx9dG
         KiNw==
X-Gm-Message-State: APjAAAWK03GkEjbfbkDyfVCLCfrTsgukFIYPgaQbwEFvCK3yW3SkVvkK
	RTR/7T+Fj8wX3QVu1+PngCxgcJ1TyVjsg2n+3iX3T6FK/sGg0c8MbZhbv465n7xQZtfVTushQZA
	KXbBn4TINkRjFa+IVz68AtRaC8O2CwkEOdfHOXRAzrpXZ1Tg+xLkdcaDi9OrnrJmTEA==
X-Received: by 2002:a9d:7102:: with SMTP id n2mr4629102otj.206.1557279822533;
        Tue, 07 May 2019 18:43:42 -0700 (PDT)
X-Received: by 2002:a9d:7102:: with SMTP id n2mr4629060otj.206.1557279821614;
        Tue, 07 May 2019 18:43:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557279821; cv=none;
        d=google.com; s=arc-20160816;
        b=ubtuV55K6YuHhbLn+3d3mzhvP3RjjtSN/FXjc9XX/PsZIy5hSRiOwPGDWNr/I0yPSd
         TPWN4O26/BPbDkDVuMutu8o1pFfBWHJMsn6z5zk3e0r4tw9aQAM6HEHK5YhV3CFDahTm
         3dUmkutjARXOmvhZIZhnHRttN4tW5c6RNNo94e17cNUlC1cKhf4GfEyUH8c9oTNqOAgc
         F3ZHJHotuWH779YbgeMzyiZztIGRtPOXZ1f+4y0YAIGhsn8t9bxnoN0YGklRK252KpeM
         E+1tquqcFLNWga12UkhMZWATr/aA+KSv7d/shK/uBlkcLJJyPJH/amRmcL6eDkH+bSWM
         pDaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=NduO8ogfu84h+oAWfquIvduxd06JrUFONyQu1hpKcT0=;
        b=JXAej6r1JlgjmUKWr0yHtHsh8PAiu9FdUPjLIzyFWat3IVmtxddwIlmyakqPY0LxpS
         KjoSuhiem3+xrhq5cZDcV20jv97jn6E9KcVeLVdfpXiAuZtB2/CYz9FUnBgrnCS2qdb4
         H0Vg6fcLJUnh5P8Ne1hK/SbRh57P3Z1DnGTRotVMPgq2mwRGT+3G03Srj2BcUlwWoD0f
         JrDu7e/eXI7SBlMF8sUiI5qD8HnIhPJ5YIXp1uv0RChrKFDgKhqf3mrUMA40fwt0aKz0
         F5kZ+lZXFCD0j0OTQGJPwQExN3vk2pSZCOVYIUwIP4bQYOAIR4noRiuOuq0aVgQB2BFP
         YDCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="O8tU0NT/";
       spf=pass (google.com: domain of 3tttsxakkcoovebqdnqowsaasxq.oayxuzgj-yywhmow.ads@flex--jsperbeck.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3TTTSXAkKCOoVebQdNQOWSaaSXQ.OaYXUZgj-YYWhMOW.adS@flex--jsperbeck.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id n39sor7161767ota.137.2019.05.07.18.43.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 18:43:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3tttsxakkcoovebqdnqowsaasxq.oayxuzgj-yywhmow.ads@flex--jsperbeck.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="O8tU0NT/";
       spf=pass (google.com: domain of 3tttsxakkcoovebqdnqowsaasxq.oayxuzgj-yywhmow.ads@flex--jsperbeck.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3TTTSXAkKCOoVebQdNQOWSaaSXQ.OaYXUZgj-YYWhMOW.adS@flex--jsperbeck.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=NduO8ogfu84h+oAWfquIvduxd06JrUFONyQu1hpKcT0=;
        b=O8tU0NT/SnusHzYpn83+BS2INjb5OytF8gAd4PLpKrAc9pjd2fZnknioiaczIYOhDJ
         kqmrXrN/YvIGLjts1jSeuSmkp1uTOeINhUa1ucsyXlWwjkjnAeF6m/3YvepnG5i3wttk
         XlHEi3gsXL9QXY2xn8mAR5nCLqTZ3U6q1VSIr1b6u8sJTz3AYVvctLlqrQ9la6PyMSAS
         6jt74pchJ9l4VlKsUNpsjfMCzLz5H7bfGaCezd7vHHTp7Uqo9i+weuqDexDfbARs/oof
         waGeWYqGvHY6RXH6DxKIxzCoZUgbJKTgaiadsPYjNQe3JH6FKp3TQCNROaOVOKI333B8
         5Qpw==
X-Google-Smtp-Source: APXvYqy7YZ/qZ/UMekXTXuLrAXn8JpizuXc1mSFZ4ETgnqDFgY80Xo1eHkGpsnbBKMdktWPM4OzZNXIljJO9vbE=
X-Received: by 2002:a9d:7d88:: with SMTP id j8mr3292175otn.39.1557279821060;
 Tue, 07 May 2019 18:43:41 -0700 (PDT)
Date: Tue,  7 May 2019 18:43:20 -0700
Message-Id: <20190508014320.55404-1-jsperbeck@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH] percpu: remove spurious lock dependency between percpu and sched
From: John Sperbeck <jsperbeck@google.com>
To: Dennis Zhou <dennis@kernel.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <edumazet@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	John Sperbeck <jsperbeck@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In free_percpu() we sometimes call pcpu_schedule_balance_work() to
queue a work item (which does a wakeup) while holding pcpu_lock.
This creates an unnecessary lock dependency between pcpu_lock and
the scheduler's pi_lock.  There are other places where we call
pcpu_schedule_balance_work() without hold pcpu_lock, and this case
doesn't need to be different.

Moving the call outside the lock prevents the following lockdep splat
when running tools/testing/selftests/bpf/{test_maps,test_progs} in
sequence with lockdep enabled:

======================================================
WARNING: possible circular locking dependency detected
5.1.0-dbg-DEV #1 Not tainted
------------------------------------------------------
kworker/23:255/18872 is trying to acquire lock:
000000000bc79290 (&(&pool->lock)->rlock){-.-.}, at: __queue_work+0xb2/0x520

but task is already holding lock:
00000000e3e7a6aa (pcpu_lock){..-.}, at: free_percpu+0x36/0x260

which lock already depends on the new lock.

the existing dependency chain (in reverse order) is:

-> #4 (pcpu_lock){..-.}:
       lock_acquire+0x9e/0x180
       _raw_spin_lock_irqsave+0x3a/0x50
       pcpu_alloc+0xfa/0x780
       __alloc_percpu_gfp+0x12/0x20
       alloc_htab_elem+0x184/0x2b0
       __htab_percpu_map_update_elem+0x252/0x290
       bpf_percpu_hash_update+0x7c/0x130
       __do_sys_bpf+0x1912/0x1be0
       __x64_sys_bpf+0x1a/0x20
       do_syscall_64+0x59/0x400
       entry_SYSCALL_64_after_hwframe+0x49/0xbe

-> #3 (&htab->buckets[i].lock){....}:
       lock_acquire+0x9e/0x180
       _raw_spin_lock_irqsave+0x3a/0x50
       htab_map_update_elem+0x1af/0x3a0

-> #2 (&rq->lock){-.-.}:
       lock_acquire+0x9e/0x180
       _raw_spin_lock+0x2f/0x40
       task_fork_fair+0x37/0x160
       sched_fork+0x211/0x310
       copy_process.part.43+0x7b1/0x2160
       _do_fork+0xda/0x6b0
       kernel_thread+0x29/0x30
       rest_init+0x22/0x260
       arch_call_rest_init+0xe/0x10
       start_kernel+0x4fd/0x520
       x86_64_start_reservations+0x24/0x26
       x86_64_start_kernel+0x6f/0x72
       secondary_startup_64+0xa4/0xb0

-> #1 (&p->pi_lock){-.-.}:
       lock_acquire+0x9e/0x180
       _raw_spin_lock_irqsave+0x3a/0x50
       try_to_wake_up+0x41/0x600
       wake_up_process+0x15/0x20
       create_worker+0x16b/0x1e0
       workqueue_init+0x279/0x2ee
       kernel_init_freeable+0xf7/0x288
       kernel_init+0xf/0x180
       ret_from_fork+0x24/0x30

-> #0 (&(&pool->lock)->rlock){-.-.}:
       __lock_acquire+0x101f/0x12a0
       lock_acquire+0x9e/0x180
       _raw_spin_lock+0x2f/0x40
       __queue_work+0xb2/0x520
       queue_work_on+0x38/0x80
       free_percpu+0x221/0x260
       pcpu_freelist_destroy+0x11/0x20
       stack_map_free+0x2a/0x40
       bpf_map_free_deferred+0x3c/0x50
       process_one_work+0x1f7/0x580
       worker_thread+0x54/0x410
       kthread+0x10f/0x150
       ret_from_fork+0x24/0x30

other info that might help us debug this:

Chain exists of:
  &(&pool->lock)->rlock --> &htab->buckets[i].lock --> pcpu_lock

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(pcpu_lock);
                               lock(&htab->buckets[i].lock);
                               lock(pcpu_lock);
  lock(&(&pool->lock)->rlock);

 *** DEADLOCK ***

3 locks held by kworker/23:255/18872:
 #0: 00000000b36a6e16 ((wq_completion)events){+.+.},
     at: process_one_work+0x17a/0x580
 #1: 00000000dfd966f0 ((work_completion)(&map->work)){+.+.},
     at: process_one_work+0x17a/0x580
 #2: 00000000e3e7a6aa (pcpu_lock){..-.},
     at: free_percpu+0x36/0x260

stack backtrace:
CPU: 23 PID: 18872 Comm: kworker/23:255 Not tainted 5.1.0-dbg-DEV #1
Hardware name: ...
Workqueue: events bpf_map_free_deferred
Call Trace:
 dump_stack+0x67/0x95
 print_circular_bug.isra.38+0x1c6/0x220
 check_prev_add.constprop.50+0x9f6/0xd20
 __lock_acquire+0x101f/0x12a0
 lock_acquire+0x9e/0x180
 _raw_spin_lock+0x2f/0x40
 __queue_work+0xb2/0x520
 queue_work_on+0x38/0x80
 free_percpu+0x221/0x260
 pcpu_freelist_destroy+0x11/0x20
 stack_map_free+0x2a/0x40
 bpf_map_free_deferred+0x3c/0x50
 process_one_work+0x1f7/0x580
 worker_thread+0x54/0x410
 kthread+0x10f/0x150
 ret_from_fork+0x24/0x30

Signed-off-by: John Sperbeck <jsperbeck@google.com>
---
 mm/percpu.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 68dd2e7e73b5..d832793bf83a 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1738,6 +1738,7 @@ void free_percpu(void __percpu *ptr)
 	struct pcpu_chunk *chunk;
 	unsigned long flags;
 	int off;
+	bool need_balance = false;
 
 	if (!ptr)
 		return;
@@ -1759,7 +1760,7 @@ void free_percpu(void __percpu *ptr)
 
 		list_for_each_entry(pos, &pcpu_slot[pcpu_nr_slots - 1], list)
 			if (pos != chunk) {
-				pcpu_schedule_balance_work();
+				need_balance = true;
 				break;
 			}
 	}
@@ -1767,6 +1768,9 @@ void free_percpu(void __percpu *ptr)
 	trace_percpu_free_percpu(chunk->base_addr, off, ptr);
 
 	spin_unlock_irqrestore(&pcpu_lock, flags);
+
+	if (need_balance)
+		pcpu_schedule_balance_work();
 }
 EXPORT_SYMBOL_GPL(free_percpu);
 
-- 
2.21.0.1020.gf2820cf01a-goog

