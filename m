Return-Path: <SRS0=+lVK=PP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D00CC43612
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 14:39:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18CE12173C
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 14:39:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18CE12173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BC4C8E002F; Mon,  7 Jan 2019 09:39:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 671628E0001; Mon,  7 Jan 2019 09:39:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47FA28E002F; Mon,  7 Jan 2019 09:39:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D863A8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 09:39:44 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e17so382088edr.7
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 06:39:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=czsf4vL5FOcnDURNZogytxKTVT3D/fN437qEHjVuQNY=;
        b=USo/h3ljzJbudQR5TJDcXtmqqPB0DYsARtocgBZj6DyOwg85tCpJVcxw7vHNvyUSlP
         GP6/umpaFqjFWRb48c4bohAllvVijBTds6hKRpCLZOftlxr0MBd7itzRzVgrn9HSn1lm
         gZX03dNr8rtCjaJefYdy1pmT4uQfe/dHwlNwy2s0/zbP5meSDonfr5ZwDrNviX3zEHiC
         XLSLp55Ys3xKlJARk+Qs7rJS8+2vBCvNqJ/cobbtBT58ecxqwXNyMOMc9Sf7rxz2LpMG
         LNsz6Vil3vQgr5UJfA/vlVusR9LowaGDPXuLcQEXV38oNSCuiiNuYEdm72GSO2d4W+mt
         wzog==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AA+aEWa27b7GHP9SyaEAlEWaCZeaJd9c6TOOpr3kuyCZ+fEogzA+60eV
	Q4iVU/FgpN+l+b1CyiJxGOyk7WuY0mJLVZXW5dWwSU7TsWLBAC5RTkj/LVdGrB+x/XqL+oY8Wwe
	MPKBEx/8C22ssT/ciN815fNeouj2deQsRlq+xj8Dz5pZiKDQpe5iT2YWKa3vzkqp0ADELX1w2Dw
	x4qlgckjcYYJh1zDgT4KV9WiT4q8W7N09CoWUHut7Ttdl8MPYsRINGUBBBjpHM3u/x1z8Ih6njI
	gNOEsb3MKL0Vnb2HR51qzbW2yBO6I8wh9zhfmLEZUg4/DqvpflCIr0oXoO45JLI+aE4ELCBDzsw
	yAU2qZOGicF+5CzkG22WmX5+VXlnQhn2SotjCxJAso5dD+cbvKeJwrc57Su5F4g8ANzf7Vfzsw=
	=
X-Received: by 2002:a50:af21:: with SMTP id g30mr52882454edd.234.1546871984394;
        Mon, 07 Jan 2019 06:39:44 -0800 (PST)
X-Received: by 2002:a50:af21:: with SMTP id g30mr52882407edd.234.1546871983534;
        Mon, 07 Jan 2019 06:39:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546871983; cv=none;
        d=google.com; s=arc-20160816;
        b=ctWSqK5wSw3VeNswPm39qsQbdIYvXNykYeoKtMbMdCWGNZSP7U7ROAHNvCRizMltsb
         YYe6VhLiRQ0KN93SC8+gj2nna1+lNtX6zwXZpc4+VNk3PXb6vmMqPhWxO+fTiAdGD603
         Xr2udajZ/AEcW7U6ui7rJdG0kU+lDxh/b22ItrCHjX6qNken+tmvJZS1ArJntLvMGrgR
         /+reBphOu7W8JWr9zbxPKk5yeCMZRqrQCSHuyiiaTaA37IIcfBWj684eIYbUa+wphqcl
         AsYMtW7U2gazHdIt7SlLgq/7eBYT7ybgT0g/rOnKRFpArk8hSMjaNYBjbWrboeE6zVff
         DpTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=czsf4vL5FOcnDURNZogytxKTVT3D/fN437qEHjVuQNY=;
        b=YtxeCmK05FIAeONnPDBY2HKOPe+YzneQuB5Ip0wT9Lh090fibY7PUCWBGlV/3dWvg7
         d/U3JWr4KTtY5qg2HQXWox64k5fxbF8GuupjfhnjucZ7QpzoJcC9j8E3qYpUGQLfRntP
         yYICqGt5IcwbC4F4GTVnA8u7mFXbR5++DjEsyX+FMB+cJCcwwr1YOjkSYMPVpNCkHkkw
         V32xxFrAJbyOR2YvlorJB1QiGk+m1cPgPVughj2W4INXsJPflVmSPDGjxjFphRK5Vfk3
         ZkOvp8fTs7u9Jn/kXcMteBeGaqLlGX6iyXT16uZBmlOGH2Yxj5+4E2XkuVzw3NXvvTYV
         U6gA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a37sor36264614edd.23.2019.01.07.06.39.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 06:39:43 -0800 (PST)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AFSGD/Uhw9JeGaHha/JfMcZjkBf21wzOw/01k7ipnizHZJkKEM6lzU1I0tG3yeYB8iVCpINRJsmKrg==
X-Received: by 2002:a50:d311:: with SMTP id g17mr55094523edh.187.1546871982911;
        Mon, 07 Jan 2019 06:39:42 -0800 (PST)
Received: from tiehlicka.suse.cz (prg-ext-pat.suse.com. [213.151.95.130])
        by smtp.gmail.com with ESMTPSA id l18sm29285813edq.87.2019.01.07.06.39.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 06:39:41 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
To: <linux-mm@kvack.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
Date: Mon,  7 Jan 2019 15:38:02 +0100
Message-Id: <20190107143802.16847-3-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190107143802.16847-1-mhocko@kernel.org>
References: <20190107143802.16847-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190107143802.p6PM1tis6fPoDoFEv753NG63bDU2RbowJBHmLzcSsec@z>

From: Michal Hocko <mhocko@suse.com>

Tetsuo has reported [1] that a single process group memcg might easily
swamp the log with no-eligible oom victim reports due to race between
the memcg charge and oom_reaper

Thread 1		Thread2				oom_reaper
try_charge		try_charge
			  mem_cgroup_out_of_memory
			    mutex_lock(oom_lock)
  mem_cgroup_out_of_memory
    mutex_lock(oom_lock)
			      out_of_memory
			        select_bad_process
				oom_kill_process(current)
				  wake_oom_reaper
							  oom_reap_task
							  MMF_OOM_SKIP->victim
			    mutex_unlock(oom_lock)
    out_of_memory
      select_bad_process # no task

If Thread1 didn't race it would bail out from try_charge and force the
charge. We can achieve the same by checking tsk_is_oom_victim inside
the oom_lock and therefore close the race.

[1] http://lkml.kernel.org/r/bb2074c0-34fe-8c2c-1c7d-db71338f1e7f@i-love.sakura.ne.jp
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memcontrol.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index af7f18b32389..90eb2e2093e7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1387,10 +1387,22 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		.gfp_mask = gfp_mask,
 		.order = order,
 	};
-	bool ret;
+	bool ret = true;
 
 	mutex_lock(&oom_lock);
+
+	/*
+	 * multi-threaded tasks might race with oom_reaper and gain
+	 * MMF_OOM_SKIP before reaching out_of_memory which can lead
+	 * to out_of_memory failure if the task is the last one in
+	 * memcg which would be a false possitive failure reported
+	 */
+	if (tsk_is_oom_victim(current))
+		goto unlock;
+
 	ret = out_of_memory(&oc);
+
+unlock:
 	mutex_unlock(&oom_lock);
 	return ret;
 }
-- 
2.20.1

