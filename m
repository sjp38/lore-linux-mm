Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5158AC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:45:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01AE52087F
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:45:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="OJ4dtljH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01AE52087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8D1A8E0002; Tue, 29 Jan 2019 13:45:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A15688E0001; Tue, 29 Jan 2019 13:45:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DEBD8E0002; Tue, 29 Jan 2019 13:45:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D4598E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:45:49 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id p24so25871926qtl.2
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:45:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=iEbt3vOpW1vSXw8Y1FUZOQX7cwVTiCMvjhJS6q091Dw=;
        b=VYGVWfbvYLAeTsoDxn7ghXUWdD+6qilHcsootHP3H5R4WYJ3Fklv3EaZUgHOT8ejyS
         N41ysOHU3ScvClmOy0icaL1Z/IlDpwyIhSf+8rNYEoVGkWhkILhTznU7FEG83coIs3LA
         yBpYC/qcn+8eV/ui/f8hJ5XrLpuwkJLNJ/VUU+8YuHboZKni67kn7N87ygk3r6hrHY/6
         0KBYJDJyfnOR8zvF8d0C2W7zxPAN6iIET5wFY6pZnh4y6ScHf6AcOUURIsqp89NNa5u/
         bimDQ2BR2ufwM3hPGT4E8NNHo/qUk5YjwJA6g6EaKP0Haoo1WgCRMacKRvv59y489eRs
         NH+Q==
X-Gm-Message-State: AJcUukdlRPWXMVQ7EwLduVtXd8R1mgUsIq6p6VbauoBovasb8OmUQr4d
	s+TRDNO6EcwMTIgi/gtN9iSSGMT8lPHs0hERi1QunnIrcCDno87rzpE1vMnB4NlHHzXmHNy8lPX
	+xcfwYKX9HsFbasBOQa7b4kpcMQz3r3j3WrwUGKYLvNrDhStDwr6prUq8ecyzBH+m/UxGox7kE9
	FHSWQtngqsVJeSel5qsMnZ1l3opP4YO9La2Nl4LZsrNO29zmsp0BJM347/fn44kpFgspKulYFiM
	csbCKnTWVsevdMu5fPrGzFVlhnJSJIcFikxE+xibnsJ1EXqSmYjgMcXPs9ijvNKGRsWv4z54W20
	aTvDJSs0NjoiPJWW4h3tjOMfX8xTa11OklXVHjz27AT8g0VeBuWUXV0BcnF5H3OaKf2pZNz1OLz
	R
X-Received: by 2002:ac8:1617:: with SMTP id p23mr27205889qtj.239.1548787549047;
        Tue, 29 Jan 2019 10:45:49 -0800 (PST)
X-Received: by 2002:ac8:1617:: with SMTP id p23mr27205832qtj.239.1548787548216;
        Tue, 29 Jan 2019 10:45:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787548; cv=none;
        d=google.com; s=arc-20160816;
        b=YErRRLZXF5EvEBeetg1Pvnwjt9giKPR+aEW13I2rbYLdaZv9GPsDgBp/B8gFioPBNn
         NrNth14q2OEiJKA9zBRpf0+jxChMU0t+m5gjKIDJWof3LsXsKyq1Ns4u5dd71/1ZZQgN
         aQa2gU9THjOz4l1Da0AOSOLc40mXYT0y3Roh4Fbdy1XRxQFApQozM8rAl7z9dQJkK/Wy
         y+N4ze9WiNnpcER+EKD1yUhhC2R/lp8A3FZwCF4I3wp/DwP+py3PXxk+qICjiGbKPG9w
         PTzzyCrDuK42GaUTnHCcXBSJZBmH+GsHrU3imszi/4BwOX92U68PVRIAfS1wORyCaBop
         L+dA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=iEbt3vOpW1vSXw8Y1FUZOQX7cwVTiCMvjhJS6q091Dw=;
        b=k5J+GQd1aH2g0IZUwGa4GIknxMV+AjwuS4bk9cqvUJloCf7OInCSKjGO+oBnQ8PxR3
         XeLvZL8Kzk5P0t1kb+RakUded9/+how7K9pq8f/n4EDV6z8v/iEuXfCqBmCZ6OCQ2I9x
         HXPnfRaxdtsqcEb87EYnMwBWrqQkZ3kBdr2duKKSZbmY1hwHlMNbxywfoA9YA7F1Gd4m
         AREbZqFsuGBqcMFFXscOseSzodFgeOu350ShIWhsoQouws4IXlNe+zFvg4pupx0m7iTf
         z5PD/gsbOYf0gv77tJT/g+t4xW9zXv08rHKxPPsZt3NWQmWw/alDrMu4RX28vTFXVf66
         Fr3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=OJ4dtljH;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j12sor69050609qkk.101.2019.01.29.10.45.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 10:45:48 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=OJ4dtljH;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=iEbt3vOpW1vSXw8Y1FUZOQX7cwVTiCMvjhJS6q091Dw=;
        b=OJ4dtljHU/GaBSQ1XRjhb/W9DwqesGympfaceTTQ9inAck7wQDCx6/0GoiFpqBG9Ak
         VYht6J9mQuugLbztmDbaDXbdaMSH3GQdZwOpPYXp39L0kOoDEdu4+zGBUQykG0BU6D0o
         yAiQ3nqKdBxlWsj8RkHOLbd2s5x2opM6bBm6ekQUKqtyxsawGEuUQapk8NJaZ1vwBlQz
         S+fd+Wt0GldHZbPodclvSu+H4xCKBBNIaGyIfs/tT7avBzmJAI3sfOOU68MbpfkC+k40
         5C0pWlSojO3qEAx/7bvpZf6rJlQNvUPHilysxSjvNMqu9u3GJKVwQiS4FzLnWEd2as7g
         VPFw==
X-Google-Smtp-Source: ALg8bN45Y/qnFMooUeuMv0mD+Z0m46goUL1Y3DSegIXG5W/cVMF9mYtAvtUCifDRv6J9anakjWR2Mg==
X-Received: by 2002:ae9:d804:: with SMTP id u4mr25088511qkf.322.1548787547783;
        Tue, 29 Jan 2019 10:45:47 -0800 (PST)
Received: from ovpn-120-54.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id e4sm94874234qka.31.2019.01.29.10.45.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 10:45:47 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: catalin.marinas@arm.com,
	cl@linux.com,
	iamjoonsoo.kim@lge.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	penberg@kernel.org,
	rientjes@google.com,
	Qian Cai <cai@lca.pw>
Subject: [RESEND PATCH] slab: kmemleak no scan alien caches
Date: Tue, 29 Jan 2019 13:45:18 -0500
Message-Id: <20190129184518.39808-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Kmemleak throws endless warnings during boot due to in
__alloc_alien_cache(),

alc = kmalloc_node(memsize, gfp, node);
init_arraycache(&alc->ac, entries, batch);
kmemleak_no_scan(ac);

Kmemleak does not track the array cache (alc->ac) but the alien cache
(alc) instead, so let it track the later by lifting kmemleak_no_scan()
out of init_arraycache().

There is another place calls init_arraycache(), but
alloc_kmem_cache_cpus() uses the percpu allocation where will never be
considered as a leak.

[   32.258841] kmemleak: Found object by alias at 0xffff8007b9aa7e38
[   32.258847] CPU: 190 PID: 1 Comm: swapper/0 Not tainted 5.0.0-rc2+ #2
[   32.258851] Call trace:
[   32.258858]  dump_backtrace+0x0/0x168
[   32.258863]  show_stack+0x24/0x30
[   32.258868]  dump_stack+0x88/0xb0
[   32.258873]  lookup_object+0x84/0xac
[   32.258877]  find_and_get_object+0x84/0xe4
[   32.258882]  kmemleak_no_scan+0x74/0xf4
[   32.258887]  setup_kmem_cache_node+0x2b4/0x35c
[   32.258892]  __do_tune_cpucache+0x250/0x2d4
[   32.258896]  do_tune_cpucache+0x4c/0xe4
[   32.258901]  enable_cpucache+0xc8/0x110
[   32.258905]  setup_cpu_cache+0x40/0x1b8
[   32.258909]  __kmem_cache_create+0x240/0x358
[   32.258913]  create_cache+0xc0/0x198
[   32.258918]  kmem_cache_create_usercopy+0x158/0x20c
[   32.258922]  kmem_cache_create+0x50/0x64
[   32.258928]  fsnotify_init+0x58/0x6c
[   32.258932]  do_one_initcall+0x194/0x388
[   32.258937]  kernel_init_freeable+0x668/0x688
[   32.258941]  kernel_init+0x18/0x124
[   32.258946]  ret_from_fork+0x10/0x18
[   32.258950] kmemleak: Object 0xffff8007b9aa7e00 (size 256):
[   32.258954] kmemleak:   comm "swapper/0", pid 1, jiffies 4294697137
[   32.258958] kmemleak:   min_count = 1
[   32.258962] kmemleak:   count = 0
[   32.258965] kmemleak:   flags = 0x1
[   32.258969] kmemleak:   checksum = 0
[   32.258972] kmemleak:   backtrace:
[   32.258977]      kmemleak_alloc+0x84/0xb8
[   32.258982]      kmem_cache_alloc_node_trace+0x31c/0x3a0
[   32.258987]      __kmalloc_node+0x58/0x78
[   32.258991]      setup_kmem_cache_node+0x26c/0x35c
[   32.258996]      __do_tune_cpucache+0x250/0x2d4
[   32.259001]      do_tune_cpucache+0x4c/0xe4
[   32.259005]      enable_cpucache+0xc8/0x110
[   32.259010]      setup_cpu_cache+0x40/0x1b8
[   32.259014]      __kmem_cache_create+0x240/0x358
[   32.259018]      create_cache+0xc0/0x198
[   32.259022]      kmem_cache_create_usercopy+0x158/0x20c
[   32.259026]      kmem_cache_create+0x50/0x64
[   32.259031]      fsnotify_init+0x58/0x6c
[   32.259035]      do_one_initcall+0x194/0x388
[   32.259039]      kernel_init_freeable+0x668/0x688
[   32.259043]      kernel_init+0x18/0x124
[   32.259048] kmemleak: Not scanning unknown object at 0xffff8007b9aa7e38
[   32.259052] CPU: 190 PID: 1 Comm: swapper/0 Not tainted 5.0.0-rc2+ #2
[   32.259056] Call trace:
[   32.259060]  dump_backtrace+0x0/0x168
[   32.259065]  show_stack+0x24/0x30
[   32.259070]  dump_stack+0x88/0xb0
[   32.259074]  kmemleak_no_scan+0x90/0xf4
[   32.259078]  setup_kmem_cache_node+0x2b4/0x35c
[   32.259083]  __do_tune_cpucache+0x250/0x2d4
[   32.259088]  do_tune_cpucache+0x4c/0xe4
[   32.259092]  enable_cpucache+0xc8/0x110
[   32.259096]  setup_cpu_cache+0x40/0x1b8
[   32.259100]  __kmem_cache_create+0x240/0x358
[   32.259104]  create_cache+0xc0/0x198
[   32.259108]  kmem_cache_create_usercopy+0x158/0x20c
[   32.259112]  kmem_cache_create+0x50/0x64
[   32.259116]  fsnotify_init+0x58/0x6c
[   32.259120]  do_one_initcall+0x194/0x388
[   32.259125]  kernel_init_freeable+0x668/0x688
[   32.259129]  kernel_init+0x18/0x124
[   32.259133]  ret_from_fork+0x10/0x18

Fixes: 1fe00d50a9e8 (slab: factor out initialization of array cache)
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/slab.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 78eb8c5bf4e4..0aff454f007b 100644
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
2.17.2 (Apple Git-113)

