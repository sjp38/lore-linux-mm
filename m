Return-Path: <SRS0=dvGr=TS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5128FC04AAF
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 08:46:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4F0D2166E
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 08:46:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4F0D2166E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52CAE6B0005; Sat, 18 May 2019 04:46:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DDA06B0006; Sat, 18 May 2019 04:46:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F3A76B0007; Sat, 18 May 2019 04:46:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 167466B0005
	for <linux-mm@kvack.org>; Sat, 18 May 2019 04:46:23 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id x23so4546594otp.5
        for <linux-mm@kvack.org>; Sat, 18 May 2019 01:46:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=DO6WLkoUqXxxlGmLPR+WFpvuFJaMgzTrrjSYWEqE6Ok=;
        b=i7uRI5K8dCgBVvvRWS9at8H8mSNHWcTB4ENvdkcF6nOZOrapZKOeSZ472K88io9G2+
         GvdFvufXkz8rll7wuLmNcE4x03pw83V1kuQ4B9ufkSWw3WiMssksDFWSvp3KvrDZgZZb
         Dh+Yco3RQ2uR+QIJcmeUVlzGKUzC/MzpU/udo0/JUjuRlcg9QRyIBXH4+6Bi/4CRxtxJ
         goQ9l/RhuZ09zip0obKoj68ay1Vc+OC9pZz/M8nUXHyv0dvIfUHrY4vCbMirXKZllgKy
         XMv5CzlEVw/ZpSvL07oqcZ79NTXVJj5N6bDEkreB2J/w2WPWMaVPxlSNKtaDiE9ex8q6
         y0VQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenjianhong2@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenjianhong2@huawei.com
X-Gm-Message-State: APjAAAWNzPeeP70HulRVl7n7VxpuiIzuhQxSOcRErftT+GlWMtw9WGB2
	70TZRp2hGvWMfchZ/vY39miPa9ZuJZQfTdUnlRXJZOHfkh/EtMMR0XbmlMABO8he9mhpzclMCv5
	YGfburCjB5qpvssw9iPviMP0mgbTxcKpw5tAXwRtfIp6Pb9jWrGDSHhk0z4ctLiYCzw==
X-Received: by 2002:a05:6830:210e:: with SMTP id i14mr68833otc.326.1558169182728;
        Sat, 18 May 2019 01:46:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrRWHLdLRv4A1IXbllk6ZT+i3XcKvVc0z+/uLb+pgUakeFLSusYIBGraqiM5geu13Xue5d
X-Received: by 2002:a05:6830:210e:: with SMTP id i14mr68807otc.326.1558169181561;
        Sat, 18 May 2019 01:46:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558169181; cv=none;
        d=google.com; s=arc-20160816;
        b=IUbj6rpIe6VfHRjOsnTA22OjQA0xr4oBtAI3nLw4viZA+mQRmnLqfHwf6IzfrbSI1c
         TueHxgSdxgDTVC8S+s20Wq8B7UB3Mt7Ge0qbeBWINxvG2yAf5ve7uoxqdsc3ScdN84hY
         177WDLtVknFfSElFZ4R9k++grdfdoSm1WNz/ISVTYfdetzWy5Q3sQZmS0Dr4YjNFlrdD
         SWrYnzmqvZHT+JjhyRfS9Y6Q/10IzLwJpseRfdjoRPTrRInfBTB0JvH7ewMkSxIQrGsm
         i0WMLEronO9Gfv+8IA36ZGB4spBhstRGv04YSsliG86RTndVPQA2JYsxh5amjM5tAuyK
         k37Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=DO6WLkoUqXxxlGmLPR+WFpvuFJaMgzTrrjSYWEqE6Ok=;
        b=0zDJ2SNH2ig9LVMr+jkns79SMfQLmTbQESi1649A9vfeV3Iix1EXV5EqBI41CnoftC
         QajaHRycCjEUIsgteiNjS21ktcDkNxc8yuEoG56BydVJvHtAcDKI2aoNEqJaGyyUml07
         elmKuZqKsLnbsFU9Pvgf8zK98bMnaFevw3BdGezsJjeC9k8mLo+MgYwgqQelX5u1vbDJ
         x7wuIwMeKbwXFKYbQ8co6TzTIjk13W+yfmwdj8SLCLJP+Y1EIzkagqLbFQZh5sweSE3b
         1otbfQ85aFTOmcEd9xVql5DZ8UGlIgwxAs2epZH8cHD5vc/btCBwWlKFKA3GXZmdGoqM
         2rqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenjianhong2@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenjianhong2@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id o12si5569295otl.289.2019.05.18.01.46.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 18 May 2019 01:46:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenjianhong2@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenjianhong2@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenjianhong2@huawei.com
Received: from DGGEMS405-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 636DA98F3BD9CDE92B79;
	Sat, 18 May 2019 16:46:14 +0800 (CST)
Received: from use12-sp2.huawei.com (10.67.188.162) by
 DGGEMS405-HUB.china.huawei.com (10.3.19.205) with Microsoft SMTP Server id
 14.3.439.0; Sat, 18 May 2019 16:46:04 +0800
From: jianhong chen <chenjianhong2@huawei.com>
To: <gregkh@linuxfoundation.org>, <akpm@linux-foundation.org>,
	<mhocko@suse.com>, <vbabka@suse.cz>, <kirill.shutemov@linux.intel.com>,
	<yang.shi@linux.alibaba.com>, <jannh@google.com>, <steve.capper@arm.com>,
	<tiny.windzz@gmail.com>, <walken@google.com>, <willy@infradead.org>
CC: <chenjianhong2@huawei.com>, <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <stable@vger.kernel.org>, <hughd@google.com>,
	<linux@arm.linux.org.uk>, <ralf@linux-mips.org>, <lethal@linux-sh.org>,
	<davem@davemloft.net>, <cmetcalf@tilera.com>, <mingo@elte.hu>,
	<tglx@linutronix.de>, <hpa@zytor.com>
Subject: [PATCH] mm/mmap: fix the adjusted length error
Date: Sat, 18 May 2019 16:50:33 +0800
Message-ID: <1558169433-121358-1-git-send-email-chenjianhong2@huawei.com>
X-Mailer: git-send-email 1.8.5.6
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
X-Originating-IP: [10.67.188.162]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In linux version 4.4, a 32-bit process may fail to allocate 64M hugepage
memory by function shmat even though there is a 64M memory gap in
the process.

It is the adjusted length that causes the problem, introduced from
commit db4fbfb9523c935 ("mm: vm_unmapped_area() lookup function").
Accounting for the worst case alignment overhead, function unmapped_area
and unmapped_area_topdown adjust the search length before searching
for available vma gap. This is an estimated length, sum of the desired
length and the longest alignment offset, which can cause misjudgement
if the system has very few virtual memory left. For example, if the
longest memory gap available is 64M, we can’t get it from the system
by allocating 64M hugepage memory via shmat function. The reason is
that it requires a longger length, the sum of the desired length(64M)
and the longest alignment offset.

To fix this error ,we can calculate the alignment offset of
gap_start or gap_end to get a desired gap_start or gap_end value,
before searching for the available gap. In this way, we don't
need to adjust the search length.

Problem reproduces procedure:
1. allocate a lot of virtual memory segments via shmat and malloc
2. release one of the biggest memory segment via shmdt
3. attach the biggest memory segment via shmat

e.g.
process maps:
00008000-00009000 r-xp 00000000 00:12 3385    /tmp/memory_mmap
00011000-00012000 rw-p 00001000 00:12 3385    /tmp/memory_mmap
27536000-f756a000 rw-p 00000000 00:00 0
f756a000-f7691000 r-xp 00000000 01:00 560     /lib/libc-2.11.1.so
f7691000-f7699000 ---p 00127000 01:00 560     /lib/libc-2.11.1.so
f7699000-f769b000 r--p 00127000 01:00 560     /lib/libc-2.11.1.so
f769b000-f769c000 rw-p 00129000 01:00 560     /lib/libc-2.11.1.so
f769c000-f769f000 rw-p 00000000 00:00 0
f769f000-f76c0000 r-xp 00000000 01:00 583     /lib/libgcc_s.so.1
f76c0000-f76c7000 ---p 00021000 01:00 583     /lib/libgcc_s.so.1
f76c7000-f76c8000 rw-p 00020000 01:00 583     /lib/libgcc_s.so.1
f76c8000-f76e5000 r-xp 00000000 01:00 543     /lib/ld-2.11.1.so
f76e9000-f76ea000 rw-p 00000000 00:00 0
f76ea000-f76ec000 rw-p 00000000 00:00 0
f76ec000-f76ed000 r--p 0001c000 01:00 543     /lib/ld-2.11.1.so
f76ed000-f76ee000 rw-p 0001d000 01:00 543     /lib/ld-2.11.1.so
f7800000-f7a00000 rw-s 00000000 00:0e 0       /SYSV000000ea (deleted)
fba00000-fca00000 rw-s 00000000 00:0e 65538   /SYSV000000ec (deleted)
fca00000-fce00000 rw-s 00000000 00:0e 98307   /SYSV000000ed (deleted)
fce00000-fd800000 rw-s 00000000 00:0e 131076  /SYSV000000ee (deleted)
ff913000-ff934000 rw-p 00000000 00:00 0       [stack]
ffff0000-ffff1000 r-xp 00000000 00:00 0       [vectors]

from 0xf7a00000 to fba00000, it has 64M memory gap, but we can't get
it from kernel.

Signed-off-by: jianhong chen <chenjianhong2@huawei.com>
Cc: stable@vger.kernel.org
---
 mm/mmap.c | 43 +++++++++++++++++++++++++++++--------------
 1 file changed, 29 insertions(+), 14 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index bd7b9f2..c5a5782 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1865,6 +1865,22 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	return error;
 }
 
+static inline unsigned long gap_start_offset(struct vm_unmapped_area_info *info,
+					unsigned long addr)
+{
+	/* get gap_start offset to adjust gap address to the
+	 * desired alignment
+	 */
+	return (info->align_offset - addr) & info->align_mask;
+}
+
+static inline unsigned long gap_end_offset(struct vm_unmapped_area_info *info,
+					unsigned long addr)
+{
+	/* get gap_end offset to adjust gap address to the desired alignment */
+	return (addr - info->align_offset) & info->align_mask;
+}
+
 unsigned long unmapped_area(struct vm_unmapped_area_info *info)
 {
 	/*
@@ -1879,10 +1895,7 @@ unsigned long unmapped_area(struct vm_unmapped_area_info *info)
 	struct vm_area_struct *vma;
 	unsigned long length, low_limit, high_limit, gap_start, gap_end;
 
-	/* Adjust search length to account for worst case alignment overhead */
-	length = info->length + info->align_mask;
-	if (length < info->length)
-		return -ENOMEM;
+	length = info->length;
 
 	/* Adjust search limits by the desired length */
 	if (info->high_limit < length)
@@ -1914,6 +1927,7 @@ unsigned long unmapped_area(struct vm_unmapped_area_info *info)
 		}
 
 		gap_start = vma->vm_prev ? vm_end_gap(vma->vm_prev) : 0;
+		gap_start += gap_start_offset(info, gap_start);
 check_current:
 		/* Check if current node has a suitable gap */
 		if (gap_start > high_limit)
@@ -1942,6 +1956,7 @@ unsigned long unmapped_area(struct vm_unmapped_area_info *info)
 				       struct vm_area_struct, vm_rb);
 			if (prev == vma->vm_rb.rb_left) {
 				gap_start = vm_end_gap(vma->vm_prev);
+				gap_start += gap_start_offset(info, gap_start);
 				gap_end = vm_start_gap(vma);
 				goto check_current;
 			}
@@ -1951,17 +1966,17 @@ unsigned long unmapped_area(struct vm_unmapped_area_info *info)
 check_highest:
 	/* Check highest gap, which does not precede any rbtree node */
 	gap_start = mm->highest_vm_end;
+	gap_start += gap_start_offset(info, gap_start);
 	gap_end = ULONG_MAX;  /* Only for VM_BUG_ON below */
 	if (gap_start > high_limit)
 		return -ENOMEM;
 
 found:
 	/* We found a suitable gap. Clip it with the original low_limit. */
-	if (gap_start < info->low_limit)
+	if (gap_start < info->low_limit) {
 		gap_start = info->low_limit;
-
-	/* Adjust gap address to the desired alignment */
-	gap_start += (info->align_offset - gap_start) & info->align_mask;
+		gap_start += gap_start_offset(info, gap_start);
+	}
 
 	VM_BUG_ON(gap_start + info->length > info->high_limit);
 	VM_BUG_ON(gap_start + info->length > gap_end);
@@ -1974,16 +1989,14 @@ unsigned long unmapped_area_topdown(struct vm_unmapped_area_info *info)
 	struct vm_area_struct *vma;
 	unsigned long length, low_limit, high_limit, gap_start, gap_end;
 
-	/* Adjust search length to account for worst case alignment overhead */
-	length = info->length + info->align_mask;
-	if (length < info->length)
-		return -ENOMEM;
+	length = info->length;
 
 	/*
 	 * Adjust search limits by the desired length.
 	 * See implementation comment at top of unmapped_area().
 	 */
 	gap_end = info->high_limit;
+	gap_end -= gap_end_offset(info, gap_end);
 	if (gap_end < length)
 		return -ENOMEM;
 	high_limit = gap_end - length;
@@ -2020,6 +2033,7 @@ unsigned long unmapped_area_topdown(struct vm_unmapped_area_info *info)
 check_current:
 		/* Check if current node has a suitable gap */
 		gap_end = vm_start_gap(vma);
+		gap_end -= gap_end_offset(info, gap_end);
 		if (gap_end < low_limit)
 			return -ENOMEM;
 		if (gap_start <= high_limit &&
@@ -2054,13 +2068,14 @@ unsigned long unmapped_area_topdown(struct vm_unmapped_area_info *info)
 
 found:
 	/* We found a suitable gap. Clip it with the original high_limit. */
-	if (gap_end > info->high_limit)
+	if (gap_end > info->high_limit) {
 		gap_end = info->high_limit;
+		gap_end -= gap_end_offset(info, gap_end);
+	}
 
 found_highest:
 	/* Compute highest gap address at the desired alignment */
 	gap_end -= info->length;
-	gap_end -= (gap_end - info->align_offset) & info->align_mask;
 
 	VM_BUG_ON(gap_end < info->low_limit);
 	VM_BUG_ON(gap_end < gap_start);
-- 
1.8.5.6

