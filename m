Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60283C43613
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:20:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DCF72075E
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:20:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DCF72075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6D746B0006; Fri, 21 Jun 2019 20:20:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1DE28E0002; Fri, 21 Jun 2019 20:20:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A33318E0001; Fri, 21 Jun 2019 20:20:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB666B0006
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 20:20:39 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 140so5315497pfa.23
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:20:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=6RRBMX3SOpfv993YgFHwmPDbxZSoZ4NpG+5+Tdr9NCY=;
        b=mUd3upBgSeWX//ljZg5bDYuayEW7Q0KUv1Oh0gZ5JlmZsi7koqXps4/fu42NGZq17z
         xGdKFyaBZUJuLpOWBLbAeMdOtdJYBgDYQ8Gb1XkV3tDNcqYGCHQcKDFU0otuUUeSUTak
         RWR4nZtSkZiwcJv4N7GWuMx27cWiBcmrNrIBsPcVHN2rjd4LgO6T8rYLscJEL3nQgTak
         3cj+jfmqwzv3hCeh6HI5rrsj4Q2z0OUj6uC0cX77+PvpJxSRLTUy01OChN7gkbHhaFJ2
         CissjvCUHjlnetVV2df3taSYx+nzf6y8cWiC9jC8GaOpt/4SyJzNz55SSOJ366SDcpN2
         e/Nw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWY9ONjtB/zus3WsX2GZLb1fKjspnR8Y+LQQNcXVOu54V4WNTIb
	DweSnJNYI93ik/gKlRsMwIIS4mm7pbWkM1KEHOqT/Lj5NF8k/gS4hAm2wVaPmQaU1MwWCANcxP3
	vrhbHCvd2wprluHzlwUxxrRFhd1rkPmHy6dOD8np/ij2kzLz3Yb513FfFRM0aXBjGcw==
X-Received: by 2002:a17:902:b096:: with SMTP id p22mr5444104plr.25.1561162839080;
        Fri, 21 Jun 2019 17:20:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUsqlK38gfqnfSrlj3Wq1tzSn5pdBjI7QE187ixbo+6k28wPgF6QqiUeGKox4400MxewQX
X-Received: by 2002:a17:902:b096:: with SMTP id p22mr5443990plr.25.1561162837688;
        Fri, 21 Jun 2019 17:20:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561162837; cv=none;
        d=google.com; s=arc-20160816;
        b=e0nA1SzHNdNRTdZOO5qLvtjvjh3B/QNSrMTLYaKodczBgHinRhaKYxjgds8NQdjtBY
         6iFvjsIa8SpFtsFDC/MNilY87sBb21nBdfYEuYQDw5PcZkyS40kGHx/7q9ndGvloRIRZ
         2QTOv8SKU6xdggcpIt1jm+6KOmTI6nzbwsDYfsAsLDePp2H6gJ2pjcdyyCPvn7SdZbsV
         xZHIJvpOYbT1RnYpBBoSuWB353PKf2aj6zZbUP7p+9SC6jP/lbAP34sVOQr6/zdGDmHO
         FAISwO/3bCSFmC7iPkAJKXtxRTtZey74ph9F2o7xR3d+3bWduUzDfnXUVGqS1WR6qNRk
         Rosg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=6RRBMX3SOpfv993YgFHwmPDbxZSoZ4NpG+5+Tdr9NCY=;
        b=isp+US+nV3K/L3qvjOhdT/ILWTWQI/NrQFHDkkCKLuX1iP0EqVa+VsSqRfVOM53Ghj
         jMriXu5T+/ul3+ri+9hnZ542cHO69UD66NAx8T5Izo4gzrFzntGRoo39TIbS9v91mLk+
         ZBO8rJQbT9ayEmH6pKUVNfcYdMyO3mNGxo/pvFGXt8N3KIfWCPeWUfrrlfkI+PdLG/Om
         5YhfUbU4KgqzsyHDoKmysA7PbBVxVKqNlB1PDUQ7SewkKp+o/BbvJL0/XklsB0ZF3ycn
         AYb1aOjdp+4rt/agH3TOtBMj84yQB/RoxUW3ol/Gwd/vOCB5UNbTI1j6o8TOy1wxViut
         2pQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id w16si4509532pfq.70.2019.06.21.17.20.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 17:20:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R871e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TUrY3xA_1561162815;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TUrY3xA_1561162815)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 22 Jun 2019 08:20:23 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: vbabka@suse.cz,
	mhocko@kernel.org,
	mgorman@techsingularity.net,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v2 PATCH 2/2] mm: mempolicy: handle vma with unmovable pages mapped correctly in mbind
Date: Sat, 22 Jun 2019 08:20:09 +0800
Message-Id: <1561162809-59140-3-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1561162809-59140-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1561162809-59140-1-git-send-email-yang.shi@linux.alibaba.com>
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
pages into the user address space specified by the mmap() call.

When calling mbind(), it would scan the vma to queue the pages for
migration to the new node.  It would split any huge page since 4.9
doesn't support THP migration, however, the packet tx ring compound
pages are not THP and even not movable.  So, the above bug is triggered.

However, the later kernel is not hit by this issue due to the
commit d44d363f65780f2ac2 ("mm: don't assume anonymous pages have
SwapBacked flag"), which just removes the PageSwapBacked check for a
different reason.

But, there is a deeper issue.  According to the semantic of mbind(), it
should return -EIO if MPOL_MF_MOVE or MPOL_MF_MOVE_ALL was specified and
MPOL_MF_STRICT was also specified, but the kernel was unable to move
all existing pages in the range.  The tx ring of the packet socket is
definitely not movable, however, mbind() returns success for this case.

Although the most socket file associates with non-movable pages, but XDP
may have movable pages from gup.  So, it sounds not fine to just check
the underlying file type of vma in vma_migratable().

Change migrate_page_add() to check if the page is movable or not, if it
is unmovable, just return -EIO.  But do not abort pte walk immediately,
since there may be pages off LRU temporarily.  We should migrate other
pages if MPOL_MF_MOVE* is specified.  Set has_unmovable flag if some
paged could not be not moved, then return -EIO for mbind() eventually.

With this change the above test would return -EIO as expected.

Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mempolicy.c | 34 +++++++++++++++++++++++++++-------
 1 file changed, 27 insertions(+), 7 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index b50039c..45d3d6e 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -403,7 +403,7 @@ void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 	},
 };
 
-static void migrate_page_add(struct page *page, struct list_head *pagelist,
+static int migrate_page_add(struct page *page, struct list_head *pagelist,
 				unsigned long flags);
 
 struct queue_pages {
@@ -465,12 +465,11 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
 	flags = qp->flags;
 	/* go to thp migration */
 	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
-		if (!vma_migratable(walk->vma)) {
+		if (!vma_migratable(walk->vma) ||
+		    migrate_page_add(page, qp->pagelist, flags)) {
 			ret = 2;
 			goto unlock;
 		}
-
-		migrate_page_add(page, qp->pagelist, flags);
 	} else
 		ret = -EIO;
 unlock:
@@ -540,7 +539,14 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 				has_unmovable |= true;
 				break;
 			}
-			migrate_page_add(page, qp->pagelist, flags);
+
+			/*
+			 * Do not abort immediately since there may be
+			 * temporary off LRU pages in the range.  Still
+			 * need migrate other LRU pages.
+			 */
+			if (migrate_page_add(page, qp->pagelist, flags))
+				has_unmovable |= true;
 		} else
 			break;
 	}
@@ -969,10 +975,21 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 /*
  * page migration, thp tail pages can be passed.
  */
-static void migrate_page_add(struct page *page, struct list_head *pagelist,
+static int migrate_page_add(struct page *page, struct list_head *pagelist,
 				unsigned long flags)
 {
 	struct page *head = compound_head(page);
+
+	/*
+	 * Non-movable page may reach here.  And, there may be
+	 * temporaty off LRU pages or non-LRU movable pages.
+	 * Treat them as unmovable pages since they can't be
+	 * isolated, so they can't be moved at the moment.  It
+	 * should return -EIO for this case too.
+	 */
+	if (!PageLRU(head) && (flags & MPOL_MF_STRICT))
+		return -EIO;
+
 	/*
 	 * Avoid migrating a page that is shared with others.
 	 */
@@ -984,6 +1001,8 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
 				hpage_nr_pages(head));
 		}
 	}
+
+	return 0;
 }
 
 /* page allocation callback for NUMA node migration */
@@ -1186,9 +1205,10 @@ static struct page *new_page(struct page *page, unsigned long start)
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

