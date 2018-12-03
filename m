Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9FA456B687B
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 05:03:22 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c34so3896557edb.8
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 02:03:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l22-v6sor3277405ejr.15.2018.12.03.02.03.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 02:03:20 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] hwpoison, memory_hotplug: allow hwpoisoned pages to be offlined
Date: Mon,  3 Dec 2018 11:03:09 +0100
Message-Id: <20181203100309.14784-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Oscar Salvador <OSalvador@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@gmail.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Stable tree <stable@vger.kernel.org>

From: Michal Hocko <mhocko@suse.com>

We have received a bug report that an injected MCE about faulty memory
prevents memory offline to succeed. The underlying reason is that the
HWPoison page has an elevated reference count and the migration keeps
failing. There are two problems with that. First of all it is dubious
to migrate the poisoned page because we know that accessing that memory
is possible to fail. Secondly it doesn't make any sense to migrate a
potentially broken content and preserve the memory corruption over to a
new location.

Oscar has found out that it is the elevated reference count from
memory_failure that is confusing the offlining path. HWPoisoned pages
are isolated from the LRU list but __offline_pages might still try to
migrate them if there is any preceding migrateable pages in the pfn
range. Such a migration would fail due to the reference count but
the migration code would put it back on the LRU list. This is quite
wrong in itself but it would also make scan_movable_pages stumble over
it again without any way out.

This means that the hotremove with hwpoisoned pages has never really
worked (without a luck). HWPoisoning really needs a larger surgery
but an immediate and backportable fix is to skip over these pages during
offlining. Even if they are still mapped for some reason then
try_to_unmap should turn those mappings into hwpoison ptes and cause
SIGBUS on access. Nobody should be really touching the content of the
page so it should be safe to ignore them even when there is a pending
reference count.

Debugged-by: Oscar Salvador <osalvador@suse.com>
Cc: stable
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
I am sending this as an RFC now because I am not fully sure I see all
the consequences myself yet. This has passed a testing by Oscar but I
would highly appreciate a review from Naoya about my assumptions about
hwpoisoning. E.g. it is not entirely clear to me whether there is a
potential case where the page might be still mapped. I have put
try_to_unmap just to be sure. It would be really great if I could drop
that part because then it is not really great which of the TTU flags to
use to cover all potential cases.

I have marked the patch for stable but I have no idea how far back it
should go. Probably everything that already has hotremove and hwpoison
code.

Thanks in advance!

 mm/memory_hotplug.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c6c42a7425e5..08c576d5a633 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -34,6 +34,7 @@
 #include <linux/hugetlb.h>
 #include <linux/memblock.h>
 #include <linux/compaction.h>
+#include <linux/rmap.h>
 
 #include <asm/tlbflush.h>
 
@@ -1366,6 +1367,17 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			pfn = page_to_pfn(compound_head(page))
 				+ hpage_nr_pages(page) - 1;
 
+		/*
+		 * HWPoison pages have elevated reference counts so the migration would
+		 * fail on them. It also doesn't make any sense to migrate them in the
+		 * first place. Still try to unmap such a page in case it is still mapped.
+		 */
+		if (PageHWPoison(page)) {
+			if (page_mapped(page))
+				try_to_unmap(page, TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS);
+			continue;
+		}
+
 		if (!get_page_unless_zero(page))
 			continue;
 		/*
-- 
2.19.1
