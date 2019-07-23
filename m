Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C29A6C761A8
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 19:04:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E489218F0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 19:04:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="efKs1W8U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E489218F0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CC006B0008; Tue, 23 Jul 2019 15:04:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 057678E0003; Tue, 23 Jul 2019 15:04:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E38438E0002; Tue, 23 Jul 2019 15:04:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A92F66B0008
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 15:04:44 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a20so26787298pfn.19
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 12:04:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=iX2rdum8LwS0b+uhjozcZFGbYT8krqFFlh+UkKmMIgQ=;
        b=G0QWR5GMmayHmD8Xils4cO27BV3HuXwLxVPz8FLt5gSy/lK+ZEElFFCVEmVMeeYkwC
         8ycsolX1wZNRN2vZHKFGQIZrPCFRtKb6S3vRO2vy/6lJSUpfl/5riFUZWchc7ZCYjXpy
         y4/qY28/UDfkW1mM8wq1CPJHBOsRvWDquYBfotAcB+ngaekKCId3P+f7nZzJ1VcRUyT3
         RTAo55tOBrHhtNt7xTSZi/pPLlklz3CCAoOvHrjeSsN2cBPxEdUFdWkTm20uw+qtjzpq
         g2gLFYw2qqHl1RRRBvr9+7q7hydN9XsTP3EDB77l/7oId9h9/uQsovL1q50bEqF0d416
         Fzhg==
X-Gm-Message-State: APjAAAWhGN+Urp5deZkkwQg7UKCvaqX6ozBhZ0CY+1vVO/UNo0qeCkls
	mYZJFFAvHJmm+DGBIQV9uauY55WJ3P5XqDho1uUuhUh6nI4b6GQjXNF36cVjAbRN7Q8arTiQcBW
	A4o9NoHi+BAZOLsedujDfJf5Pcmd2GW+Fw/gls9OF1akFvwb+op2cCHZfyc7N5m+vRw==
X-Received: by 2002:a63:db47:: with SMTP id x7mr77232014pgi.375.1563908684211;
        Tue, 23 Jul 2019 12:04:44 -0700 (PDT)
X-Received: by 2002:a63:db47:: with SMTP id x7mr77231948pgi.375.1563908683220;
        Tue, 23 Jul 2019 12:04:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563908683; cv=none;
        d=google.com; s=arc-20160816;
        b=Wz05KvEHBCoobjQMA37zI0fUyuZoy47NYtLZvCx7z0RWCgggXzRBX+2rFT6xCmR7l6
         9cFgxBTRCYb8M3f/xpybsE0Dx4ZbtMOdptjlk/AlDBNsPna4920YjRva0k5I6cen8MIH
         XzSbKHb9I0Vbt6hPGnQBorPEIuWSvmpJA+s+kNk20PJUlxFA0a0xHBlwLzGDZ8gLTMvW
         w+dpPBVp358+tEeJpn0HIcuhFcPGtQvbDvQzXehu8xivM4yeFmQOQI3n7HCLcxQmuMLh
         xzyvrtKg+opkR/sxHsjPaZFZDpvtqXKUgU2breEtZDHtvkikXx75IQi2djBQqRmJXzzj
         3k8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=iX2rdum8LwS0b+uhjozcZFGbYT8krqFFlh+UkKmMIgQ=;
        b=PHmsqKXGzXomBlS3J2SdakFcfb7rPHSYCQqypw3lD1LoV5ldqWBcCq6k0mGWu2CUm2
         d6YK1xG3htc+WCmeo3/4aPZEZGTI5N0ctPT5laXLoLvqnIR8mzwKNZwimbzbE85NtPxp
         Z8njKModTpcVLVG4cOwOo3dtbOHjgZP4GtdfhjeLNMbykbAlBAjRpsrLoYuCKsZKHyoE
         biPsKQEord+tnR695YEvickf1YSxpVpAzpnhb+48g35Fb4OhbJUxkIowtPdGX6BsGZsR
         nJTrCjg77cXlTkZWZ2URliGcqq7n5udYEfeza/lTGbwq0/b5agIrS5aCtXiJJo6GkJOG
         d7Og==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=efKs1W8U;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v21sor14622370pgb.48.2019.07.23.12.04.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 12:04:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=efKs1W8U;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=iX2rdum8LwS0b+uhjozcZFGbYT8krqFFlh+UkKmMIgQ=;
        b=efKs1W8UckyexrvbFaX1JVWquDQAPbnXf/uV6DA/2BeX7Sq1FLUVmAIsm9FHX1Cs5n
         TAyM32QYxzLcWNgCnSAZ5VyuJekiCCSBWpzpyfwqq0bL6dHay0ud6YtB/9dkNbEY0Ua2
         wHzWXgxYXBdRfbSQr4znDfnX8VifzQgMK4YE+UhYSliRgNsmeV6S20yvFiMUaTGctRS1
         u4LWrgauSDB8KeFRRR6V0WU8oMA5rtXxd+04yUifdRITayoCQu94fv+0LKJcOQ/PKV6x
         WWMD2T3RJCVuvzTE/F58mSllGUJ/vN3I9YGGgQUodn9Oq18qDjE8y/8qgI8uTrqBfdm4
         MmEw==
X-Google-Smtp-Source: APXvYqxKieWmko2TRxQnmNvA4D7SHmkxX9uOaU1GAx9OGn5S18fj4nXY5cRSKlu4xGUuC4LMy0Mh8A==
X-Received: by 2002:a63:c03:: with SMTP id b3mr13433296pgl.23.1563908681249;
        Tue, 23 Jul 2019 12:04:41 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:a7f8])
        by smtp.gmail.com with ESMTPSA id r2sm59085807pfl.67.2019.07.23.12.04.40
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 12:04:40 -0700 (PDT)
Date: Tue, 23 Jul 2019 15:04:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH] psi: annotate refault stalls from IO submission
Message-ID: <20190723190438.GA22541@cmpxchg.org>
References: <20190722201337.19180-1-hannes@cmpxchg.org>
 <20190723000226.GV7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723000226.GV7777@dread.disaster.area>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

CCing Jens for bio layer stuff

On Tue, Jul 23, 2019 at 10:02:26AM +1000, Dave Chinner wrote:
> Even better: If this memstall and "refault" check is needed to
> account for bio submission blocking, then page cache iteration is
> the wrong place to be doing this check. It should be done entirely
> in the bio code when adding pages to the bio because we'll only ever
> be doing page cache read IO on page cache misses. i.e. this isn't
> dependent on adding a new page to the LRU or not - if we add a new
> page then we are going to be doing IO and so this does not require
> magic pixie dust at the page cache iteration level

That could work. I had it at the page cache level because that's
logically where the refault occurs. But PG_workingset encodes
everything we need from the page cache layer and is available where
the actual stall occurs, so we should be able to push it down.

> e.g. bio_add_page_memstall() can do the working set check and then
> set a flag on the bio to say it contains a memstall page. Then on
> submission of the bio the memstall condition can be cleared.

A separate bio_add_page_memstall() would have all the problems you
pointed out with the original patch: it's magic, people will get it
wrong, and it'll be hard to verify and notice regressions.

How about just doing it in __bio_add_page()? PG_workingset is not
overloaded - when we see it set, we can generally and unconditionally
flag the bio as containing userspace workingset pages.

At submission time, in conjunction with the IO direction, we can
clearly tell whether we are reloading userspace workingset data,
i.e. stalling on memory.

This?

---
From 033e0c4789ef4ceefb2d8038b4e162dfb434d03d Mon Sep 17 00:00:00 2001
From: Johannes Weiner <hannes@cmpxchg.org>
Date: Thu, 11 Jul 2019 16:01:40 -0400
Subject: [PATCH] psi: annotate refault stalls from IO submission

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
index 29cd6cf4da51..6156cb1b9c2c 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -805,6 +805,9 @@ void __bio_add_page(struct bio *bio, struct page *page,
 
 	bio->bi_iter.bi_size += len;
 	bio->bi_vcnt++;
+
+	if (PageWorkingset(page))
+		bio_set_flag(bio, BIO_WORKINGSET);
 }
 EXPORT_SYMBOL_GPL(__bio_add_page);
 
diff --git a/block/blk-core.c b/block/blk-core.c
index 5d1fc8e17dd1..5993922d63fb 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -36,6 +36,7 @@
 #include <linux/blk-cgroup.h>
 #include <linux/debugfs.h>
 #include <linux/bpf.h>
+#include <linux/psi.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/block.h>
@@ -1127,6 +1128,10 @@ EXPORT_SYMBOL_GPL(direct_make_request);
  */
 blk_qc_t submit_bio(struct bio *bio)
 {
+	bool workingset_read = false;
+	unsigned long pflags;
+	blk_qc_t ret;
+
 	/*
 	 * If it's a regular read/write or a barrier with data attached,
 	 * go through the normal accounting stuff before submission.
@@ -1142,6 +1147,8 @@ blk_qc_t submit_bio(struct bio *bio)
 		if (op_is_write(bio_op(bio))) {
 			count_vm_events(PGPGOUT, count);
 		} else {
+			if (bio_flagged(bio, BIO_WORKINGSET))
+				workingset_read = true;
 			task_io_account_read(bio->bi_iter.bi_size);
 			count_vm_events(PGPGIN, count);
 		}
@@ -1156,7 +1163,21 @@ blk_qc_t submit_bio(struct bio *bio)
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
index 6a53799c3fe2..2f77e3446760 100644
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

