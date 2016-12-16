Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D42D6B0276
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:30 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id b123so21190366itb.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c91si6190344ioj.90.2016.12.16.06.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:29 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 41/42] userfaultfd: selftest: test UFFDIO_ZEROPAGE on all memory types
Date: Fri, 16 Dec 2016 15:48:20 +0100
Message-Id: <20161216144821.5183-42-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

This will verify -EINVAL is returned with hugetlbfs/shmem and it'll do
a functional test of UFFDIO_ZEROPAGE on anonymous memory.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 tools/testing/selftests/vm/userfaultfd.c | 82 +++++++++++++++++++++++++++++++-
 1 file changed, 81 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index 71b4d82..5a840a6 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -625,6 +625,86 @@ static int faulting_process(void)
 	return 0;
 }
 
+static int uffdio_zeropage(int ufd, unsigned long offset)
+{
+	struct uffdio_zeropage uffdio_zeropage;
+	int ret;
+	unsigned long has_zeropage = EXPECTED_IOCTLS & (1 << _UFFDIO_ZEROPAGE);
+
+	if (offset >= nr_pages * page_size)
+		fprintf(stderr, "unexpected offset %lu\n",
+			offset), exit(1);
+	uffdio_zeropage.range.start = (unsigned long) area_dst + offset;
+	uffdio_zeropage.range.len = page_size;
+	uffdio_zeropage.mode = 0;
+	ret = ioctl(ufd, UFFDIO_ZEROPAGE, &uffdio_zeropage);
+	if (ret) {
+		/* real retval in ufdio_zeropage.zeropage */
+		if (has_zeropage) {
+			if (uffdio_zeropage.zeropage == -EEXIST)
+				fprintf(stderr, "UFFDIO_ZEROPAGE -EEXIST\n"),
+					exit(1);
+			else
+				fprintf(stderr, "UFFDIO_ZEROPAGE error %Ld\n",
+					uffdio_zeropage.zeropage), exit(1);
+		} else {
+			if (uffdio_zeropage.zeropage != -EINVAL)
+				fprintf(stderr,
+					"UFFDIO_ZEROPAGE not -EINVAL %Ld\n",
+					uffdio_zeropage.zeropage), exit(1);
+		}
+	} else if (has_zeropage) {
+		if (uffdio_zeropage.zeropage != page_size) {
+			fprintf(stderr, "UFFDIO_ZEROPAGE unexpected %Ld\n",
+				uffdio_zeropage.zeropage), exit(1);
+		} else
+			return 1;
+	} else {
+		fprintf(stderr,
+			"UFFDIO_ZEROPAGE succeeded %Ld\n",
+			uffdio_zeropage.zeropage), exit(1);
+	}
+
+	return 0;
+}
+
+/* exercise UFFDIO_ZEROPAGE */
+static int userfaultfd_zeropage_test(void)
+{
+	struct uffdio_register uffdio_register;
+	unsigned long expected_ioctls;
+
+	printf("testing UFFDIO_ZEROPAGE: ");
+	fflush(stdout);
+
+	if (release_pages(area_dst))
+		return 1;
+
+	if (userfaultfd_open(0) < 0)
+		return 1;
+	uffdio_register.range.start = (unsigned long) area_dst;
+	uffdio_register.range.len = nr_pages * page_size;
+	uffdio_register.mode = UFFDIO_REGISTER_MODE_MISSING;
+	if (ioctl(uffd, UFFDIO_REGISTER, &uffdio_register))
+		fprintf(stderr, "register failure\n"), exit(1);
+
+	expected_ioctls = EXPECTED_IOCTLS;
+	if ((uffdio_register.ioctls & expected_ioctls) !=
+	    expected_ioctls)
+		fprintf(stderr,
+			"unexpected missing ioctl for anon memory\n"),
+			exit(1);
+
+	if (uffdio_zeropage(uffd, 0)) {
+		if (my_bcmp(area_dst, zeropage, page_size))
+			fprintf(stderr, "zeropage is not zero\n"), exit(1);
+	}
+
+	close(uffd);
+	printf("done.\n");
+	return 0;
+}
+
 static int userfaultfd_events_test(void)
 {
 	struct uffdio_register uffdio_register;
@@ -853,7 +933,7 @@ static int userfaultfd_stress(void)
 		return err;
 
 	close(uffd);
-	return userfaultfd_events_test();
+	return userfaultfd_zeropage_test() || userfaultfd_events_test();
 }
 
 #ifndef HUGETLB_TEST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
