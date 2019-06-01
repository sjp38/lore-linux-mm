Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4145AC28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:21:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA82B272F6
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:21:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Sw1QzafS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA82B272F6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 93ABE6B028F; Sat,  1 Jun 2019 09:21:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EC306B0290; Sat,  1 Jun 2019 09:21:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DB1C6B0291; Sat,  1 Jun 2019 09:21:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 460516B028F
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:21:33 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d7so9577695pfq.15
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:21:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZLFxjE0DcmTJMyQgvEAN8OQSv3qSRvCgl8zUYmvI+iE=;
        b=me/aUikJOisr3hdQq8VPXHAprJqzR7heTrpt1AJA2ZIMETnDNa1Pc7oYcAE9HYAJMM
         mCTfiCYn+kxjgN2U4iUSpIwJ337/JxLl0XfD0KQhT1VxcFrJZPkdPljjS/glhDcRXmlM
         nfFhm7k3/IyEh9kMSgfh0jEo5t3a0zsgpBSUy/2EiXKybXWhQpTSibXIlweAeZ3bs7mh
         GgbP4idOQXhAF1QYLB4YxxQnkQvfeXlqouHalhV/5O5DzO67ltkrlqY0NRiKIpVa3CEU
         tnfBy7B0DWy2d0n51QAapgpeL3fTn5ejtm17147ASqVr3vPZRK+RU+EEyLiLDZR+A2ZM
         s4jw==
X-Gm-Message-State: APjAAAWrmVAsFrIGmOoDpx7RZ1TFtqoXbgraxsq5v3RJXt14aqXe701V
	PMBSiJPS9NNhejArrSlzIGzncRUjpKtHrePCnbLwunfkk7074MHS2Bl9C4zn/ursgQqoBjf3ipP
	uoi4hADk3mxozQmHgUVE+SNmIhmCZUJVvtYXeVqf/P/Z1V9TNO/R9N6W83ScwhaFt4w==
X-Received: by 2002:a62:1ec1:: with SMTP id e184mr17300910pfe.185.1559395292891;
        Sat, 01 Jun 2019 06:21:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5AIadE01FstvCgnVmBumHZIuLkW1RYWulxjzI6w+T5VvPPJ0ejv4G9qI2gCLO4V4wRNo1
X-Received: by 2002:a62:1ec1:: with SMTP id e184mr17300824pfe.185.1559395292056;
        Sat, 01 Jun 2019 06:21:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395292; cv=none;
        d=google.com; s=arc-20160816;
        b=xRM7oIPaNuZxrgjFSep+M90bhCVgTVfme2lEF0H1vEQJRY+mz+Fsog89RMPr/sBIZm
         1MuTrmXMxxXD/2PMWL3+IuSfaGNsoWk5YJwOHmW7qK12cUrqquAzeN9DkR07sln/hSXL
         QQ+fX20bpy6dC3IB5IH0sMzIW5RLyNPDArFi7+Nr66oSh7VvQ2Hcvw3Z5oRkdJ5TDKXp
         tfyPeRkVxNxOJviP09bLrQJ0gmkwI6ND9kQYM34tFIeJK8r+skE3klftYU4od85xdxqo
         ZtSWUtOGsK1fSPX9Rt6mh8uLN0JbJlAJbrrecJvpSpAHSn98NrbKHwIXOSmnC/VxQMKe
         ggUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ZLFxjE0DcmTJMyQgvEAN8OQSv3qSRvCgl8zUYmvI+iE=;
        b=YbuFnbXtYfBrTkr3sfEGb0JSiCiILGSOMs8ljlwtz4ftBBBDH+DjBj0gii9P154+jJ
         FkYuY8vUs/2KkuucY5Nx41oYokUgMEIzs+njS4KjS/2cCPpGFjp7nrTPK9Pf84Idxz+p
         gJP9E2L4JSaRZCcnXF2dc3KVEvv/NOHnOJ93j9tbAt/BTwd5LMhqIDpUnhl8N3BYAAwM
         vYAdISkRDfPKcFpKsK1MsBbfgl8+R2bUrkR3/cOzeKer5Mq7z7BWR3uHSRsKnMpNGLdj
         MdZT7Cq3qfqyUpUkCSSvpWLlHNn3Mxlq3TcCY0V/+vVVgX6I5VdEtAMACPxI4H15Zs9u
         6keA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Sw1QzafS;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b17si10579839pfi.32.2019.06.01.06.21.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:21:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Sw1QzafS;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DB96427305;
	Sat,  1 Jun 2019 13:21:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395291;
	bh=SyI3a4Y4WPlHfdSj/wde0sOUv9ueGlk3PAJeMJDAHBE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Sw1QzafS96hU1zkXxZmCWBX4p67woZrr/plFSSt/EChiVv58NWCzetkEkZ6kqd79K
	 k1msuHnqmYQv29YvQox2fQXS+fIlvcqIOZpjGlvPEAb+FTJG+8+hsPHAQ/cxNPEuwq
	 XREzqHC4odykaFz1KlGqW5niJRpL994xHxtwnehI=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: John Sperbeck <jsperbeck@google.com>,
	Dennis Zhou <dennis@kernel.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org,
	netdev@vger.kernel.org,
	bpf@vger.kernel.org
Subject: [PATCH AUTOSEL 5.0 054/173] percpu: remove spurious lock dependency between percpu and sched
Date: Sat,  1 Jun 2019 09:17:26 -0400
Message-Id: <20190601131934.25053-54-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131934.25053-1-sashal@kernel.org>
References: <20190601131934.25053-1-sashal@kernel.org>
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
index 59bd6a51954c9..4ad3a4214249e 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1721,6 +1721,7 @@ void free_percpu(void __percpu *ptr)
 	struct pcpu_chunk *chunk;
 	unsigned long flags;
 	int off;
+	bool need_balance = false;
 
 	if (!ptr)
 		return;
@@ -1742,7 +1743,7 @@ void free_percpu(void __percpu *ptr)
 
 		list_for_each_entry(pos, &pcpu_slot[pcpu_nr_slots - 1], list)
 			if (pos != chunk) {
-				pcpu_schedule_balance_work();
+				need_balance = true;
 				break;
 			}
 	}
@@ -1750,6 +1751,9 @@ void free_percpu(void __percpu *ptr)
 	trace_percpu_free_percpu(chunk->base_addr, off, ptr);
 
 	spin_unlock_irqrestore(&pcpu_lock, flags);
+
+	if (need_balance)
+		pcpu_schedule_balance_work();
 }
 EXPORT_SYMBOL_GPL(free_percpu);
 
-- 
2.20.1

