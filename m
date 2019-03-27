Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6D6EC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:23:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5793120643
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:23:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="iMde8TIZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5793120643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 856476B0295; Wed, 27 Mar 2019 14:23:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8056F6B0296; Wed, 27 Mar 2019 14:23:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6808D6B0297; Wed, 27 Mar 2019 14:23:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 320E06B0295
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:23:46 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id q18so659310pll.16
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:23:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Ei0Yp2ugPRzOK6lKrENfyROIoWpqGG6XQyp5oMOFHEU=;
        b=aJzCNrGhxyTcJAW0KJER0RQbYMWRoaLS5kisuzy1SfCzOBo9Y4jV2tLkeAUFaAddR3
         /E9Mrx7xI5/mhhuD4sPlipQ19ZHUxb7W7IoscklmNHPoi8cuX/dEEbANqfKGACfp4SKl
         NuLT/SfAK+Hjlw6iIplhAefpucMoo9G4kojkKwQVfFy96zXtGBIYeDNdrD+EGlhKS8FV
         eKd73xReyNJlK2wYAY98OZW2qsZ9TRQKNmyLciMP9mhYWWfCaesB3Eyc18EOgMfRiiiu
         M0TRTIj8epb81J344w1WR6Lh/7MNbB0fH3EQAdkJx5RHe5D6/hblBdskjXFwM3Gp4Pou
         I9LQ==
X-Gm-Message-State: APjAAAVhwUR9HD2GuMccRD5Y0rO9fp8ggvEWq+uMJp3VuFyEW8YTz73s
	L6Ye+VLH+xpjb2bxeUiz6GMxkRghDOKx1bu+lnBlu13F+g3EU/8/fmXRgSLVYbtKOJxx8nK8PqQ
	rokOHasQ//eMdd7XS1vFgZAxLSGrm0umT3X5fgO+3LXYpx3JHWYtLckdBdbGVYHGdBQ==
X-Received: by 2002:a17:902:1102:: with SMTP id d2mr36624610pla.329.1553711025874;
        Wed, 27 Mar 2019 11:23:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzjvo98opKQbYQ8eDQ60ANdPRfkRdg73fAl3F0ZuP24d9JveuxMVKkUGYfXhmJR8BagzyB
X-Received: by 2002:a17:902:1102:: with SMTP id d2mr36624563pla.329.1553711025099;
        Wed, 27 Mar 2019 11:23:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553711025; cv=none;
        d=google.com; s=arc-20160816;
        b=xZty4y+IPE0LP8P8qz2fzXU5JvcXwUo2ri9S9wH3jwmQnToyOMI3IGQSBnpNjYf8+3
         m3c1kN36G8+i9HBaKKjHyM1k1/6IwP0Wg6bbWM9wt0MTMK7bH8LTAfHf450GCITuFyNY
         CTnITiFDQoW1XqsIQKt9TlZmlWnCnGUwnV26baghw/R/9a6kMicQHpwIBwfCDzz9xPrP
         h0y66ea69sluIRa07sZ7fnczlTT/fshAnj8xXXD0Ocr88FNvD4zVoqwk+OayMEE6K+me
         2mvwrZlbjQ+s+3TPG1h47TIu+gsJJL6TcHskiID40+mTuEzH2Pw64aK3CDs8Gpx5hR6h
         cEiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Ei0Yp2ugPRzOK6lKrENfyROIoWpqGG6XQyp5oMOFHEU=;
        b=H7Gln9QbpXplOFENVpH00mina9h0U+djQbX3t3Rx/kZ/JnowFX6rQMJCCTgMzqvBHm
         gZ+eX7o1lQRmKUQrwyVe9/YY+7YZZCOLSsDhCGMY9njq68ajcvFVwQ19CbQkmJQugKYu
         d6gcCGPPHMPRzU+V1FceniPQ5GBsEg6ser62KqUr4xOB/m0gC9TVlrEvYDoB1tshyz0D
         tfqgMfFRSgClwb8LIs0ngX8UOenIOQFC0Z1iWDJYmrHrAz88dkrWxyWpOGhvi/cH+Gs7
         7rM7jPjSqbEiBsbsqEzvz2tO5fHbNPQYwMv+S3QM/HG6cDb41EaHcljyk2QCiVd9EUEB
         G1Xw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=iMde8TIZ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k9si5736360pfo.173.2019.03.27.11.23.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:23:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=iMde8TIZ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 784C920643;
	Wed, 27 Mar 2019 18:23:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553711024;
	bh=nxdLrI+q3d7sirNu6Phhp2/ip9Eg519zhp/9x6oJj4s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=iMde8TIZtZyi3DHep7qV8l1b8xoWY4zMaCPZB62f6F9xZz4HuqBna6YMLxVXx94KF
	 inwqXvJrUCBl3+WZs4lO7l/Wd1LJStcd+GhTNI/H1x/kxKyDWiSen7hlCMPUKBoUC1
	 FK0H//9PEffYlsVG+F2dlu1CstyW0C1/reQewxq0=
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
Subject: [PATCH AUTOSEL 4.4 11/63] mm/slab.c: kmemleak no scan alien caches
Date: Wed, 27 Mar 2019 14:22:31 -0400
Message-Id: <20190327182323.18577-11-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327182323.18577-1-sashal@kernel.org>
References: <20190327182323.18577-1-sashal@kernel.org>
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
index 92df044f5e00..d043b8007f23 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -660,14 +660,6 @@ static void start_cpu_timer(int cpu)
 
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
@@ -683,6 +675,14 @@ static struct array_cache *alloc_arraycache(int node, int entries,
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
@@ -876,6 +876,7 @@ static struct alien_cache *__alloc_alien_cache(int node, int entries,
 
 	alc = kmalloc_node(memsize, gfp, node);
 	if (alc) {
+		kmemleak_no_scan(alc);
 		init_arraycache(&alc->ac, entries, batch);
 		spin_lock_init(&alc->lock);
 	}
-- 
2.19.1

