Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E450AC04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:30:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91CF02085A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:30:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91CF02085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC7B06B0005; Tue, 14 May 2019 10:30:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E505F6B0006; Tue, 14 May 2019 10:30:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF0866B0007; Tue, 14 May 2019 10:30:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id A8B646B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 10:30:22 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id q2so31361384ywd.9
        for <linux-mm@kvack.org>; Tue, 14 May 2019 07:30:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=HEA1fAm6+GiGFeeD+DZdh4xa3o529LpMnR2t1PLskcM=;
        b=rZRXwLgAAXA5yjFBXxoCbbs8LurmOJE7NNNiCDb5dw2trdeawS/VvgKmDP8j6G37j9
         49fJFcI4CLB3Pszn6hzhQ9RPFV+YQ40oVdtJY5nv0Tt/FLvJMdOw5Q/MUHGFFWmyjaGZ
         DeQP5NebojNeOBus8KXgXybg1IqnElqZkYbMK8OVRvD/gihXF/U+ZhTal6ak6/q4ibh5
         4lFnCZHbRE22751nli1jDBhRPj4JWxwvEqha5zZt2vC1GnLA+dSPao3XoWOg9U2X2bZR
         YUiM9iyWY494J29roN6FlxqhYQgWSTPZjpyqBthJGmfqA3urW+ykT6oNPj7tHRlpblyP
         /FcA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVW+ge2+QRj63ep5tfXSMjP1DGxVG1Z6/snXkg46ikFo3PNlYct
	IIZZ0pxzQH52WMK9++4p7GFPO6/RFKmiL8HixPsSwW1oeuF+F3UXzJE4bJA6VBTEewaDnfmqRxO
	gSEAnuJNsRXM04Oi+RFyKLxL5SmfFfCrJbZHByASoyxFOHumLD/zfxQsJGf/73/a0tw==
X-Received: by 2002:a81:3955:: with SMTP id g82mr17619952ywa.274.1557844222406;
        Tue, 14 May 2019 07:30:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKWhS6uqIMZN4i5Nl1rtckeV5dxahrNW9VbCWEXArv61vrggE4v3NaB+9oUpsGvNE8uTk/
X-Received: by 2002:a81:3955:: with SMTP id g82mr17619871ywa.274.1557844221025;
        Tue, 14 May 2019 07:30:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557844221; cv=none;
        d=google.com; s=arc-20160816;
        b=eYVNhRAgI6LunSP1ocjqz5ypLwqDUQgobYaHhSoEb8mNUJqZ/PZguFdIKxys2A6E5Y
         BNM2G7MTOavoEbCY9zQD7ULa1Tku3+oSpFSbSID276YNbj4IhM5KhaHPO2R7KCIuoDGy
         er6zB8EY9Fn9h000OFGcff47SlsIee/BqE1DsDay11ufhKFR/SPHMNIbueTlgzhNeRt8
         vhXf1y8Jk9vjzoW8JzgLCuCpK2NAPeMBLaj4HEn/KQ0/96kOeMpN+vC5KFFJ7Hij23Ig
         paOuUFdZCcosJ8MU7tyA5KFv+JDOqc3QU/ity2vBLTMvpiKQUKRNPPTeB5aG1UylxPJa
         pw/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=HEA1fAm6+GiGFeeD+DZdh4xa3o529LpMnR2t1PLskcM=;
        b=slXoN/Bl/iup52kAmRJL4oMOmvV0OapEd8yyYXI8nUHLpf6Tw2z2tn0AfYX/ej1Hiz
         Uy54SdFCArO1STYVp0+fhCJ+IuPru+yWHTHAMFnhr1D3T3+4pJVSaz9rsuRrcAac4aDY
         Vm/zGDvBymDPCa6Qy+DC+buTALoJ+6lxcixVurapwPpY/gIGSiqB0BnuMN1u6b7Y4FiR
         De2ZiVuiKy9d/BuhK/6grodWn3Og2iKr+UNspaAaGK+h0fwBACJviRgUwDqT1KWb0i1D
         Ja4m/uBpj1VfJ47MyWUiS/jYoSvK8ymKBDK1vdRD07cs7sUyBvfqK8fSE9nUPm79o/H8
         gxDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f5si4815879ybc.483.2019.05.14.07.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 07:30:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4EEN9RO045374
	for <linux-mm@kvack.org>; Tue, 14 May 2019 10:30:20 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sfwu3n36w-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 May 2019 10:30:20 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 14 May 2019 15:30:01 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 14 May 2019 15:29:59 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4EETwkn40108172
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 14:29:58 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 977DB11C052;
	Tue, 14 May 2019 14:29:58 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 31F7211C04A;
	Tue, 14 May 2019 14:29:57 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 14 May 2019 14:29:57 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Tue, 14 May 2019 17:29:56 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH] mm/gup: continue VM_FAULT_RETRY processing event for pre-faults
Date: Tue, 14 May 2019 17:29:55 +0300
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19051414-0020-0000-0000-0000033C94E2
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19051414-0021-0000-0000-0000218F5139
Message-Id: <1557844195-18882-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-14_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905140103
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When get_user_pages*() is called with pages = NULL, the processing of
VM_FAULT_RETRY terminates early without actually retrying to fault-in all
the pages.

If the pages in the requested range belong to a VMA that has userfaultfd
registered, handle_userfault() returns VM_FAULT_RETRY *after* user space
has populated the page, but for the gup pre-fault case there's no actual
retry and the caller will get no pages although they are present.

This issue was uncovered when running post-copy memory restore in CRIU
after commit d9c9ce34ed5c ("x86/fpu: Fault-in user stack if
copy_fpstate_to_sigframe() fails").

After this change, the copying of FPU state to the sigframe switched from
copy_to_user() variants which caused a real page fault to get_user_pages()
with pages parameter set to NULL.

In post-copy mode of CRIU, the destination memory is managed with
userfaultfd and lack of the retry for pre-fault case in get_user_pages()
causes a crash of the restored process.

Making the pre-fault behavior of get_user_pages() the same as the "normal"
one fixes the issue.

Fixes: d9c9ce34ed5c ("x86/fpu: Fault-in user stack if copy_fpstate_to_sigframe() fails")
Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 mm/gup.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 91819b8..c32ae5a 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -936,10 +936,6 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 			BUG_ON(ret >= nr_pages);
 		}
 
-		if (!pages)
-			/* If it's a prefault don't insist harder */
-			return ret;
-
 		if (ret > 0) {
 			nr_pages -= ret;
 			pages_done += ret;
@@ -955,8 +951,12 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 				pages_done = ret;
 			break;
 		}
-		/* VM_FAULT_RETRY triggered, so seek to the faulting offset */
-		pages += ret;
+		/*
+		 * VM_FAULT_RETRY triggered, so seek to the faulting offset.
+		 * For the prefault case (!pages) we only update counts.
+		 */
+		if (likely(pages))
+			pages += ret;
 		start += ret << PAGE_SHIFT;
 
 		/*
@@ -979,7 +979,8 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		pages_done++;
 		if (!nr_pages)
 			break;
-		pages++;
+		if (likely(pages))
+			pages++;
 		start += PAGE_SIZE;
 	}
 	if (lock_dropped && *locked) {
-- 
2.7.4

