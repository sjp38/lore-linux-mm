Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D7BFC4151A
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 14:27:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 450D721908
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 14:27:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 450D721908
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2FA48E0033; Thu,  7 Feb 2019 09:27:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADF0E8E0002; Thu,  7 Feb 2019 09:27:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A84C8E0033; Thu,  7 Feb 2019 09:27:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1B98E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 09:27:40 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 3so2563pfn.16
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 06:27:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=j3gjqotppROLs+s8k3htrWgJ0pyO2c5kIWZ41J0Hh40=;
        b=Ub+d4eSIegrkYLOKMu8LznBwXW1Yu8jEBEDI9rBroLp11zg1MHkf9rAXfmbYQblqX4
         YDAlIdbWEa/ETJph/RwXLRv10P09HubssmSyLd2PO9S0njTTZ37E0qe+UJbLSc+Ev8TC
         /2LI3c3tWg20KV/T1S+NPIGrgZ7rE/lUFG4kzyn/PW+rXgBV1pM+wYvdWxyNYv0uhq6I
         oB+Ni0TWgI3i2dE9GbHtjQnIDF7LkqeQhoWAQK0bk7ym6ex0l5Ak22ztPUJUNHdIjHOF
         XEvCOiWw7hzgHJh+zfHIpPxE6N6rR+TZXrNg8SZlGDeEqX6PgpqSfdCKHzwaHBlNH3dB
         qi2A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubxCQel9gnDwUfidurRlpNg0ul4qJnGe7UTewLrTd0I6kIgvh7X
	GDHJhfvViZS/sF5GGXfa3y8opWEEYqeHIfGCWjjuxvQLXUmuEZ65WFMPASOysfJSUiaIxqm9lt6
	CFfFV2vfpbjGiZj8y8n0W4QkIa0bKHxrlgXqECW7h7hroBk8vXp4bvfdWKF6WmWeCfQ==
X-Received: by 2002:a63:ce08:: with SMTP id y8mr10198782pgf.388.1549549660020;
        Thu, 07 Feb 2019 06:27:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbhxjsWxJGrEygcVUP5kBFmid3EFrDeoQtZezTwpCRdxQVOnGrGXmM408aRTEi56uwPzMdJ
X-Received: by 2002:a63:ce08:: with SMTP id y8mr10198694pgf.388.1549549658801;
        Thu, 07 Feb 2019 06:27:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549549658; cv=none;
        d=google.com; s=arc-20160816;
        b=Nh4z9Zz5LvbRGdo0efCVMZ0p7dowgXiJqa+cAx1m1Z70IJClPICt3cfAIn1cfmJ9FY
         +tithZNCrzty1MByoPv26TEfuGTx6VPS44+ZSeRmmr5dL3vlXxBe6fUJ55E42d7jNqhT
         mr898y+KBWVApLJBup8Pp4IeRVubKXzdUT+MAJ9u84L95GYoZGXBKVwE5WLr+EuFtDj/
         G0yy+Z+z5K8RYX4iq+96BXbd6C1uhUXw87WOTOD3acEVt07x35q7j2TMtRRWApvNfrAJ
         SWrUTw5QPyBmBDFNJL97YyfWbhd/RS93we2bpDXuKEdDTYMfG1c5d23bweDhEMOFQvky
         50tQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=j3gjqotppROLs+s8k3htrWgJ0pyO2c5kIWZ41J0Hh40=;
        b=A/AU6vKFEFOjrM9u4mXayHURVaXteao9Nbki+aqC8QJ4zvEbusUbYxGF4A6AL5i/cI
         0ZigKMko8EUgAUkbF2cZdsl6iwllRPEpZVMSR/kbJhmCvabGuHHLrGmsJshk8t24/ksE
         Gc1VqLnJmL9O42KS5whdqTbZSnLQksEecozdphmyywAcOXPIu0jmDVslk+NwqL/G8pFd
         WO0ic9Gyizh2uFdxJr7taorQyQrpeq4s40ssmSkSKRcr1uYtkOmnNPxJ6TpJEkX7Qb9p
         /WDp+ixltWUvMfpoUVjelEMjXgzHG5EY0glJE75nTq9K4Uho4KXL/GtvRBHr2YEhadJ2
         XZLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 187si6174151pfv.238.2019.02.07.06.27.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 06:27:38 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x17EH4M1108553
	for <linux-mm@kvack.org>; Thu, 7 Feb 2019 09:27:38 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qgpa1gjbr-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 07 Feb 2019 09:27:37 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 7 Feb 2019 14:27:35 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 7 Feb 2019 14:27:33 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x17ERWNU37748932
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 7 Feb 2019 14:27:32 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 11BA411C04A;
	Thu,  7 Feb 2019 14:27:32 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8F66611C05E;
	Thu,  7 Feb 2019 14:27:30 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu,  7 Feb 2019 14:27:30 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Thu, 07 Feb 2019 16:27:29 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [RESEND PATCH 2/3] docs/core-api/mm: fix user memory accessors formatting
Date: Thu,  7 Feb 2019 16:27:23 +0200
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1549549644-4903-1-git-send-email-rppt@linux.ibm.com>
References: <1549549644-4903-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19020714-0028-0000-0000-00000345C672
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19020714-0029-0000-0000-00002403D778
Message-Id: <1549549644-4903-3-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-07_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=846 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902070111
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The descriptions of userspace memory access functions had minor issues with
formatting that made kernel-doc unable to properly detect the
function/macro names and the return value sections:

./arch/x86/include/asm/uaccess.h:80: info: Scanning doc for
./arch/x86/include/asm/uaccess.h:139: info: Scanning doc for
./arch/x86/include/asm/uaccess.h:231: info: Scanning doc for
./arch/x86/include/asm/uaccess.h:505: info: Scanning doc for
./arch/x86/include/asm/uaccess.h:530: info: Scanning doc for
./arch/x86/lib/usercopy_32.c:58: info: Scanning doc for
./arch/x86/lib/usercopy_32.c:69: warning: No description found for return
value of 'clear_user'
./arch/x86/lib/usercopy_32.c:78: info: Scanning doc for
./arch/x86/lib/usercopy_32.c:90: warning: No description found for return
value of '__clear_user'

Fix the formatting.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/x86/include/asm/uaccess.h | 24 ++++++++++++------------
 arch/x86/lib/usercopy_32.c     |  8 ++++----
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
index a77445d..83ce5faa 100644
--- a/arch/x86/include/asm/uaccess.h
+++ b/arch/x86/include/asm/uaccess.h
@@ -76,7 +76,7 @@ static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size, un
 #endif
 
 /**
- * access_ok: - Checks if a user space pointer is valid
+ * access_ok - Checks if a user space pointer is valid
  * @addr: User space pointer to start of block to check
  * @size: Size of block to check
  *
@@ -85,12 +85,12 @@ static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size, un
  *
  * Checks if a pointer to a block of memory in user space is valid.
  *
- * Returns true (nonzero) if the memory block may be valid, false (zero)
- * if it is definitely invalid.
- *
  * Note that, depending on architecture, this function probably just
  * checks that the pointer is in the user space range - after calling
  * this function, memory access functions may still return -EFAULT.
+ *
+ * Return: true (nonzero) if the memory block may be valid, false (zero)
+ * if it is definitely invalid.
  */
 #define access_ok(addr, size)					\
 ({									\
@@ -135,7 +135,7 @@ extern int __get_user_bad(void);
 __typeof__(__builtin_choose_expr(sizeof(x) > sizeof(0UL), 0ULL, 0UL))
 
 /**
- * get_user: - Get a simple variable from user space.
+ * get_user - Get a simple variable from user space.
  * @x:   Variable to store result.
  * @ptr: Source address, in user space.
  *
@@ -149,7 +149,7 @@ __typeof__(__builtin_choose_expr(sizeof(x) > sizeof(0UL), 0ULL, 0UL))
  * @ptr must have pointer-to-simple-variable type, and the result of
  * dereferencing @ptr must be assignable to @x without a cast.
  *
- * Returns zero on success, or -EFAULT on error.
+ * Return: zero on success, or -EFAULT on error.
  * On error, the variable @x is set to zero.
  */
 /*
@@ -227,7 +227,7 @@ extern void __put_user_4(void);
 extern void __put_user_8(void);
 
 /**
- * put_user: - Write a simple value into user space.
+ * put_user - Write a simple value into user space.
  * @x:   Value to copy to user space.
  * @ptr: Destination address, in user space.
  *
@@ -241,7 +241,7 @@ extern void __put_user_8(void);
  * @ptr must have pointer-to-simple-variable type, and @x must be assignable
  * to the result of dereferencing @ptr.
  *
- * Returns zero on success, or -EFAULT on error.
+ * Return: zero on success, or -EFAULT on error.
  */
 #define put_user(x, ptr)					\
 ({								\
@@ -501,7 +501,7 @@ struct __large_struct { unsigned long buf[100]; };
 } while (0)
 
 /**
- * __get_user: - Get a simple variable from user space, with less checking.
+ * __get_user - Get a simple variable from user space, with less checking.
  * @x:   Variable to store result.
  * @ptr: Source address, in user space.
  *
@@ -518,7 +518,7 @@ struct __large_struct { unsigned long buf[100]; };
  * Caller must check the pointer with access_ok() before calling this
  * function.
  *
- * Returns zero on success, or -EFAULT on error.
+ * Return: zero on success, or -EFAULT on error.
  * On error, the variable @x is set to zero.
  */
 
@@ -526,7 +526,7 @@ struct __large_struct { unsigned long buf[100]; };
 	__get_user_nocheck((x), (ptr), sizeof(*(ptr)))
 
 /**
- * __put_user: - Write a simple value into user space, with less checking.
+ * __put_user - Write a simple value into user space, with less checking.
  * @x:   Value to copy to user space.
  * @ptr: Destination address, in user space.
  *
@@ -543,7 +543,7 @@ struct __large_struct { unsigned long buf[100]; };
  * Caller must check the pointer with access_ok() before calling this
  * function.
  *
- * Returns zero on success, or -EFAULT on error.
+ * Return: zero on success, or -EFAULT on error.
  */
 
 #define __put_user(x, ptr)						\
diff --git a/arch/x86/lib/usercopy_32.c b/arch/x86/lib/usercopy_32.c
index bfd94e7..7d29077 100644
--- a/arch/x86/lib/usercopy_32.c
+++ b/arch/x86/lib/usercopy_32.c
@@ -54,13 +54,13 @@ do {									\
 } while (0)
 
 /**
- * clear_user: - Zero a block of memory in user space.
+ * clear_user - Zero a block of memory in user space.
  * @to:   Destination address, in user space.
  * @n:    Number of bytes to zero.
  *
  * Zero a block of memory in user space.
  *
- * Returns number of bytes that could not be cleared.
+ * Return: number of bytes that could not be cleared.
  * On success, this will be zero.
  */
 unsigned long
@@ -74,14 +74,14 @@ clear_user(void __user *to, unsigned long n)
 EXPORT_SYMBOL(clear_user);
 
 /**
- * __clear_user: - Zero a block of memory in user space, with less checking.
+ * __clear_user - Zero a block of memory in user space, with less checking.
  * @to:   Destination address, in user space.
  * @n:    Number of bytes to zero.
  *
  * Zero a block of memory in user space.  Caller must check
  * the specified block with access_ok() before calling this function.
  *
- * Returns number of bytes that could not be cleared.
+ * Return: number of bytes that could not be cleared.
  * On success, this will be zero.
  */
 unsigned long
-- 
2.7.4

