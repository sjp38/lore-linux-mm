Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A093C74A54
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:26:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFFE721019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:26:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="DN3eG8DX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFFE721019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 563638E00D1; Thu, 11 Jul 2019 10:26:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F1C68E00C4; Thu, 11 Jul 2019 10:26:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F72D8E00D1; Thu, 11 Jul 2019 10:26:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 08F9E8E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:26:43 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id v11so6958992iop.7
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:26:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=/snaNkVEEW4nTR1xAXfvlEoe9rj/2L0Z92puglvXclU=;
        b=sha/vlkX1IpQ1PmdC3D2JvGUoIpIPNsOA8yPFiGN3HbZ4lzz2gXKPBu/wR0fBlLwSB
         TpyQ2ALPYgxI9flFhi7iYJeWJUhXKXJxU9hPZtTMtmYPNW08FHJxqIpKNLiB0TeyiQDh
         CQ0XnpTKOfByEOyZBOJofuAV0TbmYCKhZxm/HmzKSgssVHTZwMeTY4zD+E+GZVvgra92
         FhiBxX5XJ/y0u1O9wW8SRLLC8sueJ74WRn+DzY01x89eKa5uSXJAn9g7vGbR81FXx73S
         evH6SKQ06SgwzhzgPKVWlr4WFjHfgqMUaw1Nw7qHr4uJrd0rFOGDJ5fpIEvtq7n9TVJw
         XdKA==
X-Gm-Message-State: APjAAAUrl4t8Tr+fFhlWj0P3Ar3W9l/XzZOs/kAosjOCHd0osVyimqvp
	wLf00ZIjJ8rkpuop1hTg7kqvloKH9piBAE0sKYVlwL3Kv67OGp0Y/7U7oS9t08CI14AIYLhg/Ct
	mkzYWEUfmbZuJEhZvky5K4a7lm5VW2iJRMkScdfEm06to4bYfT01DGEpQZO0SYqRq+A==
X-Received: by 2002:a5d:9550:: with SMTP id a16mr4668807ios.106.1562855202786;
        Thu, 11 Jul 2019 07:26:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzL1nD4zSuovF2OMieH4L/I7bjx/Kl096XVXbL21vsplsrD82gAoSF4jMI1f/2MpXl6XQe8
X-Received: by 2002:a5d:9550:: with SMTP id a16mr4668702ios.106.1562855201789;
        Thu, 11 Jul 2019 07:26:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855201; cv=none;
        d=google.com; s=arc-20160816;
        b=rp+Xb4+o3I2yaM9ewYoz8XrBLRSv+7qUnVHLLeZR7rJ8uhugAXUUXNiDeHLL1SLg3Y
         joxGFpJze3mjxp4ATJ1GpEIlfo4sGfEzWAWJdjdDMtCme1Y1BMSVoud31ZFX6g6Oq0V5
         LIzCofGr4nREGOkQNdRCniE3hpSGP3qpk/RWJCCSpmfoMKSzQynGfbFRbXPBVTOr4hGd
         X+vtAF6Qu5SQszjWmxR7v4dihO2stmHqWEYm53nbmFR9oD60/orna73O6psjAZv8ER6k
         OTokerE6PQXuypBmZI7zQ7oEZC1MiaHLOBxA77/aILtX0y/LfIkrExVxmFdov+9lQoIp
         9BEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=/snaNkVEEW4nTR1xAXfvlEoe9rj/2L0Z92puglvXclU=;
        b=CA3wMrtGMNm0OGS4Y6yvgxdkez1xZX0kAPmi2LgMOzIIJDuQ1zUHvkzbevOC4gjQyv
         jyTKVck0o+kZT1dWIogjdfDUXvHQ+RTP2mdEYrcZpmxvLt5FGnG23HZ33c9/v/6A2GL1
         jQl8ua9WoqC4iUmsQxhiSCQpUvgMWfFT/6aQwEILlMmGzxx46VFdOczgrQeBXPR5HWCB
         1gZog8ar2SEIupmS5fwUmXt7aU4juKUViSmnudUfA1baWyMCR1n6vijY6dlVksKCof+r
         MTb2PAmFlgGC/CI7vM8l9RoBq1E4LmKSdPoZQLJ/AdA38tqbakQsJP2AVhJkJvTyescO
         mutw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=DN3eG8DX;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id m4si9249096iob.58.2019.07.11.07.26.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:26:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=DN3eG8DX;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEO9em001500;
	Thu, 11 Jul 2019 14:26:32 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=/snaNkVEEW4nTR1xAXfvlEoe9rj/2L0Z92puglvXclU=;
 b=DN3eG8DXxQ7ozWrPnuAeiliXI+C+IxsV4od5f1TGtSHKulg61bcs9xHwRh7Wbxnghz9I
 ThGtm4GjaEXofJ/g9FZ3+haVgxr28XtB+ucHwwPynqaJaB3a3cRcsSIJZKS7VGg7EiMw
 rNBOsKQ9GocLmZ4MB3gTzKkSMvJmagNALGBonkOZRxAN95EUC0/Wbwu+HXXfAxWl18C9
 GkNsUrqBGLn4Ir8iOvlMsFHQtMtfTKAD2WUAOBydyAaB9K/Tb/BB4EigTZEu+vozMNyu
 ysx0uiZcdvKRUDvzf4/aPdWlIS0c9udhkbyOJiJWUg4LAaH97xlf2yC2mUSNfBoqVSwX 4Q== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2tjk2u0e09-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:26:32 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcu7021444;
	Thu, 11 Jul 2019 14:26:28 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 14/26] mm/asi: Handle ASI mapped range leaks and overlaps
Date: Thu, 11 Jul 2019 16:25:26 +0200
Message-Id: <1562855138-19507-15-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=857 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When mapping a buffer in an ASI page-table, data around the buffer can
also be mapped if the entire buffer is not aligned with the page directory
size used for the mapping. So, data can potentially leak into the ASI
page-table. In such a case, print a warning that data are leaking.

Also data effectively mapped can overlap with an already mapped buffer.
This is not an issue when mapping data but, when unmapping, make sure
data from another buffer don't get unmapped as a side effect.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/mm/asi_pagetable.c |  230 +++++++++++++++++++++++++++++++++++++++----
 1 files changed, 212 insertions(+), 18 deletions(-)

diff --git a/arch/x86/mm/asi_pagetable.c b/arch/x86/mm/asi_pagetable.c
index 1ff0c47..f1ee65b 100644
--- a/arch/x86/mm/asi_pagetable.c
+++ b/arch/x86/mm/asi_pagetable.c
@@ -9,6 +9,14 @@
 
 #include <asm/asi.h>
 
+static unsigned long page_directory_size[] = {
+	[PGT_LEVEL_PTE] = PAGE_SIZE,
+	[PGT_LEVEL_PMD] = PMD_SIZE,
+	[PGT_LEVEL_PUD] = PUD_SIZE,
+	[PGT_LEVEL_P4D] = P4D_SIZE,
+	[PGT_LEVEL_PGD] = PGDIR_SIZE,
+};
+
 /*
  * Structure to keep track of address ranges mapped into an ASI.
  */
@@ -17,8 +25,16 @@ struct asi_range_mapping {
 	void *ptr;			/* range start address */
 	size_t size;			/* range size */
 	enum page_table_level level;	/* mapping level */
+	int overlap;			/* overlap count */
 };
 
+#define ASI_RANGE_MAP_ADDR(r)	\
+	round_down((unsigned long)((r)->ptr), page_directory_size[(r)->level])
+
+#define ASI_RANGE_MAP_END(r)	\
+	round_up((unsigned long)((r)->ptr + (r)->size), \
+		 page_directory_size[(r)->level])
+
 /*
  * Get the pointer to the beginning of a page table directory from a page
  * table directory entry.
@@ -609,6 +625,71 @@ static int asi_copy_pgd_range(struct asi *asi,
 	return 0;
 }
 
+
+/*
+ * Map a VA range, taking into account any overlap with already mapped
+ * VA ranges. On error, return < 0. Otherwise return the number of
+ * ranges the specified range is overlapping with.
+ */
+static int asi_map_overlap(struct asi *asi, void *ptr, size_t size,
+			   enum page_table_level level)
+{
+	unsigned long map_addr, map_end;
+	unsigned long addr, end;
+	struct asi_range_mapping *range;
+	bool need_mapping;
+	int err, overlap;
+
+	addr = (unsigned long)ptr;
+	end = addr + (unsigned long)size;
+	need_mapping = true;
+	overlap = 0;
+
+	lockdep_assert_held(&asi->lock);
+	list_for_each_entry(range, &asi->mapping_list, list) {
+
+		if (range->ptr == ptr && range->size == size) {
+			/* we are mapping the same range again */
+			pr_debug("ASI %p: MAP %px/%lx/%d already mapped\n",
+				 asi, ptr, size, level);
+			return -EBUSY;
+		}
+
+		/* check overlap with mapped range */
+		map_addr = ASI_RANGE_MAP_ADDR(range);
+		map_end = ASI_RANGE_MAP_END(range);
+		if (end <= map_addr || addr >= map_end) {
+			/* no overlap, continue */
+			continue;
+		}
+
+		pr_debug("ASI %p: MAP %px/%lx/%d overlaps with %px/%lx/%d\n",
+			 asi, ptr, size, level,
+			 range->ptr, range->size, range->level);
+		range->overlap++;
+		overlap++;
+
+		/*
+		 * Check if new range is included into an existing range.
+		 * If so then the new range is already entirely mapped.
+		 */
+		if (addr >= map_addr && end <= map_end) {
+			pr_debug("ASI %p: MAP %px/%lx/%d implicitly mapped\n",
+				 asi, ptr, size, level);
+			need_mapping = false;
+		}
+	}
+
+	if (need_mapping) {
+		err = asi_copy_pgd_range(asi, asi->pgd, current->mm->pgd,
+					 addr, end, level);
+		if (err)
+			return err;
+	}
+
+	return overlap;
+}
+
 /*
  * Copy page table entries from the current page table (i.e. from the
  * kernel page table) to the specified ASI page-table. The level
@@ -619,44 +700,53 @@ int asi_map_range(struct asi *asi, void *ptr, size_t size,
 		  enum page_table_level level)
 {
 	struct asi_range_mapping *range_mapping;
+	unsigned long page_dir_size = page_directory_size[level];
 	unsigned long addr = (unsigned long)ptr;
 	unsigned long end = addr + ((unsigned long)size);
+	unsigned long map_addr, map_end;
 	unsigned long flags;
-	int err;
+	int err, overlap;
+
+	map_addr = round_down(addr, page_dir_size);
+	map_end = round_up(end, page_dir_size);
 
-	pr_debug("ASI %p: MAP %px/%lx/%d\n", asi, ptr, size, level);
+	pr_debug("ASI %p: MAP %px/%lx/%d -> %lx-%lx\n", asi, ptr, size, level,
+		 map_addr, map_end);
+	if (map_addr < addr)
+		pr_debug("ASI %p: MAP LEAK %lx-%lx\n", asi, map_addr, addr);
+	if (map_end > end)
+		pr_debug("ASI %p: MAP LEAK %lx-%lx\n", asi, end, map_end);
 
 	spin_lock_irqsave(&asi->lock, flags);
 
-	/* check if the range is already mapped */
-	range_mapping = asi_get_range_mapping(asi, ptr);
-	if (range_mapping) {
-		pr_debug("ASI %p: MAP %px/%lx/%d already mapped\n",
-			 asi, ptr, size, level);
-		err = -EBUSY;
-		goto done;
+	/*
+	 * Map the new range with taking overlap with already mapped ranges
+	 * into account.
+	 */
+	overlap = asi_map_overlap(asi, ptr, size, level);
+	if (overlap < 0) {
+		err = overlap;
+		goto error;
 	}
 
-	/* map new range */
+	/* add new range */
 	range_mapping = kmalloc(sizeof(*range_mapping), GFP_KERNEL);
 	if (!range_mapping) {
 		err = -ENOMEM;
-		goto done;
+		goto error;
 	}
 
-	err = asi_copy_pgd_range(asi, asi->pgd, current->mm->pgd,
-				 addr, end, level);
-	if (err)
-		goto done;
-
 	INIT_LIST_HEAD(&range_mapping->list);
 	range_mapping->ptr = ptr;
 	range_mapping->size = size;
 	range_mapping->level = level;
+	range_mapping->overlap = overlap;
 	list_add(&range_mapping->list, &asi->mapping_list);
-done:
 	spin_unlock_irqrestore(&asi->lock, flags);
+	return 0;
 
+error:
+	spin_unlock_irqrestore(&asi->lock, flags);
 	return err;
 }
 EXPORT_SYMBOL(asi_map_range);
@@ -776,6 +866,110 @@ static void asi_clear_pgd_range(struct asi *asi, pgd_t *pagetable,
 	} while (pgd++, addr = next, addr < end);
 }
 
+
+/*
+ * Unmap a VA range, taking into account any overlap with other mapped
+ * VA ranges. This unmaps the specified range then remap any range this
+ * range was overlapping with.
+ */
+static void asi_unmap_overlap(struct asi *asi, struct asi_range_mapping *range)
+{
+	unsigned long map_addr, map_end;
+	struct asi_range_mapping *r;
+	unsigned long addr, end;
+	unsigned long r_addr;
+	bool need_unmapping;
+	int err, overlap;
+
+	addr = (unsigned long)range->ptr;
+	end = addr + (unsigned long)range->size;
+	overlap = range->overlap;
+	need_unmapping = true;
+
+	lockdep_assert_held(&asi->lock);
+
+	/*
+	 * Adjust overlap information and check if range effectively needs
+	 * to be unmapped.
+	 */
+	list_for_each_entry(r, &asi->mapping_list, list) {
+
+		if (!overlap) {
+			/* no more overlap */
+			break;
+		}
+
+		WARN_ON(range->ptr == r->ptr && range->size == r->size);
+
+		/* check overlap with other range */
+		map_addr = ASI_RANGE_MAP_ADDR(r);
+		map_end = ASI_RANGE_MAP_END(r);
+		if (end < map_addr || addr >= map_end) {
+			/* no overlap, continue */
+			continue;
+		}
+
+		pr_debug("ASI %p: UNMAP %px/%lx/%d overlaps with %px/%lx/%d\n",
+			 asi, range->ptr, range->size, range->level,
+			 r->ptr, r->size, r->level);
+		r->overlap--;
+		overlap--;
+
+		/*
+		 * Check if range is included into a remaining mapped range.
+		 * If so then there's no need to unmap.
+		 */
+		if (map_addr <= addr && end <= map_end) {
+			pr_debug("ASI %p: UNMAP %px/%lx/%d still mapped\n",
+				 asi, range->ptr, range->size, range->level);
+			need_unmapping = false;
+		}
+	}
+
+	WARN_ON(overlap);
+
+	if (need_unmapping) {
+		asi_clear_pgd_range(asi, asi->pgd, addr, end, range->level);
+
+		/*
+		 * Remap all range we overlap with as mapping clearing
+		 * will have unmap the overlap.
+		 */
+		overlap = range->overlap;
+		list_for_each_entry(r, &asi->mapping_list, list) {
+			if (!overlap) {
+				/* no more overlap */
+				break;
+			}
+
+			/* check overlap with other range */
+			map_addr = ASI_RANGE_MAP_ADDR(r);
+			map_end = ASI_RANGE_MAP_END(r);
+			if (end < map_addr || addr >= map_end) {
+				/* no overlap, continue */
+				continue;
+			}
+			pr_debug("ASI %p: UNMAP %px/%lx/%d remaps %px/%lx/%d\n",
+				 asi, range->ptr, range->size, range->level,
+				 r->ptr, r->size, r->level);
+			overlap--;
+
+			r_addr = (unsigned long)r->ptr;
+			err = asi_copy_pgd_range(asi, asi->pgd,
+						 current->mm->pgd,
+						 r_addr, r_addr + r->size,
+						 r->level);
+			if (err) {
+				pr_debug("ASI %p: UNMAP %px/%lx/%d remaps %px/%lx/%d error %d\n",
+					 asi, range->ptr, range->size,
+					 range->level,
+					 r->ptr, r->size, r->level,
+					 err);
+			}
+		}
+	}
+}
+
 /*
  * Clear page table entries in the specified ASI page-table.
  */
@@ -797,8 +991,8 @@ void asi_unmap(struct asi *asi, void *ptr)
 	end = addr + range_mapping->size;
 	pr_debug("ASI %p: UNMAP %px/%lx/%d\n", asi, ptr,
 		 range_mapping->size, range_mapping->level);
-	asi_clear_pgd_range(asi, asi->pgd, addr, end, range_mapping->level);
 	list_del(&range_mapping->list);
+	asi_unmap_overlap(asi, range_mapping);
 	kfree(range_mapping);
 done:
 	spin_unlock_irqrestore(&asi->lock, flags);
-- 
1.7.1

