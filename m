Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DC2DC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFA7720693
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFA7720693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69AC98E0001; Wed, 31 Jul 2019 22:18:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 612888E0005; Wed, 31 Jul 2019 22:18:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4395D8E0003; Wed, 31 Jul 2019 22:18:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D35768E0005
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:18:01 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id f2so38629947plr.0
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=O8E92+Ia5AD0U55V0BC44ctwhNJuImOq7q/fXkFayPw=;
        b=n1C/cflTnrVoi5KJ1HdclwNhmRWzwxUbYTgkrrO0e3BPsiMWMDF2F3Oc/zHX3hoJyu
         s/MxY5duXht3i6oAjWd64wbckNmGCFr56Vgjo4bckRI5vUCrtD5xfrexGwKK9g4jUQzv
         +1DcZBPaBsF6S6sOVEZInV2BAGiOvJXsvlzdL97iP7jUIiv5UQgnOCiJ12U00RnKT0g9
         5t7O2gnDV5mTDC+D/b0u01g0udheLIZ8cSJBdS2d79a4LIoIpYmZG58VLDJXsurW3DVR
         gk6Ox7oyqwbfXkg1QTLowObG9eSc9R19vPbqjM1WE+LqLms3Ugnqc97MeATiDKxGaDMh
         K4Tw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAWVOSEPTaSJBDlV5do1/UOoMfU1Nxw551WLszy8FO5BZdgJNNlE
	IUQ7gcDlaR/eAlELzHzonRdUnl/+UwLmgpOfHYmLzrQlEfEOWBzctXDZ8rFkTooW1Jf4oZBycQx
	ryq4Q1rNbmZDZo8o+PqyLzsmZW0AdrQloZU7TDjBwadGBb77bReyAK4L/GS2RXb8=
X-Received: by 2002:a63:fe15:: with SMTP id p21mr117957774pgh.149.1564625881424;
        Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRD3SDcKZNFpbrh84gUDgnT+4ONgTJvreccI7c/OUFRTDtFQyVflV8sxgFn2hNJLC2AYGO
X-Received: by 2002:a63:fe15:: with SMTP id p21mr117957711pgh.149.1564625880189;
        Wed, 31 Jul 2019 19:18:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564625880; cv=none;
        d=google.com; s=arc-20160816;
        b=b0XH7qhoQj9D8p2sYdyaL1i67Jl4uaABLB70IGPh0Ho6Iz9U/Cb8W6m0m8GlIfLPUT
         xTvwzA+V7/AmRm9qt7F3KrbIHCMx4n9kbr68kbB3LQdws7IvTRsyesmXAJI3gzNlNsgJ
         LaWK+Jk/O6wJZ0rPEhG8ojCjf4npiD06YRiJ2vjRgo8ihCLvcdk4tIZVGZLr9jPjm0mf
         HoN3tV915K9gwXM2MjK+x5sWxPTwf9HzqVS6v+zPQvilLhkcRMbu26DBjal6M+yvQCrw
         FVTDUy7ju4Iz1rOjHd4k2rALE3iyMn61mMD7EKTnZlqFkFAF4pFFuZ+Ttq4KjQKLfNox
         XgyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=O8E92+Ia5AD0U55V0BC44ctwhNJuImOq7q/fXkFayPw=;
        b=OsPg+mc3rHL5rW/frUWDVkcXMqCBVlmBrBkwJItbPg3ZBh+9LtOTQ9YOr0m2C+Nc81
         XdLcPCeLYMQ6jsmdw0jyZPsaOx6kaErvkTNWx9oOT5bcylztRgYh30LC7Uuq+B9sjzVU
         V/iNY6Mv3bi6bUeYLq9pIk1p8prNWet42cf5Z88IZUhcXKcr1SIvqCrpLWalwgusXTIy
         E8QhhPvcJZuuYp+6F41HiDLIjWdIsvoHt36wSRdbV7YZzjrMyVO7ewIyAAuKHJKmjTvV
         wtjAg4NnK73sN7elRNSicjVKUQvHtOh+GViphG2e77BVtJiwaeR2eE6Vpb5skTc2zP4T
         QVQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id f10si36673875pfq.194.2019.07.31.19.17.59
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:18:00 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id A172443EA07;
	Thu,  1 Aug 2019 12:17:58 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eB-0003as-26; Thu, 01 Aug 2019 12:16:51 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fG-0001l4-WA; Thu, 01 Aug 2019 12:17:59 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 11/24] xfs:: account for memory freed from metadata buffers
Date: Thu,  1 Aug 2019 12:17:39 +1000
Message-Id: <20190801021752.4986-12-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=1dk79d6Hl8FtNpQQbMkA:9
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

The buffer cache shrinker frees more than just the xfs_buf slab
objects - it also frees the pages attached to the buffers. Make sure
the memory reclaim code accounts for this memory being freed
correctly, similar to how the inode shrinker accounts for pages
freed from the page cache due to mapping invalidation.

We also need to make sure that the mm subsystem knows these are
reclaimable objects. We provide the memory reclaim subsystem with a
a shrinker to reclaim xfs_bufs, so we should really mark the slab
that way.

We also have a lot of xfs_bufs in a busy system, spread them around
like we do inodes.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_buf.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index 6e0f76532535..beb816cd54d6 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -1667,6 +1667,14 @@ xfs_buftarg_shrink_scan(
 		struct xfs_buf *bp;
 		bp = list_first_entry(&dispose, struct xfs_buf, b_lru);
 		list_del_init(&bp->b_lru);
+
+		/*
+		 * Account for the buffer memory freed here so memory reclaim
+		 * sees this and not just the xfs_buf slab entry being freed.
+		 */
+		if (current->reclaim_state)
+			current->reclaim_state->reclaimed_pages += bp->b_page_count;
+
 		xfs_buf_rele(bp);
 	}
 
@@ -2057,7 +2065,8 @@ int __init
 xfs_buf_init(void)
 {
 	xfs_buf_zone = kmem_zone_init_flags(sizeof(xfs_buf_t), "xfs_buf",
-						KM_ZONE_HWALIGN, NULL);
+			KM_ZONE_HWALIGN | KM_ZONE_SPREAD | KM_ZONE_RECLAIM,
+			NULL);
 	if (!xfs_buf_zone)
 		goto out;
 
-- 
2.22.0

