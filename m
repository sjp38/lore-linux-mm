Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 767F3C04AA8
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 08:19:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C39321670
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 08:19:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C39321670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EABA06B0005; Tue, 30 Apr 2019 04:19:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5D046B0007; Tue, 30 Apr 2019 04:19:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAE1B6B0008; Tue, 30 Apr 2019 04:19:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7ED926B0005
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 04:19:28 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t58so1464670edb.22
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 01:19:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fDn6LMx54Jj8tVS5WSjg5QS85E5llcN/rmWDGPkaEho=;
        b=EWBtFSBsr+PTd9UHKSMANIYd4g6bXjktbfHLaBQ1BuNiGoVsuxmT3cB5qsKW17scHC
         d41h0BU/mU0oqlLpZ9IL2+KZwM7UErQndSTA/3u/soh+DsA3b/mAHKznukRbdMRfTok1
         wBt0V0LhsDBEeCb3FL3EroXcgYKv91fv8gJuIkigGm6QpDHo+0plmHaUsUyvS8Cs3U0Z
         hsmy0E4Jo8zMrEkbhYrznfTsFAq91tdt3NHNTS6rN44Uqpoih6in/vCRRLIFwyJQnRSm
         599dp978An2AkSjv9X4+IaeETJ7NNnFtDxla0sVJ1jr0l751sX6/8+r8ktGzNHS7/hWP
         zPqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAXfyO8AeOnKqJ9EKGldNSDqIPb5Nuf6XhMkBLIXVXndS5oQkAvs
	v9a3IlrcgLahNq6ptwQIGJvafIHyblvu1NbHdoOM/WXr6/X88Mwx4efXsDRW2+j72TsmcfAx1eq
	9kTLgqu0ZMbrE2O4V/G6DPxy4Yq/iJz8GHG1B4Gp3lUqqzSKwOqWK4Fq86tpIzgx42w==
X-Received: by 2002:aa7:c750:: with SMTP id c16mr39915215eds.106.1556612367985;
        Tue, 30 Apr 2019 01:19:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxJW4CSEaJJSnU7988DevgImsQnZRA1aXUUpR/qtXbGnEqPLvwjtG7T+x/4YMSFsQDFoxt
X-Received: by 2002:aa7:c750:: with SMTP id c16mr39915175eds.106.1556612366912;
        Tue, 30 Apr 2019 01:19:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556612366; cv=none;
        d=google.com; s=arc-20160816;
        b=Z3Ey/tz+VGgfdHPxe+kkD8gTBeOP9gIrAA1GvG95Rq+MoZk4nhuuqHl4SOjbshNFwj
         tUt2MxPAE1pVSEfHL3KCIyF/8KQFgMWtIQOL3Isluu+ibJ+vofuO6qAhrg69uEkv9RNc
         bgnA7DXEeEKtl9fVEhAeJTEhM/uhmNJJRTWWAfssDOh0yrYjinMfsNNKMlNDrJwafPZO
         /khxFBOAbSzaM4FqomIY0O6gfFAbsItcPLFnMtsclzGiPpZJaWvA/2sACoI8WaQs+07Z
         XZBkd+eSoTLrQmKZ+lCgtfyF+OvwKO0YN4s/qEpOrk6Dn6huqIH25jZRF4BgHOxyTSAC
         ULSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=fDn6LMx54Jj8tVS5WSjg5QS85E5llcN/rmWDGPkaEho=;
        b=RlbaUvG9bglXwqItQpR4LxXT2IsWbpI3Xese/bIfipG2rDdCwGPT8CWe/m3NEU3d0S
         k6CYGVALkp861h+ef+GiBMIuisjCS8ywAjIx7ZJ2OjjqiOQ6cGLYGr2JOSCdgGgbik3G
         O4LUKRMAvqMUYuUPR2hXQvxcxZtIGWlUsDeNjeoWZQVu4rn3g55w3rY1HAGtr7SnPsZ/
         QDlWYrTlpCngtOgkX0a6a5FZtITPyq+K/Bz6ixeyN2xDN07Wsl4ZwuvxBztUbNQdG2Ou
         f/EWoVvdxaonqp8du0JcZoJqYsh2ORPVSqZWuMSslYIANuWQm+IHPuyVZx687nUdKRPG
         T6+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si40013eds.232.2019.04.30.01.19.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 01:19:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 85D05AE4F;
	Tue, 30 Apr 2019 08:19:26 +0000 (UTC)
From: =?UTF-8?q?Michal=20Koutn=C3=BD?= <mkoutny@suse.com>
To: gorcunov@gmail.com
Cc: akpm@linux-foundation.org,
	arunks@codeaurora.org,
	brgl@bgdev.pl,
	geert+renesas@glider.be,
	ldufour@linux.ibm.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	mguzik@redhat.com,
	mhocko@kernel.org,
	mkoutny@suse.com,
	rppt@linux.ibm.com,
	vbabka@suse.cz,
	ktkhai@virtuozzo.com
Subject: [PATCH 1/3] mm: get_cmdline use arg_lock instead of mmap_sem
Date: Tue, 30 Apr 2019 10:18:42 +0200
Message-Id: <20190430081844.22597-2-mkoutny@suse.com>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190430081844.22597-1-mkoutny@suse.com>
References: <20190418182321.GJ3040@uranus.lan>
 <20190430081844.22597-1-mkoutny@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit a3b609ef9f8b ("proc read mm's {arg,env}_{start,end} with mmap
semaphore taken.") added synchronization of reading argument/environment
boundaries under mmap_sem. Later commit 88aa7cc688d4 ("mm: introduce
arg_lock to protect arg_start|end and env_start|end in mm_struct")
avoided the coarse use of mmap_sem in similar situations.

get_cmdline can also use arg_lock instead of mmap_sem when it reads the
boundaries.

Fixes: 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|end and env_start|end in mm_struct")
Cc: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Mateusz Guzik <mguzik@redhat.com>
Signed-off-by: Michal Koutný <mkoutny@suse.com>
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 mm/util.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/util.c b/mm/util.c
index 43a2984bccaa..5cf0e84a0823 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -758,12 +758,12 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
 	if (!mm->arg_end)
 		goto out_mm;	/* Shh! No looking before we're done */
 
-	down_read(&mm->mmap_sem);
+	spin_lock(&mm->arg_lock);
 	arg_start = mm->arg_start;
 	arg_end = mm->arg_end;
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	spin_unlock(&mm->arg_lock);
 
 	len = arg_end - arg_start;
 
-- 
2.16.4

