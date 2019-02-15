Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58E5DC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00B4C222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="D2kj6qCW";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ffAj6nKR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00B4C222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 848A18E001C; Fri, 15 Feb 2019 17:09:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F7578E0014; Fri, 15 Feb 2019 17:09:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A1318E001C; Fri, 15 Feb 2019 17:09:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 34A048E0014
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:39 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 207so9421048qkl.2
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=wEhGNSHqHzp3fZwWQfZiyRwXqVI8VIbN+Kjw76/hmYo=;
        b=IEpqWGzckibGioNm5xU23bsX+kxqPBZ5HFKUbR9RxJycOB2t7WPju8ng9T8uoYkJNi
         ADUZHVQ02OIwKY+rQ5JFVQpjPuXETMPlRk1OjkyCrHKik0aJaugUpdaOneRYR6moLCLt
         aijqz2NhUFmXrfIdrhIT8vlYFQKJNOZVlN3/D64tS2acaoEUK49PBBAMpGyO0Fyv8ZwX
         sahkM+pAtZJbPTPBhA5PUdo17C+Z1dcA/V/egJlBGogLuE27IAK6qIPHlWk366OJJ5HI
         0EZ0ZFOBju6SyFyD3T/frBkZfCEc38AeLdWWKw6VRc9uHYQnRGrJC1R7Ep1+vzRquXm7
         SRUw==
X-Gm-Message-State: AHQUAua6/pJmHsul2rPRr5Cw9u+FZ06vgt7O9o3j/OQRBh4BSs3z/07K
	dZ6E9R2+yUCPPs5edhd/xT7IGCAqk0E3zgnTlE15G4wTnPUxd0+nLDB7isduJ5P5V4tiEAgEUzw
	dFhuDsDJEQCMsDCpUhXZ4ZRiLcj1vkf0tI27ZhZcCpGVpVlnoBKvQ+f5v+7bzrAfWng==
X-Received: by 2002:a37:4c0f:: with SMTP id z15mr8811588qka.180.1550268578981;
        Fri, 15 Feb 2019 14:09:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbWh6EFsQF/MhUQuTlQN410Mr7lHLNrwZYCEqH5h2J8Djcln23ikkfHCixBH249ghvEAUf2
X-Received: by 2002:a37:4c0f:: with SMTP id z15mr8811552qka.180.1550268578392;
        Fri, 15 Feb 2019 14:09:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268578; cv=none;
        d=google.com; s=arc-20160816;
        b=QMHdBKOCuv8Mu0Vrb09DxjbHrL3uJBlKyTMm7cuxWZMDE2aJPlLFdxEml+EALV2oJ2
         HYmSPhjTn+JKzRqUi6orYl08v8BIy+Eq8TxOX+Sz+QW+aErq0uTEzi8cwSpT5L8V9RXD
         HEdHySlLD9mzytIq9tKdamlp4l8j+tqovA0NRah9M6Sg/iCWUL6w503aAxOPgkv/WDuH
         W/fYA4+f558pPIWxmMwRvxKzkpblKdheoIbgt5l6yi5eMdNuXZzMiHddnQOhFjbhZgti
         t1jy4Ax0/75I9msay/VK/HqE/P874uR2GUznBsqcSQUyuOj7xrHtZwveDjhaNMpIIWyR
         tR/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=wEhGNSHqHzp3fZwWQfZiyRwXqVI8VIbN+Kjw76/hmYo=;
        b=Zpvkp/Hi/i8hMvXPTqz/3VjmE5rk4KNby3QgMD+OnlXdjSLtggOPdRGxMSoDPa1typ
         Gk6uP68Xihv+Z+jUeX/DzP/WMgzdvvb1lRezvLecuRJsiiiGtkd3f7Yzl+uzslrJMsUq
         PW96S3CgaOCw5jZmNGe90ShrFhG/cJZ4GgzWszQ3GGUk0gCAAKrpls1H2bLITKMnbOsi
         gg4xOaLu0tj2RLbfdmDX5NSscVoIXW0P3sz/U4mbji7jRGhvyxSgLwaka5OvGTmEPKyO
         yY0pIwLb/bwvJgXYH4OU6k7N5S1Urb5Na5ChnWOPT2wMQVQp0DrknCT5hQT/8nfB29S5
         MAEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=D2kj6qCW;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=ffAj6nKR;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id b203si1317806qka.144.2019.02.15.14.09.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:38 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=D2kj6qCW;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=ffAj6nKR;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 98633310A;
	Fri, 15 Feb 2019 17:09:36 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:37 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=wEhGNSHqHzp3f
	ZwWQfZiyRwXqVI8VIbN+Kjw76/hmYo=; b=D2kj6qCWlFHmfotrf7Ke/LUEg7yzF
	ccqkfGEBNm0+EFFa2BDH/ySxrvGb/NiberlTcmtesFpTwjwSX2IUByvzblQC9tV3
	YaxcXdZHTIXlk8X78XfJvT9oaqB3zhzIEFiwsPcNsu9mvDzBz2u4LCzXLPQ5eYRL
	EEBPGf2UpUtRVzYD0aZVrqq4dhb9xAqFo0VueTxjXsyaDxrji9/dqGPMb1b8H35s
	b5hEFGa0vo/18cMkaS612oUF0lIS8/VcYCZmi0aQKo1D4FBbSRANloT0DSTKJvkW
	s1dQYQho3lzL1LloYPswExDB/KOBIua9YUgMDj/xKAEZaP9XDxqfG+K3A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=wEhGNSHqHzp3fZwWQfZiyRwXqVI8VIbN+Kjw76/hmYo=; b=ffAj6nKR
	isuG/XWvtnwhlqGNCVF/7dfvaD3uRkyHj3qBgmMFVcgbFJ4mjsVhgdnP3qaUSn4S
	jQpEbyHMq6z5+DfnMRdW7XoYeqtkecJaYBqduQnzb1H5lANGGuArF4zQI5ehh8Du
	MxVzLbv6VcPGC9ZNvyAi+k44ayAVaVbeqsKXoI4wOx1ntnVXWRmLsyCkFhY3ZWVm
	kFBzy9E3KyzsJWwAe4FrqV+RyqeqyaPDphpnbaopgyAURNg7y+VOvcajVk+TeWoF
	W+gtlXt5fTLFizyrJn9acCdALc41v/sbuk0LMn2VDWpj6w277EnLUZCk06BKjGIa
	p8EMmDiC/sMxag==
X-ME-Sender: <xms:oDhnXPI8H6PcaQXElBRoS16gcG6WjTLs4h2M5raeGty36yUMBWJSkQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpedvvd
X-ME-Proxy: <xmx:oDhnXGNqa5dJIMTMzUzCaqZB8Jhp_dpajbJSf624-30e39BNkDelxg>
    <xmx:oDhnXFxisdoQLCP7QQp6pRsggjkIjUcGkNEz0donpmuFCKyYQ7mi5A>
    <xmx:oDhnXL3J_ZbWJdsS8jyIRV349BA1mvPdNW6j7R_poled6p1kviX8rA>
    <xmx:oDhnXK3VVekFOIT6Hkn3fsbtMSQSBE8Eptdk-CKGiEMvtcHdkLoo8Q>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id AAF68E4597;
	Fri, 15 Feb 2019 17:09:34 -0500 (EST)
From: Zi Yan <zi.yan@sent.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 25/31] mm: thp: add a knob to enable/disable 1GB THPs.
Date: Fri, 15 Feb 2019 14:08:50 -0800
Message-Id: <20190215220856.29749-26-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215220856.29749-1-zi.yan@sent.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

It does not affect existing 1GB THPs. It is similar to the knob for
2MB THPs.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/linux/huge_mm.h | 14 ++++++++++++++
 mm/huge_memory.c        | 42 ++++++++++++++++++++++++++++++++++++++++-
 mm/memory.c             |  2 +-
 3 files changed, 56 insertions(+), 2 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index b1acada9ce8c..687c7d59df8b 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -84,6 +84,8 @@ enum transparent_hugepage_flag {
 #ifdef CONFIG_DEBUG_VM
 	TRANSPARENT_HUGEPAGE_DEBUG_COW_FLAG,
 #endif
+	TRANSPARENT_PUD_HUGEPAGE_FLAG,
+	TRANSPARENT_PUD_HUGEPAGE_REQ_MADV_FLAG,
 };
 
 struct kobject;
@@ -146,6 +148,18 @@ static inline bool __transparent_hugepage_enabled(struct vm_area_struct *vma)
 }
 
 bool transparent_hugepage_enabled(struct vm_area_struct *vma);
+static inline bool transparent_pud_hugepage_enabled(struct vm_area_struct *vma)
+{
+	if (transparent_hugepage_enabled(vma)) {
+		if (transparent_hugepage_flags & (1 << TRANSPARENT_PUD_HUGEPAGE_FLAG))
+			return true;
+		if (transparent_hugepage_flags &
+					(1 << TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG))
+			return !!(vma->vm_flags & VM_HUGEPAGE);
+	}
+
+	return false;
+}
 
 #define transparent_hugepage_use_zero_page()				\
 	(transparent_hugepage_flags &					\
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 191261771452..fa3e12b17621 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -50,9 +50,11 @@
 unsigned long transparent_hugepage_flags __read_mostly =
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS
 	(1<<TRANSPARENT_HUGEPAGE_FLAG)|
+	(1<<TRANSPARENT_PUD_HUGEPAGE_FLAG)|
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE_MADVISE
 	(1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG)|
+	(1<<TRANSPARENT_PUD_HUGEPAGE_REQ_MADV_FLAG)|
 #endif
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG)|
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG)|
@@ -276,6 +278,43 @@ static ssize_t enabled_store(struct kobject *kobj,
 static struct kobj_attribute enabled_attr =
 	__ATTR(enabled, 0644, enabled_show, enabled_store);
 
+static ssize_t enabled_1gb_show(struct kobject *kobj,
+			    struct kobj_attribute *attr, char *buf)
+{
+	if (test_bit(TRANSPARENT_PUD_HUGEPAGE_FLAG, &transparent_hugepage_flags))
+		return sprintf(buf, "[always] madvise never\n");
+	else if (test_bit(TRANSPARENT_PUD_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags))
+		return sprintf(buf, "always [madvise] never\n");
+	else
+		return sprintf(buf, "always madvise [never]\n");
+}
+
+static ssize_t enabled_1gb_store(struct kobject *kobj,
+			     struct kobj_attribute *attr,
+			     const char *buf, size_t count)
+{
+	ssize_t ret = count;
+
+	if (!memcmp("always", buf,
+		    min(sizeof("always")-1, count))) {
+		clear_bit(TRANSPARENT_PUD_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags);
+		set_bit(TRANSPARENT_PUD_HUGEPAGE_FLAG, &transparent_hugepage_flags);
+	} else if (!memcmp("madvise", buf,
+			   min(sizeof("madvise")-1, count))) {
+		clear_bit(TRANSPARENT_PUD_HUGEPAGE_FLAG, &transparent_hugepage_flags);
+		set_bit(TRANSPARENT_PUD_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags);
+	} else if (!memcmp("never", buf,
+			   min(sizeof("never")-1, count))) {
+		clear_bit(TRANSPARENT_PUD_HUGEPAGE_FLAG, &transparent_hugepage_flags);
+		clear_bit(TRANSPARENT_PUD_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags);
+	} else
+		ret = -EINVAL;
+
+	return ret;
+}
+static struct kobj_attribute enabled_1gb_attr =
+	__ATTR(enabled_1gb, 0644, enabled_1gb_show, enabled_1gb_store);
+
 ssize_t single_hugepage_flag_show(struct kobject *kobj,
 				struct kobj_attribute *attr, char *buf,
 				enum transparent_hugepage_flag flag)
@@ -405,6 +444,7 @@ static struct kobj_attribute debug_cow_attr =
 
 static struct attribute *hugepage_attr[] = {
 	&enabled_attr.attr,
+	&enabled_1gb_attr.attr,
 	&defrag_attr.attr,
 	&use_zero_page_attr.attr,
 	&hpage_pmd_size_attr.attr,
@@ -1657,7 +1697,7 @@ int do_huge_pud_wp_page(struct vm_fault *vmf, pud_t orig_pud)
 	get_page(page);
 	spin_unlock(vmf->ptl);
 alloc:
-	if (transparent_hugepage_enabled(vma) &&
+	if (transparent_pud_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow()) {
 		huge_gfp = alloc_hugepage_direct_gfpmask(vma);
 		new_page = alloc_hugepage_vma(huge_gfp, vma, haddr, HPAGE_PUD_ORDER);
diff --git a/mm/memory.c b/mm/memory.c
index c875cc1a2600..5b8ad19cc439 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3859,7 +3859,7 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
 	vmf.pud = pud_alloc(mm, p4d, address);
 	if (!vmf.pud)
 		return VM_FAULT_OOM;
-	if (pud_none(*vmf.pud) && __transparent_hugepage_enabled(vma)) {
+	if (pud_none(*vmf.pud) && transparent_pud_hugepage_enabled(vma)) {
 		ret = create_huge_pud(&vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
-- 
2.20.1

