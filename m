Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 340FF6B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 03:28:07 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g1so1269965148pgn.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 00:28:07 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g1si68279374plb.278.2017.01.03.00.28.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 00:28:06 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v038O216033739
	for <linux-mm@kvack.org>; Tue, 3 Jan 2017 03:28:05 -0500
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0a-001b2d01.pphosted.com with ESMTP id 27r28dm5dr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 03 Jan 2017 03:28:05 -0500
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 3 Jan 2017 13:58:02 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id CA7BDE0062
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 13:58:54 +0530 (IST)
Received: from d28av08.in.ibm.com (d28av08.in.ibm.com [9.184.220.148])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v038RxMw24445178
	for <linux-mm@kvack.org>; Tue, 3 Jan 2017 13:57:59 +0530
Received: from d28av08.in.ibm.com (localhost [127.0.0.1])
	by d28av08.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v038Rxms031071
	for <linux-mm@kvack.org>; Tue, 3 Jan 2017 13:57:59 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC] nodemask: Consider MAX_NUMNODES inside node_isset
Date: Tue,  3 Jan 2017 13:57:53 +0530
Message-Id: <20170103082753.25758-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, akpm@linux-foundation.org

node_isset can give incorrect result if the node number is beyond the
bitmask size (MAX_NUMNODES in this case) which is not checked inside
test_bit. Hence check for the bit limits (MAX_NUMNODES) inside the
node_isset function before calling test_bit.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 include/linux/nodemask.h | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index 6e66cfd..0aee588b 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -139,7 +139,13 @@ static inline void __nodes_clear(nodemask_t *dstp, unsigned int nbits)
 }
 
 /* No static inline type checking - see Subtlety (1) above. */
-#define node_isset(node, nodemask) test_bit((node), (nodemask).bits)
+#define node_isset(node, nodemask) node_test_bit(node, nodemask, MAX_NUMNODES)
+static inline int node_test_bit(int node, nodemask_t nodemask, int maxnodes)
+{
+	if (node >= maxnodes)
+		return 0;
+	return test_bit((node), (nodemask).bits);
+}
 
 #define node_test_and_set(node, nodemask) \
 			__node_test_and_set((node), &(nodemask))
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
