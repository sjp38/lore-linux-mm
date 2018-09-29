Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id A508F8E0001
	for <linux-mm@kvack.org>; Sat, 29 Sep 2018 04:43:35 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id z18-v6so8335927qki.22
        for <linux-mm@kvack.org>; Sat, 29 Sep 2018 01:43:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m21-v6si1431024qtb.280.2018.09.29.01.43.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Sep 2018 01:43:34 -0700 (PDT)
From: Peter Xu <peterx@redhat.com>
Subject: [PATCH 3/3] userfaultfd: selftest: recycle lock threads first
Date: Sat, 29 Sep 2018 16:43:11 +0800
Message-Id: <20180929084311.15600-4-peterx@redhat.com>
In-Reply-To: <20180929084311.15600-1-peterx@redhat.com>
References: <20180929084311.15600-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Shuah Khan <shuah@kernel.org>, Jerome Glisse <jglisse@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, peterx@redhat.com, linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kselftest@vger.kernel.org, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

Now we recycle the uffd servicing threads earlier than the lock
threads.  It might happen that when the lock thread is still blocked at
a pthread mutex lock while the servicing thread has already quitted for
the cpu so the lock thread will be blocked forever and hang the test
program.  To fix the possible race, recycle the lock threads first.

This never happens with current missing-only tests, but when I start to
run the write-protection tests (the feature is not yet posted upstream)
it happens every time of the run possibly because in that new test we'll
need to service two page faults for each lock operation.

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 tools/testing/selftests/vm/userfaultfd.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index f79706f13ce7..a388675b15af 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -623,6 +623,12 @@ static int stress(unsigned long *userfaults)
 	if (uffd_test_ops->release_pages(area_src))
 		return 1;
 
+
+	finished = 1;
+	for (cpu = 0; cpu < nr_cpus; cpu++)
+		if (pthread_join(locking_threads[cpu], NULL))
+			return 1;
+
 	for (cpu = 0; cpu < nr_cpus; cpu++) {
 		char c;
 		if (bounces & BOUNCE_POLL) {
@@ -640,11 +646,6 @@ static int stress(unsigned long *userfaults)
 		}
 	}
 
-	finished = 1;
-	for (cpu = 0; cpu < nr_cpus; cpu++)
-		if (pthread_join(locking_threads[cpu], NULL))
-			return 1;
-
 	return 0;
 }
 
-- 
2.17.1
