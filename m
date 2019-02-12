Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0185C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:49:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3A4B2083B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:49:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3A4B2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76A1F8E0003; Tue, 12 Feb 2019 09:49:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71C818E0001; Tue, 12 Feb 2019 09:49:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BCC98E0003; Tue, 12 Feb 2019 09:49:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2FBC78E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:49:06 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id c84so15977584qkb.13
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 06:49:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=7JQPLh5bOMKxM6/Qt39hzwevbRQdYhVhpxmktml6+V8=;
        b=AWyh60Sz++jnrMREydHyrN1b7jxofF2UFMXxk0nBth1vKUNdsj2UaozUokf5elPPIm
         RFqq3bKuZdZQgY/GRLy19HtLSx9IGLik8fnoB351DJx/wILDAY7gYt1w40NqIquQGqf3
         fs6olv2uIoa10Vy5+KefauNJYAb5KGWtMaiUykvWUbCgF5lOV+4v1sSEFtRMOfmNqByJ
         kDmFF3KcrmAs2l9cbx9YzKbtA/tt2laXY2+KXonB1PJYqECCJdqHgxPBsVtXzOI4EnDy
         Lnrlir0FiNRp/m0Mv0eNCSpyziRkfrEFWKegQa0WG/A6QJOSJpe94F45jn1SWqhJ90Bk
         n4Mg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZgPAdJoueXpJMRgRCWd5aXRLo5i3dd500wbZJWpbf1MooVDHLj
	aoLMRNP8vGWouvEIGOq/ke4v4OzSAFtrIzl0HSU13iTsINxMKDJnJAFdx/+fpR5f9W4rLjlYQN+
	TmUusN9K3LY29WYxw3w+b0fbzJOt4QRPhNq9aq3D8Nrys2Ig/XVMXdtxC/qwtI4Ip2w==
X-Received: by 2002:a0c:e704:: with SMTP id d4mr2483661qvn.241.1549982945996;
        Tue, 12 Feb 2019 06:49:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZCJoeNSn7aFzVyX/BP7lGl8kCP1UYF4qzqwQQ7LzeISZy/WZIL+v9YBuBric2Edaeo7MtA
X-Received: by 2002:a0c:e704:: with SMTP id d4mr2483630qvn.241.1549982945511;
        Tue, 12 Feb 2019 06:49:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549982945; cv=none;
        d=google.com; s=arc-20160816;
        b=f1oC6XZteEzRqqdj12LWCbZfmNavftSzNr05845fkzUj7P9Evqwf9JjRa+u8r6v40F
         NQE2bjThYclMwHTxeyeerAMvlWqpsnEdRPN/lBsFwXQAfQGJIRlKiuxe3Nf4R+aYPlGO
         sQ6mPUKbWg54KhochiuPsBMQOPXlgZ+uv2LRBQDA3RyMv0BKP/DFhfsq/+iLeB6fV5Fl
         8m/OaI+8uGDyC1tDKGeUyd8XUUpSmRaQNbN6EDQE+aKCICEjkt+3xKey3wwwJzldJS9z
         jjlq6cegdcqOvf9cYJfnKNsBR2QP3cWsP+HdW5uk6zqLW9HQC1UgsWXOh3y/hzXaVheg
         Kt/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=7JQPLh5bOMKxM6/Qt39hzwevbRQdYhVhpxmktml6+V8=;
        b=uJdEwAR/TpZMavFyhAKKMLUb3V8VKO0TB/1Bf9cBZWesVZe7oCsWuYPezgvpldDh/x
         wmuPoORvRQkvo6O3mv6eqeFaGcE1u7Zx68nVkB1R2TDMOy18lMQElY1TKqDlQz3Lbf7h
         clIlYuxcWUg1U1ZLYv3MfaiD1rAPhZQWxvSJEaMQayZur3v9do4iOP78EIO058rsjekz
         7z5lFYMEmwF538Ss4j13XttKtG1Spcs5xHkqyeCjzYx1KxRlJiEfuAyipm6QqoyfIlHE
         0nt4rkZWeJxIKPgG8G6PCcp72Kny1lO+hO/kAoH/JRWqyd15oIaCqPW9kWJYTVVkDGIX
         uOUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m6si5569496qtq.192.2019.02.12.06.49.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 06:49:05 -0800 (PST)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9A4BA89AC7;
	Tue, 12 Feb 2019 14:49:04 +0000 (UTC)
Received: from firesoul.localdomain (ovpn-200-20.brq.redhat.com [10.40.200.20])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3213810021B1;
	Tue, 12 Feb 2019 14:49:04 +0000 (UTC)
Received: from [10.1.2.1] (localhost [IPv6:::1])
	by firesoul.localdomain (Postfix) with ESMTP id 49CFC31256FC7;
	Tue, 12 Feb 2019 15:49:03 +0100 (CET)
Subject: [net-next PATCH V2 1/3] mm: add dma_addr_t to struct page
From: Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: Toke =?utf-8?q?H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>,
 Ilias Apalodimas <ilias.apalodimas@linaro.org>, willy@infradead.org,
 Saeed Mahameed <saeedm@mellanox.com>,
 Alexander Duyck <alexander.duyck@gmail.com>,
 Jesper Dangaard Brouer <brouer@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net,
 "David S. Miller" <davem@davemloft.net>, Tariq Toukan <tariqt@mellanox.com>
Date: Tue, 12 Feb 2019 15:49:03 +0100
Message-ID: <154998294324.8783.9045146111677125556.stgit@firesoul>
In-Reply-To: <154998290571.8783.11827147914798438839.stgit@firesoul>
References: <154998290571.8783.11827147914798438839.stgit@firesoul>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 12 Feb 2019 14:49:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The page_pool API is using page->private to store DMA addresses.
As pointed out by David Miller we can't use that on 32-bit architectures
with 64-bit DMA

This patch adds a new dma_addr_t struct to allow storing DMA addresses

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>
Acked-by: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/mm_types.h |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2c471a2c43fa..581737bd0878 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -95,6 +95,13 @@ struct page {
 			 */
 			unsigned long private;
 		};
+		struct {	/* page_pool used by netstack */
+			/**
+			 * @dma_addr: page_pool requires a 64-bit value even on
+			 * 32-bit architectures.
+			 */
+			dma_addr_t dma_addr;
+		};
 		struct {	/* slab, slob and slub */
 			union {
 				struct list_head slab_list;	/* uses lru */

