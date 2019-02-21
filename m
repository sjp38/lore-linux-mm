Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83CE7C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 01:55:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 386C32086C
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 01:55:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="rX3Kwr1X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 386C32086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4D9D8E0055; Wed, 20 Feb 2019 20:55:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFCAA8E0002; Wed, 20 Feb 2019 20:55:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B13568E0055; Wed, 20 Feb 2019 20:55:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 857D38E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 20:55:17 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id a199so4108848qkb.23
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:55:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=YM0Wn0jbNjB6y9zmP7dH8GmfHqq62eVgozcbKGDoac8=;
        b=GQ9AAOJ9ytZS9aUidVs69SWvJd+yCqocL3FQUuLFS7Ys9i9w4GqhiZHPYewKc1phZd
         jpDozZu+R+FXQwVyYMO8OGz413FewiFHhaNifF79l4i5H8aE1LWi9BxzEiqWuNF4rse6
         KFggnJ459LGl7GQEc410sHGCt+cKoQT4u/p/9y6TN4pwae2UYoeot/u58EmuQMNxqRCW
         ok+yXInLJtV4i1NFZFSTknEPzhegPDyzkQ0qLPeIvm3JedNkBtnOPmWB3ZsPedDd1jyH
         JU81zXsuGl6L+CZn5+/Lcalq7Y80wunAaRCsJI+F/gL+u/J+xMXl6GscIwRG8s83OLtR
         ASuQ==
X-Gm-Message-State: AHQUAuZNKPZIh0NsjFno0B/yanRP1nomfLKPThCR96ribiJdwICKARlF
	nTIkqN7RR+xrP5AZ0C2tTjAyvEpTsFLRBXH1Gsl/O6EbYu37CYWpW3nnLFgIy3r3wdMwtgxwsvH
	oBK/RNqsgMMe3z4id9iNdqE732qQzpyqiUhVOP8gwZ2ilIbShmyKRYdfAR9X0URbe2wcJkXEsWB
	gAuGMSdenFIAVnVy3I3QyUg9k3tTXt4kZOoC1zyfTqTZpIWVMi58UB+Hs56ux0uIB4LtHMdS5Pk
	de+x3iwnqv9cv1He2bEPAnP8tLxJ78TiPu7b3IMb6k1Z+UomXSNBZs2d1lvnsvX+j4pQYRkDOFl
	7oCrUJBu7x4u62nrkTBykftk84cMTeUPE68lKuGT/tKHPTzcEh4f4ieFMHVfh5Kxa7zCKCwU3b1
	6
X-Received: by 2002:ac8:2ff1:: with SMTP id m46mr3002040qta.267.1550714117243;
        Wed, 20 Feb 2019 17:55:17 -0800 (PST)
X-Received: by 2002:ac8:2ff1:: with SMTP id m46mr3002013qta.267.1550714116589;
        Wed, 20 Feb 2019 17:55:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550714116; cv=none;
        d=google.com; s=arc-20160816;
        b=PRXnK1y0nChKGsGZArEShzOpvz+5D8XsJJKvsfkC7B6SA/7tWTCmE/WdQT2YPaSSFn
         3l9jOmc/6H32mEg0HN30VX62NocVNPqWU25qf4tNZ8sfpd/TVmbbJ6U0HfpO7PuO1mKw
         Lbx+SehbyYw6S2QP8VSHIaghzhFY0gxxxQeC69U1OvHZh1FGi7ZU6r54lZEMakQ0Qkj9
         vCvomevNUoPWu6Bd+Ns3DvLvoDVqza2cVlxZhrkXVo/lAfzEUgfNA1kOyIL5qO7g+SSF
         D/yU/rkyFYnFrKfX0opcSrlaeY8Qw0GzgO7nyCog1SSI99PaxWghDDJfH0xfLUSJcBUl
         pqQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=YM0Wn0jbNjB6y9zmP7dH8GmfHqq62eVgozcbKGDoac8=;
        b=eE3AgrwesUNqOu8bD8JQtVhcX8d3wtUVSCoCsJz3HtHq2i/s86hslXO1ZhT8caSjBU
         sT0Xk7SukhlkLyVCyRDoLTb7TmIYSI9AqESOQ1vayYl5C/8/3WAnVxElR9XvVK7eKWJv
         ALu+IvBMlzz16JfOp2TJEioNdVnCkzM3Cgo0xerU59IXLC9bGRDyLCXBCz57g7n//XnG
         gwQSb24G54dQqpzAaOLTxHphl35CDmWTRGkMFrIWKmBvNUPgqhLG7YhPq76/ZHVGPanH
         yFSr5wz2Yt39o0pgbrbHeYzNMqUpR12peQn6POQyCLV3adJ0ILbzOallyG/IVDVoJahN
         keNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=rX3Kwr1X;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l6sor23847212qve.32.2019.02.20.17.55.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 17:55:16 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=rX3Kwr1X;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=YM0Wn0jbNjB6y9zmP7dH8GmfHqq62eVgozcbKGDoac8=;
        b=rX3Kwr1XpKa35TGbIbHweo+w6hrnkhnOFGhfI5p39p72tXevCMi9+XmIjeHA5GTUDk
         IlrqVmrC2yjHRh0uRCohxLlIqqROxJTrgoTiFA0MqIQgFG9HlfCtSFmDdFJPbiPOPBUD
         3/AjVqXTHZb2aMWyeGyBf+9Eo82YZGJGeZAAlE33V0QyAOeegzmGIsxw4cXIWZU2+5uY
         6TfxxYS0uNtGQ13azntRmgLRayZbTfsVkF4DA0nRb0I4r9ZA/W2LuCdCH0XJLO7ILAIr
         t8lNdQm9UQWHPZVNl4behZYdRMNC5RU98PRRIppuIEpN4ujQHMSdsdURVGlVJBJRALxb
         qFDw==
X-Google-Smtp-Source: AHgI3IYucRujwkaTloIv/EFjGFEC/zNXpiIkUATN/kinrnMMB1vkS/LJTzdNHqtwt+yrsxX+aVIZUA==
X-Received: by 2002:a0c:987a:: with SMTP id e55mr8103237qvd.21.1550714116320;
        Wed, 20 Feb 2019 17:55:16 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id s8sm6657974qtb.70.2019.02.20.17.55.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 17:55:15 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: dave@stgolabs.net,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH -next] mm/debug: add a cast to u64 for atomic64_read()
Date: Wed, 20 Feb 2019 20:55:07 -0500
Message-Id: <20190221015507.92299-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

atomic64_read() on ppc64le returns "long int", so fix the same way as
the commit d549f545e690 ("drm/virtio: use %llu format string form
atomic64_t") by adding a cast to u64, which makes it work on all arches.

In file included from ./include/linux/printk.h:7,
                 from ./include/linux/kernel.h:15,
                 from mm/debug.c:9:
mm/debug.c: In function 'dump_mm':
./include/linux/kern_levels.h:5:18: warning: format '%llx' expects
argument of type 'long long unsigned int', but argument 19 has type
'long int' [-Wformat=]
 #define KERN_SOH "\001"  /* ASCII Start Of Header */
                  ^~~~~~
./include/linux/kern_levels.h:8:20: note: in expansion of macro
'KERN_SOH'
 #define KERN_EMERG KERN_SOH "0" /* system is unusable */
                    ^~~~~~~~
./include/linux/printk.h:297:9: note: in expansion of macro 'KERN_EMERG'
  printk(KERN_EMERG pr_fmt(fmt), ##__VA_ARGS__)
         ^~~~~~~~~~
mm/debug.c:133:2: note: in expansion of macro 'pr_emerg'
  pr_emerg("mm %px mmap %px seqnum %llu task_size %lu\n"
  ^~~~~~~~
mm/debug.c:140:17: note: format string is defined here
   "pinned_vm %llx data_vm %lx exec_vm %lx stack_vm %lx\n"
              ~~~^
              %lx

Fixes: 70f8a3ca68d3 ("mm: make mm->pinned_vm an atomic64 counter")
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/debug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/debug.c b/mm/debug.c
index c0b31b6c3877..45d9eb77b84e 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -168,7 +168,7 @@ void dump_mm(const struct mm_struct *mm)
 		mm_pgtables_bytes(mm),
 		mm->map_count,
 		mm->hiwater_rss, mm->hiwater_vm, mm->total_vm, mm->locked_vm,
-		atomic64_read(&mm->pinned_vm),
+		(u64)atomic64_read(&mm->pinned_vm),
 		mm->data_vm, mm->exec_vm, mm->stack_vm,
 		mm->start_code, mm->end_code, mm->start_data, mm->end_data,
 		mm->start_brk, mm->brk, mm->start_stack,
-- 
2.17.2 (Apple Git-113)

