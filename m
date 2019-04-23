Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B86B1C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 07:05:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 686002148D
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 07:05:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 686002148D
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51ECC6B0007; Wed, 24 Apr 2019 03:05:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 456356B000C; Wed, 24 Apr 2019 03:05:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A7B96B000D; Wed, 24 Apr 2019 03:05:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id DA8A36B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:05:34 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s22so11896643plq.1
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 00:05:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=Qomb4bQrj0FpHocZBe5A1sgLN2lWduvhJqbmQ7wL5d8=;
        b=VcUKQ1uU9ei01DpXct3hGW4nGfdMzt/dy8lhbt8/G8ivOcblEmNphXRMUQ1BYLzjeV
         l6RVeaAASTGPZW2IyAxPFcG9s8CsNk5kojmDj2FymdQ8b9oZSrFvgZT534+eLHSst4pL
         2m86h/a2naALjCEcub+zWorgog/vxKROG4hB6TKMwmRXb80An3GKM8S/8A1FI6MMgrTG
         fu8Sfc2EYYAXXJiplLPxr1XWNzWA6tE06Ic8yr4TtyOxGr+rdLxzQaUWCuGcLNWsodRV
         TVNo3KiSyNP46sh/yonffX7dE6YFvLYVKsr1JgYxwdVHe4cUyfbri+6o2wJ+TP6aFgpP
         H07A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAV2g1fDR908etR8JGDjX6jovDJ4l0ZTXMXlhTyOl97mN1493Pdd
	yowUmpGinyjy+afrGwXkVpH5c8XCn2e+o/hbpsMA60yYBRCXbD/+pHIGbPDYBXkbYYScSREBYBP
	xvIlAjuDQWOhUIiNM1dGlvK5CtV6kta0JSaQzON644hh+D/VO1cl1yHyYjdllrRha8g==
X-Received: by 2002:a63:d043:: with SMTP id s3mr28451258pgi.359.1556089534435;
        Wed, 24 Apr 2019 00:05:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTlC406v2KOWSJM7XAoey7bQsf4F38aGttWmvLLlbkHl2khW2xMHbno9XfxUUUq/mGCMDy
X-Received: by 2002:a63:d043:: with SMTP id s3mr28451117pgi.359.1556089532557;
        Wed, 24 Apr 2019 00:05:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556089532; cv=none;
        d=google.com; s=arc-20160816;
        b=LpNVkQF1V1+bbl2QUNduajM6tQbQQk+FLuftMK42NzIpaCmLjl8kNRWkUuwFNnEd/S
         iv0AfJtbWrivUAKjuQe7Ug4o/7m4xNh/zmbf2Vtdk+yZiqaCiMz/thxhdUFqzPKiX4oA
         VyUT2bt5vXnFZ8sardROJFkF5ReP/vFuXFA9KSSNCRZUOLJ3R73M8HFc6hIbaMk5dHe+
         a3HPOesspXV6dPuznl+tvmOzbx5WE9EcMShJDH0PAPhgEt2gxZSo5NJvWpRN9uQQ0Joh
         dGvfeYRxSVh+VdYk1ht7y/2UrSX24eG8QcMdrTSMPk4WmX5F2pbh3FiGb/ZyWTqChUP+
         A+aw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=Qomb4bQrj0FpHocZBe5A1sgLN2lWduvhJqbmQ7wL5d8=;
        b=PayQ/8sCCYRA7PTvXr/DJun9vUEC6D6mlyI7JaRpSpKe6dPUvSl5O+sddpRGEdB+15
         Ac72baDMC29Ius1OCQIOrDy/cPNLQStw2o/3Icg5lje1A+kuuryXhksxJ5q0EpMfUSAp
         zyYwv3C3sqoJBS0iJPgIbrwDuauGgl8syLm8y85iE6kRVEd3+1V/W1v2KHTLeZ72ICBH
         80GSvQdA8dFgHgmPrjnug4qrrljEFE9ILKUAM3PylLZWIb7lTwpp1BcgCocc54l26P9N
         SY6VmNkFUzsrSFTVcSJA4Elt5CdgvOx9XTt3urh14h/5LYD+lCcTXhJSDtvy1tyj/eIN
         i6aA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id w11si17355788pge.187.2019.04.24.00.05.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 24 Apr 2019 00:05:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) client-ip=208.91.0.189;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost2.vmware.com (10.113.161.72) by
 EX13-EDG-OU-001.vmware.com (10.113.208.155) with Microsoft SMTP Server id
 15.0.1156.6; Wed, 24 Apr 2019 00:05:29 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost2.vmware.com (Postfix) with ESMTP id B56C2B2415;
	Wed, 24 Apr 2019 03:05:31 -0400 (EDT)
From: Nadav Amit <namit@vmware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Michael S. Tsirkin"
	<mst@redhat.com>
CC: Arnd Bergmann <arnd@arndb.de>, Julien Freche <jfreche@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>, Jason Wang <jasowang@redhat.com>,
	<linux-kernel@vger.kernel.org>, <virtualization@lists.linux-foundation.org>,
	<linux-mm@kvack.org>, Nadav Amit <namit@vmware.com>
Subject: [PATCH v3 3/4] vmw_balloon: add memory shrinker
Date: Tue, 23 Apr 2019 16:45:30 -0700
Message-ID: <20190423234531.29371-4-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190423234531.29371-1-namit@vmware.com>
References: <20190423234531.29371-1-namit@vmware.com>
MIME-Version: 1.0
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
index 2136f6ad97d3..4b5e939ff4c8 100644
--- a/drivers/misc/vmw_balloon.c
+++ b/drivers/misc/vmw_balloon.c
@@ -40,6 +40,15 @@ MODULE_ALIAS("dmi:*:svnVMware*:*");
 MODULE_ALIAS("vmware_vmmemctl");
 MODULE_LICENSE("GPL");
 
+static bool __read_mostly vmwballoon_shrinker_enable;
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

