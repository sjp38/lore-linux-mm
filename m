Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7626B0070
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 03:58:23 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id w62so13341214wes.11
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 00:58:22 -0800 (PST)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id f19si31022692wiw.1.2015.01.15.00.58.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 00:58:16 -0800 (PST)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 15 Jan 2015 08:58:16 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 483EE17D8062
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 08:58:53 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t0F8wEUi60620984
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 08:58:14 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t0F8wEDV012563
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 01:58:14 -0700
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH 8/8] kernel: Fix sparse warning for ACCESS_ONCE
Date: Thu, 15 Jan 2015 09:58:34 +0100
Message-Id: <1421312314-72330-9-git-send-email-borntraeger@de.ibm.com>
In-Reply-To: <1421312314-72330-1-git-send-email-borntraeger@de.ibm.com>
References: <1421312314-72330-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, Christian Borntraeger <borntraeger@de.ibm.com>

Commit a91ed664749c ("kernel: tighten rules for ACCESS ONCE") results in
sparse warnings like "Using plain integer as NULL pointer" - Let's add a
type cast to the dummy assignment.
To avoid warnings lik "sparse: warning: cast to restricted __hc32" we also
use __force on that cast.

Fixes: a91ed664749c ("kernel: tighten rules for ACCESS ONCE")
Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
---
 include/linux/compiler.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/compiler.h b/include/linux/compiler.h
index 5e186bf..7bebf05 100644
--- a/include/linux/compiler.h
+++ b/include/linux/compiler.h
@@ -461,7 +461,7 @@ static __always_inline void __assign_once_size(volatile void *p, void *res, int
  * If possible use READ_ONCE/ASSIGN_ONCE instead.
  */
 #define __ACCESS_ONCE(x) ({ \
-	 __maybe_unused typeof(x) __var = 0; \
+	 __maybe_unused typeof(x) __var = (__force typeof(x)) 0; \
 	(volatile typeof(x) *)&(x); })
 #define ACCESS_ONCE(x) (*__ACCESS_ONCE(x))
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
