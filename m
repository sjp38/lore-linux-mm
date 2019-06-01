Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AF39C28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B671F272E3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="gmVdpg1I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B671F272E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87A216B0288; Sat,  1 Jun 2019 09:20:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82A3F6B0289; Sat,  1 Jun 2019 09:20:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 657256B028A; Sat,  1 Jun 2019 09:20:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC9B6B0288
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:20:37 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s195so6558307pgs.13
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:20:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TLX82GjfB2WVVgDtq4KVIuKalD0EQnphPobdQuybo6Y=;
        b=QZOUb2j4HZbCoJdBR2CsgoxXuEry3nwzvDTs+Wwjtrb2x6TyQuKMSylm+jVAlbvEx7
         qU5zRoZW5eB/ZF2ssf/OCumJoVapyn1W7h5GYs2Z9BEYCOHME/Tp8AD/wjOOQ/mzfx2+
         UIp3Y2tpX0ZGrVMRoO+EWvRhIe51LpS0g4l++0Rshj0sJJx2lEXmKJlvbK4y4xsJvBXL
         7uGtVPArQOwyvww6azSN3nqlWYxQijrdhK2C3IStiXIYlR6Sm2AKd6durn5iu7Q3IfHk
         kW0f9djK+PTOIY81UP7SPbvJ9f/87Hf+B1nQIqyWSP3PyIE7Mogh3zNxKKtEdGr/tdoH
         U8+g==
X-Gm-Message-State: APjAAAXJQwxaocxfIPO835+IWh7FQpml6sYUUk91pb9UlVvWrnXTMTR/
	eu8sOeANbXmGZc/hymPv1oo2VwGflHvTLB0U1/XBk1mTXdSLmgqseXP7hf6PPmp7LFnihQ7KGPb
	JoX5gOjhqyO4IzcJcwDytpxso76+bcOyOThgTzp454ZkP3Sp+fT+q/XJNAphwiSpTXg==
X-Received: by 2002:a17:90a:b296:: with SMTP id c22mr16811705pjr.28.1559395236851;
        Sat, 01 Jun 2019 06:20:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIlteNpGM8sWZeZ2BFuvxOr/lvw66jGFj9UUbsROmO29bMq0pePckGpHOahVZ1t+pcKRIS
X-Received: by 2002:a17:90a:b296:: with SMTP id c22mr16811636pjr.28.1559395236167;
        Sat, 01 Jun 2019 06:20:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395236; cv=none;
        d=google.com; s=arc-20160816;
        b=wdzS+p+7wZxSCZEXkt9MecOxWY1jD2agT64qHAKYKTx4F1EElK+vrisDBwIcGim9Yo
         mmbm82Uf4qKMLDsqzKDtWdc+/Kez663iZ/nBh9fAsU7QiEglvwHbvSu3kgy66LmML0Ea
         +YH7q4hZOB8RmOL3XtDt8dJHYhqfmjeuVOrL32v3dfuviQ3EJ9/+BXeBTKamsGyy0FJ9
         bd3+pXQflMnVXQAbPRHzd2krnllSGpaZlg0OtEBPNefFG9KFga6G0iGYGpL/ghxnJxqk
         lL1L3UuhjR3jeb6g/+jO5u3JcaNTfU6NxGanGO6j1OdNnm1TgW39IpLY+YgPp7E+G1cr
         /nUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=TLX82GjfB2WVVgDtq4KVIuKalD0EQnphPobdQuybo6Y=;
        b=iKbEHDs6qpcdG1bmLk1mmk9VR7H/UoHSfgCYDGhLFvLpp11MLPYTNXvAINqCAIs+pD
         ghVWaas9QyFeQMHkml4ZeOxtC89E+iT+lfppWgBO2qKc4pPQXq1ohr2Q2qqvHlDktPnh
         QSuYVPERG6XXvFFZLOKLkJDt6fR1sff7+5hrLLA3JOFRcJgclGnmxw/RFpMTyU6hbJDV
         ndN2rarREhGlKGbavTdYgcIhCKZiGFbh9GB2/1xzNASNu3sEsce/LKvedPNxaXdMAw7z
         HPqLjYZdrSGo4UuRIO8cIo7nrlD9p3jYI7OfswNaKx83Xu5ZJO5xHbzFYi51K8nx96bJ
         n/9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=gmVdpg1I;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id gb4si2308757plb.429.2019.06.01.06.20.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:20:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=gmVdpg1I;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C0B3C272D8;
	Sat,  1 Jun 2019 13:20:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395235;
	bh=lERRBpbiWXcItU0VZZrHkshCFTxnimKBKwtoNIoSXbM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=gmVdpg1IjEFC8PHYzXCJUfvfHvJ7ByU/9Nw3/Wp+CqKKQ8qeaL431Yp5IuUe2PgjZ
	 8AVtzJRnpdFYipS9Hp/SdP/muuVHxqfGwSBKtS/M+Vp1s/71eMBiiKx8jHd86iHiK+
	 Sf24ts6tzhgj795p5ChcKj8uDGo/PWTyCgxLiuE4=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 018/173] mm: page_mkclean vs MADV_DONTNEED race
Date: Sat,  1 Jun 2019 09:16:50 -0400
Message-Id: <20190601131934.25053-18-sashal@kernel.org>
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

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

[ Upstream commit 024eee0e83f0df52317be607ca521e0fc572aa07 ]

MADV_DONTNEED is handled with mmap_sem taken in read mode.  We call
page_mkclean without holding mmap_sem.

MADV_DONTNEED implies that pages in the region are unmapped and subsequent
access to the pages in that range is handled as a new page fault.  This
implies that if we don't have parallel access to the region when
MADV_DONTNEED is run we expect those range to be unallocated.

w.r.t page_mkclean() we need to make sure that we don't break the
MADV_DONTNEED semantics.  MADV_DONTNEED check for pmd_none without holding
pmd_lock.  This implies we skip the pmd if we temporarily mark pmd none.
Avoid doing that while marking the page clean.

Keep the sequence same for dax too even though we don't support
MADV_DONTNEED for dax mapping

The bug was noticed by code review and I didn't observe any failures w.r.t
test run.  This is similar to

commit 58ceeb6bec86d9140f9d91d71a710e963523d063
Author: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Date:   Thu Apr 13 14:56:26 2017 -0700

    thp: fix MADV_DONTNEED vs. MADV_FREE race

commit ced108037c2aa542b3ed8b7afd1576064ad1362a
Author: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Date:   Thu Apr 13 14:56:20 2017 -0700

    thp: fix MADV_DONTNEED vs. numa balancing race

Link: http://lkml.kernel.org/r/20190321040610.14226-1-aneesh.kumar@linux.ibm.com
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc:"Kirill A . Shutemov" <kirill@shutemov.name>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/dax.c  | 2 +-
 mm/rmap.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 8eb3e8c2b4bdc..163ebd6cc0d1c 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -814,7 +814,7 @@ static void dax_entry_mkclean(struct address_space *mapping, pgoff_t index,
 				goto unlock_pmd;
 
 			flush_cache_page(vma, address, pfn);
-			pmd = pmdp_huge_clear_flush(vma, address, pmdp);
+			pmd = pmdp_invalidate(vma, address, pmdp);
 			pmd = pmd_wrprotect(pmd);
 			pmd = pmd_mkclean(pmd);
 			set_pmd_at(vma->vm_mm, address, pmdp, pmd);
diff --git a/mm/rmap.c b/mm/rmap.c
index 0454ecc29537a..e0710b258c417 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -928,7 +928,7 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 				continue;
 
 			flush_cache_page(vma, address, page_to_pfn(page));
-			entry = pmdp_huge_clear_flush(vma, address, pmd);
+			entry = pmdp_invalidate(vma, address, pmd);
 			entry = pmd_wrprotect(entry);
 			entry = pmd_mkclean(entry);
 			set_pmd_at(vma->vm_mm, address, pmd, entry);
-- 
2.20.1

