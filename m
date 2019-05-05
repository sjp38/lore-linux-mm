Return-Path: <SRS0=X77i=TF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF8FCC004C9
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 06:41:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4120B206DF
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 06:41:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hbgeM39s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4120B206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7233C6B0003; Sun,  5 May 2019 02:41:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D3856B0006; Sun,  5 May 2019 02:41:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59B646B0007; Sun,  5 May 2019 02:41:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0EF6B0003
	for <linux-mm@kvack.org>; Sun,  5 May 2019 02:41:19 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id j1so5357441pll.13
        for <linux-mm@kvack.org>; Sat, 04 May 2019 23:41:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=r5SmfjKivPdXIE8mEIiMmS2S6APbGCFCcBaBqjpmaeo=;
        b=FH7XQBhCe0qLv3rs8mvx6ZPX1L0PseJ9T+DsyqNWt4gg0BbBrv2rWyt6COQxl/wnc1
         EAJJLqlwFaFjMCF/s9C7X1YRnqViyxE9lflPNw/CAtZtXItfFL+gGupjoR0fHzviZdy5
         1RAnGwKMQqDgCyenRADVLvXN1yvY0Ec32k3XIO51FDHp5PQm25r7IzHTAIDUNng9WSjg
         d8UdLw9kW/k2Sm535WSTLb2nAvptSv8fZvUjqVFrzc/xgocvliGCSKkNMtz2vj0f1mr3
         maPI8ack2JUR8AwSHq2Uk5qvAAIqUyfzM1xRVbo71Hdf4pzIho1YIPI/pD7VjhRZTh6y
         O5xg==
X-Gm-Message-State: APjAAAVHHYbvXXZccsYEYxWJMxxjj8jdFLCXyNwxRNsUbuOXc+TsySvU
	IR5XOn4kmHGPV3lTCpUJt/I1ku6Vt69twA2hEjMARXuVURbvHAOgFH4FzEmt/ChQSn3h85QE6R1
	ZHklFMnDEH/p0t1i3JRR8+3x8y+uJidL1G92/BbUPdJqIvGv8El/kyhIqzJJB2vkByw==
X-Received: by 2002:a62:ea0a:: with SMTP id t10mr7574584pfh.236.1557038478652;
        Sat, 04 May 2019 23:41:18 -0700 (PDT)
X-Received: by 2002:a62:ea0a:: with SMTP id t10mr7574529pfh.236.1557038477383;
        Sat, 04 May 2019 23:41:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557038477; cv=none;
        d=google.com; s=arc-20160816;
        b=LiKCgqlOfTQj1sqqciiKhyHMsz8AWz1vDIHp1/JEvDNf+/NzZ3UyAE8KbrtNgq9Z1W
         MgFoBKdHIsAEE5Z8z0lSLR8u3IBj8tdiejmnSG8UJGZLVZHHD4Y4Z2m8BfuAhCy8Dlx9
         elVWqgqEeoUiLuFq9JVkDRbXG4f8WL/dBjAh5bREIbtwlBHpLaYZ1k+1D2LDmAb+d3mc
         pjvMPEksQi7agiVj1HrTbIFJO1XfBbKEUHmDFtgrsTsKIPf43VfeERsaqzw3/MSO+3KW
         l7X7MQSOtoc5klAzKNJoqcFyZLKYyiCjkrwARZD3lPEH6KH/3eg+UTrFISMs5CRjW2Sv
         tq2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=r5SmfjKivPdXIE8mEIiMmS2S6APbGCFCcBaBqjpmaeo=;
        b=meNDzTqb/MLGrcudGozOm5J+9psmBBzoM5itmOaatqzqldlkqD5oDwFt2d58HqLgmh
         DjufTa717wHCUy/vjNL9A91iREPyfChAtO5EmPdodPwFdlPJ7r2Hp18I4iCrntqhi7lK
         8AIVPnQv+3J5+pAUlLW2UD0V9sqdiom39SVtbOnvHHdLHItMLxES6rfNyNPC0AerCmLH
         HHtOtYLfAWZ0ACMcn/oAQsUdMDj/Ty+y4C62eq9krKN2+8guxmGaQjZwfFf8dEskO/pS
         mLiY/J/X/WdRoWtOLz/vnxPWNCYG876asDJxwgXWn2K/Dy+9jTWueoe773+4kdyDpLVH
         c2Sw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hbgeM39s;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m2sor7975092pll.44.2019.05.04.23.41.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 04 May 2019 23:41:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hbgeM39s;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=r5SmfjKivPdXIE8mEIiMmS2S6APbGCFCcBaBqjpmaeo=;
        b=hbgeM39sGeaod8/26fGbb3HLjIlRnvNvXnDJxp2Js9rljqXUKst9ZK4aUYJrCmWTvr
         3c2OIii9MnzMQ7RTvixk2Nm6/O25ajThuB0qFcTKA0xv5TwkG6fiKRh2sRpPZS9+O0pj
         /eOYW57z+1LwuDMeV9ovfoXXamVXsKLvC7061sbnlGDA08vgEfouvIqMlTm/dfj+ph5V
         8KEZ67XC44vpJ7RMQZgHHqcgrZ8rFUYGNodAgqGeu+jtJFr/5KgEkpRgDekPyWL1BX9o
         IOY3KMfJFo3KJI7gZHV5phPlBW3I7XYubHd0UPqwnO6bVHio00p6gMuzuk1sVnY2XEGe
         BS8w==
X-Google-Smtp-Source: APXvYqznSF1fZUA0RrXaIbcYzJ+EHU/kRC40c/myNp9v0KEbRXV/4RtMWtpEiWqNwVYw1nPjvqNMEg==
X-Received: by 2002:a17:902:b481:: with SMTP id y1mr23343605plr.161.1557038476915;
        Sat, 04 May 2019 23:41:16 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id d10sm8065072pgi.6.2019.05.04.23.41.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 May 2019 23:41:16 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@suse.com,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm/memcontrol: avoid unnecessary PageTransHuge() when counting compound page
Date: Sun,  5 May 2019 14:40:57 +0800
Message-Id: <1557038457-25924-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If CONFIG_TRANSPARENT_HUGEPAGE is not set, hpage_nr_pages() is always 1;
if CONFIG_TRANSPARENT_HUGEPAGE is set, hpage_nr_pages() will
call PageTransHuge() to judge whether the page is compound page or not.
So we can use the result of hpage_nr_pages() to avoid uneccessary
PageTransHuge().

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/memcontrol.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2535e54..65c6f7c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6306,7 +6306,6 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage)
 {
 	struct mem_cgroup *memcg;
 	unsigned int nr_pages;
-	bool compound;
 	unsigned long flags;
 
 	VM_BUG_ON_PAGE(!PageLocked(oldpage), oldpage);
@@ -6328,8 +6327,7 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage)
 		return;
 
 	/* Force-charge the new page. The old one will be freed soon */
-	compound = PageTransHuge(newpage);
-	nr_pages = compound ? hpage_nr_pages(newpage) : 1;
+	nr_pages = hpage_nr_pages(newpage);
 
 	page_counter_charge(&memcg->memory, nr_pages);
 	if (do_memsw_account())
@@ -6339,7 +6337,7 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage)
 	commit_charge(newpage, memcg, false);
 
 	local_irq_save(flags);
-	mem_cgroup_charge_statistics(memcg, newpage, compound, nr_pages);
+	mem_cgroup_charge_statistics(memcg, newpage, nr_pages > 1, nr_pages);
 	memcg_check_events(memcg, newpage);
 	local_irq_restore(flags);
 }
@@ -6533,6 +6531,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	struct mem_cgroup *memcg, *swap_memcg;
 	unsigned int nr_entries;
 	unsigned short oldid;
+	bool compound;
 
 	VM_BUG_ON_PAGE(PageLRU(page), page);
 	VM_BUG_ON_PAGE(page_count(page), page);
@@ -6553,8 +6552,9 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	 */
 	swap_memcg = mem_cgroup_id_get_online(memcg);
 	nr_entries = hpage_nr_pages(page);
+	compound = nr_entries > 1;
 	/* Get references for the tail pages, too */
-	if (nr_entries > 1)
+	if (compound)
 		mem_cgroup_id_get_many(swap_memcg, nr_entries - 1);
 	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg),
 				   nr_entries);
@@ -6579,8 +6579,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	 * only synchronisation we have for updating the per-CPU variables.
 	 */
 	VM_BUG_ON(!irqs_disabled());
-	mem_cgroup_charge_statistics(memcg, page, PageTransHuge(page),
-				     -nr_entries);
+	mem_cgroup_charge_statistics(memcg, page, compound, -nr_entries);
 	memcg_check_events(memcg, page);
 
 	if (!mem_cgroup_is_root(memcg))
-- 
1.8.3.1

