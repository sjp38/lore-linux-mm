Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 141D3C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:54:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8CD421019
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:54:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8CD421019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 186FB6B0278; Tue, 21 May 2019 00:54:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDB536B027C; Tue, 21 May 2019 00:54:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C43966B027A; Tue, 21 May 2019 00:54:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 622B66B0279
	for <linux-mm@kvack.org>; Tue, 21 May 2019 00:54:06 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r20so28682861edp.17
        for <linux-mm@kvack.org>; Mon, 20 May 2019 21:54:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=ikv3JIS8B6O3JMfnljc+EOxnfAL3XxzIKwiJr+31Z2Y=;
        b=AIF2KWRrLtauFPSpYFrisIkvBvzeHG0Is5qh6p4CXLmcYYdM7+3lSWOXk06cyjWIHu
         vislW63PoZXL2UxD9/pQPiHjjFpjaP0n5If3FwECAegRWKVGaOnKxAYJbnyyNpjNtmYY
         yweLn1P58H+WNot6lIxAbhAB4d+10ZiIWO3AQ2mKMLDh9mh/QRjMiK9Jq+0ujq6rYdMg
         btavXl4UZ/n9FID6iZghVm4fBsv6ANKakpG/xFqRCLKzkBfbW4qTEIrgc4+pFGKomo8b
         65vPYe0LWpKtN4+SAZCxdqOW8opIszS8q07l3l2wj0BpgP65LEW9eps9WRblvsRMKWJu
         /1iA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAV1eUFimRTL+3xpH5EzoKbcNXM3yD2bRBp10YDWeZGUTB/Zo+QN
	IHWAs9HWHi0CNO61hGmEGvp68n5h1H70WUM72W2bu7diLZOIQHN4NYnKfeUOo8jkME5NV8BVsEQ
	Sr3Xp2hvdCmbpj3YgqGooMqlBVaPobAmt/nMJ9Gs0k0EdIf7ZsXnjktRpxNoRfUY=
X-Received: by 2002:a50:a535:: with SMTP id y50mr80095670edb.249.1558414445882;
        Mon, 20 May 2019 21:54:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3+T3Jgpw4bJei2aTa9oJwhrPC6RA2aOgLwuKyb7WQFzGTSPo6+R8e2UUdppDIXI6tASA1
X-Received: by 2002:a50:a535:: with SMTP id y50mr80095593edb.249.1558414444367;
        Mon, 20 May 2019 21:54:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558414444; cv=none;
        d=google.com; s=arc-20160816;
        b=xd67ESD5WSzyFZprl2qKI3KR1TPatFJwmtAa3QtGY1u7m2nSC55H3XLkw8e9uP/wvx
         VqgjXCSd8tpgUUHU2BJt9S08Nr+YAE7ktABS0ZViQyxmCFhpJWDqsRAqLTeQsxb7rUNH
         1cQ01d9zxZfJdp9ChsN7O065xNMjBsuMMVKEbqMXsvnH0TGiULMr69HmFXDrUU4uF+1W
         zJrZuTfXkDz7PlddNW+4BprO0XXCPvyOHBt5HwC16z2paQpIBKikC/PPMP8b4Qw/KIq2
         bpCBzMYLcXrgiGFH5/elOMwQDCIYqkd8ihuQo+RO7T7S3EuNEL7D/kZ7mr243jjIIGAB
         jyZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=ikv3JIS8B6O3JMfnljc+EOxnfAL3XxzIKwiJr+31Z2Y=;
        b=v9d19Vw1p8CJjFM866weW+2RQvjhotoGrJhKw29Z2vOlT1OiMc2jlZW2qrh3n6YTnC
         vGqfZyl6jY0JVfN8aIBUShoShvfHaZdrw7COKtJlBXfV7SpuVC8g1bd3arJVm0j6BE+q
         bs+OW+LiDUFHuYSX9GoP5SdDBcgftR6vVqzTW6jlagUpA8dVD287NBobvDh1+dxrw5a2
         w4EEX/kUMz1py44rPn478i6r07io4x5VgS6CuR4Tp2iBWfQTHAkhWKNj3YBALLikvQum
         HfOVK9GQKUItvr0s4ujecFoRl93UKV1cHqoMDA1xK1Jy+asQ2QgBD2sLkn34QEBMBzcz
         mn1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id ov1si1802707ejb.320.2019.05.20.21.54.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 21:54:04 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 06:54:03 +0200
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 05:53:26 +0100
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
Subject: [PATCH 14/14] mm: convert mmap_sem to range mmap_lock
Date: Mon, 20 May 2019 21:52:42 -0700
Message-Id: <20190521045242.24378-15-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190521045242.24378-1-dave@stgolabs.net>
References: <20190521045242.24378-1-dave@stgolabs.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With mmrange now in place and everyone using the mm
locking wrappers, we can convert the rwsem to a the
range locking scheme. Every single user of mmap_sem
will use a full range, which means that there is no
more parallelism than what we already had. This is
the worst case scenario.

Prefetching and some lockdep stuff have been blindly
converted (for now).

This lays out the foundations for later mm address
space locking scalability.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 arch/x86/events/core.c     |  2 +-
 arch/x86/kernel/tboot.c    |  2 +-
 arch/x86/mm/fault.c        |  2 +-
 drivers/firmware/efi/efi.c |  2 +-
 include/linux/mm.h         | 26 +++++++++++++-------------
 include/linux/mm_types.h   |  4 ++--
 kernel/bpf/stackmap.c      |  9 +++++----
 kernel/fork.c              |  2 +-
 mm/init-mm.c               |  2 +-
 mm/memory.c                |  2 +-
 10 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/arch/x86/events/core.c b/arch/x86/events/core.c
index f315425d8468..45ecca077255 100644
--- a/arch/x86/events/core.c
+++ b/arch/x86/events/core.c
@@ -2179,7 +2179,7 @@ static void x86_pmu_event_mapped(struct perf_event *event, struct mm_struct *mm)
 	 * For now, this can't happen because all callers hold mmap_sem
 	 * for write.  If this changes, we'll need a different solution.
 	 */
-	lockdep_assert_held_exclusive(&mm->mmap_sem);
+	lockdep_assert_held_exclusive(&mm->mmap_lock);
 
 	if (atomic_inc_return(&mm->context.perf_rdpmc_allowed) == 1)
 		on_each_cpu_mask(mm_cpumask(mm), refresh_pce, NULL, 1);
diff --git a/arch/x86/kernel/tboot.c b/arch/x86/kernel/tboot.c
index 6e5ef8fb8a02..e5423e2451d3 100644
--- a/arch/x86/kernel/tboot.c
+++ b/arch/x86/kernel/tboot.c
@@ -104,7 +104,7 @@ static struct mm_struct tboot_mm = {
 	.pgd            = swapper_pg_dir,
 	.mm_users       = ATOMIC_INIT(2),
 	.mm_count       = ATOMIC_INIT(1),
-	.mmap_sem       = __RWSEM_INITIALIZER(init_mm.mmap_sem),
+	.mmap_lock       = __RANGE_LOCK_TREE_INITIALIZER(init_mm.mmap_lock),
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
 	.mmlist         = LIST_HEAD_INIT(init_mm.mmlist),
 };
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index fbb060c89e7d..9f285ba76f1e 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1516,7 +1516,7 @@ static noinline void
 __do_page_fault(struct pt_regs *regs, unsigned long hw_error_code,
 		unsigned long address)
 {
-	prefetchw(&current->mm->mmap_sem);
+	prefetchw(&current->mm->mmap_lock);
 
 	if (unlikely(kmmio_fault(regs, address)))
 		return;
diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index 55b77c576c42..01e4937f3cea 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -80,7 +80,7 @@ struct mm_struct efi_mm = {
 	.mm_rb			= RB_ROOT,
 	.mm_users		= ATOMIC_INIT(2),
 	.mm_count		= ATOMIC_INIT(1),
-	.mmap_sem		= __RWSEM_INITIALIZER(efi_mm.mmap_sem),
+	.mmap_lock		= __RANGE_LOCK_TREE_INITIALIZER(efi_mm.mmap_lock),
 	.page_table_lock	= __SPIN_LOCK_UNLOCKED(efi_mm.page_table_lock),
 	.mmlist			= LIST_HEAD_INIT(efi_mm.mmlist),
 	.cpu_bitmap		= { [BITS_TO_LONGS(NR_CPUS)] = 0},
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8bf3e2542047..5ac33c46679f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2899,74 +2899,74 @@ static inline void setup_nr_node_ids(void) {}
 static inline bool mm_is_locked(struct mm_struct *mm,
 				struct range_lock *mmrange)
 {
-	return rwsem_is_locked(&mm->mmap_sem);
+	return range_is_locked(&mm->mmap_lock, mmrange);
 }
 
 /* Reader wrappers */
 static inline int mm_read_trylock(struct mm_struct *mm,
 				  struct range_lock *mmrange)
 {
-	return down_read_trylock(&mm->mmap_sem);
+	return range_read_trylock(&mm->mmap_lock, mmrange);
 }
 
 static inline void mm_read_lock(struct mm_struct *mm,
 				struct range_lock *mmrange)
 {
-	down_read(&mm->mmap_sem);
+	range_read_lock(&mm->mmap_lock, mmrange);
 }
 
 static inline void mm_read_lock_nested(struct mm_struct *mm,
 				       struct range_lock *mmrange, int subclass)
 {
-	down_read_nested(&mm->mmap_sem, subclass);
+	range_read_lock_nested(&mm->mmap_lock, mmrange, subclass);
 }
 
 static inline void mm_read_unlock(struct mm_struct *mm,
 				  struct range_lock *mmrange)
 {
-	up_read(&mm->mmap_sem);
+	range_read_unlock(&mm->mmap_lock, mmrange);
 }
 
 /* Writer wrappers */
 static inline int mm_write_trylock(struct mm_struct *mm,
 				   struct range_lock *mmrange)
 {
-	return down_write_trylock(&mm->mmap_sem);
+	return range_write_trylock(&mm->mmap_lock, mmrange);
 }
 
 static inline void mm_write_lock(struct mm_struct *mm,
 				 struct range_lock *mmrange)
 {
-	down_write(&mm->mmap_sem);
+	range_write_lock(&mm->mmap_lock, mmrange);
 }
 
 static inline int mm_write_lock_killable(struct mm_struct *mm,
 					 struct range_lock *mmrange)
 {
-	return down_write_killable(&mm->mmap_sem);
+	return range_write_lock_killable(&mm->mmap_lock, mmrange);
 }
 
 static inline void mm_downgrade_write(struct mm_struct *mm,
 				      struct range_lock *mmrange)
 {
-	downgrade_write(&mm->mmap_sem);
+	range_downgrade_write(&mm->mmap_lock, mmrange);
 }
 
 static inline void mm_write_unlock(struct mm_struct *mm,
 				   struct range_lock *mmrange)
 {
-	up_write(&mm->mmap_sem);
+	range_write_unlock(&mm->mmap_lock, mmrange);
 }
 
 static inline void mm_write_lock_nested(struct mm_struct *mm,
 					struct range_lock *mmrange,
 					int subclass)
 {
-	down_write_nested(&mm->mmap_sem, subclass);
+	range_write_lock_nest_lock(&(mm)->mmap_lock, mmrange, nest_lock);
 }
 
-#define mm_write_nest_lock(mm, range, nest_lock)		\
-	down_write_nest_lock(&(mm)->mmap_sem, nest_lock)
+#define mm_write_nest_lock(mm, range, nest_lock)			\
+	range_write_lock_nest_lock(&(mm)->mmap_lock, range, nest_lock)
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 1815fbc40926..d82612183a30 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -8,7 +8,7 @@
 #include <linux/list.h>
 #include <linux/spinlock.h>
 #include <linux/rbtree.h>
-#include <linux/rwsem.h>
+#include <linux/range_lock.h>
 #include <linux/completion.h>
 #include <linux/cpumask.h>
 #include <linux/uprobes.h>
@@ -400,7 +400,7 @@ struct mm_struct {
 		spinlock_t page_table_lock; /* Protects page tables and some
 					     * counters
 					     */
-		struct rw_semaphore mmap_sem;
+		struct range_lock_tree mmap_lock;
 
 		struct list_head mmlist; /* List of maybe swapped mm's.	These
 					  * are globally strung together off
diff --git a/kernel/bpf/stackmap.c b/kernel/bpf/stackmap.c
index fdb352bea7e8..44aa74748885 100644
--- a/kernel/bpf/stackmap.c
+++ b/kernel/bpf/stackmap.c
@@ -36,7 +36,7 @@ struct bpf_stack_map {
 /* irq_work to run up_read() for build_id lookup in nmi context */
 struct stack_map_irq_work {
 	struct irq_work irq_work;
-	struct rw_semaphore *sem;
+	struct range_lock_tree *lock;
 	struct range_lock *mmrange;
 };
 
@@ -45,8 +45,9 @@ static void do_up_read(struct irq_work *entry)
 	struct stack_map_irq_work *work;
 
 	work = container_of(entry, struct stack_map_irq_work, irq_work);
-	up_read_non_owner(work->sem);
-	work->sem = NULL;
+	/* XXX we might have to add a non_owner to range lock/unlock */
+	range_read_unlock(work->lock, work->mmrange);
+	work->lock = NULL;
 }
 
 static DEFINE_PER_CPU(struct stack_map_irq_work, up_read_work);
@@ -338,7 +339,7 @@ static void stack_map_get_build_id_offset(struct bpf_stack_build_id *id_offs,
 	if (!work) {
 		mm_read_unlock(current->mm, &mmrange);
 	} else {
-		work->sem = &current->mm->mmap_sem;
+		work->lock = &current->mm->mmap_lock;
 		work->mmrange = &mmrange;
 		irq_work_queue(&work->irq_work);
 		/*
diff --git a/kernel/fork.c b/kernel/fork.c
index cc24e3690532..a063e8703498 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -991,7 +991,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	mm->vmacache_seqnum = 0;
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
-	init_rwsem(&mm->mmap_sem);
+	range_lock_tree_init(&mm->mmap_lock);
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->core_state = NULL;
 	mm_pgtables_bytes_init(mm);
diff --git a/mm/init-mm.c b/mm/init-mm.c
index a787a319211e..35a4be1336c6 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -30,7 +30,7 @@ struct mm_struct init_mm = {
 	.pgd		= swapper_pg_dir,
 	.mm_users	= ATOMIC_INIT(2),
 	.mm_count	= ATOMIC_INIT(1),
-	.mmap_sem	= __RWSEM_INITIALIZER(init_mm.mmap_sem),
+	.mmap_lock	= __RANGE_LOCK_TREE_INITIALIZER(init_mm.mmap_lock),
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
 	.arg_lock	=  __SPIN_LOCK_UNLOCKED(init_mm.arg_lock),
 	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
diff --git a/mm/memory.c b/mm/memory.c
index 8a5f52978893..65f4d5384bef 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4494,7 +4494,7 @@ void __might_fault(const char *file, int line)
 	__might_sleep(file, line, 0);
 #if defined(CONFIG_DEBUG_ATOMIC_SLEEP)
 	if (current->mm)
-		might_lock_read(&current->mm->mmap_sem);
+		might_lock_read(&current->mm->mmap_lock);
 #endif
 }
 EXPORT_SYMBOL(__might_fault);
-- 
2.16.4

