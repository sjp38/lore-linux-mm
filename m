Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E88BC43219
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:43:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BAAA21707
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:43:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="kPo00+ES"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BAAA21707
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE9556B0006; Fri, 26 Apr 2019 21:43:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9B536B0008; Fri, 26 Apr 2019 21:43:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B895E6B000A; Fri, 26 Apr 2019 21:43:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 829E86B0006
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 21:43:00 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z12so3186322pgs.4
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 18:43:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oCwJhbmETQAR/GGaRy88QPhFO+EcGWV/zM62NDijTww=;
        b=puEA8fL5OJ5p7iA4k3d9PUw8Lo5fof521iMwMWQpHGINQpNTEzzhmOyLdwHagWV70a
         DQuWFhHvQdjtRDiEOY/IKzwf39giUsTA0ZTO08P3hORS2wXxjVIRtwssky0ramhnuOMH
         6tMIGcmcMwi3RkeCYAai7V1ExBmlttbC6Vaw7uDXiXR6/HLOEWCBZet3N14hunPGRvQr
         6S7KPhUwgIUbd1OElsr2KeaGgd1+7/OIQjuxWjxYNy0U205gtCN+sl9JPWoRTVI1JoyL
         rChea0sAb/Y/mJ3NyvhVLCpQvVHsMEldJ37zOaMns853pXoXEOzgOKoIEtLMYT43hgOG
         76Xw==
X-Gm-Message-State: APjAAAXJHS7x6l2dgEaEBSD+PF2Ha/ztSF8hqEkWTHVBfFaYbp6URV2i
	oI9YqXb7vNEK7apm7WdSK6g5x7/bkjp3CiNtDv/h8GQo7l1g362T8h3HpiGccMxua9JpFDz3Bxq
	9bxFrmrs1wLYChYUAfJgCXBKYklfKJym3SEu7wDoLJzoGUqeQBD+LmUIQl9hnDdDLDg==
X-Received: by 2002:a63:c10e:: with SMTP id w14mr27145924pgf.206.1556329380181;
        Fri, 26 Apr 2019 18:43:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAADpPGHtxvgOqEA8F3qmhA2I5NB2LtIt5yT4ryO8XQUyOs0lIwHnnUq0voNzXikoLFHGt
X-Received: by 2002:a63:c10e:: with SMTP id w14mr27145892pgf.206.1556329379582;
        Fri, 26 Apr 2019 18:42:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556329379; cv=none;
        d=google.com; s=arc-20160816;
        b=z0yWmkAo3J5UZcoV9oH3D/wKTamBK0VxTjb15isjen/EvQXNnRX/9fNsHVCGYxKs7U
         j4tBFxMK5/N1lTBv7Y3NLY3DmNPr5rPkr+LF6p7nOhFHHHsXDFVD5oZnWZZgni4cofJn
         yQGwgc33Sbu621RkGM4YHzMpI1dUceHJ7POyiJx6wMztwr98BJMUdJ0Hn7NBXdI11gAQ
         9ePjc4Nv8eBBpfh4ijODt/AI3CYlKJDwPAJkdU1vTklujKM5MXLZoivulaWpBsLdrmQy
         kTklHm0lutoYzHT91oz/Ks4F1UBJQNMVI5e1kyGNxoZx4W5+rBsEfOZA9FOGGqv7kO8X
         NJEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=oCwJhbmETQAR/GGaRy88QPhFO+EcGWV/zM62NDijTww=;
        b=NDL41+ih4g77rI1TjhrS+7vMLdXaIY8qnaSXbf/mz732XnJ5Eq2jbmP8qJ6h48uOD2
         b9aGmRlzAjYDl4Kb5+spJh6mmU5KIuWxkKYYfS3JLxsmr5tiq3Am9YDB2sO45ctfHpUD
         XERGBrmDjgwih1kbptz6pNT+VJiP7RWi9aRxLP1rgYabvdLmArLOQnk50Pv9tvKA2mmV
         AdFB05dhQlFtUMzeNfpSRF1qdPeaZn0/j7kqdCMIVDDx/osomj+Nu4pS1RxjBDEPQSkR
         zhJiT+PMBAkJME4TwNJD54yMWsQNs3sJmpzQn0YBdJOFN8rgPYo8JTlp0UBaiFb0nwqw
         uM0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=kPo00+ES;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o32si28972046pld.190.2019.04.26.18.42.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 18:42:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=kPo00+ES;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 588A82168B;
	Sat, 27 Apr 2019 01:42:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556329379;
	bh=MRApbEUyyKzYsNfmRuEvWcu8QaiBf4OcoNc9dNCwuco=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=kPo00+ESX7zn7u5cfBdUvKdbx+bGxOo9zt27xngR8kG6F8ZZ/IqkLVYFBlh0e8xg1
	 w9ij8g0+P7fKr48LhRquY9cTx9CPqRzgwFuMUB+q1KjxVd2XsdoZXdi2vYXVVWSSND
	 6d9byTk84c0iUe0OZ0gn0mm5/AKNPwxRzyaPQ1ss=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 18/32] slab: fix a crash by reading /proc/slab_allocators
Date: Fri, 26 Apr 2019 21:42:09 -0400
Message-Id: <20190427014224.8274-18-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190427014224.8274-1-sashal@kernel.org>
References: <20190427014224.8274-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit fcf88917dd435c6a4cb2830cb086ee58605a1d85 ]

The commit 510ded33e075 ("slab: implement slab_root_caches list")
changes the name of the list node within "struct kmem_cache" from "list"
to "root_caches_node", but leaks_show() still use the "list" which
causes a crash when reading /proc/slab_allocators.

You need to have CONFIG_SLAB=y and CONFIG_MEMCG=y to see the problem,
because without MEMCG all slab caches are root caches, and the "list"
node happens to be the right one.

Fixes: 510ded33e075 ("slab: implement slab_root_caches list")
Signed-off-by: Qian Cai <cai@lca.pw>
Reviewed-by: Tobin C. Harding <tobin@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index f4658468b23e..843ecea9e336 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4299,7 +4299,8 @@ static void show_symbol(struct seq_file *m, unsigned long address)
 
 static int leaks_show(struct seq_file *m, void *p)
 {
-	struct kmem_cache *cachep = list_entry(p, struct kmem_cache, list);
+	struct kmem_cache *cachep = list_entry(p, struct kmem_cache,
+					       root_caches_node);
 	struct page *page;
 	struct kmem_cache_node *n;
 	const char *name;
-- 
2.19.1

