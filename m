Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34EADC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 10:15:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF177208CA
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 10:15:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KRtoyIjK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF177208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B8A36B0007; Fri, 21 Jun 2019 06:15:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 869E78E0002; Fri, 21 Jun 2019 06:15:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7598E8E0001; Fri, 21 Jun 2019 06:15:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8C56B0007
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 06:15:22 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id s195so3813826pgs.13
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 03:15:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=EottP3kVbYYULOfj3WQDSi34DeCO2LSFzRkrgOwE2Ts=;
        b=qUzeptCpfV50L3f5Kbc5I77dCWdKfz+0nnk7wR6zg6wlMdsBeS7voNNihDoMv4om4r
         vZ2XIHX2SBzyt+1bKDGIwdXYT3jb5CkFaUM/kh+Tdvs0593iz6DGdtd8awWWkv0/bkRk
         XPH+UzRZwRlFgv2CIFUyJtiYjYl+NIsFH+QEbbBbOLFZQ7d0/+6UXyJC5PC/WX+H27dJ
         RhFWPa9IEU4LLerhj1I8A5h3vR1kWC5LEZRYrR0Fpaoch2GdksIam76+QiRCkZXRCvf/
         OQdAbzK2SkvSYJf8I/z671J6Ea7t0M1wyzTkhSJYXo8RGJUhRagSQg4dLnvcxM0KaD9+
         RVng==
X-Gm-Message-State: APjAAAUwBY+zT1nHe5o1LyCCtD/XGtd6G1BF18pCoCVQj4vqXLWxm1AF
	1lmGOKwEvBtVrSwwCATO/aTQpn3v5vqXECy3wXvtkMSP/EG9mUBX6zl89pyKufuwjUJuTTBLkwP
	wFWW6EVNWD5hFNV5USztl+2ScQ0TZPNqzA9OheKq2IVzEnax/gDpSSYaJkh6CbEX54w==
X-Received: by 2002:a17:902:222:: with SMTP id 31mr77191801plc.55.1561112121942;
        Fri, 21 Jun 2019 03:15:21 -0700 (PDT)
X-Received: by 2002:a17:902:222:: with SMTP id 31mr77191715plc.55.1561112121116;
        Fri, 21 Jun 2019 03:15:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561112121; cv=none;
        d=google.com; s=arc-20160816;
        b=PraV/uRVDCcJuKE+HamRi9P1PB2NuhzGqF2wr0jJytST0GjeW5QiC8w6yBeYYepPj3
         UzeODV39nCBsdlEZYD1cGWbKnu+Q89pS4voryFu0pXjv7iVFNyXs6DIOq/9eD5sEuggX
         C+ciCOh1VYoJ7yHOk2paGgeBhSKkRYeU6odg2buCgdQpGxccfOaHiKNuBs5v5Mt+If9P
         Vh0Ga0qEH5TUVbZjnZovEikh0H2tOw9uh8u2xIqTPQiNYgVYrOIsWJcAakT7GyZXfsec
         2biT0fZGAdX7Cq4eEQDXVxY8d8WSmHJSw7Kq2Fu0XlvN58B3ZKF39ANImUZ3Xsbw29nw
         N6nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=EottP3kVbYYULOfj3WQDSi34DeCO2LSFzRkrgOwE2Ts=;
        b=BdGLstE1PzClFLNXyr/YW0O1AyzRxZYJqpy/noVqD+nd+TbxJwAqvDYjhoMFzNYTIo
         Ud0RhDoFSzmHIdg1RV72GiBE/4hfJQZDGieMiOtEmatiuahjUij5EWuh7cxA/iPFmYpi
         aT6m4PQw7TZ1iJ4r8qilwROW4TolYE1gLmRVfxJ+0zCD2lxlD1MUnkgaqcA/HnMGY3gI
         QFYdgHOLzMYXujzRQ9HS9fQnQeTl4/KAY5t3OZCN7/AkMIh5A+bFrZMHHdb0RvXW26ot
         OM+MdVDAwt6r9M3zv7C2Zc/eZ84NanZmxmuLhVXYkA5+HV36K6UAX6TuKLjTfdacRdz2
         zSKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KRtoyIjK;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a13sor3361552pjh.1.2019.06.21.03.15.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 03:15:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KRtoyIjK;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=EottP3kVbYYULOfj3WQDSi34DeCO2LSFzRkrgOwE2Ts=;
        b=KRtoyIjKeg/XSY1xK3HxT6EJARcwEUwb266kUffwQchdAXQ9hKF0zf32XfqEWYRi0p
         UtRP7TlXt6Rjb57z4NKSqWCQiQM86P82uuIUEcZj33BdEBgDY5EOftQ92UXmE/2UMs6I
         hFAU9s5QVbQANtslyiV5vixVS5qH2UDHl4zT95IzHHyEJMS4DfX1Blhduff3d8//mY1l
         7TIpC6+86PYjWRo/9FFHSl1a2oxsQJiiMQH6R7fG97p1YTEl8dkdb6oRH3ME/qaoiFBQ
         nPD6kj1f3e8gXMYh+r+5BXICfOBp9HOstgM9D57sFuBcv8epToTe0TtSn+7Kpa2jfDDA
         gdwg==
X-Google-Smtp-Source: APXvYqzMAa73eatm5n/x18W+PYbhggMFCTtNXREv1iC4dMmDXsECr32IVzZOvNWQuAqbwL26Dvkcqg==
X-Received: by 2002:a17:90a:dd42:: with SMTP id u2mr5649875pjv.118.1561112120829;
        Fri, 21 Jun 2019 03:15:20 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id c9sm2578763pfn.3.2019.06.21.03.15.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 03:15:20 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org,
	ktkhai@virtuozzo.com,
	mhocko@suse.com,
	hannes@cmpxchg.org,
	vdavydov.dev@gmail.com,
	mgorman@techsingularity.net
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH 2/2] mm/vmscan: calculate reclaimed slab caches in all reclaim paths
Date: Fri, 21 Jun 2019 18:14:46 +0800
Message-Id: <1561112086-6169-3-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1561112086-6169-1-git-send-email-laoar.shao@gmail.com>
References: <1561112086-6169-1-git-send-email-laoar.shao@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There're six different reclaim paths by now,
- kswapd reclaim path
- node reclaim path
- hibernate preallocate memory reclaim path
- direct reclaim path
- memcg reclaim path
- memcg softlimit reclaim path

The slab caches reclaimed in these paths are only calculated in the above
three paths.

There're some drawbacks if we don't calculate the reclaimed slab caches.
- The sc->nr_reclaimed isn't correct if there're some slab caches
  relcaimed in this path.
- The slab caches may be reclaimed thoroughly if there're lots of
  reclaimable slab caches and few page caches.
  Let's take an easy example for this case.
  If one memcg is full of slab caches and the limit of it is 512M, in
  other words there're approximately 512M slab caches in this memcg.
  Then the limit of the memcg is reached and the memcg reclaim begins,
  and then in this memcg reclaim path it will continuesly reclaim the
  slab caches until the sc->priority drops to 0.
  After this reclaim stops, you will find there're few slab caches left,
  which is less than 20M in my test case.
  While after this patch applied the number is greater than 300M and
  the sc->priority only drops to 3.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/vmscan.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 18a66e5..d6c3fc8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3164,11 +3164,13 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	if (throttle_direct_reclaim(sc.gfp_mask, zonelist, nodemask))
 		return 1;
 
+	current->reclaim_state = &sc.reclaim_state;
 	trace_mm_vmscan_direct_reclaim_begin(order, sc.gfp_mask);
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
 	trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
+	current->reclaim_state = NULL;
 
 	return nr_reclaimed;
 }
@@ -3191,6 +3193,7 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 	};
 	unsigned long lru_pages;
 
+	current->reclaim_state = &sc.reclaim_state;
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
 
@@ -3212,7 +3215,9 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 					cgroup_ino(memcg->css.cgroup),
 					sc.nr_reclaimed);
 
+	current->reclaim_state = NULL;
 	*nr_scanned = sc.nr_scanned;
+
 	return sc.nr_reclaimed;
 }
 
@@ -3239,6 +3244,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 		.may_shrinkslab = 1,
 	};
 
+	current->reclaim_state = &sc.reclaim_state;
 	/*
 	 * Unlike direct reclaim via alloc_pages(), memcg's reclaim doesn't
 	 * take care of from where we get pages. So the node where we start the
@@ -3263,6 +3269,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 	trace_mm_vmscan_memcg_reclaim_end(
 				cgroup_ino(memcg->css.cgroup),
 				nr_reclaimed);
+	current->reclaim_state = NULL;
 
 	return nr_reclaimed;
 }
-- 
1.8.3.1

