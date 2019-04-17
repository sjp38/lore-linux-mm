Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 328A8C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 16:04:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9D5C206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 16:03:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="eDsDWskl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9D5C206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BF526B0005; Wed, 17 Apr 2019 12:03:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56C406B0006; Wed, 17 Apr 2019 12:03:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40FDA6B0007; Wed, 17 Apr 2019 12:03:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1DB6D6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:03:59 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id y1so18596788ybg.1
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 09:03:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=VRTGHEZ2P8IOenNpGB+9Wp9aVSXnSjOQvSDcZRVNsO8=;
        b=s5ootZCF5LWq9R15ZaAXfFHLsakjsza6kc7Mm+lc2WIR/8N4mQX6XPqblPQrbFw/Yy
         Pm8ObHlUVzhgJJ+pyhwMSiGdPsw4530a5b2FDGTs8Ag9zZTujNKHX9xbjOiLtJjnpGB6
         4Xiwme6wEcCrCPnvtM1N0sL3aPj5zCPwDLm2j8gJvYy/UvM7m+MXke056C4KWIgviWYB
         DHqJ3ogPBJ8nETzR9Dv7siPAE8g3dGVAfjAV+EVS8HYuwDz2XEgANwfp7cv9Lflg3jkh
         NJSHQjlEkNetQaExDtH2RruSSPTD5Gzr3Q2Fnoox3fIVV+zW51dfBJQ70p7AoQKI/+BV
         Cu8A==
X-Gm-Message-State: APjAAAWtVmjT5yj2RiEvwQK62kbl+UmcVDDdNd+a8ZhnFYG+pfgoHbsm
	9O/xhOwtI7GLu0rftAtrgm7JZY7HjfeeX7xA41iWdE02XuVW0+iHJEqOndoRmAJ2c1sU4obfKRe
	CBVIfG9g588QPmtqV8Vs7cp+2D06JxSrd2MXSzGe72w8RDTiouO4IxQKwHFr+UAZTaQ==
X-Received: by 2002:a25:abca:: with SMTP id v68mr53010307ybi.287.1555517038831;
        Wed, 17 Apr 2019 09:03:58 -0700 (PDT)
X-Received: by 2002:a25:abca:: with SMTP id v68mr53010151ybi.287.1555517037426;
        Wed, 17 Apr 2019 09:03:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555517037; cv=none;
        d=google.com; s=arc-20160816;
        b=k5+2pnlZcnBK0u72oRf/OyJmwGlwc/eDRbdH4sxCU6o/xxCbXCQQKXTjmJm6cMigY2
         J/EfYQuinOZWxyFZBOKG332LlmnmCNveDxcjIB0LVTjAjtd+2aBUMmbEkT6FToi7SJuM
         D/bBJdvBRDQIPwSBC6TpUiF4JWtwBDLx5TokV68felft3rhvBPbVpDwGXMzwcOjuJhIa
         rdg5TiHxX9TB7oP+NH/IbJHIAjse3mxa+P2Do3QWX7+OYqu5eQe3feZaieyuybH4U0aN
         RQm3k2qN01pdlntd67GKoPLhJU8cleEflN9RU2x/tTUy82dVrHjgFmdnwdUM6D5f6oOy
         QH9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=VRTGHEZ2P8IOenNpGB+9Wp9aVSXnSjOQvSDcZRVNsO8=;
        b=wmIDcCjEWy9nwtbk7hOshaeW2AvoJIihQMgcvNDUveF+khZUZWClYalHm+gk90BamU
         Ddm987vLTbXmrSdPa3LBnv++CNUZINDg70bgdiSbU19Adb4CwwG69AP+jvBbiiexxRaH
         Mys/xsgJezuCx3uJtVO5Ws29Cuvq4+NYPSnpR2/NCpbsIIFtPqMyuXtE/Tg0ffdosoy7
         QNEcrF1/SXskM1OlHdkJpNVUn/k8atnuaru4j2lZFgTSi9x6RorLpkThP2XU68wTBylL
         X3foqsKmhqm8Q5aXO0P1V1D60vhXhJRKusOvp2dnA+zcHpOPHoeAuJqDpj8bBVUBwXvg
         0q0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=eDsDWskl;
       spf=temperror (google.com: error in processing during lookup of hannes@cmpxchg.org: DNS error) smtp.mailfrom=hannes@cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z186sor3726144ybz.71.2019.04.17.09.03.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 09:03:49 -0700 (PDT)
Received-SPF: temperror (google.com: error in processing during lookup of hannes@cmpxchg.org: DNS error) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=eDsDWskl;
       spf=temperror (google.com: error in processing during lookup of hannes@cmpxchg.org: DNS error) smtp.mailfrom=hannes@cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=VRTGHEZ2P8IOenNpGB+9Wp9aVSXnSjOQvSDcZRVNsO8=;
        b=eDsDWsklfWOL2hK7nDALTNMMlTlJIAJEonP3lzTed+JBPFsy1zrHu5SfdLbRcQudn3
         vvGH2YGnaYPplAORrscyf+5TkmpiilGWvS6Xzld53D1WN94AVV5fvBJ6FvzmtW7K1V2u
         eF2EgewWaoAURpfkJiITXWwUHrro3eMOkD1XVDiIryzdAAsDFpq6JyqqhNHCrSzEXNXm
         fKx6TXJ1tE8HLk9w8ij1TqxuHD7QqxHT6ySUFCsKnTzXOat6L48ifdDVtD2KWNwqkzye
         4jUMSvyYPhGDH4gX5dSJDL1H4PZdCtqaoYYVamJqrOZL4vNQbUp/mj3z1qlY3U3vzZEU
         /Lgw==
X-Google-Smtp-Source: APXvYqyB4+2uikIAtAhDit0gTTnf/Zwxa7aFIrGyV05hh5hG7sgu2yY9yunwx34n0IGmVamXTC5MwA==
X-Received: by 2002:a25:9784:: with SMTP id i4mr59451217ybo.394.1555517029056;
        Wed, 17 Apr 2019 09:03:49 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::2:fc54])
        by smtp.gmail.com with ESMTPSA id l82sm19329426ywl.6.2019.04.17.09.03.47
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 09:03:48 -0700 (PDT)
Date: Wed, 17 Apr 2019 12:03:47 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: akpm@linux-foundation.org
Cc: guro@fb.com, mhocko@kernel.org, mm-commits@vger.kernel.org,
	shakeelb@google.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: +
 mm-memcontrol-make-cgroup-stats-and-events-query-api-explicitly-local.patch
 added to -mm tree
Message-ID: <20190417160347.GC23013@cmpxchg.org>
References: <20190416015132.yxxUAu8Rx%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190416015132.yxxUAu8Rx%akpm@linux-foundation.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 15, 2019 at 06:51:32PM -0700, akpm@linux-foundation.org wrote:
> 
> The patch titled
>      Subject: mm: memcontrol: make cgroup stats and events query API explicitly local
> has been added to the -mm tree.  Its filename is
>      mm-memcontrol-make-cgroup-stats-and-events-query-api-explicitly-local.patch

From 65f026fe5481f8dc32b3dc3b97994f8cdc82dd17 Mon Sep 17 00:00:00 2001
From: Johannes Weiner <hannes@cmpxchg.org>
Date: Wed, 17 Apr 2019 11:08:47 -0400
Subject: [PATCH] mm: memcontrol: make cgroup stats and events query API
 explicitly local fix

The lruvec_page_state() -> lruvec_page_state_local() rename should
have been part of this patch, not the previous one.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 871c661ca8be..6e99a8b9b2ad 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2979,7 +2979,7 @@ static void snapshot_refaults(struct mem_cgroup *root_memcg, pg_data_t *pgdat)
 		struct lruvec *lruvec;
 
 		lruvec = mem_cgroup_lruvec(pgdat, memcg);
-		refaults = lruvec_page_state(lruvec, WORKINGSET_ACTIVATE);
+		refaults = lruvec_page_state_local(lruvec, WORKINGSET_ACTIVATE);
 		lruvec->refaults = refaults;
 	} while ((memcg = mem_cgroup_iter(root_memcg, memcg, NULL)));
 }
-- 
2.21.0

