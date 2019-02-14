Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7150C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:02:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F66F218FF
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:02:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="mcr+aLBj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F66F218FF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDA948E0003; Wed, 13 Feb 2019 19:02:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E889F8E0001; Wed, 13 Feb 2019 19:02:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D52058E0003; Wed, 13 Feb 2019 19:02:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3F98E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 19:02:35 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id x134so3201695pfd.18
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:02:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=BnvBthvqyUR+BETbLnaqcFAixVQhrRUG4KWFDYKw33s=;
        b=RWLD4rjjJEkrTR69bU1UH1OaMS0YmArk7kwqEX0xDoTjrgrtu538mXNvvjlZGmhml7
         ptKHKGnH+Q4t9qGO44gSL+/BTl3txyONkhcQQZgshu0dxxY5gzrMTfTUkcFbE8O2N2L7
         xfwJjQlaOfnozUa7LjCbfAF24fOJWlKxYdT6PWEt2VZKsY95mmYz0FdnG+Lw2vvn8yKK
         u7MDmX715W9Mbg0b2zyaIIl6lsT3qSpI7H7FSBoC16iH0BI2VLB5ikDSj+T2cxI4vnR3
         5OIkjhs313w9XKCpG9XBOu/OQTT+/t5xhl3dZ5jP5fy6WoxQkvjWgvwm3izRU99QQSyp
         pWpw==
X-Gm-Message-State: AHQUAuZmjZzkmrxcnvnF/EZZQjVECDbzoAv3Atngf9sl5cYhgqBsQLMN
	OIiPQ9Z//w27AstBbuH3Vs6Jo9Kuf1MfOCYg/ceIFN+eQLHFYjxB672gZmTH10YJwchwCEyy+7R
	RI8x2ElQihdXhjbQghdMPLW4vlG5z1O6dgElMLUJi4kh2At7qtTRp2ED66gLXgHVznQ==
X-Received: by 2002:a17:902:9a4a:: with SMTP id x10mr875244plv.93.1550102555297;
        Wed, 13 Feb 2019 16:02:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbI0p7iYDv1Xk070oeANnIK5ob4IHR89AGxU08wgydCYHnXeJG6Socn2IIwGCw2Nn+QFE7i
X-Received: by 2002:a17:902:9a4a:: with SMTP id x10mr875173plv.93.1550102554498;
        Wed, 13 Feb 2019 16:02:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550102554; cv=none;
        d=google.com; s=arc-20160816;
        b=KL6r+hRQrF7FALivu1sgpgYuYJ8vQ38W1i27nB9llC8dwUSNddIFb/F3g7l5stZ/jz
         zLpoQLXVRjq0e1SA60xM//5A4f19HGqrPIUvJEW2Wv9Ut+wdE5I5JpQgQWvnMDjhbDx0
         xePLAoMYbtM1lUmLLsKrtJHZ0E9QejZmau/eNhkLnGLOG7s3Y3r0yPWXMcR3kHlOm7ie
         RaTcSfQ3T+wlCi3fS5TEJBrAl/iCza1PvLP2MKkT/AXsZ5vSjGcBtNkdo4c8qEumScR0
         N98VU0GKIGheUQF37ad4Z1xECazvfz66QT1qzz2IJvMPeUG8roXhhRg1KNuWbx2rLozD
         PCdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=BnvBthvqyUR+BETbLnaqcFAixVQhrRUG4KWFDYKw33s=;
        b=gFGEQAVquROZ6kbRSru918i/14YxxEHaoFRkVKe8dFuF9p5T3Tlv9d1FIIs7egxfJD
         utoBfFhrmcil2AWy2U9vXAgmkbMF8QMzX9OzrgvnX8O8N7KlVeuQewKz674U87TZ5/En
         48CcMtel7I2dvoAqlO33BT2GwUVEBsq3Iinoon7ZVT4xoPCjJ8d1JF6mRoby36seyPej
         W30CioFgDYySCTbhnt3ZEcB/yJHardV/Xw0HePJe9MiCFiXYRr5wVxQ1KWAD2KvdgVH6
         Tw4RgjOiroyxL5NHhNXcWC4dtqmiOfSUDbicrvMxccJRzwPrD6L1ZfrGSiXuCt6bg2kD
         4CyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=mcr+aLBj;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id m10si696301plt.295.2019.02.13.16.02.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 16:02:34 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=mcr+aLBj;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1DNwsZ2100568;
	Thu, 14 Feb 2019 00:01:59 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=BnvBthvqyUR+BETbLnaqcFAixVQhrRUG4KWFDYKw33s=;
 b=mcr+aLBjXAXSptqDtlz0VxxfWE1bq8ULxWcJo1ATX2NiCgH2AWLADjbr/HqYkpk9odGK
 ChvFnz1ZxMVxKCJ0jfXdJW5TYWVBwj+Ty3/i6pxWwCEiACxkvV13/+T2YmPTX1CBTwJG
 UBQhh1BtAVY8KyQ7Wk/NDQM5Umuvxs3VEJF2d3Xv4chhe+jqnXx8PoRI61KUxuMIHH1j
 hzaCrG4RkCU1W8fxes/FLLMZ7uQSL15sc1ZI1d0I09k3vAa0Q8LpfMdnyskkbMB7yMLc
 eVkiHdh8fE/ZM3EnxXIAPz7Bn0aTkW7mrmcxMY3krFlvZUEFc5Jyqgv8meeyiWbyIGX9 Lw== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2qhre5n3u2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:01:59 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1E01wVi031042
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:01:58 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1E01tie014301;
	Thu, 14 Feb 2019 00:01:56 GMT
Received: from concerto.internal (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 13 Feb 2019 16:01:55 -0800
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        torvalds@linux-foundation.org, liran.alon@oracle.com,
        keescook@google.com, akpm@linux-foundation.org, mhocko@suse.com,
        catalin.marinas@arm.com, will.deacon@arm.com, jmorris@namei.org,
        konrad.wilk@oracle.com
Cc: Tycho Andersen <tycho@docker.com>, deepa.srinivasan@oracle.com,
        chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk,
        andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com,
        kanth.ghatraju@oracle.com, oao.m.martins@oracle.com,
        jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com,
        tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de,
        steven.sistare@oracle.com, labbott@redhat.com, luto@kernel.org,
        dave.hansen@intel.com, peterz@infradead.org,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
Subject: [RFC PATCH v8 01/14] mm: add MAP_HUGETLB support to vm_mmap
Date: Wed, 13 Feb 2019 17:01:24 -0700
Message-Id: <ec8d9101bea98360ef1f4c7cb5bb0450859c213b.1550088114.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9166 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902130157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Tycho Andersen <tycho@docker.com>

vm_mmap is exported, which means kernel modules can use it. In particular,
for testing XPFO support, we want to use it with the MAP_HUGETLB flag, so
let's support it via vm_mmap.

Signed-off-by: Tycho Andersen <tycho@docker.com>
Tested-by: Marco Benatto <marco.antonio.780@gmail.com>
Tested-by: Khalid Aziz <khalid.aziz@oracle.com>
---
 include/linux/mm.h |  2 ++
 mm/mmap.c          | 19 +------------------
 mm/util.c          | 32 ++++++++++++++++++++++++++++++++
 3 files changed, 35 insertions(+), 18 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5411de93a363..30bddc7b3c75 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2361,6 +2361,8 @@ struct vm_unmapped_area_info {
 extern unsigned long unmapped_area(struct vm_unmapped_area_info *info);
 extern unsigned long unmapped_area_topdown(struct vm_unmapped_area_info *info);
 
+struct file *map_hugetlb_setup(unsigned long *len, unsigned long flags);
+
 /*
  * Search for an unmapped address range.
  *
diff --git a/mm/mmap.c b/mm/mmap.c
index 6c04292e16a7..c668d7d27c2b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1582,24 +1582,7 @@ unsigned long ksys_mmap_pgoff(unsigned long addr, unsigned long len,
 		if (unlikely(flags & MAP_HUGETLB && !is_file_hugepages(file)))
 			goto out_fput;
 	} else if (flags & MAP_HUGETLB) {
-		struct user_struct *user = NULL;
-		struct hstate *hs;
-
-		hs = hstate_sizelog((flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);
-		if (!hs)
-			return -EINVAL;
-
-		len = ALIGN(len, huge_page_size(hs));
-		/*
-		 * VM_NORESERVE is used because the reservations will be
-		 * taken when vm_ops->mmap() is called
-		 * A dummy user value is used because we are not locking
-		 * memory so no accounting is necessary
-		 */
-		file = hugetlb_file_setup(HUGETLB_ANON_FILE, len,
-				VM_NORESERVE,
-				&user, HUGETLB_ANONHUGE_INODE,
-				(flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);
+		file = map_hugetlb_setup(&len, flags);
 		if (IS_ERR(file))
 			return PTR_ERR(file);
 	}
diff --git a/mm/util.c b/mm/util.c
index 8bf08b5b5760..536c14cf88ba 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -357,6 +357,29 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	return ret;
 }
 
+struct file *map_hugetlb_setup(unsigned long *len, unsigned long flags)
+{
+	struct user_struct *user = NULL;
+	struct hstate *hs;
+
+	hs = hstate_sizelog((flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);
+	if (!hs)
+		return ERR_PTR(-EINVAL);
+
+	*len = ALIGN(*len, huge_page_size(hs));
+
+	/*
+	 * VM_NORESERVE is used because the reservations will be
+	 * taken when vm_ops->mmap() is called
+	 * A dummy user value is used because we are not locking
+	 * memory so no accounting is necessary
+	 */
+	return hugetlb_file_setup(HUGETLB_ANON_FILE, *len,
+			VM_NORESERVE,
+			&user, HUGETLB_ANONHUGE_INODE,
+			(flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);
+}
+
 unsigned long vm_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
 	unsigned long flag, unsigned long offset)
@@ -366,6 +389,15 @@ unsigned long vm_mmap(struct file *file, unsigned long addr,
 	if (unlikely(offset_in_page(offset)))
 		return -EINVAL;
 
+	if (flag & MAP_HUGETLB) {
+		if (file)
+			return -EINVAL;
+
+		file = map_hugetlb_setup(&len, flag);
+		if (IS_ERR(file))
+			return PTR_ERR(file);
+	}
+
 	return vm_mmap_pgoff(file, addr, len, prot, flag, offset >> PAGE_SHIFT);
 }
 EXPORT_SYMBOL(vm_mmap);
-- 
2.17.1

