Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F8D6C072AD
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:53:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1276E21019
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:53:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1276E21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4561E6B026F; Tue, 21 May 2019 00:53:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36B106B0270; Tue, 21 May 2019 00:53:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20AC16B0271; Tue, 21 May 2019 00:53:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B7EF76B026F
	for <linux-mm@kvack.org>; Tue, 21 May 2019 00:53:46 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g36so28735073edg.8
        for <linux-mm@kvack.org>; Mon, 20 May 2019 21:53:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Sr5AIbnU96HCUMRuw+zzqr1YdIo8+CnQDxY0zvVCgvk=;
        b=aJUwpDA7HgJ43NLE28cPShqdla7smXjX7F42bIYYYzu91F4PAs/jiPjlxKTt8j3gOS
         yyGXIUvRZjJ3R8RF1ZVIT9IaEPcOMuP7a5SUAh8RNWLyaJptVDzNdIOgSjWaMgdiH0UT
         Co6/DKlmBNQZWPsx0diT1j/GacHXHrl8KUhbsC8XJl4y3B3O9xeTxqPrWCQTQFw5+f8P
         jBBgSOjFMWOK6KTMXu5k1iwi02RkODojygTpkVfAiIrkXflWwOn1qD77hz/T7hSt6Wef
         eTIlCuPOnLzs8KpFQljjX97sgTCKyRlaJtcCZjg+9aYwvSIlWJivNyKlus4hQGkYy4EF
         OcPQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAVUiRefH2UVJBKvOVAvAZz2NgKNZZRgURT7q6ew7l9q1nAiJlGx
	4m67B37R1cVZdiup4ehWY/I6duJdJeSAt7BqEBM/nj8udQz33FXy2E4FNh1IImsaOveXUoVSyQK
	34JH4bOE7WoYAuPYwaHHd/QUvE8lVVdxNQB3pFKABAnnrS4kKUct5wjT17M16sRA=
X-Received: by 2002:a50:90dd:: with SMTP id d29mr79658058eda.127.1558414426210;
        Mon, 20 May 2019 21:53:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCZsilJerx1gTNrhI+fTaDTEpqIc/fN9C8lPyNgchsZ6sT2NiIElKWQ+WT1lXGduWPHZ7z
X-Received: by 2002:a50:90dd:: with SMTP id d29mr79657973eda.127.1558414424397;
        Mon, 20 May 2019 21:53:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558414424; cv=none;
        d=google.com; s=arc-20160816;
        b=FBLM/0Wo2QfBUBMaFPj+bZbj05C5bhch0WCa2/tA4bYfk/egBozHy2okGOmoQQeyre
         mgQfTUbwTA/1jnvKdTw5wuTvR9zLlZTaR7yuTTUGoByxQTaC8MpsPMT5oy6Me9lZlykk
         69UxJiYBF2E3DK7WqFI/il5rJ7MBH2k2YmJL+jqX7Hz0la5Tve6rCl4t9BJCcrPru1q6
         0n/cnSw8IbEPKjnIz5cj1/x8m82QYV1wVHMceY8FekYxAo/mLP/bJvknHMfMyC05mNG8
         x7ZUt6T0zSlifaYz1DqHpPKypoqNpTa7FuN30+yzbPx0emHLZOJw6yE2PRV06YEs9mZC
         rOww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Sr5AIbnU96HCUMRuw+zzqr1YdIo8+CnQDxY0zvVCgvk=;
        b=Jz7CIFXdXhUEFEZ886v1I1pMaEZUYzT1sMJiYO6XmwwIjJPQQyMa8o4TykUS/Z7CT3
         1Yf/+b3BCmXf4IKYgTkbptEgYUKlOtdVoXLco6JCClgl4GtkCQKrlBJrSwVhXYTndAcX
         w6+xokIa26x/Vn8CRHFkg584XTyz4HZ+1HnJ9lFA1mJywuRhJYiRKOe3ngnmhWGbxiGQ
         CSoD7KbpIxar7IRcxfS+g20S47wr3ahpqGOCuDmzCq5FePhVM67mz3Fz2D2XJhle1Byn
         KBeX4jP6/0xt6cAehUOMzXLMDpQDirZZ/G8CRHCBZNhbVpWTH6fcFP5Ybs1QaMpNCiwy
         Le1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id l58si15091537edb.163.2019.05.20.21.53.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 21:53:44 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 06:53:43 +0200
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 05:53:21 +0100
From: Davidlohr Bueso <dave@stgolabs.net>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org,
	willy@infradead.org,
	mhocko@kernel.org,
	mgorman@techsingularity.net,
	jglisse@redhat.com,
	ldufour@linux.vnet.ibm.com,
	dave@stgolabs.net,
	Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 12/14] kernel: teach the mm about range locking
Date: Mon, 20 May 2019 21:52:40 -0700
Message-Id: <20190521045242.24378-13-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190521045242.24378-1-dave@stgolabs.net>
References: <20190521045242.24378-1-dave@stgolabs.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Conversion is straightforward, mmap_sem is used within the
the same function context most of the time. No change in
semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 kernel/acct.c               |  5 +++--
 kernel/bpf/stackmap.c       |  7 +++++--
 kernel/events/core.c        |  5 +++--
 kernel/events/uprobes.c     | 20 ++++++++++++--------
 kernel/exit.c               |  9 +++++----
 kernel/fork.c               | 16 ++++++++++------
 kernel/futex.c              |  5 +++--
 kernel/sched/fair.c         |  5 +++--
 kernel/sys.c                | 22 +++++++++++++---------
 kernel/trace/trace_output.c |  5 +++--
 10 files changed, 60 insertions(+), 39 deletions(-)

diff --git a/kernel/acct.c b/kernel/acct.c
index 81f9831a7859..2bbcecbd78ef 100644
--- a/kernel/acct.c
+++ b/kernel/acct.c
@@ -538,14 +538,15 @@ void acct_collect(long exitcode, int group_dead)
 
 	if (group_dead && current->mm) {
 		struct vm_area_struct *vma;
+		DEFINE_RANGE_LOCK_FULL(mmrange);
 
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 		vma = current->mm->mmap;
 		while (vma) {
 			vsize += vma->vm_end - vma->vm_start;
 			vma = vma->vm_next;
 		}
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 	}
 
 	spin_lock_irq(&current->sighand->siglock);
diff --git a/kernel/bpf/stackmap.c b/kernel/bpf/stackmap.c
index 950ab2f28922..fdb352bea7e8 100644
--- a/kernel/bpf/stackmap.c
+++ b/kernel/bpf/stackmap.c
@@ -37,6 +37,7 @@ struct bpf_stack_map {
 struct stack_map_irq_work {
 	struct irq_work irq_work;
 	struct rw_semaphore *sem;
+	struct range_lock *mmrange;
 };
 
 static void do_up_read(struct irq_work *entry)
@@ -291,6 +292,7 @@ static void stack_map_get_build_id_offset(struct bpf_stack_build_id *id_offs,
 	struct vm_area_struct *vma;
 	bool irq_work_busy = false;
 	struct stack_map_irq_work *work = NULL;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (in_nmi()) {
 		work = this_cpu_ptr(&up_read_work);
@@ -309,7 +311,7 @@ static void stack_map_get_build_id_offset(struct bpf_stack_build_id *id_offs,
 	 * with build_id.
 	 */
 	if (!user || !current || !current->mm || irq_work_busy ||
-	    down_read_trylock(&current->mm->mmap_sem) == 0) {
+	    mm_read_trylock(current->mm, &mmrange) == 0) {
 		/* cannot access current->mm, fall back to ips */
 		for (i = 0; i < trace_nr; i++) {
 			id_offs[i].status = BPF_STACK_BUILD_ID_IP;
@@ -334,9 +336,10 @@ static void stack_map_get_build_id_offset(struct bpf_stack_build_id *id_offs,
 	}
 
 	if (!work) {
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 	} else {
 		work->sem = &current->mm->mmap_sem;
+		work->mmrange = &mmrange;
 		irq_work_queue(&work->irq_work);
 		/*
 		 * The irq_work will release the mmap_sem with
diff --git a/kernel/events/core.c b/kernel/events/core.c
index abbd4b3b96c2..3b43cfe63b54 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -9079,6 +9079,7 @@ static void perf_event_addr_filters_apply(struct perf_event *event)
 	struct mm_struct *mm = NULL;
 	unsigned int count = 0;
 	unsigned long flags;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * We may observe TASK_TOMBSTONE, which means that the event tear-down
@@ -9092,7 +9093,7 @@ static void perf_event_addr_filters_apply(struct perf_event *event)
 		if (!mm)
 			goto restart;
 
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 	}
 
 	raw_spin_lock_irqsave(&ifh->lock, flags);
@@ -9118,7 +9119,7 @@ static void perf_event_addr_filters_apply(struct perf_event *event)
 	raw_spin_unlock_irqrestore(&ifh->lock, flags);
 
 	if (ifh->nr_file_filters) {
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 
 		mmput(mm);
 	}
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 3689eceb8d0c..6779c237799a 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -997,6 +997,7 @@ register_for_each_vma(struct uprobe *uprobe, struct uprobe_consumer *new)
 	bool is_register = !!new;
 	struct map_info *info;
 	int err = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	percpu_down_write(&dup_mmap_sem);
 	info = build_map_info(uprobe->inode->i_mapping,
@@ -1013,7 +1014,7 @@ register_for_each_vma(struct uprobe *uprobe, struct uprobe_consumer *new)
 		if (err && is_register)
 			goto free;
 
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, &mmrange);
 		vma = find_vma(mm, info->vaddr);
 		if (!vma || !valid_vma(vma, is_register) ||
 		    file_inode(vma->vm_file) != uprobe->inode)
@@ -1035,7 +1036,7 @@ register_for_each_vma(struct uprobe *uprobe, struct uprobe_consumer *new)
 		}
 
  unlock:
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
  free:
 		mmput(mm);
 		info = free_map_info(info);
@@ -1189,8 +1190,9 @@ static int unapply_uprobe(struct uprobe *uprobe, struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
 	int err = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		unsigned long vaddr;
 		loff_t offset;
@@ -1207,7 +1209,7 @@ static int unapply_uprobe(struct uprobe *uprobe, struct mm_struct *mm)
 		vaddr = offset_to_vaddr(vma, uprobe->offset);
 		err |= remove_breakpoint(uprobe, mm, vaddr);
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	return err;
 }
@@ -1391,10 +1393,11 @@ void uprobe_munmap(struct vm_area_struct *vma, unsigned long start, unsigned lon
 /* Slot allocation for XOL */
 static int xol_add_vma(struct mm_struct *mm, struct xol_area *area)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	struct vm_area_struct *vma;
 	int ret;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	if (mm->uprobes_state.xol_area) {
@@ -1424,7 +1427,7 @@ static int xol_add_vma(struct mm_struct *mm, struct xol_area *area)
 	/* pairs with get_xol_area() */
 	smp_store_release(&mm->uprobes_state.xol_area, area); /* ^^^ */
  fail:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 
 	return ret;
 }
@@ -1993,8 +1996,9 @@ static struct uprobe *find_active_uprobe(unsigned long bp_vaddr, int *is_swbp)
 	struct mm_struct *mm = current->mm;
 	struct uprobe *uprobe = NULL;
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_vma(mm, bp_vaddr);
 	if (vma && vma->vm_start <= bp_vaddr) {
 		if (valid_vma(vma, false)) {
@@ -2012,7 +2016,7 @@ static struct uprobe *find_active_uprobe(unsigned long bp_vaddr, int *is_swbp)
 
 	if (!uprobe && test_and_clear_bit(MMF_RECALC_UPROBES, &mm->flags))
 		mmf_recalc_uprobes(mm);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	return uprobe;
 }
diff --git a/kernel/exit.c b/kernel/exit.c
index 8361a560cd1d..79bc5ec20694 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -497,6 +497,7 @@ static void exit_mm(void)
 {
 	struct mm_struct *mm = current->mm;
 	struct core_state *core_state;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	mm_release(current, mm);
 	if (!mm)
@@ -509,12 +510,12 @@ static void exit_mm(void)
 	 * will increment ->nr_threads for each thread in the
 	 * group with ->mm != NULL.
 	 */
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	core_state = mm->core_state;
 	if (core_state) {
 		struct core_thread self;
 
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 
 		self.task = current;
 		self.next = xchg(&core_state->dumper.next, &self);
@@ -532,14 +533,14 @@ static void exit_mm(void)
 			freezable_schedule();
 		}
 		__set_current_state(TASK_RUNNING);
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 	}
 	mmgrab(mm);
 	BUG_ON(mm != current->active_mm);
 	/* more a memory barrier than a real lock */
 	task_lock(current);
 	current->mm = NULL;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	enter_lazy_tlb(mm, current);
 	task_unlock(current);
 	mm_update_next_owner(mm);
diff --git a/kernel/fork.c b/kernel/fork.c
index 45fde571c5dd..cc24e3690532 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -468,10 +468,12 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 	struct rb_node **rb_link, *rb_parent;
 	int retval;
 	unsigned long charge;
+	DEFINE_RANGE_LOCK_FULL(old_mmrange);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	LIST_HEAD(uf);
 
 	uprobe_start_dup_mmap();
-	if (down_write_killable(&oldmm->mmap_sem)) {
+	if (mm_write_lock_killable(oldmm, &old_mmrange)) {
 		retval = -EINTR;
 		goto fail_uprobe_end;
 	}
@@ -480,7 +482,7 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 	/*
 	 * Not linked in yet - no deadlock potential:
 	 */
-	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
+	mm_write_lock_nested(mm, &mmrange, SINGLE_DEPTH_NESTING);
 
 	/* No ordering required: file already has been exposed. */
 	RCU_INIT_POINTER(mm->exe_file, get_mm_exe_file(oldmm));
@@ -595,9 +597,9 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 	/* a new mm has just been created */
 	retval = arch_dup_mmap(oldmm, mm);
 out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	flush_tlb_mm(oldmm);
-	up_write(&oldmm->mmap_sem);
+	mm_write_unlock(oldmm, &old_mmrange);
 	dup_userfaultfd_complete(&uf);
 fail_uprobe_end:
 	uprobe_end_dup_mmap();
@@ -627,9 +629,11 @@ static inline void mm_free_pgd(struct mm_struct *mm)
 #else
 static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 {
-	down_write(&oldmm->mmap_sem);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
+
+	mm_write_lock(oldmm, &mmrange);
 	RCU_INIT_POINTER(mm->exe_file, get_mm_exe_file(oldmm));
-	up_write(&oldmm->mmap_sem);
+	mm_write_unlock(oldmm, &mmrange);
 	return 0;
 }
 #define mm_alloc_pgd(mm)	(0)
diff --git a/kernel/futex.c b/kernel/futex.c
index 4615f9371a6f..53829040791b 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -730,11 +730,12 @@ static int fault_in_user_writeable(u32 __user *uaddr)
 {
 	struct mm_struct *mm = current->mm;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	ret = fixup_user_fault(current, mm, (unsigned long)uaddr,
 			       FAULT_FLAG_WRITE, NULL, NULL);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	return ret < 0 ? ret : 0;
 }
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index f35930f5e528..222b554bf928 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2461,6 +2461,7 @@ void task_numa_work(struct callback_head *work)
 	struct vm_area_struct *vma;
 	unsigned long start, end;
 	unsigned long nr_pte_updates = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	long pages, virtpages;
 
 	SCHED_WARN_ON(p != container_of(work, struct task_struct, numa_work));
@@ -2512,7 +2513,7 @@ void task_numa_work(struct callback_head *work)
 		return;
 
 
-	if (!down_read_trylock(&mm->mmap_sem))
+	if (!mm_read_trylock(mm, &mmrange))
 		return;
 	vma = find_vma(mm, start);
 	if (!vma) {
@@ -2580,7 +2581,7 @@ void task_numa_work(struct callback_head *work)
 		mm->numa_scan_offset = start;
 	else
 		reset_ptenuma_scan(p);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	/*
 	 * Make sure tasks use at least 32x as much time to run other code
diff --git a/kernel/sys.c b/kernel/sys.c
index bdbfe8d37418..c769293f8a79 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1825,6 +1825,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 	struct file *old_exe, *exe_file;
 	struct inode *inode;
 	int err;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	exe = fdget(fd);
 	if (!exe.file)
@@ -1853,7 +1854,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 	if (exe_file) {
 		struct vm_area_struct *vma;
 
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
 			if (!vma->vm_file)
 				continue;
@@ -1862,7 +1863,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 				goto exit_err;
 		}
 
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		fput(exe_file);
 	}
 
@@ -1876,7 +1877,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 	fdput(exe);
 	return err;
 exit_err:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	fput(exe_file);
 	goto exit;
 }
@@ -1979,6 +1980,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	unsigned long user_auxv[AT_VECTOR_SIZE];
 	struct mm_struct *mm = current->mm;
 	int error;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	BUILD_BUG_ON(sizeof(user_auxv) != sizeof(mm->saved_auxv));
 	BUILD_BUG_ON(sizeof(struct prctl_mm_map) > 256);
@@ -2019,7 +2021,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	 * arg_lock protects concurent updates but we still need mmap_sem for
 	 * read to exclude races with sys_brk.
 	 */
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	/*
 	 * We don't validate if these members are pointing to
@@ -2058,7 +2060,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	if (prctl_map.auxv_size)
 		memcpy(mm->saved_auxv, user_auxv, sizeof(user_auxv));
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return 0;
 }
 #endif /* CONFIG_CHECKPOINT_RESTORE */
@@ -2100,6 +2102,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 	struct prctl_mm_map prctl_map;
 	struct vm_area_struct *vma;
 	int error;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (arg5 || (arg4 && (opt != PR_SET_MM_AUXV &&
 			      opt != PR_SET_MM_MAP &&
@@ -2125,7 +2128,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 
 	error = -EINVAL;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	vma = find_vma(mm, addr);
 
 	prctl_map.start_code	= mm->start_code;
@@ -2218,7 +2221,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 
 	error = 0;
 out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return error;
 }
 
@@ -2266,6 +2269,7 @@ int __weak arch_prctl_spec_ctrl_set(struct task_struct *t, unsigned long which,
 SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 		unsigned long, arg4, unsigned long, arg5)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	struct task_struct *me = current;
 	unsigned char comm[sizeof(me->comm)];
 	long error;
@@ -2441,13 +2445,13 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	case PR_SET_THP_DISABLE:
 		if (arg3 || arg4 || arg5)
 			return -EINVAL;
-		if (down_write_killable(&me->mm->mmap_sem))
+		if (mm_write_lock_killable(me->mm, &mmrange))
 			return -EINTR;
 		if (arg2)
 			set_bit(MMF_DISABLE_THP, &me->mm->flags);
 		else
 			clear_bit(MMF_DISABLE_THP, &me->mm->flags);
-		up_write(&me->mm->mmap_sem);
+		mm_write_unlock(me->mm, &mmrange);
 		break;
 	case PR_MPX_ENABLE_MANAGEMENT:
 		if (arg2 || arg3 || arg4 || arg5)
diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
index 54373d93e251..0dbdab621f17 100644
--- a/kernel/trace/trace_output.c
+++ b/kernel/trace/trace_output.c
@@ -377,8 +377,9 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
 
 	if (mm) {
 		const struct vm_area_struct *vma;
+		DEFINE_RANGE_LOCK_FULL(mmrange);
 
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 		vma = find_vma(mm, ip);
 		if (vma) {
 			file = vma->vm_file;
@@ -390,7 +391,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
 				trace_seq_printf(s, "[+0x%lx]",
 						 ip - vmstart);
 		}
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 	}
 	if (ret && ((sym_flags & TRACE_ITER_SYM_ADDR) || !file))
 		trace_seq_printf(s, " <" IP_FMT ">", ip);
-- 
2.16.4

