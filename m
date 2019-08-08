Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A012C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 00:06:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0C2F2186A
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 00:06:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="P0m1eST+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0C2F2186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43B7D6B0003; Wed,  7 Aug 2019 20:06:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C3C16B0006; Wed,  7 Aug 2019 20:06:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2649B6B0007; Wed,  7 Aug 2019 20:06:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id EFDF76B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 20:06:04 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id l186so39831733vke.19
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 17:06:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=I2Hc/6m77d4hpaNBr8SFkiuWXjVZymWAJofoezwBLnA=;
        b=Q6u9jDZ6nk/99BEYDa3ZnjEojhWnPcGEJbeAKmbxK9sdrx6gXCbQe28+jLlQtbI1Ar
         6PwBJDgBgYmctlR1kdcmdMt9D0dkfyodTWO1YXYDxgDvdKKz9ThRrob5Uaa6OXBQeWOT
         +0i+tvhxt/VvSxdTXtbFz330VXTdCor/XXguqMXOTuX0mH6TZl8Ri6Bif9pnM5XIGO3x
         Z33hB/tV7OOy3Uzi0nXEt5ak7xo2g7UqBDV/vIuOiaIxDUb8GruCKe7oYBhKDme8D6vv
         w9uuhQ0YWqiJQrciEsRZtKYmIcfn+VpcfHO30eSG7mLjCPEGYvgI7N60R/n8wLpVjes2
         D/XA==
X-Gm-Message-State: APjAAAWcNBe/gmS2vahRQxBqh35RxBJlx/jxa4v9JYKRc86/pemMROxJ
	VIw2OREyi5yVyKSSh8DvHzG01d+Y/8zaAqP25P4x6gj3eYbnBUPEAbEqBn0jaHCCEMDmD4X2o+5
	WcYtEPYbrQ1nGFGhswaLUo6um9VRsK/WwDH7DAsMuS3KuhTGfDdgDORfYziXAHx1etQ==
X-Received: by 2002:a67:b14d:: with SMTP id z13mr7692211vsl.190.1565222764643;
        Wed, 07 Aug 2019 17:06:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwY519+8kQxdFiyySUNM+DKoEcGNasQC33bAVgFM1dkEUU2LFWevuqpSZt0b58puZp+8U3r
X-Received: by 2002:a67:b14d:: with SMTP id z13mr7692198vsl.190.1565222763920;
        Wed, 07 Aug 2019 17:06:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565222763; cv=none;
        d=google.com; s=arc-20160816;
        b=ORfO7Ybn+pgzJJpRW6Dl8SjgMeuhx5JnRroOU/RefdzrPg62kRVQezHGq23L+yMcd6
         cjoetCZkJyH08rNdKaXc/q/VygnSg6PFgGIVk2RcPFJ76nFzp2IahWw5sAtNt4q0arOI
         FOOMbgdD6tad75kzOlH7dLTmoDeMj9axfgEh9Z66gQfDPyN9lZ4wURHq/uAoGmMcvkcL
         99WHI1Ivh4Ahlx2qayG5UvH5zlrzSLBNqfVnseMEXBguhsFNInVbgb2LnhJjnLe/MIZQ
         t2PgOuRZR+MUxiuk+il/4919NG2zpiNMyK6M/c6DJrCZzL+07sCCmHUtAtMYwdRWJDMj
         xRZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=I2Hc/6m77d4hpaNBr8SFkiuWXjVZymWAJofoezwBLnA=;
        b=X5V1qN8JdmTpK5kBkcxpQLbmNVzbsQsVPH67o0B40LmSbRSnpiq2/NNU7jrOlLzYfM
         Tw4aEidTrEHxIzea+3AqhDmhZNzTbS9Vv5jTdB9YaTD528hVefurnHQ3Pe4ucOhE0nmP
         pmzmNslC0cRA8SpQQUEEN+vhYv/Jy8a1FQGPSRQJQq53jd/ayq1tBWkJdKKFAZutMkPn
         kfSuneYj2kc0jmeXDf2t05mm3CH8YSFLlfq4/jXTwlH62IMo5tPD/KqvXJC3XQa/R8Pi
         klJ+aOcoZuMmRz626H0FN3xCMmwGtiJmNV3r4CvECndbJTUWjelP/1EGyJONOlndSEIu
         RigA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=P0m1eST+;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id a18si5879256vsr.297.2019.08.07.17.06.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 17:06:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=P0m1eST+;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7803VSY194693;
	Thu, 8 Aug 2019 00:05:54 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-transfer-encoding;
 s=corp-2018-07-02; bh=I2Hc/6m77d4hpaNBr8SFkiuWXjVZymWAJofoezwBLnA=;
 b=P0m1eST+/I2izEuD8KcsWz+2ub6H8FBzrm3ZhwxxjC7qoCzv+CLqWmhFsDkX0leIpido
 THsd4c3eH+U+wbKI+8X9e2swFdd30OTgnaAqDSMbfnFUwdN0dpTkCax+8N9tu6tMZNrI
 GGlhL1VdBlemkOuocM7VcdQ7r51iopSZmRMS/qvgafHCk0O/4qPQXm1bPBqr+e4jqDFY
 1NzsxYg9LAXeohz2xFlTGo4bANlm8fOzQwgL6jy/mdeOSw/nTwFRmoRkjugMVaSi7ggL
 NGgp6gj4Y7dC9e8InHHVwLoRdqcuXTvihvekZyO6SwF9ttWOZ5cdNaxex4BijcQSJ3Nz Lg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2u52wrf95t-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 08 Aug 2019 00:05:54 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7802nQf053058;
	Thu, 8 Aug 2019 00:05:53 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2u7578e6m9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 08 Aug 2019 00:05:53 +0000
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x7805kbB031716;
	Thu, 8 Aug 2019 00:05:46 GMT
Received: from monkey.oracle.com (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 07 Aug 2019 17:05:45 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ltp@lists.linux.it
Cc: Li Wang <liwang@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        Michal Hocko <mhocko@kernel.org>, Cyril Hrubis <chrubis@suse.cz>,
        xishi.qiuxishi@alibaba-inc.com,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH] hugetlbfs: fix hugetlb page migration/fault race causing SIGBUS
Date: Wed,  7 Aug 2019 17:05:33 -0700
Message-Id: <20190808000533.7701-1-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9342 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908070214
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9342 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908070214
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Li Wang discovered that LTP/move_page12 V2 sometimes triggers SIGBUS
in the kernel-v5.2.3 testing.  This is caused by a race between hugetlb
page migration and page fault.

If a hugetlb page can not be allocated to satisfy a page fault, the task
is sent SIGBUS.  This is normal hugetlbfs behavior.  A hugetlb fault
mutex exists to prevent two tasks from trying to instantiate the same
page.  This protects against the situation where there is only one
hugetlb page, and both tasks would try to allocate.  Without the mutex,
one would fail and SIGBUS even though the other fault would be successful.

There is a similar race between hugetlb page migration and fault.
Migration code will allocate a page for the target of the migration.
It will then unmap the original page from all page tables.  It does
this unmap by first clearing the pte and then writing a migration
entry.  The page table lock is held for the duration of this clear and
write operation.  However, the beginnings of the hugetlb page fault
code optimistically checks the pte without taking the page table lock.
If clear (as it can be during the migration unmap operation), a hugetlb
page allocation is attempted to satisfy the fault.  Note that the page
which will eventually satisfy this fault was already allocated by the
migration code.  However, the allocation within the fault path could
fail which would result in the task incorrectly being sent SIGBUS.

Ideally, we could take the hugetlb fault mutex in the migration code
when modifying the page tables.  However, locks must be taken in the
order of hugetlb fault mutex, page lock, page table lock.  This would
require significant rework of the migration code.  Instead, the issue
is addressed in the hugetlb fault code.  After failing to allocate a
huge page, take the page table lock and check for huge_pte_none before
returning an error.  This is the same check that must be made further
in the code even if page allocation is successful.

Reported-by: Li Wang <liwang@redhat.com>
Fixes: 290408d4a250 ("hugetlb: hugepage migration core")
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Tested-by: Li Wang <liwang@redhat.com>
---
 mm/hugetlb.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ede7e7f5d1ab..6d7296dd11b8 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3856,6 +3856,25 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 
 		page = alloc_huge_page(vma, haddr, 0);
 		if (IS_ERR(page)) {
+			/*
+			 * Returning error will result in faulting task being
+			 * sent SIGBUS.  The hugetlb fault mutex prevents two
+			 * tasks from racing to fault in the same page which
+			 * could result in false unable to allocate errors.
+			 * Page migration does not take the fault mutex, but
+			 * does a clear then write of pte's under page table
+			 * lock.  Page fault code could race with migration,
+			 * notice the clear pte and try to allocate a page
+			 * here.  Before returning error, get ptl and make
+			 * sure there really is no pte entry.
+			 */
+			ptl = huge_pte_lock(h, mm, ptep);
+			if (!huge_pte_none(huge_ptep_get(ptep))) {
+				ret = 0;
+				spin_unlock(ptl);
+				goto out;
+			}
+			spin_unlock(ptl);
 			ret = vmf_error(PTR_ERR(page));
 			goto out;
 		}
-- 
2.20.1

