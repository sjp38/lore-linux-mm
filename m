Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E34BAC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:16:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B86B20B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:16:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="DzuN0SMd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B86B20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84E956B000E; Tue,  6 Aug 2019 19:16:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 636FE6B026B; Tue,  6 Aug 2019 19:16:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B0646B0010; Tue,  6 Aug 2019 19:16:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 166166B0010
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 19:16:19 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id s22so80308648qtb.22
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 16:16:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JxsVo1tSo9nOofaC+CW71G9A/3jHBgy7XZ2Y+iDU6wk=;
        b=uTc8Ahom1cnHgnzgHIAoGn2LluLZz53bfP5h8Lm9MACqKnQ9d3VLIh7Tfcy3bsDL3W
         lfx+T2d8WpoXq6s2N9jck/qSGwCgDV/6XuHtwAK56fiwY7yxD3jXCLV80G+SSbXPstm1
         Ghhpk+oSCuEosu4Gk1KSScz+JckUzk9FpMnMfqql/nMjib8Mn9dbIet772egwt6pQUpk
         ZGjN91a3odb43jO7h3ZWDSbmL9JsEKkZgUgITozouHgxcC+kudAPaxfV4dbKujuSkARi
         22Ji/SUxHQZBuhtaPW7qUxNtw1AT/Eknzyn2Wo9ZRIJYAHfzOyIJZBhEf7RQaGeCHiVY
         1+Wg==
X-Gm-Message-State: APjAAAVqBOe7QzjUGbapYYo5HfRwNrrLinLlMKuMjmQoDgTHk9iL+5Hj
	FIDYWNlU7AXZLRMX9xCX/xGQEglC9FV/8X8QuyybZFkMtyWH/8kTnXUztAN2bYTeSc5GJKDxXao
	1td4xfgera00z3SrFmjikfmGGtpZg7dSudAlZjo7H2xdzdw7bJ3m/mwKboO93qjRw7w==
X-Received: by 2002:ac8:1418:: with SMTP id k24mr5231134qtj.54.1565133378866;
        Tue, 06 Aug 2019 16:16:18 -0700 (PDT)
X-Received: by 2002:ac8:1418:: with SMTP id k24mr5231080qtj.54.1565133377704;
        Tue, 06 Aug 2019 16:16:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565133377; cv=none;
        d=google.com; s=arc-20160816;
        b=q26GJFyi8DjBsqTjryNBpFhGGQ4wmpmFZyiRpOpUhY498zsfGRvOKHGq11hMpHtNQV
         NLO2jDYH0uTSZISZlRYKKHPZ3MDZI1x6q01lS4d+t4xPZ+iUDtJP4C88WF9Z/RCU/vbk
         7NUr4xSqvcBwf6qio9HTu+cp1KGFY259Y8QXXOWhmoIK5rwMhVQFQ1UUwGPmpVwjB9yz
         vzYmnxSz7c23lsA8wXTWlWKO8eyOzVpWlE8DSyqCr4/v7N7wEbLCLRKYlFjxpiwSu1cx
         EhZ/PWQWCFzb7AkpFWiUI4Dv0sFXKk6tNh/o0l2tPEjQm+ccyvWsYd7elT2TB6uZup4C
         hoQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=JxsVo1tSo9nOofaC+CW71G9A/3jHBgy7XZ2Y+iDU6wk=;
        b=A//8xwuSxl8izmmmzuNyLCpHFliIuFlv6z9CkbjFU2uSgPh/LDSwbb5VfIgn5wH73i
         OwGLBQOx1DBVDjt7HkW9GYPmrYhSPsV7PSxmiVB5EG6pdja/+4oH8N0FH8RHrOSNHB9R
         fANMEd8gFY7LTsIKLQ/U7WgbAgvTv6CQwh0yBCM2lKoQ5yluIxyMlHyd6/BlTWRXopkx
         kGbhVwo/dZnZpRBQJw6owg1vLMCBrTLJyDJdzUHnOUprV/7WXrpi6n2ApcqHTDB8WU//
         dx8GU3gv1RcEMBtVgLYUni08+iTtYskSgefMuvxCiwcAevOz8snnT4kUgoaW7VHiIQvr
         yKAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=DzuN0SMd;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c8sor116877792qtc.13.2019.08.06.16.16.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 16:16:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=DzuN0SMd;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=JxsVo1tSo9nOofaC+CW71G9A/3jHBgy7XZ2Y+iDU6wk=;
        b=DzuN0SMd6m3Y09EQ3hGtHT0JB2aJvet1X6xSjLP8soFwijScUkjfei+cE2aizwyqi8
         8Jha5XC787VVWgoXYljT8xUpYPYOFigvSiU+1J03D3b5wV89VGY0fRB+2O+s8PxEW8Cc
         XHLP7NRjVVVDcyhUMTRcguAhGAT3GgYfCIM3KKJYjCw6SRWgG0LgRecPMWYG/h7iyqhL
         SibXtCYOyQ2FlxTLqndgSo2yQc+yBvh9wTZCUo6uritT4lvyCwq2m+CMyMiFrNowhMlw
         wZUotLzWJuJo3OH1QCGYmHg/VKilwJSVIFt6wDKRQhIZCMQPFq5BgAju/1yQr1cKLEEf
         ycrA==
X-Google-Smtp-Source: APXvYqxBbEyHGgxF5Nl8cVhIwdz1mu4o1neH5++dyqiahCeO4T26lyxvhtz3KCxPPf/9Z4FNDxc5Wg==
X-Received: by 2002:aed:3ac1:: with SMTP id o59mr5389656qte.260.1565133377305;
        Tue, 06 Aug 2019 16:16:17 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id b13sm52681923qtk.55.2019.08.06.16.16.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 16:16:17 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hv8gg-0006f4-G2; Tue, 06 Aug 2019 20:16:14 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>,
	Christoph Hellwig <hch@lst.de>,
	John Hubbard <jhubbard@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"Kuehling, Felix" <Felix.Kuehling@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Dimitri Sivanich <sivanich@sgi.com>,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	intel-gfx@lists.freedesktop.org,
	Gavin Shan <shangw@linux.vnet.ibm.com>,
	Andrea Righi <andrea@betterlinux.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v3 hmm 09/11] drm/amdkfd: fix a use after free race with mmu_notifer unregister
Date: Tue,  6 Aug 2019 20:15:46 -0300
Message-Id: <20190806231548.25242-10-jgg@ziepe.ca>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190806231548.25242-1-jgg@ziepe.ca>
References: <20190806231548.25242-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

When using mmu_notifer_unregister_no_release() the caller must ensure
there is a SRCU synchronize before the mn memory is freed, otherwise use
after free races are possible, for instance:

     CPU0                                      CPU1
                                      invalidate_range_start
                                         hlist_for_each_entry_rcu(..)
 mmu_notifier_unregister_no_release(&p->mn)
 kfree(mn)
                                      if (mn->ops->invalidate_range_end)

The error unwind in amdkfd misses the SRCU synchronization.

amdkfd keeps the kfd_process around until the mm is released, so split the
flow to fully initialize the kfd_process and register it for find_process,
and with the notifier. Past this point the kfd_process does not need to be
cleaned up as it is fully ready.

The final failable step does a vm_mmap() and does not seem to impact the
kfd_process global state. Since it also cannot be undone (and already has
problems with undo if it internally fails), it has to be last.

This way we don't have to try to unwind the mmu_notifier_register() and
avoid the problem with the SRCU.

Along the way this also fixes various other error unwind bugs in the flow.

Fixes: 45102048f77e ("amdkfd: Add process queue manager module")
Reviewed-by: Felix Kuehling <Felix.Kuehling@amd.com>
Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 drivers/gpu/drm/amd/amdkfd/kfd_process.c | 78 +++++++++++-------------
 1 file changed, 37 insertions(+), 41 deletions(-)

diff --git a/drivers/gpu/drm/amd/amdkfd/kfd_process.c b/drivers/gpu/drm/amd/amdkfd/kfd_process.c
index 8f1076c0c88a25..c06e6190f21ffa 100644
--- a/drivers/gpu/drm/amd/amdkfd/kfd_process.c
+++ b/drivers/gpu/drm/amd/amdkfd/kfd_process.c
@@ -62,8 +62,8 @@ static struct workqueue_struct *kfd_restore_wq;
 
 static struct kfd_process *find_process(const struct task_struct *thread);
 static void kfd_process_ref_release(struct kref *ref);
-static struct kfd_process *create_process(const struct task_struct *thread,
-					struct file *filep);
+static struct kfd_process *create_process(const struct task_struct *thread);
+static int kfd_process_init_cwsr_apu(struct kfd_process *p, struct file *filep);
 
 static void evict_process_worker(struct work_struct *work);
 static void restore_process_worker(struct work_struct *work);
@@ -289,7 +289,15 @@ struct kfd_process *kfd_create_process(struct file *filep)
 	if (process) {
 		pr_debug("Process already found\n");
 	} else {
-		process = create_process(thread, filep);
+		process = create_process(thread);
+		if (IS_ERR(process))
+			goto out;
+
+		ret = kfd_process_init_cwsr_apu(process, filep);
+		if (ret) {
+			process = ERR_PTR(ret);
+			goto out;
+		}
 
 		if (!procfs.kobj)
 			goto out;
@@ -609,81 +617,69 @@ static int kfd_process_device_init_cwsr_dgpu(struct kfd_process_device *pdd)
 	return 0;
 }
 
-static struct kfd_process *create_process(const struct task_struct *thread,
-					struct file *filep)
+/*
+ * On return the kfd_process is fully operational and will be freed when the
+ * mm is released
+ */
+static struct kfd_process *create_process(const struct task_struct *thread)
 {
 	struct kfd_process *process;
 	int err = -ENOMEM;
 
 	process = kzalloc(sizeof(*process), GFP_KERNEL);
-
 	if (!process)
 		goto err_alloc_process;
 
-	process->pasid = kfd_pasid_alloc();
-	if (process->pasid == 0)
-		goto err_alloc_pasid;
-
-	if (kfd_alloc_process_doorbells(process) < 0)
-		goto err_alloc_doorbells;
-
 	kref_init(&process->ref);
-
 	mutex_init(&process->mutex);
-
 	process->mm = thread->mm;
-
-	/* register notifier */
-	process->mmu_notifier.ops = &kfd_process_mmu_notifier_ops;
-	err = mmu_notifier_register(&process->mmu_notifier, process->mm);
-	if (err)
-		goto err_mmu_notifier;
-
-	hash_add_rcu(kfd_processes_table, &process->kfd_processes,
-			(uintptr_t)process->mm);
-
 	process->lead_thread = thread->group_leader;
-	get_task_struct(process->lead_thread);
-
 	INIT_LIST_HEAD(&process->per_device_data);
-
+	INIT_DELAYED_WORK(&process->eviction_work, evict_process_worker);
+	INIT_DELAYED_WORK(&process->restore_work, restore_process_worker);
+	process->last_restore_timestamp = get_jiffies_64();
 	kfd_event_init_process(process);
+	process->is_32bit_user_mode = in_compat_syscall();
+
+	process->pasid = kfd_pasid_alloc();
+	if (process->pasid == 0)
+		goto err_alloc_pasid;
+
+	if (kfd_alloc_process_doorbells(process) < 0)
+		goto err_alloc_doorbells;
 
 	err = pqm_init(&process->pqm, process);
 	if (err != 0)
 		goto err_process_pqm_init;
 
 	/* init process apertures*/
-	process->is_32bit_user_mode = in_compat_syscall();
 	err = kfd_init_apertures(process);
 	if (err != 0)
 		goto err_init_apertures;
 
-	INIT_DELAYED_WORK(&process->eviction_work, evict_process_worker);
-	INIT_DELAYED_WORK(&process->restore_work, restore_process_worker);
-	process->last_restore_timestamp = get_jiffies_64();
-
-	err = kfd_process_init_cwsr_apu(process, filep);
+	/* Must be last, have to use release destruction after this */
+	process->mmu_notifier.ops = &kfd_process_mmu_notifier_ops;
+	err = mmu_notifier_register(&process->mmu_notifier, process->mm);
 	if (err)
-		goto err_init_cwsr;
+		goto err_register_notifier;
+
+	get_task_struct(process->lead_thread);
+	hash_add_rcu(kfd_processes_table, &process->kfd_processes,
+			(uintptr_t)process->mm);
 
 	return process;
 
-err_init_cwsr:
+err_register_notifier:
 	kfd_process_free_outstanding_kfd_bos(process);
 	kfd_process_destroy_pdds(process);
 err_init_apertures:
 	pqm_uninit(&process->pqm);
 err_process_pqm_init:
-	hash_del_rcu(&process->kfd_processes);
-	synchronize_rcu();
-	mmu_notifier_unregister_no_release(&process->mmu_notifier, process->mm);
-err_mmu_notifier:
-	mutex_destroy(&process->mutex);
 	kfd_free_process_doorbells(process);
 err_alloc_doorbells:
 	kfd_pasid_free(process->pasid);
 err_alloc_pasid:
+	mutex_destroy(&process->mutex);
 	kfree(process);
 err_alloc_process:
 	return ERR_PTR(err);
-- 
2.22.0

