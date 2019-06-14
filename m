Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 570C2C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 14:21:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C14E20866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 14:21:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XJPmVvUQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C14E20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E7726B026C; Fri, 14 Jun 2019 10:21:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 998306B026D; Fri, 14 Jun 2019 10:21:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 887296B0270; Fri, 14 Jun 2019 10:21:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4FD3E6B026C
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 10:21:06 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i26so1857541pfo.22
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 07:21:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=KUs+eA/7OEbDRmYf6ovajaPBtNHnJudBeV2rHnQKJzg=;
        b=I2YmHa/yhOEDCSjTZ/4krnsPZBr/RVLwNFVSlbSbjP2yX1YabqXHSiEjFnq0q+Q2Vz
         1Rv4+eTNqTn+TLROknN+dGfrYYvuHdSpzYeQJohAbMVYhVypSWqFTMCr4RDkgnfi4FVV
         XpbTh6XYb8TfgexlY98/6ZKoo1ubY/i9O7Q+VZ3uMqE3IFdwsifS3XGgzx9KRpRczpIy
         oTckBHT/hbM5F5GtaNz6oPOSgyUxK8NTRSdDed2vPMe+eeYk+wpkD4KOK0GwJB1i4orc
         lonJI9ZgwVleBQ/yGid9sxbA/kf3xCyUm+lwCI+JKty6j56AafXVkZQ7Q2oX7pv8wgrJ
         nSOQ==
X-Gm-Message-State: APjAAAWqpgmpbhMKAHYoj0DxGm1RUtmpswLPeJkIM1DNw6UFKHwso0iX
	Bdp/lKMFHbKyGmQ5zhyJzf/bvhYJkO9+WrI8kQaxa61w0lACugWV7LCkR4CBrxiZUDQdOytveOa
	qnyvyQbidLVPyXR3te+9kfNgOFpS7gVPE5A4wddgaJfaIK9aasMgNWIEucZqCgDDY0A==
X-Received: by 2002:a63:eb0a:: with SMTP id t10mr32476065pgh.99.1560522065809;
        Fri, 14 Jun 2019 07:21:05 -0700 (PDT)
X-Received: by 2002:a63:eb0a:: with SMTP id t10mr32475978pgh.99.1560522064387;
        Fri, 14 Jun 2019 07:21:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560522064; cv=none;
        d=google.com; s=arc-20160816;
        b=ol+hXywjT8vmykqnFp/9+hMXuLWx9GWr+UXveXeeUU/wbs0lEj1zp11MXEYqx/70e6
         7GM9MnMkmYLgmfEzNqZSGqDfERgApDNMNMAK3V+sgOTEbngTF4BQThdu65V6txtoRUT+
         IK4gl/Fo6Jg8/5jdabxT7iV8lNSGFe3mQQ/dvF5Z0QWvgi0eH7mIpt/yjlV+99lx6x11
         0u2Po4bKNa37sHXV95BNDgYFVVhBfafEVTB+7nH6EYKKqSnS3srGf2I5OIoNt0FP0685
         TtQ8h9otL9aO1ZeXBkNYbibs3l/b0XzIZ007/DAwshaGUCvAargeykjvVKzmgoZjuXYl
         r3DQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=KUs+eA/7OEbDRmYf6ovajaPBtNHnJudBeV2rHnQKJzg=;
        b=DpWmUEkkVZKH+J3tWXUrB8YfcRJkdCnD/3PWvDBj52SZ7RuzqyPjkj8Tnkxq69GLmJ
         r/PC+p66ogKLHGTowuR+sOkSTZ2M1i2y4g+5b6VbAuUFwywKCXXGRRffyP4sb8unZ1kg
         X4CvziKE4ayJjm5LvJoBLov28Ef/szMY8ur7VXSfahNft8GFt4S+N/efvl16FdYhGt8N
         yPvgERVXcATnQAQWAQlS0/jhAL90tk+3ENRG+hhjtiYnI81pPRRE0JD0dI7uMOwx0hDU
         aQSDe08BJPHuS6OoTi0SgZ3kwI2qGNHffJURuFI//8aPPdV1QUFmZ7qBu4DGPUgLm6gy
         iJcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XJPmVvUQ;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z12sor1994500pfa.56.2019.06.14.07.21.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 07:21:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XJPmVvUQ;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=KUs+eA/7OEbDRmYf6ovajaPBtNHnJudBeV2rHnQKJzg=;
        b=XJPmVvUQ+1hIKac+QIqYLd5YFJV7m3YdhgIvmEZAXcG41G4eOhm2u2oNIsU7DLvY1W
         WVowE4mF58jVb5xP+NVxVDB5bfVeY4gRmDrot+tFAO1hRjjNUbn6gyI5NZ56eaZvpT5F
         mWbYLJf2PYdJz5iWhesjqYa9CMv2gL45b1+jjOnL75iIDPe9kOtXP4ywd3eow/H+mJLU
         itVtP6eBTpHRDnV4dIoAzI1GKZnt5OcnXJDiDNzJBa5Xbo8fyS9VfML4BcW9BRO5hcW4
         6eVp12fhWG58yEcNNAfMkLzqB3FDUFRJ9uC6tWHnrpqZIVHMlngUuiwibdy90bx7BNHU
         qvMQ==
X-Google-Smtp-Source: APXvYqwIJ1UQUE6L0loVaP/fryRfeYi1tnk7UQAdoBEKiWevUAiSGZgFy3zetTWz4G5LEPkcOKLZuw==
X-Received: by 2002:aa7:92d2:: with SMTP id k18mr88187pfa.153.1560522064093;
        Fri, 14 Jun 2019 07:21:04 -0700 (PDT)
Received: from localhost.localhost ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id a3sm3709746pje.3.2019.06.14.07.21.01
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 07:21:03 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>,
	Wind Yu <yuzhoujian@didichuxing.com>
Subject: [PATCH] mm/oom_kill: fix uninitialized oc->constraint
Date: Fri, 14 Jun 2019 22:20:38 +0800
Message-Id: <1560522038-15879-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In dump_oom_summary() oc->constraint is used to show
oom_constraint_text, but it hasn't been set before.
So the value of it is always the default value 0.
We should inititialize it before.

Bellow is the output when memcg oom occurs,

before this patch:
[  133.078102] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),
cpuset=/,mems_allowed=0,oom_memcg=/foo,task_memcg=/foo,task=bash,pid=7997,uid=0

after this patch:
[  952.977946] oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null),
cpuset=/,mems_allowed=0,oom_memcg=/foo,task_memcg=/foo,task=bash,pid=13681,uid=0

Fixes: ef8444ea01d7 ("mm, oom: reorganize the oom report in dump_header")
Cc: Wind Yu <yuzhoujian@didichuxing.com>
Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5a58778..f719b64 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -987,8 +987,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 /*
  * Determines whether the kernel must panic because of the panic_on_oom sysctl.
  */
-static void check_panic_on_oom(struct oom_control *oc,
-			       enum oom_constraint constraint)
+static void check_panic_on_oom(struct oom_control *oc)
 {
 	if (likely(!sysctl_panic_on_oom))
 		return;
@@ -998,7 +997,7 @@ static void check_panic_on_oom(struct oom_control *oc,
 		 * does not panic for cpuset, mempolicy, or memcg allocation
 		 * failures.
 		 */
-		if (constraint != CONSTRAINT_NONE)
+		if (oc->constraint != CONSTRAINT_NONE)
 			return;
 	}
 	/* Do not panic for oom kills triggered by sysrq */
@@ -1035,7 +1034,6 @@ int unregister_oom_notifier(struct notifier_block *nb)
 bool out_of_memory(struct oom_control *oc)
 {
 	unsigned long freed = 0;
-	enum oom_constraint constraint = CONSTRAINT_NONE;
 
 	if (oom_killer_disabled)
 		return false;
@@ -1071,10 +1069,10 @@ bool out_of_memory(struct oom_control *oc)
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA and memcg) that may require different handling.
 	 */
-	constraint = constrained_alloc(oc);
-	if (constraint != CONSTRAINT_MEMORY_POLICY)
+	oc->constraint = constrained_alloc(oc);
+	if (oc->constraint != CONSTRAINT_MEMORY_POLICY)
 		oc->nodemask = NULL;
-	check_panic_on_oom(oc, constraint);
+	check_panic_on_oom(oc);
 
 	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
 	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
-- 
1.8.3.1

