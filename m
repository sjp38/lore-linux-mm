Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE58EC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 22:04:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2634B21773
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 22:04:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2634B21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95A116B0003; Thu, 23 May 2019 18:04:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93A876B0005; Thu, 23 May 2019 18:04:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F8B56B0006; Thu, 23 May 2019 18:04:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 52F506B0003
	for <linux-mm@kvack.org>; Thu, 23 May 2019 18:04:42 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id z2so5804190iog.12
        for <linux-mm@kvack.org>; Thu, 23 May 2019 15:04:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=9nKU8NqRvqZx3WzNNGvgxe1LwRuzLp0wxpy3QaCqsnE=;
        b=VfY6Ihccmwi4rW9SnvmJkuvvNayXc+N2/IDIWQN2zA+3oIIwsgA0mQqHJuFwbiSDap
         ZmMSgrdw9VBgasfqEzIjqVQEv/plLzcLopFdexGMDM6su3brkiGZO5mPhyrpAMGNW0ZV
         xf7Xja3/GP/NJDsPhQGz/VqDTj5yY6jUJkTHzgR/7GgQo6c0quPy10pU421jUqwPzLxX
         Vq4t9DqCs2OPtb6kRAJcKLbcGiCmuDjG68sHtXFmZ+uWZUSZVhpT+Wc6hQflprHDlkm9
         xx+saGDZAQRCbrO1a4Xo8aS3wzm8sZLNMUUyX89DPXLgdYuwChfo68BUiY6Kir7qr+XI
         Y4ew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAWKcJWD1ln9xgztsT0DDV2bQ+QSHZznSA27jHz+TS711fIJ4mws
	SiAOxdAZdNVoxQaPp7D3TEaI+JkiWSOrU4MzdxbcSIvcX0S6a6C2YbeXsHn/g+QGT9Ayc8vjA7z
	sr2doUQIlihF7er4IcpnvVIGj3xjs5AADvIRq9SE0nbGqomafv14A+z5KgvsCKoYpYA==
X-Received: by 2002:a5e:9505:: with SMTP id r5mr54644489ioj.285.1558649081935;
        Thu, 23 May 2019 15:04:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQt24df9e5CFtcI1VU56ED8PHyh5Z/tD5LE50wzZR++DgDaHYzN6cSo0Vh+rEm5cdbJ3pc
X-Received: by 2002:a5e:9505:: with SMTP id r5mr54644414ioj.285.1558649080686;
        Thu, 23 May 2019 15:04:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558649080; cv=none;
        d=google.com; s=arc-20160816;
        b=vppl3hKxHe3lrHa/vmMXgs0smnWopV4V1k/sHdEjhu959Ss0iUkt6bPqj8CdnnlGL9
         bloCeCKaU2t5dUuwK9IwOwxBLX/FPZEfBRIHN+YjhxQkk71+vQq0RwJzKQOJCdWahu3e
         801UxVgx1FURMi3o5trp55Txh7gpExc3okeCM6vDiM7kk5k1oNN1uYPxr/KIv5WkWlaY
         fUxBy7bmZ0MBHi7d8CB0eGr5pEHlNk+ZbmAsBsmHe5UxspEv4Fvpxuouxg0eovfuHTkz
         gmYD5hEXnxYwDnjyZpLL4gsi1SuUBABCHzeEQYR8gzvWCuyUYasKTlHWHARG20uq/kY8
         OGzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=9nKU8NqRvqZx3WzNNGvgxe1LwRuzLp0wxpy3QaCqsnE=;
        b=Um70P1YokwDPkDGaYSW0NuZMnOre9BhT7QXZkiA5lzzNvXAiSFuFVwkpC8v3B3TVp0
         7TIEhXlkAAyjerKM+JHnucARa6nGfCn/2w7+iSWs+COjzcrzFjTliS1zQhyCItzgS76q
         3oZx0BlKMyRYd433j0w+VpXhSaeGnE8BIvJHFECOnMWCR/C/YjS/O5j3oRc+GvABoYXR
         M+8YUOwdgkmQnQLdpNjAOv0Qv3LPgGVx4UhRinT2T46P/X3A1Xw5uCut4ejAWzXIQJHz
         xmhWnpc15PcMq8HYX1BT4f0XY24IX0GhMSl/u8kU6ooAp8UR1dbA25/Ie+Eveztazq4P
         2SMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s11si495234ioc.48.2019.05.23.15.04.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 15:04:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav402.sakura.ne.jp (fsav402.sakura.ne.jp [133.242.250.101])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x4NM4acO052792;
	Fri, 24 May 2019 07:04:37 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav402.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav402.sakura.ne.jp);
 Fri, 24 May 2019 07:04:36 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav402.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x4NM4atO052789
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Fri, 24 May 2019 07:04:36 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: [PATCH 5/4] mm, oom: Deduplicate memcg candidates at
 select_bad_process().
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>
References: <1558519686-16057-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <84c59c15-fb60-2421-3c75-cf704572f8d3@i-love.sakura.ne.jp>
Date: Fri, 24 May 2019 07:04:37 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <1558519686-16057-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since "mm, oom: Avoid potential RCU stall at dump_tasks()." changed to
cache all candidates at select_bad_process(), dump_tasks() started
printing all threads upon memcg OOM event.

Unfortunately, mem_cgroup_scan_tasks() can't traverse on only thread
group leaders because CSS_TASK_ITER_PROCS does not work if the thread
group leader already exit()ed.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index bdd90b53bbd3..a92b2f70d15b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -334,6 +334,20 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 		goto abort;
 	}
 
+	/*
+	 * Since mem_cgroup_scan_tasks() calls this function on each thread
+	 * whlie for_each_process() calls this function on each thread group,
+	 * memcg OOM should evaluate only one thread from each thread group.
+	 */
+	if (is_memcg_oom(oc) && get_nr_threads(task) != 1) {
+		struct task_struct *p;
+
+		list_for_each_entry_reverse(p, &oom_candidate_list,
+					    oom_candidate_list)
+			if (same_thread_group(p, task))
+				goto next;
+	}
+
 	get_task_struct(task);
 	list_add_tail(&task->oom_candidate_list, &oom_candidate_list);
 
@@ -350,9 +364,6 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	if (!points || points < oc->chosen_points)
 		goto next;
 
-	/* Prefer thread group leaders for display purposes */
-	if (points == oc->chosen_points && thread_group_leader(oc->chosen))
-		goto next;
 select:
 	oc->chosen = task;
 	oc->chosen_points = points;
-- 
2.16.5

