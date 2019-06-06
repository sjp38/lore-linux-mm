Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2485DC28D1D
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 12:04:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDBDE20868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 12:04:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HZ7EcqzL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDBDE20868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 303596B026F; Thu,  6 Jun 2019 08:04:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B6F16B0270; Thu,  6 Jun 2019 08:04:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1596D6B0271; Thu,  6 Jun 2019 08:04:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9389E6B0270
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 08:04:29 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id a2so473459ljd.19
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 05:04:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=MRxFMmBYeOcfOROJA3F+SVmsyybL0BND7saL3kxCMEU=;
        b=tmCyx3TT1zYjOJ+J+USs1ibfGqZAyB7DSZZKutn8Me3Vb9ty9jlih0cvQ+api4yMrz
         qOUeGFNOqKNorHNIZu2hrrFZxepq5BBkeZD+s+zt9Vv7WSItHq1aqYlfXeJ73D8WrbJu
         /QPwvqHAbh3Kgn+Tj8D7t5PciD1ZrfkmLceY6HcnIoEi7HnT1O1TWAsGo0HFM6lGGW9A
         lRoxfymJLjXH0HVUCyfaURIEkdzB45a0nrHDY64Mau0wFU8FZVaGQbLS0J6V8Tq1F84J
         88yKfvWLtiIYpUdDE2KcqSZund/qtfLFmgPwmAA4MUMQb1HsIFzyfflGnMCxysWy5v8g
         AAGw==
X-Gm-Message-State: APjAAAXGAbCSOrZy5yNToamwN80b8kxsllwGL+cHR984sN5v81JwtUJE
	EL75D8QdBiSSGeay19UiF5R7ggm6YLG2YrqZ4OPiuYjvTNyiNFdUwaVkNMcRLtTR14oVeNQiqAF
	s+CGydT15X54JtXR6RyMs3pypW5VINSmnOyZb9RJyXnZQbHdbeV60Xg3qhf/kuEMKog==
X-Received: by 2002:ac2:46f9:: with SMTP id q25mr25352127lfo.181.1559822669014;
        Thu, 06 Jun 2019 05:04:29 -0700 (PDT)
X-Received: by 2002:ac2:46f9:: with SMTP id q25mr25352050lfo.181.1559822667630;
        Thu, 06 Jun 2019 05:04:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559822667; cv=none;
        d=google.com; s=arc-20160816;
        b=XgFq4X0QJtduN/Ls1+ZSpISRTdZNU/tfmAxgU5hubfyTdCgajkXg1t7r5kW3om6eyw
         rvO6ICASKJ7dqPSONU2o5CZXzs7ATpp27/Hh/kCTv8o6C0Pup+xrqF+F0J/G1hLnV04w
         /3dgd+pEw9u10HQBlCJO+6Dsamia8PQtH0wo7KHFdj7qjVZ87b3b8FjVXKf5MQPto0pl
         C8cY0HgPFLB47vATILMa3DLfR44GY9p3klvLZvXYhf/fqHBzs8zbuYUTB7dcsuqGRmNW
         qsnsbB4AtlI41DpJXJm/D2veMfNgXulBkV5bnVChtbHZAdVxnP/zMJhsfFrMIJ6WO1fj
         Omdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=MRxFMmBYeOcfOROJA3F+SVmsyybL0BND7saL3kxCMEU=;
        b=hZALtTKpGImg4OH4/zpDuCuOo3+nqUou5CpUuwanm/pcNPJzBNb/+IOdJdBNzRw20O
         NM3KM9nYsTtVqGUq/xE/rNvzB9Hs/1H58IlAJtYhSL6U40PX8j7rFOB6yQM3dRwpF3AX
         pUbKAQTTa5RYBfwxhKZHhXsjFl3H3fE7lWjWYPBgU2HzACfHqCZ/9PwnwGFwsS7fBex9
         Ks8Hpi2g8AkYGx7R26jjo9f9hLKFHiF6nNpoL2wd/umo86ZLPTxPjebJ7iesSxZXaTPQ
         yv/KzQ1j5Dou+O5e7mBLxr67B7KuD3ZOJpxi8luDqBP9Tf4QRbUncRGsb/zNEReMKi7W
         8+oQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HZ7EcqzL;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b19sor480911lfj.71.2019.06.06.05.04.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 05:04:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HZ7EcqzL;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=MRxFMmBYeOcfOROJA3F+SVmsyybL0BND7saL3kxCMEU=;
        b=HZ7EcqzL4NXZJzoiyoS9j++T2BZmiWFS/5supBxv2WREp5utcc2p1e588OOZ5xSNFt
         lOdr/giv7KKtNLnKC0lm93kxocNgZ6XAP7DOLCF6mw1MZCuSBGNwv+lGqsWRRda4xk2B
         EvYkslYRyZ0dtuqmylqJRfav/pe9jVzRphHERGN+/D85P2QG4lQx6HVGNWKKMEIV4pG8
         wDe9lmHq0DBwRfRSlwnVXTWpasBqCshZ595Ti0/Z8Rz+v9ZfpzjqB5EQOvo0DdWAPayH
         YFh83gtmcnRu7LvFejwYzB+0YOPnwHJqq/zuLz/OZhSR/Z+s3+b8MURxt4oM+YIOcDqB
         l/Lw==
X-Google-Smtp-Source: APXvYqyz5hDWDD6CLYMB1TnL2eHwqeiB8HW9gZoViWH7Xm7CCUACGnDGlIz+Y+5hFioLnk2Y+Xroag==
X-Received: by 2002:ac2:41d7:: with SMTP id d23mr20251558lfi.118.1559822667190;
        Thu, 06 Jun 2019 05:04:27 -0700 (PDT)
Received: from pc636.lan (h5ef52e31.seluork.dyn.perspektivbredband.net. [94.245.46.49])
        by smtp.gmail.com with ESMTPSA id l18sm309036lja.94.2019.06.06.05.04.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 05:04:26 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Hillf Danton <hdanton@sina.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH v5 3/4] mm/vmalloc.c: get rid of one single unlink_va() when merge
Date: Thu,  6 Jun 2019 14:04:10 +0200
Message-Id: <20190606120411.8298-4-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190606120411.8298-1-urezki@gmail.com>
References: <20190606120411.8298-1-urezki@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It does not make sense to try to "unlink" the node that is definitely not
linked with a list nor tree.  On the first merge step VA just points to
the previously disconnected busy area.

On the second step, check if the node has been merged and do "unlink" if
so, because now it points to an object that must be linked.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
Acked-by: Hillf Danton <hdanton@sina.com>
Reviewed-by: Roman Gushchin <guro@fb.com>
---
 mm/vmalloc.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index fcda966589a6..a4bdf5fc3512 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -719,9 +719,6 @@ merge_or_add_vmap_area(struct vmap_area *va,
 			/* Check and update the tree if needed. */
 			augment_tree_propagate_from(sibling);
 
-			/* Remove this VA, it has been merged. */
-			unlink_va(va, root);
-
 			/* Free vmap_area object. */
 			kmem_cache_free(vmap_area_cachep, va);
 
@@ -746,12 +743,11 @@ merge_or_add_vmap_area(struct vmap_area *va,
 			/* Check and update the tree if needed. */
 			augment_tree_propagate_from(sibling);
 
-			/* Remove this VA, it has been merged. */
-			unlink_va(va, root);
+			if (merged)
+				unlink_va(va, root);
 
 			/* Free vmap_area object. */
 			kmem_cache_free(vmap_area_cachep, va);
-
 			return;
 		}
 	}
-- 
2.11.0

