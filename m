Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id A89986B006E
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 19:23:57 -0400 (EDT)
Received: by igcxg11 with SMTP id xg11so6364376igc.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 16:23:57 -0700 (PDT)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com. [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id v2si211244igs.21.2015.03.26.16.23.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 16:23:57 -0700 (PDT)
Received: by ieclw3 with SMTP id lw3so58978350iec.2
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 16:23:57 -0700 (PDT)
Date: Thu, 26 Mar 2015 16:23:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/2] mm, selftests: test return value of munmap for MAP_HUGETLB
 memory
In-Reply-To: <alpine.DEB.2.10.1503261621570.20009@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1503261623280.20009@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503261621570.20009@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, Davide Libenzi <davidel@xmailserver.org>, Luiz Capitulino <lcapitulino@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-doc@vger.kernel.org

When MAP_HUGETLB memory is unmapped, the length must be hugepage aligned,
otherwise it fails with -EINVAL.

All tests currently behave correctly, but it's better to explcitly test
the return value for completeness and document the requirement,
especially if users copy map_hugetlb.c as a sample implementation.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 tools/testing/selftests/powerpc/mm/hugetlb_vs_thp_test.c | 8 ++++++--
 tools/testing/selftests/vm/hugetlbfstest.c               | 4 +++-
 tools/testing/selftests/vm/map_hugetlb.c                 | 6 +++++-
 3 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/tools/testing/selftests/powerpc/mm/hugetlb_vs_thp_test.c b/tools/testing/selftests/powerpc/mm/hugetlb_vs_thp_test.c
--- a/tools/testing/selftests/powerpc/mm/hugetlb_vs_thp_test.c
+++ b/tools/testing/selftests/powerpc/mm/hugetlb_vs_thp_test.c
@@ -21,9 +21,13 @@ static int test_body(void)
 		 * Typically the mmap will fail because no huge pages are
 		 * allocated on the system. But if there are huge pages
 		 * allocated the mmap will succeed. That's fine too, we just
-		 * munmap here before continuing.
+		 * munmap here before continuing.  munmap() length of
+		 * MAP_HUGETLB memory must be hugepage aligned.
 		 */
-		munmap(addr, SIZE);
+		if (munmap(addr, SIZE)) {
+			perror("munmap");
+			return 1;
+		}
 	}
 
 	p = mmap(addr, SIZE, PROT_READ | PROT_WRITE,
diff --git a/tools/testing/selftests/vm/hugetlbfstest.c b/tools/testing/selftests/vm/hugetlbfstest.c
--- a/tools/testing/selftests/vm/hugetlbfstest.c
+++ b/tools/testing/selftests/vm/hugetlbfstest.c
@@ -34,6 +34,7 @@ static void do_mmap(int fd, int extra_flags, int unmap)
 	int *p;
 	int flags = MAP_PRIVATE | MAP_POPULATE | extra_flags;
 	u64 before, after;
+	int ret;
 
 	before = read_rss();
 	p = mmap(NULL, length, PROT_READ | PROT_WRITE, flags, fd, 0);
@@ -44,7 +45,8 @@ static void do_mmap(int fd, int extra_flags, int unmap)
 			!"rss didn't grow as expected");
 	if (!unmap)
 		return;
-	munmap(p, length);
+	ret = munmap(p, length);
+	assert(!ret || !"munmap returned an unexpected error");
 	after = read_rss();
 	assert(llabs(after - before) < 0x40000 ||
 			!"rss didn't shrink as expected");
diff --git a/tools/testing/selftests/vm/map_hugetlb.c b/tools/testing/selftests/vm/map_hugetlb.c
--- a/tools/testing/selftests/vm/map_hugetlb.c
+++ b/tools/testing/selftests/vm/map_hugetlb.c
@@ -73,7 +73,11 @@ int main(void)
 	write_bytes(addr);
 	ret = read_bytes(addr);
 
-	munmap(addr, LENGTH);
+	/* munmap() length of MAP_HUGETLB memory must be hugepage aligned */
+	if (munmap(addr, LENGTH)) {
+		perror("munmap");
+		exit(1);
+	}
 
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
