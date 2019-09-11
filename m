Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59AFFECDE20
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 15:06:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28E2F207FC
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 15:06:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28E2F207FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB8A36B0271; Wed, 11 Sep 2019 11:06:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C69306B0272; Wed, 11 Sep 2019 11:06:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B58626B0273; Wed, 11 Sep 2019 11:06:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0157.hostedemail.com [216.40.44.157])
	by kanga.kvack.org (Postfix) with ESMTP id 91E656B0271
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 11:06:24 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 4953F37F1
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:06:24 +0000 (UTC)
X-FDA: 75922965888.14.blade57_37c9200727328
X-HE-Tag: blade57_37c9200727328
X-Filterd-Recvd-Size: 3499
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:06:23 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 63CF5307D925;
	Wed, 11 Sep 2019 15:06:22 +0000 (UTC)
Received: from llong.com (ovpn-125-196.rdu2.redhat.com [10.10.125.196])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D361D5D9E2;
	Wed, 11 Sep 2019 15:06:19 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Will Deacon <will.deacon@arm.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Davidlohr Bueso <dave@stgolabs.net>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH 4/5] locking/rwsem: Enable timeout check when staying in the OSQ
Date: Wed, 11 Sep 2019 16:05:36 +0100
Message-Id: <20190911150537.19527-5-longman@redhat.com>
In-Reply-To: <20190911150537.19527-1-longman@redhat.com>
References: <20190911150537.19527-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Wed, 11 Sep 2019 15:06:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Use the break function allowed by the new osq_lock() to enable early
break from the OSQ when a timeout value is specified and expiration
time has been reached.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem.c | 35 +++++++++++++++++++++++++++++++----
 1 file changed, 31 insertions(+), 4 deletions(-)

diff --git a/kernel/locking/rwsem.c b/kernel/locking/rwsem.c
index c15926ecb21e..78708097162a 100644
--- a/kernel/locking/rwsem.c
+++ b/kernel/locking/rwsem.c
@@ -794,23 +794,50 @@ static inline u64 rwsem_rspin_threshold(struct rw_semaphore *sem)
 	return sched_clock() + delta;
 }
 
+struct rwsem_break_arg {
+	u64 timeout;
+	int loopcnt;
+};
+
+static bool rwsem_osq_break(void *brk_arg)
+{
+	struct rwsem_break_arg *arg = brk_arg;
+
+	arg->loopcnt++;
+	/*
+	 * Check sched_clock() only once every 256 iterations.
+	 */
+	if (!(arg->loopcnt++ & 0xff) && (sched_clock() >= arg->timeout))
+		return true;
+	return false;
+}
+
 static bool rwsem_optimistic_spin(struct rw_semaphore *sem, bool wlock,
 				  ktime_t timeout)
 {
-	bool taken = false;
+	bool taken = false, locked;
 	int prev_owner_state = OWNER_NULL;
 	int loop = 0;
 	u64 rspin_threshold = 0, curtime;
+	struct rwsem_break_arg break_arg;
 	unsigned long nonspinnable = wlock ? RWSEM_WR_NONSPINNABLE
 					   : RWSEM_RD_NONSPINNABLE;
 
 	preempt_disable();
 
 	/* sem->wait_lock should not be held when doing optimistic spinning */
-	if (!osq_lock(&sem->osq, NULL, NULL))
-		goto done;
+	if (timeout) {
+		break_arg.timeout = ktime_to_ns(timeout);
+		break_arg.loopcnt = 0;
+		locked = osq_lock(&sem->osq, rwsem_osq_break, &break_arg);
+		curtime = sched_clock();
+	} else {
+		locked = osq_lock(&sem->osq, NULL, NULL);
+		curtime = 0;
+	}
 
-	curtime = timeout ? sched_clock() : 0;
+	if (!locked)
+		goto done;
 
 	/*
 	 * Optimistically spin on the owner field and attempt to acquire the
-- 
2.18.1


