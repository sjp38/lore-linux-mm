Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DATE_IN_FUTURE_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CF03C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:09:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A8BA206BA
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:09:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A8BA206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D2C16B000C; Wed, 27 Mar 2019 13:09:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70DCF6B000E; Wed, 27 Mar 2019 13:09:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EA806B000D; Wed, 27 Mar 2019 13:09:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB8616B000E
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 13:09:32 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 73so14456630pga.18
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 10:09:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=FdRMFnk0K2CXCQt2IydJOxzkV2BiPw7I3vvs+rcgIiY=;
        b=AWZr2Me3a10UVNDmZSyR3dWQW2tZ8vrWK+unb3fhivYiBsqCYWiTKaAJN8hlVn/tqH
         OMBPQUknxvoSvkgKFplV7jd90S0WVDMRWaAign1L476tTVGZ4UYMpfbLPmD5Ukvtgs0a
         0wi7me5LlWIhB0dZjXspWQEw99diS1e2uRjpmhKe0xdOXjInCjyDEgExc8ZbogrM3Rhq
         g7LfmYR1rHIZFo0E+WFivh36pOGhgsyckIKTyXFK3CHIJcEHRlgg6EaNPqKI44jGFc4i
         iRrorSBhsl50SuqgWO9q9oBiDOvf/JnopJizVQ+9TseaRWFOYLkUFZwSWy3rI09kfbig
         MHwg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAWpyBR6E9wlEqUBbFjXJKobxJv6UQD0VMVVzRlOLh0yoOf8Plp5
	CMN4RQho3JzmBYsOGO1bf1g72N31sqR65lFbV6S92fi3t8aWiFJqVMfgAVIm0WbzEpO+h5YgYzo
	no0hfHkyNJtClhh2YT9Hurmb0u1QeI5nrweGTqIgb+kXlnLEGSriW7MOWZEjRw1KPIg==
X-Received: by 2002:a63:1d20:: with SMTP id d32mr35678076pgd.49.1553706572594;
        Wed, 27 Mar 2019 10:09:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNc1+PP8umJxgu9jnhgm7+bAh7dMQ1ipSWolarbQGghl2lfY9f3Mv6KHMwP10vXou02Z5y
X-Received: by 2002:a63:1d20:: with SMTP id d32mr35677932pgd.49.1553706571042;
        Wed, 27 Mar 2019 10:09:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553706571; cv=none;
        d=google.com; s=arc-20160816;
        b=r0gKt36ZVPYFIo6gTeWzwCQMcnCCpSMlMSekdjtvauHWvYmU58ySNH4Mf9vjNI7BYR
         6WPolNJHo5Xhf+rZjz7E/zpBNi4kfr+JHuPEUwdBvE60inRcbizyzzemGU3KQ8VHyPYJ
         PzJKIbF8I6o0KT/ytC/E4sNI0+APru4fPhMTE81SJPBukSD/GIwHxZ7RJWx4IHbz1XU3
         a3PfJEVslpA/Ex5MzHQNW8gbE0Ghmf8ESv0vcn3i6Uamw7ykmOoQRpew0tn9CBzIQjEK
         ZNFqab1ekyzUGypF0DIHVit4DqxPZBYPGnnpM/A+tuebto3P7EzKwnpF+0GA/TfwZAlI
         y1+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=FdRMFnk0K2CXCQt2IydJOxzkV2BiPw7I3vvs+rcgIiY=;
        b=lj0gMgNJw/1ycOeEX/vdhjWaiw5szC5HxFuisIHWxASVUDRFDVM7OLqslC2ZpumIPp
         n5cU0SkGGABTM5pLrAUi1uR4f/Ivn+MAWGCIRS3SpGi+xxNgvLB21Ij3lK08GvEgLNDe
         HCDBR7HOHS8Iwtrh5w2dwxkIUAKZRLmxlmTHCq5O4gjwtDQ3D+2GYrUIePlt/RuglJ8L
         jm6Tub7XeGnnJaNea3511FqzFV3EmnS9k9VoV5XhsIU3CDJQZCY6w3WPDxRwQXIU3PFi
         YxcSSBmfXLhQEC7mTSRrmmxQOTW+uZcvqdi6HYcQugnFQEq0CPrcmeUEacCnoC8Qs6HQ
         zUjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id n22si19678465plp.296.2019.03.27.10.09.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Mar 2019 10:09:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) client-ip=208.91.0.189;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost2.vmware.com (10.113.161.72) by
 EX13-EDG-OU-001.vmware.com (10.113.208.155) with Microsoft SMTP Server id
 15.0.1156.6; Wed, 27 Mar 2019 10:09:16 -0700
Received: from namit-esx4.eng.vmware.com (sc2-hs2-general-dhcp-219-51.eng.vmware.com [10.172.219.51])
	by sc9-mailhost2.vmware.com (Postfix) with ESMTP id D5241B2125;
	Wed, 27 Mar 2019 13:09:29 -0400 (EDT)
From: Nadav Amit <namit@vmware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann
	<arnd@arndb.de>
CC: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
	<virtualization@lists.linux-foundation.org>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, "VMware, Inc." <pv-drivers@vmware.com>,
	Julien Freche <jfreche@vmware.com>, Nadav Amit <nadav.amit@gmail.com>, Nadav
 Amit <namit@vmware.com>
Subject: [PATCH v2 3/4] vmw_balloon: add memory shrinker
Date: Thu, 28 Mar 2019 01:07:17 +0000
Message-ID: <20190328010718.2248-4-namit@vmware.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190328010718.2248-1-namit@vmware.com>
References: <20190328010718.2248-1-namit@vmware.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-001.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add a shrinker to the VMware balloon to prevent out-of-memory events.
We reuse the deflate logic for this matter. Deadlocks should not happen,
as no memory allocation is performed while the locks of the
communication (batch/page) and page-list are taken. In the unlikely
event in which the configuration semaphore is taken for write we bail
out and fail gracefully (causing processes to be killed).

Once the shrinker is called, inflation is postponed for few seconds.
The timeout is updated without any lock, but this should not cause any
races, as it is written and read atomically.

This feature is disabled by default, since it might cause performance
degradation.

Reviewed-by: Xavier Deguillard <xdeguillard@vmware.com>
Signed-off-by: Nadav Amit <namit@vmware.com>
---
 drivers/misc/vmw_balloon.c | 133 ++++++++++++++++++++++++++++++++++++-
 1 file changed, 131 insertions(+), 2 deletions(-)

diff --git a/drivers/misc/vmw_balloon.c b/drivers/misc/vmw_balloon.c
index 2136f6ad97d3..59d3c0202dcc 100644
--- a/drivers/misc/vmw_balloon.c
+++ b/drivers/misc/vmw_balloon.c
@@ -40,6 +40,15 @@ MODULE_ALIAS("dmi:*:svnVMware*:*");
 MODULE_ALIAS("vmware_vmmemctl");
 MODULE_LICENSE("GPL");
 
+bool __read_mostly vmwballoon_shrinker_enable;
+module_param(vmwballoon_shrinker_enable, bool, 0444);
+MODULE_PARM_DESC(vmwballoon_shrinker_enable,
+	"Enable non-cooperative out-of-memory protection. Disabled by default as it may degrade performance.");
+
+/* Delay in seconds after shrink before inflation. */
+#define VMBALLOON_SHRINK_DELAY		(5)
+
+/* Maximum number of refused pages we accumulate during inflation cycle */
 #define VMW_BALLOON_MAX_REFUSED		16
 
 /* Magic number for the balloon mount-point */
@@ -217,12 +226,13 @@ enum vmballoon_stat_general {
 	VMW_BALLOON_STAT_TIMER,
 	VMW_BALLOON_STAT_DOORBELL,
 	VMW_BALLOON_STAT_RESET,
-	VMW_BALLOON_STAT_LAST = VMW_BALLOON_STAT_RESET
+	VMW_BALLOON_STAT_SHRINK,
+	VMW_BALLOON_STAT_SHRINK_FREE,
+	VMW_BALLOON_STAT_LAST = VMW_BALLOON_STAT_SHRINK_FREE
 };
 
 #define VMW_BALLOON_STAT_NUM		(VMW_BALLOON_STAT_LAST + 1)
 
-
 static DEFINE_STATIC_KEY_TRUE(vmw_balloon_batching);
 static DEFINE_STATIC_KEY_FALSE(balloon_stat_enabled);
 
@@ -321,6 +331,15 @@ struct vmballoon {
 	 */
 	struct page *page;
 
+	/**
+	 * @shrink_timeout: timeout until the next inflation.
+	 *
+	 * After an shrink event, indicates the time in jiffies after which
+	 * inflation is allowed again. Can be written concurrently with reads,
+	 * so must use READ_ONCE/WRITE_ONCE when accessing.
+	 */
+	unsigned long shrink_timeout;
+
 	/* statistics */
 	struct vmballoon_stats *stats;
 
@@ -361,6 +380,20 @@ struct vmballoon {
 	 * Lock ordering: @conf_sem -> @comm_lock .
 	 */
 	spinlock_t comm_lock;
+
+	/**
+	 * @shrinker: shrinker interface that is used to avoid over-inflation.
+	 */
+	struct shrinker shrinker;
+
+	/**
+	 * @shrinker_registered: whether the shrinker was registered.
+	 *
+	 * The shrinker interface does not handle gracefully the removal of
+	 * shrinker that was not registered before. This indication allows to
+	 * simplify the unregistration process.
+	 */
+	bool shrinker_registered;
 };
 
 static struct vmballoon balloon;
@@ -935,6 +968,10 @@ static int64_t vmballoon_change(struct vmballoon *b)
 	    size - target < vmballoon_page_in_frames(VMW_BALLOON_2M_PAGE))
 		return 0;
 
+	/* If an out-of-memory recently occurred, inflation is disallowed. */
+	if (target > size && time_before(jiffies, READ_ONCE(b->shrink_timeout)))
+		return 0;
+
 	return target - size;
 }
 
@@ -1430,6 +1467,90 @@ static void vmballoon_work(struct work_struct *work)
 
 }
 
+/**
+ * vmballoon_shrinker_scan() - deflate the balloon due to memory pressure.
+ * @shrinker: pointer to the balloon shrinker.
+ * @sc: page reclaim information.
+ *
+ * Returns: number of pages that were freed during deflation.
+ */
+static unsigned long vmballoon_shrinker_scan(struct shrinker *shrinker,
+					     struct shrink_control *sc)
+{
+	struct vmballoon *b = &balloon;
+	unsigned long deflated_frames;
+
+	pr_debug("%s - size: %llu", __func__, atomic64_read(&b->size));
+
+	vmballoon_stats_gen_inc(b, VMW_BALLOON_STAT_SHRINK);
+
+	/*
+	 * If the lock is also contended for read, we cannot easily reclaim and
+	 * we bail out.
+	 */
+	if (!down_read_trylock(&b->conf_sem))
+		return 0;
+
+	deflated_frames = vmballoon_deflate(b, sc->nr_to_scan, true);
+
+	vmballoon_stats_gen_add(b, VMW_BALLOON_STAT_SHRINK_FREE,
+				deflated_frames);
+
+	/*
+	 * Delay future inflation for some time to mitigate the situations in
+	 * which balloon continuously grows and shrinks. Use WRITE_ONCE() since
+	 * the access is asynchronous.
+	 */
+	WRITE_ONCE(b->shrink_timeout, jiffies + HZ * VMBALLOON_SHRINK_DELAY);
+
+	up_read(&b->conf_sem);
+
+	return deflated_frames;
+}
+
+/**
+ * vmballoon_shrinker_count() - return the number of ballooned pages.
+ * @shrinker: pointer to the balloon shrinker.
+ * @sc: page reclaim information.
+ *
+ * Returns: number of 4k pages that are allocated for the balloon and can
+ *	    therefore be reclaimed under pressure.
+ */
+static unsigned long vmballoon_shrinker_count(struct shrinker *shrinker,
+					      struct shrink_control *sc)
+{
+	struct vmballoon *b = &balloon;
+
+	return atomic64_read(&b->size);
+}
+
+static void vmballoon_unregister_shrinker(struct vmballoon *b)
+{
+	if (b->shrinker_registered)
+		unregister_shrinker(&b->shrinker);
+	b->shrinker_registered = false;
+}
+
+static int vmballoon_register_shrinker(struct vmballoon *b)
+{
+	int r;
+
+	/* Do nothing if the shrinker is not enabled */
+	if (!vmwballoon_shrinker_enable)
+		return 0;
+
+	b->shrinker.scan_objects = vmballoon_shrinker_scan;
+	b->shrinker.count_objects = vmballoon_shrinker_count;
+	b->shrinker.seeks = DEFAULT_SEEKS;
+
+	r = register_shrinker(&b->shrinker);
+
+	if (r == 0)
+		b->shrinker_registered = true;
+
+	return r;
+}
+
 /*
  * DEBUGFS Interface
  */
@@ -1447,6 +1568,8 @@ static const char * const vmballoon_stat_names[] = {
 	[VMW_BALLOON_STAT_TIMER]		= "timer",
 	[VMW_BALLOON_STAT_DOORBELL]		= "doorbell",
 	[VMW_BALLOON_STAT_RESET]		= "reset",
+	[VMW_BALLOON_STAT_SHRINK]		= "shrink",
+	[VMW_BALLOON_STAT_SHRINK_FREE]		= "shrinkFree"
 };
 
 static int vmballoon_enable_stats(struct vmballoon *b)
@@ -1780,6 +1903,10 @@ static int __init vmballoon_init(void)
 
 	INIT_DELAYED_WORK(&balloon.dwork, vmballoon_work);
 
+	error = vmballoon_register_shrinker(&balloon);
+	if (error)
+		goto fail;
+
 	error = vmballoon_debugfs_init(&balloon);
 	if (error)
 		goto fail;
@@ -1805,6 +1932,7 @@ static int __init vmballoon_init(void)
 
 	return 0;
 fail:
+	vmballoon_unregister_shrinker(&balloon);
 	vmballoon_compaction_deinit(&balloon);
 	return error;
 }
@@ -1819,6 +1947,7 @@ late_initcall(vmballoon_init);
 
 static void __exit vmballoon_exit(void)
 {
+	vmballoon_unregister_shrinker(&balloon);
 	vmballoon_vmci_cleanup(&balloon);
 	cancel_delayed_work_sync(&balloon.dwork);
 
-- 
2.19.1

