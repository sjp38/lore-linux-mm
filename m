Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF585C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 10:31:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 060F320851
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 10:31:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 060F320851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F0B98E0003; Fri,  1 Mar 2019 05:31:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8782D8E0001; Fri,  1 Mar 2019 05:31:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71B598E0003; Fri,  1 Mar 2019 05:31:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5928E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 05:31:05 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id q21so18540563pfi.17
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 02:31:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=H0Z/VF4qQ44+OlrFcrtn0W0bcnnawA4YW7e5qO1gQLk=;
        b=ipCYib9VQRCxJc6aklr+6f0pmdw1LKj7Z5TEjbyEQZEflM+FGm4Kribf2vWBoqtxym
         uk5K/mITC6hUeXUk1OFTx9OLF22gc2Q8q9GM0/k/xBJZN0Yv0pNbp4uZYjtbigAvRIbu
         6XGVVzdA4Zm+nxaXSFD7i3ppakVFR6c0k32MNrOIj5INGEAWDaz+iduq4mo8of1i6WWB
         9LWPyFz1ixAvniwcQ0DlsHav4qR4GLwnWHFg1y2V8LdMhdM0ZJygsLj8Q6UwTWj5q3DX
         IMKQoAvYIeaSaOab/E7nsbk4KuTi0B9SX8nTN/WO1umgtxQsA0UrzO3d1lnAdewaP36S
         ZmhQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAUaBr9hyl6lWHWIpTx/quRCw9+UvCO6kiEFUoQX6xg8US+A6wWF
	7gow2YfkcDt7Q5Agb6SkbAaEQdtrhzpW4XSorn3jCiQlxzxBT7Hmlo6C1/Z7kDumuLxDJvKC8JF
	4pFhzGTYLyl8HadQvpQRGLrIwNIlvAUZTSdMEbSqt9m7fg50LBv4vroJTu5MxnDyZwQ==
X-Received: by 2002:a63:4962:: with SMTP id y34mr4219272pgk.425.1551436264829;
        Fri, 01 Mar 2019 02:31:04 -0800 (PST)
X-Google-Smtp-Source: APXvYqxm8ThNXSJY1kQAq/vQLzjadhYSM8dWxBeoQzj5rqFcBx2f49VYExZ5B9YBHpImFpRiwLfd
X-Received: by 2002:a63:4962:: with SMTP id y34mr4219186pgk.425.1551436263597;
        Fri, 01 Mar 2019 02:31:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551436263; cv=none;
        d=google.com; s=arc-20160816;
        b=irM+oaOgnobinSXDBVWY2S+D7EKci/UKVro4lz/jE4FEcgz9LY6fZpWu6sNB/6vGor
         QynSDPtkFjuwNmXStxXFDr/btI/EvDuDFNgjwYqd7TGogxJei/ihvqTZfWztToX+Dngb
         NU83WfqXd2NTZ8aQdjur2ePLb4j9pa+iTk36m7QNQpQ8SEUk+/7WEH7AtcJ8HKnU6OkV
         nlffExvheeT8VUuY4knkgevOg4XsUh1Eo3mBMA7xwOIZktKJvH/uufQz4G/yQeT9qFx/
         u1gnpL0nMNz8pg7Q/m8kQkaxgBu9aYt5L7fhlc3q1rZfUU/6j4M8q2rtJlqR5ASIiL0r
         wNZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=H0Z/VF4qQ44+OlrFcrtn0W0bcnnawA4YW7e5qO1gQLk=;
        b=tIwz3LZNWEautGNKrP2TyF0OQagCPrAinuy5MIn7eGhi/2GxxlwNqfhS7s+7tpR2B6
         XGWR8fav37P5oc8XjLuH3BiXb7gflI+Sx/rfL8ze4tUqKdpS4E2tYvDjnFoi1vpJOcF9
         p2CBR3x5gizvvix+so2vjnGV1ugiMAs1FyXXX3s5RywC0APH6Iw2jOiYE1eNU2/YLGKX
         1/PUTCcdzV12faTiNQ0BN49l2WnPyCT0GvfUfDX5UsAQTcQbhO2Du4gYEh8nH5zHFBJ+
         TaE+3m+zA9j6Wru7gENK4yYsI1Wre+jAv9JP68pcqsJtf0uGQRStQACwRDVZaLIDtCN1
         rYyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id v63si19400949pgd.563.2019.03.01.02.31.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 02:31:03 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav403.sakura.ne.jp (fsav403.sakura.ne.jp [133.242.250.102])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x21AUxnx012132;
	Fri, 1 Mar 2019 19:30:59 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav403.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav403.sakura.ne.jp);
 Fri, 01 Mar 2019 19:30:59 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav403.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x21AUsEj012096
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Fri, 1 Mar 2019 19:30:59 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: mm: Can we bail out p?d_alloc() loops upon SIGKILL?
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org
References: <201902270343.x1R3hpZl029621@www262.sakura.ne.jp>
 <20190227092136.GM10588@dhcp22.suse.cz>
 <ccd9e864-0e47-b0e3-8d0e-9431937b604c@i-love.sakura.ne.jp>
 <20190228092641.GW10588@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <f64326a8-092d-0d13-3795-4d01d242379c@i-love.sakura.ne.jp>
Date: Fri, 1 Mar 2019 19:30:54 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190228092641.GW10588@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/02/28 18:26, Michal Hocko wrote:
> We cannot do anything about the preemption so that is moot. ALLOC_OOM
> reserve is limited so the failure should happen sooner or later. But

The problem is that preemption can slowdown ALLOC_OOM allocations (at e.g.
cond_resched() from direct reclaim path). Since concurrently allocating
threads can consume CPU time, the OOM reaper can fail to wait for the OOM
victim to complete (or fail) ALLOC_OOM allocations.

> I would be OK to check for fatal_signal_pending once per pmd or so if
> that helps and it doesn't add a noticeable overhead.

Another option is to scatter __GFP_NOMEMALLOC to allocations which might
be used from fork() path.

> 
>> Technically, it would be possible to use a per task_struct flag
>> which allows __alloc_pages_nodemask() to check early and bail out:
>>
>>   down_write(&current->mm->mmap_sem);
>>   current->no_oom_alloc = 1;
>>   while (...) {
>>       p?d_alloc();
>>   }
>>   current->no_oom_alloc = 0;
>>   up_write(&current->mm->mmap_sem);
> 
> Looks like a hack to me. We already do have __GFP_NOMEMALLOC,
> __GFP_MEMALLOC and PF_MEMALLOC and you want yet another way to control
> access to reserves. This is a mess.

The intention is to fail the allocation as quick as possible rather than
avoid consumption of memory reserves. Since the OOM reaper gives up after
just one second, being able to quickly exit the allocation loop and release
mmap_sem held for write is important for allowing the OOM reaper to reclaim
memory from the OOM victim. (I wish __GFP_KILLABLE were there...)

>                                     If anything then PF_NOMEMALLOC would
> be a better fit but the flag space is quite tight already. Besides that
> is this really worth doing when the caller can bail out?

Scattering __GFP_NOMEMALLOC (like draft patch shown below) reduces frequency of
failing to reclaim memory from the OOM victim. Though it cannot become perfect
because the OOM victim might be still blocked at e.g. down_write() or
cond_resched() in __alloc_pages_nodemask(), callers using GFP_KERNEL_ACCOUNT
allocations could afford __GFP_NOMEMALLOC ?



diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
index a281e61..fef88fb 100644
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -102,7 +102,7 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	struct page *page;
-	gfp_t gfp = GFP_KERNEL_ACCOUNT | __GFP_ZERO;
+	gfp_t gfp = GFP_KERNEL_ACCOUNT | __GFP_ZERO | __GFP_NOMEMALLOC;
 
 	if (mm == &init_mm)
 		gfp &= ~__GFP_ACCOUNT;
@@ -162,7 +162,7 @@ static inline void p4d_populate_safe(struct mm_struct *mm, p4d_t *p4d, pud_t *pu
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	gfp_t gfp = GFP_KERNEL_ACCOUNT;
+	gfp_t gfp = GFP_KERNEL_ACCOUNT | __GFP_NOMEMALLOC;
 
 	if (mm == &init_mm)
 		gfp &= ~__GFP_ACCOUNT;
@@ -202,7 +202,7 @@ static inline void pgd_populate_safe(struct mm_struct *mm, pgd_t *pgd, p4d_t *p4
 
 static inline p4d_t *p4d_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	gfp_t gfp = GFP_KERNEL_ACCOUNT;
+	gfp_t gfp = GFP_KERNEL_ACCOUNT | __GFP_NOMEMALLOC;
 
 	if (mm == &init_mm)
 		gfp &= ~__GFP_ACCOUNT;
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 7bd0170..2a36287 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -21,7 +21,7 @@
 #define PGALLOC_USER_GFP 0
 #endif
 
-gfp_t __userpte_alloc_gfp = PGALLOC_GFP | PGALLOC_USER_GFP;
+gfp_t __userpte_alloc_gfp = PGALLOC_GFP | PGALLOC_USER_GFP | __GFP_NOMEMALLOC;
 
 pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
diff --git a/kernel/fork.c b/kernel/fork.c
index b69248e..57f0b54 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -338,7 +338,7 @@ struct vm_area_struct *vm_area_alloc(struct mm_struct *mm)
 
 struct vm_area_struct *vm_area_dup(struct vm_area_struct *orig)
 {
-	struct vm_area_struct *new = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
+	struct vm_area_struct *new = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL | __GFP_NOMEMALLOC);
 
 	if (new) {
 		*new = *orig;
diff --git a/mm/memory.c b/mm/memory.c
index e11ca9d..0f27d67 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4574,7 +4574,7 @@ bool ptlock_alloc(struct page *page)
 {
 	spinlock_t *ptl;
 
-	ptl = kmem_cache_alloc(page_ptl_cachep, GFP_KERNEL);
+	ptl = kmem_cache_alloc(page_ptl_cachep, GFP_KERNEL | __GFP_NOMEMALLOC);
 	if (!ptl)
 		return false;
 	page->ptl = ptl;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 26ea863..d81b0f8 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -41,6 +41,7 @@
 #include <linux/kthread.h>
 #include <linux/init.h>
 #include <linux/mmu_notifier.h>
+#include <linux/sched/debug.h>
 
 #include <asm/tlb.h>
 #include "internal.h"
@@ -610,6 +611,7 @@ static void oom_reap_task(struct task_struct *tsk)
 
 	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
 		task_pid_nr(tsk), tsk->comm);
+	sched_show_task(tsk);
 	debug_show_all_locks();
 
 done:
diff --git a/mm/rmap.c b/mm/rmap.c
index 0454ecc2..332743c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -270,7 +270,7 @@ int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
 		if (unlikely(!avc)) {
 			unlock_anon_vma_root(root);
 			root = NULL;
-			avc = anon_vma_chain_alloc(GFP_KERNEL);
+			avc = anon_vma_chain_alloc(GFP_KERNEL | __GFP_NOMEMALLOC);
 			if (!avc)
 				goto enomem_failure;
 		}
@@ -341,7 +341,7 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	anon_vma = anon_vma_alloc();
 	if (!anon_vma)
 		goto out_error;
-	avc = anon_vma_chain_alloc(GFP_KERNEL);
+	avc = anon_vma_chain_alloc(GFP_KERNEL | __GFP_NOMEMALLOC);
 	if (!avc)
 		goto out_error_free_anon_vma;
 

