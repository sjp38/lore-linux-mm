Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65916C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 18:48:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D010F2084D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 18:48:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D010F2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43EFF8E0002; Mon, 17 Jun 2019 14:48:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EEE38E0001; Mon, 17 Jun 2019 14:48:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B6D98E0002; Mon, 17 Jun 2019 14:48:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E73B38E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 14:48:21 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d19so6416274pls.1
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 11:48:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=cEa79Ing7vSKaX8MDn2jSM4PVmMjoywAZwnvPul/TVo=;
        b=dOcWspXggsXNajqX/XBhtlfMu1+3Nf5PsGnvCLVFAyzl0wqqV24By9BpEmFMVX3i9s
         nr1AsNmqSvrzdhJaQN/hYeGYCK3Hrk+efy4/6Rwf/nu68HRMPGTIMF539lVYXRzBVs8w
         ZcIn3UD7WZnY2cL4zQRy0yZ/SML4zrI/As733M/7SbYXjAufGIhbg2WUbq8Z/rDZE6vI
         WV4t9q9a/3WbAdKLLQq8JkPVxHe19dQfsim/E51fY+BMG5fzMQwpu6yj4jDo0XE2vdyn
         A/soedznx4/vxTicLe3ktT249sk0dwq9V/KUDXzoDWp813t7Pry7sAD+fT8kbdi6CNaa
         XZsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAV+d3Uttlok5x9rlaRCFglRJPNl+luDBAu7Ie672erLy8ZcKwy6
	PtifQnSMpPoirSAQcxF0KFSpAmgn7zKWrhxunA7EgprxWVitUhhIzu1SN7rMAuJRU/LT1prFvOo
	hjfNIKqyN5OCcfT4dV2kfH6eFGuk60wBhwycs6QH+V1y98MfLd7Xcc6gT6JQiqZpMeA==
X-Received: by 2002:a17:90a:23ce:: with SMTP id g72mr265140pje.77.1560797301585;
        Mon, 17 Jun 2019 11:48:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3J+d2jyk7FzJaSl95DjMMIpQ8De2R/3GF6h+HbX0JJpjE3xJMvsv82M3SM7OUL1lXp1X2
X-Received: by 2002:a17:90a:23ce:: with SMTP id g72mr264989pje.77.1560797300016;
        Mon, 17 Jun 2019 11:48:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560797300; cv=none;
        d=google.com; s=arc-20160816;
        b=pK5ZAfnBqddugkHAX292G54NKl/W4IAMHv0AvPkS8NzpmlfxA4hca8aymknsGo+PZ5
         Pn5EeyWZJmV9vyxslWB+92JS9cC81oRJQTXa+gDjTe4GXMZEGQ6/J+WtGPR01o6W4N85
         SUfQqJr2Z/lbGRd8Pb6k7JQs8KK6fQ6m4jhwCB3nvrn+cNP+qZo4KuP1s9K+bkosNYaE
         ueyzElgqsw+Nkp2hpNNrG/t56Co0P9+I4z6SHU3esEarbGoBe9Bo4v9F7doUtwfuSCZO
         ooiGJHA09X+R6eVX53IrAWfz+2wQPTPZCavkipsHogXDS8ncPeqJf6Hu7VqWB/veTbyo
         pQ7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=cEa79Ing7vSKaX8MDn2jSM4PVmMjoywAZwnvPul/TVo=;
        b=scJ7vfdTMbUOMLzMP9l5OTHimfLO9ZZ5uznUDJXZvpdHmoLNQX2Vin+yZJ2WpCA0+X
         uxcM8oW0omw1CtHEbbFKKIZY/y3tmf0+iZgrxxCEgGiwf2q0ItOaXY4FRNBU2qAIBPaL
         aSHlWWlf8dBfBDx8AbN264cCS2TNsl6k4UTc6JcSdRmIcnK8qWgJAuzwoemXbIB8TqRD
         X1IrL/Y8T/wseudQ/cK6PBNm6II+r/dicKYW6hc3XKMwLAx0a0Wt746AltBgPmQtXrhD
         h/Z+lUEKfwKntaB+x8cVdAaLrOxGf5irLfs4osyzmncnz56sHgazsMUL2C/viZv69UIV
         mauw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id co12si693078plb.197.2019.06.17.11.48.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 11:48:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R101e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TURWG85_1560797291;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TURWG85_1560797291)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 18 Jun 2019 02:48:17 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	mgorman@techsingularity.net,
	vbabka@suse.cz,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm: mempolicy: handle vma with unmovable pages mapped correctly in mbind
Date: Tue, 18 Jun 2019 02:48:10 +0800
Message-Id: <1560797290-42267-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When running syzkaller internally, we ran into the below bug on 4.9.x
kernel:

kernel BUG at mm/huge_memory.c:2124!
invalid opcode: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 0 PID: 1518 Comm: syz-executor107 Not tainted 4.9.168+ #2
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 0.5.1 01/01/2011
task: ffff880067b34900 task.stack: ffff880068998000
RIP: 0010:[<ffffffff81895d6b>]  [<ffffffff81895d6b>] split_huge_page_to_list+0x8fb/0x1030 mm/huge_memory.c:2124
RSP: 0018:ffff88006899f980  EFLAGS: 00010286
RAX: 0000000000000000 RBX: ffffea00018f1700 RCX: 0000000000000000
RDX: 1ffffd400031e2e7 RSI: 0000000000000001 RDI: ffffea00018f1738
RBP: ffff88006899f9e8 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000000 R11: fffffbfff0d8b13e R12: ffffea00018f1400
R13: ffffea00018f1400 R14: ffffea00018f1720 R15: ffffea00018f1401
FS:  00007fa333996740(0000) GS:ffff88006c600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020000040 CR3: 0000000066b9c000 CR4: 00000000000606f0
Stack:
 0000000000000246 ffff880067b34900 0000000000000000 ffff88007ffdc000
 0000000000000000 ffff88006899f9e8 ffffffff812b4015 ffff880064c64e18
 ffffea00018f1401 dffffc0000000000 ffffea00018f1700 0000000020ffd000
Call Trace:
 [<ffffffff818490f1>] split_huge_page include/linux/huge_mm.h:100 [inline]
 [<ffffffff818490f1>] queue_pages_pte_range+0x7e1/0x1480 mm/mempolicy.c:538
 [<ffffffff817ed0da>] walk_pmd_range mm/pagewalk.c:50 [inline]
 [<ffffffff817ed0da>] walk_pud_range mm/pagewalk.c:90 [inline]
 [<ffffffff817ed0da>] walk_pgd_range mm/pagewalk.c:116 [inline]
 [<ffffffff817ed0da>] __walk_page_range+0x44a/0xdb0 mm/pagewalk.c:208
 [<ffffffff817edb94>] walk_page_range+0x154/0x370 mm/pagewalk.c:285
 [<ffffffff81844515>] queue_pages_range+0x115/0x150 mm/mempolicy.c:694
 [<ffffffff8184f493>] do_mbind mm/mempolicy.c:1241 [inline]
 [<ffffffff8184f493>] SYSC_mbind+0x3c3/0x1030 mm/mempolicy.c:1370
 [<ffffffff81850146>] SyS_mbind+0x46/0x60 mm/mempolicy.c:1352
 [<ffffffff810097e2>] do_syscall_64+0x1d2/0x600 arch/x86/entry/common.c:282
 [<ffffffff82ff6f93>] entry_SYSCALL_64_after_swapgs+0x5d/0xdb
Code: c7 80 1c 02 00 e8 26 0a 76 01 <0f> 0b 48 c7 c7 40 46 45 84 e8 4c
RIP  [<ffffffff81895d6b>] split_huge_page_to_list+0x8fb/0x1030 mm/huge_memory.c:2124
 RSP <ffff88006899f980>

with the below test:

---8<---

uint64_t r[1] = {0xffffffffffffffff};

int main(void)
{
	syscall(__NR_mmap, 0x20000000, 0x1000000, 3, 0x32, -1, 0);
				intptr_t res = 0;
	res = syscall(__NR_socket, 0x11, 3, 0x300);
	if (res != -1)
		r[0] = res;
*(uint32_t*)0x20000040 = 0x10000;
*(uint32_t*)0x20000044 = 1;
*(uint32_t*)0x20000048 = 0xc520;
*(uint32_t*)0x2000004c = 1;
	syscall(__NR_setsockopt, r[0], 0x107, 0xd, 0x20000040, 0x10);
	syscall(__NR_mmap, 0x20fed000, 0x10000, 0, 0x8811, r[0], 0);
*(uint64_t*)0x20000340 = 2;
	syscall(__NR_mbind, 0x20ff9000, 0x4000, 0x4002, 0x20000340,
0x45d4, 3);
	return 0;
}

---8<---

Actually the test does:

mmap(0x20000000, 16777216, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x20000000
socket(AF_PACKET, SOCK_RAW, 768)        = 3
setsockopt(3, SOL_PACKET, PACKET_TX_RING, {block_size=65536, block_nr=1, frame_size=50464, frame_nr=1}, 16) = 0
mmap(0x20fed000, 65536, PROT_NONE, MAP_SHARED|MAP_FIXED|MAP_POPULATE|MAP_DENYWRITE, 3, 0) = 0x20fed000
mbind(..., MPOL_MF_STRICT|MPOL_MF_MOVE) = 0

The setsockopt() would allocate compound pages (16 pages in this test)
for packet tx ring, then the mmap() would call packet_mmap() to map the
pages into the user address space specifed by the mmap() call.

When calling mbind(), it would scan the vma to queue the pages for
migration to the new node.  It would split any huge page since 4.9
doesn't support THP migration, however, the packet tx ring compound
pages are not THP and even not movable.  So, the above bug is triggered.

However, the later kernel is not hit by this issue due to the commit
d44d363f65780f2ac2ec672164555af54896d40d ("mm: don't assume anonymous
pages have SwapBacked flag"), which just removes the PageSwapBacked
check for a different reason.

But, there is a deeper issue.  According to the semantic of mbind(), it
should return -EIO if MPOL_MF_MOVE or MPOL_MF_MOVE_ALL was specified and
the kernel was unable to move all existing pages in the range.  The tx ring
of the packet socket is definitely not movable, however, mbind returns
success for this case.

Although the most socket file associates with non-movable pages, but XDP
may have movable pages from gup.  So, it sounds not fine to just check
the underlying file type of vma in vma_migratable().

Change migrate_page_add() to check if the page is movable or not, if it
is unmovable, just return -EIO.  We don't have to check non-LRU movable
pages since just zsmalloc and virtio-baloon support this.  And, they
should be not able to reach here.

With this change the above test would return -EIO as expected.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/mempolicy.h |  3 ++-
 mm/mempolicy.c            | 22 +++++++++++++++++-----
 2 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 5228c62..cce7ba3 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -198,7 +198,8 @@ static inline bool vma_migratable(struct vm_area_struct *vma)
 	if (vma->vm_file &&
 		gfp_zone(mapping_gfp_mask(vma->vm_file->f_mapping))
 								< policy_zone)
-			return false;
+		return false;
+
 	return true;
 }
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 2219e74..4d9e17d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -403,7 +403,7 @@ void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 	},
 };
 
-static void migrate_page_add(struct page *page, struct list_head *pagelist,
+static int migrate_page_add(struct page *page, struct list_head *pagelist,
 				unsigned long flags);
 
 struct queue_pages {
@@ -467,7 +467,9 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
 			goto unlock;
 		}
 
-		migrate_page_add(page, qp->pagelist, flags);
+		ret = migrate_page_add(page, qp->pagelist, flags);
+		if (ret)
+			goto unlock;
 	} else
 		ret = -EIO;
 unlock:
@@ -521,7 +523,9 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
 			if (!vma_migratable(vma))
 				break;
-			migrate_page_add(page, qp->pagelist, flags);
+			ret = migrate_page_add(page, qp->pagelist, flags);
+			if (ret)
+				break;
 		} else
 			break;
 	}
@@ -940,10 +944,15 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 /*
  * page migration, thp tail pages can be passed.
  */
-static void migrate_page_add(struct page *page, struct list_head *pagelist,
+static int migrate_page_add(struct page *page, struct list_head *pagelist,
 				unsigned long flags)
 {
 	struct page *head = compound_head(page);
+
+	/* Non-movable page may reach here. */
+	if (!PageLRU(head))
+		return -EIO;
+
 	/*
 	 * Avoid migrating a page that is shared with others.
 	 */
@@ -955,6 +964,8 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
 				hpage_nr_pages(head));
 		}
 	}
+
+	return 0;
 }
 
 /* page allocation callback for NUMA node migration */
@@ -1157,9 +1168,10 @@ static struct page *new_page(struct page *page, unsigned long start)
 }
 #else
 
-static void migrate_page_add(struct page *page, struct list_head *pagelist,
+static int migrate_page_add(struct page *page, struct list_head *pagelist,
 				unsigned long flags)
 {
+	return -EIO;
 }
 
 int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
-- 
1.8.3.1

