Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2BD4C48BE4
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:49:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A5FD208C3
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:49:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="gafcg6C8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A5FD208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E09AF6B0010; Sun, 23 Jun 2019 01:49:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDF5F8E0008; Sun, 23 Jun 2019 01:49:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C59498E0007; Sun, 23 Jun 2019 01:49:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8781C6B000E
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 01:49:01 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x18so7166891pfj.4
        for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:49:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=CFhlysmGz57clyaJ1HAINnv1wDIl1pPPAi1K6HzPDZ0=;
        b=FrrhyVbmAQB54sfa42L8ChHYyZiHAb4J0U9PZ5eWCa3e6HNtSr8AQhtJLyRTgwWacL
         rGCUSRVrZtIRaE1uv98rSYoF+yq9NVm1Cw4xMbpVRTF9ushQytSCF1AtpVgwV3sq0Gaa
         ekfRriZvguuTHnu97t26DEm6AHHnRu0mKEFTqO1rlJWcR6O+uATfEceBq8SKoB4BR/WX
         lxwHDFsH9dTKsL0WQ6wEjf4fhcWImujiPdDc7vNb8nvmnEjYFQR2zU6ARlJF12lPVF9y
         FYXZECBk/Gbd4OsoKmWIrisx8qUSjDaLJbMGkWb19tB3ODBP0SqXb+SdIm9mi63+JZWJ
         +cfw==
X-Gm-Message-State: APjAAAUvwAwsU+BX09qTxFuJSQSeEkM+GSQKl3hlZh14Im0wuTuDGUvG
	4jGaWeZcIDoTltKcbeOsZosGXW3TWHcEUth/PHFbypBbxkunoRJ07gauc1MPP/o7tD+A59YeWEx
	FGvsGzxF/0i3BMa1SlzHlqUSSQbZ9mNTNqOXYTxE6PXM/ws+2cJXo3qVZu4QwhxmDEA==
X-Received: by 2002:a63:e001:: with SMTP id e1mr26855903pgh.306.1561268941054;
        Sat, 22 Jun 2019 22:49:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyl7nD4f2lKWp5EOdvA3oK+caxOxkpKxDBQY9/innhQALe8DF5u2j1agDjIikjHl7fSwNU8
X-Received: by 2002:a63:e001:: with SMTP id e1mr26855871pgh.306.1561268940159;
        Sat, 22 Jun 2019 22:49:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561268940; cv=none;
        d=google.com; s=arc-20160816;
        b=om39U38oBT/h+6wwG0DGLRjdpgMIpgchx1sir6wOm4SEWydrPDWC4WgJ4c0Yx7iOUy
         YjeKMhRgOBR+nAsnvnquMpKKTVXstd7Jmqb0xYhXVdYxe9XiBOy3rB9wKsI/J2U5UAg+
         KOmQXk83uhgeU+DI6zU5lB9NpDGDn24QJTYb9PNGWg1YQvUq6AUlU0R20TP4ajuoeN8F
         5OkH7A6wZamx3152+/KkOAP/2PSPkB9M9pEDGey//UnrAISbG7p6I7H+Tdi0CQsPtC5W
         QoAkSfgQ7voShmOF0M3d6MfNXzGp/wxq+VEGLuruGFZre10P8QCA85WwdJuoiJZ/uAHF
         UGsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=CFhlysmGz57clyaJ1HAINnv1wDIl1pPPAi1K6HzPDZ0=;
        b=Igh1yFZkFcOZ6VmdnG+1a6zOehvBDpapCYUVx8F99U7t5R5ahV2ZpwR7VUQml3KHco
         EnaNeqYOe7YOg3oGd7Aqq8GDpC78plnYDiTiGoGXz1rTbKVqFGGSwFtJ2i/4/iDcUFDR
         EOSqAIWs9fvaxhzz9rawBej3w7Yue5viyiZXIoGIOTiWE4qssZaLeOB2oSbCtaByw+lL
         YB1PjNmu20ZWLthorxW903sr+wN2ZfnJpMOs2dpcRKb3yHBlXxd6LAL9qMgEvWAFjx0V
         HGSi6lhRIqZZHARoSO/IXa0nlD2a3XTTv+gayc8v1OblH6F7oYoeGfVxEZg8+QPcMzau
         s8Gg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=gafcg6C8;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id a12si6974683pgq.208.2019.06.22.22.48.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Jun 2019 22:49:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=gafcg6C8;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5N5iprh015299
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:59 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=CFhlysmGz57clyaJ1HAINnv1wDIl1pPPAi1K6HzPDZ0=;
 b=gafcg6C8zP7ZBtoTG180sNk0r9ODkCNup9DgAtwrNhAafglZwxjmkMOIdDOdX4f6rBcZ
 gXDmKHBh5OmHh/aNzF0JLzF4/1Eugd5wpDQqo2J1e+rU4MAfN6QMKAOXDfphSvXS8hsx
 jn2PaPJumGspkXlSYEA8tLPi8R03XIGzCe8= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t9gc0jd4a-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:59 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Sat, 22 Jun 2019 22:48:58 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id A436162E2CFB; Sat, 22 Jun 2019 22:48:55 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v6 5/6] khugepaged: enable collapse pmd for pte-mapped THP
Date: Sat, 22 Jun 2019 22:48:28 -0700
Message-ID: <20190623054829.4018117-6-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190623054829.4018117-1-songliubraving@fb.com>
References: <20190623054829.4018117-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-23_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=347 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906230050
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

khugepaged needs exclusive mmap_sem to access page table. When it fails
to lock mmap_sem, the page will fault in as pte-mapped THP. As the page
is already a THP, khugepaged will not handle this pmd again.

This patch enables the khugepaged to retry retract_page_tables().

A new flag AS_COLLAPSE_PMD is introduced to show the address_space may
contain pte-mapped THPs. When khugepaged fails to trylock the mmap_sem,
it sets AS_COLLAPSE_PMD. Then, at a later time, khugepaged will retry
compound pages in this address_space.

Since collapse may happen at an later time, some pages may already fault
in. To handle these pages properly, it is necessary to prepare the pmd
before collapsing. prepare_pmd_for_collapse() is introduced to prepare
the pmd by removing rmap, adjusting refcount and mm_counter.

prepare_pmd_for_collapse() also double checks whether all ptes in this
pmd are mapping to the same THP. This is necessary because some subpage
of the THP may be replaced, for example by uprobe. In such cases, it
is not possible to collapse the pmd, so we fall back.

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/linux/pagemap.h |  1 +
 mm/khugepaged.c         | 69 +++++++++++++++++++++++++++++++++++------
 2 files changed, 60 insertions(+), 10 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 9ec3544baee2..eac881de2a46 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -29,6 +29,7 @@ enum mapping_flags {
 	AS_EXITING	= 4, 	/* final truncate in progress */
 	/* writeback related tags are not used */
 	AS_NO_WRITEBACK_TAGS = 5,
+	AS_COLLAPSE_PMD = 6,	/* try collapse pmd for THP */
 };
 
 /**
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index a4f90a1b06f5..9b980327fd9b 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1254,7 +1254,47 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
 }
 
 #if defined(CONFIG_SHMEM) && defined(CONFIG_TRANSPARENT_HUGE_PAGECACHE)
-static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
+
+/* return whether the pmd is ready for collapse */
+bool prepare_pmd_for_collapse(struct vm_area_struct *vma, pgoff_t pgoff,
+			      struct page *hpage, pmd_t *pmd)
+{
+	unsigned long haddr = page_address_in_vma(hpage, vma);
+	unsigned long addr;
+	int i, count = 0;
+
+	/* step 1: check all mapped PTEs are to this huge page */
+	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
+		pte_t *pte = pte_offset_map(pmd, addr);
+
+		if (pte_none(*pte))
+			continue;
+
+		if (hpage + i != vm_normal_page(vma, addr, *pte))
+			return false;
+		count++;
+	}
+
+	/* step 2: adjust rmap */
+	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
+		pte_t *pte = pte_offset_map(pmd, addr);
+		struct page *page;
+
+		if (pte_none(*pte))
+			continue;
+		page = vm_normal_page(vma, addr, *pte);
+		page_remove_rmap(page, false);
+	}
+
+	/* step 3: set proper refcount and mm_counters. */
+	page_ref_sub(hpage, count);
+	add_mm_counter(vma->vm_mm, mm_counter_file(hpage), -count);
+	return true;
+}
+
+extern pid_t sysctl_dump_pt_pid;
+static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff,
+				struct page *hpage)
 {
 	struct vm_area_struct *vma;
 	unsigned long addr;
@@ -1273,21 +1313,21 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 		pmd = mm_find_pmd(vma->vm_mm, addr);
 		if (!pmd)
 			continue;
-		/*
-		 * We need exclusive mmap_sem to retract page table.
-		 * If trylock fails we would end up with pte-mapped THP after
-		 * re-fault. Not ideal, but it's more important to not disturb
-		 * the system too much.
-		 */
 		if (down_write_trylock(&vma->vm_mm->mmap_sem)) {
 			spinlock_t *ptl = pmd_lock(vma->vm_mm, pmd);
-			/* assume page table is clear */
+
+			if (!prepare_pmd_for_collapse(vma, pgoff, hpage, pmd)) {
+				spin_unlock(ptl);
+				up_write(&vma->vm_mm->mmap_sem);
+				continue;
+			}
 			_pmd = pmdp_collapse_flush(vma, addr, pmd);
 			spin_unlock(ptl);
 			up_write(&vma->vm_mm->mmap_sem);
 			mm_dec_nr_ptes(vma->vm_mm);
 			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
-		}
+		} else
+			set_bit(AS_COLLAPSE_PMD, &mapping->flags);
 	}
 	i_mmap_unlock_write(mapping);
 }
@@ -1561,7 +1601,7 @@ static void collapse_file(struct mm_struct *mm,
 		/*
 		 * Remove pte page tables, so we can re-fault the page as huge.
 		 */
-		retract_page_tables(mapping, start);
+		retract_page_tables(mapping, start, new_page);
 		*hpage = NULL;
 
 		khugepaged_pages_collapsed++;
@@ -1622,6 +1662,7 @@ static void khugepaged_scan_file(struct mm_struct *mm,
 	int present, swap;
 	int node = NUMA_NO_NODE;
 	int result = SCAN_SUCCEED;
+	bool collapse_pmd = false;
 
 	present = 0;
 	swap = 0;
@@ -1640,6 +1681,14 @@ static void khugepaged_scan_file(struct mm_struct *mm,
 		}
 
 		if (PageTransCompound(page)) {
+			if (collapse_pmd ||
+			    test_and_clear_bit(AS_COLLAPSE_PMD,
+					       &mapping->flags)) {
+				collapse_pmd = true;
+				retract_page_tables(mapping, start,
+						    compound_head(page));
+				continue;
+			}
 			result = SCAN_PAGE_COMPOUND;
 			break;
 		}
-- 
2.17.1

