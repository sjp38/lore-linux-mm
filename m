Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45F35C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:11:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2C1B217D9
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:11:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="gpjuknid"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2C1B217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E30A36B027A; Wed, 27 Mar 2019 14:11:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB96E6B027C; Wed, 27 Mar 2019 14:11:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAB8D6B027D; Wed, 27 Mar 2019 14:11:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 62DA76B027A
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:11:15 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id a90so4812169pla.11
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:11:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+T44u5bIU/P3avjmDcSMpYAg984E4STk4hP/54qFw6c=;
        b=cnsPSY8rnqD7B1PSXlP+C36ugnAUdlX5szXUpP7SSXT+YN0TOvhQITX/vRG1yxQBDN
         UANyuOXpWoPDkcQnouOAWFCbzmf09UMYBx8Q3PUV8mbcodQ40DhFFrz4wo93d8ugrVrT
         bGF8LX1Mdx3/OzKXV3Ckr8KwRGZLrkY6l+HJusP5bBVcUfgZKTQ4tC+TpHYJAzM9GC69
         xdJHP8bJn8m4rdWACVFDwa1S0/rsUPXEWHKgMDkIo37GM1bW0VTI4xx2R//BRGIRehaR
         zvlUXTqMy7PC2kkwccIRsrIh3mRUFhdFvE189946yfqIb1GGbIZcA7pfZtRbLMFbMKMb
         6o3A==
X-Gm-Message-State: APjAAAW5OcmMfPWJbaFkIbX/KmtOVMNHFFrv+4oqRv/xZ5eBZ5JzUbxT
	64Gc5Nq0Yn24qt/RiVgmMvxT8E3Z9o1t9/YGVmb1dkVBYkiwmSrFG8BSVDNkgJ6y+rtqJfp2KoI
	XEqDsVlzJZfawRSnFoZj8bZHpMWT19kRdQ3OwMcWlavMYzk2ocqu0jJ44kEYOKNKddQ==
X-Received: by 2002:a17:902:bd96:: with SMTP id q22mr29836913pls.322.1553710275011;
        Wed, 27 Mar 2019 11:11:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzblMgBhJeI0/Pggfq4a2NSf/yaQn1B2prpyx/V39I3OwLNlrlyDAptg7b+OF8HV2ZIfy3C
X-Received: by 2002:a17:902:bd96:: with SMTP id q22mr29836833pls.322.1553710274150;
        Wed, 27 Mar 2019 11:11:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710274; cv=none;
        d=google.com; s=arc-20160816;
        b=X10b6MdpUs115z8Gr4ynfCxzT0a58ZD2eQto3KPx9FB+k6PQ6UuBquSy3FTdg8fL2z
         DwjAfduRfeRQ2geSVCj5DcqsrFfPOxmJB5fleNM+fZzixWUObKU3f9eYkjTO8Z1hTixu
         /QQ91uGmuZVg6DgU6kKf7EdAamjXa2CZs7RXI9Hl11myfH++3q5MNvi8JZjKkF0ASWo7
         yqjjYw+DuVnccHVcKgYBdpmBdDIvZzBp075trUD/HaYZ7OhwKkA5MtB280c9oLYWlhNZ
         /cq8jc1du594b3WlES+5VlE7KGjDgo5cwszc4c5YxWHSJhm6mbOtbFr/DvttOj91X4cp
         I3ZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=+T44u5bIU/P3avjmDcSMpYAg984E4STk4hP/54qFw6c=;
        b=WsFyV5I6i8ZVy01BDtyejWCJQl8KPsoit/wgFDe9nmFcgeLrvFvucU+drpQXexADml
         VMTzja3JxPWFaJmyqT7L+f/xPcz5K524sk/54X4MfrmCjKMBR5Q596arB9C4rayiduY8
         tSROhsGvzbVidnUwBo6daaBJuwrjTFcRqPHyo1I/NhKzrfJULWK5S7MGlkL3MoTU7mVD
         yyihImJkp2RguBLUempC2twVlClsbsABeSBcSMPdv4G5jwX9qPVhZBM1u/QiTBJpFG+T
         QxhDi++tq+codmM7l86W6mMDFmgS+LHZzemfzEmuQ8Q+ahW3YwhB16PH3sDHnfvLhyCU
         z/Kg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=gpjuknid;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y10si19329217pll.142.2019.03.27.11.11.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:11:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=gpjuknid;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4331621741;
	Wed, 27 Mar 2019 18:11:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553710273;
	bh=jjyy72O1VbcZ/3O4FpFKkZSa8zUDlWIVltcMCUYuvQw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=gpjuknidbSXJc9S5Aw5EaotPfirqykXmQx6JegXQ4wSgYuDIo9l6/16f9tFTQGmNu
	 vNhKksITohIjoPkg979h5oddZl9aNmgcPzEAfRqjIR8sRwzpBkRZkWgxTDHAXdcH4R
	 zIOAgvJzdyfwqim2TkPpNUBsQXOrw+J3uCAZztZc=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Yisheng Xie <xieyisheng1@huawei.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 027/192] mm, mempolicy: fix uninit memory access
Date: Wed, 27 Mar 2019 14:07:39 -0400
Message-Id: <20190327181025.13507-27-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327181025.13507-1-sashal@kernel.org>
References: <20190327181025.13507-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Vlastimil Babka <vbabka@suse.cz>

[ Upstream commit 2e25644e8da4ed3a27e7b8315aaae74660be72dc ]

Syzbot with KMSAN reports (excerpt):

==================================================================
BUG: KMSAN: uninit-value in mpol_rebind_policy mm/mempolicy.c:353 [inline]
BUG: KMSAN: uninit-value in mpol_rebind_mm+0x249/0x370 mm/mempolicy.c:384
CPU: 1 PID: 17420 Comm: syz-executor4 Not tainted 4.20.0-rc7+ #15
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x173/0x1d0 lib/dump_stack.c:113
  kmsan_report+0x12e/0x2a0 mm/kmsan/kmsan.c:613
  __msan_warning+0x82/0xf0 mm/kmsan/kmsan_instr.c:295
  mpol_rebind_policy mm/mempolicy.c:353 [inline]
  mpol_rebind_mm+0x249/0x370 mm/mempolicy.c:384
  update_tasks_nodemask+0x608/0xca0 kernel/cgroup/cpuset.c:1120
  update_nodemasks_hier kernel/cgroup/cpuset.c:1185 [inline]
  update_nodemask kernel/cgroup/cpuset.c:1253 [inline]
  cpuset_write_resmask+0x2a98/0x34b0 kernel/cgroup/cpuset.c:1728

...

Uninit was created at:
  kmsan_save_stack_with_flags mm/kmsan/kmsan.c:204 [inline]
  kmsan_internal_poison_shadow+0x92/0x150 mm/kmsan/kmsan.c:158
  kmsan_kmalloc+0xa6/0x130 mm/kmsan/kmsan_hooks.c:176
  kmem_cache_alloc+0x572/0xb90 mm/slub.c:2777
  mpol_new mm/mempolicy.c:276 [inline]
  do_mbind mm/mempolicy.c:1180 [inline]
  kernel_mbind+0x8a7/0x31a0 mm/mempolicy.c:1347
  __do_sys_mbind mm/mempolicy.c:1354 [inline]

As it's difficult to report where exactly the uninit value resides in
the mempolicy object, we have to guess a bit.  mm/mempolicy.c:353
contains this part of mpol_rebind_policy():

        if (!mpol_store_user_nodemask(pol) &&
            nodes_equal(pol->w.cpuset_mems_allowed, *newmask))

"mpol_store_user_nodemask(pol)" is testing pol->flags, which I couldn't
ever see being uninitialized after leaving mpol_new().  So I'll guess
it's actually about accessing pol->w.cpuset_mems_allowed on line 354,
but still part of statement starting on line 353.

For w.cpuset_mems_allowed to be not initialized, and the nodes_equal()
reachable for a mempolicy where mpol_set_nodemask() is called in
do_mbind(), it seems the only possibility is a MPOL_PREFERRED policy
with empty set of nodes, i.e.  MPOL_LOCAL equivalent, with MPOL_F_LOCAL
flag.  Let's exclude such policies from the nodes_equal() check.  Note
the uninit access should be benign anyway, as rebinding this kind of
policy is always a no-op.  Therefore no actual need for stable
inclusion.

Link: http://lkml.kernel.org/r/a71997c3-e8ae-a787-d5ce-3db05768b27c@suse.cz
Link: http://lkml.kernel.org/r/73da3e9c-cc84-509e-17d9-0c434bb9967d@suse.cz
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Reported-by: syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com
Cc: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>
Cc: zhong jiang <zhongjiang@huawei.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/mempolicy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 89d4439516f6..c716ba52fb9e 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -350,7 +350,7 @@ static void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *newmask)
 {
 	if (!pol)
 		return;
-	if (!mpol_store_user_nodemask(pol) &&
+	if (!mpol_store_user_nodemask(pol) && !(pol->flags & MPOL_F_LOCAL) &&
 	    nodes_equal(pol->w.cpuset_mems_allowed, *newmask))
 		return;
 
-- 
2.19.1

