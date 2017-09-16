Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id D322B6B0277
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 22:53:51 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 43so4466835qtr.6
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 19:53:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r55sor1148391qta.18.2017.09.15.19.53.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Sep 2017 19:53:50 -0700 (PDT)
Subject: [PATCH 2/2] mm/memory_hotplug: define
 find_{smallest|biggest}_section_pfn as unsigned long
References: <e643a387-e573-6bbf-d418-c60c8ee3d15e@gmail.com>
From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Message-ID: <d9d5593a-d0a4-c4be-ab08-493df59a85c6@gmail.com>
Date: Fri, 15 Sep 2017 22:53:49 -0400
MIME-Version: 1.0
In-Reply-To: <e643a387-e573-6bbf-d418-c60c8ee3d15e@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.com>, qiuxishi@huawei.com, arbab@linux.vnet.ibm.com, vbabka@suse.cz, linux-kernel@vger.kernel.org

find_{smallest|biggest}_section_pfn()s find the smallest/biggest section
and return the pfn of the section. But the functions are defined as int.
So the functions always return 0x00000000 - 0xffffffff. It means
if memory address is over 16TB, the functions does not work correctly.

To handle 64 bit value, the patch defines find_{smallest|biggest}_section_pfn()
as unsigned long.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 mm/memory_hotplug.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 38c3c37..120e45b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -582,7 +582,7 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,

 #ifdef CONFIG_MEMORY_HOTREMOVE
 /* find the smallest valid pfn in the range [start_pfn, end_pfn) */
-static int find_smallest_section_pfn(int nid, struct zone *zone,
+static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
 				     unsigned long start_pfn,
 				     unsigned long end_pfn)
 {
@@ -607,7 +607,7 @@ static int find_smallest_section_pfn(int nid, struct zone *zone,
 }

 /* find the biggest valid pfn in the range [start_pfn, end_pfn). */
-static int find_biggest_section_pfn(int nid, struct zone *zone,
+static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
 				    unsigned long start_pfn,
 				    unsigned long end_pfn)
 {
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
