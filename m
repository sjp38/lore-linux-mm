Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAE65C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 15:52:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A54620656
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 15:52:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="bYJhk0dL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A54620656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E02856B0005; Wed, 17 Apr 2019 11:52:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8A2E6B0006; Wed, 17 Apr 2019 11:52:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C56076B0007; Wed, 17 Apr 2019 11:52:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9EFD46B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 11:52:47 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id d2so18540402ybs.10
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 08:52:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=sg3wq3MteswBnaiecj+bveQZpY+H78RJr86m90y8oys=;
        b=rc4o/JSqpiCXD8hLOkR0FIlWz2UcNFi7WTFy5MBk0sh61OJk6cDOR3HQZDF1DdnS/Y
         kJRCPEfUg6vUSY9SxP2Fcq/EXv7mo+wqv/KFKvrNhfMifFSBHN4p/j7j+/KKyrNPJMdy
         2sx6uL1OzNRW4sUYYS2ZABMSXpTmVkzd8C/wD/ueW1wbgMGlgBJ4CyZ/t71rT9aXo3i7
         k3E0btXNXZrZfIDZG3d15ti8kg5OiR8fcwJf/gqn8Azvb018HNPNx7CKDJSrFoaZY10W
         Ov5J7KnEfY0h0oF2b/IuysxUUJtWIGZ5CR2R5pLG/ofonXr8GzocGJbtP2QhWZ6o8PmX
         2p0A==
X-Gm-Message-State: APjAAAXTeYVo/yE8tvN1nNMLgSDKl7JDwDUMgJOB1oG6eu8ZU/Szu3cw
	eVgr+eVDTICgRRyHH385CSTHKeseUHyk/zbJWFfx66kTBdY+AKWp9XbKn8WVoVCxf6MZ35dBHbf
	JOdvIzAR+zGbhbsaQMeTsQDEvh6vmjgkcwgP8w6lCw94ku3Rnd5aN3oc8fsmu8saSlw==
X-Received: by 2002:a81:6a42:: with SMTP id f63mr66918718ywc.60.1555516367355;
        Wed, 17 Apr 2019 08:52:47 -0700 (PDT)
X-Received: by 2002:a81:6a42:: with SMTP id f63mr66918654ywc.60.1555516366355;
        Wed, 17 Apr 2019 08:52:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555516366; cv=none;
        d=google.com; s=arc-20160816;
        b=Qk+FnEQ5Im9O10A+v2OYU/zkmrvsG4/e+A6QW4U9N7I56UAVevSOih1jVAAb9Tk5st
         NS59xG2ky7ETvl8BKsPZ7yhS5b5bh9OBxUUM9YLXRlGODPkFvjLyWfWdQny4tN60UYiL
         m05Db7ZDk++xuqPK9+s2TNRDepqAbanOTZEMgssHbxQzOfkR+neJcgShYLRwwkGVBBaD
         rqRC0Xy06GizJKyFXHOmmxWbUcCrHEMlI5QPMMWokMn/Unk80x3L1NgVVbMx1tWZ61jI
         POsgJsfmLYxtyMr3rAK46hlLp3gaQnZmIounPEW63OuJdYronz04hv2vq6B4ph9pM1o4
         tabA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=sg3wq3MteswBnaiecj+bveQZpY+H78RJr86m90y8oys=;
        b=sFNlpDObPqgNbcXY953icZht1t0l/rtn86om6uusTbPSUeFh37HlXLgl3tBOLkGqwn
         coHBW9Cz13h51a4d+wj1oFtkRV/Ne0MIAHCHG1+oO3G2hJX76PAc9ZBGQigjA8oPb2DX
         MLlTfP0/2LZV7apSh7aMu95lBtAc4c+B0adLJN6xgSW2DTmLY2uG4F4rVvQL7Lu3DyiU
         SaarnPBD+3soDlCONMiaiCRKGlhbntvD20VzXCZqvPugo7/rILy2Jxc5aoupFnERAIiv
         vvnGy5BkZB+lv1Geg/Dsw+uxHJZ2EGZQaRfJjFtqzVVMkFGayOL39vR49/N7uWP25AF8
         KJOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=bYJhk0dL;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e204sor11540926ybe.25.2019.04.17.08.52.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 08:52:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=bYJhk0dL;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=sg3wq3MteswBnaiecj+bveQZpY+H78RJr86m90y8oys=;
        b=bYJhk0dLrPtTxpjPurxmDPGapsniq5TRVmv2A6DGFE6jpqbRdsEcFg5Q2KvfAsOpen
         l74SfecVlMebY6oiDK+k83CYJ0SX7NzkRP0RPbi90WD4OtJllWHGVti8CbaVwNV1aNBn
         +SI9MI7iW7Letd3aig1QTC3dd+DvGGX3CA+NmXot1uCu+fJh6kwzno1NJJCmzx7Vaapz
         dIvhnraeSD1i/m7WJrTqNo9m9OqdRcvn7DCk93gRVX7H8hcvszEj6cObcVyr5mQgKXYZ
         xZBx1k4I6JVpDuq+7S4X4x+rJ2KwGqQ03gsK+xjlz+omnm8Elti0/MCEGXinyTpELxwi
         17wg==
X-Google-Smtp-Source: APXvYqzz8WMq8k7MzdIHvCMSCLAQVY4Q0vbKn+dG9MzFKu7XCQZZv5oDI0gB1QChOxDaH3RLOM0pJg==
X-Received: by 2002:a5b:987:: with SMTP id c7mr473393ybq.499.1555516363612;
        Wed, 17 Apr 2019 08:52:43 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::2:fc54])
        by smtp.gmail.com with ESMTPSA id h3sm22321975ywa.61.2019.04.17.08.52.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 08:52:42 -0700 (PDT)
Date: Wed, 17 Apr 2019 11:52:41 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: shakeelb@google.com, mhocko@kernel.org, guro@fb.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: +
 mm-fix-inactive-list-balancing-between-numa-nodes-and-cgroups.patch added to
 -mm tree
Message-ID: <20190417155241.GB23013@cmpxchg.org>
References: <20190415212744.v9aTn%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190415212744.v9aTn%akpm@linux-foundation.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 15, 2019 at 02:27:44PM -0700, akpm@linux-foundation.org wrote:
> 
> The patch titled
>      Subject: mm: fix inactive list balancing between NUMA nodes and cgroups
> has been added to the -mm tree.  Its filename is
>      mm-fix-inactive-list-balancing-between-numa-nodes-and-cgroups.patch

---

From b5a82062b99fd3d2d4f4f7dc220d4acb1aa9b749 Mon Sep 17 00:00:00 2001
From: Johannes Weiner <hannes@cmpxchg.org>
Date: Wed, 17 Apr 2019 11:08:07 -0400
Subject: [PATCH] mm: fix inactive list balancing between NUMA nodes and
 cgroups fix

lruvec_page_state_local() is only defined later in the series. This is
fallout from reshuffling the patch series to pull a standalone fix
before the bigger stats rework.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c9f8afe61ae3..461720e2ae90 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2979,7 +2979,7 @@ static void snapshot_refaults(struct mem_cgroup *root_memcg, pg_data_t *pgdat)
 		struct lruvec *lruvec;
 
 		lruvec = mem_cgroup_lruvec(pgdat, memcg);
-		refaults = lruvec_page_state_local(lruvec, WORKINGSET_ACTIVATE);
+		refaults = lruvec_page_state(lruvec, WORKINGSET_ACTIVATE);
 		lruvec->refaults = refaults;
 	} while ((memcg = mem_cgroup_iter(root_memcg, memcg, NULL)));
 }
-- 
2.21.0

