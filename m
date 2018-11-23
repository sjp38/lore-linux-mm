Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BC51E6B332C
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 17:28:43 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id a72-v6so5906016pfj.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 14:28:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i63sor63780418pge.62.2018.11.23.14.28.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Nov 2018 14:28:42 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] drivers/base/memory.c: remove an unnecessary check on NR_MEM_SECTIONS
Date: Sat, 24 Nov 2018 06:28:11 +0800
Message-Id: <20181123222811.18216-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, rafael@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

In commit cb5e39b8038b ("drivers: base: refactor add_memory_section() to
add_memory_block()"), add_memory_block() is introduced, which is only
invoked in memory_dev_init().

When combine these two loops in memory_dev_init() and
add_memory_block(), they looks like this:

    for (i = 0; i < NR_MEM_SECTIONS; i += sections_per_block)
        for (j = i;
	    (j < i + sections_per_block) && j < NR_MEM_SECTIONS;
	    j++)

Since it is sure (i < NR_MEM_SECTIONS) and j sits in its own memory
block, the check of (j < NR_MEM_SECTIONS) is not necessary.

This patch just removes this check.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 drivers/base/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 0e5985682642..547997a2249b 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -688,7 +688,7 @@ static int add_memory_block(int base_section_nr)
 	int i, ret, section_count = 0, section_nr;
 
 	for (i = base_section_nr;
-	     (i < base_section_nr + sections_per_block) && i < NR_MEM_SECTIONS;
+	     i < base_section_nr + sections_per_block;
 	     i++) {
 		if (!present_section_nr(i))
 			continue;
-- 
2.15.1
