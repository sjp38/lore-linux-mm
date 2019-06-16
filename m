Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC70AC31E51
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 02:36:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BF3321773
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 02:36:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BF3321773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F3456B0005; Sat, 15 Jun 2019 22:36:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97E666B0006; Sat, 15 Jun 2019 22:36:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 845888E0001; Sat, 15 Jun 2019 22:36:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 59C266B0005
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 22:36:26 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a20so1896687pfn.19
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 19:36:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=bkl2m9rSznBKJR9/S1mkDkSTlCwIFMZFBeZM6ElkH2c=;
        b=q6bQlKd3ow8DSJ3dyx3ttvcdwRVeajUaWXS86ZRUXQIB/o/cgBu5rVr1hkTcsmH8AI
         ZZMcg5quQ7ne8jjUi/Zs1JMDT4xBU8qYaIFho+ExYlYyKnEoaFk9gwZSveZpH1RSs6Nw
         RiIgxxM7E4+37a6axA7wQvE0TGKpIk8uYgOMJx5RGelDbOI3wewjZrcR0DZwg0wm2TYi
         dz55p0C/VMJy5hWtCLFUakWTsO/X66dw26ZCwF6It82v1UIkBSIzQMIwDFNVo5HcxdFE
         MsqKrzttc28m+sHAWrHKFeT+RtvPEDVk33jFjFo8DksIJcETyt2NRmp464VbBJz/2WQS
         d9wQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUImJ/RWuBMiqfVxZUoiqAHhqeV1MrPwi4SXYZCmw2Icj8j4hWg
	Rc4APPE0aKGtei4IBxTzfrh8fW4m8EsSW2cp38CLPURCawf7d4pvS5NAf/haURLBe4So5VerG7O
	jUjmpumTXG5mu7uEFzB4+aVr4d6FSjIIUiF7bZpeFgQYBh/z4LRbKRTw95M7iTHLfeA==
X-Received: by 2002:a17:90a:6097:: with SMTP id z23mr7314999pji.75.1560652586035;
        Sat, 15 Jun 2019 19:36:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQyDgYootjLNyUK5Rs0gXiOhnveLKTLtel9Qy3IycXjjaAoPPCbKJQFjd6WpMc6v2glwU/
X-Received: by 2002:a17:90a:6097:: with SMTP id z23mr7314946pji.75.1560652585211;
        Sat, 15 Jun 2019 19:36:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560652585; cv=none;
        d=google.com; s=arc-20160816;
        b=iQOpnwV6SuYRC6jJ9xe4BUtznW1ImPkSB9NiKhAiiqDkt7fhLJddcpJbO2hqaCyt+p
         RFwqn0rLvTPisT8XWWGpwG+DH9BDREsRqU8o1EyPzUWVGgs4xc93ccKN6dhvgHQV68aJ
         sEo8XDltaf0AbOwJhtHdkMYjbf5htTuu+094FUEG/zLCbZixfRoD0NTQq4MKM6J7CqY0
         rqZIxmQIWSnTVtohXy9pLW4noq1ZQp/5EIakMBrIH8+fZ83g64diLhX2dVwLOGvZrwtE
         tUAmrMOqcg7tDEPNvdgGpdzZtNa5VEYh/w2YkDS7m692JH2ICp4dyVR+RzpVUoWLAEcq
         g2Ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=bkl2m9rSznBKJR9/S1mkDkSTlCwIFMZFBeZM6ElkH2c=;
        b=I1hvy1IazcM4om/VxxsXQOknJckOOVOLdfIqrBqo/Z91ZZHEKU7CLwI6qXwrVLNxye
         i0nqOqcUTDUzc5Y94I2jsH7BLUolkAKJUuIUIJEMEzjvxK3sKUQaEhzrnFcRyDN30VRn
         9EErZ5a3KkKaLJUEO6diAN2CrkVXx5owWMfDc4r0RDk2hnhUtrQEAVNv4VkUnvlhoYXh
         imfRfZOrER+Gf1BfBawGM74ItIxcVntXUNc8q4WgmJFm8Wyp6OIeD0TUsl7+sR14Lwdt
         uDZnKA9pCEcraGTZh7NFWqtHREOfLwyQdFwHZoCIbIMXMovvvZhr2KxluEcr0qj5B5SC
         cWVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id c15si6749370pgm.421.2019.06.15.19.36.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 19:36:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 15 Jun 2019 19:36:24 -0700
X-ExtLoop1: 1
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by fmsmga006.fm.intel.com with ESMTP; 15 Jun 2019 19:36:23 -0700
From: Wei Yang <richardw.yang@linux.intel.com>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org,
	pasha.tatashin@oracle.com,
	osalvador@suse.de,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: [PATCH] mm/sparse: set section nid for hot-add memory
Date: Sun, 16 Jun 2019 10:35:54 +0800
Message-Id: <20190616023554.19316-1-richardw.yang@linux.intel.com>
X-Mailer: git-send-email 2.19.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

section_to_node_table[] is used to record section's node id, which is
used in page_to_nid(). While for hot-add memory, this is missed.

BTW, current online_pages works because it leverages nid in memory_block.
But the granularity of node id should be mem_section wide.

Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
---
 mm/sparse.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/sparse.c b/mm/sparse.c
index fd13166949b5..3ba8f843cb7a 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -735,6 +735,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 	 */
 	page_init_poison(memmap, sizeof(struct page) * PAGES_PER_SECTION);
 
+	set_section_nid(section_nr, nid);
 	section_mark_present(ms);
 	sparse_init_one_section(ms, section_nr, memmap, usemap);
 
-- 
2.19.1

