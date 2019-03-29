Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02F54C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 17:45:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B27DD2184D
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 17:45:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="U9KbfiY2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B27DD2184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55A6C6B000D; Fri, 29 Mar 2019 13:45:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5099D6B000E; Fri, 29 Mar 2019 13:45:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 421DD6B0010; Fri, 29 Mar 2019 13:45:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21E416B000D
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 13:45:54 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id d49so2961879qtk.8
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 10:45:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=MY/FhGStq36GLtRvOP3TUiFwwq8ZbgwnWXgDNjfyXLc=;
        b=EHrXwsV7Ww1efWniTta3Qkm4lGQ+NIRZU2WBr7mIYt/9nvRqxfPnFhefxb+BklqPtO
         ebRap0lxA+339QSZco9R5fdCOy4GWhb7orUkCX+l67w481gH/o2yPM3TIFwgJW3n5rvK
         W3CgQzmSQo+C1gEIxxvPDRI6mPfzlK+d1U0ypW73UYfQskk9hHf2cULGg6FqyaUBi7ZK
         sXyc+UrmAbAE1t0bZ8Bb0J6mNkZYN2rAe7s8Jb/tT2JIIXQbzS6sao2Citt6eXw9ybUN
         jwQe3IB2tHrxcCWeKd2rkqibtDUZ/01cDYckD4onHYCGoaBRWNlvoteay3/U95Q8rx86
         PKAQ==
X-Gm-Message-State: APjAAAXfjq8DrsvglEhcbmZO8NLHlUzM1bhzgzRDQ9P/h4xkaXQstFQN
	++IwTZU7jpQSneQKA0c65aZy0shaaFYAuMO0G0iq6kD2tQOskJeDo3CXM1Bv8RxOfzM2qJBCUKg
	w2XYVYzboySaTly/R37KS++KdsTsHu7GVm9pzQD/ai0Tvwtn6VfyYVTgF3Dcg4W2RZA==
X-Received: by 2002:a05:620a:12d0:: with SMTP id e16mr39561443qkl.140.1553881553808;
        Fri, 29 Mar 2019 10:45:53 -0700 (PDT)
X-Received: by 2002:a05:620a:12d0:: with SMTP id e16mr39561409qkl.140.1553881553209;
        Fri, 29 Mar 2019 10:45:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553881553; cv=none;
        d=google.com; s=arc-20160816;
        b=ZdVEYjtBMVyS62+fHNk1lhEqVcyfI1FeyFuO9HUljkIbrPUBL3zAH/rk5Uk+WwBO1n
         qv9hac8XHOU+BTMbjmmMZBoIrZM3kyat70QmJqtDsZHfRpPGOK2IlfvjE5GnD0kpbCHf
         yvH/zhEPSSupvH2stwO+A6PNZOxYnpDceliIDQHylwlzmeKE+6LNA4D2shw5hhwjC+2Y
         dAMY1GCAp7RrHqoK6LQMoxSfYv8/mgyba5WQ7hbZmGCWdm2A5JZSezzRzBq3j0dO3tth
         cAIVaYP7BuR77yC1uaJIAE6tm2ZS5cjYsN6Wj867lO63rURP7FCytVSZOwHTVsi0jQG5
         jCcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=MY/FhGStq36GLtRvOP3TUiFwwq8ZbgwnWXgDNjfyXLc=;
        b=CUeWy+UEXK2JS8/jJuIuSzk2zHBkD4AcTgESq4yohrlXUPA5Ojzv8AFVUEPXvY7pGI
         nl0jLLm4Q1+cxX2P3dsaigb3PqLWGQ6HIRS6FDvgB/jY8gXM1Q6jVmoG/vPqD8dm1+aR
         EL6bIo5Qjo+HTcjCeAI1xYGdrbWcD8wY2bt2Tj5LtzhWBSQRj2oNK2a3HY7rIKgqGqIb
         8IW/0C7y8MAHCiu/J8zs305YFOcgrakB/peB5rbz2EAUjNPZ8hdoUZYL6qRhlZuPSOpv
         XxrUsY2lrMFrO8yUr5pjDqZ3RtE3hUrdBZkfnfWgIGUgQ8pnJ6EKa1ToAe4yyAWiA7S7
         murg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=U9KbfiY2;
       spf=pass (google.com: domain of 30fmexawkcocwmnbjduwrnabpxxpun.lxvurwdg-vvtejlt.xap@flex--ndesaulniers.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=30FmeXAwKCOcWMNbJdUWRNabPXXPUN.LXVURWdg-VVTeJLT.XaP@flex--ndesaulniers.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id j6sor1605409qkg.72.2019.03.29.10.45.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Mar 2019 10:45:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of 30fmexawkcocwmnbjduwrnabpxxpun.lxvurwdg-vvtejlt.xap@flex--ndesaulniers.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=U9KbfiY2;
       spf=pass (google.com: domain of 30fmexawkcocwmnbjduwrnabpxxpun.lxvurwdg-vvtejlt.xap@flex--ndesaulniers.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=30FmeXAwKCOcWMNbJdUWRNabPXXPUN.LXVURWdg-VVTeJLT.XaP@flex--ndesaulniers.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=MY/FhGStq36GLtRvOP3TUiFwwq8ZbgwnWXgDNjfyXLc=;
        b=U9KbfiY2tmMN3GbfNt8jNImUF01m6grsBPWSAKAY+TrMvuGI6cltQvl/Nirx7lcbau
         /akZ/ARDBKBCMYz1I19MMPsToUhiU4BJcVIzKJV6YKtUdE+bzoUnHPToaaCd2naMOIcV
         ZOtykiTHkOTpTb3WJkmcOfffCA+58ktbybVfG6xMgrWhv46+yngJmvLRhCyWQETNKMyJ
         1WWioQfxhI3z8MqAPw7T5CTFK7yCulwR3rMPL/3fVEFMgCF+IBB2IlQ+korX36XTuOHG
         EB0aNuRSnIgnZEgMx9fBh8DS75VMssmVPBjHGBoAp6X+bazkB2/R8bYyJxs8T23jiQif
         73qQ==
X-Google-Smtp-Source: APXvYqxtGdNegUoK0pdi/nSTKMHASrseGZaV3kE5Z3L0T9xsiDIdV2DrQQlwb5i+SndR8Lbae0m3yNWoCYyCgBJwxzs=
X-Received: by 2002:a37:6704:: with SMTP id b4mr3214830qkc.29.1553881552858;
 Fri, 29 Mar 2019 10:45:52 -0700 (PDT)
Date: Fri, 29 Mar 2019 10:45:41 -0700
In-Reply-To: <201903291603.7podsjD7%lkp@intel.com>
Message-Id: <20190329174541.79972-1-ndesaulniers@google.com>
Mime-Version: 1.0
References: <201903291603.7podsjD7%lkp@intel.com>
X-Mailer: git-send-email 2.21.0.392.gf8f6787159e-goog
Subject: [PATCH] gcov: include linux/module.h for within_module
From: Nick Desaulniers <ndesaulniers@google.com>
To: oberpar@linux.ibm.com, akpm@linux-foundation.org
Cc: Nick Desaulniers <ndesaulniers@google.com>, Greg Hackmann <ghackmann@android.com>, 
	Tri Vo <trong@android.com>, linux-mm@kvack.org, kbuild-all@01.org, 
	kbuild test robot <lkp@intel.com>, linux-kernel@vger.kernel.org
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
Reported-by: kbuild test robot <lkp@intel.com>
Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
Signed-off-by: Nick Desaulniers <ndesaulniers@google.com>
---
 kernel/gcov/gcc_3_4.c | 1 +
 kernel/gcov/gcc_4_7.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/kernel/gcov/gcc_3_4.c b/kernel/gcov/gcc_3_4.c
index 801ee4b0b969..0eda59ef57df 100644
--- a/kernel/gcov/gcc_3_4.c
+++ b/kernel/gcov/gcc_3_4.c
@@ -16,6 +16,7 @@
  */
 
 #include <linux/errno.h>
+#include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/seq_file.h>
diff --git a/kernel/gcov/gcc_4_7.c b/kernel/gcov/gcc_4_7.c
index ec37563674d6..677851284fe2 100644
--- a/kernel/gcov/gcc_4_7.c
+++ b/kernel/gcov/gcc_4_7.c
@@ -13,6 +13,7 @@
  */
 
 #include <linux/errno.h>
+#include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/seq_file.h>
-- 
2.21.0.392.gf8f6787159e-goog

