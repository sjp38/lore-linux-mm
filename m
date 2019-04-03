Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D9A5C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CF3920700
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="yb2s85wr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CF3920700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AB456B0271; Wed,  3 Apr 2019 13:37:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1363A6B0272; Wed,  3 Apr 2019 13:37:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F151E6B0274; Wed,  3 Apr 2019 13:37:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id CED4C6B0271
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:37:05 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id w7so13137452ybp.13
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:37:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=LzrGW3pZOFIG85sCwfxmi85ZudWsgckwNMXygdjGg74=;
        b=lgrbR0vyk/wNWYEBTMLpJW/lrMBNJhrcCDQANcWkgFHf/csFnKeg0swvqcQBc2g1ho
         4/Rq+TPxiAsxgiFqDEQd8b5SZ7T1sIRKAor/jeFVuysgEbq4YC2UfxGkpcXnbUtdq5xj
         /KG3spFtayxl5qo+hLLL8CwacF5ZIzHyvoDPSZZuJM9+6QN4zjg9p/Ce2QLgRhTnDALe
         3BAZVQl0Hq7p+cX47d4jqNxYk7N/FCLUTpVhmYqR5qo2euaXZQ8mn1LqbEiHLFVhJNUR
         aqSfVcdpR0qMHDs2tpM2l6wZ8rjzo6I5VslJneBxSjsKjCU4dF16v8OENTHHaJM7kJu9
         hITg==
X-Gm-Message-State: APjAAAW5UfW87K2ubQ0W+SGvQZvCNqC4xOSnoR09zADU+KfXWSBPr8hd
	YKZitWj0OEbA+Uj45bMXxKkbwFcc3r2PRG8M4jX5r0Dvyvz0XSDeDdrPbVbIYcaKYxDwSlGAvFB
	EnkA0jsS2bADMbvkMu/jnZ0cHOx4T7cwlC83FkY6DCSXaUJCXIA2rz72OQPVsaYVezg==
X-Received: by 2002:a25:2d4e:: with SMTP id s14mr1146730ybe.451.1554313025575;
        Wed, 03 Apr 2019 10:37:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybNu4uPmC9krpWR/T2A//H6wjveaLc2tH+jbWDr9wlb5V1vIbdb0jzijXrheF5Wo8GoRPM
X-Received: by 2002:a25:2d4e:: with SMTP id s14mr1146648ybe.451.1554313024666;
        Wed, 03 Apr 2019 10:37:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554313024; cv=none;
        d=google.com; s=arc-20160816;
        b=i+b4zW53UZdePXDhRi3YOp1xjQZHngT0SRu0u+o/rbQnriQxV6IAqThCU/y0FzqfpL
         hBlVrFHyQvE4Em3dGDmcTuytzqHumqApdHavOZysqNuDhH491YEwjOwjBMaVc5Z8bqoi
         F3V2p2bk/RP8aRrsmO5qU4Jj0aWZhWD5uublMwXFYU227403dyxDsOshGaO2TCB0Aeru
         mSCvOB8+GP8J66jYN1TrKzgJeAga4RgJjgw9OiMbyrkPswbfIHvK27g6vvy1aTTqSJ8/
         bPp+PV6evY9IVFMWWGxuzKdMXeCqTVScG5/Un2yQweYnYAlucO0WI9Tt6ur8vzVSwana
         X2SA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=LzrGW3pZOFIG85sCwfxmi85ZudWsgckwNMXygdjGg74=;
        b=Wnm7031+rbJhQV3WPQIoldxYshZo5XuTyoLHbSQ6EiWEzchWTj2Muse7xVFsr6YoRq
         uFG8Ecc+Cl1TGBz0M9Tig8RCuUPdOv16Qqjtz/VhZXsvXM72rsGSbavUqScI2Avph+Oq
         IWOOho/I5oiJU83mMvJpM4zGWzvjFoHGVcZUrJ9bryNNDR/+upKuFSbQCgtQlyHcZYZC
         a4ed8uy6oyF9Q/2Kikp90Yd2eXt0nB/XwvnplKy2oBLh5EHGdk2ejrrVnevrCT8a7lAN
         cC+g1MT5JISt4OMFLVBieJ99aAzfJepKfTlAvXzdX4o90lwuYr7pwdhNG+3M6mAU5bDH
         fJAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=yb2s85wr;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id p67si9738832yba.289.2019.04.03.10.37.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 10:37:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=yb2s85wr;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HO2Zk172124;
	Wed, 3 Apr 2019 17:35:50 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=LzrGW3pZOFIG85sCwfxmi85ZudWsgckwNMXygdjGg74=;
 b=yb2s85wrMl2MIk7Bn095Fz1NdBkZqLuibeAWQyKsKpyvGrfKVWLorsRSq1Thu+qi73my
 d52f5Yber4UKWoAppEwqAc+DiC9qptpIVd///1NlPfNywtq61IOahpH0kNs9G187AbwV
 15mFm/B/N41Zh/mW9fkLqquUQR5mKPr+pTKsbCw5OJAJQ3qtJWA0tPVkoOVUf0vnMf4q
 NppUVHudJlARSoSc9r5j+yJ2fEZRVlkNw/pI5DbvQpIss9Sjwz8F8ZBPkD3wdUDnbhpY
 ue6t7/aaEh7DXxhyjZc1/B8q/VhDjk+1fyRKdORpH/tzk1cV7G4AnakvA9fV6blsiqcJ hA== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2130.oracle.com with ESMTP id 2rhwydaped-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:35:50 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HYDoo081801;
	Wed, 3 Apr 2019 17:35:49 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2rm8f57yqf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:35:49 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x33HZiJm001392;
	Wed, 3 Apr 2019 17:35:44 GMT
Received: from concerto.internal (/10.65.181.37)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 10:35:44 -0700
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        joao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        peterz@infradead.org, aaron.lu@intel.com, akpm@linux-foundation.org,
        alexander.h.duyck@linux.intel.com, amir73il@gmail.com,
        andreyknvl@google.com, aneesh.kumar@linux.ibm.com,
        anthony.yznaga@oracle.com, ard.biesheuvel@linaro.org, arnd@arndb.de,
        arunks@codeaurora.org, ben@decadent.org.uk, bigeasy@linutronix.de,
        bp@alien8.de, brgl@bgdev.pl, catalin.marinas@arm.com, corbet@lwn.net,
        cpandya@codeaurora.org, daniel.vetter@ffwll.ch,
        dan.j.williams@intel.com, gregkh@linuxfoundation.org, guro@fb.com,
        hannes@cmpxchg.org, hpa@zytor.com, iamjoonsoo.kim@lge.com,
        james.morse@arm.com, jannh@google.com, jgross@suse.com,
        jkosina@suse.cz, jmorris@namei.org, joe@perches.com,
        jrdr.linux@gmail.com, jroedel@suse.de, keith.busch@intel.com,
        khalid.aziz@oracle.com, khlebnikov@yandex-team.ru, logang@deltatee.com,
        marco.antonio.780@gmail.com, mark.rutland@arm.com,
        mgorman@techsingularity.net, mhocko@suse.com, mhocko@suse.cz,
        mike.kravetz@oracle.com, mingo@redhat.com, mst@redhat.com,
        m.szyprowski@samsung.com, npiggin@gmail.com, osalvador@suse.de,
        paulmck@linux.vnet.ibm.com, pavel.tatashin@microsoft.com,
        rdunlap@infradead.org, richard.weiyang@gmail.com, riel@surriel.com,
        rientjes@google.com, robin.murphy@arm.com, rostedt@goodmis.org,
        rppt@linux.vnet.ibm.com, sai.praneeth.prakhya@intel.com,
        serge@hallyn.com, steve.capper@arm.com, thymovanbeers@gmail.com,
        vbabka@suse.cz, will.deacon@arm.com, willy@infradead.org,
        yang.shi@linux.alibaba.com, yaojun8558363@gmail.com,
        ying.huang@intel.com, zhangshaokun@hisilicon.com,
        iommu@lists.linux-foundation.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-security-module@vger.kernel.org,
        Khalid Aziz <khalid@gonehiking.org>
Subject: [RFC PATCH v9 06/13] lkdtm: Add test for XPFO
Date: Wed,  3 Apr 2019 11:34:07 -0600
Message-Id: <f2ebf3d199aec62815242ac45ef2fd9300c1a9d5.1554248002.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1554248001.git.khalid.aziz@oracle.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1554248001.git.khalid.aziz@oracle.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904030118
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904030118
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Juerg Haefliger <juerg.haefliger@canonical.com>

This test simply reads from userspace memory via the kernel's linear
map.

v6: * drop an #ifdef, just let the test fail if XPFO is not supported
    * add XPFO_SMP test to try and test the case when one CPU does an xpfo
      unmap of an address, that it can't be used accidentally by other
      CPUs.

Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@tycho.ws>
Tested-by: Marco Benatto <marco.antonio.780@gmail.com>
[jsteckli@amazon.de: rebased from v4.13 to v4.19]
Signed-off-by: Julian Stecklina <jsteckli@amazon.de>
Tested-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
---
 drivers/misc/lkdtm/Makefile |   1 +
 drivers/misc/lkdtm/core.c   |   3 +
 drivers/misc/lkdtm/lkdtm.h  |   5 +
 drivers/misc/lkdtm/xpfo.c   | 196 ++++++++++++++++++++++++++++++++++++
 4 files changed, 205 insertions(+)
 create mode 100644 drivers/misc/lkdtm/xpfo.c

diff --git a/drivers/misc/lkdtm/Makefile b/drivers/misc/lkdtm/Makefile
index 951c984de61a..97c6b7818cce 100644
--- a/drivers/misc/lkdtm/Makefile
+++ b/drivers/misc/lkdtm/Makefile
@@ -9,6 +9,7 @@ lkdtm-$(CONFIG_LKDTM)		+= refcount.o
 lkdtm-$(CONFIG_LKDTM)		+= rodata_objcopy.o
 lkdtm-$(CONFIG_LKDTM)		+= usercopy.o
 lkdtm-$(CONFIG_LKDTM)		+= stackleak.o
+lkdtm-$(CONFIG_LKDTM)		+= xpfo.o
 
 KASAN_SANITIZE_stackleak.o	:= n
 KCOV_INSTRUMENT_rodata.o	:= n
diff --git a/drivers/misc/lkdtm/core.c b/drivers/misc/lkdtm/core.c
index 2837dc77478e..25f4ab4ebf50 100644
--- a/drivers/misc/lkdtm/core.c
+++ b/drivers/misc/lkdtm/core.c
@@ -185,6 +185,9 @@ static const struct crashtype crashtypes[] = {
 	CRASHTYPE(USERCOPY_KERNEL),
 	CRASHTYPE(USERCOPY_KERNEL_DS),
 	CRASHTYPE(STACKLEAK_ERASING),
+	CRASHTYPE(XPFO_READ_USER),
+	CRASHTYPE(XPFO_READ_USER_HUGE),
+	CRASHTYPE(XPFO_SMP),
 };
 
 
diff --git a/drivers/misc/lkdtm/lkdtm.h b/drivers/misc/lkdtm/lkdtm.h
index 3c6fd327e166..6b31ff0c7f8f 100644
--- a/drivers/misc/lkdtm/lkdtm.h
+++ b/drivers/misc/lkdtm/lkdtm.h
@@ -87,4 +87,9 @@ void lkdtm_USERCOPY_KERNEL_DS(void);
 /* lkdtm_stackleak.c */
 void lkdtm_STACKLEAK_ERASING(void);
 
+/* lkdtm_xpfo.c */
+void lkdtm_XPFO_READ_USER(void);
+void lkdtm_XPFO_READ_USER_HUGE(void);
+void lkdtm_XPFO_SMP(void);
+
 #endif
diff --git a/drivers/misc/lkdtm/xpfo.c b/drivers/misc/lkdtm/xpfo.c
new file mode 100644
index 000000000000..8876128f0144
--- /dev/null
+++ b/drivers/misc/lkdtm/xpfo.c
@@ -0,0 +1,196 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * This is for all the tests related to XPFO (eXclusive Page Frame Ownership).
+ */
+
+#include "lkdtm.h"
+
+#include <linux/cpumask.h>
+#include <linux/mman.h>
+#include <linux/uaccess.h>
+#include <linux/xpfo.h>
+#include <linux/kthread.h>
+
+#include <linux/delay.h>
+#include <linux/sched/task.h>
+
+#define XPFO_DATA 0xdeadbeef
+
+static unsigned long do_map(unsigned long flags)
+{
+	unsigned long user_addr, user_data = XPFO_DATA;
+
+	user_addr = vm_mmap(NULL, 0, PAGE_SIZE,
+			    PROT_READ | PROT_WRITE | PROT_EXEC,
+			    flags, 0);
+	if (user_addr >= TASK_SIZE) {
+		pr_warn("Failed to allocate user memory\n");
+		return 0;
+	}
+
+	if (copy_to_user((void __user *)user_addr, &user_data,
+			 sizeof(user_data))) {
+		pr_warn("copy_to_user failed\n");
+		goto free_user;
+	}
+
+	return user_addr;
+
+free_user:
+	vm_munmap(user_addr, PAGE_SIZE);
+	return 0;
+}
+
+static unsigned long *user_to_kernel(unsigned long user_addr)
+{
+	phys_addr_t phys_addr;
+	void *virt_addr;
+
+	phys_addr = user_virt_to_phys(user_addr);
+	if (!phys_addr) {
+		pr_warn("Failed to get physical address of user memory\n");
+		return NULL;
+	}
+
+	virt_addr = phys_to_virt(phys_addr);
+	if (phys_addr != virt_to_phys(virt_addr)) {
+		pr_warn("Physical address of user memory seems incorrect\n");
+		return NULL;
+	}
+
+	return virt_addr;
+}
+
+static void read_map(unsigned long *virt_addr)
+{
+	pr_info("Attempting bad read from kernel address %p\n", virt_addr);
+	if (*(unsigned long *)virt_addr == XPFO_DATA)
+		pr_err("FAIL: Bad read succeeded?!\n");
+	else
+		pr_err("FAIL: Bad read didn't fail but data is incorrect?!\n");
+}
+
+static void read_user_with_flags(unsigned long flags)
+{
+	unsigned long user_addr, *kernel;
+
+	user_addr = do_map(flags);
+	if (!user_addr) {
+		pr_err("FAIL: map failed\n");
+		return;
+	}
+
+	kernel = user_to_kernel(user_addr);
+	if (!kernel) {
+		pr_err("FAIL: user to kernel conversion failed\n");
+		goto free_user;
+	}
+
+	read_map(kernel);
+
+free_user:
+	vm_munmap(user_addr, PAGE_SIZE);
+}
+
+/* Read from userspace via the kernel's linear map. */
+void lkdtm_XPFO_READ_USER(void)
+{
+	read_user_with_flags(MAP_PRIVATE | MAP_ANONYMOUS);
+}
+
+void lkdtm_XPFO_READ_USER_HUGE(void)
+{
+	read_user_with_flags(MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB);
+}
+
+struct smp_arg {
+	unsigned long *virt_addr;
+	unsigned int cpu;
+};
+
+static int smp_reader(void *parg)
+{
+	struct smp_arg *arg = parg;
+	unsigned long *virt_addr;
+
+	if (arg->cpu != smp_processor_id()) {
+		pr_err("FAIL: scheduled on wrong CPU?\n");
+		return 0;
+	}
+
+	virt_addr = smp_cond_load_acquire(&arg->virt_addr, VAL != NULL);
+	read_map(virt_addr);
+
+	return 0;
+}
+
+#ifdef CONFIG_X86
+#define XPFO_SMP_KILLED SIGKILL
+#elif CONFIG_ARM64
+#define XPFO_SMP_KILLED SIGSEGV
+#else
+#error unsupported arch
+#endif
+
+/* The idea here is to read from the kernel's map on a different thread than
+ * did the mapping (and thus the TLB flushing), to make sure that the page
+ * faults on other cores too.
+ */
+void lkdtm_XPFO_SMP(void)
+{
+	unsigned long user_addr, *virt_addr;
+	struct task_struct *thread;
+	int ret;
+	struct smp_arg arg;
+
+	if (num_online_cpus() < 2) {
+		pr_err("not enough to do a multi cpu test\n");
+		return;
+	}
+
+	arg.virt_addr = NULL;
+	arg.cpu = (smp_processor_id() + 1) % num_online_cpus();
+	thread = kthread_create(smp_reader, &arg, "lkdtm_xpfo_test");
+	if (IS_ERR(thread)) {
+		pr_err("couldn't create kthread? %ld\n", PTR_ERR(thread));
+		return;
+	}
+
+	kthread_bind(thread, arg.cpu);
+	get_task_struct(thread);
+	wake_up_process(thread);
+
+	user_addr = do_map(MAP_PRIVATE | MAP_ANONYMOUS);
+	if (!user_addr)
+		goto kill_thread;
+
+	virt_addr = user_to_kernel(user_addr);
+	if (!virt_addr) {
+		/*
+		 * let's store something that will fail, so we can unblock the
+		 * thread
+		 */
+		smp_store_release(&arg.virt_addr, &arg);
+		goto free_user;
+	}
+
+	/* Store to test address to unblock the thread */
+	smp_store_release(&arg.virt_addr, virt_addr);
+
+	/* there must be a better way to do this. */
+	while (1) {
+		if (thread->exit_state)
+			break;
+		msleep_interruptible(100);
+	}
+
+free_user:
+	if (user_addr)
+		vm_munmap(user_addr, PAGE_SIZE);
+
+kill_thread:
+	ret = kthread_stop(thread);
+	if (ret != XPFO_SMP_KILLED)
+		pr_err("FAIL: thread wasn't killed: %d\n", ret);
+	put_task_struct(thread);
+}
-- 
2.17.1

