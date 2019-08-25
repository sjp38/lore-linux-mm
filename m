Return-Path: <SRS0=zwjV=WV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEA4EC3A5A4
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:54:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71C5322CE3
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:54:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="VrpFC1Sa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71C5322CE3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28EDF6B04FF; Sat, 24 Aug 2019 20:54:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 218586B0501; Sat, 24 Aug 2019 20:54:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17C576B0502; Sat, 24 Aug 2019 20:54:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0058.hostedemail.com [216.40.44.58])
	by kanga.kvack.org (Postfix) with ESMTP id EDF2E6B04FF
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 20:54:55 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 91B514820
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:54:55 +0000 (UTC)
X-FDA: 75859130550.08.space69_481215c01285b
X-HE-Tag: space69_481215c01285b
X-Filterd-Recvd-Size: 3521
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:54:55 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C7F3A2190F;
	Sun, 25 Aug 2019 00:54:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566694494;
	bh=YpmFU5fs/NJMrrrVE0ZhpttDS0wDvYzWyG+8KwPKHfM=;
	h=Date:From:To:Subject:From;
	b=VrpFC1Saajfsx9VLQwtvXAPYy7hXdVbLfCrBXyb4Wm4IwKNAet80OW8STG8HkbGcU
	 Ys2WyzPJg/SLAeXcwZdtRgjbuCxmRaNTHYhqmelHe33dSrdlxW8tF31mhLBWssL+Iz
	 UHP4cbGrg4r+RMlWxnvY3HN+CbP6lCvnjv0HQg8I=
Date: Sat, 24 Aug 2019 17:54:53 -0700
From: akpm@linux-foundation.org
To: akpm@linux-foundation.org, caspar@linux.alibaba.com,
 hannes@cmpxchg.org, joseph.qi@linux.alibaba.com,
 kerneljasonxing@linux.alibaba.com, linux-mm@kvack.org, mingo@redhat.com,
 mm-commits@vger.kernel.org, peterz@infradead.org,
 stable@vger.kernel.org, surenb@google.com,
 torvalds@linux-foundation.org
Subject:  [patch 06/11] psi: get poll_work to run when calling poll
 syscall next time
Message-ID: <20190825005453.mWr0lsMZh%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Xing <kerneljasonxing@linux.alibaba.com>
Subject: psi: get poll_work to run when calling poll syscall next time

Only when calling the poll syscall the first time can user receive POLLPRI
correctly.  After that, user always fails to acquire the event signal.

Reproduce case:
1. Get the monitor code in Documentation/accounting/psi.txt
2. Run it, and wait for the event triggered.
3. Kill and restart the process.

The question is why we can end up with poll_scheduled = 1 but the work not
running (which would reset it to 0).  And the answer is because the
scheduling side sees group->poll_kworker under RCU protection and then
schedules it, but here we cancel the work and destroy the worker.  The
cancel needs to pair with resetting the poll_scheduled flag.

Link: http://lkml.kernel.org/r/1566357985-97781-1-git-send-email-joseph.qi@linux.alibaba.com
Signed-off-by: Jason Xing <kerneljasonxing@linux.alibaba.com>
Signed-off-by: Joseph Qi <joseph.qi@linux.alibaba.com>
Reviewed-by: Caspar Zhang <caspar@linux.alibaba.com>
Reviewed-by: Suren Baghdasaryan <surenb@google.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 kernel/sched/psi.c |    8 ++++++++
 1 file changed, 8 insertions(+)

--- a/kernel/sched/psi.c~psi-get-poll_work-to-run-when-calling-poll-syscall-next-time
+++ a/kernel/sched/psi.c
@@ -1131,7 +1131,15 @@ static void psi_trigger_destroy(struct k
 	 * deadlock while waiting for psi_poll_work to acquire trigger_lock
 	 */
 	if (kworker_to_destroy) {
+		/*
+		 * After the RCU grace period has expired, the worker
+		 * can no longer be found through group->poll_kworker.
+		 * But it might have been already scheduled before
+		 * that - deschedule it cleanly before destroying it.
+		 */
 		kthread_cancel_delayed_work_sync(&group->poll_work);
+		atomic_set(&group->poll_scheduled, 0);
+
 		kthread_destroy_worker(kworker_to_destroy);
 	}
 	kfree(t);
_

