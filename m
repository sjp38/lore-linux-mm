Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A752C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 19:01:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A352206BA
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 19:01:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="esuVGuPH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A352206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFDE08E0005; Thu, 20 Jun 2019 15:01:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D870F8E0001; Thu, 20 Jun 2019 15:01:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4D1A8E0005; Thu, 20 Jun 2019 15:01:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F1B38E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 15:01:08 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 11so3486785qkg.3
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 12:01:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=fxS7BF5YnKVYas/qowRkmGk4FPNWJ865a8LlJ7jJcM4=;
        b=VbgnPBhbgIt8C1SCMbrj30A4NpPpOpa8zz17rPD50VGpqFSLcMA9MebikBPl8gm0VN
         468kFm57iew5T86G0b05679ncQpirWbz3Dj1tJ9m/5x62Fan8zTxaiMHHMqbWm093MUg
         pGFqmQiNK8wAo9bejLvSXQQFMX4hJ8v07mCuF8i8gJB5qs7MEBq+2qzFVGqoF2/FiS0d
         m9J/gSZGD6E4vQjro2LbxtZ1jQbjkboxFtHvHY8v3itbDy0hX4pJR4OVsiXnBl6B/K53
         kzLUImMR1tTw2ZYY3mevaNYPJA/uV64OuRBmzRuAe+/KuaCtFVCdmAJD1CLF+6OCJrHf
         ToKA==
X-Gm-Message-State: APjAAAUYVrPMEe+zMRpuBfstkneIcxywMh8rlFv1YM0cNPhR8D2zXs8C
	5S5QYMVDEOQa4CvO/L1J0o14yXOdU+nyTWP5RhJxfuApkENKrPKjsBEw+eKBPwoj0PQUcflbFgn
	T82PyFAev3LPgHM0Lhpnc+EX+/IaFeoWZjWkozMUvcW3SGrlRu7b72Nv4BLVDNn7wiQ==
X-Received: by 2002:ac8:17f7:: with SMTP id r52mr15676794qtk.235.1561057268383;
        Thu, 20 Jun 2019 12:01:08 -0700 (PDT)
X-Received: by 2002:ac8:17f7:: with SMTP id r52mr15676725qtk.235.1561057267607;
        Thu, 20 Jun 2019 12:01:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561057267; cv=none;
        d=google.com; s=arc-20160816;
        b=qZwcqVNgI7KMhPJeGXUW70W8DTvXLIy3nO3OP5U3u+zX8YQiteEsCopk2ATHL/D8SI
         84q5yU8R7b6U9cCY2WoafUWlxmE3K3T9122QiPDtzcSMV6+3aeRxVy4hMp1urPPaVXh0
         qc3Ku0WeDxIRzWBbx0Wcaw6v8JbJ1bY5NDO9QCQfA6/KDkW2lAcKKn7RVwfQ2zYgUqC3
         iEZPLqgSMklVrE3dn5SD0om6BaTu9YBnz+U1jfrHKj8/gux2suQLAdn4Djc3u9/pEkOr
         JNbPwtvdSkc/SQ7y2NcoeSU3aZjGHS66W7qeZHucC4HhOt1YCsvGl0nlQAj0AWt1Kmku
         /NGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=fxS7BF5YnKVYas/qowRkmGk4FPNWJ865a8LlJ7jJcM4=;
        b=q6s3nY0T980FKcdzaUP1z4vaxkXXhOdj+0q8krhFmNRcWVZTBhVFV8h60I6pEJkfmy
         jrnMVuSNPQEE5Vm2B6LONXGUcHVwZ6nGihHZqQmNVc7ktQII+cvlazTUELwI8WAeZ0rI
         3gPRAcH2SFrmSsZjl31B6OBEgHAiWWx0aECJaIWbd7tVNKB+en1fRQPppT2Wekirer83
         357FO1jI11Q7YYdxnHIdtk22WzsnSxj3hGRjmQuRyeCmqcLbOwSwmN09qSiq+TukHaWJ
         PTQEjXAf5yT/khyqtwW0saOTU6qynCduSv66E8rnEQzdMmO1tfWcrt4anZpV8f0f3sfu
         bWSg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=esuVGuPH;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u44sor287762qvh.40.2019.06.20.12.01.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 12:01:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=esuVGuPH;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=fxS7BF5YnKVYas/qowRkmGk4FPNWJ865a8LlJ7jJcM4=;
        b=esuVGuPHL56ybvaqOi4wr1sfCwyi7F90uFQQg9tDD7rakbJPt06CIihYvU6E/v7e+I
         uENQ4kzNchpmVv/XoVJiEEgg378BnrefimklEXz6CAeEB311DR3h8OgJjMntqg4AoGmi
         tCa7K0JPelfWIG5PvLB+98Sg0cEYB5XPVyjpvIiLjStcU4LZ7t3vbLUYjlTCNkRXFHIT
         ecPYI7BNUFg0LIRkX/JlHlb6+HXYysZkx8gm54zyBF88Bz2MDiqMSyQCsK0hOVv4L958
         nP76/otkB76YZk9ir5BcKU7vVwQXXZWENpXaQeFy0FRIwaiisCKVarXEjd78H0mYBEqL
         X0Kg==
X-Google-Smtp-Source: APXvYqysIE3Ly6ZIllbwREVHhww7QCrn4Q3w2CO3KTEKsTltsmi4QX8G1yOr8xqJrrtRaWd1Y93z4Q==
X-Received: by 2002:a0c:add8:: with SMTP id x24mr41689584qvc.167.1561057267285;
        Thu, 20 Jun 2019 12:01:07 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id k58sm279904qtc.38.2019.06.20.12.01.05
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 12:01:06 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: glider@google.com,
	keescook@chromium.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH -next] mm/page_poison: fix a false memory corruption
Date: Thu, 20 Jun 2019 15:00:49 -0400
Message-Id: <1561057249-7493-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The linux-next commit "mm: security: introduce init_on_alloc=1 and
init_on_free=1 boot options" [1] introduced a false positive when
init_on_free=1 and page_poison=on, due to the page_poison expects the
pattern 0xaa when allocating pages which were overwritten by
init_on_free=1 with 0.

It is not possible to switch the order between kernel_init_free_pages()
and kernel_poison_pages() in free_pages_prepare(), because at least on
powerpc the formal will call clear_page() and the subsequence access by
kernel_poison_pages() will trigger the kernel access of bad area errors.

Fix it by treating init_on_free=1 the same as
CONFIG_PAGE_POISONING_ZERO=y.

[1] https://patchwork.kernel.org/patch/10999465/

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/page_poison.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/page_poison.c b/mm/page_poison.c
index 21d4f97cb49b..272403b992d3 100644
--- a/mm/page_poison.c
+++ b/mm/page_poison.c
@@ -68,22 +68,26 @@ static void check_poison_mem(unsigned char *mem, size_t bytes)
 	static DEFINE_RATELIMIT_STATE(ratelimit, 5 * HZ, 10);
 	unsigned char *start;
 	unsigned char *end;
+	int pattern = PAGE_POISON;
 
 	if (IS_ENABLED(CONFIG_PAGE_POISONING_NO_SANITY))
 		return;
 
-	start = memchr_inv(mem, PAGE_POISON, bytes);
+	if (static_branch_unlikely(&init_on_free))
+		pattern = 0;
+
+	start = memchr_inv(mem, pattern, bytes);
 	if (!start)
 		return;
 
 	for (end = mem + bytes - 1; end > start; end--) {
-		if (*end != PAGE_POISON)
+		if (*end != pattern)
 			break;
 	}
 
 	if (!__ratelimit(&ratelimit))
 		return;
-	else if (start == end && single_bit_flip(*start, PAGE_POISON))
+	else if (start == end && single_bit_flip(*start, pattern))
 		pr_err("pagealloc: single bit error\n");
 	else
 		pr_err("pagealloc: memory corruption\n");
-- 
1.8.3.1

