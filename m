Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12A1AC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3DEC22310
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3DEC22310
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8622B6B0273; Tue, 16 Apr 2019 09:47:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8157A6B0274; Tue, 16 Apr 2019 09:47:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68ACB6B0275; Tue, 16 Apr 2019 09:47:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 43A636B0273
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:07 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id y6so15678866ybb.20
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:47:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=UAHX411TVfkHtYtx3rwTP/R30VyZz8uurL0FWWNuBRg=;
        b=igTsLL661aI6Y14h0YUn361eGffPN3aSFebQkrNriz0+tqDgmq1rcN4Mu08Lm2Xvfg
         1LvzUUEaXqbl9Q9JFFW6cbytcPFUH8ER3uRULm6eW88gnaB4A8oV7f5XJDMoqye1CPXS
         z7ZzVqhtanqLjJgKhBgJNq594pwpnJlgVSofdontqZlNTgwAgwHx/PxloUJ1v+RJ/sih
         vLEhtrRmCy+h8xfYVws18k3rtrvb2T+X3PdHkUZt/OmoTmayffazzAOPT+Cxy4ve0twW
         jKlBvwXzAxbKfnaIRxp9yZKmnJxQLun7qMurUJfM7Um6LEqK/tdIbTHjdmyV3hs37gna
         E4OA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXcjJuUz7r+Vd53rquTHlc4UtXnrjAxXwyfjcwnbiXr3NZ2we4n
	Mne/2MgbvfxHsfTczbwba2aw9mAtGtumiUcY7GiMNHQSENTg81EcMQNby5PM7YpS2JoBpUK2ps6
	qWVf0PaKAQo2/9vL1APwURZiBPalgPSrTQglNfvI3NXIbxCwyTsCUsHrLOfF3KGIA5g==
X-Received: by 2002:a81:1d49:: with SMTP id d70mr67013274ywd.84.1555422427015;
        Tue, 16 Apr 2019 06:47:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHiPemEeekaTMNp8S/DxryBG/c/OtYnJiXFuSwdRptu7Z3457YoWkGAenFt0Z3uyQCzc2T
X-Received: by 2002:a81:1d49:: with SMTP id d70mr67013191ywd.84.1555422426040;
        Tue, 16 Apr 2019 06:47:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422426; cv=none;
        d=google.com; s=arc-20160816;
        b=EaCADxEC5WsLtlAsutcelXOtdymlAzMgzsVdXK2Ghvhar22aBPlJbJq9Mg2YxpjzL6
         Nf2cjzU8EKj+pgxFTn6LOmCQWUv9TJT7h5ANziajrIfPjjRrKmTTj0ImU5bMbw9u2keJ
         NuclGlxyQyIO2ZYn5F+gxe4jJoJSPOn6CI7fO/JGgpVytfdElPO+nH3vxJLSOVnWwfsH
         jokxTpDm87GIYECQ7roUpRo5OWr5pXWhbuwceLnpmS/ABxPZQr6m+ii3G9hpLzmZQDqW
         Pjs8ZQA91KOeUGFowZfAK+k/UYxrDZZf3fNX3weFaH5h8PhrK15WjBldU/LQXRqlaD1C
         tRAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=UAHX411TVfkHtYtx3rwTP/R30VyZz8uurL0FWWNuBRg=;
        b=Pr2QSiXAywjpSD9Hj/Lt8elUJiWEUx9qMcvjZqJZ6tLzVp1el11FfqbQY7GaumD4c3
         TpsHA9x/hEHOgxDKkbXSen+MTJpzyRmA7UIQnp7KWuBRTEhvpVBmEhXrq27txjjU016D
         6/7YNFnwBIMbo02Gv52ORhf0xfL4XwHXJv0IuqCHjNzTWV1RNik53qJ997S7+pB/6crL
         DFe5YNA/OYOvRipaDunU8NElwskywHT9tra4sLkv8iV4wS7kQZw8OsIKUIUUOZSjAOtx
         cIh6KglnknHaFCRLBCNR+DXFfYyv+76FjGW39Zmg4ndgTvw9SWU6jz3aokNnDUYWq3GX
         udDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u129si3612603ybf.268.2019.04.16.06.47.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:47:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDkpwE059599
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:05 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwe36nypd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:01 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:46:49 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:46:38 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDkbc850200614
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:46:37 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 473624C04E;
	Tue, 16 Apr 2019 13:46:37 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A910F4C04A;
	Tue, 16 Apr 2019 13:46:35 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:46:35 +0000 (GMT)
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
Subject: [PATCH v12 25/31] perf: add a speculative page fault sw event
Date: Tue, 16 Apr 2019 15:45:16 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0016-0000-0000-0000026F727D
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0017-0000-0000-000032CBBD95
Message-Id: <20190416134522.17540-26-ldufour@linux.ibm.com>
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

Add a new software event to count succeeded speculative page faults.

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 include/uapi/linux/perf_event.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/perf_event.h b/include/uapi/linux/perf_event.h
index 7198ddd0c6b1..3b4356c55caa 100644
--- a/include/uapi/linux/perf_event.h
+++ b/include/uapi/linux/perf_event.h
@@ -112,6 +112,7 @@ enum perf_sw_ids {
 	PERF_COUNT_SW_EMULATION_FAULTS		= 8,
 	PERF_COUNT_SW_DUMMY			= 9,
 	PERF_COUNT_SW_BPF_OUTPUT		= 10,
+	PERF_COUNT_SW_SPF			= 11,
 
 	PERF_COUNT_SW_MAX,			/* non-ABI */
 };
-- 
2.21.0

