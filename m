Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11550C28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:22:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD96E24438
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:22:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="wHZUqz32"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD96E24438
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A2D56B029A; Sat,  1 Jun 2019 09:22:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 653336B029C; Sat,  1 Jun 2019 09:22:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5417C6B029D; Sat,  1 Jun 2019 09:22:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1C5516B029A
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:22:36 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id w14so8241668plp.4
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:22:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eCVHmQjBKkxCyThO47Zi1+A+g6crq0LDkm/bzXEHyYY=;
        b=lzJ2Tp5m7DLiUt2B0HNX5ydMhtyOv6Zl9Up/IKpm9cLBePiKOKDAMhOl6DNWBzX4/N
         bZ3l0nVsL2lg3tr4TAH3e6VOsyxks1hZehe3rjedaJDE5asP9L6Q4xe7ESL2DAU3PA1K
         yBovk3JCN1ClQNYjWx6YTTl6qGWS8vkBH7sKSLvGKTvke2X/mIqj0GkDIgvd9WTOYUuG
         fIU971o7JY2S7ymQqrN7dbC/lODkIIeZHadr4fzqG3/J+D9HOTRR3b21MP8vtOFR/XKM
         1UT0K5LAFWAPlC3FNjZ8BzXg0CSDRbs1iwohweq5WoBVBAv0LgmMAmtLqCAnyB7kxH8v
         P5ow==
X-Gm-Message-State: APjAAAWNDq7f0ksG/3o2hmqMhUPLvqBaZQTQz5dZuE0jiUu3pSUK8RDH
	csBMTSA0yBsjz0oGS4RK6Rh7RM58pFRTdDS3dlZR4/poZRHAOZmQXl/CMclVRfzeBQMJAryTcW3
	0Wg6EP/LiR4bbqzZsfTuaQ0n6ddMpdPpvAkJL+UlasjEYDP4m2Pos3jWuDGLzkzHU7w==
X-Received: by 2002:a62:5cc6:: with SMTP id q189mr17129510pfb.114.1559395355778;
        Sat, 01 Jun 2019 06:22:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzeXA7oHcD+cUxjeAkdxnQjZNzJrfbNphODr34u9H+P1Te1GJaWP/SsTD7TYAmhket0zU/5
X-Received: by 2002:a62:5cc6:: with SMTP id q189mr17129440pfb.114.1559395355205;
        Sat, 01 Jun 2019 06:22:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395355; cv=none;
        d=google.com; s=arc-20160816;
        b=hOtu20XgZU31DHsxRUHo7QyK78EPYNymPya1gwbGg7pWMfbvqUhkAszO/oNoScBgF+
         LbQWoliMQO+1/ErMCEZhpQ3Z6nZ7DqJR8RApK3ZLBAXaS/S/GDB00335/j7Qi0NxHIjz
         mtk09pl+/k43L1RKGdJ+/O9RT5/WakZ8yZfxAn67orJd4s76TA4K69H+qiBI/ZYaKib9
         Cf/5/B0Eb5C4AGx6yLRRS/VEV7Mtf6NbSpoVV38FP3BwPybtW+HlVG9z85fFJft2f3d2
         VoxrGEHdcvGTW+035l4WZOglYwSXP/Dl/zja4rncBp8rPoxuzUECGy+3MEs2JaHYBQI6
         dkCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=eCVHmQjBKkxCyThO47Zi1+A+g6crq0LDkm/bzXEHyYY=;
        b=vEDdRYhWxUdWk9b07VZnKavu7z6Q/gayuySXe3mn6QQaQ0vd+voiQI3Z7H+fowJ35Y
         ZGschUnNwcprZuaELrgyfdjEZmBwI8qZ7hk41M9ZW+ODgBxMNbHHpAUK3RuAHfKIouPN
         3+dUcp7YSXVcXpsaXgvRlrpuT9OhxLzuvXakobDY3ODeLTIeaXsBZ3lENaRRuofbaNEa
         4TmVacLkky6NwVaCdVqVLItLres3l48rXs7Ag9qGQGt7I7Hfc7/3zRfijUL4TxjQZzhs
         jyLm0Igm2/53x8EfJyYX/86EnsC2AFs8wCXaYN/6vTrwhMkSxL1FKNXvrlbEfVQLuxVt
         TK8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=wHZUqz32;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n3si9814164pgh.53.2019.06.01.06.22.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:22:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=wHZUqz32;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BF97126E87;
	Sat,  1 Jun 2019 13:22:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395354;
	bh=gOZxUIYQsBEQRv9bk+M8JatOYaVu6PBPjijotTiPsns=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=wHZUqz32iMTPY1jA7ax4RY3fenLrXNAdaQmzNdANUaF0MH+Fi4Wbf/8ckv3ikjlzu
	 +dIh+cdEP31vBOn84qlvACNtF+M1OInnwSmhPHsvChVfKw9Cw5UdERLv5Vc4lchfq9
	 Iuw1+lrUeqVnQd3Dk8m3pMCZgbFaqveG6y9Glk/4=
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
Subject: [PATCH AUTOSEL 4.19 013/141] mm: page_mkclean vs MADV_DONTNEED race
Date: Sat,  1 Jun 2019 09:19:49 -0400
Message-Id: <20190601132158.25821-13-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132158.25821-1-sashal@kernel.org>
References: <20190601132158.25821-1-sashal@kernel.org>
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
index 004c8ac1117c4..75a289c31c7e5 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -908,7 +908,7 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 				goto unlock_pmd;
 
 			flush_cache_page(vma, address, pfn);
-			pmd = pmdp_huge_clear_flush(vma, address, pmdp);
+			pmd = pmdp_invalidate(vma, address, pmdp);
 			pmd = pmd_wrprotect(pmd);
 			pmd = pmd_mkclean(pmd);
 			set_pmd_at(vma->vm_mm, address, pmdp, pmd);
diff --git a/mm/rmap.c b/mm/rmap.c
index 85b7f94233526..f048c2651954b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -926,7 +926,7 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 				continue;
 
 			flush_cache_page(vma, address, page_to_pfn(page));
-			entry = pmdp_huge_clear_flush(vma, address, pmd);
+			entry = pmdp_invalidate(vma, address, pmd);
 			entry = pmd_wrprotect(entry);
 			entry = pmd_mkclean(entry);
 			set_pmd_at(vma->vm_mm, address, pmd, entry);
-- 
2.20.1

