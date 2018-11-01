Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id D54B86B026D
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 06:09:25 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id j131so234565lfg.14
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 03:09:25 -0700 (PDT)
Received: from forwardcorp1o.cmail.yandex.net (forwardcorp1o.cmail.yandex.net. [37.9.109.47])
        by mx.google.com with ESMTPS id w72si17488088lfd.64.2018.11.01.03.09.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 03:09:23 -0700 (PDT)
Subject: [PATCH 2] mm/kvmalloc: do not call kmalloc for size >
 KMALLOC_MAX_SIZE
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Thu, 01 Nov 2018 13:09:16 +0300
Message-ID: <154106695670.898059.5301435081426064314.stgit@buzz>
In-Reply-To: <154106356066.887821.4649178319705436373.stgit@buzz>
References: <154106356066.887821.4649178319705436373.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org

Allocations over KMALLOC_MAX_SIZE could be served only by vmalloc.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/util.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/util.c b/mm/util.c
index 8bf08b5b5760..f5f04fa22814 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -392,6 +392,9 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
 	gfp_t kmalloc_flags = flags;
 	void *ret;
 
+	if (size > KMALLOC_MAX_SIZE)
+		goto fallback;
+
 	/*
 	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tables)
 	 * so the given set of flags has to be compatible.
@@ -422,6 +425,7 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
 	if (ret || size <= PAGE_SIZE)
 		return ret;
 
+fallback:
 	return __vmalloc_node_flags_caller(size, node, flags,
 			__builtin_return_address(0));
 }
