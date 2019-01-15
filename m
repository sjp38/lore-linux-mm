Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 11AC48E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 07:03:16 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i55so1033778ede.14
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 04:03:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q9sor11144071eda.25.2019.01.15.04.03.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 04:03:14 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, memory_hotplug: __offline_pages fix wrong locking
Date: Tue, 15 Jan 2019 13:03:07 +0100
Message-Id: <20190115120307.22768-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Oscar Salvador <OSalvador@suse.com>, Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Jan has noticed that we do double unlock on some failure paths when
offlining a page range. This is indeed the case when test_pages_in_a_zone
respp. start_isolate_page_range fail. This was an omission when forward
porting the debugging patch from an older kernel.

Fix the issue by dropping mem_hotplug_done from the failure condition
and keeping the single unlock in the catch all failure path.

Reported-by: Jan Kara <jack@suse.cz>
Fixes: 7960509329c2 ("mm, memory_hotplug: print reason for the offlining failure")
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b9a667d36c55..faeeaccc5fae 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1576,7 +1576,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	   we assume this for now. .*/
 	if (!test_pages_in_a_zone(start_pfn, end_pfn, &valid_start,
 				  &valid_end)) {
-		mem_hotplug_done();
 		ret = -EINVAL;
 		reason = "multizone range";
 		goto failed_removal;
@@ -1591,7 +1590,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
 				       MIGRATE_MOVABLE,
 				       SKIP_HWPOISON | REPORT_FAILURE);
 	if (ret) {
-		mem_hotplug_done();
 		reason = "failure to isolate range";
 		goto failed_removal;
 	}
-- 
2.20.1
