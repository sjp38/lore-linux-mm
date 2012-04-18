Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 9C8E56B007E
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 05:27:28 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zhong@linux.vnet.ibm.com>;
	Wed, 18 Apr 2012 14:57:25 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3I9RL3x4251666
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 14:57:21 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3IEv3xg017490
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 20:27:03 +0530
Message-ID: <1334741239.30072.7.camel@ThinkPad-T420>
Subject: [PATCH mm] limit the mm->map_count not greater than
 sysctl_max_map_count
From: Li Zhong <zhong@linux.vnet.ibm.com>
Date: Wed, 18 Apr 2012 05:27:19 -0400
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

When reading the mmap codes, I found the checking of mm->map_count
against sysctl_max_map_count is not consistent. At some places, ">" is
used; at some other places, ">=" is used.

This patch changes ">" to ">=", so they are consistent, and makes sure
the value is not greater (one more) than sysctl_max_map_count.

Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
---
 mm/mmap.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index a7bf6a3..85f4816 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -987,7 +987,7 @@ unsigned long do_mmap_pgoff(struct file *file,
unsigned long addr,
                return -EOVERFLOW;
 
 	/* Too many mappings? */
-	if (mm->map_count > sysctl_max_map_count)
+	if (mm->map_count >= sysctl_max_map_count)
 		return -ENOMEM;
 
 	/* Obtain the address to map to. we verify (or select) it and ensure
@@ -2193,7 +2193,7 @@ unsigned long do_brk(unsigned long addr, unsigned
long len)
 	if (!may_expand_vm(mm, len >> PAGE_SHIFT))
 		return -ENOMEM;
 
-	if (mm->map_count > sysctl_max_map_count)
+	if (mm->map_count >= sysctl_max_map_count)
 		return -ENOMEM;
 
 	if (security_vm_enough_memory_mm(mm, len >> PAGE_SHIFT))
-- 
1.7.6.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
