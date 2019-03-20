Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E68AC10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:10:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D5562184E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:10:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D5562184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1AE46B0288; Tue, 19 Mar 2019 22:10:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA3B06B028A; Tue, 19 Mar 2019 22:10:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91CD46B028B; Tue, 19 Mar 2019 22:10:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6676B0288
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:10:48 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id x12so934124qtk.2
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:10:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=MIozerEVlbsC7Eks2DH/IrUUfmnGE+cAmIg6z0gEZVg=;
        b=c8nuffO/+XOyaQZ3yws3sI1qVfKMFL9hg3kbTNWToibGbuKoVENgvHzCwbgNUSGKIM
         AKrzrezBEmvPslIKt+qf2jN4QgnBFmxCVVzKCS6bc8PYd5Aw6TYLSHA2O1NQrtw3NAn+
         msi1MPITPhKHByur3ePuSykm4IQDez6/Zo9MVLuU1dpvxp909e+abadO5nk6vmlvnpKy
         ccMKD4DzHDv1WBPEYfKS5DEEZdgpFK9FPh3eMKFaEY7naBt42zFmpdUp6baWwWsLfpTZ
         6IMkSQ4wY5Aqhrwr9c98xLk74cKu/NOWa2POC60VpEu8wvQKRea3A/TXg1m3QoqiQZbq
         ZpGg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWj3yYGzS5gMVYy+WKPosP2+AwSoG2ojp6rZYrot9efmWCn24I2
	ScQ1JU3Y4EagcKsIMAhBd3v9olNs7D2F3glyO2LavlZyFZ8U73VoSsK1/uc8X7wq5S/RRxtNT+c
	gZKaFG23H5puxcXTYEsJ/U8ZAvEVUOWWt2ZLLFWQcLEX2hW6ZC/dQi2cyhjalgfTccg==
X-Received: by 2002:a0c:87d9:: with SMTP id 25mr4444458qvk.219.1553047848182;
        Tue, 19 Mar 2019 19:10:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwaDN986vv6NeXmB++csbovv1THwb25UIaeRtX7bfplTmQod5bO1biYUXQOJZzbK9HBoBe3
X-Received: by 2002:a0c:87d9:: with SMTP id 25mr4444415qvk.219.1553047847093;
        Tue, 19 Mar 2019 19:10:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047847; cv=none;
        d=google.com; s=arc-20160816;
        b=txn0WP0lPsFoWEDrrWhN90Wz985TtO3VRbMDHmQnduguW3tRlKOPGi207OC+Q+NK1k
         hcUY5WHCYtULanxViC2Pu4ydQr8vnZqmLyH6oqVrGWz2GaMRPjGT+w1I67pOZkK78Snw
         ng/lsDJ6y8ikwYIHDTeVNeEF3jbta22wnn1r3ksxSHNbXDT1DuhT7vlnumFBuaw3CAaC
         UcEbpjKeXM82LwqTj8dSYQEyviPqV1rg6PIdbzpnx4AhQS6Y7+9Ul+spoN5jEwZE+GCW
         OZD9P5usJq5aupxzpidP+TYDLeMsRGkGvCXZywbAirzXWazFfMSRBQk/oGE3uOlCuIKT
         0Amw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=MIozerEVlbsC7Eks2DH/IrUUfmnGE+cAmIg6z0gEZVg=;
        b=cpVoT7C6UHeL4ztC/wQV/zh/KWyKOGg8ak0FC5d+sRtc5dUEjzkCfuiJs8UtO5FcOn
         cxN/wvIzxnPmdb/MY9tWKWXp99wTI0+CqtnQrD9VG9XuFcb0hEBhhYq8PTPSIBLxuDDK
         r4dThXQMAvs1neYmM0yFeO/0wZnSYE89HuYX4VRfr9pc6xCznzpJ+mzoJPVFvHZHvcVF
         VWNhu2iRxRefdFcdftxllCDTeibyjS2ubovI4niZFCk2wJQNu4V+ce3KP7xSmhFQoJZT
         nMrdm6cIPFK2m6coLZWlgqYhAsbmyp/k8SUzCPA/bQzQfY3Tf6NyHKgXOS7m5ZHscAbc
         8OcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l24si345455qkg.256.2019.03.19.19.10.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:10:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2880FC1306F8;
	Wed, 20 Mar 2019 02:10:46 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 32D1F60634;
	Wed, 20 Mar 2019 02:10:39 +0000 (UTC)
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
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v3 28/28] userfaultfd: selftests: add write-protect test
Date: Wed, 20 Mar 2019 10:06:42 +0800
Message-Id: <20190320020642.4000-29-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 20 Mar 2019 02:10:46 +0000 (UTC)
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

