Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0A39C4151A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 11:29:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CBC32073D
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 11:29:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fBMsPRyi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CBC32073D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECC0E8E0003; Wed, 13 Feb 2019 06:29:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7CFB8E0001; Wed, 13 Feb 2019 06:29:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6BFD8E0003; Wed, 13 Feb 2019 06:29:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 962698E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:29:15 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id k10so1682091pfi.5
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 03:29:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=ZP4eZYg4uMuESOTns7x6z0Gns1FpDtn/SzQe1DyPZ2c=;
        b=b9iIdk6QQiUSU5bYwaX0njCBIQ+fL45muE/tHsa3pwinAn7olnvSRQDYERQOb2kSPs
         k8oxGiaYqd6yOEKz+rgnP38nbIXXaMXjdFF42yCRzbMPhmEymUsLyCOC6gWkRBmtp2Qm
         vQ3hbYVsAcGQhqLg8Xb2X9FsIUUlHYfUKWUDck3BABBnTOfP9Zwq3XKkAxpjcXYt0/t1
         1C4lYZVCuS2+qXjswtbD1lEP+6vLJ8Hz6FTWc0gjIl7a22kX0yj52uh11VwLrTHeFme3
         3HKw+fUY/xayUJcNiLl4AfNZm6Fp7C68LmB+pUUTgjFfUi/T/BifxsDrP71JxHTPjVHb
         nJpA==
X-Gm-Message-State: AHQUAuYlOcuImv02RNMeq+8LydzJH5AlHYG1/0+ebtBP2b+r8a6YyKXK
	Ht6SylJbOEptre4l62ksX51hKhrM3MKbwrNwSY27ma2JNkeHS/BwxYCZL4iLrWjcgA60lu2RlAS
	0UM8nYRPrEIdgueb2vmvQIUS372Cu4x1bVXeCksIxZX31uk86xZlb3Bfg//aWTv3lWYlqwcE4TD
	n3HUz7Ow/gUN3PpFEfOrrv9MjF62tmEOxYhcRYyWuk3QvkJ988u7uOqG0Xle+gI8cvRxmmZsbCt
	TaU5VdPFTs+Tcbape42FXCiA399IjZxgSbjlViGmEJlsUsoiM1Ll2jnrm5z0YEosTYoouY36UYF
	utQR2GYe3hZXJCww72yqBNPWtweQJns7sAVLzn+81OwTlKiPFfdfh+jsQff9s6/AtieOyViJYQ=
	=
X-Received: by 2002:a63:ce45:: with SMTP id r5mr29377pgi.112.1550057355158;
        Wed, 13 Feb 2019 03:29:15 -0800 (PST)
X-Received: by 2002:a63:ce45:: with SMTP id r5mr29311pgi.112.1550057354216;
        Wed, 13 Feb 2019 03:29:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550057354; cv=none;
        d=google.com; s=arc-20160816;
        b=1Bs6aU2c1Wzzfnf81XJHjy3lXb9kJ556gICF0nggKV930S9Yk1RrRAYGbQ9iOlC5KY
         xaKXT2GORrQUzgJh1B3+HtzJeqimQ8XyzcpdTt8ggZUdumz2YXMFR5NDVa0kzu0WyHKr
         G7/dvHkMQYuIsjo/1hzThN4lwc0BZ8SUtPJF5eZQobHxAsr+5Qzu25/iZxzT+smM0aCJ
         iNUXXRM7eQGeVD0ZNEN4fBPH0Nc1A/bBS3gES54kN/ReelCkIfxUkKJSQRk5GCPM2cyK
         3fsELJzmeBdTaPh17WDYcoIZmgyuC7dfbkcRdNa3d0AQ/jMn+KCquv+oma9aFf3+n5tK
         3xFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:sender:dkim-signature;
        bh=ZP4eZYg4uMuESOTns7x6z0Gns1FpDtn/SzQe1DyPZ2c=;
        b=jWhpJgCUsP8mnyoQYX3naD7p5XUf6Uqu2kMuB2pZdS2a0JEYWIe8cUPo0R6TFZ+Pdw
         OcLeWOumFkE9MbMBqTnmikxizgbntE7QULET9s1sqbkBh1/laL743EYXtQb2eIyJQsrv
         /HHqAvNCGqhAp9KbHn08XghkWT/iCmQn3cLG2Zzy1mPHKr/Z3eL2MwW9nsu3RjKLOXFV
         loms/H2K1R7GBaFS0nYeydizgIrgJeYUChudzZ5z1c6Zp6KSBLRqIuimAjSvJfr8hYIk
         4zqLBWtyVZI2vCmL5/ukTwI/oQajop6deJtp73Ji69Sr1/j7CKLpR4e18BErTAzmiZQY
         CBcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fBMsPRyi;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g10sor23185861pgq.32.2019.02.13.03.29.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 03:29:14 -0800 (PST)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fBMsPRyi;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ZP4eZYg4uMuESOTns7x6z0Gns1FpDtn/SzQe1DyPZ2c=;
        b=fBMsPRyi5W07JhLDu6G7haXyioP2Nu9geoYYaXXao12x4/GcGBKANyupnDaTtheYrx
         CBRu4eUMgDG8Imk1kCi7cLRQhdjs9hYBR6XrREMCo+ul2XWUK07iJSzf0RrzfmuKWl6D
         HmS6ZH84nN8L6FYoydqnzV+FOQabKtRzxrGfCe9sxFsgqjFJmA4gV1ZwOYqz/ltjabEb
         vDmM6fGwz/iR5z+iESZj4VVrl8ZOzr7SmlMVqPiUmifjPRavafgaKH7nL1UkhWF0IOdg
         aYwymCh4A6LcwzdeTZkgYtiP5T3CwARnboi65AmwqmbV4djTXFhq+iF1kPdbFDE/6klb
         d7Mg==
X-Google-Smtp-Source: AHgI3IazGpHnKo0uva+QDysHCoFLMqAktO841uduCRt0cTupKZWBIYuAxV8TGgMRyaYbmf6asGY5SA==
X-Received: by 2002:a63:5813:: with SMTP id m19mr12411pgb.294.1550057353027;
        Wed, 13 Feb 2019 03:29:13 -0800 (PST)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id e19sm6968911pfn.145.2019.02.13.03.29.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 03:29:11 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
To: gregkh@linuxfoundation.org
Cc: linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Minchan Kim <minchan@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Hugh Dickins <hughd@google.com>,
	Liu Bo <bo.liu@linux.alibaba.com>,
	stable@vger.kernel.org
Subject: [PATCH] mm: Fix the pgtable leak
Date: Wed, 13 Feb 2019 20:29:00 +0900
Message-Id: <20190213112900.33963-1-minchan@kernel.org>
X-Mailer: git-send-email 2.20.1.791.gb4d0f1c61a-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[1] was backported to v4.9 stable tree but it introduces pgtable
memory leak because with fault retrial, preallocated pagetable
could be leaked in second iteration.
To fix the problem, this patch backport [2].

[1] 5cf3e5ff95876, mm, memcg: fix reclaim deadlock with writeback
[2] b0b9b3df27d10, mm: stop leaking PageTables

Fixes: 5cf3e5ff95876 ("mm, memcg: fix reclaim deadlock with writeback")
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Liu Bo <bo.liu@linux.alibaba.com>
Cc: <stable@vger.kernel.org> [4.9]
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/memory.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 35d8217bb0467..47248dc0b9e1a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3329,15 +3329,24 @@ static int do_fault(struct fault_env *fe)
 {
 	struct vm_area_struct *vma = fe->vma;
 	pgoff_t pgoff = linear_page_index(vma, fe->address);
+	int ret;
 
 	/* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND */
 	if (!vma->vm_ops->fault)
-		return VM_FAULT_SIGBUS;
-	if (!(fe->flags & FAULT_FLAG_WRITE))
-		return do_read_fault(fe, pgoff);
-	if (!(vma->vm_flags & VM_SHARED))
-		return do_cow_fault(fe, pgoff);
-	return do_shared_fault(fe, pgoff);
+		ret = VM_FAULT_SIGBUS;
+	else if (!(fe->flags & FAULT_FLAG_WRITE))
+		ret = do_read_fault(fe, pgoff);
+	else if (!(vma->vm_flags & VM_SHARED))
+		ret = do_cow_fault(fe, pgoff);
+	else
+		ret = do_shared_fault(fe, pgoff);
+
+	/* preallocated pagetable is unused: free it */
+	if (fe->prealloc_pte) {
+		pte_free(vma->vm_mm, fe->prealloc_pte);
+		fe->prealloc_pte = 0;
+	}
+	return ret;
 }
 
 static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
-- 
2.20.1.791.gb4d0f1c61a-goog

