Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8B1EC282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:47:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62B8322310
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:47:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62B8322310
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AABD46B026F; Tue, 16 Apr 2019 09:47:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5A1C6B0270; Tue, 16 Apr 2019 09:47:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 948096B0272; Tue, 16 Apr 2019 09:47:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2F8256B026F
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:03 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p26so2657705edy.19
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:47:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=G5RcpMbs5Qpi7XAuTIhInlGH2eGdEH42UsKUzadUQCU=;
        b=iCbTpXfCr5SslcjWm9bhs5AQi6orJuGDw9+zg0z8/9jUvdm1b5wISoDaplfg5659RJ
         SWXqkkR0LCoxfIvE5v2vlEO+c1klfWmmfHHUkcmrZRHZ1HP2fd5AWgEEhMibFjtMJ0Ww
         A5ZUYVG87OR9ZKBrzd0ZWZWJMtGeCR2mfKe8jK6vWazIpZWi4D84CAegs2ncRI5MXc6d
         g0s3wT9THBib5gUyE6Ltr+svrBFCx0OXYpyP5WHFXH+fxgKZbBGW98qtp/Rj3op62FC6
         MxUVdjZRizBKja+UXqq6K6cqZAQ7TX9sXs7aS/aeaxcMfvE4TMLiFVPB/2w1EyuSfZRO
         nk1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVNvlfDoIvfv7UG8upC51oL6bwIutqoRFC0luclA91W3BK8kv88
	1nH6PJ0npQJz5Z0fzFasS3+tPFVBKCIphdvse215cZgkzdx8Q1TOfwDgfUzhC7wEqoFMWlXWScz
	v/NuBmVCxcK0xzixAHxoWmYf7VwPe7VXUlAYaNKiTTxL4wwvI1uAl0qUhXvwh4/MNlg==
X-Received: by 2002:a17:906:46d1:: with SMTP id k17mr16143396ejs.104.1555422422668;
        Tue, 16 Apr 2019 06:47:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMou6fTPXL5/Lx5d4W4cNctLAxMysGQwSlVt+aRHQlEbqcdCCT+WE1w9t5QxsyUP7+y2Ru
X-Received: by 2002:a17:906:46d1:: with SMTP id k17mr16143317ejs.104.1555422421148;
        Tue, 16 Apr 2019 06:47:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422421; cv=none;
        d=google.com; s=arc-20160816;
        b=0+74KHkmxCqE4/RIF1ZnH+gJCQRYj+BXoszlVlLBsiLg5xjom9U94BJ03y3noNSjxZ
         UsSumxYorbF4wONWEYC3zjAY9raN4RfY+FiDPWNcJxlWrSMaOxrobAgRZ0WQOaiRhXH+
         VZYBRBNXLmZ7OyjJWFN77uiRlvCDkTqv6AM1mQP0300+lr3RBsD88GGkNUJ965zE8JSl
         +LzTYE+pNuHGeoJaKtb5aLinbNwTXuOxIbFLdD11tL7tb5gdWIGHEjdvuvY9HHk0d6+A
         +s9HxXCXhtmcjCGdRz+V5GGMwrtPH2Gc5GMd9BnJ7esP58XqQtrwjmq1c2fFE5X1ywgO
         2l4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=G5RcpMbs5Qpi7XAuTIhInlGH2eGdEH42UsKUzadUQCU=;
        b=lrYnYey/u+RJx1uHA1aclZcaKtFBGJRnrlQjXdGbvMeM+Lgfa3bgStNztbzdnupNMO
         4dZpQMWc4qOl07lLApzCR2c8XrSwdcSBIXmcLj4njClXCmBq+mJLCgdRQg7VD0SDP+ai
         9iyPiwNjPta7oF7Jn+cXEUPbNRL3K5/P/bwrp8CshR1mVR+jfNbAPqqKhufyMA6Q5omU
         xTmKaAdF1CYuvBTFYEVW61VqQ/tKHGj3ZBDYgVfinGBhEka2789QkxJnFQMAmDgdEm3z
         d0z5aLIo+9VjSv8jTu7DapcZBsSu4nCOw89SPwxDF6cgd54w2kqlNUaZXnSgfWoaleo8
         Gm4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d7si244793edx.319.2019.04.16.06.47.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:47:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDkS1b100127
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:59 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rwdvq70e7-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:59 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:46:55 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:46:43 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDkgCs32833784
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:46:42 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5135C4C04E;
	Tue, 16 Apr 2019 13:46:42 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DDCD34C05A;
	Tue, 16 Apr 2019 13:46:40 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:46:40 +0000 (GMT)
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
Subject: [PATCH v12 27/31] mm: add speculative page fault vmstats
Date: Tue, 16 Apr 2019 15:45:18 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0016-0000-0000-0000026F7280
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0017-0000-0000-000032CBBD97
Message-Id: <20190416134522.17540-28-ldufour@linux.ibm.com>
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

Add speculative_pgfault vmstat counter to count successful speculative page
fault handling.

Also fixing a minor typo in include/linux/vm_event_item.h.

Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 include/linux/vm_event_item.h | 3 +++
 mm/memory.c                   | 3 +++
 mm/vmstat.c                   | 5 ++++-
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 47a3441cf4c4..137666e91074 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -109,6 +109,9 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #ifdef CONFIG_SWAP
 		SWAP_RA,
 		SWAP_RA_HIT,
+#endif
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+		SPECULATIVE_PGFAULT,
 #endif
 		NR_VM_EVENT_ITEMS
 };
diff --git a/mm/memory.c b/mm/memory.c
index 509851ad7c95..c65e8011d285 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4367,6 +4367,9 @@ vm_fault_t __handle_speculative_fault(struct mm_struct *mm,
 
 	put_vma(vma);
 
+	if (ret != VM_FAULT_RETRY)
+		count_vm_event(SPECULATIVE_PGFAULT);
+
 	/*
 	 * The task may have entered a memcg OOM situation but
 	 * if the allocation error was handled gracefully (no
diff --git a/mm/vmstat.c b/mm/vmstat.c
index a7d493366a65..93f54b31e150 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1288,7 +1288,10 @@ const char * const vmstat_text[] = {
 	"swap_ra",
 	"swap_ra_hit",
 #endif
-#endif /* CONFIG_VM_EVENTS_COUNTERS */
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+	"speculative_pgfault",
+#endif
+#endif /* CONFIG_VM_EVENT_COUNTERS */
 };
 #endif /* CONFIG_PROC_FS || CONFIG_SYSFS || CONFIG_NUMA */
 
-- 
2.21.0

