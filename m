Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1B56C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D1BD222B2
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D1BD222B2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D68966B0006; Tue, 16 Apr 2019 09:47:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D19056B0274; Tue, 16 Apr 2019 09:47:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB9646B0275; Tue, 16 Apr 2019 09:47:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 97AEA6B0006
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:12 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id j63so15584221ywb.15
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:47:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=rgeNuvJuXBGvLDIQM3tb0bsPHtZK+4OhBnf+76arYR0=;
        b=kpRnJMQBLv7xn4A+lJhLqrT8OKpffY+qr5j1q43qWrHfzq2iyFH3Dm5UHNRi5jmhye
         NSORmzWMu5wa1pxLBWVZdkUngduiRQ6NUtfNRCo/0nLHaQoPud/T0WZKM3Gwpee3fZsY
         LVTaGml+Zv1sEjKXjxRdRiRJJraWgefuKx0nHkYcQSxN6MhBw0ClAADm6oaO/oUQfS/D
         JXAyeLEQw3/Od1vlEKUpOlNk8J5AedjqA8R/dDmZsHeR8BXRLJS32A3zbOikME0Ym4VF
         dWEYMHwC21WZtVC79Fvghs5r7RtIJHH9yb2sau/oibJuui5NUsgkPDpui7KSv7MWGL52
         ZkQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAU7Dss4GTp0PvMfkRue5QZ4Lfnw+KgFc5z29KP1ByRhDrLLo1MK
	xNfCqLRdPIRoepZdAFAWW7yp4KEf4VTXje9NuPUSapv9iNlYHmhHjlikSNN1TtUneJ6VWN6X9AK
	J1FHdNZ/lEb+QfyiKSRlPH5jOd7PeZdFcPBO/Dm0uB3OE0aDeIPCeCetswFSU9hGBxA==
X-Received: by 2002:a0d:d58d:: with SMTP id x135mr65956971ywd.396.1555422432311;
        Tue, 16 Apr 2019 06:47:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxps3DJ431u8XdXJbQIW70c29mUyo17UqdrmuTJ/yuZnV4tRqgP4x1giE+vRUY0L85M7ezJ
X-Received: by 2002:a0d:d58d:: with SMTP id x135mr65956857ywd.396.1555422431064;
        Tue, 16 Apr 2019 06:47:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422431; cv=none;
        d=google.com; s=arc-20160816;
        b=M5W3Yc8OrQgkNKcOxpaTZrQ96k1FcBRcUP3ec0EMtEsq9DJWKsccC6szMLxqaHRnys
         UxvwlIMA16dmdZHDisguyrjwjo7A7SUJHcMgSAPxctR8rw2uaE577R0BR5FHNM7+Crvk
         agx4rC5Nv+/gEApBTQbmRT4oyTYMQo9uWUzScgI31RQhsF952HTNyRX72tGc/zu8Unv4
         SrRyvIpqkYY6ilyoLWrnDDHNvYPh7GVK3jgUYn6dpHfXVFRfncEMagvwiCQ4oQOO6Did
         SB8vYqSkrsRIWGXSMtD18IIuCNocsk2k9AS5gpoMGg2Va5TPhOop2YTBGHTaSalud/8C
         eI/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=rgeNuvJuXBGvLDIQM3tb0bsPHtZK+4OhBnf+76arYR0=;
        b=PjxYDB0jh/YSdfKlGXCuTUFtHJLAi2vZ+JLb3pEQBuD+NEqjjkA5Ph7BmEd4f4MrfE
         1dvcCiCikBpRXOzekXSfwBks+zQaVCgHKs5QQlVmU+EoSwYl17OR6wwwrmlceM1C+zo1
         3aewiM8hh2RizF3mBaP5Z+vIV4Pqdt+R1ndOvKHbavFCtO0NtJXE0ZgU9tY9PfLTdQJQ
         gVbbYOwN/ypZ8oudEFBDUtK/71PJsTnu193L/4nvFFosYJJ+0jEvJkvCWGXfJAiwNmbK
         lyGcQcwcayahQ8GkWQ+ewq0qwIG7AvwWTzU+QlD+Bbsw3gSzEdZrN9woq/WbwdiwkAwl
         sQjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x144si20350614ywd.157.2019.04.16.06.47.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:47:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDkIaC129607
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:10 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwe6cnqfw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:08 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:47:04 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:46:53 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDkqd060686582
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:46:52 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DE5414C066;
	Tue, 16 Apr 2019 13:46:51 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6804E4C046;
	Tue, 16 Apr 2019 13:46:50 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:46:50 +0000 (GMT)
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
Subject: [PATCH v12 31/31] mm: Add a speculative page fault switch in sysctl
Date: Tue, 16 Apr 2019 15:45:22 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0020-0000-0000-000003307064
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0021-0000-0000-00002182B514
Message-Id: <20190416134522.17540-32-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-16_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=781 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904160093
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This allows to turn on/off the use of the speculative page fault handler.

By default it's turned on.

Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 include/linux/mm.h | 3 +++
 kernel/sysctl.c    | 9 +++++++++
 mm/memory.c        | 3 +++
 3 files changed, 15 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ec609cbad25a..f5bf13a2197a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1531,6 +1531,7 @@ extern vm_fault_t handle_mm_fault(struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags);
 
 #ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+extern int sysctl_speculative_page_fault;
 extern vm_fault_t __handle_speculative_fault(struct mm_struct *mm,
 					     unsigned long address,
 					     unsigned int flags);
@@ -1538,6 +1539,8 @@ static inline vm_fault_t handle_speculative_fault(struct mm_struct *mm,
 						  unsigned long address,
 						  unsigned int flags)
 {
+	if (unlikely(!sysctl_speculative_page_fault))
+		return VM_FAULT_RETRY;
 	/*
 	 * Try speculative page fault for multithreaded user space task only.
 	 */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 9df14b07a488..3a712e52c14a 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1295,6 +1295,15 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 		.extra2		= &two,
 	},
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+	{
+		.procname	= "speculative_page_fault",
+		.data		= &sysctl_speculative_page_fault,
+		.maxlen		= sizeof(sysctl_speculative_page_fault),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+#endif
 	{
 		.procname	= "panic_on_oom",
 		.data		= &sysctl_panic_on_oom,
diff --git a/mm/memory.c b/mm/memory.c
index c65e8011d285..a12a60891350 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -83,6 +83,9 @@
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/pagefault.h>
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+int sysctl_speculative_page_fault = 1;
+#endif
 
 #if defined(LAST_CPUPID_NOT_IN_PAGE_FLAGS) && !defined(CONFIG_COMPILE_TEST)
 #warning Unfortunate NUMA and NUMA Balancing config, growing page-frame for last_cpupid.
-- 
2.21.0

