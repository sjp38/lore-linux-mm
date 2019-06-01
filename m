Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBA39C28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:22:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CE71257AC
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:22:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="oVTPgSHu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CE71257AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1D066B029E; Sat,  1 Jun 2019 09:22:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCCE06B02A0; Sat,  1 Jun 2019 09:22:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE6456B02A1; Sat,  1 Jun 2019 09:22:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8FD876B029E
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:22:40 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id k22so9590220pfg.18
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:22:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=OvNkdztaViHJha/up0kAJ/pTuQzb+Qzduu4nNqnWjZg=;
        b=ps9NaBTqBBDgV2f5/7sG9nVPiBt2DC0djdJFacMIgPMTqI0NWlaPx0lH/K5GUU0iRR
         1ScFGJP4lUGI7E0+wKUzk4dez2KGLEbQXwd59ibdO0Hezr8SIRXJgw4utiBKxKbErM0q
         NxClAdpMdZzx2RQUwt0qar04advKV0nhg5HeKW/PiZ3Ui4SszGMg8D31kYMLCU/+ZzKS
         xmZvHiebQrc++Q0fTQcHPB1zdeJ6k/YEDn+mL63A7NdAR8POn0bzFPDIDLGONVHD2jQQ
         zbdqbjSyuQept7t4JKan4iyzlhFnD10UA4XoUBL/AKn36y2Pb6CYvBCEOhzmi/qkckQV
         s9jw==
X-Gm-Message-State: APjAAAUGVbUqGKuWKRX2hETPiXN3m/tSPJy9iixSixgBBKQ3MdFy/fhU
	2Z4oPZZt1UDbxYyvsvTYeI+KFhEPvbjg8y8He0bBu0eveYytm1uyJMNOV2LtC70bM+JK9q/uKYS
	ygQFggKGC+SreRpUgDEh3vOgkz5sM7wORXAvT/uOxOkWvP9xOK+47aTN8J1godkuQiw==
X-Received: by 2002:a17:90a:1993:: with SMTP id 19mr2045567pji.1.1559395360255;
        Sat, 01 Jun 2019 06:22:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAOb1BqyXNv9G8UWk8kC0RMdAqdRYH/rEqFV1NTbnBReu67mQLdWnYHkeCO8jRlyCsefCg
X-Received: by 2002:a17:90a:1993:: with SMTP id 19mr2045499pji.1.1559395359642;
        Sat, 01 Jun 2019 06:22:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395359; cv=none;
        d=google.com; s=arc-20160816;
        b=yk+KLvWmpD3FriBwkipU/C55PwC9v4wzNoP8PqJCBRvSn6gICSLuovbcPg0fIfIkaU
         16QVr/VOfe6COVh7hf89/oGaSjpi/M45MBE8c50IrDYz7JGyrSXY531dofTx/Tq1y1nb
         h3iO3xuc72Q4Uj1iJToPy4+30ExXHXb33mdk67OpD5ENHKopliYOrxTDhzDabws5dT3K
         yzm4h/2hFFzt3o8Aoxo8MzgdEYqkiIuWbN55aaq4Dv9uZlcljOsJMYVpcDYgKuBACwsk
         duhC2ig6mvPkveI4v6b/Yd530/ewLBWgMBvD/dDCE0GLC1+/4nKcWaeFo3SeUY3rI6ma
         M0Sw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=OvNkdztaViHJha/up0kAJ/pTuQzb+Qzduu4nNqnWjZg=;
        b=ZXFOcxfndHYq5QfsI+2nLIjvYJYmvoMxRcIfuN7xR7X6nPM71s5t0kKOh+ZSrjuWPj
         5V8U8PpeaD3xb4MYhchIskbB3+UoDZo3S2GnKpaM/XM6NxFMkoVrPMg5y/ADNUS9BwTU
         QAmY4iRCTfFKmKskC7WJTmg+aJsaQ3ZaM5P3wCiDsWerev3Xp92C6ohljv+O2JrpoPK2
         WykOQP4kam35aJPQSZebAALx2lgvENIzPl0QjskcKr2JzXLRZnWOkRlIYzTvNvPVYKeO
         +bKd/HHPjgjXB8qpWCwYSs8eVbZCRu1Fx8Ibvhw6QBC4etTfSYKWOi2G6gYWF6CBeHq2
         PIhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=oVTPgSHu;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m8si9800535pgt.140.2019.06.01.06.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:22:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=oVTPgSHu;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 245EB20673;
	Sat,  1 Jun 2019 13:22:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395359;
	bh=+suWpKVMNp3OuefTy5XAmtprvWsLh/6/kbmYWMzZsSc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=oVTPgSHutV4LGVAFDKdLYKLsOTi1JNgObOL85pf+ALdz+Lk5a9D3BHyIzWci1NSk/
	 L7xZI87nFpIl6+ATCWhE5FwvEpt9EFeugT0ZAQR0WpZBiKNd2aHfF6kLq6vLOc1ayF
	 kj2i9NlaZaiy7QL6zGzgSUTruX/UpdpJ1PUGutAY=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 015/141] mm/slab.c: fix an infinite loop in leaks_show()
Date: Sat,  1 Jun 2019 09:19:51 -0400
Message-Id: <20190601132158.25821-15-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132158.25821-1-sashal@kernel.org>
References: <20190601132158.25821-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit 745e10146c31b1c6ed3326286704ae251b17f663 ]

"cat /proc/slab_allocators" could hang forever on SMP machines with
kmemleak or object debugging enabled due to other CPUs running do_drain()
will keep making kmemleak_object or debug_objects_cache dirty and unable
to escape the first loop in leaks_show(),

do {
	set_store_user_clean(cachep);
	drain_cpu_caches(cachep);
	...

} while (!is_store_user_clean(cachep));

For example,

do_drain
  slabs_destroy
    slab_destroy
      kmem_cache_free
        __cache_free
          ___cache_free
            kmemleak_free_recursive
              delete_object_full
                __delete_object
                  put_object
                    free_object_rcu
                      kmem_cache_free
                        cache_free_debugcheck --> dirty kmemleak_object

One approach is to check cachep->name and skip both kmemleak_object and
debug_objects_cache in leaks_show().  The other is to set store_user_clean
after drain_cpu_caches() which leaves a small window between
drain_cpu_caches() and set_store_user_clean() where per-CPU caches could
be dirty again lead to slightly wrong information has been stored but
could also speed up things significantly which sounds like a good
compromise.  For example,

 # cat /proc/slab_allocators
 0m42.778s # 1st approach
 0m0.737s  # 2nd approach

[akpm@linux-foundation.org: tweak comment]
Link: http://lkml.kernel.org/r/20190411032635.10325-1-cai@lca.pw
Fixes: d31676dfde25 ("mm/slab: alternative implementation for DEBUG_SLAB_LEAK")
Signed-off-by: Qian Cai <cai@lca.pw>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 018d32496e8d1..46f21e73db2f8 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4326,8 +4326,12 @@ static int leaks_show(struct seq_file *m, void *p)
 	 * whole processing.
 	 */
 	do {
-		set_store_user_clean(cachep);
 		drain_cpu_caches(cachep);
+		/*
+		 * drain_cpu_caches() could make kmemleak_object and
+		 * debug_objects_cache dirty, so reset afterwards.
+		 */
+		set_store_user_clean(cachep);
 
 		x[1] = 0;
 
-- 
2.20.1

