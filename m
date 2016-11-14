Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6FEC16B0038
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 06:12:58 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 83so42440304pfx.1
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 03:12:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j19si21795974pgk.185.2016.11.14.03.12.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 03:12:57 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAEB8xN6034133
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 06:12:56 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26q70c66jh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 06:12:56 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Mon, 14 Nov 2016 11:12:55 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id ED8632190023
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 11:12:05 +0000 (GMT)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAEBCq2Z39649446
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 11:12:52 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAEBCqam017097
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 04:12:52 -0700
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH] mm/pkeys: generate pkey system call code only if ARCH_HAS_PKEYS is selected
Date: Mon, 14 Nov 2016 12:12:51 +0100
Message-Id: <20161114111251.70084-1-heiko.carstens@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>

Having code for the pkey_mprotect, pkey_alloc and pkey_free system
calls makes only sense if ARCH_HAS_PKEYS is selected. If not selected
these system calls will always return -ENOSPC or -EINVAL.

To simplify things and have less code generate the pkey system call
code only if ARCH_HAS_PKEYS is selected.

For architectures which have already wired up the system calls, but do
not select ARCH_HAS_PKEYS this will result in less generated code and
a different return code: the three system calls will now always return
-ENOSYS, using the cond_syscall mechanism.

For architectures which have not wired up the system calls less
unreachable code will be generated.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 mm/mprotect.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 11936526b08b..a06e91c4de29 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -484,6 +484,8 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 	return do_mprotect_pkey(start, len, prot, -1);
 }
 
+#ifdef CONFIG_ARCH_HAS_PKEYS
+
 SYSCALL_DEFINE4(pkey_mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot, int, pkey)
 {
@@ -534,3 +536,5 @@ SYSCALL_DEFINE1(pkey_free, int, pkey)
 	 */
 	return ret;
 }
+
+#endif /* CONFIG_ARCH_HAS_PKEYS */
-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
