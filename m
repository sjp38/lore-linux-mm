Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA7A7C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65F3320855
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="5CgYTMir"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65F3320855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 146FD8E0008; Thu,  7 Mar 2019 23:15:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CC758E0002; Thu,  7 Mar 2019 23:15:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED74F8E0008; Thu,  7 Mar 2019 23:15:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id C2B6C8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 23:15:19 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id q193so14944802qke.12
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 20:15:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7aXu4Ayrrg1lqUVhlvuMknXlREOy+clc066/B0tC+rw=;
        b=CZbjFUH7k8c63KOm5ayjzTRLjbmJwwseDfqmVjXaWsS36knfX3zta61X+LtVpYDSaT
         oR1gN0OfLg+7r3AJ1zkyLPluyhgFE4DIwpEYevifry+PLF8RXg4R4g4lXYkvWQLzB0o/
         THkdmjE782XOwnn3vIESxdwK32LhmDBsa+lY6qgyGXoC/qz1fVpJprTXj2/RPIjfCk7/
         o4t/FVuRpEejIfZzoXqldfOGo3XABGMK3LhjEluu5cQHmh3+Uu1lKPkl0rRn/JMLgZ5F
         emgfgV6v+9UO+o92G1jitrLrpzjMMtt9rpEGhq12Bf3GDf0Jm84I9DAPFlTnNEzd4fXH
         hDLQ==
X-Gm-Message-State: APjAAAW3Rva1zRjR9dZxGbnTdUQIaFYj1u6rX1CBcdKOHh5toT74pmjP
	AWqEATSST0gni/7eadzuWBuZghZYfe5qeHMwwRfITUqPjcWPPtm3E/+EVL69clhngApeBLM8/HW
	EU1mQCIqoUC7x/Dh2jFPOc4+Dzhil4RiVluXv8QDTRnb+QL9vEWAQqmyraMzWNDM=
X-Received: by 2002:a37:bd81:: with SMTP id n123mr12668561qkf.249.1552018519548;
        Thu, 07 Mar 2019 20:15:19 -0800 (PST)
X-Google-Smtp-Source: APXvYqxe0x3bCh5gjBzTqcLt5UnDCC5ayqzgejHT0FVAmdxGAfuYQMdkyUSvsySyPta5h/lNJwxi
X-Received: by 2002:a37:bd81:: with SMTP id n123mr12668524qkf.249.1552018518549;
        Thu, 07 Mar 2019 20:15:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552018518; cv=none;
        d=google.com; s=arc-20160816;
        b=BVSJXSm2XLLg5aND9/KK3Vxvb8FmO+8uRuiwngZHqLjP6tZY1Y7jWYDu0S+WReGIaD
         eKAmUI/ypwzrGScva+mPlLQMZCZfCYSzR+0TSaBcaEbtEOOcboFS7MlYolsaFQJuBg5t
         o95QOGJj+4Rg5Ex/P1IjG+A9kXsT40qQ0mKNng7SeKDDoi+Z7W1VIqXSuSxVuuijznFq
         tpIXBr5seFINQcgDaEbJTZGbSMULB7I3vM2Vnh1GhI57RIN2Kq+VVOvKJNPq8Qz4tOpS
         tk9NNT6lw4wE89i4zdyBQkM3ivfznpl0Cb43iFX16tV5nyKpeexilryPbFPCzBxrD/d8
         fhag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=7aXu4Ayrrg1lqUVhlvuMknXlREOy+clc066/B0tC+rw=;
        b=juCaHLrFSjIubRteW7lAaslt1JTp9ygagsI9EYsROXmaclWylvRn7ZDXUiR5NmVnwP
         2kY7JxYhIqS/LLZM2y4VJwHl3dVLLVfva0w8adiPIQtKfnnGxUKkk/iPurtG0LOZL3cu
         EsBIDCvTb1yV7p/kXbuoRToDeioUnLmL/WJcaVZNNAhV7/8ZxXDMkH9ya+MyYACBGDMZ
         1fkyBRk4ok5JFSvjofgKj/IalAtmYsG2A9w7e13qVZoCw4uhDC9WbzYS2Tyapye+T7Iu
         17t6Mn8FUXpVCU9FpsepLijprsFCm1vQKv3yELDCqd4sa98pGn2FnBJxKwEOOkUsxPkE
         uC8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=5CgYTMir;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id q33si3942514qvc.139.2019.03.07.20.15.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 20:15:18 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=5CgYTMir;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 170A336A8;
	Thu,  7 Mar 2019 23:15:17 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 07 Mar 2019 23:15:17 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=7aXu4Ayrrg1lqUVhlvuMknXlREOy+clc066/B0tC+rw=; b=5CgYTMir
	sAHs6VuabE1G9iZrzN0Oi5mXbESfWpoQZyZRGmnw4vSL55ewvT5H4u8AeazvgsMc
	rBbvfmAZdeB25lubI+EM1xiVKSwZeeys5B8eRxi+inmikijvx6nHd/8Tnntb3twx
	7PwPKdTAvpLyCjJGRCGxKIbhsIuh4buEjLuDNfszP6jm+/FrPDmdT5Y2dHQ2QE2i
	KZ7ZmY7za7/dNYV/AxNH19RNfLr5ccEHuVTJNyl4WSYdA93J0yS9d5Lp+2/py9HX
	Jof8yQjdClrJMhbQKcrKin5JiEl59DbFAfiBu+fYq2gyP5artxGvyE9+f6rz6saK
	7xPc5fBThFgsRA==
X-ME-Sender: <xms:VOyBXH0qsqvhr-dhk1uH2Jjg7homNmmhHQMmAA6SD5o_MenLRRn_ag>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrfeelgdeifecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrhedrudehkeenucfrrghrrghmpehmrghilhhfrhhomhepthhosghi
    nheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepge
X-ME-Proxy: <xmx:VOyBXM21B0Ensgjz-kAXWpSp5DKmvWs_sAoMdqB3lTz6ixXV621TCg>
    <xmx:VOyBXJp2Ti_I1qryjFn1xVrKDvWxYSIWvIj3trNCPR-amIA54TlbsQ>
    <xmx:VOyBXIiwDAwY5IgwsfMPW89t7BwprkYHjHfyVYsTL-a-wKHfP4OENQ>
    <xmx:VOyBXDrk1gtI_4psQwRLwknP-oT_PIe5sM6m9IrmgiBYn6PwXxCDTg>
Received: from eros.localdomain (124-169-5-158.dyn.iinet.net.au [124.169.5.158])
	by mail.messagingengine.com (Postfix) with ESMTPA id BE59DE4548;
	Thu,  7 Mar 2019 23:15:13 -0500 (EST)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>,
	Tycho Andersen <tycho@tycho.ws>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC 05/15] slub: Sort slab cache list
Date: Fri,  8 Mar 2019 15:14:16 +1100
Message-Id: <20190308041426.16654-6-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190308041426.16654-1-tobin@kernel.org>
References: <20190308041426.16654-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It is advantageous to have all defragmentable slabs together at the
beginning of the list of slabs so that there is no need to scan the
complete list. Put defragmentable caches first when adding a slab cache
and others last.

Co-developed-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slab_common.c | 2 +-
 mm/slub.c        | 6 ++++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 754acdb292e4..1d492b59eee1 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -397,7 +397,7 @@ static struct kmem_cache *create_cache(const char *name,
 		goto out_free_cache;
 
 	s->refcount = 1;
-	list_add(&s->list, &slab_caches);
+	list_add_tail(&s->list, &slab_caches);
 	memcg_link_cache(s);
 out:
 	if (err)
diff --git a/mm/slub.c b/mm/slub.c
index 6ce866b420f1..f37103e22d3f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4427,6 +4427,8 @@ void kmem_cache_setup_mobility(struct kmem_cache *s,
 		return;
 	}
 
+	mutex_lock(&slab_mutex);
+
 	s->isolate = isolate;
 	s->migrate = migrate;
 
@@ -4435,6 +4437,10 @@ void kmem_cache_setup_mobility(struct kmem_cache *s,
 	 * to disable fast cmpxchg based processing.
 	 */
 	s->flags &= ~__CMPXCHG_DOUBLE;
+
+	list_move(&s->list, &slab_caches);	/* Move to top */
+
+	mutex_unlock(&slab_mutex);
 }
 EXPORT_SYMBOL(kmem_cache_setup_mobility);
 
-- 
2.21.0

