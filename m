Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55EB5C004C9
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 04:54:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06A162087B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 04:54:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06A162087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 945056B026C; Mon, 29 Apr 2019 00:54:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F2896B026D; Mon, 29 Apr 2019 00:54:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8072D6B026E; Mon, 29 Apr 2019 00:54:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 488936B026D
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 00:54:12 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f7so6652123pfd.7
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 21:54:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DUvFDn7C5Eh34MdB6r7GUuxOF+hBXuSzGP9HXtCcuKI=;
        b=JnLcDkOPidVw6ubB8gMAgrbhvKdj3bGQphFy8fh0tGyS8zPSSk1m3plHZXmslo/xfa
         VlmzFD52TX84JDq4YwtVeL2jidwWh5Rh9w79yyimB7ljPb0GQIufUtZyse+UyNgPU0az
         uiYjDkfYUsal8xgaWzP8vSa3EC9IGX1n5AX6Hc8O5OGcUZbCV74BKz1OBDnYjZCpJIcS
         SnXVYoEm8F0pE9pwXWtLWjyEwTvHsqV47KXsc8Jz1tEdbuW4Gs4AupLTAiejMKYbTYq4
         MuepCyJoYfoUK2wdJPdyUqvS+lVJhl7u/jxZdfkP1xT53OoRncUBI76mS6v//du23yKx
         PacA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWpQDhSLbqyIASYYTa5Rb7h8yC6fL7Dy8M7gzO1fRXypRLXwzuv
	lzL84EXdy0cRJyn3D+LQAgB2n44bP/6MXWSdhqDAR489T5bJUeLtqIJAm7SFrTSfSLdRzGOgt+t
	59BeVfD2UrlcM+eCCAOAIqhDASQRE0Okl3DSV/P1q77W1Px2dMwtYKCJV/dYPac7JLg==
X-Received: by 2002:a17:902:a7:: with SMTP id a36mr59731883pla.111.1556513651953;
        Sun, 28 Apr 2019 21:54:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynEotcfbW0EDVn9v6KNgAT/kAbGkzVsSKTicFV1bZtSZS5FhMKv+f6uBBOnlDAsHshCa2r
X-Received: by 2002:a17:902:a7:: with SMTP id a36mr59731858pla.111.1556513651276;
        Sun, 28 Apr 2019 21:54:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556513651; cv=none;
        d=google.com; s=arc-20160816;
        b=G30uMN9h8M55W1+inzpLuaPM5ZU4YEs0j+/av0wwOJ5WqHT+29CKntjQ4UuqRk4M0i
         +QDWo+lTcBRFSZVEJqx+RoX0zNUQYFVX0Ku0f1gGF+SULDY0BplokOPCWZXD5LXCaUP5
         PKH4azSx131jYtZMrjwjtPMxGndzC6rjFsthL07F/w8fiyRvdLI+enBR8NNC2juGXEcY
         6a6JQ6oLEddyXBaL1FqpUes77cIeoH+8ga8gCEvi8h4F60hIBOoNdxMLf5o4Uy7C8EeD
         0ic5B5BtzTOa/VQj8YZlC33MiIeQ93v8kk2Nmv7il8sE4kJ8hPgtLUifAbqgET127KW7
         rphg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=DUvFDn7C5Eh34MdB6r7GUuxOF+hBXuSzGP9HXtCcuKI=;
        b=werc8iSjbkWJXK871rT+T+o9L6vYzz9s8fMzfrFKz6eGFjImf48BZq5RzSeTq1NTb5
         +CIcjnAhjukT/T6+5ar2BT944ki/W3+7/uDX2aBJwME93tyb0tLVywdKVI/aGU648bWe
         m/WT2X08aAZTIZ1WvrMqb3PjejhrhQMxEz/G19v3QLzDaWXVKXG3mLo200XEb7npTtPe
         ZXOdwMOTJeO5RRP3wFN/RUmqAZ0+2LXaH9OSehc3BYD+eJgxGQnNjJ8M4PY4XKNU9zAD
         BEFL7nClANFw1F1XjhQC0lbiadAtaMC2dPBkG4Aor8dn4s1AajZ5EgSUJ75H3fDOLDpE
         3tqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id m184si14181099pfb.166.2019.04.28.21.54.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Apr 2019 21:54:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Apr 2019 21:54:10 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,408,1549958400"; 
   d="scan'208";a="146566319"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 28 Apr 2019 21:54:10 -0700
From: ira.weiny@intel.com
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Dan Williams <dan.j.williams@intel.com>,
	Jan Kara <jack@suse.cz>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [RFC PATCH 10/10] mm/gup: Remove FOLL_LONGTERM DAX exclusion
Date: Sun, 28 Apr 2019 21:53:59 -0700
Message-Id: <20190429045359.8923-11-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190429045359.8923-1-ira.weiny@intel.com>
References: <20190429045359.8923-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Now that there is a mechanism for users to safely take LONGTERM pins on
FS DAX pages.  Remove the FS DAX exclusion from GUP with FOLL_LONGTERM.

Special processing remains in effect for CONFIG_CMA
---
 mm/gup.c | 65 ++++++--------------------------------------------------
 1 file changed, 6 insertions(+), 59 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 1ee17f2339f7..cf6863422cb9 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1324,26 +1324,6 @@ long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 }
 EXPORT_SYMBOL(get_user_pages_remote);
 
-#if defined(CONFIG_FS_DAX) || defined (CONFIG_CMA)
-static bool check_dax_vmas(struct vm_area_struct **vmas, long nr_pages)
-{
-	long i;
-	struct vm_area_struct *vma_prev = NULL;
-
-	for (i = 0; i < nr_pages; i++) {
-		struct vm_area_struct *vma = vmas[i];
-
-		if (vma == vma_prev)
-			continue;
-
-		vma_prev = vma;
-
-		if (vma_is_fsdax(vma))
-			return true;
-	}
-	return false;
-}
-
 #ifdef CONFIG_CMA
 static struct page *new_non_cma_page(struct page *page, unsigned long private)
 {
@@ -1474,18 +1454,6 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 
 	return nr_pages;
 }
-#else
-static long check_and_migrate_cma_pages(struct task_struct *tsk,
-					struct mm_struct *mm,
-					unsigned long start,
-					unsigned long nr_pages,
-					struct page **pages,
-					struct vm_area_struct **vmas,
-					unsigned int gup_flags)
-{
-	return nr_pages;
-}
-#endif
 
 /*
  * __gup_longterm_locked() is a wrapper for __get_user_pages_locked which
@@ -1499,49 +1467,28 @@ static long __gup_longterm_locked(struct task_struct *tsk,
 				  struct vm_area_struct **vmas,
 				  unsigned int gup_flags)
 {
-	struct vm_area_struct **vmas_tmp = vmas;
 	unsigned long flags = 0;
-	long rc, i;
+	long rc;
 
-	if (gup_flags & FOLL_LONGTERM) {
-		if (!pages)
-			return -EINVAL;
-
-		if (!vmas_tmp) {
-			vmas_tmp = kcalloc(nr_pages,
-					   sizeof(struct vm_area_struct *),
-					   GFP_KERNEL);
-			if (!vmas_tmp)
-				return -ENOMEM;
-		}
+	if (flags & FOLL_LONGTERM)
 		flags = memalloc_nocma_save();
-	}
 
 	rc = __get_user_pages_locked(tsk, mm, start, nr_pages, pages,
-				     vmas_tmp, NULL, gup_flags);
+				     vmas, NULL, gup_flags);
 
 	if (gup_flags & FOLL_LONGTERM) {
 		memalloc_nocma_restore(flags);
 		if (rc < 0)
 			goto out;
 
-		if (check_dax_vmas(vmas_tmp, rc)) {
-			for (i = 0; i < rc; i++)
-				put_page(pages[i]);
-			rc = -EOPNOTSUPP;
-			goto out;
-		}
-
 		rc = check_and_migrate_cma_pages(tsk, mm, start, rc, pages,
-						 vmas_tmp, gup_flags);
+						 vmas, gup_flags);
 	}
 
 out:
-	if (vmas_tmp != vmas)
-		kfree(vmas_tmp);
 	return rc;
 }
-#else /* !CONFIG_FS_DAX && !CONFIG_CMA */
+#else /* !CONFIG_CMA */
 static __always_inline long __gup_longterm_locked(struct task_struct *tsk,
 						  struct mm_struct *mm,
 						  unsigned long start,
@@ -1553,7 +1500,7 @@ static __always_inline long __gup_longterm_locked(struct task_struct *tsk,
 	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
 				       NULL, flags);
 }
-#endif /* CONFIG_FS_DAX || CONFIG_CMA */
+#endif /* CONFIG_CMA */
 
 /*
  * This is the same as get_user_pages_remote(), just with a
-- 
2.20.1

