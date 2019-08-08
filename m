Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5806C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 14:28:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7657621743
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 14:28:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7657621743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 004426B0003; Thu,  8 Aug 2019 10:28:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF66E6B0006; Thu,  8 Aug 2019 10:28:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE6676B0007; Thu,  8 Aug 2019 10:28:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A7B436B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 10:28:52 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n9so54336603pgq.4
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 07:28:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=kQBL0PYTul2vp4+gsnrLKbiCJ8tcxgOTtMZDvmAvlm4=;
        b=Bqsh9a8dJdnyNu+81mllnmQVDAFb+gmw3xfbC2EyBUs5uzH+vkEfdAmX96sZKmsQaV
         OVEZx2AhWNOpBS+2yj6y6cxko/oDazpICq9N+SeYz+g7hfjaCIi4MnXVCM3Ya0rJqeml
         NhnCmfV6UmIvI7AgCWn8KnuwPxSxvdnunvZSRQM/d1FkIj47ihgSc3EqYIW0/zqcSeen
         4WE1w6NJLQAlIHM26hYgegIe27jQuWFpblh/h9RWW7gSpbgHyjI9U9qyatJTMcM0ZEMO
         dekv+4Rh7LrElMeJUQ3Rgu6xWVitPHh68be08NSyV35j6hCztJD+u8SZaGgCatMhD25s
         ywlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-Gm-Message-State: APjAAAVM/dSPdZNgp8yGy1N4B4fVEiXkuRgl8iyQyt3Sa+V70Z5bzSrD
	qiftLNCOj0Q8XqPuVfv7NOVHfIRMGJgxGjyBUDpZLDodPt3h8eXpVkVdsUl7lz7R+bcJh5AdHmH
	1LvI+iaJSj7rQN63XZ/lY2NlvfffFN3BQdX2X2dVprDA66aEIStEoeQT93KQE7MLzSg==
X-Received: by 2002:a17:90a:b104:: with SMTP id z4mr4405585pjq.102.1565274532252;
        Thu, 08 Aug 2019 07:28:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy53QLOZas+oXahdi3kxAGUBZ33RjG0uyYK8G+502gROKmSMAMzxHhuguzlQDkfUdABgYJ2
X-Received: by 2002:a17:90a:b104:: with SMTP id z4mr4405476pjq.102.1565274530984;
        Thu, 08 Aug 2019 07:28:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565274530; cv=none;
        d=google.com; s=arc-20160816;
        b=fgyFMZzLJ+rJ4qRNBc/zPteTmcgp89Ws7rRF2RMxvr5e7XV34G3n3BLdTPd7BBWQ68
         MoAs1RIFRD1lu8E6NslCd0FiBLpme8N4rOH5vHKIt0OPpXVp6dc5gJjpqlVI7Q48+irK
         lsZVIx5MOqluQjMb2PT/zWZC+lnbtACbmD3YZPY3DD/PBQ/d7ZaWQBY3v3oqGNrj8sF5
         +fIEgy47Y/nQLECe/1+QXK/ERyxCq+R0Ir7XMM2gRC7UghP4ofMJorFQX7tm/WPAAKnO
         mmO9WhFdiCqf8+sdG88s4izGwGq3B9j2YHlxuEuhdFHh+pSEbpAJALtVd320QR+X58cy
         F12Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=kQBL0PYTul2vp4+gsnrLKbiCJ8tcxgOTtMZDvmAvlm4=;
        b=k+7VwY3qwlPOWMqAeHoNsbBf6Mswu60fTCy77mbJVlhXCpTad2jQxWu9iP1Fn8M2d6
         A57M6E6+lu1+mgpFKrNvIEFv6nvKeY+XGoVOaZeq1pHrY+jVpIxguw+JNXPUtGJfwkN2
         uVf5Zl2/VsDI5OBbzoLJa1YlHQwJWP7LqCNWzrPKh0RVU/lsp7Bs1mNU1AOt32cKbl/w
         MimDQvxkJDMPmtb9NahgGwN7ZQNhCRRxlA+lBZiFEt2V9LKlc49e4TD9hRIjJcRWoWrF
         xnipmz8AfjNQbQ3fS2Q3lHeNMv8xnpVzEnMdXVYiSoPyg2G2pdbGf65M6vVcKrF74MQo
         KYZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTP id a15si8546025pgw.313.2019.08.08.07.28.50
        for <linux-mm@kvack.org>;
        Thu, 08 Aug 2019 07:28:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) client-ip=210.61.82.183;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-UUID: ad55d4d908ed454083dd1205e0106285-20190808
X-UUID: ad55d4d908ed454083dd1205e0106285-20190808
Received: from mtkexhb01.mediatek.inc [(172.21.101.102)] by mailgw01.mediatek.com
	(envelope-from <miles.chen@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0707 with TLS)
	with ESMTP id 943411608; Thu, 08 Aug 2019 22:28:42 +0800
Received: from MTKCAS06.mediatek.inc (172.21.101.30) by
 mtkmbs07n1.mediatek.inc (172.21.101.16) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Thu, 8 Aug 2019 22:28:44 +0800
Received: from mtksdccf07.mediatek.inc (172.21.84.99) by MTKCAS06.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Thu, 8 Aug 2019 22:28:44 +0800
From: <miles.chen@mediatek.com>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David
 Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew
 Morton <akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<linux-mediatek@lists.infradead.org>, <wsd_upstream@mediatek.com>, Miles Chen
	<miles.chen@mediatek.com>
Subject: [RFC PATCH] mm: slub: print kernel addresses when CONFIG_SLUB_DEBUG=y
Date: Thu, 8 Aug 2019 22:28:43 +0800
Message-ID: <20190808142843.32151-1-miles.chen@mediatek.com>
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
2. print kernel addresses with %pK,
3. print kernel addresses with %px.
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

