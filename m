Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CDD1C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:03:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2972521734
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:03:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="MrhfaG5I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2972521734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 895A96B0269; Wed, 27 Mar 2019 14:03:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F0D46B026A; Wed, 27 Mar 2019 14:03:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 668236B026B; Wed, 27 Mar 2019 14:03:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 277216B0269
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:03:13 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e5so14621296pfi.23
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:03:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zKhPr1m6X7Bh69zsikV/JQPrsM/TyWcmBTYbPmxqcHU=;
        b=GWh/LSszUiErzYdo6Zr4G+Ezv1Ih8FHFg2w5uynN34S8QZD/IIJPNGp60oi8PwqfQa
         uyd6ila4eAXFHeS7qTMA+Lgay+kCIFaKqJ6VQywUpBEoZrqbKc+zgRTSeO12eO8szBsz
         ok9ZOyPsnRv3m4auiNyvvUOs6rWabP1txwq1bXJexQhtdeL8lE8dEEBpkfVFGZ4vhvXj
         gjJC3MLdlyXCpWB8Okzwj31v9mIxigf86pQNaXzDma4bnlWsX3twNBc8kxaAdiekDWzp
         JqdB/R/5Drr3h8UlC8WxJrA/PpgLEQvE2whONeXrq8TP8rBZf1/G0uq2cGb52CusVzLs
         vriA==
X-Gm-Message-State: APjAAAXNXAi3L+X2pT0MDwTdB4ogy1CcZ2J+/Ui4/wO0nHzDr3Ks5TSo
	q0fX+kjQHgSIA3+qKwajrljqeAW2Nbf2yTyYMpi4JHq9sVYB5mBClmKSHMT+5BaVyD2gVNzdAze
	z3dqubnhAaQvjYSK8oA5BrXzvjcy1KQ1+8IUssOsNaxSuUxk7K7FZY6XpHeKhVCEd8A==
X-Received: by 2002:a17:902:e305:: with SMTP id cg5mr8418076plb.340.1553709792818;
        Wed, 27 Mar 2019 11:03:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFt0LKlrEJm/H8BAAfAM5G7R62+/NKu+1la4h4Mdq7x9UseVcXwedtE1RbOsS8ndc+AYG7
X-Received: by 2002:a17:902:e305:: with SMTP id cg5mr8418004plb.340.1553709791916;
        Wed, 27 Mar 2019 11:03:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553709791; cv=none;
        d=google.com; s=arc-20160816;
        b=T/7t7m7yuQ/BJiwv3dGXHkJ5Li8oWHuW+kQr7tB7pbDSho9Kn69IVKErkj/7GrcTdW
         Dbs6F/SXpmSOdJenEJURgdLP35KAkEGmX5//hrTrIOCwRLY7zKo5A6oQaBkZ8UHJctvz
         xZKnxz1Z556VPhbEZOrHvBEP7Jl6xyUAHPKtVABBEPA18qU7YCEjMCzfpTPVlB/OxLo9
         OgJq1BbbIAg9XEMYc1bh0hXGYfuYjFhwLDeV82N+b4eOkd/Z2uE2CTQWm/EhjV0b1Zir
         vFZljrnOHF7meCeowUi5npCe+zFykfO18jkzLUVM6EojmOhSiowZrYrhprY7fhQ5es4P
         SBQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=zKhPr1m6X7Bh69zsikV/JQPrsM/TyWcmBTYbPmxqcHU=;
        b=iU29+WJK7YFrLOCGskzWS6/MLm7tiK5G9fhIVGzDRx/p90Vm0lwbDAyMYF0mkJA3Po
         MS/ZfX5Iez7tCpMJslu3aHAlpg/05ew3fJvzZ7RFhv+uelP8yP3IycUzVaBy3RDh3zUT
         NsIgX9tAhzecQiEVuv+Wrr3zgcmDJAYMc25ceV7BnG4T3WJCqWL5bmz7GrMBh9kA5Sa0
         ej85e+jT+IZPDHl1rRhn0pbgxXdZF8QiIeooJmfG1giae/03gKc3JNrXvIg8DzDTThjt
         kqojDRfXS9XGM47C6iL+vrBgXNgDtTZ+nIXNAFn+Bi1P+HqLBW5u0apoS9PRRVLcvXJE
         RCow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=MrhfaG5I;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 89si20306098pla.124.2019.03.27.11.03.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:03:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=MrhfaG5I;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 53348217F9;
	Wed, 27 Mar 2019 18:03:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553709791;
	bh=ivaTjn1jSV5RyjTdZjh90E05Ur4A5uE28t4p8BVbvH0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=MrhfaG5IpPJcBKGXBUKD9STs53I/yePxyTJzbX9O5IfY1CPYmIk4eun+h90HMZU9d
	 g7AwA9mHv+BwPC0CxVigdCwglQ24MPQg8Dht2w03ZHSZpNCDKPldLUDZtnHp8k6VCv
	 PwdtOKLLAhVsePeBkUm6+6VRB816hfgImAJbG1OI=
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
Subject: [PATCH AUTOSEL 5.0 039/262] mm/slab.c: kmemleak no scan alien caches
Date: Wed, 27 Mar 2019 13:58:14 -0400
Message-Id: <20190327180158.10245-39-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327180158.10245-1-sashal@kernel.org>
References: <20190327180158.10245-1-sashal@kernel.org>
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
index 91c1863df93d..757e646baa5d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -550,14 +550,6 @@ static void start_cpu_timer(int cpu)
 
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
@@ -573,6 +565,14 @@ static struct array_cache *alloc_arraycache(int node, int entries,
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
@@ -667,6 +667,7 @@ static struct alien_cache *__alloc_alien_cache(int node, int entries,
 
 	alc = kmalloc_node(memsize, gfp, node);
 	if (alc) {
+		kmemleak_no_scan(alc);
 		init_arraycache(&alc->ac, entries, batch);
 		spin_lock_init(&alc->lock);
 	}
-- 
2.19.1

