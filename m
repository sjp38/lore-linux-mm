Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id CCD816B0038
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 09:31:02 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so15875512pab.4
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 06:31:02 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id i9si5861526pdn.129.2014.12.17.06.31.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 17 Dec 2014 06:31:01 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NGQ00806DUG6240@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 17 Dec 2014 14:35:04 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH 1/2] hugetlb, sysctl: pass '.extra1 = NULL' rather then
 '.extra1 = &zero'
Date: Wed, 17 Dec 2014 17:30:49 +0300
Message-id: <1418826650-10145-1-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <548CA6B6.3060901@colorfullife.com>
References: <548CA6B6.3060901@colorfullife.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Manfred Spraul <manfred@colorfullife.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Luiz Capitulino <lcapitulino@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "nadia.derbey@bull.net" <Nadia.Derbey@bull.net>, aquini@redhat.com, Joe Perches <joe@perches.com>, avagin@openvz.org, LKML <linux-kernel@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <andreyknvl@google.com>, Konstantin Khlebnikov <koct9i@gmail.com>, kasan-dev <kasan-dev@googlegroups.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org

Commit ed4d4902ebdd ("mm, hugetlb: remove hugetlb_zero and hugetlb_infinity") replaced
'unsigned long hugetlb_zero' with 'int zero' leading to out-of-bounds access
in proc_doulongvec_minmax().
Use '.extra1 = NULL' instead of '.extra1 = &zero'. Passing NULL is equivalent to
passing minimal value, which is 0 for unsigned types.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Suggested-by: Manfred Spraul <manfred@colorfullife.com>
Fixes: ed4d4902ebdd ("mm, hugetlb: remove hugetlb_zero and hugetlb_infinity")
Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 kernel/sysctl.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 137c7f6..88ea2d6 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1248,7 +1248,6 @@ static struct ctl_table vm_table[] = {
 		.maxlen		= sizeof(unsigned long),
 		.mode		= 0644,
 		.proc_handler	= hugetlb_sysctl_handler,
-		.extra1		= &zero,
 	},
 #ifdef CONFIG_NUMA
 	{
@@ -1257,7 +1256,6 @@ static struct ctl_table vm_table[] = {
 		.maxlen         = sizeof(unsigned long),
 		.mode           = 0644,
 		.proc_handler   = &hugetlb_mempolicy_sysctl_handler,
-		.extra1		= &zero,
 	},
 #endif
 	 {
@@ -1280,7 +1278,6 @@ static struct ctl_table vm_table[] = {
 		.maxlen		= sizeof(unsigned long),
 		.mode		= 0644,
 		.proc_handler	= hugetlb_overcommit_handler,
-		.extra1		= &zero,
 	},
 #endif
 	{
-- 
2.2.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
