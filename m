Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7254FC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:17:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1411021741
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:17:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="GS3NQYjP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1411021741
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 022B06B028C; Wed, 27 Mar 2019 14:17:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE9056B028E; Wed, 27 Mar 2019 14:17:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D17946B028F; Wed, 27 Mar 2019 14:17:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A9DB6B028C
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:17:07 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e12so10488497pgh.2
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:17:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VhjjZL8e8AX0+GZxy8DQJNlnVz/FaNPsuY0In7tp1kY=;
        b=aAA2XV11/pOopm9DbQmR8Ig97XAG6mHbyNkXb4rwyOd9zH7dJDbtIY5XVBiE/Qzdy+
         ZyHGOuH/gG6PyOwRFdoNocC7rU5j+bsuprr8o2gfqPvdWGiramPT9EMN/8moViTqwzwX
         o6oBJgzjM+p8x2nf2UtCjjVgGVE56RXQ/BM/DFmmFMM4dbFDExDZOwNawxaeXlEEdXY0
         bF3buKsgKAgjM+9MBEaFQq2iOHiYGxIpFahd1r/s/QbFAwjL4Ci0Lptyn64yZMUD5cgx
         RjDhZLFuBECa4QEF2GpSE+4wxt7vdX6CrALVITSvlRUNJyc6w88ZkqJ2CMIOPrDecUwv
         oJrQ==
X-Gm-Message-State: APjAAAW6pLHFUd2S70CIboCLY0knnZO0IPIeNGW71outt9tJIxie0Fkk
	JBnyiA1ifIFfqhUFiHBsrsNCzINzeowgPGEehNQj14+4wRhN8UvF2rlgD8cB/Bqki14G9hjpRLg
	wDpTdSJe8R3BKIks+dQXHlDGyk7GiNEzU4DTmWnFm2bjd1jIYKOGGkDR/tE/JybkEdQ==
X-Received: by 2002:a63:4620:: with SMTP id t32mr33626984pga.363.1553710627192;
        Wed, 27 Mar 2019 11:17:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrpX1fU6CGHqX8ApNPYT3/gjtkx+g1up5mZLD86GEJcd1eo0JomAl9fdCU4MksXcQ3ObpE
X-Received: by 2002:a63:4620:: with SMTP id t32mr33626923pga.363.1553710626440;
        Wed, 27 Mar 2019 11:17:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710626; cv=none;
        d=google.com; s=arc-20160816;
        b=OEFprejW5joJ3nxLsNmVkE6x65yCXbWyPffhYKOn1WZbKvHVQ4sRRoIY0Z85rOdcW8
         Ec+ijLEgQ1OqLEZkO9fFFWsn859++J1In25/xHK41qrKzk8mBh7rCHLgmfJIejfdoVgq
         IIZaJmmC0GkVOyygqpU9X1CIrtkRcxF9L/G6wpmO+wtsxFxr0c0lGFvL4E3ou/N2RVgL
         9m2GvwcAyksb29IFCrfcP8kdNDWR+aTLpmIzz7zbL2UT81KDzpJjL80d6i3X5d4YbMOc
         sD7/BpJNgvGKBgzpj9E4zN/6TpzLo/74USvPWDB2jIVHFuSHbrxzyLmrjH4iuqCB5HFQ
         esYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=VhjjZL8e8AX0+GZxy8DQJNlnVz/FaNPsuY0In7tp1kY=;
        b=yrtYWaRZuGOLfciJxSC75nvYCVaBAapvQnqLnlS7MZkNzveD3wEhVc0/otaAHfyyTp
         m4dzX58Ec5x4+3l1C5R6ebda5jRdZMbznSFx+odmS5hfvNRf9ZPXlMwL0uGuhlOHtjwR
         C04UQ5dhrz/xpkky15H+YSCsJIuoV7S7ErQTS/Ll1m72w5NT15zrUgVdGjhO8DtoH4rI
         yk6j/r3RM8U/SmPlCBfhKtWToc4iqQYFLu1a6pVnPZkMpO0O9OSE/cD/0juuD4tRjZ2X
         8fFMpYD1ZdLZTyEb6Ski24TxBu5CzfcQof5H4XLgOon23jw989x1i4dQ75io0Wo845UN
         ZzkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=GS3NQYjP;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i10si20296316plb.384.2019.03.27.11.17.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:17:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=GS3NQYjP;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D21E921741;
	Wed, 27 Mar 2019 18:17:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553710626;
	bh=4LbCgJpuY1jTG3D6aNuuzjh3gcZf7TkIu+2WNuflVnM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=GS3NQYjPZ9JMHjBFNtRPjLWU6rPHeDuQTynqAtOmV7WgrEKIfFiOtG29QEZt9fQOj
	 jXiWIRWMfTuMBsCA9XWXk7aC7+5+hsTUo2xjt6SEXaFxiw2hcz7LJoScePNcyPIUGp
	 JObpju42kQOlIBPZT7SMhGuFMsC3BsG2I5LiD/2k=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 019/123] mm/slab.c: kmemleak no scan alien caches
Date: Wed, 27 Mar 2019 14:14:43 -0400
Message-Id: <20190327181628.15899-19-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327181628.15899-1-sashal@kernel.org>
References: <20190327181628.15899-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit 92d1d07daad65c300c7d0b68bbef8867e9895d54 ]

Kmemleak throws endless warnings during boot due to in
__alloc_alien_cache(),

    alc = kmalloc_node(memsize, gfp, node);
    init_arraycache(&alc->ac, entries, batch);
    kmemleak_no_scan(ac);

Kmemleak does not track the array cache (alc->ac) but the alien cache
(alc) instead, so let it track the latter by lifting kmemleak_no_scan()
out of init_arraycache().

There is another place that calls init_arraycache(), but
alloc_kmem_cache_cpus() uses the percpu allocation where will never be
considered as a leak.

  kmemleak: Found object by alias at 0xffff8007b9aa7e38
  CPU: 190 PID: 1 Comm: swapper/0 Not tainted 5.0.0-rc2+ #2
  Call trace:
   dump_backtrace+0x0/0x168
   show_stack+0x24/0x30
   dump_stack+0x88/0xb0
   lookup_object+0x84/0xac
   find_and_get_object+0x84/0xe4
   kmemleak_no_scan+0x74/0xf4
   setup_kmem_cache_node+0x2b4/0x35c
   __do_tune_cpucache+0x250/0x2d4
   do_tune_cpucache+0x4c/0xe4
   enable_cpucache+0xc8/0x110
   setup_cpu_cache+0x40/0x1b8
   __kmem_cache_create+0x240/0x358
   create_cache+0xc0/0x198
   kmem_cache_create_usercopy+0x158/0x20c
   kmem_cache_create+0x50/0x64
   fsnotify_init+0x58/0x6c
   do_one_initcall+0x194/0x388
   kernel_init_freeable+0x668/0x688
   kernel_init+0x18/0x124
   ret_from_fork+0x10/0x18
  kmemleak: Object 0xffff8007b9aa7e00 (size 256):
  kmemleak:   comm "swapper/0", pid 1, jiffies 4294697137
  kmemleak:   min_count = 1
  kmemleak:   count = 0
  kmemleak:   flags = 0x1
  kmemleak:   checksum = 0
  kmemleak:   backtrace:
       kmemleak_alloc+0x84/0xb8
       kmem_cache_alloc_node_trace+0x31c/0x3a0
       __kmalloc_node+0x58/0x78
       setup_kmem_cache_node+0x26c/0x35c
       __do_tune_cpucache+0x250/0x2d4
       do_tune_cpucache+0x4c/0xe4
       enable_cpucache+0xc8/0x110
       setup_cpu_cache+0x40/0x1b8
       __kmem_cache_create+0x240/0x358
       create_cache+0xc0/0x198
       kmem_cache_create_usercopy+0x158/0x20c
       kmem_cache_create+0x50/0x64
       fsnotify_init+0x58/0x6c
       do_one_initcall+0x194/0x388
       kernel_init_freeable+0x668/0x688
       kernel_init+0x18/0x124
  kmemleak: Not scanning unknown object at 0xffff8007b9aa7e38
  CPU: 190 PID: 1 Comm: swapper/0 Not tainted 5.0.0-rc2+ #2
  Call trace:
   dump_backtrace+0x0/0x168
   show_stack+0x24/0x30
   dump_stack+0x88/0xb0
   kmemleak_no_scan+0x90/0xf4
   setup_kmem_cache_node+0x2b4/0x35c
   __do_tune_cpucache+0x250/0x2d4
   do_tune_cpucache+0x4c/0xe4
   enable_cpucache+0xc8/0x110
   setup_cpu_cache+0x40/0x1b8
   __kmem_cache_create+0x240/0x358
   create_cache+0xc0/0x198
   kmem_cache_create_usercopy+0x158/0x20c
   kmem_cache_create+0x50/0x64
   fsnotify_init+0x58/0x6c
   do_one_initcall+0x194/0x388
   kernel_init_freeable+0x668/0x688
   kernel_init+0x18/0x124
   ret_from_fork+0x10/0x18

Link: http://lkml.kernel.org/r/20190129184518.39808-1-cai@lca.pw
Fixes: 1fe00d50a9e8 ("slab: factor out initialization of array cache")
Signed-off-by: Qian Cai <cai@lca.pw>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 09df506ae830..f4658468b23e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -563,14 +563,6 @@ static void start_cpu_timer(int cpu)
 
 static void init_arraycache(struct array_cache *ac, int limit, int batch)
 {
-	/*
-	 * The array_cache structures contain pointers to free object.
-	 * However, when such objects are allocated or transferred to another
-	 * cache the pointers are not cleared and they could be counted as
-	 * valid references during a kmemleak scan. Therefore, kmemleak must
-	 * not scan such objects.
-	 */
-	kmemleak_no_scan(ac);
 	if (ac) {
 		ac->avail = 0;
 		ac->limit = limit;
@@ -586,6 +578,14 @@ static struct array_cache *alloc_arraycache(int node, int entries,
 	struct array_cache *ac = NULL;
 
 	ac = kmalloc_node(memsize, gfp, node);
+	/*
+	 * The array_cache structures contain pointers to free object.
+	 * However, when such objects are allocated or transferred to another
+	 * cache the pointers are not cleared and they could be counted as
+	 * valid references during a kmemleak scan. Therefore, kmemleak must
+	 * not scan such objects.
+	 */
+	kmemleak_no_scan(ac);
 	init_arraycache(ac, entries, batchcount);
 	return ac;
 }
@@ -680,6 +680,7 @@ static struct alien_cache *__alloc_alien_cache(int node, int entries,
 
 	alc = kmalloc_node(memsize, gfp, node);
 	if (alc) {
+		kmemleak_no_scan(alc);
 		init_arraycache(&alc->ac, entries, batch);
 		spin_lock_init(&alc->lock);
 	}
-- 
2.19.1

