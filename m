Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC515C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:06:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93570207E0
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:06:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="jFUgvtAn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93570207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44E586B0278; Tue,  2 Apr 2019 19:06:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FD5B6B0279; Tue,  2 Apr 2019 19:06:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C63A6B027A; Tue,  2 Apr 2019 19:06:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4916B0278
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 19:06:56 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id d8so12970705qkk.17
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 16:06:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BFIyNbFQfvFKfyZUHijpqSaVm8ggK3M3/XYK2FaoXEA=;
        b=LMtndD71l3MLIyIUv8lr9quui+3LwW1Jh3DjSjLZGfrE74C6g85SbsMUuJYNBPgVsw
         J8nqc1TzEJS5mbX/wtjXr0hgzloLD8XebU0fiw2rHuotXjSRU81hSt1DNJXF8nCMI1im
         rDK7LhSAGb95Eo3wSEv9+uA+nDUpk1Oz6bb6/1LrGVN/uSOARTlaE4FJIH7SMPHQc90K
         r0m281FfbxEz7zNEouUMRYT1BcjAIdEGipc5abGNEDA3QOSL0gqy8hv8XrdhsBlNYvxD
         C6lQftHaHLUdduBcA996j/HkBXp09C850rWkqCWubSpLSHy2bZhbmkWtox/wnVA753LW
         BlDg==
X-Gm-Message-State: APjAAAVPlcgBYr5OLRaR6fUK5lSGplXb2HcYHpBNBzmRZCrPJRxI9D8E
	bS2Ul+0rYWbCFRrwe1oZUv84uWd9ZjYDUAPRR0BRr+U9lj//hymXTXodTaiCnNBj2hapXC6RW2p
	9GSGE6NUPQWbdYY/d5SLt80dWFZUs/7Em38JFFDr/6VV0YSp1+eB8QlTxGRftQsk=
X-Received: by 2002:a37:4b03:: with SMTP id y3mr16868856qka.260.1554246415845;
        Tue, 02 Apr 2019 16:06:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwoxM6lVwjwIlLFrrnY+3L46DXHUtWw+k6ioBDFNy3fxhj/ExUkWqR0+WC+Ve41b7cC8Hir
X-Received: by 2002:a37:4b03:: with SMTP id y3mr16868807qka.260.1554246415123;
        Tue, 02 Apr 2019 16:06:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554246415; cv=none;
        d=google.com; s=arc-20160816;
        b=LrqzsB2l7DrJ13mQDt56Khzk+pdiTNe7N2DSP5Jm6V/DIs7QQM59/ZlhLXbDATpMnv
         MpFGyHVWzd+6uEPQl7/VSq26+iE9rIZQ6Aw7NE/ZruRrCMnGtpACDPyt9IryXqjPozYw
         p7rG6e11u2QoU66ue+yFt0/VMAFQ2FsJU9f3sRghEUG78sZBiEpQ8lcAZWu/v+izeV3c
         JT5qo2ryYtjh2dm9qU7jy4p0p8kXKty7jgzE/Myx52F0M11O4GXW45MtwaDPVUi2RrUH
         mTpeZl7I1h8EtgH1zMLTVyyAokCdUeH1HebxyfK2cTM/8fiFVOXMq29jLvI5lIopnVn1
         oY0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=BFIyNbFQfvFKfyZUHijpqSaVm8ggK3M3/XYK2FaoXEA=;
        b=0qLbLUB5j5kMri26Q26+LOb5w557iDFpgq4B2V5yDUDsHLV7Z8gHfD3TJunSHBuG+M
         jYnwP1NnAamxTybxbKmSxQjq689V9i5b9w1z8d8xwYXOiYyW3mC568PcVxBlJydJAPBU
         da44VK/DBsThxjDg42aHolzPhHPXqvALyhC9NffEPAenRZXD0w6RbeIHiEQx3fICEvYH
         tLrWcAVvZGuTy0oiky+rw5udaUbwd5wST5VVnDkbt0Q4n/Mz+xUH6+gtTkjArwehVGj+
         SN4S8HjuuReUQjCXqIMqPphNlA6WhjjkaAOgk6ZPY0EQu1G05fsr9kU5SYI0ARBwh2we
         +dzg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=jFUgvtAn;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id x18si5344430qtp.368.2019.04.02.16.06.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 16:06:55 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=jFUgvtAn;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id D7A872201F;
	Tue,  2 Apr 2019 19:06:54 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Tue, 02 Apr 2019 19:06:54 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=BFIyNbFQfvFKfyZUHijpqSaVm8ggK3M3/XYK2FaoXEA=; b=jFUgvtAn
	ZD44OM9rhEKh8z7rEJ3IOjLZxODs7BrvCHA6A9nZFfJ4LTx2tMN6jsJa3K5fGXV7
	JG0CEUTQLUc0zkavWdhwXnLP2jBJXznd0sZrSJ9DzJCwWfyTaIhawW8j+Fc/aOwL
	dnDekI7NVWb5zJVIM1HuXvsEG3cbBqh4/ikkVFEfWvpcQnmEQhh/lLUuvuhRvm9x
	DRsgG+bDTSQrq0SHLppcw/lsiLLFQ6qjJwI10FN7dae58qTzwu85vyXr7XVlEEuY
	dBeaZvSJtT442FqLK+Rbux04dPrtWeASpm1s+EYiWl7yp6UzRvfPs6tEUwFELSh1
	JxHWOwHuipcqZQ==
X-ME-Sender: <xms:DuujXArJUzFxjNjOvNz_u472fh9cModyLkC1Jz8aGyahX_KPyAA5CQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdduieculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhgggfestdekredtredttden
    ucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrh
    hnvghlrdhorhhgqeenucfkphepuddvgedrudeiledrvdejrddvtdeknecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghruf
    hiiigvpeei
X-ME-Proxy: <xmx:DuujXK6KqOmMJlt6YmKqst823_3vQlEGdq_4mUmMMSSN3Wf6RZnf7g>
    <xmx:DuujXANNbmc5OO97zUnWbroGMKOSnkZngMp1aCcCXn_1PHhCp56tjA>
    <xmx:DuujXMOF6sr2fm4UddbdBKIwzISOdf4kwVz9RpRUYmYva3pDPAVTcw>
    <xmx:DuujXMXoiFV_nHUVTKcwhFlQ9YLoxn15hvtcAEmgLc75bCMdhG7viQ>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id E3F3010390;
	Tue,  2 Apr 2019 19:06:50 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v5 7/7] mm: Remove stale comment from page struct
Date: Wed,  3 Apr 2019 10:05:45 +1100
Message-Id: <20190402230545.2929-8-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190402230545.2929-1-tobin@kernel.org>
References: <20190402230545.2929-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We now use the slab_list list_head instead of the lru list_head.  This
comment has become stale.

Remove stale comment from page struct slab_list list_head.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 include/linux/mm_types.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 7eade9132f02..63a34e3d7c29 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -103,7 +103,7 @@ struct page {
 		};
 		struct {	/* slab, slob and slub */
 			union {
-				struct list_head slab_list;	/* uses lru */
+				struct list_head slab_list;
 				struct {	/* Partial pages */
 					struct page *next;
 #ifdef CONFIG_64BIT
-- 
2.21.0

