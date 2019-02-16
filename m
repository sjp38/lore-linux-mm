Return-Path: <SRS0=AfK9=QX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87E21C43381
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 14:05:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE103222E0
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 14:05:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE103222E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 551288E0002; Sat, 16 Feb 2019 09:05:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5004A8E0001; Sat, 16 Feb 2019 09:05:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A2D78E0002; Sat, 16 Feb 2019 09:05:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E8C558E0001
	for <linux-mm@kvack.org>; Sat, 16 Feb 2019 09:05:35 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id w17so8928483plp.23
        for <linux-mm@kvack.org>; Sat, 16 Feb 2019 06:05:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=l5f+rE4w47wMVj4XZtPe3XvKwPgXGrVgdCuZVgTNW88=;
        b=fT9UtTHZdiuY8QL/kdGIYkSM12+0owV1/LE/kIp+WMFiQnSIUBxoPFI6anEbpfOtvM
         k3EnNglGQrXRk3KnGdAhTYFQcDd7YejGiYUEkOJhRjy4RYvZ/X/n7mmAeQM9q6OjQQYd
         +mncMA9e2m8vCcbV8o1fe4br2l+R/FYR4rCl0tUs5kCmVcF/DrN5Z1HKFmzEChaPkEdx
         wa1ZhuCBHKb8v4SvsZLhom5PD1W2yt8OBGUpl0YYTc9xRSWlCy8yK9lQtJ8Ryi9ctl96
         El7GQLyGG5h5fIldAt7RlToYn2feQkj219yjBoG9BfDpT5vC1D8sOWS09ZpWlNvphAHy
         ahqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAub0RVK4T7i6MI0lmbH6jn9VR3gcIxuRATA8hZisP/OmSyOKyyyu
	lF5xY99H1Pg0cHQfNyfdd2JPjy5Mh6oKZ8noPcdzbO0OMLV6Xw9dUa8195oUP1ucoZytCSR41BY
	GZduwj35qFpfSnRXEN20PxYho1TFg2M47ekR6ftMls+nF3DAGYPdvtpjDrsLf5uOqFQ==
X-Received: by 2002:a63:5362:: with SMTP id t34mr13880146pgl.81.1550325935486;
        Sat, 16 Feb 2019 06:05:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZrPneeX6LZRZGK9daW9tSHc0ZCAFFonlUKUUD9XG6Qtvi4rQZiNB4yKS/cg/OFSux70CH0
X-Received: by 2002:a63:5362:: with SMTP id t34mr13880070pgl.81.1550325934223;
        Sat, 16 Feb 2019 06:05:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550325934; cv=none;
        d=google.com; s=arc-20160816;
        b=vJmmG43GL1iIAd10OCBw4CHNH3SikETkzovKCCvfEPEHrQ653pWAZ5cWF8fpeGu0xY
         NgjmANzNWn3K00Dtl5fO4zBrl7nLOKBpUp70DLyWxJ/g2LjS7Xmu0qqdy4Lpx5p1/9E2
         Q/foaOsM7qa7uBAEAOTQvQxKJB8uRVaYpDegmeNxYl56i3t5GxiauDbRs7dJN5sgHNb8
         ZsXoTyic5NDUo6SpBdxeTT9/SK3AQHbcjvCPgP5BAxgDgI+4Lrf1NFxXDZKCrzsU/clh
         sxEd0nzrwvGiD7UryQsjzo6yNepGPw24Oxm6iSi5qInFa0otXwjHeBmvo0Ax/+l1jPR5
         forQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=l5f+rE4w47wMVj4XZtPe3XvKwPgXGrVgdCuZVgTNW88=;
        b=JaJPQR1TbaSn/hSzRLiSoB8yB9iOF4K53ROMBpb10HdY9cD8/brVE4lmeKfYGlaoyI
         LW9QT38LtJMqdrx7O2pig8npuQQQq1EpNYFTsV4rg58Mb/Gp94jy1T6YThG34oTsTGWn
         HZGOnNaeES0qLvphw71vZOU4hbB5m3U92n8NG6MNVyLnrSeqqSV7E+DAmtGxyh1IoGp0
         qGPHUfXbe0tjkNHGiA2VOD4FL/MQSk03aF9E043zgcZBTyZRhJNrBHQJlFBb8Uxmp9jS
         pxDg1jLf/pT3fVNPj05kvNkt4Nm7LuKzBvh1rJgwl7W22PvEcCJXxmzvFjS8MpRANFSS
         G56w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s5si8035548plp.139.2019.02.16.06.05.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Feb 2019 06:05:33 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav106.sakura.ne.jp (fsav106.sakura.ne.jp [27.133.134.233])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x1GE5Apt080461;
	Sat, 16 Feb 2019 23:05:10 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav106.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav106.sakura.ne.jp);
 Sat, 16 Feb 2019 23:05:10 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav106.sakura.ne.jp)
Received: from ccsecurity.localdomain (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x1GE4v8v080234
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Sat, 16 Feb 2019 23:05:10 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Andrea Arcangeli <aarcange@redhat.com>,
        David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>,
        Roman Gushchin <guro@fb.com>, Yang Shi <yang.s@alibaba-inc.com>,
        yuzhoujian <yuzhoujian@didichuxing.com>
Subject: [PATCH 2/2] mm, oom: More aggressively ratelimit dump_header().
Date: Sat, 16 Feb 2019 23:04:55 +0900
Message-Id: <1550325895-9291-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1550325895-9291-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1550325895-9291-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since the owner of oom_lock cannot send SIGKILL before dump_header()
completes (which might take minutes if preempted by concurrently allocating
threads) while concurrently allocating threads are expecting that sleeping
for one jiffy is sufficient, we need to make sure that dump_header() is
rarely called so that concurrently allocating threads won't waste CPU time
too much.

This patch makes sure that we waited for at least 5 seconds before calling
dump_header() again. This patch is not helpful for the first call. But
holding off for jiffies spent for previous dump_header() (or at least 5
seconds) should be able to prevent concurrently allocating threads from
wasting CPU time for subsequent dump_header() calls.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: yuzhoujian <yuzhoujian@didichuxing.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Yang Shi <yang.s@alibaba-inc.com>
---
 mm/oom_kill.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 254c7fb..87180b8 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -440,8 +440,17 @@ static void dump_oom_summary(struct oom_control *oc, struct task_struct *victim)
 		from_kuid(&init_user_ns, task_uid(victim)));
 }
 
+static void oom_holdoff_expired(struct timer_list *unused)
+{
+}
+static DEFINE_TIMER(oom_timer, oom_holdoff_expired);
+
 static void dump_header(struct oom_control *oc)
 {
+	unsigned long holdoff = jiffies;
+
+	if (timer_pending(&oom_timer))
+		return;
 	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), order=%d, oom_score_adj=%hd\n",
 		current->comm, oc->gfp_mask, &oc->gfp_mask, oc->order,
 			current->signal->oom_score_adj);
@@ -458,6 +467,10 @@ static void dump_header(struct oom_control *oc)
 	}
 	if (sysctl_oom_dump_tasks)
 		dump_tasks(oc->memcg, oc->nodemask);
+	holdoff = jiffies - holdoff;
+	if (holdoff < 5 * HZ)
+		holdoff = 5 * HZ;
+	mod_timer(&oom_timer, jiffies + holdoff);
 }
 
 /*
@@ -939,8 +952,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 {
 	struct task_struct *victim = oc->chosen;
 	struct mem_cgroup *oom_group;
-	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
-					      DEFAULT_RATELIMIT_BURST);
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -957,8 +968,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	}
 	task_unlock(victim);
 
-	if (__ratelimit(&oom_rs))
-		dump_header(oc);
+	dump_header(oc);
 	dump_oom_summary(oc, victim);
 
 	/*
@@ -1001,6 +1011,7 @@ static void check_panic_on_oom(struct oom_control *oc,
 	/* Do not panic for oom kills triggered by sysrq */
 	if (is_sysrq_oom(oc))
 		return;
+	del_timer_sync(&oom_timer);
 	dump_header(oc);
 	panic("Out of memory: %s panic_on_oom is enabled\n",
 		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
@@ -1085,6 +1096,8 @@ bool out_of_memory(struct oom_control *oc)
 	select_bad_process(oc);
 	/* Found nothing?!?! */
 	if (!oc->chosen) {
+		if (!is_sysrq_oom(oc) && !is_memcg_oom(oc))
+			del_timer_sync(&oom_timer);
 		dump_header(oc);
 		pr_warn("Out of memory and no killable processes...\n");
 		/*
-- 
1.8.3.1

