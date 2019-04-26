Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12499C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:56:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCBA6206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:56:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCBA6206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BB516B028E; Fri, 26 Apr 2019 00:56:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56B9C6B0290; Fri, 26 Apr 2019 00:56:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45B216B0291; Fri, 26 Apr 2019 00:56:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 24A276B028E
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:56:07 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id c44so1900034qtb.9
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:56:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=MIozerEVlbsC7Eks2DH/IrUUfmnGE+cAmIg6z0gEZVg=;
        b=spgJz8hk+vH9eRx4RVav0S9HZ2EmCoa+VYXHQXwGQKAXpiHEMxd6at3UA8boDeRlI7
         Lf0ELzCdfk81yKkqbuTcsQqleI0BbiUpGTcZfZFXFxEezKkW/Ix+CzJo5ZlDshiWtdjt
         DlX60i+IMqM8LHcTTFUOJhInD/NeR2WUaV58loe11Ebw3qqDUEYsmC+lo6QPPDtxokwh
         vkCQsw3qE7928SeyjTo9UBKHfQwaA+YeusygoH0Q2Ab+ZUCHaW/nT819yTazf4cELasv
         NM4mH73HoJCYa5K/Zy+2QBizaUdu9QUcgnm1Xgk6uWrKjpTbhS52+yvCzGDK8DqErZVO
         VXrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUkDZspZkzwIOeaVyE9QzWeAj6o3AyMwCdvmUvjR5h9q/eiLpn1
	B7INOpEwyL8C3RCzg3+ufCli8QAcce7/KZdzNEHNmsyz3D8yQCS68gmFsPfKKTKwTdZKbTvpyom
	Dwo/vnNnwVl49bdEQUmxJGOknLKX7iwv0DUReneUJORD13GfcF1QD14qmeMB0gOblXg==
X-Received: by 2002:a37:ef13:: with SMTP id j19mr13614794qkk.264.1556254566883;
        Thu, 25 Apr 2019 21:56:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzyNaQt3gzc0sAr47/s8YsYpBus0xPkMqCac1wEQf8G5cWntTygNZbAimUZQbZQjgy1Djom
X-Received: by 2002:a37:ef13:: with SMTP id j19mr13614755qkk.264.1556254565835;
        Thu, 25 Apr 2019 21:56:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254565; cv=none;
        d=google.com; s=arc-20160816;
        b=I5V1VLkNapF7WWqOVvmvRLuOvCk5JuYKJa5ZJbznNfIlITSbKxCtX6pnmvXzQe5leT
         Ec1nUWdtXV3s7CY+nNCOAPRtFXyOXFa5ydlHhcS1W0VkN7QZ9K5q2NcKQ5prchGnqfJD
         paEAdXJ3bn/AzklwZ1ZiIDYTE0DbaUJmqwfKszCxV5EvVx4KiHkCmqebLTzWcL7DhIHe
         EJYZ3PmfAcDsX9jbuUdAMH7jW2PB2FVtp0FNN7VE9sRG/+/au4Xp9m0fzYqSdSeShFJp
         5FPvwPrM0cW6iveK4OAYTiSFRDyoA2RZZ7W27Om4kC3OYv8nw0Fj3M/ZsIm69jJKBdwo
         f05Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=MIozerEVlbsC7Eks2DH/IrUUfmnGE+cAmIg6z0gEZVg=;
        b=tWgx/1rXwS8KkQzKSryXb3hosYw0Kw4XLunXucwtlWnFU9Pw17vVgekv5wKsOZoJmS
         65l6kC0umf2MyY34+GJAdonOItmZWhcHhILW4CTmL5fbA359OtxyG4EXk0GfAM6t1xtE
         FKIYjRw8bY3mFOh6BSEP6tnmdqkTkwlg+gvRxJjKXrtj/xVZL6b/lgqhvp398Oi85bUK
         p39JOK4c8I2zlyr6v3cvdbIAEDGmpVkjcTT4/Y8cpxX9HdpElMbkwnmbQ28obrML+xNX
         PjGCZNmTpvLUhWDv3QSKRwumiFUndfFKcaDqdWlovmbaJtgSE473o9DTk+YWLC/06m9v
         K0oQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y18si1858338qtj.397.2019.04.25.21.56.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:56:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id ED3EE3082B4D;
	Fri, 26 Apr 2019 04:56:04 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5784C17B21;
	Fri, 26 Apr 2019 04:55:59 +0000 (UTC)
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
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v4 27/27] userfaultfd: selftests: add write-protect test
Date: Fri, 26 Apr 2019 12:51:51 +0800
Message-Id: <20190426045151.19556-28-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Fri, 26 Apr 2019 04:56:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds uffd tests for write protection.

Instead of introducing new tests for it, let's simply squashing uffd-wp
tests into existing uffd-missing test cases.  Changes are:

(1) Bouncing tests

  We do the write-protection in two ways during the bouncing test:

  - By using UFFDIO_COPY_MODE_WP when resolving MISSING pages: then
    we'll make sure for each bounce process every single page will be
    at least fault twice: once for MISSING, once for WP.

  - By direct call UFFDIO_WRITEPROTECT on existing faulted memories:
    To further torture the explicit page protection procedures of
    uffd-wp, we split each bounce procedure into two halves (in the
    background thread): the first half will be MISSING+WP for each
    page as explained above.  After the first half, we write protect
    the faulted region in the background thread to make sure at least
    half of the pages will be write protected again which is the first
    half to test the new UFFDIO_WRITEPROTECT call.  Then we continue
    with the 2nd half, which will contain both MISSING and WP faulting
    tests for the 2nd half and WP-only faults from the 1st half.

(2) Event/Signal test

  Mostly previous tests but will do MISSING+WP for each page.  For
  sigbus-mode test we'll need to provide standalone path to handle the
  write protection faults.

For all tests, do statistics as well for uffd-wp pages.

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 tools/testing/selftests/vm/userfaultfd.c | 157 +++++++++++++++++++----
 1 file changed, 133 insertions(+), 24 deletions(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index e5d12c209e09..bf1e10db72f5 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -56,6 +56,7 @@
 #include <linux/userfaultfd.h>
 #include <setjmp.h>
 #include <stdbool.h>
+#include <assert.h>
 
 #include "../kselftest.h"
 
@@ -78,6 +79,8 @@ static int test_type;
 #define ALARM_INTERVAL_SECS 10
 static volatile bool test_uffdio_copy_eexist = true;
 static volatile bool test_uffdio_zeropage_eexist = true;
+/* Whether to test uffd write-protection */
+static bool test_uffdio_wp = false;
 
 static bool map_shared;
 static int huge_fd;
@@ -92,6 +95,7 @@ pthread_attr_t attr;
 struct uffd_stats {
 	int cpu;
 	unsigned long missing_faults;
+	unsigned long wp_faults;
 };
 
 /* pthread_mutex_t starts at page offset 0 */
@@ -141,9 +145,29 @@ static void uffd_stats_reset(struct uffd_stats *uffd_stats,
 	for (i = 0; i < n_cpus; i++) {
 		uffd_stats[i].cpu = i;
 		uffd_stats[i].missing_faults = 0;
+		uffd_stats[i].wp_faults = 0;
 	}
 }
 
+static void uffd_stats_report(struct uffd_stats *stats, int n_cpus)
+{
+	int i;
+	unsigned long long miss_total = 0, wp_total = 0;
+
+	for (i = 0; i < n_cpus; i++) {
+		miss_total += stats[i].missing_faults;
+		wp_total += stats[i].wp_faults;
+	}
+
+	printf("userfaults: %llu missing (", miss_total);
+	for (i = 0; i < n_cpus; i++)
+		printf("%lu+", stats[i].missing_faults);
+	printf("\b), %llu wp (", wp_total);
+	for (i = 0; i < n_cpus; i++)
+		printf("%lu+", stats[i].wp_faults);
+	printf("\b)\n");
+}
+
 static int anon_release_pages(char *rel_area)
 {
 	int ret = 0;
@@ -264,10 +288,15 @@ struct uffd_test_ops {
 	void (*alias_mapping)(__u64 *start, size_t len, unsigned long offset);
 };
 
-#define ANON_EXPECTED_IOCTLS		((1 << _UFFDIO_WAKE) | \
+#define SHMEM_EXPECTED_IOCTLS		((1 << _UFFDIO_WAKE) | \
 					 (1 << _UFFDIO_COPY) | \
 					 (1 << _UFFDIO_ZEROPAGE))
 
+#define ANON_EXPECTED_IOCTLS		((1 << _UFFDIO_WAKE) | \
+					 (1 << _UFFDIO_COPY) | \
+					 (1 << _UFFDIO_ZEROPAGE) | \
+					 (1 << _UFFDIO_WRITEPROTECT))
+
 static struct uffd_test_ops anon_uffd_test_ops = {
 	.expected_ioctls = ANON_EXPECTED_IOCTLS,
 	.allocate_area	= anon_allocate_area,
@@ -276,7 +305,7 @@ static struct uffd_test_ops anon_uffd_test_ops = {
 };
 
 static struct uffd_test_ops shmem_uffd_test_ops = {
-	.expected_ioctls = ANON_EXPECTED_IOCTLS,
+	.expected_ioctls = SHMEM_EXPECTED_IOCTLS,
 	.allocate_area	= shmem_allocate_area,
 	.release_pages	= shmem_release_pages,
 	.alias_mapping = noop_alias_mapping,
@@ -300,6 +329,21 @@ static int my_bcmp(char *str1, char *str2, size_t n)
 	return 0;
 }
 
+static void wp_range(int ufd, __u64 start, __u64 len, bool wp)
+{
+	struct uffdio_writeprotect prms = { 0 };
+
+	/* Write protection page faults */
+	prms.range.start = start;
+	prms.range.len = len;
+	/* Undo write-protect, do wakeup after that */
+	prms.mode = wp ? UFFDIO_WRITEPROTECT_MODE_WP : 0;
+
+	if (ioctl(ufd, UFFDIO_WRITEPROTECT, &prms))
+		fprintf(stderr, "clear WP failed for address 0x%Lx\n",
+			start), exit(1);
+}
+
 static void *locking_thread(void *arg)
 {
 	unsigned long cpu = (unsigned long) arg;
@@ -438,7 +482,10 @@ static int __copy_page(int ufd, unsigned long offset, bool retry)
 	uffdio_copy.dst = (unsigned long) area_dst + offset;
 	uffdio_copy.src = (unsigned long) area_src + offset;
 	uffdio_copy.len = page_size;
-	uffdio_copy.mode = 0;
+	if (test_uffdio_wp)
+		uffdio_copy.mode = UFFDIO_COPY_MODE_WP;
+	else
+		uffdio_copy.mode = 0;
 	uffdio_copy.copy = 0;
 	if (ioctl(ufd, UFFDIO_COPY, &uffdio_copy)) {
 		/* real retval in ufdio_copy.copy */
@@ -495,15 +542,21 @@ static void uffd_handle_page_fault(struct uffd_msg *msg,
 		fprintf(stderr, "unexpected msg event %u\n",
 			msg->event), exit(1);
 
-	if (bounces & BOUNCE_VERIFY &&
-	    msg->arg.pagefault.flags & UFFD_PAGEFAULT_FLAG_WRITE)
-		fprintf(stderr, "unexpected write fault\n"), exit(1);
+	if (msg->arg.pagefault.flags & UFFD_PAGEFAULT_FLAG_WP) {
+		wp_range(uffd, msg->arg.pagefault.address, page_size, false);
+		stats->wp_faults++;
+	} else {
+		/* Missing page faults */
+		if (bounces & BOUNCE_VERIFY &&
+		    msg->arg.pagefault.flags & UFFD_PAGEFAULT_FLAG_WRITE)
+			fprintf(stderr, "unexpected write fault\n"), exit(1);
 
-	offset = (char *)(unsigned long)msg->arg.pagefault.address - area_dst;
-	offset &= ~(page_size-1);
+		offset = (char *)(unsigned long)msg->arg.pagefault.address - area_dst;
+		offset &= ~(page_size-1);
 
-	if (copy_page(uffd, offset))
-		stats->missing_faults++;
+		if (copy_page(uffd, offset))
+			stats->missing_faults++;
+	}
 }
 
 static void *uffd_poll_thread(void *arg)
@@ -589,11 +642,30 @@ static void *uffd_read_thread(void *arg)
 static void *background_thread(void *arg)
 {
 	unsigned long cpu = (unsigned long) arg;
-	unsigned long page_nr;
+	unsigned long page_nr, start_nr, mid_nr, end_nr;
+
+	start_nr = cpu * nr_pages_per_cpu;
+	end_nr = (cpu+1) * nr_pages_per_cpu;
+	mid_nr = (start_nr + end_nr) / 2;
+
+	/* Copy the first half of the pages */
+	for (page_nr = start_nr; page_nr < mid_nr; page_nr++)
+		copy_page_retry(uffd, page_nr * page_size);
 
-	for (page_nr = cpu * nr_pages_per_cpu;
-	     page_nr < (cpu+1) * nr_pages_per_cpu;
-	     page_nr++)
+	/*
+	 * If we need to test uffd-wp, set it up now.  Then we'll have
+	 * at least the first half of the pages mapped already which
+	 * can be write-protected for testing
+	 */
+	if (test_uffdio_wp)
+		wp_range(uffd, (unsigned long)area_dst + start_nr * page_size,
+			nr_pages_per_cpu * page_size, true);
+
+	/*
+	 * Continue the 2nd half of the page copying, handling write
+	 * protection faults if any
+	 */
+	for (page_nr = mid_nr; page_nr < end_nr; page_nr++)
 		copy_page_retry(uffd, page_nr * page_size);
 
 	return NULL;
@@ -755,17 +827,31 @@ static int faulting_process(int signal_test)
 	}
 
 	for (nr = 0; nr < split_nr_pages; nr++) {
+		int steps = 1;
+		unsigned long offset = nr * page_size;
+
 		if (signal_test) {
 			if (sigsetjmp(*sigbuf, 1) != 0) {
-				if (nr == lastnr) {
+				if (steps == 1 && nr == lastnr) {
 					fprintf(stderr, "Signal repeated\n");
 					return 1;
 				}
 
 				lastnr = nr;
 				if (signal_test == 1) {
-					if (copy_page(uffd, nr * page_size))
-						signalled++;
+					if (steps == 1) {
+						/* This is a MISSING request */
+						steps++;
+						if (copy_page(uffd, offset))
+							signalled++;
+					} else {
+						/* This is a WP request */
+						assert(steps == 2);
+						wp_range(uffd,
+							 (__u64)area_dst +
+							 offset,
+							 page_size, false);
+					}
 				} else {
 					signalled++;
 					continue;
@@ -778,8 +864,13 @@ static int faulting_process(int signal_test)
 			fprintf(stderr,
 				"nr %lu memory corruption %Lu %Lu\n",
 				nr, count,
-				count_verify[nr]), exit(1);
-		}
+				count_verify[nr]);
+	        }
+		/*
+		 * Trigger write protection if there is by writting
+		 * the same value back.
+		 */
+		*area_count(area_dst, nr) = count;
 	}
 
 	if (signal_test)
@@ -801,6 +892,11 @@ static int faulting_process(int signal_test)
 				nr, count,
 				count_verify[nr]), exit(1);
 		}
+		/*
+		 * Trigger write protection if there is by writting
+		 * the same value back.
+		 */
+		*area_count(area_dst, nr) = count;
 	}
 
 	if (uffd_test_ops->release_pages(area_dst))
@@ -904,6 +1000,8 @@ static int userfaultfd_zeropage_test(void)
 	uffdio_register.range.start = (unsigned long) area_dst;
 	uffdio_register.range.len = nr_pages * page_size;
 	uffdio_register.mode = UFFDIO_REGISTER_MODE_MISSING;
+	if (test_uffdio_wp)
+		uffdio_register.mode |= UFFDIO_REGISTER_MODE_WP;
 	if (ioctl(uffd, UFFDIO_REGISTER, &uffdio_register))
 		fprintf(stderr, "register failure\n"), exit(1);
 
@@ -949,6 +1047,8 @@ static int userfaultfd_events_test(void)
 	uffdio_register.range.start = (unsigned long) area_dst;
 	uffdio_register.range.len = nr_pages * page_size;
 	uffdio_register.mode = UFFDIO_REGISTER_MODE_MISSING;
+	if (test_uffdio_wp)
+		uffdio_register.mode |= UFFDIO_REGISTER_MODE_WP;
 	if (ioctl(uffd, UFFDIO_REGISTER, &uffdio_register))
 		fprintf(stderr, "register failure\n"), exit(1);
 
@@ -979,7 +1079,8 @@ static int userfaultfd_events_test(void)
 		return 1;
 
 	close(uffd);
-	printf("userfaults: %ld\n", stats.missing_faults);
+
+	uffd_stats_report(&stats, 1);
 
 	return stats.missing_faults != nr_pages;
 }
@@ -1009,6 +1110,8 @@ static int userfaultfd_sig_test(void)
 	uffdio_register.range.start = (unsigned long) area_dst;
 	uffdio_register.range.len = nr_pages * page_size;
 	uffdio_register.mode = UFFDIO_REGISTER_MODE_MISSING;
+	if (test_uffdio_wp)
+		uffdio_register.mode |= UFFDIO_REGISTER_MODE_WP;
 	if (ioctl(uffd, UFFDIO_REGISTER, &uffdio_register))
 		fprintf(stderr, "register failure\n"), exit(1);
 
@@ -1141,6 +1244,8 @@ static int userfaultfd_stress(void)
 		uffdio_register.range.start = (unsigned long) area_dst;
 		uffdio_register.range.len = nr_pages * page_size;
 		uffdio_register.mode = UFFDIO_REGISTER_MODE_MISSING;
+		if (test_uffdio_wp)
+			uffdio_register.mode |= UFFDIO_REGISTER_MODE_WP;
 		if (ioctl(uffd, UFFDIO_REGISTER, &uffdio_register)) {
 			fprintf(stderr, "register failure\n");
 			return 1;
@@ -1195,6 +1300,11 @@ static int userfaultfd_stress(void)
 		if (stress(uffd_stats))
 			return 1;
 
+		/* Clear all the write protections if there is any */
+		if (test_uffdio_wp)
+			wp_range(uffd, (unsigned long)area_dst,
+				 nr_pages * page_size, false);
+
 		/* unregister */
 		if (ioctl(uffd, UFFDIO_UNREGISTER, &uffdio_register.range)) {
 			fprintf(stderr, "unregister failure\n");
@@ -1233,10 +1343,7 @@ static int userfaultfd_stress(void)
 		area_src_alias = area_dst_alias;
 		area_dst_alias = tmp_area;
 
-		printf("userfaults:");
-		for (cpu = 0; cpu < nr_cpus; cpu++)
-			printf(" %lu", uffd_stats[cpu].missing_faults);
-		printf("\n");
+		uffd_stats_report(uffd_stats, nr_cpus);
 	}
 
 	if (err)
@@ -1276,6 +1383,8 @@ static void set_test_type(const char *type)
 	if (!strcmp(type, "anon")) {
 		test_type = TEST_ANON;
 		uffd_test_ops = &anon_uffd_test_ops;
+		/* Only enable write-protect test for anonymous test */
+		test_uffdio_wp = true;
 	} else if (!strcmp(type, "hugetlb")) {
 		test_type = TEST_HUGETLB;
 		uffd_test_ops = &hugetlb_uffd_test_ops;
-- 
2.17.1

