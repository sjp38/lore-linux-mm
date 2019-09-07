Return-Path: <SRS0=dqyo=XC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36A28C0030C
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 21:41:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED95A21835
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 21:41:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kwSx+U26"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED95A21835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89C146B0007; Sat,  7 Sep 2019 17:41:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 825A96B0008; Sat,  7 Sep 2019 17:41:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6ED1C6B000A; Sat,  7 Sep 2019 17:41:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0075.hostedemail.com [216.40.44.75])
	by kanga.kvack.org (Postfix) with ESMTP id 4B37E6B0007
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 17:41:33 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id F34F7180AD801
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 21:41:32 +0000 (UTC)
X-FDA: 75909446424.21.angle29_47b07d5788828
X-HE-Tag: angle29_47b07d5788828
X-Filterd-Recvd-Size: 4042
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com [209.85.215.193])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 21:41:32 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id d10so5494092pgo.5
        for <linux-mm@kvack.org>; Sat, 07 Sep 2019 14:41:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :in-reply-to:references;
        bh=rar7+a8LD0KANAp/lVeGtNr0VZS4OVkIBwxcWjVF7fo=;
        b=kwSx+U26sg/1ZFJEwjbGN++gHnIHb25rHZQsX7kQge9MWN2Wn/8QiDbNh5Yx/3ecs0
         1zEkIP8zO8k8w4wnReHUF009lMiHIidZHKDpcJx6DabjzX3j+xIFQpAF6Am1pHQScsyx
         A2iliUkyQT0+XOOHJdQ2Uf7WvinVvPa0XTTlUL5NwE0EoE/Jd8nqZndeJn1xBgJf8JLy
         GesKao2qJon0PnciwA1FJofqTgS8vpb+86V6Mn/Z0cGUv1AGRaKYz5CmQ9OEkLlr+e/Y
         1jaz9g9YSTdBJ83S6AWzyyrD7cza1zehSuSFX1wB42VOeTMc9t9QlzckCkzKCaKVKELm
         3I6A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:in-reply-to:references;
        bh=rar7+a8LD0KANAp/lVeGtNr0VZS4OVkIBwxcWjVF7fo=;
        b=qMq0Ak+u9d4zCSikxrmBZnh596UmZde2h7lKbc06ZZqmtqv72lwE3913f62LI0RpRU
         xmmTUM0VbFlMJ30En52O1CiZ8HdsXnqj3p/QYLNA4AFZHCMNM2omSoJ4pRWGTwu7SKP4
         ii6vOqKqaBoHbJXykyr+HLL1Hg0o90iO139CgdpqfTs1anAuev1UrQ0yT7QRdnENCvTk
         A0tt0V/A96WDWaTBbyiKWvku6+k3yOMPea7fnu/7d7wmAGQTarvciZ1uK9H/gSCCNbXA
         Co1QSQj19li+fHlJUVSUhXeXj0QB++cOGR/Q0lIGfDEtN/kia1cGC1KHgfiDN6yTABxI
         W0qg==
X-Gm-Message-State: APjAAAWUzIWJT6FNaMvTVxuhX/cxKh8T6yKwrp2idb0opkR0V0Qkz9JI
	F8u74iPxEKLKnRTAeYVFnOc=
X-Google-Smtp-Source: APXvYqwoZAkoLr5to9U2rXC0sBG3iafTZgw6qEDbSJDElFdfik0viB+6vT7qjTj7VVZh0WLTfkqGzA==
X-Received: by 2002:a62:1658:: with SMTP id 85mr19104372pfw.195.1567892491692;
        Sat, 07 Sep 2019 14:41:31 -0700 (PDT)
Received: from localhost.localdomain ([112.79.80.177])
        by smtp.gmail.com with ESMTPSA id h11sm9078516pgv.5.2019.09.07.14.41.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 07 Sep 2019 14:41:30 -0700 (PDT)
From: Souptick Joarder <jrdr.linux@gmail.com>
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com,
	sashal@kernel.org,
	boris.ostrovsky@oracle.com,
	jgross@suse.com,
	sstabellini@kernel.org,
	akpm@linux-foundation.org,
	david@redhat.com,
	osalvador@suse.com,
	mhocko@suse.com,
	pasha.tatashin@soleen.com,
	dan.j.williams@intel.com,
	richard.weiyang@gmail.com,
	cai@lca.pw
Cc: linux-hyperv@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH 2/3] xen/ballon: Avoid calling dummy function __online_page_set_limits()
Date: Sun,  8 Sep 2019 03:17:03 +0530
Message-Id: <854db2cf8145d9635249c95584d9a91fd774a229.1567889743.git.jrdr.linux@gmail.com>
X-Mailer: git-send-email 1.9.1
In-Reply-To: <cover.1567889743.git.jrdr.linux@gmail.com>
References: <cover.1567889743.git.jrdr.linux@gmail.com>
In-Reply-To: <cover.1567889743.git.jrdr.linux@gmail.com>
References: <cover.1567889743.git.jrdr.linux@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

__online_page_set_limits() is a dummy function and an extra call
to this function can be avoided.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 drivers/xen/balloon.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 4e11de6..05b1f7e 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -376,7 +376,6 @@ static void xen_online_page(struct page *page, unsigned int order)
 	mutex_lock(&balloon_mutex);
 	for (i = 0; i < size; i++) {
 		p = pfn_to_page(start_pfn + i);
-		__online_page_set_limits(p);
 		__SetPageOffline(p);
 		__balloon_append(p);
 	}
-- 
1.9.1


