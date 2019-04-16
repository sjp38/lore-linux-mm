Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B0E7C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8825222D6
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8825222D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8155E6B0294; Tue, 16 Apr 2019 09:47:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 79C746B0296; Tue, 16 Apr 2019 09:47:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68C716B0297; Tue, 16 Apr 2019 09:47:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4874B6B0294
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:44 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id s11so15575940ywa.18
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:47:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=Xp+UT7lx7SKMZtWDQJKM8VxsYgdJIamGRljD+mKc5XE=;
        b=ZrDl4OqRnnsCrrZWQnma48FWkAr4CRBM8fHHI618/XUUQ8zwYH3X6denqIlbnEJ10v
         3iGqidHyTU33M3mGE3npzna8SAF7rN8w3/r7CJzcOseNanXWkT7RFpQDkti6E2u6jBT8
         O/JHKsNz7/w8CFyKTxbkFCmCOwM36uMJjwBndSXW/99eJlPfqV6g4PUSzNNHiFrkkaY1
         pC2QMarHyBesLmIurYb0Z0Lv9N6tiG904ka7K66MolC6XxaqVSjAslFGCPs8I4ZhHteS
         44PznEpQFLRSMiEamxAm5V1Ve7VI/7X7YrXPbyjMV2BG819Br4EqsSkWWZ/yB/oIgbvk
         MrNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXLiUXFWAGLEyi4nK5de+WkL9gHDmZ+U27zBe4gaKci06l4epR6
	FoQidkwzNSbch2f1D9Tw1/K4ZupK/AuY7ifjEpT/7QACGrDtjRY7YBebHbxH0Koms5AAI0kfRI2
	KYIR1bcBxkPkw3B9MQK+m8/L2mb8E05TXUq+cZTL0H5PD5Pqdk/X2pRbb8LdCLxVneg==
X-Received: by 2002:a81:9ad0:: with SMTP id r199mr64350296ywg.310.1555422463952;
        Tue, 16 Apr 2019 06:47:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6rknmXsC9+fRRNst14wRcT0aQxPNHrKLZQAo7DGENDzFtENsgcBQjAHCBzMHOT7NJpi5t
X-Received: by 2002:a81:9ad0:: with SMTP id r199mr64350211ywg.310.1555422462976;
        Tue, 16 Apr 2019 06:47:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422462; cv=none;
        d=google.com; s=arc-20160816;
        b=Nsd0d4teBOQnbmHMhlRxpp1lW8SN5apYyNRn2T3uSDkTEoVKYUUZ58P3cz5CCl+z6N
         pIpJRKl3r6ZmW2Qq/8xmWgmEjqiEhYkJh6ov24813Xp58y1Z7ofc5b3uaxV3BIzRMotf
         UdbuAefzBPnJE8q2o6BC1ohHkUA8hz6du1aFf4P3T9ZakFHISUVcd+bY0N0SeA9ZWDef
         O8ZvYGGbcO0E1g3sAP4SHxpowsK8i4sJZ8jStxttl/eh2WtVueS7iYrp+ya4P8mgpFSL
         Kw5TeuLzoUHw0/j0pcuOK/ERFgY3pAWhRwqLJeazPYInoV48BbdPzMzbDAPVyWYhx0h6
         II0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=Xp+UT7lx7SKMZtWDQJKM8VxsYgdJIamGRljD+mKc5XE=;
        b=UUBFeGTVU5I9wN82UBugHoS5gWj5QfDQdRpydOWHgFOlYG8fzx4Vv1fkBiZXwbYpgY
         YuFOhLmkgkj+eYxQMBFqMzwVHgxx7AYlAZgZg7D3DsEkL6y26oD+5Yp9SzkXGi8y5SCl
         /ZdKvYwejVzJYK1jAH1k4N+cogVX41nI6w9/9DYvQMaGb2EiIdTI62dWtFkB/Kb7gIQq
         vRE/FXpaHi3/FzERfKMk/MzEgO8Jd8wLgLN8R1Zy0Laup27rdzBpLbjQTyuck90ysMM2
         VtiL5YsxxpPmcYh+G+A6wTEf5IxrhcygvyCa58dSTUMzxoPOf0BNHXMLy7tZwr92aRFQ
         JYCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u31si20813894ywh.269.2019.04.16.06.47.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:47:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDlKYP091712
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:42 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwfsus89w-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:30 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:46:17 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:46:07 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDk5E642074152
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:46:05 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 735CD4C050;
	Tue, 16 Apr 2019 13:46:05 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8A1104C040;
	Tue, 16 Apr 2019 13:46:01 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:46:01 +0000 (GMT)
From: Laurent Dufour <ldufour@linux.ibm.com>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
        kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
        jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
        aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
        mpe@ellerman.id.au, paulus@samba.org,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        hpa@zytor.com, Will Deacon <will.deacon@arm.com>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        sergey.senozhatsky.work@gmail.com,
        Andrea Arcangeli <aarcange@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com,
        Daniel Jordan <daniel.m.jordan@oracle.com>,
        David Rientjes <rientjes@google.com>,
        Jerome Glisse <jglisse@redhat.com>,
        Ganesh Mahendran <opensource.ganesh@gmail.com>,
        Minchan Kim <minchan@kernel.org>,
        Punit Agrawal <punitagrawal@gmail.com>,
        vinayak menon <vinayakm.list@gmail.com>,
        Yang Shi <yang.shi@linux.alibaba.com>,
        zhong jiang <zhongjiang@huawei.com>,
        Haiyan Song <haiyanx.song@intel.com>,
        Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
        Michel Lespinasse <walken@google.com>,
        Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com,
        npiggin@gmail.com, paulmck@linux.vnet.ibm.com,
        Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org,
        x86@kernel.org
Subject: [PATCH v12 14/31] mm/migrate: Pass vm_fault pointer to migrate_misplaced_page()
Date: Tue, 16 Apr 2019 15:45:05 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0016-0000-0000-0000026F7273
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0017-0000-0000-000032CBBD8A
Message-Id: <20190416134522.17540-15-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-16_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904160093
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

migrate_misplaced_page() is only called during the page fault handling so
it's better to pass the pointer to the struct vm_fault instead of the vma.

This way during the speculative page fault path the saved vma->vm_flags
could be used.

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 include/linux/migrate.h | 4 ++--
 mm/memory.c             | 2 +-
 mm/migrate.c            | 4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index e13d9bf2f9a5..0197e40325f8 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -125,14 +125,14 @@ static inline void __ClearPageMovable(struct page *page)
 #ifdef CONFIG_NUMA_BALANCING
 extern bool pmd_trans_migrating(pmd_t pmd);
 extern int migrate_misplaced_page(struct page *page,
-				  struct vm_area_struct *vma, int node);
+				  struct vm_fault *vmf, int node);
 #else
 static inline bool pmd_trans_migrating(pmd_t pmd)
 {
 	return false;
 }
 static inline int migrate_misplaced_page(struct page *page,
-					 struct vm_area_struct *vma, int node)
+					 struct vm_fault *vmf, int node)
 {
 	return -EAGAIN; /* can't migrate now */
 }
diff --git a/mm/memory.c b/mm/memory.c
index d0de58464479..56802850e72c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3747,7 +3747,7 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
 	}
 
 	/* Migrate to the requested node */
-	migrated = migrate_misplaced_page(page, vma, target_nid);
+	migrated = migrate_misplaced_page(page, vmf, target_nid);
 	if (migrated) {
 		page_nid = target_nid;
 		flags |= TNF_MIGRATED;
diff --git a/mm/migrate.c b/mm/migrate.c
index a9138093a8e2..633bd9abac54 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1938,7 +1938,7 @@ bool pmd_trans_migrating(pmd_t pmd)
  * node. Caller is expected to have an elevated reference count on
  * the page that will be dropped by this function before returning.
  */
-int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
+int migrate_misplaced_page(struct page *page, struct vm_fault *vmf,
 			   int node)
 {
 	pg_data_t *pgdat = NODE_DATA(node);
@@ -1951,7 +1951,7 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
 	 * with execute permissions as they are probably shared libraries.
 	 */
 	if (page_mapcount(page) != 1 && page_is_file_cache(page) &&
-	    (vma->vm_flags & VM_EXEC))
+	    (vmf->vma_flags & VM_EXEC))
 		goto out;
 
 	/*
-- 
2.21.0

