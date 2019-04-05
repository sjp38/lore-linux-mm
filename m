Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2FC2C10F0F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 13:51:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F55121738
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 13:51:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F55121738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 77D766B026D; Fri,  5 Apr 2019 09:51:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7271E6B026E; Fri,  5 Apr 2019 09:51:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 646126B0270; Fri,  5 Apr 2019 09:51:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 132E36B026E
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 09:51:24 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w3so3302918edt.2
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 06:51:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=05XxbmfCAjHMhi/VtlSMkPiApWuac6A+r9QYYikljpc=;
        b=l0YCdaJ1sIOXyTHSASbCuIi+yseTVmj2tWgovWNGVWxubrVsBXF+49FeLom/BRGMG7
         WnwNG9K+AB/nk8VaF0HhymEyRZ6fcAFX9EuEq1zwli+nyBrQzqSARFwY+4Ewb5q0r8EZ
         wfLxguIgTj2xvFrEXf+5JeNYMP7sZq2KWAFqHUWrZ5mhR1jjDVSekdydm/0B9tJFC3pZ
         SfWWLvX3ABMuhPOsSDo8R9ecKuOQMaBeCAeTOxSKr/bbGPksKSihJnMU0sb3dGhndzKu
         gb5kauvQqgfyvlAUIgb9jlgx31XcdVZ1cWMSNj6KULvu4hN4vrIeaQOOGWOC5jnppOaZ
         0ioQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAW6VXkDHbmxcI6GY4tYnAcED+U9qw8sG3lHN8x0XZXsaBXtW3GS
	wr2l7jg6dzucd+CrjCjBPWSDEwI0XMuBolpYwVR18+aQPOFekZTU3FBaWtWrfAIVvtOmoua5j//
	D9EOXBgwiXpKxSzOMYFdTUN+ttrf/J7ur0QyL5paPjcUg2XAR5e+ktiiLuayiIQhA8w==
X-Received: by 2002:a17:906:4453:: with SMTP id i19mr7563876ejp.39.1554472283551;
        Fri, 05 Apr 2019 06:51:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWErtYNv/ks6sxsjxuoVvBogJ1JNPEoZ0xa4d3+php/EZuRVWicG76pCsgUSVlds7sdcqk
X-Received: by 2002:a17:906:4453:: with SMTP id i19mr7563800ejp.39.1554472282003;
        Fri, 05 Apr 2019 06:51:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554472282; cv=none;
        d=google.com; s=arc-20160816;
        b=f/olmr0vwAmceH0odu1O4hXHok1pWoIh5fNQ5/biGybeaXBB4MtQZC+7Zb0iuOxgWk
         zRCIcTmSrGifzjyjUBIbeyfgmymjhqVNLAkMiLMntm+30NX4NSYorXN3pXoEg5VGW6z3
         Tit7IUF/xCFp64aCiacDXkqxlVsN89fB9CwlRx3pEmZJQUsJA3LS4bLvD68t+V9FEWsO
         e9z6EqSHw7tj47PrLdxBa8/E/WCoDMEpnDC/lYfwBZ7JGXWvRDngsIfiqMjj1s2GOqbh
         QdZQHkcd0JJpXYF8M/Hx8n0UTkCQ4FkIpdVauCHXcMkyZguFarKwD0b0MlFGOH9t1m3b
         4UYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=05XxbmfCAjHMhi/VtlSMkPiApWuac6A+r9QYYikljpc=;
        b=KqqM1PYSW/ylKEa/qB72IWwSzO+CPXSY2zNNarZq6oE8N8423vP+fvoFoY5FqHP+Uo
         i1s49fkEHUP5NVpbBTz8nV0FOU7OYAEzal6XfYPZOssFUkBfEDeFN+h8sh0cha4vVlAT
         RrUu1U7E8DBf4pxLCPlCvFK6UZjki4SVdexx0FPvYDB//DqYm7GckpuZir8fPe63I4CT
         JELhdVCFss1ei93V1Ns2KbODYey5+woxyjY8TTcsYlTB6fLRRIVCxVLiWNVYguDk2yLb
         bLwuIyD1mH/RHtR9SmOGVt38yM2B9pgk3l0dRXXi7r4Wlu3beDipidYUxQHJBOz7CimO
         AyMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id ce3si2496598ejb.400.2019.04.05.06.51.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 06:51:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) client-ip=81.17.249.8;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 7E7D098D8C
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 13:51:21 +0000 (UTC)
Received: (qmail 28412 invoked from network); 5 Apr 2019 13:51:21 -0000
Received: from unknown (HELO stampy.163woodhaven.lan) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPA; 5 Apr 2019 13:51:21 -0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Linus Torvalds <torvalds@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux-MM <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 2/2] mm/compaction.c: abort search if isolation fails
Date: Fri,  5 Apr 2019 14:51:20 +0100
Message-Id: <20190405135120.27532-3-mgorman@techsingularity.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190405135120.27532-1-mgorman@techsingularity.net>
References: <20190405135120.27532-1-mgorman@techsingularity.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

Running LTP oom01 in a tight loop or memory stress testing put the system
in a low-memory situation could triggers random memory corruption like
page flag corruption below due to in fast_isolate_freepages(), if
isolation fails, next_search_order() does not abort the search immediately
could lead to improper accesses.

UBSAN: Undefined behaviour in ./include/linux/mm.h:1195:50
index 7 is out of range for type 'zone [5]'
Call Trace:
 dump_stack+0x62/0x9a
 ubsan_epilogue+0xd/0x7f
 __ubsan_handle_out_of_bounds+0x14d/0x192
 __isolate_free_page+0x52c/0x600
 compaction_alloc+0x886/0x25f0
 unmap_and_move+0x37/0x1e70
 migrate_pages+0x2ca/0xb20
 compact_zone+0x19cb/0x3620
 kcompactd_do_work+0x2df/0x680
 kcompactd+0x1d8/0x6c0
 kthread+0x32c/0x3f0
 ret_from_fork+0x35/0x40
------------[ cut here ]------------
kernel BUG at mm/page_alloc.c:3124!
invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
RIP: 0010:__isolate_free_page+0x464/0x600
RSP: 0000:ffff888b9e1af848 EFLAGS: 00010007
RAX: 0000000030000000 RBX: ffff888c39fcf0f8 RCX: 0000000000000000
RDX: 1ffff111873f9e25 RSI: 0000000000000004 RDI: ffffed1173c35ef6
RBP: ffff888b9e1af898 R08: fffffbfff4fc2461 R09: fffffbfff4fc2460
R10: fffffbfff4fc2460 R11: ffffffffa7e12303 R12: 0000000000000008
R13: dffffc0000000000 R14: 0000000000000000 R15: 0000000000000007
FS:  0000000000000000(0000) GS:ffff888ba8e80000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fc7abc00000 CR3: 0000000752416004 CR4: 00000000001606a0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
 compaction_alloc+0x886/0x25f0
 unmap_and_move+0x37/0x1e70
 migrate_pages+0x2ca/0xb20
 compact_zone+0x19cb/0x3620
 kcompactd_do_work+0x2df/0x680
 kcompactd+0x1d8/0x6c0
 kthread+0x32c/0x3f0
 ret_from_fork+0x35/0x40

Link: http://lkml.kernel.org/r/20190320192648.52499-1-cai@lca.pw
Fixes: dbe2d4e4f12e ("mm, compaction: round-robin the order while searching the free lists for a target")
Signed-off-by: Qian Cai <cai@lca.pw>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index b4930bf93c8a..3319e0872d01 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1370,7 +1370,7 @@ fast_isolate_freepages(struct compact_control *cc)
 				count_compact_events(COMPACTISOLATED, nr_isolated);
 			} else {
 				/* If isolation fails, abort the search */
-				order = -1;
+				order = cc->search_order + 1;
 				page = NULL;
 			}
 		}
-- 
2.16.4

