Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A48BBC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:23:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A79A20659
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:23:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A79A20659
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A7938E0035; Wed, 31 Jul 2019 11:23:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0581E8E0007; Wed, 31 Jul 2019 11:23:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E88138E0035; Wed, 31 Jul 2019 11:23:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B20BF8E0007
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:23:10 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so42632028eds.14
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:23:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=Q7cChAliTnvhbj6r6q3lHkxC923nMhufIvXHZZox4kg=;
        b=o2wXNfomRi5NqFPGm/liM009I4oX4TIH5qecD0HvFvDxDUpf9/l36MJPlWZzglCPb/
         PqEc9N5KgwTPnMG1fjg6x8Nvx3FsnoYBtb0ueKrvJOd+MxXgHvN9WFGyQ39dhv8DYpsF
         Ad6+OUXCQocCNJ41RvvfkZIMqXZ/Zr8sVhq0TRUs3+ze504yqtoL/KHCw5NsP8/ko0rM
         rR+o0ZC3aoLjrMS353nWGsixSzqatVxDhfW6uXEm2T1EX+FMcEPEqwJNKGWK5Sh8bohc
         sLKwjzpOOu03joHceMp+zi/M12qYpB6PrUiAcyM7DIhbgly43pBSCmqS6zC8S9XQB6yT
         g9yw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAV2AoMoK6V1BlYlUZk9Z8sThvrtjSOcrICKEzcVeyrENFEUfHgz
	q0LfpsGpr9BTFDjpyaP+gsY64COkMfQah9hafyhvBA4+JJpd/MKhgUkKgVkwP1Lj2LurJF4MWGV
	1RZHXDCOPBo+zguwOhSs3gA2Oj3V/dDf+vYs/cPKor5zF0GCHCobr5XfcZ8NfYZ25Mw==
X-Received: by 2002:aa7:ce91:: with SMTP id y17mr36198188edv.56.1564586590297;
        Wed, 31 Jul 2019 08:23:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1eL93qbEao5PtkDc6IWYAer5uDMN8HvWCmnL3J8riy3PYqqN2QUWv79aZJQsq0/3wA6N+
X-Received: by 2002:aa7:ce91:: with SMTP id y17mr36197903edv.56.1564586587086;
        Wed, 31 Jul 2019 08:23:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586587; cv=none;
        d=google.com; s=arc-20160816;
        b=uipOvpWNIVFzK+L4tOQNgXOvUph0uR8R8lgzbwkGh8QZqpEs5prF07wGKZHmZtkJ9i
         QOqRz6ePskeadX2cuhbBrBPM3yPl2C+bMmxG3/HRtFnETgnDgImxCODkumG7FKlqYvRH
         mtHnTRv0G18+YJBPSbgSp8z4PfUnmj6BkQbqV/VeUCfAUEx22VgesREFRLZSi7cfMfcB
         obsSkxLI7oGBIwKHFXZA2tEW0nogI/V53cjjmZqbHE40P9zDlbtpAN262WBWZVCibHCw
         qHvQ7IXqmb47+f+Ugwfb1lfWSzkFRQkUNz9DVBmVhz1O3CFGWdN+15xqOjOPiitQT5+Q
         an1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=Q7cChAliTnvhbj6r6q3lHkxC923nMhufIvXHZZox4kg=;
        b=NDX6ZpFnyHsLbUxSU/7zlzjjvtrTISYt8Pkc9294t8AcIpQG7aHQk6M4zDV4XJo60Z
         muJa9lMtLbREDIEaMlQUUs+GVwnW1hWi0qyhyrrRt9gsSXn0ATsVi1ydlPilGBHWfN81
         M8EfG/UAWiIVepWd856Xc03mX3rcWRoPNUe5YLfgjujvOWsnheQL/WeILviO1emXsjDC
         EBrlhHxgmw5MpuBmMTFND8Ji0MxjR7RUp0z/5f0dv64OgCIR1n6ijWzyFbZihCPzse7a
         KVYzNs0Wi63jLHdiGtNP4jVVH5cHtc0Ch3WA8rBsZnN3z624stCmfNcp+FthLo9yB0RU
         scnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id t1si18824262ejb.61.2019.07.31.08.23.06
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:23:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 10E4E344;
	Wed, 31 Jul 2019 08:23:06 -0700 (PDT)
Received: from arrakis.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 3A28A3F694;
	Wed, 31 Jul 2019 08:23:05 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm: kmemleak: Disable early logging in case of error
Date: Wed, 31 Jul 2019 16:23:02 +0100
Message-Id: <20190731152302.42073-1-catalin.marinas@arm.com>
X-Mailer: git-send-email 2.23.0.rc0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If an error occurs during kmemleak_init() (e.g. kmem cache cannot be
created), kmemleak is disabled but kmemleak_early_log remains enabled.
Subsequently, when the .init.text section is freed, the log_early()
function no longer exists. To avoid a page fault in such scenario,
ensure that kmemleak_disable() also disables early logging.

Cc: Andrew Morton <akpm@linux-foundation.org>
Reported-by: Qian Cai <cai@lca.pw>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 mm/kmemleak.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 6e9e8cca663e..f6e602918dac 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1966,6 +1966,7 @@ static void kmemleak_disable(void)
 
 	/* stop any memory operation tracing */
 	kmemleak_enabled = 0;
+	kmemleak_early_log = 0;
 
 	/* check whether it is too early for a kernel thread */
 	if (kmemleak_initialized)
@@ -2009,7 +2010,6 @@ void __init kmemleak_init(void)
 
 #ifdef CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF
 	if (!kmemleak_skip_disable) {
-		kmemleak_early_log = 0;
 		kmemleak_disable();
 		return;
 	}

