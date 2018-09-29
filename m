Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FDDE8E0001
	for <linux-mm@kvack.org>; Sat, 29 Sep 2018 04:43:31 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id p52-v6so8099740qtf.9
        for <linux-mm@kvack.org>; Sat, 29 Sep 2018 01:43:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b3-v6si2106869qvo.193.2018.09.29.01.43.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Sep 2018 01:43:30 -0700 (PDT)
From: Peter Xu <peterx@redhat.com>
Subject: [PATCH 2/3] userfaultfd: selftest: generalize read and poll
Date: Sat, 29 Sep 2018 16:43:10 +0800
Message-Id: <20180929084311.15600-3-peterx@redhat.com>
In-Reply-To: <20180929084311.15600-1-peterx@redhat.com>
References: <20180929084311.15600-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Shuah Khan <shuah@kernel.org>, Jerome Glisse <jglisse@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, peterx@redhat.com, linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kselftest@vger.kernel.org, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

We do very similar things in read and poll modes, but we're copying the
codes around.  Share the codes properly on reading the message and
handling the page fault to make the code cleaner.  Meanwhile this solves
previous mismatch of behaviors between the two modes on that the old
code:

- did not check EAGAIN case in read() mode
- ignored BOUNCE_VERIFY check in read() mode

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 tools/testing/selftests/vm/userfaultfd.c | 76 +++++++++++++-----------
 1 file changed, 42 insertions(+), 34 deletions(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index 2a84adaf8cf8..f79706f13ce7 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -449,6 +449,42 @@ static int copy_page(int ufd, unsigned long offset)
 	return __copy_page(ufd, offset, false);
 }
 
+static int uffd_read_msg(int ufd, struct uffd_msg *msg)
+{
+	int ret = read(uffd, msg, sizeof(*msg));
+
+	if (ret != sizeof(*msg)) {
+		if (ret < 0)
+			if (errno == EAGAIN)
+				return 1;
+			else
+				perror("blocking read error"), exit(1);
+		else
+				fprintf(stderr, "short read\n"), exit(1);
+	}
+
+	return 0;
+}
+
+/* Return 1 if page fault handled by us; otherwise 0 */
+static int uffd_handle_page_fault(struct uffd_msg *msg)
+{
+	unsigned long offset;
+
+	if (msg->event != UFFD_EVENT_PAGEFAULT)
+		fprintf(stderr, "unexpected msg event %u\n",
+			msg->event), exit(1);
+
+	if (bounces & BOUNCE_VERIFY &&
+	    msg->arg.pagefault.flags & UFFD_PAGEFAULT_FLAG_WRITE)
+		fprintf(stderr, "unexpected write fault\n"), exit(1);
+
+	offset = (char *)(unsigned long)msg->arg.pagefault.address - area_dst;
+	offset &= ~(page_size-1);
+
+	return copy_page(uffd, offset);
+}
+
 static void *uffd_poll_thread(void *arg)
 {
 	unsigned long cpu = (unsigned long) arg;
@@ -456,7 +492,6 @@ static void *uffd_poll_thread(void *arg)
 	struct uffd_msg msg;
 	struct uffdio_register uffd_reg;
 	int ret;
-	unsigned long offset;
 	char tmp_chr;
 	unsigned long userfaults = 0;
 
@@ -480,25 +515,15 @@ static void *uffd_poll_thread(void *arg)
 		if (!(pollfd[0].revents & POLLIN))
 			fprintf(stderr, "pollfd[0].revents %d\n",
 				pollfd[0].revents), exit(1);
-		ret = read(uffd, &msg, sizeof(msg));
-		if (ret < 0) {
-			if (errno == EAGAIN)
-				continue;
-			perror("nonblocking read error"), exit(1);
-		}
+		if (uffd_read_msg(uffd, &msg))
+			continue;
 		switch (msg.event) {
 		default:
 			fprintf(stderr, "unexpected msg event %u\n",
 				msg.event), exit(1);
 			break;
 		case UFFD_EVENT_PAGEFAULT:
-			if (msg.arg.pagefault.flags & UFFD_PAGEFAULT_FLAG_WRITE)
-				fprintf(stderr, "unexpected write fault\n"), exit(1);
-			offset = (char *)(unsigned long)msg.arg.pagefault.address -
-				area_dst;
-			offset &= ~(page_size-1);
-			if (copy_page(uffd, offset))
-				userfaults++;
+			userfaults += uffd_handle_page_fault(&msg);
 			break;
 		case UFFD_EVENT_FORK:
 			close(uffd);
@@ -526,8 +551,6 @@ static void *uffd_read_thread(void *arg)
 {
 	unsigned long *this_cpu_userfaults;
 	struct uffd_msg msg;
-	unsigned long offset;
-	int ret;
 
 	this_cpu_userfaults = (unsigned long *) arg;
 	*this_cpu_userfaults = 0;
@@ -536,24 +559,9 @@ static void *uffd_read_thread(void *arg)
 	/* from here cancellation is ok */
 
 	for (;;) {
-		ret = read(uffd, &msg, sizeof(msg));
-		if (ret != sizeof(msg)) {
-			if (ret < 0)
-				perror("blocking read error"), exit(1);
-			else
-				fprintf(stderr, "short read\n"), exit(1);
-		}
-		if (msg.event != UFFD_EVENT_PAGEFAULT)
-			fprintf(stderr, "unexpected msg event %u\n",
-				msg.event), exit(1);
-		if (bounces & BOUNCE_VERIFY &&
-		    msg.arg.pagefault.flags & UFFD_PAGEFAULT_FLAG_WRITE)
-			fprintf(stderr, "unexpected write fault\n"), exit(1);
-		offset = (char *)(unsigned long)msg.arg.pagefault.address -
-			 area_dst;
-		offset &= ~(page_size-1);
-		if (copy_page(uffd, offset))
-			(*this_cpu_userfaults)++;
+		if (uffd_read_msg(uffd, &msg))
+			continue;
+		(*this_cpu_userfaults) += uffd_handle_page_fault(&msg);
 	}
 	return (void *)NULL;
 }
-- 
2.17.1
