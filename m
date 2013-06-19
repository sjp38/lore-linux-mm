Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 47D546B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 13:55:03 -0400 (EDT)
Date: Wed, 19 Jun 2013 12:25:06 -0400
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: [PATCH] mmap: allow MAP_HUGETLB for hugetlbfs files v2
Message-ID: <20130619162506.GA7511@logfs.org>
References: <1371581225-27535-1-git-send-email-joern@logfs.org>
 <1371581225-27535-3-git-send-email-joern@logfs.org>
 <51C107E9.9050900@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <51C107E9.9050900@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

It is counterintuitive at best that mmap'ing a hugetlbfs file with
MAP_HUGETLB fails, while mmap'ing it without will a) succeed and b)
return huge pages.
v2: use is_file_hugepages(), as suggested by Jianguo

Signed-off-by: Joern Engel <joern@logfs.org>
Cc: Jianguo Wu <wujianguo@huawei.com>
---
 mm/mmap.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 2a594246..cdc8e7a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1322,11 +1322,12 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 
 	if (!(flags & MAP_ANONYMOUS)) {
 		audit_mmap_fd(fd, flags);
-		if (unlikely(flags & MAP_HUGETLB))
-			return -EINVAL;
 		file = fget(fd);
 		if (!file)
 			goto out;
+		retval = -EINVAL;
+		if (unlikely(flags & MAP_HUGETLB && !is_file_hugepages(file)))
+			goto out_fput;
 	} else if (flags & MAP_HUGETLB) {
 		struct user_struct *user = NULL;
 		/*
@@ -1346,6 +1347,7 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
 	retval = vm_mmap_pgoff(file, addr, len, prot, flags, pgoff);
+out_fput:
 	if (file)
 		fput(file);
 out:
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
