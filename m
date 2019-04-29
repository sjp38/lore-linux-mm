Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B237C004C9
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 17:13:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A58920675
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 17:13:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="FKmZgoHb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A58920675
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AF6C6B0003; Mon, 29 Apr 2019 13:13:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95F496B0005; Mon, 29 Apr 2019 13:13:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84FF96B0007; Mon, 29 Apr 2019 13:13:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 62FF76B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 13:13:49 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g28so10493220qtk.7
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 10:13:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=eAfjg0nGPcLWfxJJhGXBjl7FIwajcYkmLSUZC9BoAVo=;
        b=RzjoBos97q1myDmpUasmCxkm6dRpyvIce330QpV1K7rqqbEN1qpbCs5+H9qtWW+zDe
         KQIONSGKHf3mxZ02i+0iw4uw5gDpSOhYUXZUzHFS53pCzM2aj1N2/WbI8nEJyJ8FlKlh
         fPsJ0hTJ9nGum+UfoIU0cfSgznUQK0bn55Gd6ZoyR7ULG9hlDdq8ngTtWM9Di7B/aFeZ
         UXE6EiZmnA9NT9ypMZx1prdHXh7Zm0rB2F1SE0JXqtt6hbMdITFlbJwLsS41fg1532EQ
         iTvxQab+30o42mCG/FDk8jrTtcoCQLHB/SIkIoBhIcus0eKm1rKOcnP/KNZOvKF57F49
         EbhQ==
X-Gm-Message-State: APjAAAUnVXK7Ex3Fqt3aB4pBwXb1dK93SlQBdR7HEEfF4VZrbFlMH5l/
	ezqfEWvb5jB6CW0ih2BZB7eVJZ+kp1LsuMP9CkIg13k6u3DECUci8xTkgf/d3vUI9rtFkeuR6Qw
	wI7pKdyU3KQK5Dr8QdHyEvon1Jd5YplRCSK7PsrPiBlka6Kacq96nTO8UWtAxWdL9YA==
X-Received: by 2002:aed:3e93:: with SMTP id n19mr27154430qtf.345.1556558029131;
        Mon, 29 Apr 2019 10:13:49 -0700 (PDT)
X-Received: by 2002:aed:3e93:: with SMTP id n19mr27154375qtf.345.1556558028414;
        Mon, 29 Apr 2019 10:13:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556558028; cv=none;
        d=google.com; s=arc-20160816;
        b=bfN09b+UtfD93WlFwtaMnogRl/msZ9m1jCoS1Mldw5TDycn/EPJyksl4hvXCv/zvbz
         Dq45RnbGT6HND5kx+Tdcv0TEFc+gzTmFe/L+w4Z5PdJqg1xxM0d8iGbB6z1hrSrV/oQk
         NTCJ1f1KLzn+YSP/rtfTCqsLvqH31g1/hYKiaTaUN60OFXuk0uaE4UZT2tH7NUcx8ooB
         X3jnFeTvdhTtbDE8AhcGmsA8enFw6ge1jIHk1se9HGE4iEAIkIMMt+zMKE8mLvSgkl2Z
         nt1BEx8TWC4dIGNLyyUCzamlMSL7dEHwJb8skDvw6SvSEi5REKnmbhWKbPYkY32utHZN
         zLiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=eAfjg0nGPcLWfxJJhGXBjl7FIwajcYkmLSUZC9BoAVo=;
        b=rehevY1Y0iPKqL6FHfNl45FZ0esZj80cUG+rL5QL011oYxQl9SGNxtTKOpSeotZsl1
         JCNymqSRfS84MF2XIGwf2Oj83++2yVMEbRVtFvUjt2A+IysmE9bAE5cOAfGSY2fm1mEv
         ioYdLlVXzwdL0MRcMTn9lWFkpvvwMGuDG4ZbJUjikDehywxs3rtZltCvJIW32hJaJNJO
         MlddzzhK1iWDl9nUWQtnmu3ITMx4ZiB0JV78upIZ+HXRB4T+H9bYkcMRd9PDn6qd2WM+
         /ZGI86Ttl4AhksNTpm1QZpL5m0HPxGxYCPTgglEyN1C3dOePftPPBCmhDWHWmPC3XnmM
         CPfg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FKmZgoHb;
       spf=pass (google.com: domain of 3yzdhxagkcdykzscwwdtyggydw.ugedafmp-eecnsuc.gjy@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3yzDHXAgKCDYkZScWWdTYggYdW.Ugedafmp-eecnSUc.gjY@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id r12sor8445681qvq.10.2019.04.29.10.13.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Apr 2019 10:13:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3yzdhxagkcdykzscwwdtyggydw.ugedafmp-eecnsuc.gjy@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FKmZgoHb;
       spf=pass (google.com: domain of 3yzdhxagkcdykzscwwdtyggydw.ugedafmp-eecnsuc.gjy@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3yzDHXAgKCDYkZScWWdTYggYdW.Ugedafmp-eecnSUc.gjY@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=eAfjg0nGPcLWfxJJhGXBjl7FIwajcYkmLSUZC9BoAVo=;
        b=FKmZgoHbVGCO97K3BcQ+ic4v++s8rwzSXFy75ckZdej+bpKpVXnUNuY3AXrL33BVgJ
         Hqz2qDXRzmxVtOoIbcV+h21LE3UduSmU2SvSZoF6iZ6fTU/Uda98vcUkpqI6iB9iB4m3
         ts6v/RxvQwZAPpQgbA2bqqm1snmfVmcGk/alcHvia2mC0gY7WxDx3MzXcsdnuqA/gMZJ
         XBYlW9aAVRGre8B6TOocT9qUo0Kl2vE6THP1e5dwTEiMa3I9hqxw/zuSjkYo1tPPGfr0
         F47SccgEZEd4YLwQlE/5seZLLVVmyOrAhtyFNqs1W697mP3Z5oznCNev6CK6HYxdQwla
         tG+g==
X-Google-Smtp-Source: APXvYqwwgWs3zy3FLOkSJFSV4QCkVGyC8pGPoFtNLJRMe+t9+l0sHrdTDJroLj5qqsGFZEw5ucWIBmehPElR7Q==
X-Received: by 2002:a0c:c18d:: with SMTP id n13mr19796452qvh.109.1556558027954;
 Mon, 29 Apr 2019 10:13:47 -0700 (PDT)
Date: Mon, 29 Apr 2019 10:13:31 -0700
Message-Id: <20190429171332.152992-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH 1/2] memcg, oom: no oom-kill for __GFP_RETRY_MAYFAIL
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>, Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The documentation of __GFP_RETRY_MAYFAIL clearly mentioned that the
OOM killer will not be triggered and indeed the page alloc does not
invoke OOM killer for such allocations. However we do trigger memcg
OOM killer for __GFP_RETRY_MAYFAIL. Fix that. This flag will used later
to not trigger oom-killer in the charging path for fanotify and inotify
event allocations.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
Changelog since v1:
- commit message updated.

 mm/memcontrol.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2713b45ec3f0..99eca724ed3b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2294,7 +2294,6 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	unsigned long nr_reclaimed;
 	bool may_swap = true;
 	bool drained = false;
-	bool oomed = false;
 	enum oom_status oom_status;
 
 	if (mem_cgroup_is_root(memcg))
@@ -2381,7 +2380,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (nr_retries--)
 		goto retry;
 
-	if (gfp_mask & __GFP_RETRY_MAYFAIL && oomed)
+	if (gfp_mask & __GFP_RETRY_MAYFAIL)
 		goto nomem;
 
 	if (gfp_mask & __GFP_NOFAIL)
@@ -2400,7 +2399,6 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	switch (oom_status) {
 	case OOM_SUCCESS:
 		nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
-		oomed = true;
 		goto retry;
 	case OOM_FAILED:
 		goto force;
-- 
2.21.0.593.g511ec345e18-goog

