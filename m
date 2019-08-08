Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10146C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 19:03:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF0552173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 19:03:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="HIQxeRJU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF0552173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 664166B0007; Thu,  8 Aug 2019 15:03:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 615B16B0008; Thu,  8 Aug 2019 15:03:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 503606B000A; Thu,  8 Aug 2019 15:03:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1776E6B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 15:03:08 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id l11so36821352pgc.14
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 12:03:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=YaDw968sYZinLHwfTVtmoWadaU+xxvDOnKy5RkNnHhY=;
        b=OKLg8D35BBlSMb4XKBAX/zSbfxZbQak71wM0FAPI/ban26rXgNwWQpj15ZEv+J82zR
         MuWIbptOxClaeISsRhHUG+eOebpzxZiBsj97ITrGeA8jtJojLItVeXq2o5mCGaqA1Fjl
         HPnXIUHAOixd4VD8guSYlrRjK/wigJc+gBSOeZlmjHKGEeNo8eCZozc8i7K3/UPm/tN9
         8jOuuGQtSwttFS+cXlsey8NjnxNPHDgMPW/s3aKdRLYvtwFSFAwURoXcSQlNaE2VjdW6
         qBlWufJb+l2QzUT/eLlgxfUlIjAOjeW/aUiLTNWDM1OxcLn9dR3S3nu0Gblm0ZE0JGC7
         BhyA==
X-Gm-Message-State: APjAAAX+N8ijiqeZbg9TEC1xyH44eTTsBrqO5sjszoobdsQ/ZDDVTko5
	LEelC/0Y6dokdzLC/2rmTwTiI+pts0kjy+WBuCt7CeS6O0QrebJdmuEp1GjLRdZLymc2k+pMuZr
	fzejk9PJmDVsVWq5PXF0bcCY/yGzFnm+8MSvXWYEQGc/0b7BPdN2GU5uFB3H6qnnzpQ==
X-Received: by 2002:aa7:84d4:: with SMTP id x20mr16972246pfn.60.1565290987687;
        Thu, 08 Aug 2019 12:03:07 -0700 (PDT)
X-Received: by 2002:aa7:84d4:: with SMTP id x20mr16972168pfn.60.1565290986633;
        Thu, 08 Aug 2019 12:03:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565290986; cv=none;
        d=google.com; s=arc-20160816;
        b=dO7FSthOG801SuI8tsMRKNtKB1awd45XHUBknrsdEl2tiFQbkcD7opc54c+9jJV40g
         f9dN+cnYwAs0fd1IiedY9DMMHi/QiRkDEpDlg0ODtMskABAOoyimEL6S4WF/xCkYQx2H
         pOuO4ptTZlw3wQV4ZbGKpSxGdr7IIhdNDH5/x8AAUemf7rjuwDnJJrvYAijlkvIatECl
         zBZETXPhfU7F445PHzW0jlEm1QMu9Lyc0nKzZjq/TvccITw+ji0NwFnVcEpcpopxGd/B
         pgKp/bsAOsELcHRIw2V1azRThtE1a0FiePIJC/jzSym+Z0TX6sfrBKIqer9T/9iUISiZ
         fJgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=YaDw968sYZinLHwfTVtmoWadaU+xxvDOnKy5RkNnHhY=;
        b=Mhp2K3cuUEb/DUJneYH5GmB/8dzxgGQ5WuFxBRZVPH9iWXE4PyCYnCQeb+DHzy6kXX
         CJZlaZOeIChczj8i3rPzUKnXFyHYMmZsJq5rFE5j2fS78c1McmpIgT8L0GtAPc2mE5+E
         UA1R7Y0igT1YJIbFzYG4b75GrEVdOzQ8+o9ioKnIZJo14tzdz10Hs8P5a+YM1nlCdXST
         20FqkLvKkRqmDX0OVTa2EMn5f+xQkK/eOIrXKAA2tPqSY6NgO+HLY/5v4RCxqLshVoBp
         vTsYN1bZR+dgvK8UsyaBRzkf3DddFjk6k717PLES/9sUe6NrIW4IO5yS5xTxsSa+jh7y
         y/fA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=HIQxeRJU;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s14sor3774319pjb.11.2019.08.08.12.03.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 12:03:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=HIQxeRJU;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=YaDw968sYZinLHwfTVtmoWadaU+xxvDOnKy5RkNnHhY=;
        b=HIQxeRJULmhNEAqcWiiIVZr0UAHZw/vMZ/YXLmvIkXIat0A1z75P9Q0d/P74XRw3do
         R7+ctJwPKZUsckjeTNvykCKZsWrBGUXA5z5ZhyRNBYXd8H4O6Fr/Cfh1Tgcp0VtQSpzQ
         sHkoTTEtlwzMapLsx/9XmEPsqlkUGcTTXFX0+zFyl6atF/lOxErRKyNsY876FIdy4kom
         iHrVYxjJMl+rUFyMB+98d2/kmsgt03t7E0C/Gw5ePaTD8Sis0vFdJXbU/8NWpzUYzFd/
         +GAdy2lZyujaVYVCBCBCH4QSjJMb3LYnJxKiTOIRpKMlA/KjrXwRHyDPiu3C/9kVghl3
         PqlA==
X-Google-Smtp-Source: APXvYqyauxFlil+jXyg34wXrmqepCBj1OqcfC1/2Gy4eTEI53he4OQNjlsbx5piBhi7v9zETXwpdnA==
X-Received: by 2002:a17:90a:8b98:: with SMTP id z24mr5545969pjn.77.1565290983429;
        Thu, 08 Aug 2019 12:03:03 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:e15f])
        by smtp.gmail.com with ESMTPSA id t6sm22068113pgu.23.2019.08.08.12.03.02
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 08 Aug 2019 12:03:02 -0700 (PDT)
Date: Thu, 8 Aug 2019 15:03:00 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Dave Chinner <david@fromorbit.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH RESEND] block: annotate refault stalls from IO submission
Message-ID: <20190808190300.GA9067@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

psi tracks the time tasks wait for refaulting pages to become
uptodate, but it does not track the time spent submitting the IO. The
submission part can be significant if backing storage is contended or
when cgroup throttling (io.latency) is in effect - a lot of time is
spent in submit_bio(). In that case, we underreport memory pressure.

Annotate submit_bio() to account submission time as memory stall when
the bio is reading userspace workingset pages.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 block/bio.c               |  3 +++
 block/blk-core.c          | 23 ++++++++++++++++++++++-
 include/linux/blk_types.h |  1 +
 3 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/block/bio.c b/block/bio.c
index 299a0e7651ec..4196865dd300 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -806,6 +806,9 @@ void __bio_add_page(struct bio *bio, struct page *page,
 
 	bio->bi_iter.bi_size += len;
 	bio->bi_vcnt++;
+
+	if (!bio_flagged(bio, BIO_WORKINGSET) && unlikely(PageWorkingset(page)))
+		bio_set_flag(bio, BIO_WORKINGSET);
 }
 EXPORT_SYMBOL_GPL(__bio_add_page);
 
diff --git a/block/blk-core.c b/block/blk-core.c
index d0cc6e14d2f0..1b1705b7dde7 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -36,6 +36,7 @@
 #include <linux/blk-cgroup.h>
 #include <linux/debugfs.h>
 #include <linux/bpf.h>
+#include <linux/psi.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/block.h>
@@ -1128,6 +1129,10 @@ EXPORT_SYMBOL_GPL(direct_make_request);
  */
 blk_qc_t submit_bio(struct bio *bio)
 {
+	bool workingset_read = false;
+	unsigned long pflags;
+	blk_qc_t ret;
+
 	if (blkcg_punt_bio_submit(bio))
 		return BLK_QC_T_NONE;
 
@@ -1146,6 +1151,8 @@ blk_qc_t submit_bio(struct bio *bio)
 		if (op_is_write(bio_op(bio))) {
 			count_vm_events(PGPGOUT, count);
 		} else {
+			if (bio_flagged(bio, BIO_WORKINGSET))
+				workingset_read = true;
 			task_io_account_read(bio->bi_iter.bi_size);
 			count_vm_events(PGPGIN, count);
 		}
@@ -1160,7 +1167,21 @@ blk_qc_t submit_bio(struct bio *bio)
 		}
 	}
 
-	return generic_make_request(bio);
+	/*
+	 * If we're reading data that is part of the userspace
+	 * workingset, count submission time as memory stall. When the
+	 * device is congested, or the submitting cgroup IO-throttled,
+	 * submission can be a significant part of overall IO time.
+	 */
+	if (workingset_read)
+		psi_memstall_enter(&pflags);
+
+	ret = generic_make_request(bio);
+
+	if (workingset_read)
+		psi_memstall_leave(&pflags);
+
+	return ret;
 }
 EXPORT_SYMBOL(submit_bio);
 
diff --git a/include/linux/blk_types.h b/include/linux/blk_types.h
index 1b1fa1557e68..a9dadfc16a92 100644
--- a/include/linux/blk_types.h
+++ b/include/linux/blk_types.h
@@ -209,6 +209,7 @@ enum {
 	BIO_BOUNCED,		/* bio is a bounce bio */
 	BIO_USER_MAPPED,	/* contains user pages */
 	BIO_NULL_MAPPED,	/* contains invalid user pages */
+	BIO_WORKINGSET,		/* contains userspace workingset pages */
 	BIO_QUIET,		/* Make BIO Quiet */
 	BIO_CHAIN,		/* chained bio, ->bi_remaining in effect */
 	BIO_REFFED,		/* bio has elevated ->bi_cnt */
-- 
2.22.0

