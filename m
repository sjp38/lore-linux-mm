Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AD5EC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 10:21:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B8A0218FD
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 10:21:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B8A0218FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B45048E0014; Tue, 12 Feb 2019 05:21:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF2428E0012; Tue, 12 Feb 2019 05:21:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BA128E0014; Tue, 12 Feb 2019 05:21:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4499D8E0012
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 05:21:39 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c53so2016670edc.9
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 02:21:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=Zo9+FKt51sWjrcVWjLOayf+02nh5kJtN90CHM7zOA8o=;
        b=VW00yOUJv+DFvgle16ESs11jwV7DdY5tioGDbaZpKpSV+bygl0J6HCuWVa11LD0PZ4
         SizHEBVoQ6x7fgUr0eIzSD2AdyFv1AEsF1oCKuHEKOZsJA8ajIjOSODdLrkPl5orBIiH
         llBTcKt+m/mI7NPBkjSXiTx0Mqhy1pCH6nm3QT/L462b83sH/r39b2qNSkWTlS//G8fH
         ++wekz2hDJW9xJWF9hqRhFF6pZQSRL5teKi0UlvOVJNS8z+G/WsNfPBHIcfLuRt3ANe/
         1X/BVUlMxsGBzlh+egG1ovMQGDOMwgBaIit+MQN+cYJKunxc1QYwoQOlWKsqu+o4Hzrb
         ugKg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYQWGpK/zipOBWZSgxCO4c2AxkHsxOtllzi6Zsp2nb8wxkpxMRI
	jYPizeXgoaq0tKEsQJMpegHfOn3Oo2/Of/PBLS04DSQXbMQajnwcMnt1psNX9tGpMmmxQXPsIpX
	zMlOjJ82+UkDrlSwr9a9PAL9dqutWReuCpkYRSzkDRFrPGERdGCacsVSR2nSmWuwUh9GI57DPBs
	r4DXPtLKHxEuAKCU0NTo6hh+1x2d2GZH2Y6GT9whQrgsL7QkEpLkUAKbOLiKUgzajSFLPfzOM8K
	vZZmnBZEYvalUwF8Ppl/P3GTbwQ2tcRjp9zweW1OGMY/EDpI4PlirZEZwOtATKXx9fgabYVTrzA
	WK3qs7GMrnDYNWPqu2LSC2bmA7j8Zr9SDqTcvayaSSA31362QVjmXJQ0PCEwJCDJFlK8MfJ4kA=
	=
X-Received: by 2002:a17:906:c7c7:: with SMTP id dc7mr148822ejb.51.1549966898678;
        Tue, 12 Feb 2019 02:21:38 -0800 (PST)
X-Received: by 2002:a17:906:c7c7:: with SMTP id dc7mr148734ejb.51.1549966896917;
        Tue, 12 Feb 2019 02:21:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549966896; cv=none;
        d=google.com; s=arc-20160816;
        b=hlKFl5WMgankjRkPs4/nsiAMbGvIe1LThg+p5K8uXUr+MKJCZzlQgkwlG/C1Bm8Es4
         fCWUJFAhR2mRUDOzsKu+QbeI51+9eaTv7qG/4FoI6tz+8+AcolIx2p6ytaAz2igVxmJt
         D+M8GnzYRJtWBtkpnwumCo/SP7/KFHR5kSPVlitXrvVk/bB8chaKS3qoQnlALwkNG74i
         w4sBQ/shp4uvGctb4PvelRhyv34LAQKYNjRR4gbFCLg808INI3860Dn35S2XyCz+/x6W
         gmZUC+4NURKaz/gKO5L6Nibskc0wYcbRuWn/fjM1gNVyUJlrY2OhL8BBTjME6f1LgVl4
         Gf0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=Zo9+FKt51sWjrcVWjLOayf+02nh5kJtN90CHM7zOA8o=;
        b=QIQn2Hx76SB84hT+YyXxTcd3YkrIrHcdjG25F0q/bHT769Wx/pHaPLzmoa5mG+WMOM
         zwcGwbUSW3GdX72IN0By1+VD++L+jJC8Tqv68f9/XNoPQp+IzEkZ0XMUEaonJgPsfFgU
         TLAn7GlGQqdaE6BaDr7m4jrZnN+z1OtlXjPXGyGPMufs3LZKm4a31diycPX7MzwICr0L
         1qzBDhN+fc75Qg/AC6C8tJO7QT+VV5YSRVenyURa7eqG7JLDSm878Yiyud6tkrugzpAJ
         aA/zKxNE4yFLiTBGqjpayE3LKD+bTVE5KOHL0Hpxz7HcpljJcXtSTcrRqwwWDQq04hcq
         mBOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e12sor4278790edc.13.2019.02.12.02.21.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 02:21:36 -0800 (PST)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IaOi1HojbWicHleY82Zg6LAsGM4FuUjqN46BBHOFYVqeRQyxeQeOnBqVNBTOEU0Xku63geUCQ==
X-Received: by 2002:aa7:cb5a:: with SMTP id w26mr2430908edt.261.1549966896510;
        Tue, 12 Feb 2019 02:21:36 -0800 (PST)
Received: from tiehlicka.microfocus.com (prg-ext-pat.suse.com. [213.151.95.130])
        by smtp.gmail.com with ESMTPSA id w56sm3753105edb.72.2019.02.12.02.21.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 02:21:35 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	David Rientjes <rientjes@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Yong-Taek Lee <ytk.lee@samsung.com>,
	<linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: [PATCH] proc, oom: do not report alien mms when setting oom_score_adj
Date: Tue, 12 Feb 2019 11:21:29 +0100
Message-Id: <20190212102129.26288-1-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Michal Hocko <mhocko@suse.com>

Tetsuo has reported that creating a thousands of processes sharing MM
without SIGHAND (aka alien threads) and setting
/proc/<pid>/oom_score_adj will swamp the kernel log and takes ages [1]
to finish. This is especially worrisome that all that printing is done
under RCU lock and this can potentially trigger RCU stall or softlockup
detector.

The primary reason for the printk was to catch potential users who might
depend on the behavior prior to 44a70adec910 ("mm, oom_adj: make sure
processes sharing mm have same view of oom_score_adj") but after more
than 2 years without a single report I guess it is safe to simply remove
the printk altogether.

The next step should be moving oom_score_adj over to the mm struct and
remove all the tasks crawling as suggested by [2]

[1] http://lkml.kernel.org/r/97fce864-6f75-bca5-14bc-12c9f890e740@i-love.sakura.ne.jp
[2] http://lkml.kernel.org/r/20190117155159.GA4087@dhcp22.suse.cz
Reported-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/proc/base.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 633a63462573..f5ed9512d193 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1086,10 +1086,6 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 
 			task_lock(p);
 			if (!p->vfork_done && process_shares_mm(p, mm)) {
-				pr_info("updating oom_score_adj for %d (%s) from %d to %d because it shares mm with %d (%s). Report if this is unexpected.\n",
-						task_pid_nr(p), p->comm,
-						p->signal->oom_score_adj, oom_adj,
-						task_pid_nr(task), task->comm);
 				p->signal->oom_score_adj = oom_adj;
 				if (!legacy && has_capability_noaudit(current, CAP_SYS_RESOURCE))
 					p->signal->oom_score_adj_min = (short)oom_adj;
-- 
2.20.1

