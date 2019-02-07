Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58FC8C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 05:38:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 237EE218D3
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 05:38:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 237EE218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD2F48E001B; Thu,  7 Feb 2019 00:38:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B59728E0002; Thu,  7 Feb 2019 00:38:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A48998E001B; Thu,  7 Feb 2019 00:38:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7B38E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 00:38:37 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c34so3758571edb.8
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 21:38:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=XTzdyLtai2BUGlbOWdmDrFpkGiuimymKU9xYTKalbrg=;
        b=QQpdQpgd8TN6MCL2yUTmE2ikX7Sn/YMf+/8zRt1AN0XFwkBnRNex2iPanm4mCsLbql
         NNKju0etBnadztfxB+KvVFJrHwcEERReeR7rG7qMqP9zciSx62h/P59YX57oRT7ycAtc
         M/162jdZ6CfU0Yv56flBxa/hiOqpJWRHAi1dfVekMCVQQo1UIjQImh/flcemibgR6R9Z
         WQTkukc+qsXMB55HUqc1+2ngwbhfjbzehwtRth49ORLs5Iij7OImgodPEdlPflgaApMs
         udzMjMWZ8t82h25M3YC6pCvc4lsrD1u4pMPrYgioM0Ge+AqIlyetWWUhD9k4il/CUeJi
         /XNQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: AHQUAuYRc19KSTkwr3y+QF6amKRGsZL0R0VSHXRFoX2hgUZRZgvWsS2r
	Z2LdktvNhwELjI/MejyA3yUrLK0keIZuIntJZUxhFv8rezbxkfncXVy5ME0Z5y+WLULgjOLiK2I
	FGzcvB6fjNWRwJl/BFdnSh+VKYjoJX6l1GP/BmX5dkMwHDwdpS+vTxd19tziImT0=
X-Received: by 2002:a17:906:28c9:: with SMTP id p9mr6411483ejd.77.1549517916884;
        Wed, 06 Feb 2019 21:38:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaJsuAkNTkt2L6wESQ0hJ32pVWwfoS1bzWGMcFSjaqKYjvlfB7u8yI2H05CqEBsVD/k4CMW
X-Received: by 2002:a17:906:28c9:: with SMTP id p9mr6411434ejd.77.1549517915978;
        Wed, 06 Feb 2019 21:38:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549517915; cv=none;
        d=google.com; s=arc-20160816;
        b=o9/+r8/sh7FHIlgrdtzBcHjsIInD1vJUf5Ozorw9qP4B9cEpCxDVPhFEjyVqKKZAS3
         870z8Y2BPynuS1iENFGsEnSV4Amj7MydbfhoZ2eGbov4NfephTs8a3iYqpgfD6Ufyj4v
         hPv2VJNa0tY1I01uUBGHhIvXrqdTRQ+WAaiO7gatuvbkWfC6IGg7v5sPNoefVPi61Hh3
         Htg/xm/3+9krOO9LrF8TBCXFEUWTyI59VaoCnrpOhGk/YKo7ltp77N4WbpiFHUUAZJn1
         QYxVjLAQzUw8wAvKSZd9yfuNBmhpdeX8GmD+NIi+41oie3FzziWhWnO9WwleInczTda3
         XxNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=XTzdyLtai2BUGlbOWdmDrFpkGiuimymKU9xYTKalbrg=;
        b=gETUWbLd4MoQmcF8IW1FAJw+n7bwu94AfRHzXnFbsiXD5j2JiCmyswEdKxIZkX/h+d
         SJCkS02R86vB46tN6k02Ns2txa3+rC49kcABAvOvdEQFAHJzoppP7ECyQgoBqfBnhk0R
         HtviyS4wGJz5zcO2KebzYsBGTVfURfVfb0ogdM0V23kbCN10sF8LMeoiqhYhhB+iAQTN
         Rf3lcvfuSxDMJMC31LIZ+p/WdifgWwb6/xzlO6yfw5OdVpDRxlutUVL1T91+yGvF2uN4
         YBneV9lCkM/FKM0mGc/gFNkkJa625HPUwa+cBO7iAq7Lqax+xWLAC43ZB1ynuMPuJMxQ
         XLow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id g13si6595976edk.370.2019.02.06.21.38.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 21:38:35 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Thu, 07 Feb 2019 06:38:35 +0100
Received: from localhost.localdomain (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Thu, 07 Feb 2019 05:38:02 +0000
From: Davidlohr Bueso <dave@stgolabs.net>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	dave@stgolabs.net,
	linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Bjorn Topel <bjorn.topel@intel.com>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	netdev@vger.kernel.org,
	Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 1/2] xsk: do not use mmap_sem
Date: Wed,  6 Feb 2019 21:37:39 -0800
Message-Id: <20190207053740.26915-2-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190207053740.26915-1-dave@stgolabs.net>
References: <20190207053740.26915-1-dave@stgolabs.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Holding mmap_sem exclusively for a gup() is an overkill.
Lets replace the call for gup_fast() and let the mm take
it if necessary.

Cc: David S. Miller <davem@davemloft.net>
Cc: Bjorn Topel <bjorn.topel@intel.com>
Cc: Magnus Karlsson <magnus.karlsson@intel.com>
CC: netdev@vger.kernel.org
Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 net/xdp/xdp_umem.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
index 5ab236c5c9a5..25e1e76654a8 100644
--- a/net/xdp/xdp_umem.c
+++ b/net/xdp/xdp_umem.c
@@ -265,10 +265,8 @@ static int xdp_umem_pin_pages(struct xdp_umem *umem)
 	if (!umem->pgs)
 		return -ENOMEM;
 
-	down_write(&current->mm->mmap_sem);
-	npgs = get_user_pages(umem->address, umem->npgs,
-			      gup_flags, &umem->pgs[0], NULL);
-	up_write(&current->mm->mmap_sem);
+	npgs = get_user_pages_fast(umem->address, umem->npgs,
+				   gup_flags, &umem->pgs[0]);
 
 	if (npgs != umem->npgs) {
 		if (npgs >= 0) {
-- 
2.16.4

