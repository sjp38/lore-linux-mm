Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8D33C06511
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 02:16:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6FDC1218A3
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 02:16:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="so/bqVAc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FDC1218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 100AB6B0003; Tue,  2 Jul 2019 22:16:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08A608E0003; Tue,  2 Jul 2019 22:16:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBCDD8E0001; Tue,  2 Jul 2019 22:16:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B20B56B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 22:16:19 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y5so486290pfb.20
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 19:16:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BgSM6IHsaO52Di3Clxlx9n/zbd2uNGqX7EipFim+04w=;
        b=eyvTL4sxYelfvd4f0pDCJ4t4+AztN+nLOc4gm/yBKux0JaB2FcTtqCtA/2jZNh0i6V
         tZZPCukIo04bM7iJWu1iZ5L6Yd/uMGatblG9+AET/nktOoLA16yJdpceXKPtJ2ub2i+6
         ucUcvST5fJJ1kbwbDQOemjOzu1D4Buikjymf9u2Zt25v/9J0x5ktpdcwttn+KHtJvzS+
         5AAUwPOjyBgwpWQDZHIQgH7yet5p9UW/XihRDb17RGG7rwOXBWevjMyn4rHs6hySFhuO
         dhLZSOgbvzPOSUk8dgMY8zaOBPJCD/B1ny5t/TyuW5DKhURAwaGn/STjqKgvX116WJMg
         vhFw==
X-Gm-Message-State: APjAAAWKgUd5pEiwHO5EWooQD5CMtQ+VL/QHbbd3q79G8X1zA0td6OOE
	BdU8bz5zEXpwBakn9VB7CDAOXepbtgwosHzV+xwSxdIakBAk2Um0QUeb4HZmrtri6m1tjkjGGAn
	7DMzPB50GWcmv9oJe8s3Tqp/kWnyoDQ2T6ECzsGjn7LlNfy6hNO7Ut3luWlbNjZG+Dg==
X-Received: by 2002:a65:454c:: with SMTP id x12mr33956577pgr.354.1562120179097;
        Tue, 02 Jul 2019 19:16:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1FvOHdXYob8uuxQhAiyqaH9ybXklPfeBxEoaBbyWGi5vgh3zLR5ar4nkKNJCe3g4O+UJq
X-Received: by 2002:a65:454c:: with SMTP id x12mr33956511pgr.354.1562120178333;
        Tue, 02 Jul 2019 19:16:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562120178; cv=none;
        d=google.com; s=arc-20160816;
        b=BV1me1Z2FGEd5A01X9nHDlfYokJEG4b09o3k4Dw0ZNxC8X1WNTbMZVtxs+mXUaQfK5
         o2TnRka7DAnrmU0kiXK6N8bPsCvTyDWuVAKAUJBqhnxysrhTZWEWagjS1ZMvkPMOBn54
         yQ38w/htUYC7nvDvgNeHaYbxxKDQW+vpqObODdTdxXk8biIGXZcRIkykQ8mcpFbHhWpD
         aarnrBddlkwDcdHKjbdR3j48RKRrFWyfTTi/Fj9UbPKWGrkJ80QwY33ui8PcUqPgB/8Z
         yA18npfUFQLLFyP+at+S7VUrZwWRJAcwo4c2IzPY2+Jes2fC404c4V53oYSC7uljaDxy
         KPEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=BgSM6IHsaO52Di3Clxlx9n/zbd2uNGqX7EipFim+04w=;
        b=m6Pikli++VTaoVNJvZqQHevDVXL7kJV1WYhfOCm0ukpcI6p5M8xel4bmwNu8sY+XKI
         /Ow1mrY0P2zrSLft/PHBGgq7xub0yfG7hQRHAVWC6KkzcGLzyz4bMPizIRHEGzSUZVvo
         v+ZZaan+Oh+JF4V9IfNRDgVeWGhABYH5/BnP62ifI2JvbXDnbQ359pQScLQhUOcmzIhT
         k8YRbwI4kgaYnKR/YpFwso3M7OEBBrj8fP+VzwqcnuozZaiaKS+u+iykYs8hYc3Dbpu/
         0NF5aXI/9SlBP/WJAhg6Lb/01AoTCqTaR5L6zuZgme9f4la8HHsqA6zJH4BYftcbIO22
         2TDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="so/bqVAc";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 32si600853plb.86.2019.07.02.19.16.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 19:16:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="so/bqVAc";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1253A2187F;
	Wed,  3 Jul 2019 02:16:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562120178;
	bh=0VqhOrySUpgW0ddkrrcTG2M+nPD6bjN6ICpW5L0wvWw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=so/bqVAcjFTT3cgV0vgcX76LQO1yvZo/p22MmF9G1Y6/HJqn66DsuzkWvDCUZFHP6
	 YMOVj2HVGXOp9cYMVmQr1XIgUpmeWHLA+plw56h3gVHdaLvfFGTAUHrt4xesAtxyGw
	 wmUHyntC1zbfIQRr8E6oq5hL4RKbP+y7lB+6FHQs=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Yafang Shao <laoar.shao@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Wind Yu <yuzhoujian@didichuxing.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.1 37/39] mm/oom_kill.c: fix uninitialized oc->constraint
Date: Tue,  2 Jul 2019 22:15:12 -0400
Message-Id: <20190703021514.17727-37-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190703021514.17727-1-sashal@kernel.org>
References: <20190703021514.17727-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yafang Shao <laoar.shao@gmail.com>

[ Upstream commit 432b1de0de02a83f64695e69a2d83cbee10c236f ]

In dump_oom_summary() oc->constraint is used to show oom_constraint_text,
but it hasn't been set before.  So the value of it is always the default
value 0.  We should inititialize it before.

Bellow is the output when memcg oom occurs,

before this patch:
  oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null), cpuset=/,mems_allowed=0,oom_memcg=/foo,task_memcg=/foo,task=bash,pid=7997,uid=0

after this patch:
  oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null), cpuset=/,mems_allowed=0,oom_memcg=/foo,task_memcg=/foo,task=bash,pid=13681,uid=0

Link: http://lkml.kernel.org/r/1560522038-15879-1-git-send-email-laoar.shao@gmail.com
Fixes: ef8444ea01d7 ("mm, oom: reorganize the oom report in dump_header")
Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Wind Yu <yuzhoujian@didichuxing.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/oom_kill.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3a2484884cfd..263efad6fc7e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -985,8 +985,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 /*
  * Determines whether the kernel must panic because of the panic_on_oom sysctl.
  */
-static void check_panic_on_oom(struct oom_control *oc,
-			       enum oom_constraint constraint)
+static void check_panic_on_oom(struct oom_control *oc)
 {
 	if (likely(!sysctl_panic_on_oom))
 		return;
@@ -996,7 +995,7 @@ static void check_panic_on_oom(struct oom_control *oc,
 		 * does not panic for cpuset, mempolicy, or memcg allocation
 		 * failures.
 		 */
-		if (constraint != CONSTRAINT_NONE)
+		if (oc->constraint != CONSTRAINT_NONE)
 			return;
 	}
 	/* Do not panic for oom kills triggered by sysrq */
@@ -1033,7 +1032,6 @@ EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 bool out_of_memory(struct oom_control *oc)
 {
 	unsigned long freed = 0;
-	enum oom_constraint constraint = CONSTRAINT_NONE;
 
 	if (oom_killer_disabled)
 		return false;
@@ -1069,10 +1067,10 @@ bool out_of_memory(struct oom_control *oc)
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
2.20.1

