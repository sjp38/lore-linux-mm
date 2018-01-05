Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABD8B6B03BD
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 01:10:27 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id t65so2289727pfe.22
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 22:10:27 -0800 (PST)
Received: from out0-194.mail.aliyun.com (out0-194.mail.aliyun.com. [140.205.0.194])
        by mx.google.com with ESMTPS id 68si3549770pfx.404.2018.01.04.22.10.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 22:10:26 -0800 (PST)
From: "=?UTF-8?B?5aS35YiZKENhc3Bhcik=?=" <jinli.zjl@alibaba-inc.com>
Subject: [PATCH v2] mm/fadvise: discard partial page if endbyte is also EOF
Date: Fri, 05 Jan 2018 14:10:16 +0800
Message-Id: <5222da9ee20e1695eaabb69f631f200d6e6b8876.1515132470.git.jinli.zjl@alibaba-inc.com>
In-Reply-To: <1514002568-120457-1-git-send-email-shidao.ytt@alibaba-inc.com>
References: <1514002568-120457-1-git-send-email-shidao.ytt@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?B?5p2o5YuHKOaZuuW9uyk=?= <zhiche.yy@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, green@linuxhacker.ru, =?UTF-8?B?5aS35YiZKENhc3Bhcik=?= <jinli.zjl@alibaba-inc.com>, =?UTF-8?B?5Y2B5YiA?= <shidao.ytt@alibaba-inc.com>

From: shidao.ytt <shidao.ytt@alibaba-inc.com>

During our recent testing with fadvise(FADV_DONTNEED), we find that if
given offset/length is not page-aligned, the last page will not be
discarded. The tool we use is vmtouch (https://hoytech.com/vmtouch/), we
map a 10KB-sized file into memory and then try to run this tool to evict
the whole file mapping, but the last single page always remains staying
in the memory:

$./vmtouch -e test_10K
           Files: 1
     Directories: 0
   Evicted Pages: 3 (12K)
         Elapsed: 2.1e-05 seconds

$./vmtouch test_10K
           Files: 1
     Directories: 0
  Resident Pages: 1/3  4K/12K  33.3%
         Elapsed: 5.5e-05 seconds

However when we test with an older kernel, say 3.10, this problem is
gone. So we wonder if this is a regression:

$./vmtouch -e test_10K
           Files: 1
     Directories: 0
   Evicted Pages: 3 (12K)
         Elapsed: 8.2e-05 seconds

$./vmtouch test_10K
           Files: 1
     Directories: 0
  Resident Pages: 0/3  0/12K  0%  <-- partial page also discarded
         Elapsed: 5e-05 seconds

After digging a little bit into this problem, we find it seems not a
regression. Not discarding partial page is likely to be on purpose
according to commit 441c228f817f7 ("mm: fadvise: document the
fadvise(FADV_DONTNEED) behaviour for partial pages") written by
Mel Gorman. He explained why partial pages should be preserved instead
of being discarded when using fadvise(FADV_DONTNEED). However, the
interesting part is that the actual code did NOT work as the same as it
was described, the partial page was still discarded anyway, due to a
calculation mistake of `end_index' passed to invalidate_mapping_pages().
This mistake has not been fixed until recently, that's why we fail to
reproduce our problem in old kernels. The fix is done in commit
18aba41cbf ("mm/fadvise.c: do not discard partial pages with
POSIX_FADV_DONTNEED") by Oleg Drokin.

Back to the original testing, our problem becomes that there is a
speical case that, if the page-unaligned `endbyte' is also the end
of file, it is not necessary at all to preserve the last partial page,
as we all know no one else will use the rest of it. It should be safe
enough if we just discard the whole page. So we add an EOF check in this
patch.

We also find a poosbile real world issue in mainline kernel. Assume such
scenario: A userspace backup application want to backup a huge amount of
small files (<4k) at once, the developer might (I guess) want to use
fadvise(FADV_DONTNEED) to save memory. However, FADV_DONTNEED won't
really happen since the only page mapped is a partial page, and kernel
will preserve it. Our patch also fixes this problem, since we know the
endbyte is EOF, so we discard it.

Here is a simple reproducer to reproduce and verify each scenario we
described above:

  test_fadvise.c
  ==============================
  #include <sys/mman.h>
  #include <sys/stat.h>
  #include <fcntl.h>
  #include <stdlib.h>
  #include <string.h>
  #include <stdio.h>
  #include <unistd.h>

  int main(int argc, char **argv)
  {
  	int i, fd, ret, len;
  	struct stat buf;
  	void *addr;
  	unsigned char *vec;
  	char *strbuf;
  	ssize_t pagesize = getpagesize();
  	ssize_t filesize;

  	fd = open(argv[1], O_RDWR|O_CREAT, S_IRUSR|S_IWUSR);
  	if (fd < 0)
  		return -1;
  	filesize = strtoul(argv[2], NULL, 10);

  	strbuf = malloc(filesize);
  	memset(strbuf, 42, filesize);
  	write(fd, strbuf, filesize);
  	free(strbuf);
  	fsync(fd);

  	len = (filesize + pagesize - 1) / pagesize;
  	printf("length of pages: %d\n", len);

  	addr = mmap(NULL, filesize, PROT_READ, MAP_SHARED, fd, 0);
  	if (addr == MAP_FAILED)
  		return -1;

  	ret = posix_fadvise(fd, 0, filesize, POSIX_FADV_DONTNEED);
  	if (ret < 0)
  		return -1;

  	vec = malloc(len);
  	ret = mincore(addr, filesize, (void *)vec);
  	if (ret < 0)
  		return -1;

  	for (i = 0; i < len; i++)
  		printf("pages[%d]: %x\n", i, vec[i] & 0x1);

  	free(vec);
  	close(fd);

  	return 0;
  }
  ==============================

Test 1: running on kernel with commit 18aba41cbf reverted:

[root@caspar ~]# uname -r
4.15.0-rc6.revert+
[root@caspar ~]# ./test_fadvise file1 1024
length of pages: 1
pages[0]: 0    # <-- partial page discarded
[root@caspar ~]# ./test_fadvise file2 8192
length of pages: 2
pages[0]: 0
pages[1]: 0
[root@caspar ~]# ./test_fadvise file3 10240
length of pages: 3
pages[0]: 0
pages[1]: 0
pages[2]: 0    # <-- partial page discarded

Test 2: running on mainline kernel:

[root@caspar ~]# uname -r
4.15.0-rc6+
[root@caspar ~]# ./test_fadvise test1 1024
length of pages: 1
pages[0]: 1    # <-- partial and the only page not discarded
[root@caspar ~]# ./test_fadvise test2 8192
length of pages: 2
pages[0]: 0
pages[1]: 0
[root@caspar ~]# ./test_fadvise test3 10240
length of pages: 3
pages[0]: 0
pages[1]: 0
pages[2]: 1    # <-- partial page not discarded

Test 3: running on kernel with this patch:

[root@caspar ~]# uname -r
4.15.0-rc6.patched+
[root@caspar ~]# ./test_fadvise test1 1024
length of pages: 1
pages[0]: 0    # <-- partial page and EOF, discarded
[root@caspar ~]# ./test_fadvise test2 8192
length of pages: 2
pages[0]: 0
pages[1]: 0
[root@caspar ~]# ./test_fadvise test3 10240
length of pages: 3
pages[0]: 0
pages[1]: 0
pages[2]: 0    # <-- partial page and EOF, discarded

Signed-off-by: shidao.ytt <shidao.ytt@alibaba-inc.com>
Signed-off-by: Caspar Zhang <jinli.zjl@alibaba-inc.com>
Reviewed-by: Oliver Yang <zhiche.yy@alibaba-inc.com>
---
v1->v2: added comments, added testcase and discussion backgrounds to
        commit msg.

 mm/fadvise.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/fadvise.c b/mm/fadvise.c
index ec70d6e4b86d..de00da7c03cb 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -127,7 +127,16 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 		 */
 		start_index = (offset+(PAGE_SIZE-1)) >> PAGE_SHIFT;
 		end_index = (endbyte >> PAGE_SHIFT);
-		if ((endbyte & ~PAGE_MASK) != ~PAGE_MASK) {
+		/*
+		 * page at end_index will be inclusively discarded according
+		 * to invalidate_mapping_pages() implementation, thus, minus
+		 * end_index by 1 means we would skip the last page.
+		 * Yet, if endbyte is page-aligned, or it is at the end of
+		 * file, we should not skip, discarding the last page is just
+		 * safe enough.
+		 */
+		if ((endbyte & ~PAGE_MASK) != ~PAGE_MASK &&
+				endbyte != inode->i_size - 1) {
 			/* First page is tricky as 0 - 1 = -1, but pgoff_t
 			 * is unsigned, so the end_index >= start_index
 			 * check below would be true and we'll discard the whole
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
