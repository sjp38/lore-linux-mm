Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBC48C28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:24:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 940C027358
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:24:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="DZGkah5e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 940C027358
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCE0B6B02AE; Sat,  1 Jun 2019 09:24:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D82546B02B0; Sat,  1 Jun 2019 09:24:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD4A76B02B1; Sat,  1 Jun 2019 09:24:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 73B2B6B02AE
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:24:21 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id w14so8244309plp.4
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:24:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AxueT8Q5DnhJsw+K4mEtsj6Ay1oYCVniCqI7qjyUtBQ=;
        b=XAMuJsaZJcByCSRkmq48F501rJg2SlU9LMU4DX/x4Dq7wdBvUwPvmXxsBik3MknT+P
         kBlTcmygCKbJhcwWU60f1RUdmJAfX9n+7IBcVyAudWcjNhpTT1FcoZ/Z44bYNilnR+ww
         6K1JFujiSlqMyVdMbFlsywhQzZM1lJa8HNOy2UBNoYPESuHDdKZCd/0sNQath3iN3pgI
         Nlx/FaNgvwOh+QM7uYJ5eIb4iif5Uetv6fglcXpnr1NwrWeUgDm1c2F40QAP9IYFJPpg
         y+GVPCLJogcp12N1fkTXilgMKuvvnIFxXFZvuCyYcKx3/aAhyGssvuaOXo/gaKKfPkr/
         6i5w==
X-Gm-Message-State: APjAAAXUexxaBNIIgw4HbLsglj5lbl1Sm3I22eaXSDymxabBe0FmLVq3
	XQ09x0rtvPNVC5ZlEg/mvqVpl2yNlOdQhfpAuYxLW7LltNppb2fyohRK9s6YWKndJ0pHTnQJYb2
	03O9ASOylS1NIFanPda+WNr3orHvJ3zgSkNw07b/LvPEWcBF9oFkfFEByq0IA0Yshnw==
X-Received: by 2002:a17:90a:a00a:: with SMTP id q10mr16089978pjp.102.1559395461097;
        Sat, 01 Jun 2019 06:24:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/Stm5lGdi/XNxd27LpZ7LJS6xIf9E9qa1Te5VAljI+fM0HCgVpMJKf8IWPIXqPil0JRxL
X-Received: by 2002:a17:90a:a00a:: with SMTP id q10mr16089917pjp.102.1559395460471;
        Sat, 01 Jun 2019 06:24:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395460; cv=none;
        d=google.com; s=arc-20160816;
        b=yNMeKgyCZGFi/ZSQfv9LthVWMLqqopncD84xevtR2pD7h8EpIUkrG7eAvYHVUzasTH
         HpHe1vhV2XlGXUvXybGUFoZTJ0atCZT/8DD+wxDZNkthvzO7vOJ/jDAu9UewgsOs5nKP
         fiACfMN+wE2DNHUjGZPX4LxfsmKVNgYzVxXPym3VA/fEJCJoYYhYABn+AG98ycsw8ppD
         j3bXEgJxcUd5c1M1mxDvP2pzGhk+EoGWSjNMXpRTVP175LNI82pfkJftO9rxIDTyW79e
         TSox1z/r1M1+yHLouLOuZeGqS7YFCLB2fK5dQyjMXEcq264xPU+tCrXlQNBJ4E8oAduc
         eugw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=AxueT8Q5DnhJsw+K4mEtsj6Ay1oYCVniCqI7qjyUtBQ=;
        b=dsIkWNLQdONPA9NJFKjUlOTCkIc49Fe4b10jEfPHZ5siB3tYVszXAc6wp4Xx6f7qts
         1NQi4TNB30rqp+Em2eNia4dGLJVhz/iY8mi8cHffUkZzYzN6UIMVptmyKMDcFKrnPRsY
         s8UAfCIN1lxQuf4D236s5DguGtie30eTmTZv2cnV0MPQVQ7Qq7T7++puAugybwzgkm7R
         847mpXZGj1H0J2/n9X000SBZ9oQKACqOcDdjGpYhqZOnck4qleMpILg/YE9+p00/ccc1
         zpFMEis87XIgFLQLrNqFua9GWVqxBlMTKQsn5FKP/ixY83eU2x12wu5IHw0iFniVdbw6
         diGg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=DZGkah5e;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p22si9966594plo.341.2019.06.01.06.24.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:24:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=DZGkah5e;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id EB9BD27381;
	Sat,  1 Jun 2019 13:24:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395460;
	bh=1FCE2P2huRigfGwOZTyr6/C7luFUnEpUUA7uGPN+dFw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=DZGkah5eAu2N9rYwOEcgn6p9K2GvC6/ouED06+KTcGnYkhnKOnuooDG9wMjHgoQfz
	 bQjoU4Q17LHH1HSIT+SgF6PFS44Xa9X+VWP3q9e58IJJzN3kqYZvBVXnGm2BR6GGIm
	 UudXqYxLkdBNBJraWttrIHbSVmUiRWydHDBM+VwI=
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
Subject: [PATCH AUTOSEL 4.14 12/99] mm/slab.c: fix an infinite loop in leaks_show()
Date: Sat,  1 Jun 2019 09:22:19 -0400
Message-Id: <20190601132346.26558-12-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132346.26558-1-sashal@kernel.org>
References: <20190601132346.26558-1-sashal@kernel.org>
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
index 843ecea9e336b..a04aeae423062 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4320,8 +4320,12 @@ static int leaks_show(struct seq_file *m, void *p)
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

