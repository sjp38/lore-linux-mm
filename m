Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB14CC282D7
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:01:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6567C217FA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:01:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6567C217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE9C38E01B0; Mon, 11 Feb 2019 22:01:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D99E28E000E; Mon, 11 Feb 2019 22:01:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3BBE8E01B0; Mon, 11 Feb 2019 22:01:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 955458E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 22:01:47 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id e9so14242240qka.11
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:01:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=1e0ADGgd5khDqTzI8a0ZR54GIFB9fAr8S+c4oruTe0w=;
        b=LTlt5lDpcH4rXAhOQkAqE3B50TRT0zeXGpXP7Z9AWF3vK9U93FfVusfkKjp/Wja0Qv
         NoEVjCLWRZvNa//+mPU1IwGfITpkx2ATJthrfCwFzmxWitM17ZaOCUG8KroUZIvVivbJ
         afyRvzdFqj/qB1XBFyVGRElrgqfMIMcHClqysh7AuhMhFU1iLIQNRwLAGIz9aVvyQ88w
         Ay48q6hBuv0/pXmX7McCgGKVXEt2Bu1VjltMKFOhMSs35nSxwr2zmZ8It2BtRiVnO//o
         00hleTpaFJAlGX9UCltWRH6Sow1k3DoDfRyLfBnC+C8SyXQCPuG5pv444HR4+j0JHG6o
         QVPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAube1fRncSdtprpBTf3/i4wfLe181LJd2pIZA3DfFFCdQHqFdYRy
	06jf0fm+ja1/Nnj4eEHFNQQpFwL68avkuWNeDhXV/5caKn0ykMA4oBhJOiEcy0xt5AUQPwEzThP
	aRR7m9oaFYZCi9BVHIXtq6DuzfV4siZfy1hH4O9T6vFxcybp4mNxkxekN8WXBNCDbcA==
X-Received: by 2002:ac8:3f0f:: with SMTP id c15mr1141821qtk.142.1549940507370;
        Mon, 11 Feb 2019 19:01:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYKo2RlG2UPBHoM3bBNEfedNxJ90cEJ80W4d6cL3U9gTR1R3W3ulM7EFKZA2l6QqPAO8Eat
X-Received: by 2002:ac8:3f0f:: with SMTP id c15mr1141778qtk.142.1549940506396;
        Mon, 11 Feb 2019 19:01:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940506; cv=none;
        d=google.com; s=arc-20160816;
        b=Y2Fq7hjawWPy0wOhkP1CB3OiD41vWt4XZi6CBB1SDvKYA9HZlo6gi8dEaNVhYoBCLG
         0lznje5SP8Wc4ibEthyJSAI2z+DrWYXWLQM0mXnjUw292SKodBPw1R+AzP5s1eVs/GIu
         GhVQXMOo/2mqHRr6rj+gKpsOmesIntTl3skHimLRjN+Amz1xgqQY/tUBO6AqZV52Qx4T
         xnUZpBLZJDkKKNWP2UQqDrqYkfPQ3v63qkDbUCTO1wY7w20j3Q5ALUuZJKa+0wNsIylU
         gk1Ol8FPYVLgaiXdeeFIdy18L7+IbYEWdsv4rS78uILoiQlF/OsUCJL9d9+DJ4RUualL
         KcCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=1e0ADGgd5khDqTzI8a0ZR54GIFB9fAr8S+c4oruTe0w=;
        b=a5bNx/0ibiX+3nVJH+4MR3bYLVr1Jjk+Nwd5RW1Cw43tT2TVmHjqsYlOkTOB6/mCoT
         zRh2ZE8tvlSLgA7m+doA/a2smEGZnMGtieWz60KOmE5FA/740V1zS2Us2orKOE2onVAR
         TOjkIRXZ8Y/gMv0dTCpBxN/Y62N9CyfFwEvxgM3U18cySnanv1eryXlZiiNdsW1nGhr6
         C0dYh/2uV+hXW26fBVotil+yWHE6oPuWootYKNC+Vcvj4e5ITGN6nY5+mnhaFgi/drU7
         wkvpMCNLJgblCSPfYrb8XvVtF8RH/e4ARUrNzyDLuwcUobkyqTXCXIkMvjiBWFwfEDH7
         duBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z55si2005656qta.188.2019.02.11.19.01.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 19:01:46 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 13DF058E22;
	Tue, 12 Feb 2019 03:01:45 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id F0174600C6;
	Tue, 12 Feb 2019 03:01:27 +0000 (UTC)
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
Subject: [PATCH v2 26/26] userfaultfd: selftests: add write-protect test
Date: Tue, 12 Feb 2019 10:56:32 +0800
Message-Id: <20190212025632.28946-27-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 12 Feb 2019 03:01:45 +0000 (UTC)
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
 tools/testing/selftests/vm/userfaultfd.c | 154 ++++++++++++++++++-----
 1 file changed, 126 insertions(+), 28 deletions(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index e5d12c209e09..57b5ac02080a 100644
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
@@ -264,19 +288,15 @@ struct uffd_test_ops {
 	void (*alias_mapping)(__u64 *start, size_t len, unsigned long offset);
 };
 
-#define ANON_EXPECTED_IOCTLS		((1 << _UFFDIO_WAKE) | \
-					 (1 << _UFFDIO_COPY) | \
-					 (1 << _UFFDIO_ZEROPAGE))
-
 static struct uffd_test_ops anon_uffd_test_ops = {
-	.expected_ioctls = ANON_EXPECTED_IOCTLS,
+	.expected_ioctls = UFFD_API_RANGE_IOCTLS,
 	.allocate_area	= anon_allocate_area,
 	.release_pages	= anon_release_pages,
 	.alias_mapping = noop_alias_mapping,
 };
 
 static struct uffd_test_ops shmem_uffd_test_ops = {
-	.expected_ioctls = ANON_EXPECTED_IOCTLS,
+	.expected_ioctls = UFFD_API_RANGE_IOCTLS,
 	.allocate_area	= shmem_allocate_area,
 	.release_pages	= shmem_release_pages,
 	.alias_mapping = noop_alias_mapping,
@@ -300,6 +320,21 @@ static int my_bcmp(char *str1, char *str2, size_t n)
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
@@ -438,7 +473,10 @@ static int __copy_page(int ufd, unsigned long offset, bool retry)
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
@@ -495,15 +533,21 @@ static void uffd_handle_page_fault(struct uffd_msg *msg,
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
@@ -589,11 +633,30 @@ static void *uffd_read_thread(void *arg)
 static void *background_thread(void *arg)
 {
 	unsigned long cpu = (unsigned long) arg;
-	unsigned long page_nr;
+	unsigned long page_nr, start_nr, mid_nr, end_nr;
 
-	for (page_nr = cpu * nr_pages_per_cpu;
-	     page_nr < (cpu+1) * nr_pages_per_cpu;
-	     page_nr++)
+	start_nr = cpu * nr_pages_per_cpu;
+	end_nr = (cpu+1) * nr_pages_per_cpu;
+	mid_nr = (start_nr + end_nr) / 2;
+
+	/* Copy the first half of the pages */
+	for (page_nr = start_nr; page_nr < mid_nr; page_nr++)
+		copy_page_retry(uffd, page_nr * page_size);
+
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
@@ -755,17 +818,31 @@ static int faulting_process(int signal_test)
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
@@ -778,8 +855,13 @@ static int faulting_process(int signal_test)
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
@@ -801,6 +883,11 @@ static int faulting_process(int signal_test)
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
@@ -949,6 +1036,8 @@ static int userfaultfd_events_test(void)
 	uffdio_register.range.start = (unsigned long) area_dst;
 	uffdio_register.range.len = nr_pages * page_size;
 	uffdio_register.mode = UFFDIO_REGISTER_MODE_MISSING;
+	if (test_uffdio_wp)
+		uffdio_register.mode |= UFFDIO_REGISTER_MODE_WP;
 	if (ioctl(uffd, UFFDIO_REGISTER, &uffdio_register))
 		fprintf(stderr, "register failure\n"), exit(1);
 
@@ -979,7 +1068,8 @@ static int userfaultfd_events_test(void)
 		return 1;
 
 	close(uffd);
-	printf("userfaults: %ld\n", stats.missing_faults);
+
+	uffd_stats_report(&stats, 1);
 
 	return stats.missing_faults != nr_pages;
 }
@@ -1009,6 +1099,8 @@ static int userfaultfd_sig_test(void)
 	uffdio_register.range.start = (unsigned long) area_dst;
 	uffdio_register.range.len = nr_pages * page_size;
 	uffdio_register.mode = UFFDIO_REGISTER_MODE_MISSING;
+	if (test_uffdio_wp)
+		uffdio_register.mode |= UFFDIO_REGISTER_MODE_WP;
 	if (ioctl(uffd, UFFDIO_REGISTER, &uffdio_register))
 		fprintf(stderr, "register failure\n"), exit(1);
 
@@ -1141,6 +1233,8 @@ static int userfaultfd_stress(void)
 		uffdio_register.range.start = (unsigned long) area_dst;
 		uffdio_register.range.len = nr_pages * page_size;
 		uffdio_register.mode = UFFDIO_REGISTER_MODE_MISSING;
+		if (test_uffdio_wp)
+			uffdio_register.mode |= UFFDIO_REGISTER_MODE_WP;
 		if (ioctl(uffd, UFFDIO_REGISTER, &uffdio_register)) {
 			fprintf(stderr, "register failure\n");
 			return 1;
@@ -1195,6 +1289,11 @@ static int userfaultfd_stress(void)
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
@@ -1233,10 +1332,7 @@ static int userfaultfd_stress(void)
 		area_src_alias = area_dst_alias;
 		area_dst_alias = tmp_area;
 
-		printf("userfaults:");
-		for (cpu = 0; cpu < nr_cpus; cpu++)
-			printf(" %lu", uffd_stats[cpu].missing_faults);
-		printf("\n");
+		uffd_stats_report(uffd_stats, nr_cpus);
 	}
 
 	if (err)
@@ -1276,6 +1372,8 @@ static void set_test_type(const char *type)
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

