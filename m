Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EC10C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 05:43:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 322B8216C8
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 05:43:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="KG/ve38L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 322B8216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB1068E0007; Mon, 29 Jul 2019 01:43:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5FDB8E0002; Mon, 29 Jul 2019 01:43:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C28078E0007; Mon, 29 Jul 2019 01:43:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED658E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 01:43:51 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id d135so44663549ywd.0
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 22:43:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=EE+Pu9y0F1ARDAjr/r+SMoQJ3r8nmOZDEQBazFBlpMA=;
        b=b4TlAXRFLPpFkqBAjYDpLuSAfFxWOfhHu9hE/jD45oVJ9gg9Yn2myUVU8U54jNSZJ1
         m5y5DmE7IGB9DkdcFZAPUn+auut7BvBQuRHvRQmznfD0hvneOlwuNC4vxq4c3uZzv7rW
         BK9DUH1xW3zWoqoTc75v0KYesD46O2g2KpLsgKJ4YczFJGPrw3q1F6Ht37EpPShERyZr
         cYuTmLbca+F/hH7qGkDRIc6pLqYEsmK0SKGwgT/84IPCz8vK19ZlvqiGdax3GyOeBN6S
         SIzBygw9itdGOTSzwW4c6SaSg5DTgXtJ864kJghzaGzeYpnY5BlXiSI+ce2ktrg6OnTS
         K0Ww==
X-Gm-Message-State: APjAAAUkZFVHdxoRaWKBZsS7VLmN0hvtnDQhlCTVpnScM3UFbvoZK5iR
	y9rUMy2L6zsRloC+bkzC2eMWbchuQo7bkeuDsLoayvWGqDq/u+VvVecBhlQg+L2JA2xDt1+ccLV
	UMLyFFOAXIeCEpou9DOoLlknDDNWZ3oPREJCMd2QUoBWNqA5MME3VV99wwRikjX87cg==
X-Received: by 2002:a25:3b56:: with SMTP id i83mr34903442yba.39.1564379031414;
        Sun, 28 Jul 2019 22:43:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSaycF7iJbGcXTq4KE03uectHJTAFxM4VsbuGjXvbTWwHW+gzmuf0vQ5LMqTdNMvtckpND
X-Received: by 2002:a25:3b56:: with SMTP id i83mr34903429yba.39.1564379030963;
        Sun, 28 Jul 2019 22:43:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564379030; cv=none;
        d=google.com; s=arc-20160816;
        b=DymwUg38u2VEvSS5oOhRQhV56uSpmjcazS7DYCAoKQ+/9XJnMZFGQgLvjYPb9cnoMn
         A8Ku8aQB2D+coSI4hHKefcnK0pklHCxxXxatjoKNhrHI+4NrYbNVOVX4ScgolU99JYV8
         4vP2xH5IUs4+ZsCtOMbeeygWznhtB5bld9Yy8v9C1E+WJnvT4fJrd/u0Y1tOLhDpOqVg
         0QAftQzxKj6SmTlhW1nJuQxQMnb4m4zRzvQFAjAmXXqY7jRFOwlpHJhhw0t94zoXfVFd
         OyJv3t/QWB8FpYEm3k5MDBvPIQVj5MUVn0NvjeStiMVxWCX0gm7dzZ13JEm9r2ymlnmT
         eLvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=EE+Pu9y0F1ARDAjr/r+SMoQJ3r8nmOZDEQBazFBlpMA=;
        b=KA1N705NZN/b4RMihHm7JFQD/MBcJ6i2zO13CKFguyRWGDBTQCLOrtNTMCj0PkUGLX
         ob9r2qJ5pOYZsNC4SfIG7vCEjwfmdfxPosgUZnzh6hWw2mVQPYCj07s1k1MM2o8WhU2t
         C3c8UvFTEkCM/3MMJCGE6UlxbfASzOMx29Db4CtbijZFAbTNzfJKrm6Gp0xtVJCLy1N4
         hB4o3MA7hWGeRPXKJ7QS06NRfJUtsaw5QjTKWISJpl7IWzWj6tc1Rjb43mM9uY0spfbj
         C51BK+TrNE9JonhJiYJIhKWLthEg6l68LrBswXon6RdxtZRT6VViZ0B8F5kbQS6iO0A6
         frOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="KG/ve38L";
       spf=pass (google.com: domain of prvs=3113871558=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3113871558=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id x15si15502287ybq.238.2019.07.28.22.43.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jul 2019 22:43:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3113871558=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="KG/ve38L";
       spf=pass (google.com: domain of prvs=3113871558=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3113871558=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x6T5gQjS023482
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 22:43:50 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=EE+Pu9y0F1ARDAjr/r+SMoQJ3r8nmOZDEQBazFBlpMA=;
 b=KG/ve38LPd2XQl1RAA3ilSq3yPU3m74OuSvfRGqry9P7HWVN3EzyNVlZoS1ZLnqITfVm
 pgu1Zz0y30mgfwx41agWM/XdAAMkbx0VJHF+wM5Dv/v+1YNn/3WRb83qEFXe4d2ZtkNM
 Y+EWC2zht5tvFuQMFYyF65xp7Nbav2+Qx9o= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0001303.ppops.net with ESMTP id 2u1tf10238-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 22:43:50 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Sun, 28 Jul 2019 22:43:49 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 7863562E3383; Sun, 28 Jul 2019 22:43:48 -0700 (PDT)
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
Subject: [PATCH 2/2] uprobe: collapse THP pmd after removing all uprobes
Date: Sun, 28 Jul 2019 22:43:35 -0700
Message-ID: <20190729054335.3241150-3-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190729054335.3241150-1-songliubraving@fb.com>
References: <20190729054335.3241150-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-29_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=515 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907290068
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After all uprobes are removed from the huge page (with PTE pgtable), it
is possible to collapse the pmd and benefit from THP again. This patch
does the collapse by calling khugepaged_add_pte_mapped_thp().

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 kernel/events/uprobes.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 58ab7fc7272a..cc53789fefc6 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -26,6 +26,7 @@
 #include <linux/percpu-rwsem.h>
 #include <linux/task_work.h>
 #include <linux/shmem_fs.h>
+#include <linux/khugepaged.h>
 
 #include <linux/uprobes.h>
 
@@ -470,6 +471,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	struct page *old_page, *new_page;
 	struct vm_area_struct *vma;
 	int ret, is_register, ref_ctr_updated = 0;
+	bool orig_page_huge = false;
 
 	is_register = is_swbp_insn(&opcode);
 	uprobe = container_of(auprobe, struct uprobe, arch);
@@ -525,6 +527,9 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 
 				/* dec_mm_counter for old_page */
 				dec_mm_counter(mm, MM_ANONPAGES);
+
+				if (PageCompound(orig_page))
+					orig_page_huge = true;
 			}
 			put_page(orig_page);
 		}
@@ -543,6 +548,10 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	if (ret && is_register && ref_ctr_updated)
 		update_ref_ctr(uprobe, mm, -1);
 
+	/* try collapse pmd for compound page */
+	if (!ret && orig_page_huge)
+		khugepaged_add_pte_mapped_thp(mm, vaddr & HPAGE_PMD_MASK);
+
 	return ret;
 }
 
-- 
2.17.1

