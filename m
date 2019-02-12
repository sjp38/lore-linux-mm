Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3649DC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:01:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E426C21773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:01:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E426C21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 930188E01AF; Mon, 11 Feb 2019 22:01:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E0FD8E000E; Mon, 11 Feb 2019 22:01:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7805A8E01AF; Mon, 11 Feb 2019 22:01:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 492128E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 22:01:29 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id n197so14472753qke.0
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:01:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=FAHDI2rhdj9FPEM82Nf5d1uwaIql7JfBDm123fs4fBA=;
        b=sOEFtfAvoNdg+aak2WoEuTedxhL6DzMqzPrXUSDRNVN1L9aGj4u1A/IFdQ+zmn3Y5P
         ooP22nhPC2j+YXuqzpxvot8Fc8y+UVg5wxTi6Pf2WVXm/Zbfqy7LcQsXTwemHdBk1Pf4
         5itQQe/RUI1uQXbpVargwEMJBU1zE9cQ6hw/h07ZZcAjk/Jte+S419IqNBYWhjUhOu9N
         o/PEkUaX70JHR+OGKJl6USXGn+eaEHvUDkfdDciaaDazeq9hR4fj/xdUTdKWajDV2xXU
         FWSn7UyUL88U9R1hRsuxX8GIM8Qv6zgqG/SegYmJrxhOzUZbaJF56EeyfgGzYOsJwXy1
         sy/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZPUsI+RMn7WiyRGzukwqmdoX7AjQCA6DV2BRPEwj6NVuAdajpO
	mtbHVnmwTdNxU9uK61TKq/NyS0tZJAbzv+4BvIrQP3Li2MBIyInxbELWzONagMzQElc2CAEhHtS
	tNRdpy5P+5ylSkUQ1jtiy3Xi5Vfpi484GFho6PmTH0CHfqQAkVAS4hUswEwd7Una0JA==
X-Received: by 2002:ac8:e43:: with SMTP id j3mr1110922qti.239.1549940489045;
        Mon, 11 Feb 2019 19:01:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYyupaSSkaaEJw5vtoKzdvd9j7aEwTZbH9t4j7RTkEipBTpVJG4QRh/R5oE1AhoPK6JAGwf
X-Received: by 2002:ac8:e43:: with SMTP id j3mr1110890qti.239.1549940488398;
        Mon, 11 Feb 2019 19:01:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940488; cv=none;
        d=google.com; s=arc-20160816;
        b=R9sbN1vKeB+uQ0g73BNcCQkooEw5tVpTHe90Xg/R+Ne1/aus/60hx7DC7JkXZJcWJR
         IhF2Kpqs6wWb3XuzSHwcM0Vg9ewck8lXgXkAIHsUtmMFsQqhIIunNLSVV/rXyY9zl1fm
         pTgaEZwYBAv8mVOXz7Ne+sJDhqyC2FpAaCAPSV2biAxaenX0uayv0pVlqQL3tebOsO5M
         Yw+eYseGykkJelpMoPJ42kXhcUNc/ZTQ/Mr0jslndKerf/D8xVP+T23oE9XeEh6aGHci
         hpiBg+ReFRJGsWA5HThWXAEDuxfNN6Vv5/6L1gA5d5XWmK7wN+LXwLC0WPThPdrYou8U
         9RMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=FAHDI2rhdj9FPEM82Nf5d1uwaIql7JfBDm123fs4fBA=;
        b=ShHePSTbvQs5G2Z2Z/uJDqcbyMijJE5eYuy5SOws+rBUCmflfSjY0VIQhv1E8HXqme
         bNtGdDvLQ4hXr/f7TBZyTqDatvPqtePKaVyody9oFfYSKp9Xx+4LfivUspS7MojjmMHy
         e2X3Lznw4/RpYgrYcxEkGQ535lqiR3kRf2nRMx4nNuwVFNLoTE0EDBJq5SMJAX/uEcDT
         6Rfkm77EZSU+WkycKBIk8ipMZh4b1ULBS+P8kVw13+O7JUKogfkIDOEnqIcCKEgMF0BC
         QMy7lCB5S4wOxN6NSrjd8fCkYKk8D/R7AAqTlle8C1Xmy9pMWeAt9V1kFrm/VFf/9t0D
         +gIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z14si1511753qtn.132.2019.02.11.19.01.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 19:01:28 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7576474F12;
	Tue, 12 Feb 2019 03:01:27 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B56776443D;
	Tue, 12 Feb 2019 03:01:15 +0000 (UTC)
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v2 25/26] userfaultfd: selftests: refactor statistics
Date: Tue, 12 Feb 2019 10:56:31 +0800
Message-Id: <20190212025632.28946-26-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 12 Feb 2019 03:01:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Introduce uffd_stats structure for statistics of the self test, at the
same time refactor the code to always pass in the uffd_stats for either
read() or poll() typed fault handling threads instead of using two
different ways to return the statistic results.  No functional change.

With the new structure, it's very easy to introduce new statistics.

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 tools/testing/selftests/vm/userfaultfd.c | 76 +++++++++++++++---------
 1 file changed, 49 insertions(+), 27 deletions(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index 5d1db824f73a..e5d12c209e09 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -88,6 +88,12 @@ static char *area_src, *area_src_alias, *area_dst, *area_dst_alias;
 static char *zeropage;
 pthread_attr_t attr;
 
+/* Userfaultfd test statistics */
+struct uffd_stats {
+	int cpu;
+	unsigned long missing_faults;
+};
+
 /* pthread_mutex_t starts at page offset 0 */
 #define area_mutex(___area, ___nr)					\
 	((pthread_mutex_t *) ((___area) + (___nr)*page_size))
@@ -127,6 +133,17 @@ static void usage(void)
 	exit(1);
 }
 
+static void uffd_stats_reset(struct uffd_stats *uffd_stats,
+			     unsigned long n_cpus)
+{
+	int i;
+
+	for (i = 0; i < n_cpus; i++) {
+		uffd_stats[i].cpu = i;
+		uffd_stats[i].missing_faults = 0;
+	}
+}
+
 static int anon_release_pages(char *rel_area)
 {
 	int ret = 0;
@@ -469,8 +486,8 @@ static int uffd_read_msg(int ufd, struct uffd_msg *msg)
 	return 0;
 }
 
-/* Return 1 if page fault handled by us; otherwise 0 */
-static int uffd_handle_page_fault(struct uffd_msg *msg)
+static void uffd_handle_page_fault(struct uffd_msg *msg,
+				   struct uffd_stats *stats)
 {
 	unsigned long offset;
 
@@ -485,18 +502,19 @@ static int uffd_handle_page_fault(struct uffd_msg *msg)
 	offset = (char *)(unsigned long)msg->arg.pagefault.address - area_dst;
 	offset &= ~(page_size-1);
 
-	return copy_page(uffd, offset);
+	if (copy_page(uffd, offset))
+		stats->missing_faults++;
 }
 
 static void *uffd_poll_thread(void *arg)
 {
-	unsigned long cpu = (unsigned long) arg;
+	struct uffd_stats *stats = (struct uffd_stats *)arg;
+	unsigned long cpu = stats->cpu;
 	struct pollfd pollfd[2];
 	struct uffd_msg msg;
 	struct uffdio_register uffd_reg;
 	int ret;
 	char tmp_chr;
-	unsigned long userfaults = 0;
 
 	pollfd[0].fd = uffd;
 	pollfd[0].events = POLLIN;
@@ -526,7 +544,7 @@ static void *uffd_poll_thread(void *arg)
 				msg.event), exit(1);
 			break;
 		case UFFD_EVENT_PAGEFAULT:
-			userfaults += uffd_handle_page_fault(&msg);
+			uffd_handle_page_fault(&msg, stats);
 			break;
 		case UFFD_EVENT_FORK:
 			close(uffd);
@@ -545,28 +563,27 @@ static void *uffd_poll_thread(void *arg)
 			break;
 		}
 	}
-	return (void *)userfaults;
+
+	return NULL;
 }
 
 pthread_mutex_t uffd_read_mutex = PTHREAD_MUTEX_INITIALIZER;
 
 static void *uffd_read_thread(void *arg)
 {
-	unsigned long *this_cpu_userfaults;
+	struct uffd_stats *stats = (struct uffd_stats *)arg;
 	struct uffd_msg msg;
 
-	this_cpu_userfaults = (unsigned long *) arg;
-	*this_cpu_userfaults = 0;
-
 	pthread_mutex_unlock(&uffd_read_mutex);
 	/* from here cancellation is ok */
 
 	for (;;) {
 		if (uffd_read_msg(uffd, &msg))
 			continue;
-		(*this_cpu_userfaults) += uffd_handle_page_fault(&msg);
+		uffd_handle_page_fault(&msg, stats);
 	}
-	return (void *)NULL;
+
+	return NULL;
 }
 
 static void *background_thread(void *arg)
@@ -582,13 +599,12 @@ static void *background_thread(void *arg)
 	return NULL;
 }
 
-static int stress(unsigned long *userfaults)
+static int stress(struct uffd_stats *uffd_stats)
 {
 	unsigned long cpu;
 	pthread_t locking_threads[nr_cpus];
 	pthread_t uffd_threads[nr_cpus];
 	pthread_t background_threads[nr_cpus];
-	void **_userfaults = (void **) userfaults;
 
 	finished = 0;
 	for (cpu = 0; cpu < nr_cpus; cpu++) {
@@ -597,12 +613,13 @@ static int stress(unsigned long *userfaults)
 			return 1;
 		if (bounces & BOUNCE_POLL) {
 			if (pthread_create(&uffd_threads[cpu], &attr,
-					   uffd_poll_thread, (void *)cpu))
+					   uffd_poll_thread,
+					   (void *)&uffd_stats[cpu]))
 				return 1;
 		} else {
 			if (pthread_create(&uffd_threads[cpu], &attr,
 					   uffd_read_thread,
-					   &_userfaults[cpu]))
+					   (void *)&uffd_stats[cpu]))
 				return 1;
 			pthread_mutex_lock(&uffd_read_mutex);
 		}
@@ -639,7 +656,8 @@ static int stress(unsigned long *userfaults)
 				fprintf(stderr, "pipefd write error\n");
 				return 1;
 			}
-			if (pthread_join(uffd_threads[cpu], &_userfaults[cpu]))
+			if (pthread_join(uffd_threads[cpu],
+					 (void *)&uffd_stats[cpu]))
 				return 1;
 		} else {
 			if (pthread_cancel(uffd_threads[cpu]))
@@ -910,11 +928,11 @@ static int userfaultfd_events_test(void)
 {
 	struct uffdio_register uffdio_register;
 	unsigned long expected_ioctls;
-	unsigned long userfaults;
 	pthread_t uffd_mon;
 	int err, features;
 	pid_t pid;
 	char c;
+	struct uffd_stats stats = { 0 };
 
 	printf("testing events (fork, remap, remove): ");
 	fflush(stdout);
@@ -941,7 +959,7 @@ static int userfaultfd_events_test(void)
 			"unexpected missing ioctl for anon memory\n"),
 			exit(1);
 
-	if (pthread_create(&uffd_mon, &attr, uffd_poll_thread, NULL))
+	if (pthread_create(&uffd_mon, &attr, uffd_poll_thread, &stats))
 		perror("uffd_poll_thread create"), exit(1);
 
 	pid = fork();
@@ -957,13 +975,13 @@ static int userfaultfd_events_test(void)
 
 	if (write(pipefd[1], &c, sizeof(c)) != sizeof(c))
 		perror("pipe write"), exit(1);
-	if (pthread_join(uffd_mon, (void **)&userfaults))
+	if (pthread_join(uffd_mon, NULL))
 		return 1;
 
 	close(uffd);
-	printf("userfaults: %ld\n", userfaults);
+	printf("userfaults: %ld\n", stats.missing_faults);
 
-	return userfaults != nr_pages;
+	return stats.missing_faults != nr_pages;
 }
 
 static int userfaultfd_sig_test(void)
@@ -975,6 +993,7 @@ static int userfaultfd_sig_test(void)
 	int err, features;
 	pid_t pid;
 	char c;
+	struct uffd_stats stats = { 0 };
 
 	printf("testing signal delivery: ");
 	fflush(stdout);
@@ -1006,7 +1025,7 @@ static int userfaultfd_sig_test(void)
 	if (uffd_test_ops->release_pages(area_dst))
 		return 1;
 
-	if (pthread_create(&uffd_mon, &attr, uffd_poll_thread, NULL))
+	if (pthread_create(&uffd_mon, &attr, uffd_poll_thread, &stats))
 		perror("uffd_poll_thread create"), exit(1);
 
 	pid = fork();
@@ -1032,6 +1051,7 @@ static int userfaultfd_sig_test(void)
 	close(uffd);
 	return userfaults != 0;
 }
+
 static int userfaultfd_stress(void)
 {
 	void *area;
@@ -1040,7 +1060,7 @@ static int userfaultfd_stress(void)
 	struct uffdio_register uffdio_register;
 	unsigned long cpu;
 	int err;
-	unsigned long userfaults[nr_cpus];
+	struct uffd_stats uffd_stats[nr_cpus];
 
 	uffd_test_ops->allocate_area((void **)&area_src);
 	if (!area_src)
@@ -1169,8 +1189,10 @@ static int userfaultfd_stress(void)
 		if (uffd_test_ops->release_pages(area_dst))
 			return 1;
 
+		uffd_stats_reset(uffd_stats, nr_cpus);
+
 		/* bounce pass */
-		if (stress(userfaults))
+		if (stress(uffd_stats))
 			return 1;
 
 		/* unregister */
@@ -1213,7 +1235,7 @@ static int userfaultfd_stress(void)
 
 		printf("userfaults:");
 		for (cpu = 0; cpu < nr_cpus; cpu++)
-			printf(" %lu", userfaults[cpu]);
+			printf(" %lu", uffd_stats[cpu].missing_faults);
 		printf("\n");
 	}
 
-- 
2.17.1

