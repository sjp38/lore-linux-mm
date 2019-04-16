Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6698C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96564222D6
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96564222D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48F5D6B0292; Tue, 16 Apr 2019 09:47:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43FEB6B0294; Tue, 16 Apr 2019 09:47:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DFE26B0295; Tue, 16 Apr 2019 09:47:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0ABA86B0292
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:42 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id x66so15618571ywx.1
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:47:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=q7pYK44vfsHNTj5O8epyA0bbX50XM1Dt0+DiR1yO2TQ=;
        b=TDZ9n24leFjxKryIGEHUErrCSn7wNo7IQSeqLW/1W8U5hU4TLuA6J6dqmH6ej9YJpm
         GFKhAGAuX1TUPbWpCFaILkmPWshLGbhiGE/cDj/AJv9f5R6VBh0C3r2eUTTn0D/uNcgY
         kD93NYGAZJe5fbWgiExIKUF23U1RGuKrTBUsoVZwoTFEP9r3hIUWnNFnqCtyIulkKcK/
         xdQ25i15M8tUkJ3gNbP3fXZt9ZezaLFT1/llZdWEdCz6b2HHZKmPNdObbreWauJg6QAM
         /VWclTBKyQF0NElYvcBgRmviVWcdupOxhBAjAMbjST9xQKSBnVicugLYpl9M3ispzuyE
         ZZbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVHhsnx7XL7HmTA213reB3X5K4IVWOOs7DixQ9RxO6QaM0Dnmyo
	o+3laR4VvgqxFmSXVRtODmFwVbMt45cZYF9WNvCs97ginpLNBqF2Gmao/R8AdIegYMC6Gjsy/O4
	sjo5qXDP/DrKdajZXrfl6Fk6ZK3OO5W0QNY8SWW7so6a8SxtCWSjFiDd1zeWR4pHarQ==
X-Received: by 2002:a81:3bc5:: with SMTP id i188mr65480930ywa.404.1555422461742;
        Tue, 16 Apr 2019 06:47:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZydaWgDW8ot4StG3je2hDfN9E+tXdWNMyNEVr4CZxnuKR8JSnIS3wdJadMF2nnpyMaB/K
X-Received: by 2002:a81:3bc5:: with SMTP id i188mr65480822ywa.404.1555422460503;
        Tue, 16 Apr 2019 06:47:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422460; cv=none;
        d=google.com; s=arc-20160816;
        b=vABQGQWBhbAwfh1UbgG6H7snw3rWaBwXm/xioXAHzRv3j8i34U0fHAMNT4fj2PTvWS
         TpLCuslJsNQ8GB4lgzVeRBB11Vngd3RvXIeO2WbLw3IBajH/jPXD6YOc927hL6SvcMaa
         3dh+bb4JwwjLp5rRAXGvVnXfFiU+ULNcmrQBP9dynoHtWVwb4QITejd08PyXT+4gq9KP
         GecEZVccLs2T1CSG0J0rZjzSmBm6ZBLhVUxqigDX8oEZB1n1YxUP0TPYoOpb966RHx7A
         bN6iLtVR/2GfEDdAGEEDm4dN11/Cx3vnYsc+KEuJwRl/G8Vwhhq2nRkPtcyFg/fxIsnr
         i2Mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=q7pYK44vfsHNTj5O8epyA0bbX50XM1Dt0+DiR1yO2TQ=;
        b=IjdNr4Zy1/UIudN5VeAFMKl4VAqip4zQNi+xJPgQ5Ws03RRLT+TzNnY50U6Z/GVtr6
         Hsm/2N1p3iqMG+Y/sRyWyfmPAXMEG1GYBbdITi8Pr8bW5RxAWlpx0qmoZxGw+9PF+g0j
         k25jeOdfCszP6pUkqnlnkOVc55IKYgr2qCJRUigGrNVUUWvBDwcRU9EA4fRkFvrVhRiN
         nSeOmlc+T3iWwefrqKkwH3vva1+nsQK9XPQ1IoeBLIkfOMnyMFCy9MMSNPccSsez3Kce
         gkpF5nLocltdgFIJOg19BfB430ct8RSFJu57Y3yMmuwPOXrGfBCE+YV/9TqkiYwm+sD0
         XP+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x126si11773922ybc.456.2019.04.16.06.47.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:47:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDlNPO091859
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:39 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwfsus8fr-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:30 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:46:29 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:46:19 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDkH0i8716466
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:46:17 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 662084C040;
	Tue, 16 Apr 2019 13:46:17 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A03F74C046;
	Tue, 16 Apr 2019 13:46:15 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:46:15 +0000 (GMT)
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
        x86@kernel.org, Vinayak Menon <vinmenon@codeaurora.org>
Subject: [PATCH v12 18/31] mm: protect against PTE changes done by dup_mmap()
Date: Tue, 16 Apr 2019 15:45:09 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-4275-0000-0000-000003287653
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-4276-0000-0000-00003837A75B
Message-Id: <20190416134522.17540-19-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-16_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904160093
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Vinayak Menon and Ganesh Mahendran reported that the following scenario may
lead to thread being blocked due to data corruption:

    CPU 1                   CPU 2                    CPU 3
    Process 1,              Process 1,               Process 1,
    Thread A                Thread B                 Thread C

    while (1) {             while (1) {              while(1) {
    pthread_mutex_lock(l)   pthread_mutex_lock(l)    fork
    pthread_mutex_unlock(l) pthread_mutex_unlock(l)  }
    }                       }

In the details this happens because :

    CPU 1                CPU 2                       CPU 3
    fork()
    copy_pte_range()
      set PTE rdonly
    got to next VMA...
     .                   PTE is seen rdonly          PTE still writable
     .                   thread is writing to page
     .                   -> page fault
     .                     copy the page             Thread writes to page
     .                      .                        -> no page fault
     .                     update the PTE
     .                     flush TLB for that PTE
   flush TLB                                        PTE are now rdonly

So the write done by the CPU 3 is interfering with the page copy operation
done by CPU 2, leading to the data corruption.

To avoid this we mark all the VMA involved in the COW mechanism as changing
by calling vm_write_begin(). This ensures that the speculative page fault
handler will not try to handle a fault on these pages.
The marker is set until the TLB is flushed, ensuring that all the CPUs will
now see the PTE as not writable.
Once the TLB is flush, the marker is removed by calling vm_write_end().

The variable last is used to keep tracked of the latest VMA marked to
handle the error path where part of the VMA may have been marked.

Since multiple VMA from the same mm may have the sequence count increased
during this process, the use of the vm_raw_write_begin/end() is required to
avoid lockdep false warning messages.

Reported-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Reported-by: Vinayak Menon <vinmenon@codeaurora.org>
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 kernel/fork.c | 30 ++++++++++++++++++++++++++++--
 1 file changed, 28 insertions(+), 2 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index f8dae021c2e5..2992d2c95256 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -462,7 +462,7 @@ EXPORT_SYMBOL(free_task);
 static __latent_entropy int dup_mmap(struct mm_struct *mm,
 					struct mm_struct *oldmm)
 {
-	struct vm_area_struct *mpnt, *tmp, *prev, **pprev;
+	struct vm_area_struct *mpnt, *tmp, *prev, **pprev, *last = NULL;
 	struct rb_node **rb_link, *rb_parent;
 	int retval;
 	unsigned long charge;
@@ -581,8 +581,18 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 		rb_parent = &tmp->vm_rb;
 
 		mm->map_count++;
-		if (!(tmp->vm_flags & VM_WIPEONFORK))
+		if (!(tmp->vm_flags & VM_WIPEONFORK)) {
+			if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT)) {
+				/*
+				 * Mark this VMA as changing to prevent the
+				 * speculative page fault hanlder to process
+				 * it until the TLB are flushed below.
+				 */
+				last = mpnt;
+				vm_raw_write_begin(mpnt);
+			}
 			retval = copy_page_range(mm, oldmm, mpnt);
+		}
 
 		if (tmp->vm_ops && tmp->vm_ops->open)
 			tmp->vm_ops->open(tmp);
@@ -595,6 +605,22 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 out:
 	up_write(&mm->mmap_sem);
 	flush_tlb_mm(oldmm);
+
+	if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT)) {
+		/*
+		 * Since the TLB has been flush, we can safely unmark the
+		 * copied VMAs and allows the speculative page fault handler to
+		 * process them again.
+		 * Walk back the VMA list from the last marked VMA.
+		 */
+		for (; last; last = last->vm_prev) {
+			if (last->vm_flags & VM_DONTCOPY)
+				continue;
+			if (!(last->vm_flags & VM_WIPEONFORK))
+				vm_raw_write_end(last);
+		}
+	}
+
 	up_write(&oldmm->mmap_sem);
 	dup_userfaultfd_complete(&uf);
 fail_uprobe_end:
-- 
2.21.0

