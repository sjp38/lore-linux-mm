Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F462C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0082222B2
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0082222B2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 861386B0277; Tue, 16 Apr 2019 09:47:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C1EE6B0278; Tue, 16 Apr 2019 09:47:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68BAE6B0279; Tue, 16 Apr 2019 09:47:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 18EC76B0278
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:20 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g1so10962859edm.16
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:47:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=k9/z2p3j44DZBGh5PTqmYkMKjzVk66Vx/Q6VNa38JtM=;
        b=MquTjq2kRIrluY7/skOCnmPS6F3roK6HRaK1Izm3URFikYxRQtBYbsc/dh6OfP4Z8w
         JT2Q7l9T1yiiIufRk1ztQXm+lTJRvjeIVDOzStuDPsVEcj4qkYAcXd4z4yvNtCUEZboM
         P+j3U0tb+pfRCTIR4iD6yizU8Pl3DyVOijqM7eVxgd7b1qddrBugmchSbehBQr18n9u4
         8kOKqkqfg1DDCtNx699aUni5qtmbwHnJ5uAOUwAB4sVs9k5LQxHbXEyWmXvGmIghxHmK
         jkV7gSuejxPepkxa5eKycdKrpBwZ3mmbUBV6Ou8YHxk0NaQIZ8IzP0a46kqlReT7VyDp
         EFaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUiQ3ab1RRi6/Ge0o6awhysfB65okh+1yFP6QHYMAAjEa8HHEM2
	Z+AmTCguNS8cqfYza11jEnKTt99eHbOFbBtvH08QT7GSiF3Nk49pmL6bm+uSY9HmY83Z/LyEXlw
	VYJY/n8PaDoXp2jFmDHeHCphpM508Kn2e4+2f4UN63aA4xNm/1sSMv9ekg7iFaPaQJg==
X-Received: by 2002:a50:92a6:: with SMTP id k35mr21816409eda.100.1555422439591;
        Tue, 16 Apr 2019 06:47:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDpvLmJC+GfM+uXEbiQB+HNdZ3lUt8g3Pig/cx0wZ7DxaHt47Nut0G7rTYnEUQeVVSBRUP
X-Received: by 2002:a50:92a6:: with SMTP id k35mr21816329eda.100.1555422438185;
        Tue, 16 Apr 2019 06:47:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422438; cv=none;
        d=google.com; s=arc-20160816;
        b=hKr04n3J35CXygI92idexF6sm7YtZF3NgyYyFMehJA+7Z4NxDVs9FYqRXJkjniLBeu
         LEt4ri9CuRgf0X+cZ8HSKpehK5VrS0vztRvx44894t5k573QgW/VIoJUFioTTvs7V1CG
         /EkeIwU0wNKp8BLuThZQkn4FCrw0YBJdOqotSPkfdkfwCbOxApkey++bIdF7ggjiuq1P
         vTBABqwT21frtpul/UMkv5BK3TZnfdluTRlw7p30T2EGgWaDyE6uBWrPY89mAa12EOMH
         +PKPsdiEw8nPm867orQdpnaSMRjaf0UYEcEtBgzsT78vuDazeO5JfgEIx+0RAxrZktpX
         rngg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=k9/z2p3j44DZBGh5PTqmYkMKjzVk66Vx/Q6VNa38JtM=;
        b=MJn4dCF9oujSm1LDBcPlFGLA0+1AezxhXNP0qkI9ju0p/bt33wdAf4ffK+o2qxGQGk
         Q+Nmnxyd3rbqWV/bIaltMbdGXGtUG6zOIrOLlNIDLKWlnNskEI9zzpvvO0wsn0zBU88G
         ISeZS+Gy7WBBjdxnfzuJgnI/B40oF49opwyPNrxY6RKrfN8kYb+gRqN/h8q4vrwzSvJW
         AmfXtbBF+sd6Z3RdFLThhdf7EwDb4llqC1LLlIGcO9Y61joeQO6P5ysSDfBenL8YhlSt
         Shmh4xXsYdgLK2IiG3lu3QL209ru7a5IT8FWb0mC7nlHtCrjAmNUeJ6gtOgKd2HvuDJ2
         cOnw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w23si4997066eji.29.2019.04.16.06.47.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:47:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDkcdK175887
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:16 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rwfbattea-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:15 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:46:58 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:46:47 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDkjdC54067278
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:46:45 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E76AD4C05C;
	Tue, 16 Apr 2019 13:46:44 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6053D4C052;
	Tue, 16 Apr 2019 13:46:43 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:46:43 +0000 (GMT)
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
Subject: [PATCH v12 28/31] x86/mm: add speculative pagefault handling
Date: Tue, 16 Apr 2019 15:45:19 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0016-0000-0000-0000026F7281
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0017-0000-0000-000032CBBD98
Message-Id: <20190416134522.17540-29-ldufour@linux.ibm.com>
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

From: Peter Zijlstra <peterz@infradead.org>

Try a speculative fault before acquiring mmap_sem, if it returns with
VM_FAULT_RETRY continue with the mmap_sem acquisition and do the
traditional fault.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

[Clearing of FAULT_FLAG_ALLOW_RETRY is now done in
 handle_speculative_fault()]
[Retry with usual fault path in the case VM_ERROR is returned by
 handle_speculative_fault(). This allows signal to be delivered]
[Don't build SPF call if !CONFIG_SPECULATIVE_PAGE_FAULT]
[Handle memory protection key fault]
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 arch/x86/mm/fault.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 667f1da36208..4390d207a7a1 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1401,6 +1401,18 @@ void do_user_addr_fault(struct pt_regs *regs,
 	}
 #endif
 
+	/*
+	 * Do not try to do a speculative page fault if the fault was due to
+	 * protection keys since it can't be resolved.
+	 */
+	if (!(hw_error_code & X86_PF_PK)) {
+		fault = handle_speculative_fault(mm, address, flags);
+		if (fault != VM_FAULT_RETRY) {
+			perf_sw_event(PERF_COUNT_SW_SPF, 1, regs, address);
+			goto done;
+		}
+	}
+
 	/*
 	 * Kernel-mode access to the user address space should only occur
 	 * on well-defined single instructions listed in the exception
@@ -1499,6 +1511,8 @@ void do_user_addr_fault(struct pt_regs *regs,
 	}
 
 	up_read(&mm->mmap_sem);
+
+done:
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		mm_fault_error(regs, hw_error_code, address, fault);
 		return;
-- 
2.21.0

