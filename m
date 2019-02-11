Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE15AC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:45:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 898002184E
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:45:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="MlSZBhMC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 898002184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24D188E017D; Mon, 11 Feb 2019 17:45:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FB598E0163; Mon, 11 Feb 2019 17:45:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 113198E017D; Mon, 11 Feb 2019 17:45:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC9AF8E0163
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:45:49 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id m1so992579ita.9
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:45:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5o86+WlRzT0Hhn4QJL5kLu5bSJTU1vffRIZ0ttnB1EA=;
        b=iE67Hm2J0AqKoV1Jzpce6WhFcJBIuq0SN7YgW8yyGcP0yKtktKnK7Jtcfdlzj8KZB/
         9pzyf0DxYhU/gNAn52N82XerccNUlTyCJkIeYnlAo/3xQwULb4/bNW6RL/Th8hAJe/yQ
         8Uaxlt/6bIf1bYNng/32gdk9Zdipbpy9jzoo8sTt1Co4+uY0uRRPTV9kW2Xe+YWwtqaf
         GEx2vK3ohF0qovS4c1HxPoP4JWNfUseVMy+OulZ/HfSW+mxWO4+wpqXPMWrUsu7ljwVR
         /zNFwMq4K7QEde2Yof0tbIXQ33aNLnLknXm3FuydIen0Xrn44PvI1LbcO1neYLKx0Iv6
         p7PQ==
X-Gm-Message-State: AHQUAuZo5q96xB27ECVN+0ymjutfS7vHW4/cbtcNO4AayiM51Qc0Pj4k
	W/HAn8jDW4cbRiRmbMzXg5VCte5WNIcGWv/zz4oVFlIRZIGLeiV9H7G9uB+L+YNIfKznMgxb9+e
	UkSpHNbnaSaC7dbLmj3tWfasD3Kl5dwoH2n3sRRf9WhjFY+byj+ibs1RlixL8gRcctQ==
X-Received: by 2002:a24:7b90:: with SMTP id q138mr279640itc.37.1549925149595;
        Mon, 11 Feb 2019 14:45:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZY+4A6G7FxZebnI+YxB8HOTGEy/yuwDz66l4xNhQi4BfwqbLxv6aqLdWv8lvo0PHXoXIY/
X-Received: by 2002:a24:7b90:: with SMTP id q138mr279617itc.37.1549925148466;
        Mon, 11 Feb 2019 14:45:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549925148; cv=none;
        d=google.com; s=arc-20160816;
        b=TSBlDtp9eoRf12uGhWZd2O6jZaBU1/OqnC0/c+pvxdIlD6FmTkVGng8gEzsm+5AuCz
         X91/VoaG5LBHAnnfeIrZ1lO6NkNjtiIvpQ6S5hWUxL7M34ltGZ1RPUd8OZDSGMuQmKsx
         j2no6GOHjdAkGLtT/yQKmryhhNb7cjwgLWTaAs8UG2nKbJt/3zGC40w3vrW+YFMr0btG
         gyNqQzLkEtehFscsd3hs73JEiZ9HZVgraFegqAJWMZXHY1QrLEynRyfNeickdjXdeoGs
         yX/OwjLMioi2/nJi+EqhjQ1lus7GL0x3dGhrV7YEmEvdXR8lOJJlxt0W6uXu8bq4o6Ws
         BN6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=5o86+WlRzT0Hhn4QJL5kLu5bSJTU1vffRIZ0ttnB1EA=;
        b=PTbmb/ZS4f/iLI3YBKhk7Iamw050IeYbxrAc8S1JFT77K+1YEvHluGISUz/B3pQYFP
         yzP01UmFfS/wwYscc1qKKfgs39vvVFn2OfXGtR5f/f40XyRRr2T3dGoEtkcR+oJRE5Fj
         qtChRTyMPjcKjJQVGpcYtwnkZq6x101k5mfzpCL82UsHX01SrXcJY5ILVC1WBBxwngGG
         rikKZMFNVgngjE3ZEKhezSY5KJpQAT1aCopW35SiEguJFDx4w6WFFAnuanIgobPjXYKM
         3YvyrB05Z8Blx+C47RdE1Qgo3dFz7be6s6yQThklBrM1+ZqDSdZg6jAGMDUm6GcTpKt9
         oeqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=MlSZBhMC;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id r12si364554ith.90.2019.02.11.14.45.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 14:45:48 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=MlSZBhMC;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1BMhfbR080591;
	Mon, 11 Feb 2019 22:44:50 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=5o86+WlRzT0Hhn4QJL5kLu5bSJTU1vffRIZ0ttnB1EA=;
 b=MlSZBhMCsIFCTUo0EIPL0tPnswkHaSGhLsLeLDsJtU0vCNa46hIRRwnWmZSJMf688QxF
 YfShCZB8rrfpNQU2rjW9bZ6NE1kq9Zeczsj2tyi+FNtwLEbk799j8ZAiasLuzHoOfl0W
 Xo3MyqoH9tyXpg/1cG6wwMG/TLaUZDVevzLwdHfp/LuFIbDLtYidG+ReUKsulAaalIVf
 YqH2t7Wtxgv/iFnMIPqorbKWsfOUBzIF/Uou4/FQJ3509CoaV/FXjsZN3CaF8wE/LKVE
 qDr9sCOeKQBYER0qMM6Cvq63erEgMnEp1448hqV7AaO20jWtZMt40cDFVkI46fDjJFjR vA== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2qhre58p9n-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 22:44:50 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1BMin5P030881
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 22:44:49 GMT
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1BMimLO006595;
	Mon, 11 Feb 2019 22:44:48 GMT
Received: from localhost.localdomain (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 11 Feb 2019 14:44:47 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: jgg@ziepe.ca
Cc: akpm@linux-foundation.org, dave@stgolabs.net, jack@suse.cz, cl@linux.com,
        linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
        paulus@ozlabs.org, benh@kernel.crashing.org, mpe@ellerman.id.au,
        hao.wu@intel.com, atull@kernel.org, mdf@kernel.org, aik@ozlabs.ru,
        daniel.m.jordan@oracle.com
Subject: [PATCH 2/5] vfio/spapr_tce: use pinned_vm instead of locked_vm to account pinned pages
Date: Mon, 11 Feb 2019 17:44:34 -0500
Message-Id: <20190211224437.25267-3-daniel.m.jordan@oracle.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9164 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Beginning with bc3e53f682d9 ("mm: distinguish between mlocked and pinned
pages"), locked and pinned pages are accounted separately.  The SPAPR
TCE VFIO IOMMU driver accounts pinned pages to locked_vm; use pinned_vm
instead.

pinned_vm recently became atomic and so no longer relies on mmap_sem
held as writer: delete.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 Documentation/vfio.txt              |  6 +--
 drivers/vfio/vfio_iommu_spapr_tce.c | 64 ++++++++++++++---------------
 2 files changed, 33 insertions(+), 37 deletions(-)

diff --git a/Documentation/vfio.txt b/Documentation/vfio.txt
index f1a4d3c3ba0b..fa37d65363f9 100644
--- a/Documentation/vfio.txt
+++ b/Documentation/vfio.txt
@@ -308,7 +308,7 @@ This implementation has some specifics:
    currently there is no way to reduce the number of calls. In order to make
    things faster, the map/unmap handling has been implemented in real mode
    which provides an excellent performance which has limitations such as
-   inability to do locked pages accounting in real time.
+   inability to do pinned pages accounting in real time.
 
 4) According to sPAPR specification, A Partitionable Endpoint (PE) is an I/O
    subtree that can be treated as a unit for the purposes of partitioning and
@@ -324,7 +324,7 @@ This implementation has some specifics:
 		returns the size and the start of the DMA window on the PCI bus.
 
 	VFIO_IOMMU_ENABLE
-		enables the container. The locked pages accounting
+		enables the container. The pinned pages accounting
 		is done at this point. This lets user first to know what
 		the DMA window is and adjust rlimit before doing any real job.
 
@@ -454,7 +454,7 @@ This implementation has some specifics:
 
    PPC64 paravirtualized guests generate a lot of map/unmap requests,
    and the handling of those includes pinning/unpinning pages and updating
-   mm::locked_vm counter to make sure we do not exceed the rlimit.
+   mm::pinned_vm counter to make sure we do not exceed the rlimit.
    The v2 IOMMU splits accounting and pinning into separate operations:
 
    - VFIO_IOMMU_SPAPR_REGISTER_MEMORY/VFIO_IOMMU_SPAPR_UNREGISTER_MEMORY ioctls
diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
index c424913324e3..f47e020dc5e4 100644
--- a/drivers/vfio/vfio_iommu_spapr_tce.c
+++ b/drivers/vfio/vfio_iommu_spapr_tce.c
@@ -34,9 +34,11 @@
 static void tce_iommu_detach_group(void *iommu_data,
 		struct iommu_group *iommu_group);
 
-static long try_increment_locked_vm(struct mm_struct *mm, long npages)
+static long try_increment_pinned_vm(struct mm_struct *mm, long npages)
 {
-	long ret = 0, locked, lock_limit;
+	long ret = 0;
+	s64 pinned;
+	unsigned long lock_limit;
 
 	if (WARN_ON_ONCE(!mm))
 		return -EPERM;
@@ -44,39 +46,33 @@ static long try_increment_locked_vm(struct mm_struct *mm, long npages)
 	if (!npages)
 		return 0;
 
-	down_write(&mm->mmap_sem);
-	locked = mm->locked_vm + npages;
+	pinned = atomic64_add_return(npages, &mm->pinned_vm);
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
-	if (locked > lock_limit && !capable(CAP_IPC_LOCK))
+	if (pinned > lock_limit && !capable(CAP_IPC_LOCK)) {
 		ret = -ENOMEM;
-	else
-		mm->locked_vm += npages;
+		atomic64_sub(npages, &mm->pinned_vm);
+	}
 
-	pr_debug("[%d] RLIMIT_MEMLOCK +%ld %ld/%ld%s\n", current->pid,
+	pr_debug("[%d] RLIMIT_MEMLOCK +%ld %ld/%lu%s\n", current->pid,
 			npages << PAGE_SHIFT,
-			mm->locked_vm << PAGE_SHIFT,
-			rlimit(RLIMIT_MEMLOCK),
-			ret ? " - exceeded" : "");
-
-	up_write(&mm->mmap_sem);
+			atomic64_read(&mm->pinned_vm) << PAGE_SHIFT,
+			rlimit(RLIMIT_MEMLOCK), ret ? " - exceeded" : "");
 
 	return ret;
 }
 
-static void decrement_locked_vm(struct mm_struct *mm, long npages)
+static void decrement_pinned_vm(struct mm_struct *mm, long npages)
 {
 	if (!mm || !npages)
 		return;
 
-	down_write(&mm->mmap_sem);
-	if (WARN_ON_ONCE(npages > mm->locked_vm))
-		npages = mm->locked_vm;
-	mm->locked_vm -= npages;
-	pr_debug("[%d] RLIMIT_MEMLOCK -%ld %ld/%ld\n", current->pid,
+	if (WARN_ON_ONCE(npages > atomic64_read(&mm->pinned_vm)))
+		npages = atomic64_read(&mm->pinned_vm);
+	atomic64_sub(npages, &mm->pinned_vm);
+	pr_debug("[%d] RLIMIT_MEMLOCK -%ld %ld/%lu\n", current->pid,
 			npages << PAGE_SHIFT,
-			mm->locked_vm << PAGE_SHIFT,
+			atomic64_read(&mm->pinned_vm) << PAGE_SHIFT,
 			rlimit(RLIMIT_MEMLOCK));
-	up_write(&mm->mmap_sem);
 }
 
 /*
@@ -110,7 +106,7 @@ struct tce_container {
 	bool enabled;
 	bool v2;
 	bool def_window_pending;
-	unsigned long locked_pages;
+	unsigned long pinned_pages;
 	struct mm_struct *mm;
 	struct iommu_table *tables[IOMMU_TABLE_GROUP_MAX_TABLES];
 	struct list_head group_list;
@@ -283,7 +279,7 @@ static int tce_iommu_find_free_table(struct tce_container *container)
 static int tce_iommu_enable(struct tce_container *container)
 {
 	int ret = 0;
-	unsigned long locked;
+	unsigned long pinned;
 	struct iommu_table_group *table_group;
 	struct tce_iommu_group *tcegrp;
 
@@ -292,15 +288,15 @@ static int tce_iommu_enable(struct tce_container *container)
 
 	/*
 	 * When userspace pages are mapped into the IOMMU, they are effectively
-	 * locked memory, so, theoretically, we need to update the accounting
-	 * of locked pages on each map and unmap.  For powerpc, the map unmap
+	 * pinned memory, so, theoretically, we need to update the accounting
+	 * of pinned pages on each map and unmap.  For powerpc, the map unmap
 	 * paths can be very hot, though, and the accounting would kill
 	 * performance, especially since it would be difficult to impossible
 	 * to handle the accounting in real mode only.
 	 *
 	 * To address that, rather than precisely accounting every page, we
-	 * instead account for a worst case on locked memory when the iommu is
-	 * enabled and disabled.  The worst case upper bound on locked memory
+	 * instead account for a worst case on pinned memory when the iommu is
+	 * enabled and disabled.  The worst case upper bound on pinned memory
 	 * is the size of the whole iommu window, which is usually relatively
 	 * small (compared to total memory sizes) on POWER hardware.
 	 *
@@ -317,7 +313,7 @@ static int tce_iommu_enable(struct tce_container *container)
 	 *
 	 * So we do not allow enabling a container without a group attached
 	 * as there is no way to know how much we should increment
-	 * the locked_vm counter.
+	 * the pinned_vm counter.
 	 */
 	if (!tce_groups_attached(container))
 		return -ENODEV;
@@ -335,12 +331,12 @@ static int tce_iommu_enable(struct tce_container *container)
 	if (ret)
 		return ret;
 
-	locked = table_group->tce32_size >> PAGE_SHIFT;
-	ret = try_increment_locked_vm(container->mm, locked);
+	pinned = table_group->tce32_size >> PAGE_SHIFT;
+	ret = try_increment_pinned_vm(container->mm, pinned);
 	if (ret)
 		return ret;
 
-	container->locked_pages = locked;
+	container->pinned_pages = pinned;
 
 	container->enabled = true;
 
@@ -355,7 +351,7 @@ static void tce_iommu_disable(struct tce_container *container)
 	container->enabled = false;
 
 	BUG_ON(!container->mm);
-	decrement_locked_vm(container->mm, container->locked_pages);
+	decrement_pinned_vm(container->mm, container->pinned_pages);
 }
 
 static void *tce_iommu_open(unsigned long arg)
@@ -658,7 +654,7 @@ static long tce_iommu_create_table(struct tce_container *container,
 	if (!table_size)
 		return -EINVAL;
 
-	ret = try_increment_locked_vm(container->mm, table_size >> PAGE_SHIFT);
+	ret = try_increment_pinned_vm(container->mm, table_size >> PAGE_SHIFT);
 	if (ret)
 		return ret;
 
@@ -677,7 +673,7 @@ static void tce_iommu_free_table(struct tce_container *container,
 	unsigned long pages = tbl->it_allocated_size >> PAGE_SHIFT;
 
 	iommu_tce_table_put(tbl);
-	decrement_locked_vm(container->mm, pages);
+	decrement_pinned_vm(container->mm, pages);
 }
 
 static long tce_iommu_create_window(struct tce_container *container,
-- 
2.20.1

