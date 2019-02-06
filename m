Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 273ACC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:00:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D055D20818
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:00:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D055D20818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 160018E00E2; Wed,  6 Feb 2019 13:00:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 111BA8E00D1; Wed,  6 Feb 2019 13:00:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECEB38E00E2; Wed,  6 Feb 2019 13:00:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A97938E00D1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 13:00:04 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id y8so5117985pgq.12
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 10:00:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=0n7fg0iJYctopHXS8YxQYYdUHYinmEBkqLo15ZLF1mI=;
        b=MFUTXTPiON6SQl8aHag+3m1N8WITK4p+wzvAPOCXjak1uVOIeuWiJ//ZwqthkZKmgW
         ssuxOkgxGph4VeQ9z7p1PZpzRTEvyMXRSnpljIKeAWuBN39hHuHR2QU+rKp5yB6brR57
         OOkiPEfSQB8Mjlo0KP3Q/BWYvZf9EeJCKrQEBLq7z0dJQbGnnP44wSUPv7z5127aAXWx
         UlUDP0CgJkr32yZekUKSCSwAWJ6jYcXFZ09cKTQRVvGv8rNCCPg8DVTt9pXpcarQmDcU
         3+DrCx7qf/SocXHJuawjRUtOhfACqcqhKZ3PxxztFPgxKY0iwZK9DSu4rg5qHU+IXuqy
         Ig+g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: AHQUAuYd9IL8bINr1ngQrCl9Stqowjp6Dw0ojsL3aDzcKxw6uvDUE75R
	0pc7lqFfCGQooTlXKVdpwz/TAZePLWOXvSiKM1UDxASShJic4ZzBL434RuEILLD5TRcZQu5oF8r
	TuRnimqp5NrFWNr7+L01CkHY7I292Bvhd4MokY0TZjLwBCxYBHWxTmIouoOdT97g=
X-Received: by 2002:a17:902:9687:: with SMTP id n7mr11644971plp.94.1549476004319;
        Wed, 06 Feb 2019 10:00:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IarUuMPHOIEVIhQ4zMdp6cpoWN2BW+F4qruxiKRCnykNmqrgc0vfqcKb+RPgJF8tHsLaUZN
X-Received: by 2002:a17:902:9687:: with SMTP id n7mr11644879plp.94.1549476003120;
        Wed, 06 Feb 2019 10:00:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549476003; cv=none;
        d=google.com; s=arc-20160816;
        b=lAyppG5iEfekU1CAGzgvko4YhkZPQazgaSiKW7J2Bo9aWBD60sZTU/xaJGq9Oq7dv8
         P07w1U1dS84NkSlvP8Od6bt0K6wchvIxrhs7XI1AkEL0KRoanOmHC6KGpjOpFl25ywFp
         ymEbGOYNZ0W712/I9c9M1h1ue3ShpHYfV6/TP4G/t3ws7w/paPI1ciBMx0szJvC9pMQ1
         iBZsNBxkzo/s3F4JqV5w1rdQSZQCd3FXhIowppCdTiyIhGs1XB1ahRjK5iPV5jTnMocK
         3lZmQOZn2HwpjD4DtvCLUwKoKMB5QbSLvO/UFo/ZVUDv1YjyIIpZEVizWWOmcbW26vA8
         bdKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=0n7fg0iJYctopHXS8YxQYYdUHYinmEBkqLo15ZLF1mI=;
        b=RyCxvoYc/GrKNaYz1v/FxgnI4jMhMbZ0C38o28bgjl98vTYb6o/d28g28q618RgB9n
         rRx+7qjdc7tTo7ILJZXOFIVozFkzkpMKgFTrzsra8im+UM3kRdTv4lWtQEE/LQZibQWO
         kVSJHxQTSIj1Yv1sTR8XWhoJhYa1VGC3CigvRZwYaDHgStwjykqLG3zTC32msRXZ//ld
         mQIE8GjcwIFlBKBQlb8We2d+ihD6TE0V8GviOqHnDqEJ1Uzjl2TmU5DJQVVEvt5Nwoyw
         zvq4A4bsUG4aDFtlWWVLgxKcyxVMiSYoVOuPphQSSRLhoVvIdZE1VnppFcsjci8AQGqy
         kkVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id cb16si2468902plb.290.2019.02.06.10.00.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 10:00:03 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Wed, 06 Feb 2019 19:00:00 +0100
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Wed, 06 Feb 2019 17:59:41 +0000
From: Davidlohr Bueso <dave@stgolabs.net>
To: jgg@ziepe.ca,
	akpm@linux-foundation.org
Cc: dledford@redhat.com,
	jgg@mellanox.com,
	jack@suse.cz,
	willy@infradead.org,
	ira.weiny@intel.com,
	linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	dave@stgolabs.net,
	sudeep.dutt@intel.com,
	ashutosh.dixit@intel.com,
	Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 2/6] drivers/mic/scif: do not use mmap_sem
Date: Wed,  6 Feb 2019 09:59:16 -0800
Message-Id: <20190206175920.31082-3-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190206175920.31082-1-dave@stgolabs.net>
References: <20190206175920.31082-1-dave@stgolabs.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The driver uses mmap_sem for both pinned_vm accounting and
get_user_pages(). By using gup_fast() and letting the mm handle
the lock if needed, we can no longer rely on the semaphore and
simplify the whole thing.

Cc: sudeep.dutt@intel.com
Cc: ashutosh.dixit@intel.com
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/misc/mic/scif/scif_rma.c | 36 +++++++++++-------------------------
 1 file changed, 11 insertions(+), 25 deletions(-)

diff --git a/drivers/misc/mic/scif/scif_rma.c b/drivers/misc/mic/scif/scif_rma.c
index 2448368f181e..263b8ad507ea 100644
--- a/drivers/misc/mic/scif/scif_rma.c
+++ b/drivers/misc/mic/scif/scif_rma.c
@@ -272,21 +272,12 @@ static inline void __scif_release_mm(struct mm_struct *mm)
 
 static inline int
 __scif_dec_pinned_vm_lock(struct mm_struct *mm,
-			  int nr_pages, bool try_lock)
+			  int nr_pages)
 {
 	if (!mm || !nr_pages || !scif_ulimit_check)
 		return 0;
-	if (try_lock) {
-		if (!down_write_trylock(&mm->mmap_sem)) {
-			dev_err(scif_info.mdev.this_device,
-				"%s %d err\n", __func__, __LINE__);
-			return -1;
-		}
-	} else {
-		down_write(&mm->mmap_sem);
-	}
+
 	atomic64_sub(nr_pages, &mm->pinned_vm);
-	up_write(&mm->mmap_sem);
 	return 0;
 }
 
@@ -298,16 +289,16 @@ static inline int __scif_check_inc_pinned_vm(struct mm_struct *mm,
 	if (!mm || !nr_pages || !scif_ulimit_check)
 		return 0;
 
-	locked = nr_pages;
-	locked += atomic64_read(&mm->pinned_vm);
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
+	locked = atomic64_add_return(nr_pages, &mm->pinned_vm);
+
 	if ((locked > lock_limit) && !capable(CAP_IPC_LOCK)) {
+		atomic64_sub(nr_pages, &mm->pinned_vm);
 		dev_err(scif_info.mdev.this_device,
 			"locked(%lu) > lock_limit(%lu)\n",
 			locked, lock_limit);
 		return -ENOMEM;
 	}
-	atomic64_set(&mm->pinned_vm, locked);
 	return 0;
 }
 
@@ -326,7 +317,7 @@ int scif_destroy_window(struct scif_endpt *ep, struct scif_window *window)
 
 	might_sleep();
 	if (!window->temp && window->mm) {
-		__scif_dec_pinned_vm_lock(window->mm, window->nr_pages, 0);
+		__scif_dec_pinned_vm_lock(window->mm, window->nr_pages);
 		__scif_release_mm(window->mm);
 		window->mm = NULL;
 	}
@@ -737,7 +728,7 @@ int scif_unregister_window(struct scif_window *window)
 					    ep->rma_info.dma_chan);
 		} else {
 			if (!__scif_dec_pinned_vm_lock(window->mm,
-						       window->nr_pages, 1)) {
+						       window->nr_pages)) {
 				__scif_release_mm(window->mm);
 				window->mm = NULL;
 			}
@@ -1385,28 +1376,23 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 		prot |= SCIF_PROT_WRITE;
 retry:
 		mm = current->mm;
-		down_write(&mm->mmap_sem);
 		if (ulimit) {
 			err = __scif_check_inc_pinned_vm(mm, nr_pages);
 			if (err) {
-				up_write(&mm->mmap_sem);
 				pinned_pages->nr_pages = 0;
 				goto error_unmap;
 			}
 		}
 
-		pinned_pages->nr_pages = get_user_pages(
+		pinned_pages->nr_pages = get_user_pages_fast(
 				(u64)addr,
 				nr_pages,
 				(prot & SCIF_PROT_WRITE) ? FOLL_WRITE : 0,
-				pinned_pages->pages,
-				NULL);
-		up_write(&mm->mmap_sem);
+				pinned_pages->pages);
 		if (nr_pages != pinned_pages->nr_pages) {
 			if (try_upgrade) {
 				if (ulimit)
-					__scif_dec_pinned_vm_lock(mm,
-								  nr_pages, 0);
+					__scif_dec_pinned_vm_lock(mm, nr_pages);
 				/* Roll back any pinned pages */
 				for (i = 0; i < pinned_pages->nr_pages; i++) {
 					if (pinned_pages->pages[i])
@@ -1433,7 +1419,7 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 	return err;
 dec_pinned:
 	if (ulimit)
-		__scif_dec_pinned_vm_lock(mm, nr_pages, 0);
+		__scif_dec_pinned_vm_lock(mm, nr_pages);
 	/* Something went wrong! Rollback */
 error_unmap:
 	pinned_pages->nr_pages = nr_pages;
-- 
2.16.4

