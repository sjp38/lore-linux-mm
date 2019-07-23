Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF7D7C41517
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 20:42:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 505F0218D4
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 20:42:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="Br7NzGnD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 505F0218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6F586B0003; Tue, 23 Jul 2019 16:42:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1F228E0003; Tue, 23 Jul 2019 16:42:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90E618E0002; Tue, 23 Jul 2019 16:42:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 541006B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 16:42:11 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z14so19694170pgr.22
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:42:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=46Sn1TjB+7cXjJ1oCwsYotRCUk4eF4IUbdpH2VBpW9w=;
        b=gcz++ZXBWGyR1hnGCAQ+DLvBNmedJLby71LFSDGoX07G0816jaHzOvB4kkyl1QoSaW
         urB2U62SgtgHSh1ClvOwa3nqYPbtQTSvytyxgU5lQPbSMm8nOtjR4vkwvLvRUHL4Zc8t
         RIZKPzp7ICchPK199s+y6m/POeOVkOT5+9IllTR7f6Fof4aYrb9tSfUf7pjhWMISk+dH
         IQbt4Ql51winlSgi+NtLdDOWzggAJKrecioqQNgaQqrVUnKmv23CjwcXY/MLYfkWyD68
         WH+tuSMe22b8i3ulTPo1jIbQvJf2Kl5phENTlPe8Dg/ZgWHqxrkwWux1sWaM74Dxp+Kk
         +8gA==
X-Gm-Message-State: APjAAAVLviRbRsmC8Hz5Aes/F2Mkb6b2X6TQC+knGN3R3bwq1NnM871t
	6eX34RUyCOLyOZ3QBxlA9yeoPLaTkBsFLodr9r9ndhC+ngC9L/ypliALumRXxsRPuGMFO0zsLjP
	b5fIRlzcJfQQKrMBIo8FqFip8rryZlOWZkeCK6Ew83CVGmddkuNEMaxD3lXCkqz5N2w==
X-Received: by 2002:a17:902:1aa:: with SMTP id b39mr33881645plb.333.1563914530849;
        Tue, 23 Jul 2019 13:42:10 -0700 (PDT)
X-Received: by 2002:a17:902:1aa:: with SMTP id b39mr33881590plb.333.1563914529849;
        Tue, 23 Jul 2019 13:42:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563914529; cv=none;
        d=google.com; s=arc-20160816;
        b=sFhGHhZOmxYar6fW2mm+BJkVT4Dw5cgU+B4jwJXh88M+kSm88Lc8c96m/O+ZAs/oAn
         0Ef0NrB9hBkZCiAGjOA4XzEcQ3evmVRjq/DsGqIFVxQrcwVSJ+ov1LVmjT69GrOYjy3w
         4+/JbN5fCWVL2NWwOylBmUpf/dwLNBtjw2Gukju6Fg3+uWXO0qRQaC60PYYBAbyR8Uuy
         lE+8sw9vCkyo3umLmSYGIJdx1KZDb+R4gNwDqOit9cb9rhMDJIbn1Tjmv/n8lSjQJxjg
         W1eApVXwzqjpIggdGe1FkvgMiLxRyWVtGhrF92fdbeVFCAOdPoM5leN//+RnWOztYqC2
         DeDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=46Sn1TjB+7cXjJ1oCwsYotRCUk4eF4IUbdpH2VBpW9w=;
        b=sNfGuZeL+ZUmioKD6NDEGgQWDN1SD6SRYaf6IUEahTUi9Pvmb+r4Vqs9/4efeyyHT3
         Gd+Kh2PL9DPvOdxCXrgwRtNpgYmG37KmVulErQyRzsJpgRiBiJ8r65bLNeylUzbacJwe
         9KFeXLuxFul5qxRyz70ezemoHQNcPlWy747DDyaTxnW/q7aI6a/j2U4I8pkaWHmgF1Gc
         TwX+Od3bPW+/EK8hpYMD6l5wub9v/rju1+dP8/83I3KmIPhjy5S+08wfXHGI1KcW9+X0
         CMupZ1Jn8JEQEuifmGT0SaGUOLZPYdJkZEOUzATS71oiOTUvtZerXfeS/Y19b+WJw2PP
         KMCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=Br7NzGnD;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 17sor53520809pjh.2.2019.07.23.13.42.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 13:42:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=Br7NzGnD;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=46Sn1TjB+7cXjJ1oCwsYotRCUk4eF4IUbdpH2VBpW9w=;
        b=Br7NzGnD5/uCHAmUbgP3kHHUnne3uBIYrLHkT3Hm0Jyj+iblE7CK2NiIlIoP+/F9pU
         01vAz3ku27SycTFXXZSK3irK4+2oOhqILT01R36pQq5zL8cSp9bP7tPG26Sif9oRY3qf
         0PGSjIRMkZxbsAsxuTMrP9jGTuePIPWJAwuqtn6tYRCVFakd06ytTSrREcFqXS1rEUOO
         nLOByE+Car72iOAp7zUMnMsh4fAUlmL3oeI8qX9R+sm2mp+h0QjDlfY+G/xzmOyxGloQ
         /gu0INMxBzrUMs2JSktwTYaMrL4gmyd4KmevwUVfEIdocwgHrBWdFH7GTqrWirEsJ/Fw
         aDJw==
X-Google-Smtp-Source: APXvYqyJqnV/CGvEDEu2xDeIC1Qvo93stTXChykOGP1ABuWnCB7sJFtX0B0wjIsZWY7FJuPTVEmakQ==
X-Received: by 2002:a17:90a:7d04:: with SMTP id g4mr84685532pjl.41.1563914528974;
        Tue, 23 Jul 2019 13:42:08 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:a7f8])
        by smtp.gmail.com with ESMTPSA id g11sm41178603pgu.11.2019.07.23.13.42.07
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 13:42:08 -0700 (PDT)
Date: Tue, 23 Jul 2019 16:42:06 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Dave Chinner <david@fromorbit.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] psi: annotate refault stalls from IO submission
Message-ID: <20190723204206.GA30522@cmpxchg.org>
References: <20190722201337.19180-1-hannes@cmpxchg.org>
 <20190723000226.GV7777@dread.disaster.area>
 <20190723190438.GA22541@cmpxchg.org>
 <2d80cfdb-f5e0-54f1-29a3-a05dee5b94eb@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2d80cfdb-f5e0-54f1-29a3-a05dee5b94eb@kernel.dk>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 01:34:50PM -0600, Jens Axboe wrote:
> On 7/23/19 1:04 PM, Johannes Weiner wrote:
> > CCing Jens for bio layer stuff
> > 
> > On Tue, Jul 23, 2019 at 10:02:26AM +1000, Dave Chinner wrote:
> >> Even better: If this memstall and "refault" check is needed to
> >> account for bio submission blocking, then page cache iteration is
> >> the wrong place to be doing this check. It should be done entirely
> >> in the bio code when adding pages to the bio because we'll only ever
> >> be doing page cache read IO on page cache misses. i.e. this isn't
> >> dependent on adding a new page to the LRU or not - if we add a new
> >> page then we are going to be doing IO and so this does not require
> >> magic pixie dust at the page cache iteration level
> > 
> > That could work. I had it at the page cache level because that's
> > logically where the refault occurs. But PG_workingset encodes
> > everything we need from the page cache layer and is available where
> > the actual stall occurs, so we should be able to push it down.
> > 
> >> e.g. bio_add_page_memstall() can do the working set check and then
> >> set a flag on the bio to say it contains a memstall page. Then on
> >> submission of the bio the memstall condition can be cleared.
> > 
> > A separate bio_add_page_memstall() would have all the problems you
> > pointed out with the original patch: it's magic, people will get it
> > wrong, and it'll be hard to verify and notice regressions.
> > 
> > How about just doing it in __bio_add_page()? PG_workingset is not
> > overloaded - when we see it set, we can generally and unconditionally
> > flag the bio as containing userspace workingset pages.
> > 
> > At submission time, in conjunction with the IO direction, we can
> > clearly tell whether we are reloading userspace workingset data,
> > i.e. stalling on memory.
> > 
> > This?
> 
> Not vehemently opposed to it, even if it sucks having to test page flags
> in the hot path.

Yeah, it's not great :/ Just seems marginally better than annotating
all the callsites and maintain correctness there in the future.

> Maybe even do:
> 
> 	if (!bio_flagged(bio, BIO_WORKINGSET) && PageWorkingset(page))
> 		bio_set_flag(bio, BIO_WORKINGSET);
> 
> to at least avoid it for the (common?) case where multiple pages are
> marked as workingset.

Sounds good. If refaults occur, most likely the whole readahead batch
has that flag set, so I've added that. I've also marked the page test
unlikely.

This way we have no jumps in the most common path (no refaults), one
jump in the second most common (bit already set), and the double for
the least likely case of hitting the first refault page in a batch.

Updated patch below.

---
From 1b3888bdf075f86f226af4e350c8a88435d1fe8e Mon Sep 17 00:00:00 2001
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
index 29cd6cf4da51..4dd9ea0b068b 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -805,6 +805,9 @@ void __bio_add_page(struct bio *bio, struct page *page,
 
 	bio->bi_iter.bi_size += len;
 	bio->bi_vcnt++;
+
+	if (!bio_flagged(bio, BIO_WORKINGSET) && unlikely(PageWorkingset(page)))
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

