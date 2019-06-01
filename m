Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26B57C28CC4
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:18:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1142272BA
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:18:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="aAazg0Bu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1142272BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7418B6B0277; Sat,  1 Jun 2019 09:18:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F2766B0279; Sat,  1 Jun 2019 09:18:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E0FE6B027A; Sat,  1 Jun 2019 09:18:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 23EFA6B0277
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:18:56 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s12so6526221plr.5
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:18:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wjLMxnUd2EejU6uvUmJhzcLKz2PMUeFF2bQIERSqwAg=;
        b=no3Er1V0UwaWZeXtV2CbJs8c8TSh0D2s8ML/k5uk7T5kG4P9Gm0NXIuo0n9o2NDN9/
         i/ucpM028Iw+3E2KCLK036W1670kSRbf+HdLJkqLSvt8FakpqVylvr3F8qkcyq0SiUrh
         JIHoBZ80u5vCSUE23/WU3+MQQHrL+t8Vfd3deg3RI2O/xAzxlfz3YP/Ca472imm48AiJ
         I+/7gz0poybvfS0vbjp8MUMZ0OhOLlBd0SCNnPWrM9WGR0Svae+k4kOw5KT/tdOTo4ny
         PgsBkedjHEwF4Xwe4DphE8IZB2ooman7PWK+s4s9dF7TM6M2D76GZVlz9r1dDu1PLmQD
         YP2g==
X-Gm-Message-State: APjAAAVMEgCafUqLwhSPuO5Gr1fVih2VKiqhWBB3vm30zw3rnKI50fQa
	0AZqTjW1bTYhj/94gk8Dg2NbRk1qGLrkodFvirkMJwqXnkkbzm9xcppZNf0D1mOGgLqWaUxbqfZ
	AdKuHy9pdAExvLSl30KKYBGum6aMaUVFhpVIvNlS/iGWri+GiOgwPPINCs3Kh6SGHcw==
X-Received: by 2002:a62:6046:: with SMTP id u67mr17117395pfb.118.1559395135787;
        Sat, 01 Jun 2019 06:18:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0Bm0GtH/vFL+lsJUhj5og9MRSKG5rKPmMZxWYgHdyB9f4tUt4AZkVMWKbbZIZm5UYwDda
X-Received: by 2002:a62:6046:: with SMTP id u67mr17117325pfb.118.1559395135109;
        Sat, 01 Jun 2019 06:18:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395135; cv=none;
        d=google.com; s=arc-20160816;
        b=KB3HM8hdMVq1hwvlp0AV/kB2pDLTMOzVRQxgOI6JhWTMZlyqg752xuen6+MSE8U+UA
         ezcZ1Bppk8WvNU6rP4eQbhD2oOoJLQMnrfHArRDY9hscTjYkyry9vhvLOk2Spacqezhz
         UJHljcxfMIqf2KtWVySMMw5kWe1DZTcVy8/3Dc8XVl34L/46j7RMixLpGn2SfLv+cQAd
         fEZHFGaM3cTK/aCtC5ChjQURvRjKK95jt0b6PSBfM6UVdNT/bfDg87ILvFkXi92PsbUd
         Jw0zvwocF9oeWntNzIo9jg1vbPZDvSPl0nbVPD9IP6TeBJBgWFEGvVX8Vd8IjzbuDswS
         uS4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=wjLMxnUd2EejU6uvUmJhzcLKz2PMUeFF2bQIERSqwAg=;
        b=OMy2BbQxP/oBQWz8nm4zvWJAUZXdcjYQ75n23qIXNIOrz5K+b7h35fyfpftxGudxnn
         T23bT+ubjMLFGMhDann/BpbmgIswnDk+6Ngw45JdrqNecx+Og00okEx2PxXR+bsP59zo
         JgmtTLIEBH4leGnIe2dZCsAiiMc+ySnhaSmcfoNdmDgeED5Vp8G5WsXpZbfcqaYDqEKn
         1ycLL3imkzLIm3dNTwjhZZ/suLcIs5d8nHTsofgRQbgxPO1VNWH7SC61fa+ewR8MbDY8
         lNsNopttRI3WAzswtJJSCgp55K+Bd+WWQG2qXry+T09ZIL84cXrW9/3bxNKU1kbhs9Py
         /DnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=aAazg0Bu;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p5si10181896pls.431.2019.06.01.06.18.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:18:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=aAazg0Bu;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E714027252;
	Sat,  1 Jun 2019 13:18:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395134;
	bh=RsMJ2gpHDXspPAgTj0ik2EwRWy/P72vcnaQQA3/im+g=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=aAazg0BuxDlfRJRT2NAGmCPUf69II0Icsef9WmSTpGxaIRvLN4N6ruaPk/RBep4Gf
	 73tz7TURcpaxDERPSsUyinERj6me/mqHlRODM1Q8Bk7m/yflyoUy8QLudBnkpdQlGL
	 U4ngLRPOMeu1PvOQVklZlBPGud4LRT1yJpMn9/k4=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: John Sperbeck <jsperbeck@google.com>,
	Dennis Zhou <dennis@kernel.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org,
	netdev@vger.kernel.org,
	bpf@vger.kernel.org
Subject: [PATCH AUTOSEL 5.1 057/186] percpu: remove spurious lock dependency between percpu and sched
Date: Sat,  1 Jun 2019 09:14:33 -0400
Message-Id: <20190601131653.24205-57-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131653.24205-1-sashal@kernel.org>
References: <20190601131653.24205-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Sperbeck <jsperbeck@google.com>

[ Upstream commit 198790d9a3aeaef5792d33a560020861126edc22 ]

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
Signed-off-by: Dennis Zhou <dennis@kernel.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/percpu.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 68dd2e7e73b5f..d832793bf83a1 100644
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
2.20.1

