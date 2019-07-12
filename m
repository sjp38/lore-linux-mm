Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 029A7C742A1
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 01:10:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B84A214AF
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 01:10:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="HtcxWO4G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B84A214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AB828E010B; Thu, 11 Jul 2019 21:10:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15CCE8E00DB; Thu, 11 Jul 2019 21:10:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 072F58E010B; Thu, 11 Jul 2019 21:10:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C7F248E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 21:10:19 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h3so4656549pgc.19
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 18:10:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EUPEqAyhpwTtgDqJ62ya1pjngvc+Gk4DR3wCwHiNqJM=;
        b=cryvQQzbcDEfFV16+bY1q9iY/DRHANhQ/YcrNUJzmqRmXhNV0clBhYmBqdwrIRpk6V
         4074UgKS7ddCuD0ccEle3gQV2v0TjKBCHu5nE1RbmmvVF/kjCtbm3AEwlyx5ZsjMZd59
         rYobPEW8oCahd9HAuM2lYLXhYpJn33i9Ao9xuODONRJvbI+7Q6l6+BP0f3GFfMr0N5nc
         snxEflOzygDPUD47H9SHbIW3ssci4+3HxqRyTEDAuHdKxM62LG/RmUfQpQh2CAUdWeaZ
         znceWqzJtG8KXqG0cE5bNWTagw7SOMpnwSRf5clDFoMwPGU4/iJ69axZjziBnHqjg+DX
         sb1g==
X-Gm-Message-State: APjAAAVUoZVKzrWUucySR169U0uvvTL8pb6HHmfWdgIyUIoGG2NUQtk1
	RQVsafe5INGGn+NgvGggke8bEXogKi6wGrsS9uvmF4uvueb8lX7dvugQDIOyQXT/f1CDosc6kK+
	DcBstvrHnfLTyJ55FJA79Ce4KI8f7HNTx3UFj0rWF9tL5MgnPtVq1yyiMAHIlKCPo+g==
X-Received: by 2002:a63:dc50:: with SMTP id f16mr7581800pgj.447.1562893819393;
        Thu, 11 Jul 2019 18:10:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQylY+DX1gzBql2r0vDXnNigXBElPrGELYQcJwk4Jx00hN98UGAs1ZAQuxw1+/o0uTRNmi
X-Received: by 2002:a63:dc50:: with SMTP id f16mr7581735pgj.447.1562893818505;
        Thu, 11 Jul 2019 18:10:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562893818; cv=none;
        d=google.com; s=arc-20160816;
        b=ttHVzYiPFk9FT7SLAqwgFnDtbTcMaI+3Cv7zUrj3tV5PD7Jo0XebaRkkeBCpWVwDX0
         SY8DobaI44BLLU3VKPPFs+/ahaxeIqAmex6MQ7Exrv4ADAgsKUmUChpDpd7+AlZQh7fz
         rHPpDbEiIvckh2ORCcapl9AsdzmLldS4pNA0g5skXCpjCqJPDAvdx9bSVtcQrmHLBqfU
         rGWK5KQkiFP2qNT2+SSCmNTKr+SDAnmhPBbXq9ys3BIA+bzz5gX7L/+btRJPVFVUSQ7K
         GE2s6pks2PueU3de9G4W8BCtrsmNm2rSadRTBdEgXyTaonRG/dkbaEkTzeCQidIOMDsx
         7SZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=EUPEqAyhpwTtgDqJ62ya1pjngvc+Gk4DR3wCwHiNqJM=;
        b=qoA6iwku11xAl9CD9FU4E9v78bI/9q0K2jPUXpHv2dkU+LXDGp6XGjfd17kxdk8KAu
         bWSHy+ZMUZIkti6wNWK8jbL8FVZKeUgDZTSeDTEANzur16TPUKBDQvEyXXVMS0vHbugN
         qDaFWGhRJVKokyMaH1aIb5lb+ZVHQW+UuDLlWWA3ym0//OKFUxcLJhjHQyc3d58/0Kby
         W5eohfeqRDqyTCfphrnDYYhJWDM0bpOpy+/5ylxOQyEdauoxhyyhLnoxabOuzN2SVjut
         kYrAzPJT89AjBtT2voLenf+nBwBhQ/yKeXiVj4ojWm3iaLOcpP6TJNSjKt6t1MZ4dA/N
         ZDlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=HtcxWO4G;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 3si6317952plp.31.2019.07.11.18.10.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 18:10:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=HtcxWO4G;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C5A6821019;
	Fri, 12 Jul 2019 01:10:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562893818;
	bh=2/LW+KsVlppENNnulMTMmXj8MykqRJ6aHGeN8JW70cM=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=HtcxWO4G7XVoVCv35riSbs8zHzhLTS0Rn4OjGpIInOif01b1S3r0gmw7/jgyXODID
	 ESy8ij39m1W6MrV+aEKWvDscY237YQUkxIu7fZDWOYftX5BxnKPIEEA4nwtfqw3lP+
	 ud2cEFnKAD3oFmp5FMedYrgT80f6vqpRP9EitCtQ=
Date: Thu, 11 Jul 2019 18:10:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: mhocko@suse.com, linux-mm@kvack.org, shaoyafang@didiglobal.com, Johannes
 Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm/vmscan: expose cgroup_ino for memcg reclaim
 tracepoints
Message-Id: <20190711181017.d8fc41678fc7a754264c6bdf@linux-foundation.org>
In-Reply-To: <1554804700-7813-1-git-send-email-laoar.shao@gmail.com>
References: <1554804700-7813-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Can we please get some review of this one?  It has been in -mm since
May 22, no issues that I've heard of.


From: Yafang Shao <laoar.shao@gmail.com>
Subject: mm/vmscan: expose cgroup_ino for memcg reclaim tracepoints

We can use the exposed cgroup_ino to trace specified cgroup.

For example,
step 1, get the inode of the specified cgroup
	$ ls -di /tmp/cgroupv2/foo
step 2, set this inode into tracepoint filter to trace this cgroup only
	(assume the inode is 11)
	$ cd /sys/kernel/debug/tracing/events/vmscan/
	$ echo 'cgroup_ino == 11' > mm_vmscan_memcg_reclaim_begin/filter
	$ echo 'cgroup_ino == 11' > mm_vmscan_memcg_reclaim_end/filter

The reason I made this change is to trace a specific container.

Sometimes there're lots of containers on one host.  Some of them are
not important at all, so we don't care whether them are under memory
pressure.  While some of them are important, so we want't to know if
these containers are doing memcg reclaim and how long this relaim
takes.

Without this change, we don't know the memcg reclaim happend in which
container.

Link: http://lkml.kernel.org/r/1557649528-11676-1-git-send-email-laoar.shao@gmail.com
Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: <shaoyafang@didiglobal.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/trace/events/vmscan.h |   71 ++++++++++++++++++++++++++------
 mm/vmscan.c                   |   18 +++++---
 2 files changed, 72 insertions(+), 17 deletions(-)

--- a/include/trace/events/vmscan.h~mm-vmscan-expose-cgroup_ino-for-memcg-reclaim-tracepoints
+++ a/include/trace/events/vmscan.h
@@ -127,18 +127,43 @@ DEFINE_EVENT(mm_vmscan_direct_reclaim_be
 );
 
 #ifdef CONFIG_MEMCG
-DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_reclaim_begin,
+DECLARE_EVENT_CLASS(mm_vmscan_memcg_reclaim_begin_template,
 
-	TP_PROTO(int order, gfp_t gfp_flags),
+	TP_PROTO(unsigned int cgroup_ino, int order, gfp_t gfp_flags),
 
-	TP_ARGS(order, gfp_flags)
+	TP_ARGS(cgroup_ino, order, gfp_flags),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, cgroup_ino)
+		__field(int, order)
+		__field(gfp_t, gfp_flags)
+	),
+
+	TP_fast_assign(
+		__entry->cgroup_ino	= cgroup_ino;
+		__entry->order		= order;
+		__entry->gfp_flags	= gfp_flags;
+	),
+
+	TP_printk("cgroup_ino=%u order=%d gfp_flags=%s",
+		__entry->cgroup_ino, __entry->order,
+		show_gfp_flags(__entry->gfp_flags))
 );
 
-DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_softlimit_reclaim_begin,
+DEFINE_EVENT(mm_vmscan_memcg_reclaim_begin_template,
+	     mm_vmscan_memcg_reclaim_begin,
 
-	TP_PROTO(int order, gfp_t gfp_flags),
+	TP_PROTO(unsigned int cgroup_ino, int order, gfp_t gfp_flags),
 
-	TP_ARGS(order, gfp_flags)
+	TP_ARGS(cgroup_ino, order, gfp_flags)
+);
+
+DEFINE_EVENT(mm_vmscan_memcg_reclaim_begin_template,
+	     mm_vmscan_memcg_softlimit_reclaim_begin,
+
+	TP_PROTO(unsigned int cgroup_ino, int order, gfp_t gfp_flags),
+
+	TP_ARGS(cgroup_ino, order, gfp_flags)
 );
 #endif /* CONFIG_MEMCG */
 
@@ -167,18 +192,40 @@ DEFINE_EVENT(mm_vmscan_direct_reclaim_en
 );
 
 #ifdef CONFIG_MEMCG
-DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_reclaim_end,
+DECLARE_EVENT_CLASS(mm_vmscan_memcg_reclaim_end_template,
 
-	TP_PROTO(unsigned long nr_reclaimed),
+	TP_PROTO(unsigned int cgroup_ino, unsigned long nr_reclaimed),
 
-	TP_ARGS(nr_reclaimed)
+	TP_ARGS(cgroup_ino, nr_reclaimed),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, cgroup_ino)
+		__field(unsigned long, nr_reclaimed)
+	),
+
+	TP_fast_assign(
+		__entry->cgroup_ino	= cgroup_ino;
+		__entry->nr_reclaimed	= nr_reclaimed;
+	),
+
+	TP_printk("cgroup_ino=%u nr_reclaimed=%lu",
+		__entry->cgroup_ino, __entry->nr_reclaimed)
 );
 
-DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_softlimit_reclaim_end,
+DEFINE_EVENT(mm_vmscan_memcg_reclaim_end_template,
+	     mm_vmscan_memcg_reclaim_end,
 
-	TP_PROTO(unsigned long nr_reclaimed),
+	TP_PROTO(unsigned int cgroup_ino, unsigned long nr_reclaimed),
 
-	TP_ARGS(nr_reclaimed)
+	TP_ARGS(cgroup_ino, nr_reclaimed)
+);
+
+DEFINE_EVENT(mm_vmscan_memcg_reclaim_end_template,
+	     mm_vmscan_memcg_softlimit_reclaim_end,
+
+	TP_PROTO(unsigned int cgroup_ino, unsigned long nr_reclaimed),
+
+	TP_ARGS(cgroup_ino, nr_reclaimed)
 );
 #endif /* CONFIG_MEMCG */
 
--- a/mm/vmscan.c~mm-vmscan-expose-cgroup_ino-for-memcg-reclaim-tracepoints
+++ a/mm/vmscan.c
@@ -3191,8 +3191,10 @@ unsigned long mem_cgroup_shrink_node(str
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
 
-	trace_mm_vmscan_memcg_softlimit_reclaim_begin(sc.order,
-						      sc.gfp_mask);
+	trace_mm_vmscan_memcg_softlimit_reclaim_begin(
+					cgroup_ino(memcg->css.cgroup),
+					sc.order,
+					sc.gfp_mask);
 
 	/*
 	 * NOTE: Although we can get the priority field, using it
@@ -3203,7 +3205,9 @@ unsigned long mem_cgroup_shrink_node(str
 	 */
 	shrink_node_memcg(pgdat, memcg, &sc, &lru_pages);
 
-	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
+	trace_mm_vmscan_memcg_softlimit_reclaim_end(
+					cgroup_ino(memcg->css.cgroup),
+					sc.nr_reclaimed);
 
 	*nr_scanned = sc.nr_scanned;
 	return sc.nr_reclaimed;
@@ -3241,7 +3245,9 @@ unsigned long try_to_free_mem_cgroup_pag
 
 	zonelist = &NODE_DATA(nid)->node_zonelists[ZONELIST_FALLBACK];
 
-	trace_mm_vmscan_memcg_reclaim_begin(0, sc.gfp_mask);
+	trace_mm_vmscan_memcg_reclaim_begin(
+				cgroup_ino(memcg->css.cgroup),
+				0, sc.gfp_mask);
 
 	psi_memstall_enter(&pflags);
 	noreclaim_flag = memalloc_noreclaim_save();
@@ -3251,7 +3257,9 @@ unsigned long try_to_free_mem_cgroup_pag
 	memalloc_noreclaim_restore(noreclaim_flag);
 	psi_memstall_leave(&pflags);
 
-	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
+	trace_mm_vmscan_memcg_reclaim_end(
+				cgroup_ino(memcg->css.cgroup),
+				nr_reclaimed);
 
 	return nr_reclaimed;
 }
_

