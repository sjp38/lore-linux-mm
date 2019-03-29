Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35041C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 18:18:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC1502184C
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 18:18:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="aCWK7gJz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC1502184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F03A6B000D; Fri, 29 Mar 2019 14:18:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69E566B000E; Fri, 29 Mar 2019 14:18:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58DB06B0010; Fri, 29 Mar 2019 14:18:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2786B000D
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 14:18:46 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id q15so1831768otl.8
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 11:18:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=TseWlpWgDOC1dH/DYUii6Dj7Adu2b04wsLgsksnWzVs=;
        b=LWwlH7SirEz1F73WeVmQeSg5W4Apm2Vs6UApTaLDlGrTCon5fi2zqyHmejqVbQ8JSt
         Tsx24PRC5rUV2XpJc81/7ex1Qnx49HTxPibPFYkmW0eg4j36bQI3ENlZPqVgMzlvmsAm
         YZG/X3N5QaYG+5hkDPOr8WmhkUK4+hQEZSjzaC+70bbHodRtej3GA0tgRtg2FSkYn/GK
         kbzT2VyiKCyTsgA5wNp9ZH3h5muMAxfZj6ZdGoDMT12pDn/1LCvw52uesWEKrWXI95+6
         bAoZu8tZVXDYZ4JcIYKZ/U3H6c3+NSHOvwcnRANY7Xhb5/A8rP3iEzp0Gw/p0qLgZr4J
         NwAg==
X-Gm-Message-State: APjAAAVGBoskKVkhyu0QSI2X4Xk+xCKxsnHuQd5DVUsB1gZNzwSv8J/v
	I1wtFi6ChJ+S+XBKS+TdgX3PHqeo/7wmTXHvyPrwwdSVT9C6uuQwXDqFfho0IH6fiJQw7vrVRgR
	piAFpg0s9o0vdK1VxTF14JsEDkUuvWPTPZfTiVtJRJ6H0TmZ8Lqhz4qxYgX7owVSn1w==
X-Received: by 2002:aca:4e46:: with SMTP id c67mr140195oib.127.1553883525702;
        Fri, 29 Mar 2019 11:18:45 -0700 (PDT)
X-Received: by 2002:aca:4e46:: with SMTP id c67mr140170oib.127.1553883525117;
        Fri, 29 Mar 2019 11:18:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553883525; cv=none;
        d=google.com; s=arc-20160816;
        b=ltx++7bfXg4YG9bLmHt3qGmN9TsR4YDLQhChVCVvzU5825FC5tbSjcOi9llUcDxmTL
         D+D5DuKbkB/QFAx5IGpChje95ngoZl/q85rBLfKwEZplEFkULMJ1l/0vKSJp9qWdJrxp
         /Yl2eEh9jO6lPx+fCAi6abMtgCLtFXOMadjf5Xt1aGPq1Q0uGqO4ptsi/EY73jscUbHi
         KLZM/oSay19TWI3zoo1rrV5SjM9BjvLpDNTMLAbo/GOIH3aiv88lHU5MddFfvwKV54Hu
         4ueIYeCN6En9S/Z2raCCFOiTkMoyZRAA8dVUqAtU4M7Osfnti9noztMjqgzw+g6Yw0BH
         dQmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=TseWlpWgDOC1dH/DYUii6Dj7Adu2b04wsLgsksnWzVs=;
        b=Pdjuos+BAIuovHu6k9Bbc214Y+qwUp7H+fWbJ5Wv6H0k/SvvopFAohrSixsCFQAKwc
         9q/6vVoWf5VmQ6MFtH1Lo8deDeJiC/YltMKqTYs/IsGo/4ikdHZ7izo5DpdOy3zgnYRV
         493xKQBnsQsFOeFpxaryyvcS9KH26whD4JgpGpmngBKw3ex5E1gG6VXrTe0qkpa7okqh
         OQTMxbl6sHu0riZwp7LBhbAybzduH+eeIkX/x9acIqtXxqojxYr11870ASbFU99Y57eN
         NTSJFqr407CAz13V+8/85VKyTnvhv+SIYHYq8FHEAxE+Um44WS7u2txB0v4E6f8d2ymJ
         zm5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=aCWK7gJz;
       spf=pass (google.com: domain of 3hggexawkcksyopdlfwytpcdrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--ndesaulniers.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3hGGeXAwKCKsYOPdLfWYTPcdRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--ndesaulniers.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id w85sor1571269oie.139.2019.03.29.11.18.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Mar 2019 11:18:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3hggexawkcksyopdlfwytpcdrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--ndesaulniers.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=aCWK7gJz;
       spf=pass (google.com: domain of 3hggexawkcksyopdlfwytpcdrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--ndesaulniers.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3hGGeXAwKCKsYOPdLfWYTPcdRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--ndesaulniers.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=TseWlpWgDOC1dH/DYUii6Dj7Adu2b04wsLgsksnWzVs=;
        b=aCWK7gJzF3d75NDpKwWtvmS/qE84L+JURj00H6Rnfrs9q+nLcB7Iar9x4ITUCEC0Nb
         3lumsJUWh9/3schkD1WrA+EGu2Vu6ZLjfVb6lYn94aGhq8iMp69ap/CFBL1esizbgHGT
         zuRylkxVZv3nLdX/jczIvsCBbtQkWaKggyYZ2Fo3Tedv2UuFmPW5INX+fQNmYKnrmwCA
         2cb9kFZDTglPbLG6521pJ03Rx2hZfprggupI01xKA2z7uvIgASCVvL13RwWwi7kGKJ4q
         zj0Urly5rpwdSrRefTuReJ4cPhu5Bc6ksomuE39b6dp1n3b0lMTAt5Fbp92I3eBS84u8
         6VUQ==
X-Google-Smtp-Source: APXvYqzfwHSCPcOtHrOCnhWc8fdsm1m+pGdQUhnhIoEflOxbRll66KgIaKEOvChamCyINXmb+mMmrq9F7N5iWy8mcRo=
X-Received: by 2002:aca:3841:: with SMTP id f62mr4238023oia.9.1553883524800;
 Fri, 29 Mar 2019 11:18:44 -0700 (PDT)
Date: Fri, 29 Mar 2019 11:18:39 -0700
In-Reply-To: <eea3ce6a-732b-5c1d-9975-eddaeee21cf5@infradead.org>
Message-Id: <20190329181839.139301-1-ndesaulniers@google.com>
Mime-Version: 1.0
References: <eea3ce6a-732b-5c1d-9975-eddaeee21cf5@infradead.org>
X-Mailer: git-send-email 2.21.0.392.gf8f6787159e-goog
Subject: [PATCH v2] gcov: fix when CONFIG_MODULES is not set
From: Nick Desaulniers <ndesaulniers@google.com>
To: oberpar@linux.ibm.com, akpm@linux-foundation.org
Cc: Nick Desaulniers <ndesaulniers@google.com>, Greg Hackmann <ghackmann@android.com>, 
	Tri Vo <trong@android.com>, linux-mm@kvack.org, kbuild-all@01.org, 
	Randy Dunlap <rdunlap@infradead.org>, kbuild test robot <lkp@intel.com>, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Fixes commit 8c3d220cb6b5 ("gcov: clang support")

Cc: Greg Hackmann <ghackmann@android.com>
Cc: Tri Vo <trong@android.com>
Cc: Peter Oberparleiter <oberpar@linux.ibm.com>
Cc: linux-mm@kvack.org
Cc: kbuild-all@01.org
Reported-by: Randy Dunlap <rdunlap@infradead.org>
Reported-by: kbuild test robot <lkp@intel.com>
Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
Signed-off-by: Nick Desaulniers <ndesaulniers@google.com>
---
 kernel/gcov/gcc_3_4.c | 4 ++++
 kernel/gcov/gcc_4_7.c | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/kernel/gcov/gcc_3_4.c b/kernel/gcov/gcc_3_4.c
index 801ee4b0b969..8fc30f178351 100644
--- a/kernel/gcov/gcc_3_4.c
+++ b/kernel/gcov/gcc_3_4.c
@@ -146,7 +146,11 @@ void gcov_info_unlink(struct gcov_info *prev, struct gcov_info *info)
  */
 bool gcov_info_within_module(struct gcov_info *info, struct module *mod)
 {
+#ifdef CONFIG_MODULES
 	return within_module((unsigned long)info, mod);
+#else
+	return false;
+#endif
 }
 
 /* Symbolic links to be created for each profiling data file. */
diff --git a/kernel/gcov/gcc_4_7.c b/kernel/gcov/gcc_4_7.c
index ec37563674d6..0b6886d4a4dd 100644
--- a/kernel/gcov/gcc_4_7.c
+++ b/kernel/gcov/gcc_4_7.c
@@ -159,7 +159,11 @@ void gcov_info_unlink(struct gcov_info *prev, struct gcov_info *info)
  */
 bool gcov_info_within_module(struct gcov_info *info, struct module *mod)
 {
+#ifdef CONFIG_MODULES
 	return within_module((unsigned long)info, mod);
+#else
+	return false;
+#endif
 }
 
 /* Symbolic links to be created for each profiling data file. */
-- 
2.21.0.392.gf8f6787159e-goog

