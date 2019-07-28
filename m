Return-Path: <SRS0=ErOr=VZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B15DC7618B
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 12:29:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDBD72087C
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 12:29:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="1whsAqWu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDBD72087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BDAE8E0003; Sun, 28 Jul 2019 08:29:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3473C8E0002; Sun, 28 Jul 2019 08:29:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19A2D8E0003; Sun, 28 Jul 2019 08:29:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id A545B8E0002
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 08:29:41 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id 12so12589555ljj.17
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 05:29:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=EObxK8dqWVVRvRBsEeGGtpDlfj4a0yOhIWWPIED/x3I=;
        b=nGYVJQck8Fp2DbeDR7wDdlFOLHM70OmBIZTnLEx8/5NOf4GQNlpt0TUYIALaJ1z1GA
         VXR3Ix6Xe5HI8VpA8k0RktGCHT0WuAsoEK6tMt7mRL4Mp3mLYhpenj4aH1/mUqAceJCW
         IoHZrbW4gjSIoaRsJ/OSmAFfK4V09jy1GE13kH0VujhAs7A9/1fXNakThnYNhNU5hhGl
         WJLQwQf9J4flsfVwvsToy+5ii5d3jdPKWcBOWa+NHpA5BHMkyEq4TXglGslrVjHRE8PT
         +qjoxLe4tSI39G6BScBMqydRsThrUD8r74XCUOC/8+GdKoJedldFtMb1zJTcdH+x5A+I
         0Aeg==
X-Gm-Message-State: APjAAAU4o72P+QurS9ODmfkiJgOpJ8GZoYct66Rj+5ZSPtv/7iJwzDKl
	T6FBf0r4Kpea+PCCaJZ9Qj7219EdDtFKCxOYcfehWslWausPAwkwrWWUHDns/vJS1uLWNF4nYmR
	LyHZs60nlPa2rU+wUXUgc/XGCd0kjlS0SZiWQCIu0rz67hA5Nckq/QCiI2OJQsWQIzg==
X-Received: by 2002:a2e:730d:: with SMTP id o13mr35576692ljc.81.1564316980912;
        Sun, 28 Jul 2019 05:29:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwKLnywZ9+dHLyw12gDrQ6Ku5HOJD0A+pKwwF0B+4lEm8+wY7qSR9YjJbLNAN754FTCQpc
X-Received: by 2002:a2e:730d:: with SMTP id o13mr35576665ljc.81.1564316980013;
        Sun, 28 Jul 2019 05:29:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564316980; cv=none;
        d=google.com; s=arc-20160816;
        b=f90Xh5CFFWz3yRmTBqMI+kWom0Aj5xLL+Y0zMK1FCKLdW65FDpBzIl3V/8SI3eWVEZ
         gDpgIB5KgGmpxDRannPGRCQ3/iy1N8ki+LH1OW00IAAU5s4BLJcCnLz+AHiZcJ01cbCC
         2JtDR7UV2ZYU8F0lE2hg3Z5BolU5yWFCZVuypDWoZLrQ3ZIuiSoQTfQnjjFw8S1bmvpp
         vqRL2RQ71JQyQnz88kMiG3jDg5jFcSXAoBucnj78rXyDZbS6bdAPh3oLvM89JM8/P0RI
         fi/PK1A6OGAvAVQRcx3TsX+arZmsucRq0nQK9qO41EFEVV2eFjE3ofKbHmebk7CbSaV0
         jnSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=EObxK8dqWVVRvRBsEeGGtpDlfj4a0yOhIWWPIED/x3I=;
        b=Wxrq/Dnpda961KbM4uLETxRTK0jQrSAYk3oVNmUNXcTPM+JQMES35HLyfSNbVklXsZ
         FY+PjcS0vawCY7wEJYuUha58+e25AEPgrvgfmK2CaS8D4/V7+I6beZkamMFfpL5HUohx
         iV5Jb/G6G5HcgC/QhTFohzX4afk9DkwGc8IBJJtB+fTAtOMvhPMFCOL7HymkLKiyl/ep
         dDiSZj6G02PvSupBqOeX7e4uGnXxFV4DeNvqmuPC0NrgGyenjaNBg1SV4Q7aWHyDGS/h
         FJ4ZmTRmA6nlYOEwRZCzCWFIFpnlu/9uZKywPcYWKO7JnrjbMzMFsl0451EzvJKd7Rj4
         enKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=1whsAqWu;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net. [77.88.29.217])
        by mx.google.com with ESMTPS id p24si45458743lfc.77.2019.07.28.05.29.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jul 2019 05:29:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) client-ip=77.88.29.217;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=1whsAqWu;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id 2691F2E0ACA;
	Sun, 28 Jul 2019 15:29:39 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id dss6TXipDP-TcNGG9RB;
	Sun, 28 Jul 2019 15:29:39 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1564316979; bh=EObxK8dqWVVRvRBsEeGGtpDlfj4a0yOhIWWPIED/x3I=;
	h=Message-ID:Date:To:From:Subject:Cc;
	b=1whsAqWuYKUJOXIPmma8+5xsd/DouCy6BjR807Y4R+wzUZD3rwTnOdzO8+z9EzdNm
	 DhYxNS7unEDB0vVeMJeEVb0CTUOUtgKtNd7Qx+hfo0Mic5/s1HJS79olmnfDG17l7a
	 0AqyBOkOz+M6pGmoVhyanJQEcgC735AjJsBq5x6M=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from unknown (unknown [2a02:6b8:b080:9005::1:7])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id uMle0XeyLh-TcAq4Ce2;
	Sun, 28 Jul 2019 15:29:38 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit in
 get_user_pages loop
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>,
 Johannes Weiner <hannes@cmpxchg.org>
Date: Sun, 28 Jul 2019 15:29:38 +0300
Message-ID: <156431697805.3170.6377599347542228221.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

High memory limit in memory cgroup allows to batch memory reclaiming and
defer it until returning into userland. This moves it out of any locks.

Fixed gap between high and max limit works pretty well (we are using
64 * NR_CPUS pages) except cases when one syscall allocates tons of
memory. This affects all other tasks in cgroup because they might hit
max memory limit in unhandy places and\or under hot locks.

For example mmap with MAP_POPULATE or MAP_LOCKED might allocate a lot
of pages and push memory cgroup usage far ahead high memory limit.

This patch uses halfway between high and max limits as threshold and
in this case starts memory reclaiming if mem_cgroup_handle_over_high()
called with argument only_severe = true, otherwise reclaim is deferred
till returning into userland. If high limits isn't set nothing changes.

Now long running get_user_pages will periodically reclaim cgroup memory.
Other possible targets are generic file read/write iter loops.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 include/linux/memcontrol.h |    4 ++--
 include/linux/tracehook.h  |    2 +-
 mm/gup.c                   |    5 ++++-
 mm/memcontrol.c            |   17 ++++++++++++++++-
 4 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 44c41462be33..eca2bf9560f2 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -512,7 +512,7 @@ unsigned long mem_cgroup_get_zone_lru_size(struct lruvec *lruvec,
 	return mz->lru_zone_size[zone_idx][lru];
 }
 
-void mem_cgroup_handle_over_high(void);
+void mem_cgroup_handle_over_high(bool only_severe);
 
 unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg);
 
@@ -969,7 +969,7 @@ static inline void unlock_page_memcg(struct page *page)
 {
 }
 
-static inline void mem_cgroup_handle_over_high(void)
+static inline void mem_cgroup_handle_over_high(bool only_severe)
 {
 }
 
diff --git a/include/linux/tracehook.h b/include/linux/tracehook.h
index 36fb3bbed6b2..8845fb65353f 100644
--- a/include/linux/tracehook.h
+++ b/include/linux/tracehook.h
@@ -194,7 +194,7 @@ static inline void tracehook_notify_resume(struct pt_regs *regs)
 	}
 #endif
 
-	mem_cgroup_handle_over_high();
+	mem_cgroup_handle_over_high(false);
 	blkcg_maybe_throttle_current();
 }
 
diff --git a/mm/gup.c b/mm/gup.c
index 98f13ab37bac..42b93fffe824 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -847,8 +847,11 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			ret = -ERESTARTSYS;
 			goto out;
 		}
-		cond_resched();
 
+		/* Reclaim memory over high limit before stocking too much */
+		mem_cgroup_handle_over_high(true);
+
+		cond_resched();
 		page = follow_page_mask(vma, start, foll_flags, &ctx);
 		if (!page) {
 			ret = faultin_page(tsk, vma, start, &foll_flags,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cdbb7a84cb6e..15fa664ce98c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2317,11 +2317,16 @@ static void high_work_func(struct work_struct *work)
 	reclaim_high(memcg, MEMCG_CHARGE_BATCH, GFP_KERNEL);
 }
 
+#define MEMCG_SEVERE_OVER_HIGH	(1 << 31)
+
 /*
  * Scheduled by try_charge() to be executed from the userland return path
  * and reclaims memory over the high limit.
+ *
+ * Long allocation loops should call periodically with only_severe = true
+ * to reclaim memory if usage already over halfway to the max limit.
  */
-void mem_cgroup_handle_over_high(void)
+void mem_cgroup_handle_over_high(bool only_severe)
 {
 	unsigned int nr_pages = current->memcg_nr_pages_over_high;
 	struct mem_cgroup *memcg;
@@ -2329,6 +2334,11 @@ void mem_cgroup_handle_over_high(void)
 	if (likely(!nr_pages))
 		return;
 
+	if (nr_pages & MEMCG_SEVERE_OVER_HIGH)
+		nr_pages -= MEMCG_SEVERE_OVER_HIGH;
+	else if (only_severe)
+		return;
+
 	memcg = get_mem_cgroup_from_mm(current->mm);
 	reclaim_high(memcg, nr_pages, GFP_KERNEL);
 	css_put(&memcg->css);
@@ -2493,6 +2503,11 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				schedule_work(&memcg->high_work);
 				break;
 			}
+			/* Mark as severe if over halfway to the max limit */
+			if (page_counter_read(&memcg->memory) >
+			    (memcg->high >> 1) + (memcg->memory.max >> 1))
+				current->memcg_nr_pages_over_high |=
+						MEMCG_SEVERE_OVER_HIGH;
 			current->memcg_nr_pages_over_high += batch;
 			set_notify_resume(current);
 			break;

