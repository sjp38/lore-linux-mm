Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 653B5C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 01:08:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 190BC2166E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 01:08:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 190BC2166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6C2C6B0003; Thu,  8 Aug 2019 21:08:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1CF26B0006; Thu,  8 Aug 2019 21:08:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E4476B0007; Thu,  8 Aug 2019 21:08:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 63AE26B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 21:08:44 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y9so56483127plp.12
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 18:08:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=MoAOmSO/ag8dc1h6fGhZHEEUcxTS+Lm1W2JgsC2KnqM=;
        b=fqJuDXmb+GYw/PsAB/oCP4HZfmb89HzYFgsuVFW9+3mS5/OCYcACVUuHDYXR1MTLFO
         JgtnGbMlNRAcyhaAsktUeW3yGpoMLxwS3vqEyTVoifSop8stGL4JwErAE1n1oZtt1fIc
         lxhC2D1Aljz1PWUaWJ4JG2YPP3gfR323R6qPi4ZfUHSWelY2VF/kBGo10tPZpov6Zdbb
         cSS6SpU/2hC9Q4hNrbnqN2Fi3D5cSUlyEdqGwcl1g2hgWPdxHDUP0x05j7zJiRWQF2mP
         wVcNSSu4zmX/VnUDFHL6L2mf9RtWYr5gNOuEofnzVb1BHigl8kTV6RUANMQNdb2qnle3
         0ueA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-Gm-Message-State: APjAAAW7NB5+noHSGds9b/n8sO+NOoICOWOqqdXcpsE2plo1a4gnmkQi
	wCdOZ6vHdCa6+CwI1hjD0F/7QnGRFv5uoTK17W7/kj7lROTzQxvXuaSZ4EW96RSHYkOF+SFmftx
	p0B9DpHTyYdIWRCW4DBu5BfJhrAsQd5EqEJ9OSTs42fihuet3S4ATvvfnikQdscMeoA==
X-Received: by 2002:a17:902:e287:: with SMTP id cf7mr16490746plb.32.1565312924037;
        Thu, 08 Aug 2019 18:08:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzYFcOqBcMFrnxZ01MvX2vLn1SS/R9QMq+nnHpYTVuEk2CM+4kzCyOWywyOwmzNTDoIjQy
X-Received: by 2002:a17:902:e287:: with SMTP id cf7mr16490663plb.32.1565312922763;
        Thu, 08 Aug 2019 18:08:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565312922; cv=none;
        d=google.com; s=arc-20160816;
        b=TEQDBJBWaNRC9sstxr4Fx8dDOJavs8S78UlROZjKTz6iqlXM69RUrr9FSuTDcA2cSh
         eK17F9PVzhDVtgiHLnrVrU0wP71PQB86sbyQgqJTkGxX3MWmw77dvbS6EQSG+Z6PU3Zu
         +8PiqFaPz5ZhQTvC2AjaJW0zehdnjhgA/+WEZ94hqUxuxA3n2TNPXtf7ki2T4jBvIQBN
         dXp4wXJu+Lh7v3jG2w1dZSlPuNfacVl2ucxE7AfYOE99gUNeEEBjkHHVPrpAFpDkaCL9
         i+D3GtxFf5c+7XYtaD2hQtCh37udwu4Uo6UD8Dacw4RnuYXFDi/+bGL0ejhQCUc6qGtY
         gUfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=MoAOmSO/ag8dc1h6fGhZHEEUcxTS+Lm1W2JgsC2KnqM=;
        b=YMMIN6HbyxNGgBoydvMp1XfpDhbsKlWOxOyagYOHNBLtOaV7/vyYIWFc6r+T/Vk1EJ
         SOo9NrrdCpvmRByHnkDeSjWvJrHtsm6YKJ7AM4VW8tbuJWugNN3zoFDr8viyTlMa9gzz
         vdp4by0Ou52orisWAzT5ka47vb0pPuVem5I7UfghZj15plRfepz/fdJXq4Fr78XPXZ6P
         trp32fHwfJdPmtKRlNmGPRwpoFpY609RcHmxodBfFJk23k2e44KzB5RZvzWQfwIWuzOu
         JUvbpVlxL1+JhIR3PpKqG6QPwamkq5ropyXuVEYdvkwP4XWy+gvNkFnmVrgBG8dcOTmL
         cuiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTP id s7si48600063plr.95.2019.08.08.18.08.42
        for <linux-mm@kvack.org>;
        Thu, 08 Aug 2019 18:08:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) client-ip=210.61.82.183;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-UUID: ce082dbf4911436bb8c5323e45215de2-20190809
X-UUID: ce082dbf4911436bb8c5323e45215de2-20190809
Received: from mtkcas07.mediatek.inc [(172.21.101.84)] by mailgw01.mediatek.com
	(envelope-from <miles.chen@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0707 with TLS)
	with ESMTP id 1689208884; Fri, 09 Aug 2019 09:08:37 +0800
Received: from mtkcas08.mediatek.inc (172.21.101.126) by
 mtkmbs06n1.mediatek.inc (172.21.101.129) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Fri, 9 Aug 2019 09:08:37 +0800
Received: from mtksdccf07.mediatek.inc (172.21.84.99) by mtkcas08.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Fri, 9 Aug 2019 09:08:37 +0800
From: <miles.chen@mediatek.com>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David
 Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew
 Morton <akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<linux-mediatek@lists.infradead.org>, <wsd_upstream@mediatek.com>, Miles Chen
	<miles.chen@mediatek.com>, "Tobin C . Harding" <me@tobin.cc>, Kees Cook
	<keescook@chromium.org>
Subject: [RFC PATCH v2] mm: slub: print kernel addresses in slub debug messages
Date: Fri, 9 Aug 2019 09:08:37 +0800
Message-ID: <20190809010837.24166-1-miles.chen@mediatek.com>
X-Mailer: git-send-email 2.18.0
MIME-Version: 1.0
Content-Type: text/plain
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Miles Chen <miles.chen@mediatek.com>

This RFC patch is sent to discuss the printing address with %p issue.

Since commit ad67b74d2469d9b8 ("printk: hash addresses printed with %p"),
%p gives obfuscated addresses now. When CONFIG_SLUB_DEBUG=y, it is still
useful to get real virtual addresses.

Possible approaches are:
1. stop printing kernel addresses
2. print with %pK,
3. print with %px.
4. do nothing

This patch takes %px approach and shows the output here.
(%px will causes checkpatch warnings, let us ignore the warning here to
have the discussion). Also, use DUMP_PREFIX_OFFSET instead of
DUMP_PREFIX_ADDRESS.

Before this patch:

INFO: Slab 0x(____ptrval____) objects=25 used=10 fp=0x(____ptrval____)
INFO: Object 0x(____ptrval____) @offset=1408 fp=0x(____ptrval____)
Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5
Redzone (____ptrval____): bb bb bb bb bb bb bb bb
Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
...
FIX kmalloc-128: Object at 0x(____ptrval____) not freed

After this patch:

INFO: Slab 0xffffffbf00f57000 objects=25 used=23 fp=0xffffffc03d5c3500
INFO: Object 0xffffffc03d5c3500 @offset=13568 fp=0xffffffc03d5c0800
Redzone 00000000: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
Redzone 00000010: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
Redzone 00000020: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
Redzone 00000030: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
Redzone 00000040: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
Redzone 00000050: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
Redzone 00000060: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
Redzone 00000070: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
Object 00000000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
Object 00000010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
Object 00000020: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
Object 00000030: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
Object 00000040: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
Object 00000050: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
Object 00000060: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
Object 00000070: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5
Redzone 00000000: bb bb bb bb bb bb bb bb
Padding 00000000: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
Padding 00000010: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
Padding 00000020: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
Padding 00000030: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
...
FIX kmalloc-128: Object at 0xffffffc03d5c3500 not freed

Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tobin C. Harding <me@tobin.cc>
Cc: Kees Cook <keescook@chromium.org>
Signed-off-by: Miles Chen <miles.chen@mediatek.com>
---
 mm/slub.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 8834563cdb4b..bc1fb8e81557 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -528,7 +528,7 @@ static void print_section(char *level, char *text, u8 *addr,
 			  unsigned int length)
 {
 	metadata_access_enable();
-	print_hex_dump(level, text, DUMP_PREFIX_ADDRESS, 16, 1, addr,
+	print_hex_dump(level, text, DUMP_PREFIX_OFFSET, 16, 1, addr,
 			length, 1);
 	metadata_access_disable();
 }
@@ -611,7 +611,7 @@ static void print_tracking(struct kmem_cache *s, void *object)
 
 static void print_page_info(struct page *page)
 {
-	pr_err("INFO: Slab 0x%p objects=%u used=%u fp=0x%p flags=0x%04lx\n",
+	pr_err("INFO: Slab 0x%px objects=%u used=%u fp=0x%px flags=0x%04lx\n",
 	       page, page->objects, page->inuse, page->freelist, page->flags);
 
 }
@@ -653,7 +653,7 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 
 	print_page_info(page);
 
-	pr_err("INFO: Object 0x%p @offset=%tu fp=0x%p\n\n",
+	pr_err("INFO: Object 0x%px @offset=%tu fp=0x%px\n\n",
 	       p, p - addr, get_freepointer(s, p));
 
 	if (s->flags & SLAB_RED_ZONE)
@@ -991,7 +991,7 @@ static void trace(struct kmem_cache *s, struct page *page, void *object,
 								int alloc)
 {
 	if (s->flags & SLAB_TRACE) {
-		pr_info("TRACE %s %s 0x%p inuse=%d fp=0x%p\n",
+		pr_info("TRACE %s %s 0x%px inuse=%d fp=0x%p\n",
 			s->name,
 			alloc ? "alloc" : "free",
 			object, page->inuse,
@@ -1212,7 +1212,7 @@ static noinline int free_debug_processing(
 	slab_unlock(page);
 	spin_unlock_irqrestore(&n->list_lock, flags);
 	if (!ret)
-		slab_fix(s, "Object at 0x%p not freed", object);
+		slab_fix(s, "Object at 0x%px not freed", object);
 	return ret;
 }
 
@@ -3693,7 +3693,7 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
 	for_each_object(p, s, addr, page->objects) {
 
 		if (!test_bit(slab_index(p, s, addr), map)) {
-			pr_err("INFO: Object 0x%p @offset=%tu\n", p, p - addr);
+			pr_err("INFO: Object 0x%px @offset=%tu\n", p, p - addr);
 			print_tracking(s, p);
 		}
 	}
-- 
2.18.0

