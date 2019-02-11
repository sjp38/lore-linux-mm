Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A945C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:46:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0A012184E
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:46:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="0ANS8qxu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0A012184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42AE78E017E; Mon, 11 Feb 2019 17:46:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2994A8E0183; Mon, 11 Feb 2019 17:46:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 188198E0181; Mon, 11 Feb 2019 17:46:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF6568E017E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:46:08 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id g19so432436ybe.2
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:46:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TgUKT8mxeCnG73KFILQS5yx+gXU/1gCSnq77DsUA3Jw=;
        b=rD6mqLhgz+XxRP+SuDx7Eu6hUoqM9X7INN0XFz+oFluK94CYS50JbDwQlyCpgMs8kW
         LA4IESYh/1VZyP3KlPE7VT5pwGYE/QWaHJSgAqsGPrLcLo993cyMU5c2RwnVXErcXIQ2
         BOYJDyhIEb7UW2xu1sfxBcRcxv2Ll8K0RBTyJ2AS0fQpVIOSxKW38hM+61Kd/O2J61nt
         HvgU9ZfplQ3/xty1Qst3cP3VmYjYjYS1RlnoaeD7RL4cKeS4Fzc8YgNqFV7qypnwhU32
         l72NrnoFilFtJOUdWdh1+lREC2l/DLtVEaLvjqI1l0y5LdeEgh9fSzuJ7GG54NqCZdbf
         d2yg==
X-Gm-Message-State: AHQUAua5fUS+2TC6STSPAAgT1zU3j2gBT25cz539SWTQB5Wal2GUfFDI
	St/cS+2R8f63n7ELRAcAr6GiZ85ute1R1DH25vrtTfAPosJP1FE9GRlSnc9DTIvXIOFtKBlN3QN
	QQRN4hV+Y8SSAQscKYccNxMar6/2o5CFU0aM5b6b/9CnbGOFL+U6sHMwv51w9XdphAg==
X-Received: by 2002:a81:4c44:: with SMTP id z65mr419603ywa.417.1549925168630;
        Mon, 11 Feb 2019 14:46:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaL8+j/Zb/oRiTdKMY1mtx2rfmkLM+zjMWXuPvLN0i7AkObmQZAMfUv+O7FC4glcyMeBuvP
X-Received: by 2002:a81:4c44:: with SMTP id z65mr419574ywa.417.1549925167865;
        Mon, 11 Feb 2019 14:46:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549925167; cv=none;
        d=google.com; s=arc-20160816;
        b=mP550nyxKChdMLoQe3cTiDOYDpH4YC+sga7ij22oMAewwoQ6donYLBYfIZcIcqxe6A
         kUrSO8e5tNvsvNqWDFYXCn5bupP1qdqePS4ywJqGlKZZ8mmaTof726Umo0QooYMwe4Go
         Mg/AUNTMLlre99CtHs+T0RBgrzIztLcjNS2kYgc6ttxWZxgac2nttKHDeFmwbGiIFL4K
         ei+1eSURoZFE9cRaYSlydZWrPewk275kHDLn0aHYLrbivtrkl58sRIlO6GAyUyrynWxU
         VdCgAXp19EKAMnwhmAuNX5VVIE03eWNDDeaAPhZB8p1JfGPFUmwZ6Vxm2U+qWKqUjvsh
         ChWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=TgUKT8mxeCnG73KFILQS5yx+gXU/1gCSnq77DsUA3Jw=;
        b=c4otTBO1baSv++vp7ezFr+X6aaHEVZ1nDW48duimu0cptBTkGB5xjPiE/GD1eDfd5u
         zFGte7ByIfvByjP2K3NT13E6gvd/pQ7cnF49HjSZPFipYH3kR2LYK0nJKEQUk5ExKTON
         sXpMjJUY2om2dP8vZ0+pREL7W9vOUcBSG9q30adPZCzZGDOi093fdYhNlTCLPdkNpJJH
         u9vYevVYtSWju6ZK2HLOnnprPNloPFdo9R8AvpnwbNDTy0JSxvWpcr5SbVestuC2fwK7
         JkVM/cgz9wHhxJvzRH4UaNbMjDUJJdu90n7THH/Fzi9DaYHO/7sOHU1IIyi8KeZoVLap
         e4Lg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=0ANS8qxu;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id w18si6409371ybk.392.2019.02.11.14.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 14:46:07 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=0ANS8qxu;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1BMhX6S072792;
	Mon, 11 Feb 2019 22:44:57 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=TgUKT8mxeCnG73KFILQS5yx+gXU/1gCSnq77DsUA3Jw=;
 b=0ANS8qxu8TUrSovIxqwwoe9wU2/vLFPDYfYCtTSQUkAD9qLOpgMzZevM/x0UcMlhK49Z
 7aIjfLZEMOusmCpnPd7YQ31hCy9VcXSDJiZZskRnJmzG7fIiL7CrWmf0TPps/G8H56L6
 pKN8SS+SgWvazK/god5fAnt2HFhSt6tp281BNStRPuBg8jPGY3z0TjRy+iinS9R5eVEA
 5JtKnNRRE89P2LS14sT7f/TuTPjdcNU2+zW0EmPcFQRmAOptWifW9G9c17HgjQ1ebW5l
 sRJbXxCq2H0Ra5R5NNQ4XeDzlr3cdF3L+POvvYoQLjhrrMX9gPW7g3olX5OMeoWlyTis Vg== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2130.oracle.com with ESMTP id 2qhrek8q85-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 22:44:56 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1BMipfj030923
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 22:44:51 GMT
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1BMio0A006609;
	Mon, 11 Feb 2019 22:44:50 GMT
Received: from localhost.localdomain (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 11 Feb 2019 14:44:50 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: jgg@ziepe.ca
Cc: akpm@linux-foundation.org, dave@stgolabs.net, jack@suse.cz, cl@linux.com,
        linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
        paulus@ozlabs.org, benh@kernel.crashing.org, mpe@ellerman.id.au,
        hao.wu@intel.com, atull@kernel.org, mdf@kernel.org, aik@ozlabs.ru,
        daniel.m.jordan@oracle.com
Subject: [PATCH 3/5] fpga/dlf/afu: use pinned_vm instead of locked_vm to account pinned pages
Date: Mon, 11 Feb 2019 17:44:35 -0500
Message-Id: <20190211224437.25267-4-daniel.m.jordan@oracle.com>
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
pages"), locked and pinned pages are accounted separately.  The FPGA AFU
driver accounts pinned pages to locked_vm; use pinned_vm instead.

pinned_vm recently became atomic and so no longer relies on mmap_sem
held as writer: delete.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 drivers/fpga/dfl-afu-dma-region.c | 50 ++++++++++++++-----------------
 1 file changed, 23 insertions(+), 27 deletions(-)

diff --git a/drivers/fpga/dfl-afu-dma-region.c b/drivers/fpga/dfl-afu-dma-region.c
index e18a786fc943..a9a6b317fe2e 100644
--- a/drivers/fpga/dfl-afu-dma-region.c
+++ b/drivers/fpga/dfl-afu-dma-region.c
@@ -32,47 +32,43 @@ void afu_dma_region_init(struct dfl_feature_platform_data *pdata)
 }
 
 /**
- * afu_dma_adjust_locked_vm - adjust locked memory
+ * afu_dma_adjust_pinned_vm - adjust pinned memory
  * @dev: port device
  * @npages: number of pages
- * @incr: increase or decrease locked memory
  *
- * Increase or decrease the locked memory size with npages input.
+ * Increase or decrease the pinned memory size with npages input.
  *
  * Return 0 on success.
- * Return -ENOMEM if locked memory size is over the limit and no CAP_IPC_LOCK.
+ * Return -ENOMEM if pinned memory size is over the limit and no CAP_IPC_LOCK.
  */
-static int afu_dma_adjust_locked_vm(struct device *dev, long npages, bool incr)
+static int afu_dma_adjust_pinned_vm(struct device *dev, long pages)
 {
-	unsigned long locked, lock_limit;
+	unsigned long lock_limit;
+	s64 pinned_vm;
 	int ret = 0;
 
 	/* the task is exiting. */
-	if (!current->mm)
+	if (!current->mm || !pages)
 		return 0;
 
-	down_write(&current->mm->mmap_sem);
-
-	if (incr) {
-		locked = current->mm->locked_vm + npages;
+	if (pages > 0) {
 		lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
-
-		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
+		pinned_vm = atomic64_add_return(pages, &current->mm->pinned_vm);
+		if (pinned_vm > lock_limit && !capable(CAP_IPC_LOCK)) {
 			ret = -ENOMEM;
-		else
-			current->mm->locked_vm += npages;
+			atomic64_sub(pages, &current->mm->pinned_vm);
+		}
 	} else {
-		if (WARN_ON_ONCE(npages > current->mm->locked_vm))
-			npages = current->mm->locked_vm;
-		current->mm->locked_vm -= npages;
+		pinned_vm = atomic64_read(&current->mm->pinned_vm);
+		if (WARN_ON_ONCE(pages > pinned_vm))
+			pages = pinned_vm;
+		atomic64_sub(pages, &current->mm->pinned_vm);
 	}
 
-	dev_dbg(dev, "[%d] RLIMIT_MEMLOCK %c%ld %ld/%ld%s\n", current->pid,
-		incr ? '+' : '-', npages << PAGE_SHIFT,
-		current->mm->locked_vm << PAGE_SHIFT, rlimit(RLIMIT_MEMLOCK),
-		ret ? "- exceeded" : "");
-
-	up_write(&current->mm->mmap_sem);
+	dev_dbg(dev, "[%d] RLIMIT_MEMLOCK %c%ld %lld/%lu%s\n", current->pid,
+		(pages > 0) ? '+' : '-', pages << PAGE_SHIFT,
+		(s64)atomic64_read(&current->mm->pinned_vm) << PAGE_SHIFT,
+		rlimit(RLIMIT_MEMLOCK), ret ? "- exceeded" : "");
 
 	return ret;
 }
@@ -92,7 +88,7 @@ static int afu_dma_pin_pages(struct dfl_feature_platform_data *pdata,
 	struct device *dev = &pdata->dev->dev;
 	int ret, pinned;
 
-	ret = afu_dma_adjust_locked_vm(dev, npages, true);
+	ret = afu_dma_adjust_pinned_vm(dev, npages);
 	if (ret)
 		return ret;
 
@@ -121,7 +117,7 @@ static int afu_dma_pin_pages(struct dfl_feature_platform_data *pdata,
 free_pages:
 	kfree(region->pages);
 unlock_vm:
-	afu_dma_adjust_locked_vm(dev, npages, false);
+	afu_dma_adjust_pinned_vm(dev, -npages);
 	return ret;
 }
 
@@ -141,7 +137,7 @@ static void afu_dma_unpin_pages(struct dfl_feature_platform_data *pdata,
 
 	put_all_pages(region->pages, npages);
 	kfree(region->pages);
-	afu_dma_adjust_locked_vm(dev, npages, false);
+	afu_dma_adjust_pinned_vm(dev, -npages);
 
 	dev_dbg(dev, "%ld pages unpinned\n", npages);
 }
-- 
2.20.1

