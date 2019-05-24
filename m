Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE497C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 08:06:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6177E2133D
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 08:06:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="o0Dk7f3+";
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="kE4NYJ/h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6177E2133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC83A6B0005; Fri, 24 May 2019 04:06:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C78BA6B0008; Fri, 24 May 2019 04:06:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B40576B000A; Fri, 24 May 2019 04:06:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3616B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 04:06:38 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id z2so6306375pfb.12
        for <linux-mm@kvack.org>; Fri, 24 May 2019 01:06:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:dmarc-filter:from
         :to:cc:subject:date:message-id;
        bh=3IA1BAi9eimDGQCfJtfUGB7E4u11v01pte5YUVPS/hc=;
        b=fTFheTDXhhBR3OpXNEppcRBOA/hDLoJRoDDm9IsrFktmu7g7A/PIt1fWfu1EyT3Jov
         rN9vLpSR0QcmAuxip4VF7h+HOrV0+pJ335anW6ngEzMdGOC0PBUkO6SkofbxXN9MTpd4
         i6VprlAbDo6HFwhcCH94ghMcFFk63PR0LfKTuAD74RubycYTwiy2X6sxqMXbTfhy0KEX
         GmZ85eb+cgRm3ALjEGd9H35qsti+xS5hj1rsJHaRY+YhdIJ5Rw3VK+sRwYURv0wT5Jib
         LL3H5RtSikvWUtlHAFUVRN81/W9VkOHsSPrMDhdl7aUCHzl+zberjVqxVIMulVRbU/4H
         m8zg==
X-Gm-Message-State: APjAAAUsORpBZVA6Et6x3DqSd9TRcldhQHvXCx5zmNjcaRCiQrwyECwR
	oR22OEm2EtpSnfAxBI5bkVuGrNdFmPmGUUAtHOPmDJ+cF9O+P7Jg8pKUhiLNtYzTE2oPmEqvy00
	rRSjJPGMJCOuG/ZEJjFSh6CrVvPuBQ9PaCEe6L0rkGyaFK0LSrhtwsu4NYSUsxMjwjg==
X-Received: by 2002:a62:54c7:: with SMTP id i190mr87802834pfb.87.1558685197953;
        Fri, 24 May 2019 01:06:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytR5OYUDnNTQgemGJfwvp9pdGrXCdOSAcwCV+NznLapEmb0tFEc2JxEUD13aTV362BZvQw
X-Received: by 2002:a62:54c7:: with SMTP id i190mr87802756pfb.87.1558685196601;
        Fri, 24 May 2019 01:06:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558685196; cv=none;
        d=google.com; s=arc-20160816;
        b=x5n97H1w0g9X4LSXQVMxC7iKvn+R558q54L3bSICUNnKdIn8NR4nMPDcEcs89rZlc7
         D80Zyf5YZy8dFuwKU7RVpBLW+2Lc1RJtG0/d9ypdlCxe3HdzXibf7b/Tv3xXy8hft/a6
         0rbV/UFlmb1r2VsKYaN9TUnLbGLdbh9H/cv9aqXKN0AKcMvHpRXh+SFaqOFxmLyOjbVH
         gif9SpaSaZhPNFM+Ah0nxIxaSIYOs9TUEWMpFtyyAW/DeQahoQgK5uPRGZTFBSAF3XZF
         ouVGtgo9ztnlCbHSFn+lKLY/D9fbokXSaQZamgYIBIJj8Da6Ir50Xrqe40J09dM4UilP
         +wLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dmarc-filter:dkim-signature
         :dkim-signature;
        bh=3IA1BAi9eimDGQCfJtfUGB7E4u11v01pte5YUVPS/hc=;
        b=oxlydRaKkebOPqwDL+CTNRGZQr2ynx2Pgs93/riy1JSRlrR5W7/6H8ILjCXqwL4yIK
         hOzn/fxiYf3y7H1/GBtF2P2tEzrMisRHSsr99mxvSaxa63vsyrZ0gkpjrMcxYmqzmFFX
         QamB19lDoau/o8xCg0j/PXe2hwkIz8iX/uxOpNDKMFw3pI9gTK5wwbMnttQPUup7vE7t
         kEV9bvy6JwyYQZJiU0d8GAOLrp/ARqZnjz8ybBM7JfdqcDSCpbhI7JWNByZr/T4fts84
         Px3YdfCY5HKQhJggTTp5DH1fd6YuvRM8YR/x+CqL65wL95EX9KazGJBtT9buMvOyYfCV
         WfWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=o0Dk7f3+;
       dkim=pass header.i=@codeaurora.org header.s=default header.b="kE4NYJ/h";
       spf=pass (google.com: domain of stummala@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=stummala@codeaurora.org
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id q138si2695088pfq.149.2019.05.24.01.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 01:06:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of stummala@codeaurora.org designates 198.145.29.96 as permitted sender) client-ip=198.145.29.96;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=o0Dk7f3+;
       dkim=pass header.i=@codeaurora.org header.s=default header.b="kE4NYJ/h";
       spf=pass (google.com: domain of stummala@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=stummala@codeaurora.org
Received: by smtp.codeaurora.org (Postfix, from userid 1000)
	id 1464660E3E; Fri, 24 May 2019 08:06:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1558685196;
	bh=HFahEd1e9otwuYSiHy1qPYvBNA3cY2td10pq593gtdw=;
	h=From:To:Cc:Subject:Date:From;
	b=o0Dk7f3+hdz7aLAyaH+W2bwHvC2BB+Qo7wch7/PP9JDnDkcfeQL3QIBvBweFT/5Hw
	 XS8fzRC1wLadBfl4wxjqJ5IZEcUs6TlNd1ZqDXwBc6gawFGgTgvx6XRoSSGAyTR9fy
	 Sa6xsgNpqk6Jyk005JTE9Rkg7+Prbf5tR/gJmIIM=
Received: from codeaurora.org (blr-c-bdr-fw-01_globalnat_allzones-outside.qualcomm.com [103.229.19.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: stummala@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id 3FC7C60716;
	Fri, 24 May 2019 08:06:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1558685195;
	bh=HFahEd1e9otwuYSiHy1qPYvBNA3cY2td10pq593gtdw=;
	h=From:To:Cc:Subject:Date:From;
	b=kE4NYJ/hbdpoJMFmQboUNCozSkfLhIstHc2jckprU6iCfY++FGxUi0PuBJuCb2yGb
	 72EfNaAjfosSNFJm6llDdqSxPceH2w1ay4QaS73iKcXMWqbjCRmejXDuPzVug4udpX
	 gB9LczQo46sRD5H9Llx+DAkvtItJUD1AnpKIzayM=
DMARC-Filter: OpenDMARC Filter v1.3.2 smtp.codeaurora.org 3FC7C60716
Authentication-Results: pdx-caf-mail.web.codeaurora.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: pdx-caf-mail.web.codeaurora.org; spf=none smtp.mailfrom=stummala@codeaurora.org
From: Sahitya Tummala <stummala@codeaurora.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Yafang Shao <laoar.shao@gmail.com>,
	Roman Gushchin <guro@fb.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	linux-mm@kvack.org,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Eric Biggers <ebiggers@kernel.org>,
	linux-fscrypt@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	Sahitya Tummala <stummala@codeaurora.org>
Subject: [PATCH] mm/vmscan.c: drop all inode/dentry cache from LRU
Date: Fri, 24 May 2019 13:36:01 +0530
Message-Id: <1558685161-860-1-git-send-email-stummala@codeaurora.org>
X-Mailer: git-send-email 1.9.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is important for the scenario where FBE (file based encryption)
is enabled. With FBE, the encryption context needed to en/decrypt a file
will be stored in inode and any inode that is left in the cache after
drop_caches is done will be a problem. For ex, in Android, drop_caches
will be used when switching work profiles.

Signed-off-by: Sahitya Tummala <stummala@codeaurora.org>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d96c547..b48926f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -730,7 +730,7 @@ void drop_slab_node(int nid)
 		do {
 			freed += shrink_slab(GFP_KERNEL, nid, memcg, 0);
 		} while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
-	} while (freed > 10);
+	} while (freed != 0);
 }
 
 void drop_slab(void)
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project.

