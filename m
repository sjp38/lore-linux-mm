Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 1E7266B0037
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 13:13:08 -0400 (EDT)
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 6/7] drivers: base: remove improper get/put in add_memory_section()
Date: Tue, 20 Aug 2013 12:13:02 -0500
Message-Id: <1377018783-26756-6-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1377018783-26756-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1377018783-26756-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dave Hansen <dave@sr71.net>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Yinghai Lu <yinghai@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

The path through add_memory_section() when the memory block already
exists uses flawed refcounting logic.  A get_device() is done on a
memory block using a pointer that might not be valid as we dropped
our previous reference and didn't obtain a new reference in the
proper way.

Lets stop pretending and just remove the get/put.  The
mem_sysfs_mutex, which we hold over the entire init loop now, will
prevent the memory blocks from disappearing from under us.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/base/memory.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index a695164..7d9d3bc 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -613,14 +613,12 @@ static int add_memory_section(struct mem_section *section,
 		if (scn_nr >= (*mem_p)->start_section_nr &&
 		    scn_nr <= (*mem_p)->end_section_nr) {
 			mem = *mem_p;
-			get_device(&mem->dev);
 		}
 	}
 
-	if (mem) {
+	if (mem)
 		mem->section_count++;
-		put_device(&mem->dev);
-	} else {
+	else {
 		ret = init_memory_block(&mem, section, MEM_ONLINE);
 		/* store memory_block pointer for next loop */
 		if (!ret && mem_p)
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
