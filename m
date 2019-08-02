Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 024DBC0650F
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 23:18:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9AF620880
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 23:18:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="IkPxc/Km"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9AF620880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 506B96B0006; Fri,  2 Aug 2019 19:18:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48DC76B0008; Fri,  2 Aug 2019 19:18:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37BBB6B000A; Fri,  2 Aug 2019 19:18:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 15B6E6B0005
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 19:18:28 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id b78so28971745ybg.20
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 16:18:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=NLo+kUCCETQ4ngAnRD6GoEVLB9ZFwANLd+99Aj/UcOA=;
        b=ttmZO1Lj4yWTK15zdDjjEk5Ob9lbGMqlb3ehgwEu1P36FyTA92XmcSOlWFtwyuUlte
         R4qDM4kIITxQ4GIM8qmUTxSA460dJcBQqXTUoA0sBHO7h3JipIvjmQcCLJxZEO3ImHgM
         XYyR9wyVf3LB89rITyDNyReX+xPFRfSOpgvIdS47Yh+ZAHNZPAdyXafzpF7lV9wKlalQ
         tb6jg//E/tzt+sFQFvPtlQeKc+8yeHfMNSjYjSAJBlt7RakLoWB2q5Kq2UEn+qFbHarP
         mU/Z8nE+7Zz08GoEuLAjJC6HwDlWuZDLuaB8PnooEjipYe/Ifi17l5PtspkAyWDC3Nb+
         Jetw==
X-Gm-Message-State: APjAAAXx14v0ML98QjZ6pkDFNkIZ+DMT+BxETxO34o18pv8QfJgIKCRa
	CZmAPLcVuRf8JWkN6NJTnO+89K1wlBmdBrmapI2R7vSj4iOBYiOl7ot6Q+PDTHMvdRfjs2NjfUI
	MdL52Sl88aNYthjPt/W+dl+hF3jNlhJaVfjPCE32A2D764rfxuAnh2So53NHvuQAbdw==
X-Received: by 2002:a25:392:: with SMTP id 140mr88366589ybd.34.1564787907739;
        Fri, 02 Aug 2019 16:18:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdSyl8+9T67rgLka39h6g/7FuWbx/GZjcAsQWGyRMzWpumc4QdjkHJq7kC1+bF15rB1UbS
X-Received: by 2002:a25:392:: with SMTP id 140mr88366564ybd.34.1564787907131;
        Fri, 02 Aug 2019 16:18:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564787907; cv=none;
        d=google.com; s=arc-20160816;
        b=0vivIZwFBS5a5D03p71ks8iV5o3IeLwGZeGEGb8chhdAcUMQwq+uto8IVw+nc2kdqn
         SEfyiNlhetsm84wYy1AWsEHMRU1WSIQUJBNKgdbI+hBwEV31+ErgeyZ6v77icOJjciVB
         VEfmkuQWbnjvQfZSswUvS5fPSQSSCz4igGfYWAUDGYrWFLGN6BZLOfnRbahku7jOcfRL
         z/8hJVgugWtUqOnAs2YOKsBRijmajS1kJzFD2vdKqcfdMUf95uCGwydi6znXALoTNGJd
         7ceZ46QWcq/0GJ1hwyWyirJ8NPxr8QIFSvF7LHt1cmeqNdcyb5QzOTtGUeIrJYnjLWvt
         tbww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=NLo+kUCCETQ4ngAnRD6GoEVLB9ZFwANLd+99Aj/UcOA=;
        b=VWSM0hYt2RhnABpte8XjHgDIUZplEDqE+Gp36GkOPtv1wEXzBfJU1aM231Hv7IoRD4
         +weKblZ2xQAyw8KWpsQ0MpgdsrZT52cffDXG4DacuG3gaydk+eaTZWw+IzcOHMOgouUM
         LicD2A5ocBMpiMvOMKYlkkyrOXmSKKlqSP8M1QWzK1DVcOdtomMEq7MjBup1ANogD6+J
         69eGAY11QZjUWc4pSZSrHBTzLsHqWF5JcLnf9W/1Hj9iPahX96sOHMc+6CW0pHhtTKAH
         MqNb5JJB2JxYQ74WvtGhjvjqZX9rm1XJVDMhLTjxEb57l5wxdTOuynuZWhqiksdyI2IV
         w1fw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="IkPxc/Km";
       spf=pass (google.com: domain of prvs=3117788d8b=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3117788d8b=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id z4si1406216ybk.78.2019.08.02.16.18.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 16:18:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3117788d8b=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="IkPxc/Km";
       spf=pass (google.com: domain of prvs=3117788d8b=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3117788d8b=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x72NHBjo009205
	for <linux-mm@kvack.org>; Fri, 2 Aug 2019 16:18:26 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=NLo+kUCCETQ4ngAnRD6GoEVLB9ZFwANLd+99Aj/UcOA=;
 b=IkPxc/KmNzax1zVqzjFJCLfvquf5ZibULR/cj6bX6njcKca5+rypWhsHWfn5F99RnBDO
 7WhXb9bZSB++6Y5eLXiB46oB2TTdusuk+RcHnDiVWKXFlC/tCEbiOF/n+O3k5Ne9wHRi
 Q3YizG4qW6aAL1iL0P78U+w/G4NQkcDM+ik= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0001303.ppops.net with ESMTP id 2u4wrt86cu-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 02 Aug 2019 16:18:26 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Fri, 2 Aug 2019 16:18:25 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id D092F62E2BEF; Fri,  2 Aug 2019 16:18:23 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <oleg@redhat.com>, <kernel-team@fb.com>,
        <william.kucharski@oracle.com>, <srikar@linux.vnet.ibm.com>,
        Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v4 2/2] uprobe: collapse THP pmd after removing all uprobes
Date: Fri, 2 Aug 2019 16:18:17 -0700
Message-ID: <20190802231817.548920-3-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190802231817.548920-1-songliubraving@fb.com>
References: <20190802231817.548920-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-02_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=400 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908020241
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After all uprobes are removed from the huge page (with PTE pgtable), it
is possible to collapse the pmd and benefit from THP again. This patch
does the collapse by calling collapse_pte_mapped_thp().

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 kernel/events/uprobes.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 27b596f14463..94d38a39d72e 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -26,6 +26,7 @@
 #include <linux/percpu-rwsem.h>
 #include <linux/task_work.h>
 #include <linux/shmem_fs.h>
+#include <linux/khugepaged.h>
 
 #include <linux/uprobes.h>
 
@@ -472,6 +473,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	struct page *old_page, *new_page;
 	struct vm_area_struct *vma;
 	int ret, is_register, ref_ctr_updated = 0;
+	bool orig_page_huge = false;
 
 	is_register = is_swbp_insn(&opcode);
 	uprobe = container_of(auprobe, struct uprobe, arch);
@@ -529,6 +531,9 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 				/* let go new_page */
 				put_page(new_page);
 				new_page = NULL;
+
+				if (PageCompound(orig_page))
+					orig_page_huge = true;
 			}
 			put_page(orig_page);
 		}
@@ -547,6 +552,10 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	if (ret && is_register && ref_ctr_updated)
 		update_ref_ctr(uprobe, mm, -1);
 
+	/* try collapse pmd for compound page */
+	if (!ret && orig_page_huge)
+		collapse_pte_mapped_thp(mm, vaddr);
+
 	return ret;
 }
 
-- 
2.17.1

