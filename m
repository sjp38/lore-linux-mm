Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E88BC10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C526222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="nC8wJYxr";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Cr27w0fX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C526222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 009848E000B; Fri, 15 Feb 2019 17:09:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED5008E0009; Fri, 15 Feb 2019 17:09:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9FE28E000B; Fri, 15 Feb 2019 17:09:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id A9D1D8E0009
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:15 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id a11so9324966qkk.10
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=uwePujYO5Bi6rSoxtQfAUMSLQwvWmv1VR4nTNRj43D8=;
        b=Zamj5IsG5sIPNhNvVl/E5aDjCSVhrKA6yHiCvnhzAJI1Bo99IePQBJZ/AF47gdbw+r
         eb/KdO35o8Xr8uL0ULAIq5vTt+TgcLfrOiVyU7jjtka5qS0tvWvAyDP8uxQNiIysqzfd
         4OdoX5lB6x8yd8iU3byPRMUbR/oKpVxpEbiErPEDZeNDVoifbyjxBjZ5Z0XOT3UjeNNh
         Zp89485ORBBbKReiPJ5FgthUcPlpBq/CzKR8gA1cxw4YcHB/VvCSw0b1y9Wecy6Ym6d0
         BSbasHsX+IdXUbM+Fv0OIXeO+rsYKrK1mEdMpo61L+8uPF12QjIrAFt0u1AU8E9JkSyf
         ORKw==
X-Gm-Message-State: AHQUAub2c4an14qJRvXL2UEIX+QwInl+1lqN7WpB5EemQ+GPf2Bi2jWD
	nDdkQ3a46BrW9k0hyH3fRByx27lCIkQ9IdBHLx87WmdYyqjdYJFfBuNu1SptLQFvJ6yoTqQUOPd
	rVzj0hz4XbynwBrRdO2NykTyqKBBxEsJms0j9c1I0pUvnPcplPnAWN7UqyAXw6SUQPQ==
X-Received: by 2002:a37:b581:: with SMTP id e123mr8526412qkf.183.1550268555455;
        Fri, 15 Feb 2019 14:09:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZfo1K0aIBAGnmqApEiUa4lE6cuWFIZsJZmMX99h4RUAiyccAgSxXxxEWUNpLSSCvdf/mck
X-Received: by 2002:a37:b581:: with SMTP id e123mr8526381qkf.183.1550268554813;
        Fri, 15 Feb 2019 14:09:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268554; cv=none;
        d=google.com; s=arc-20160816;
        b=MFC8fH5pxSs37BPQqurrJJNYyqWuToErxY8d4ueYk4G3bNPnVcVG3fHBgBorf7hym1
         D7mlJLse2P/+IgIfxxTQ/axxfqkmxFGpky58t77Q1EJqbJirFMEn3T2xu7yq9s1h2Hxj
         wmNLDB7MHEwjBL8RJfiiMzj3m3CmlDotaQ7cl4XYWAGB5rFnIZZo/8tmG6fYTmw00Ira
         FL/qfMb1NMPgPRRLgWyw7/PygUkyzwWDyoFW1Q6JuUvmFOMiMKEvcAS7OwjKebmtpIGC
         6fXmhhPVKTMnUZo2WShY3b+Xx/JEggvKIZ9hkorm3F4B8ZLsFz4NPvDXrjj5J5m17cQz
         5cyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=uwePujYO5Bi6rSoxtQfAUMSLQwvWmv1VR4nTNRj43D8=;
        b=k1cB0GDSKDU6pUJOu4C7/32XffWHWX++p/8bXvcMzaEeAZNU8jod0eR5Z85tNjXs9o
         1jpOxPeKor1Kotjbee+eOMdvSB8jDR79MCcCl2++4I+XlkSJ4lMJxcnpa0o9YUoDvGhI
         7sa6btznZ9WBZiZJXTKepsajdBC64h/ER2wBUtdcikJ1xgIRJ80qvxcbWAfOXuuK9PGg
         t/lxxpbipYHdsY/0mjBcZQrYM8FDXmlZgb3b9eJ45LiHKkXLj5K5AFKBTuMPbksvRK5X
         YGIYAasNoVosjTDbnisk6ZWPvnorISJMW7EO2Z/8KHwXVK6s+Tg+pQixACwCvuijJRnk
         UNEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=nC8wJYxr;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Cr27w0fX;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id f36si4192660qtk.149.2019.02.15.14.09.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:14 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=nC8wJYxr;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Cr27w0fX;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 0AF6631E4;
	Fri, 15 Feb 2019 17:09:12 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:13 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=uwePujYO5Bi6r
	SoxtQfAUMSLQwvWmv1VR4nTNRj43D8=; b=nC8wJYxrkic1or95bLI0GYWFtsGrQ
	9VYMM75Q7iaUOojaj3DxJATMc98abDC5rnSiIqSVbMboOPzaiQZGZFYIY0JNXbzt
	fn5Ccwqpq8a8eFx/cewftjMPzK1g0swu1KgrHqn++lE1FBn9oHzbFHnxcygnuHMT
	ajoGJCK8DhNIdAFN2g1nmnLyISw+3Zuj9IJYFakrkeqGu4tQ94WeBwmYx8DB6JKF
	HEh7V32pyFVtybjuC8R0yJv+1arzGA3MGHKbl1xMwRElzsFNtTdpM+koDKP5Xhbt
	FhFcB6p4c6JSoFGBC26ad0XVlVLCzxKE0dY3BB9RYftHlkX2mCwiI3v9w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=uwePujYO5Bi6rSoxtQfAUMSLQwvWmv1VR4nTNRj43D8=; b=Cr27w0fX
	JNjaiz9AQcalW7mj+chni9lvuDy2hlj5bN++V4Zz/pzLbTyJJ6+gWvhbeejSPrKF
	qE4LVQwDMHxWuFUz2dp0NM2ZWU/Jy6tEhkke3NGTgbIu9mKwYdPCc57qbMoS2J03
	jnzWObyX20UCFARwxhjxDbFY05pOZWmFOfcr0+Hix2Nb9URberL/7Zh0O5F4btjf
	dMZX9spArEGnOaEFtCd2yBEEg2VlhFro8OAdG+KhpwBpwO4YHMvOT1wBOB6Qgd3b
	l4qcgYuCq0BRbqXK+tO1EmKjR9IZgNXagRS7xSJQdSejFu2NXBuJh8y9fZ3vhD+s
	C+V/O/eL6Hv0Kg==
X-ME-Sender: <xms:iDhnXOpX2PCGy33ayjTK4o6RZGWXpf91RrdkoLdqQ7u7lfNYBZdQow>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpeeh
X-ME-Proxy: <xmx:iDhnXIcVA6Ahuam9gSqND0WuZ1FlhBdCMM85_rZQGVmgj9NKpynMJQ>
    <xmx:iDhnXOmtbJnJDecc_JsFaEXuupo5Uj0a_jYxA8ashy4MI679vy3Tbg>
    <xmx:iDhnXHaf_4p9p-UAF_AtEWgKWeYmXGBPFyHqHhVGt_lbo8Xwn_6Nfw>
    <xmx:iDhnXOKsMKwGLSAfgTNWDxsGYqN4HIJXX7ZJKPhquvKsmLg6Uvuqtg>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 27FBCE4511;
	Fri, 15 Feb 2019 17:09:11 -0500 (EST)
From: Zi Yan <zi.yan@sent.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 08/31] mm: add pagechain container for storing multiple pages.
Date: Fri, 15 Feb 2019 14:08:33 -0800
Message-Id: <20190215220856.29749-9-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215220856.29749-1-zi.yan@sent.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

When depositing page table pages for 1GB THPs, we need 512 PTE pages +
1 PMD page. Instead of counting and depositing 513 pages, we can use the
PMD page as a leader page and chain the rest 512 PTE pages with ->lru.
This, however, prevents us depositing PMD pages with ->lru, which is
currently used by depositing PTE pages for 2MB THPs. So add a new
pagechain container for PMD pages.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/linux/pagechain.h | 73 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 73 insertions(+)
 create mode 100644 include/linux/pagechain.h

diff --git a/include/linux/pagechain.h b/include/linux/pagechain.h
new file mode 100644
index 000000000000..be536142b413
--- /dev/null
+++ b/include/linux/pagechain.h
@@ -0,0 +1,73 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * include/linux/pagechain.h
+ *
+ * In many places it is efficient to batch an operation up against multiple
+ * pages. A pagechain is a multipage container which is used for that.
+ */
+
+#ifndef _LINUX_PAGECHAIN_H
+#define _LINUX_PAGECHAIN_H
+
+#include <linux/slab.h>
+
+/* 14 pointers + two long's align the pagechain structure to a power of two */
+#define PAGECHAIN_SIZE	13
+
+struct page;
+
+struct pagechain {
+	struct list_head list;
+	unsigned int nr;
+	struct page *pages[PAGECHAIN_SIZE];
+};
+
+static inline void pagechain_init(struct pagechain *pchain)
+{
+	pchain->nr = 0;
+	INIT_LIST_HEAD(&pchain->list);
+}
+
+static inline void pagechain_reinit(struct pagechain *pchain)
+{
+	pchain->nr = 0;
+}
+
+static inline unsigned int pagechain_count(struct pagechain *pchain)
+{
+	return pchain->nr;
+}
+
+static inline unsigned int pagechain_space(struct pagechain *pchain)
+{
+	return PAGECHAIN_SIZE - pchain->nr;
+}
+
+static inline bool pagechain_empty(struct pagechain *pchain)
+{
+	return pchain->nr == 0;
+}
+
+/*
+ * Add a page to a pagechain.  Returns the number of slots still available.
+ */
+static inline unsigned int pagechain_deposit(struct pagechain *pchain, struct page *page)
+{
+	VM_BUG_ON(!pagechain_space(pchain));
+	pchain->pages[pchain->nr++] = page;
+	return pagechain_space(pchain);
+}
+
+static inline struct page *pagechain_withdraw(struct pagechain *pchain)
+{
+	if (!pagechain_count(pchain))
+		return NULL;
+	return pchain->pages[--pchain->nr];
+}
+
+void __init pagechain_cache_init(void);
+struct pagechain *pagechain_alloc(void);
+void pagechain_free(struct pagechain *pchain);
+
+#endif /* _LINUX_PAGECHAIN_H */
+
-- 
2.20.1

