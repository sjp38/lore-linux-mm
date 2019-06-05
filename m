Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDE51C28D18
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 14:49:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F552206B8
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 14:49:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="J2IZunxC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F552206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F0646B0007; Wed,  5 Jun 2019 10:49:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29F396B000A; Wed,  5 Jun 2019 10:49:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18EEE6B000D; Wed,  5 Jun 2019 10:49:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D6C3F6B0007
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 10:49:24 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id a5so16247099pla.3
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 07:49:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uokpXhUGAbY6p5XmmfFzDRpYAOfHcWN+Kl+0vKMAotA=;
        b=WmXmu1DusMhn+t/r6aO7AEnBN42Ag/w33+OvG2CV9l+R2dw+VHQXhxMyR7Ec2MmsyV
         lw5qwRaZJJlEvsD5m1FzPpcgBNJWj0dovO1YZV415eQX9zmzYrDJ9jWAD1Z6PGO7ETYC
         qUSgByaOSLBxTOk3eHQV3O/nsJqVpEOXlEdsPMRUlvmLqdOT5MGFSGVszqJ5BDnaOt93
         LjqbNXP9Sqbu05hh91CKTg5SukTXg1Npor8AGViXlHwlqe6GhM6BkUBKddPg1DWKeMn0
         1O6hLGfzTaBAVRxIiPPiEaeyUzPVt3v75gfylbFLhRLMGxgha8blDm+AzrHFQxdx/KHw
         c+BQ==
X-Gm-Message-State: APjAAAVbCtdY7ZDAfBUR+mmgLeaV7AUMkJzSBdL4GogNzlK5Jx+zm38E
	2tRkw7rZ0I5SpK2OPQL5sbFlI4+aLk2xpbYiV60ZPmN1o6BRhKXcmBGl4BGWXiEx4GN3p2McsI9
	HqJReEkvWf1ogdwoqhlCfzIzFAA+UI3iAFrbTV1kd74Fpj5MIh70+2Dm+whmiEhEUpA==
X-Received: by 2002:a17:902:42d:: with SMTP id 42mr42463485ple.228.1559746164355;
        Wed, 05 Jun 2019 07:49:24 -0700 (PDT)
X-Received: by 2002:a17:902:42d:: with SMTP id 42mr42463328ple.228.1559746163009;
        Wed, 05 Jun 2019 07:49:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559746163; cv=none;
        d=google.com; s=arc-20160816;
        b=a5KMQ379CU/Wv/MqVQPN5zn7RInSVMoZ6Z+XG4mChHFHodvtl/1KV8kdlmbrd9dBBv
         lz5QheovgOzAlRWJTNJydoyPTgJ/pf7eInG3Ao04bjlD4esZfBsSJYUf4bnqzTN0zknf
         EPNmwmPVFkctkdb9SwsyC/AekpE41JNkq4z69c55QsQDlPq2bRNST8YfBjl2xV+DgMJA
         LFTblGJuZxOrwuzAZHvWnJqKg/vCaKrKVD5/e++SC3zyLKOyAPgDuK+yG5a1EtKL15fr
         ALdUNr54IPwCKHYjwt5MCWQauvB6aQmuCaFyp8maEpJvfFKZYhE2sBxClwDbYNRiFBfP
         T3gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=uokpXhUGAbY6p5XmmfFzDRpYAOfHcWN+Kl+0vKMAotA=;
        b=RKha9UCEqbgM7TzB1T49nF/xaFU9BzKk3UyWQecyokn6wfW+U+R3VO4r2oonSEdqaH
         QTHZHI8grlgiksn6g26PI4H8m5yuIpgjkJqJdhJLV8H+uumWu0Hi8hvXxlejQO5kLMQn
         oasTNF+bl+yM1erweX0aRnMCaIZ5weypsv72cKqxzMOQ+KDeKId+UtuhCO913dhIcEPy
         0jp6cWwjvQIJrjbCESIXUTEYvcIiEcQBZ0j26o7Jhr0J20XyvbspXQ0oHW1TYnHgTiRK
         NicG5puFkpwqrz5O9Qk/hMHQ/d4RbI8QCDGmOu/CMtF95SF4dHq1suXSqxgaVwc/awgQ
         UI0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=J2IZunxC;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q16sor24358175pls.29.2019.06.05.07.49.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 07:49:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=J2IZunxC;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=uokpXhUGAbY6p5XmmfFzDRpYAOfHcWN+Kl+0vKMAotA=;
        b=J2IZunxCvI+d08sLrBzSc3RRPxO2OwlM39JK3Wfz7NHVngOBAtWqR8LmRGyHdMML4H
         xJ2memtPxZu00hLPKDBQq3Kxz797fYuSHyz5MjFeuGvOGgdFli2RaOk5+fCl8K4RUByH
         zTyfexL/KNSXqkjKSBxsg1gZsKpQTyVhwUrXQjXGO4pG0TSYNyDeCjnb/skVPGUmy0mf
         ILTmQLnxJ+gq9qzMJv6iRgnIiHoZZNuXwF0++xu1MmCaYxdA47zGacG7Tnhqr/6kHJ0Y
         8L7tgd4Zfm/GQ1ySDh3QfXdINL81pLmMoedb74dlImuilFm4D8it+aDUxKka7xcx2ezR
         kYeQ==
X-Google-Smtp-Source: APXvYqzclwzYKdfqEnZ6+MDN2VJ6wxc2CPFyVlmBhB2yRZPhVC1P4kxcpKFPMHk9z1/c/77J1YvRaQ==
X-Received: by 2002:a17:902:e306:: with SMTP id cg6mr15878349plb.341.1559746162576;
        Wed, 05 Jun 2019 07:49:22 -0700 (PDT)
Received: from bobo.local0.net ([203.220.89.252])
        by smtp.gmail.com with ESMTPSA id m19sm13375840pff.153.2019.06.05.07.49.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 07:49:22 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH 2/2] mm/large system hash: clear hashdist when only one node with memory is booted
Date: Thu,  6 Jun 2019 00:48:14 +1000
Message-Id: <20190605144814.29319-2-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190605144814.29319-1-npiggin@gmail.com>
References: <20190605144814.29319-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

CONFIG_NUMA on 64-bit CPUs currently enables hashdist unconditionally
even when booting on single node machines. This causes the large system
hashes to be allocated with vmalloc, and mapped with small pages.

This change clears hashdist if only one node has come up with memory.

This results in the important large inode and dentry hashes using
memblock allocations. All others are within 4MB size up to about 128GB
of RAM, which allows them to be allocated from the linear map on most
non-NUMA images.

Other big hashes like futex and TCP should eventually be moved over to
the same style of allocation as those vfs caches that use HASH_EARLY if
!hashdist, so they don't exceed MAX_ORDER on very large non-NUMA images.

This brings dTLB misses for linux kernel tree `git diff` from ~45,000 to
~8,000 on a Kaby Lake KVM guest with 8MB dentry hash and mitigations=off
(performance is in the noise, under 1% difference, page tables are
likely to be well cached for this workload).

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 mm/page_alloc.c | 31 ++++++++++++++++++-------------
 1 file changed, 18 insertions(+), 13 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 15f46be7d210..cd944f48be9a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7519,10 +7519,28 @@ static int page_alloc_cpu_dead(unsigned int cpu)
 	return 0;
 }
 
+#ifdef CONFIG_NUMA
+int hashdist = HASHDIST_DEFAULT;
+
+static int __init set_hashdist(char *str)
+{
+	if (!str)
+		return 0;
+	hashdist = simple_strtoul(str, &str, 0);
+	return 1;
+}
+__setup("hashdist=", set_hashdist);
+#endif
+
 void __init page_alloc_init(void)
 {
 	int ret;
 
+#ifdef CONFIG_NUMA
+	if (num_node_state(N_MEMORY) == 1)
+		hashdist = 0;
+#endif
+
 	ret = cpuhp_setup_state_nocalls(CPUHP_PAGE_ALLOC_DEAD,
 					"mm/page_alloc:dead", NULL,
 					page_alloc_cpu_dead);
@@ -7907,19 +7925,6 @@ int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *table, int write,
 	return ret;
 }
 
-#ifdef CONFIG_NUMA
-int hashdist = HASHDIST_DEFAULT;
-
-static int __init set_hashdist(char *str)
-{
-	if (!str)
-		return 0;
-	hashdist = simple_strtoul(str, &str, 0);
-	return 1;
-}
-__setup("hashdist=", set_hashdist);
-#endif
-
 #ifndef __HAVE_ARCH_RESERVED_KERNEL_PAGES
 /*
  * Returns the number of pages that arch has reserved but
-- 
2.20.1

