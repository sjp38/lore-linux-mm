Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CE78C32751
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:33:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D284C206B8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:33:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D284C206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 590518E0007; Wed, 31 Jul 2019 22:33:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 519C98E0001; Wed, 31 Jul 2019 22:33:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42EC58E0007; Wed, 31 Jul 2019 22:33:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F61C8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:33:28 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e20so44655526pfd.3
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:33:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0PxqOxr1HKVjo3540PJp0gfmBwwVWbrNktsrkewzctc=;
        b=WbBepw63iSMpWkbLEWRAIhQeAqX56dzIHXmO0PvTD6U7HCXfSsmZNfKc/uz00oJZK4
         obxAV2s/eg9POsgTgfjLfsKxeYRmqmL9fFl3jBxxOcBFDHythmHP+lp2zb9cbHTavXh+
         MTOqOmDNu2Vb+Z6hRdVKvkbb6LVTR2M9rf3qs3G9iddxqGHPRpCaEFjX9yrAwX5izI7q
         DfkBwfTNLx+O7wyz476rtWHd5F9WdAagChwVQVbbd0GytN4WQLAzyQjSPnX1l3en6XYb
         89TdQ+RIoMJNMMF2ZYxOKtARiFgLZXvfg272JfQUojE5tA+r3isNUfFguz4bd0a5yLB9
         c1LQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXQCSFk2IqltnHjKTCuKUyAuVjz3uQ+h1NsROqRHBapyf3Yd5ft
	tXBI3NHnD16nq84IfnHaSNH83wCQWbqmoCWwjYARggG8l2Yqr3YSD/qdi7Fa2L9JX/H7HnUEInU
	a51H4ybuAGACmiHtHQj0AsZ6dIEqOfydI62LE9LrSCNWIS5QeOh81OdfYY0wNGYs=
X-Received: by 2002:a17:902:d917:: with SMTP id c23mr123375638plz.248.1564626807724;
        Wed, 31 Jul 2019 19:33:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8CHZg1TpCenMvHTS6vwopxNbTUTooK+1KKUxtShLY+BSa1WwwrYDc5PjXddXc7WR9F0wx
X-Received: by 2002:a17:902:d917:: with SMTP id c23mr123375578plz.248.1564626806492;
        Wed, 31 Jul 2019 19:33:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564626806; cv=none;
        d=google.com; s=arc-20160816;
        b=f06sKW9W1b3r3k1M7QBCWiCv5thgen5eYh0W/JZwex1uHh5ptQGFKV/t5uyySYIBFR
         /uTrMRR2vzxqQM0Wt1TsgOJigya2f679Mk7UQln//Bcbya9Jd8m1G93pjLtuIouSR8O8
         6462OQ6u//kTbmSprOCWD4/2mJwvAFIw1HCr0X5Cv8/EcFC5C7NSSPq84J/gI0mU9iPE
         txmMbOfxq59VhnbnnUH7XZsLiaQ4+L/ZcUHj9qh4tYgArDrNSKbh6J62tRCbTmJ8x1bq
         zkJ0V/Y8ngAOwAcSaZii/wEWl1SYcXfQ/Ba1XCWon8o/iXn0lb1J47gij0xkv2ul7b3I
         +qCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=0PxqOxr1HKVjo3540PJp0gfmBwwVWbrNktsrkewzctc=;
        b=jqT6MVGT1Ov9vjkPCJae3Lg0+jYwHLCwYcECAiNvXI0h5Q0yq8UJjM/ATNEHnLFePW
         LMFI+FuLYXctKHWPV9HrCKAakKY7b1AJecBa8Nv+LqNMxnXehO6VTJnnPo6HOua6NFQx
         oH1ekVeUc78U1Wd3z+eNF66DF4rg5T1cFJ7p+Pw8APTqauwBUN4rzY9a0ZrGx3uEIMxs
         gc6hHRfL2iyqh6BVEadf4dBOjzGePqXrgV4mLbGMy/dQe8PzmWp/J2XYVfADYNHxOgeu
         abb92/k38YUlS/RyI8CkXcDJVR7yEzZP+yTa8P5sppx/b5EmyLdVpnCFCz5LPF1liJbC
         qKjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id m45si2824381pje.39.2019.07.31.19.33.26
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:33:26 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 3CD9043D7CA
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 12:33:25 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eB-0003ap-0r; Thu, 01 Aug 2019 12:16:51 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fG-0001l1-V0; Thu, 01 Aug 2019 12:17:58 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 10/24] xfs: fix missed wakeup on l_flush_wait
Date: Thu,  1 Aug 2019 12:17:38 +1000
Message-Id: <20190801021752.4986-11-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=fwyzoN0nAAAA:8
	a=FOH2dFAWAAAA:8 a=20KFwNOVAAAA:8 a=TIbIJjZQYPkjqnKAcywA:9
	a=Sc3RvPAMVtkGz6dGeUiH:22 a=i3VuKzQdj-NEYjvDI-p3:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Rik van Riel <riel@surriel.com>

The code in xlog_wait uses the spinlock to make adding the task to
the wait queue, and setting the task state to UNINTERRUPTIBLE atomic
with respect to the waker.

Doing the wakeup after releasing the spinlock opens up the following
race condition:

Task 1					task 2
add task to wait queue
					wake up task
set task state to UNINTERRUPTIBLE

This issue was found through code inspection as a result of kworkers
being observed stuck in UNINTERRUPTIBLE state with an empty
wait queue. It is rare and largely unreproducable.

Simply moving the spin_unlock to after the wake_up_all results
in the waker not being able to see a task on the waitqueue before
it has set its state to UNINTERRUPTIBLE.

This bug dates back to the conversion of this code to generic
waitqueue infrastructure from a counting semaphore back in 2008
which didn't place the wakeups consistently w.r.t. to the relevant
spin locks.

[dchinner: Also fix a similar issue in the shutdown path on
xc_commit_wait. Update commit log with more details of the issue.]

Fixes: d748c62367eb ("[XFS] Convert l_flushsema to a sv_t")
Reported-by: Chris Mason <clm@fb.com>
Signed-off-by: Rik van Riel <riel@surriel.com>
Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_log.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/xfs/xfs_log.c b/fs/xfs/xfs_log.c
index 7bdea629e749..b78c5e95bbba 100644
--- a/fs/xfs/xfs_log.c
+++ b/fs/xfs/xfs_log.c
@@ -2630,7 +2630,6 @@ xlog_state_do_callback(
 	int		   funcdidcallbacks; /* flag: function did callbacks */
 	int		   repeats;	/* for issuing console warnings if
 					 * looping too many times */
-	int		   wake = 0;
 
 	spin_lock(&log->l_icloglock);
 	first_iclog = iclog = log->l_iclog;
@@ -2826,11 +2825,9 @@ xlog_state_do_callback(
 #endif
 
 	if (log->l_iclog->ic_state & (XLOG_STATE_ACTIVE|XLOG_STATE_IOERROR))
-		wake = 1;
-	spin_unlock(&log->l_icloglock);
-
-	if (wake)
 		wake_up_all(&log->l_flush_wait);
+
+	spin_unlock(&log->l_icloglock);
 }
 
 
@@ -3930,7 +3927,9 @@ xfs_log_force_umount(
 	 * item committed callback functions will do this again under lock to
 	 * avoid races.
 	 */
+	spin_lock(&log->l_cilp->xc_push_lock);
 	wake_up_all(&log->l_cilp->xc_commit_wait);
+	spin_unlock(&log->l_cilp->xc_push_lock);
 	xlog_state_do_callback(log, true, NULL);
 
 #ifdef XFSERRORDEBUG
-- 
2.22.0

