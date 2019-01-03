Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0190BC43387
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 22:57:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA0522070D
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 22:57:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA0522070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 690D48E00B7; Thu,  3 Jan 2019 17:57:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 640968E00AE; Thu,  3 Jan 2019 17:57:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5098F8E00B7; Thu,  3 Jan 2019 17:57:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E8DDF8E00AE
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 17:57:15 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x15so34467353edd.2
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 14:57:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=HceLtEysvFgt7zivn0Lm6/7/xb+OF/PSJJcOZlMMatQ=;
        b=RzT2K0iYNpVdniMGPt/u0FJKHwfaSuh8REgJ8afgIWthkAlYLvJqDkFiIuhN8R4NxZ
         D5yEcbSLzK1tpJc1fblXJNCmkG99gYCiFWEpBQ3o+pKi/py4TkT4DgFDjgkj7liitymw
         PVcDCKtkd2mJUyr7unPLm97h/IEnJoBm6AaYR215wAQfI9XY1pebMlZg5JarppQV9GMS
         BRdByta8Tvq50IJjPZRdbxMQu9Tk8+kU4glKHFKq5R73WuI/vZOTULPyVBoMV+TGYxq4
         md9yvw8En55QvFEUKLPKodm5qlkEu5+zMHOHB6n/jzHWWEJR2Qw6ehQHOqVB5FixZ9S3
         xQJw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: AJcUukc7zC8qcPuLj8AQsGeBXFRg09guW2JM53Ltf8UywNvybcMNHe1a
	JdiJeVzRi1grUoigSXeD/viZcvNxfjVOY5JpfdUiTS8jUfWLGGsB5xAPDKWIz14lfir/Mez7D24
	rqux1D0P9+mOxBy+/hjQ0CbgtyjR6986YNMa4UKrIipQ/Jxr7GJ5n89bR1rRv0s0iug==
X-Received: by 2002:a17:906:f108:: with SMTP id gv8-v6mr19581011ejb.173.1546556235320;
        Thu, 03 Jan 2019 14:57:15 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7HI0ScAp1ZkEj6crVWwxgy/gGuwZFCeUIZ4s4lSi4FME0sSF9ABWdXx+atx3gNKI0X5yZW
X-Received: by 2002:a17:906:f108:: with SMTP id gv8-v6mr19580982ejb.173.1546556234302;
        Thu, 03 Jan 2019 14:57:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546556234; cv=none;
        d=google.com; s=arc-20160816;
        b=OhYQXWQ6D+HlQUmxwNd8yupQtZkQQCG526zeA1m0+YpncAmajCRIqSvwdABsDmudJT
         gd+OCZtCZMgBUFrSh+/s/3gDR9+zHdTPuvST3BQf+aOYjrdviRPKAhdP6KsKa5/2DcHy
         RVQLzj4CgAMWIa2zvCdnyz7pKQMJg+s5rmPFCaDHivaNp/7t2c+aaMvfV8XnYQX2+Aua
         dP/5DFhJHMUCTL8NK+fSk3Sbfv5Zu32qblxCDcH6TSp3oEnXazfv1NKyc1/ChF1Fxuz3
         7zrJlDJSZptWJNR3yv8Ba0FS5+UnCXZaUMqet+6sQ0hTPzKOdAXtb7nZMdfZo5CAbse1
         oelg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=HceLtEysvFgt7zivn0Lm6/7/xb+OF/PSJJcOZlMMatQ=;
        b=zHXzhUnpZ/4P9mBOYBRiPKoqMwZDoWko7r7CJAt+mUfkuk9FFdwsv2K+nXQcMu5pd5
         tb0yigMcM5EN9UhPVIcbXhkekXxYCUTsupTMJOgZ13u1nre6PzQ8ZDB2TfdEIrt51K42
         vEiQaoUdaoc97BOi4A9swiXkt0uNx2a3YlZbNXp8ibeBR7NB5rUl115Jz0HIBpp9QV7S
         9zVzOtNS2+7u6BLHpD9r7idI9XVY2hPQpiJgsuVnx9w1dFhngacCpcCJgRWKQYMzdZa9
         eRAvX4JIaPA554noNIurAYERYUY/PvsgsxmT+Jzcda1XxyP57T45r44z58MHOHj2i8Ng
         1ODw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id d8si139059edo.400.2019.01.03.14.57.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 14:57:14 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) client-ip=81.17.249.8;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id EC22798A4E
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 22:57:13 +0000 (UTC)
Received: (qmail 14609 invoked from network); 3 Jan 2019 22:57:13 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.229.96])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 3 Jan 2019 22:57:13 -0000
Date: Thu, 3 Jan 2019 22:57:12 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Qian Cai <cai@lca.pw>, Dmitry Vyukov <dvyukov@google.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	syzbot <syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	linux@dominikbrodowski.net, Michal Hocko <mhocko@suse.com>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Subject: [PATCH] mm, page_alloc: Do not wake kswapd with zone lock held
Message-ID: <20190103225712.GJ31517@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103225712.YwEKwdiu2JaCns58ov_SUN-GVR2d3FobXUY5ulwHue8@z>

syzbot reported the following regression in the latest merge window
and it was confirmed by Qian Cai that a similar bug was visible from a
different context.

======================================================
WARNING: possible circular locking dependency detected
4.20.0+ #297 Not tainted
------------------------------------------------------
syz-executor0/8529 is trying to acquire lock:
000000005e7fb829 (&pgdat->kswapd_wait){....}, at:
__wake_up_common_lock+0x19e/0x330 kernel/sched/wait.c:120

but task is already holding lock:
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: spin_lock
include/linux/spinlock.h:329 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: rmqueue_bulk
mm/page_alloc.c:2548 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: __rmqueue_pcplist
mm/page_alloc.c:3021 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: rmqueue_pcplist
mm/page_alloc.c:3050 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: rmqueue
mm/page_alloc.c:3072 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at:
get_page_from_freelist+0x1bae/0x52a0 mm/page_alloc.c:3491

It appears to be a false positive in that the only way the lock
ordering should be inverted is if kswapd is waking itself and the
wakeup allocates debugging objects which should already be allocated
if it's kswapd doing the waking. Nevertheless, the possibility exists
and so it's best to avoid the problem.

This patch flags a zone as needing a kswapd using the, surprisingly,
unused zone flag field. The flag is read without the lock held to
do the wakeup. It's possible that the flag setting context is not
the same as the flag clearing context or for small races to occur.
However, each race possibility is harmless and there is no visible
degredation in fragmentation treatment.

While zone->flag could have continued to be unused, there is potential
for moving some existing fields into the flags field instead. Particularly
read-mostly ones like zone->initialized and zone->contiguous.

Reported-by: syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com
Tested-by: Qian Cai <cai@lca.pw>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mmzone.h | 6 ++++++
 mm/page_alloc.c        | 8 +++++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index cc4a507d7ca4..842f9189537b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -520,6 +520,12 @@ enum pgdat_flags {
 	PGDAT_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
 };
 
+enum zone_flags {
+	ZONE_BOOSTED_WATERMARK,		/* zone recently boosted watermarks.
+					 * Cleared when kswapd is woken.
+					 */
+};
+
 static inline unsigned long zone_managed_pages(struct zone *zone)
 {
 	return (unsigned long)atomic_long_read(&zone->managed_pages);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cde5dac6229a..d295c9bc01a8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2214,7 +2214,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 	 */
 	boost_watermark(zone);
 	if (alloc_flags & ALLOC_KSWAPD)
-		wakeup_kswapd(zone, 0, 0, zone_idx(zone));
+		set_bit(ZONE_BOOSTED_WATERMARK, &zone->flags);
 
 	/* We are not allowed to try stealing from the whole block */
 	if (!whole_block)
@@ -3102,6 +3102,12 @@ struct page *rmqueue(struct zone *preferred_zone,
 	local_irq_restore(flags);
 
 out:
+	/* Separate test+clear to avoid unnecessary atomics */
+	if (test_bit(ZONE_BOOSTED_WATERMARK, &zone->flags)) {
+		clear_bit(ZONE_BOOSTED_WATERMARK, &zone->flags);
+		wakeup_kswapd(zone, 0, 0, zone_idx(zone));
+	}
+
 	VM_BUG_ON_PAGE(page && bad_range(zone, page), page);
 	return page;
 

