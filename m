Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72C02C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 07:21:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3387C217D6
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 07:21:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3387C217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D62556B000D; Fri, 10 May 2019 03:21:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D124B6B000E; Fri, 10 May 2019 03:21:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8D5D6B0010; Fri, 10 May 2019 03:21:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9CE3D6B000D
	for <linux-mm@kvack.org>; Fri, 10 May 2019 03:21:31 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id v6so4656543qkh.6
        for <linux-mm@kvack.org>; Fri, 10 May 2019 00:21:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qzOAoH/TNvXjcpwg8Oz/fc8MXlS07T4EqVnD2ZBjw6A=;
        b=gHEmxrY79UwqtOAk+N8ZqK5ukD4vjuW6HBFxTrhijR5+EhpXoAP2c+KSJk1++p3Urr
         sFOubgBdzjzWs7jYUSJWvx4MtOkEQsxziVvG6yBlDZR0cY0jZckbux/mAfNJ4nXeQfCQ
         IRttGIZc2ocUmzAJTgD9tUfSJCRqek/D9ABmYBetrdhhZmwQQHbextL7IGWRNm4L3MB4
         G8PPtcx609H19tSqD0UPdIs18gA7oDYC1EqSfoQgiYdug/mdqEj0KZZ0HC9UZbW/t+yp
         Jy5IJypINpVlnlDqrNzW3wArlRxnHaWhNz2vCmjya2iVhzqR/Vaxwu5PYpNQH7CDvbE2
         VR3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWllIRN8MBTVpx+3SfIXBHvvB7O97YjtquKy9OfR9t6KS5C+SuQ
	Lmqt3gu0SvICzCB+S+yLi9BN+BOV3C9+a/DqV/lQ3y3askl0MMTCxIIa8mOQ0FG3HFgI16vttar
	5XLTgiZok24/XMa1CZkAy2Ook5m8dUBxpb3QPJ7e2/ZmCmv7zkqQcIG+27x2Kk4g7Tw==
X-Received: by 2002:a37:7986:: with SMTP id u128mr7720409qkc.45.1557472891393;
        Fri, 10 May 2019 00:21:31 -0700 (PDT)
X-Received: by 2002:a37:7986:: with SMTP id u128mr7720341qkc.45.1557472890051;
        Fri, 10 May 2019 00:21:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557472890; cv=none;
        d=google.com; s=arc-20160816;
        b=Zod5Ci/alJVH8kmSGfPBSR2ufJuyg61zieb1AYu/42leqVgTIz4enitsTGJNiBReiV
         yxTIBA1+wOkFVrz7KYO0y6DeidH1lEb+sOGxcGgBOw0rc9yC7VJmOBkfnnVBtpUq6A2g
         c+g1mClUxorlXshpNYPFru5CRMMS8TFptEnEuhF59Hg5bnSmVe5jLtC9NVmlRueHNDJe
         tntoaxOLUpK86sIaRnFjxK6yLpwtd0NtQ4WDYjtfISQ1vtVp+PZrkZJbl+Wlky/zO+X3
         aivRv9XAWguz89tw+KaVqu+6YcavWH03UosfXQPmzJCMLHZfDYcYa9K3ujl+K3xU81LA
         nsuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=qzOAoH/TNvXjcpwg8Oz/fc8MXlS07T4EqVnD2ZBjw6A=;
        b=M6JY73i/3Y+2QLkg2UopPGPr/c8JPqzHCTVykyILzPvw4dprBRTAXvZlZ3yL/5BqCd
         Npqeh46o6Koi2PlV4kEpBML+KhCCsR/uj5BtdpYHUSb3mupfr+AQ2S9Efz7egQJ6YfmI
         5ncLbj/LvO7Ep678S1vW0jgPmoHsxcbLBgamg6f5X6EMDRRsa5rawkAvr3NyFiS+qxxi
         uwuuDWZoObE3bk78sla6Op1Stq/eid1038SN6EexGPAX8pAEHnH3R/U4jEpJAItY88hj
         FZyPc8PliaLDADn8nNoBOcgQDNpZb9MtizExodGPn2I4bMSNSiFZOIfCQ1Sy2ZTkkHA9
         z8vw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j124sor2459245qkc.24.2019.05.10.00.21.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 May 2019 00:21:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwKpqIkvTy6CiBwHKtkH71OJTdUzb+Ov2Uf7B01EGgr+mZM24+4w2juFKcB1sGHGd3S+eq7hw==
X-Received: by 2002:a37:648d:: with SMTP id y135mr7656118qkb.237.1557472889756;
        Fri, 10 May 2019 00:21:29 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id i92sm2579667qtb.44.2019.05.10.00.21.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 00:21:29 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	linux-mm@kvack.org
Subject: [PATCH RFC 1/4] mm/ksm: introduce ksm_enter() helper
Date: Fri, 10 May 2019 09:21:22 +0200
Message-Id: <20190510072125.18059-2-oleksandr@redhat.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190510072125.18059-1-oleksandr@redhat.com>
References: <20190510072125.18059-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Move MADV_MERGEABLE part of ksm_madvise() into a dedicated helper since
it will be further used in do_anonymous_page().

This does not bring any functional changes.

Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
---
 include/linux/ksm.h |  2 ++
 mm/ksm.c            | 66 ++++++++++++++++++++++++++-------------------
 2 files changed, 41 insertions(+), 27 deletions(-)

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index e48b1e453ff5..bc13f228e2ed 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -21,6 +21,8 @@ struct mem_cgroup;
 #ifdef CONFIG_KSM
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		unsigned long end, int advice, unsigned long *vm_flags);
+int ksm_enter(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long *vm_flags);
 int __ksm_enter(struct mm_struct *mm);
 void __ksm_exit(struct mm_struct *mm);
 
diff --git a/mm/ksm.c b/mm/ksm.c
index fc64874dc6f4..a6b0788a3a22 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2450,33 +2450,9 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 
 	switch (advice) {
 	case MADV_MERGEABLE:
-		/*
-		 * Be somewhat over-protective for now!
-		 */
-		if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
-				 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
-				 VM_HUGETLB | VM_MIXEDMAP))
-			return 0;		/* just ignore the advice */
-
-		if (vma_is_dax(vma))
-			return 0;
-
-#ifdef VM_SAO
-		if (*vm_flags & VM_SAO)
-			return 0;
-#endif
-#ifdef VM_SPARC_ADI
-		if (*vm_flags & VM_SPARC_ADI)
-			return 0;
-#endif
-
-		if (!test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
-			err = __ksm_enter(mm);
-			if (err)
-				return err;
-		}
-
-		*vm_flags |= VM_MERGEABLE;
+		err = ksm_enter(mm, vma, vm_flags);
+		if (err)
+			return err;
 		break;
 
 	case MADV_UNMERGEABLE:
@@ -2496,6 +2472,42 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 	return 0;
 }
 
+int ksm_enter(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long *vm_flags)
+{
+	int err;
+
+	/*
+	 * Be somewhat over-protective for now!
+	 */
+	if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
+			 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
+			 VM_HUGETLB | VM_MIXEDMAP))
+		return 0;		/* just ignore the advice */
+
+	if (vma_is_dax(vma))
+		return 0;
+
+#ifdef VM_SAO
+	if (*vm_flags & VM_SAO)
+		return 0;
+#endif
+#ifdef VM_SPARC_ADI
+	if (*vm_flags & VM_SPARC_ADI)
+		return 0;
+#endif
+
+	if (!test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
+		err = __ksm_enter(mm);
+		if (err)
+			return err;
+	}
+
+	*vm_flags |= VM_MERGEABLE;
+
+	return 0;
+}
+
 int __ksm_enter(struct mm_struct *mm)
 {
 	struct mm_slot *mm_slot;
-- 
2.21.0

