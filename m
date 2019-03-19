Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCFCFC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:56:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71ACC217F4
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:56:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="kkRScrd3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71ACC217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEC236B0007; Tue, 19 Mar 2019 19:56:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9A2A6B0008; Tue, 19 Mar 2019 19:56:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9888A6B000A; Tue, 19 Mar 2019 19:56:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 718576B0007
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:56:33 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id c25so620382qtj.13
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 16:56:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=Hcsw4jWN1hMUQas5fk8qH4/pHraV7uLJWBMnp4emY1w=;
        b=PdkvHkLM2Uizgr5/P81RYkG6YWnevxFm4mu0qn+Fyw/LXPLt0slrtfgNdVQ/8jWCvO
         B6QiB0XsCZd7PIMFmcPHZzrPijMIV8N+TR+HYcXOnSK5QGI2pXib58PI4r+rrTIM1Zhm
         7jhM8ako5sg6IOYLRikHiOeEvxoOn+1pMuwSdmRF7FgtzsMkkWKtJyRCDzGGfxxX3GRX
         kzDhcDjIDcEc+cJjXmoQZz6bA2TbN+vo7oHt69KWBDsNcHoGCSoxu/d1UKjJrxT/z0C9
         eI1wws3yr40zzQgkk28VZWJsAJOfoYarYiLl+FiJpE8sox70B4nWS1MsiGCRxitRWIea
         CIsg==
X-Gm-Message-State: APjAAAVlG+PGGy96YfQNIHxXAE9F0pAV2W8Vj0o2ncBAKOEtXHdu28KG
	iFf1QkDhVJ/cqZUz6bvLy4ZsRBZ8jzMHv9FmkwefjqixzSrIVFyeq9VLUuIHsmXqT3dCdhSVEfN
	07k40SooDY0uS4zKQEMfUB0nTdPe/K2VEf4pnpvuL25xRjztl0YbFo3xD/EVa8cjUcw==
X-Received: by 2002:ac8:1187:: with SMTP id d7mr2745214qtj.241.1553039793220;
        Tue, 19 Mar 2019 16:56:33 -0700 (PDT)
X-Received: by 2002:ac8:1187:: with SMTP id d7mr2745199qtj.241.1553039792600;
        Tue, 19 Mar 2019 16:56:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553039792; cv=none;
        d=google.com; s=arc-20160816;
        b=evt+j/Yp4+A+Rm3KZjwjjkYFXhrG1QscrKmnOirEEMj8nO2bLK/cBvC+0GZpBEWf5e
         SgT8SS0hKWLGJ37mqV3V0/NRtx7OLdvvwSNbsPlz5VVwJd6azqtpbfDccybNYQ1pk+Xq
         NYjBjtSOdbmMeTSYdC9WSQVgGl5GwVWM86HTMU7GUlF4XKJDU+c6/d3QRKC5oqY33zE0
         JMXOHLO5LSdplmafonGHCMZuRz/yJP1PSPELzEX9m0LyhZdBjY1QmaO+G2/vLUVwMeWj
         +Tqnq7BKbJ3Iio2ptyRgVadYcJIP8asYeQiaicELlvJIk3Ku86786+sph4CkN+53uMS/
         GfIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=Hcsw4jWN1hMUQas5fk8qH4/pHraV7uLJWBMnp4emY1w=;
        b=q1X3BI9O39L4TrcFk/KBWOnDNpnp4rxVkO++SUoUlQtLhF13iy1xoDOWy4rLbskp9N
         5LMH23afvdizEMiQL0wPI3DH8n00ufQ1w6fpF5h7Q8OTVCHD3V2yyfCUm2sl0UfKZh8c
         faoOQAusnFtDTYeb4QK4Jv4n0TDKoGgU6b5fgyQstUR8b1gff873HaS7Mdgv0TOs/oR7
         CM5KVEMvVePdlM+VLNIqKmGNg1nd5iGKGHk0fUq7mpjuexzaJnZnhiEvTMPLTlCNUeZ0
         o7fg6ltjoi7QpJd+JlSYKiAGirleRwCpkiceXFFu4+REdSTZXLp6+XMfVvoIAzjZfC6S
         J6Vw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kkRScrd3;
       spf=pass (google.com: domain of 3sigrxaykcomxzwjsglttlqj.htrqnszc-rrpafhp.twl@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3sIGRXAYKCOMXZWJSGLTTLQJ.HTRQNSZc-RRPaFHP.TWL@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id o55sor790241qto.65.2019.03.19.16.56.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 16:56:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3sigrxaykcomxzwjsglttlqj.htrqnszc-rrpafhp.twl@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kkRScrd3;
       spf=pass (google.com: domain of 3sigrxaykcomxzwjsglttlqj.htrqnszc-rrpafhp.twl@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3sIGRXAYKCOMXZWJSGLTTLQJ.HTRQNSZc-RRPaFHP.TWL@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=Hcsw4jWN1hMUQas5fk8qH4/pHraV7uLJWBMnp4emY1w=;
        b=kkRScrd31+enlreI5z0oUEdvclr3JCffoxWlBxgdfvsiHG+l1qdm7rpPzTM74AffEB
         LfPQCYRFRkk5MVQ3Sswlo00GL73nAMZLv5CUblp9iwglJ0iHORdkEQbjcmg+RAyhtDSK
         O9SwD0WRSCDe+dqmFFjegvme5136ckLAkDUHKL6mVSMZP0sNbLYuvx8Ezdf706E/KfDY
         9fBeMjXuR3YFS9h86rSzKNERDrjqmseba0FXjHr885Gzr4DFfIZy5quXrHuTBM0lthvA
         9RXHgsNWSfaXr1nwN76MY2akaLAzeMLaPr9LrKq+sgEJNGwUCyr6TQwEqhNFsTdPpUau
         OdXQ==
X-Google-Smtp-Source: APXvYqwR1TAk3oGEqI2JtJ8ECEcet2nolarI6UbO1myJOnWcfePT76GDZJa39xicW9tBqtTiou2qy4qktOo=
X-Received: by 2002:ac8:2e7a:: with SMTP id s55mr13937762qta.34.1553039792366;
 Tue, 19 Mar 2019 16:56:32 -0700 (PDT)
Date: Tue, 19 Mar 2019 16:56:14 -0700
In-Reply-To: <20190319235619.260832-1-surenb@google.com>
Message-Id: <20190319235619.260832-3-surenb@google.com>
Mime-Version: 1.0
References: <20190319235619.260832-1-surenb@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v6 2/7] psi: make psi_enable static
From: Suren Baghdasaryan <surenb@google.com>
To: gregkh@linuxfoundation.org
Cc: tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, 
	dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, 
	peterz@infradead.org, akpm@linux-foundation.org, corbet@lwn.net, 
	cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, 
	linux-kernel@vger.kernel.org, kernel-team@android.com, 
	Suren Baghdasaryan <surenb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

psi_enable is not used outside of psi.c, make it static.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Suren Baghdasaryan <surenb@google.com>
---
 kernel/sched/psi.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 22c1505ad290..281702de9772 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -140,9 +140,9 @@ static int psi_bug __read_mostly;
 DEFINE_STATIC_KEY_FALSE(psi_disabled);
 
 #ifdef CONFIG_PSI_DEFAULT_DISABLED
-bool psi_enable;
+static bool psi_enable;
 #else
-bool psi_enable = true;
+static bool psi_enable = true;
 #endif
 static int __init setup_psi(char *str)
 {
-- 
2.21.0.225.g810b269d1ac-goog

