Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0451C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:35:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87BD32229F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:35:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87BD32229F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29F3A8E0005; Thu, 14 Feb 2019 05:35:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24FC18E0001; Thu, 14 Feb 2019 05:35:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1666D8E0005; Thu, 14 Feb 2019 05:35:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id A010F8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 05:35:40 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id u13so397733ljj.13
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 02:35:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=0f9owyR/NSRzC8ViUPOE6sLF6LKi2n+ogoDsLA3wDhs=;
        b=SkJs/6Erenq2jX176t3IdgGXVywbbYzMdq9Gukc0e1raKaWsYJGzURslyK3/PWXIc3
         F0+luF8/G8AGesDMnuCcYqG/T3SFhu2cx4KC/vwG1j3qhLIR8DU029mcqg7/ncSy4eVb
         KM1ovB3Om8P+s5rdHUzrTL07qAUeyTSUR4vk6VMKc9kpCO5zTzfkCXwvcfiSoaHaZJ+M
         ECofAHBmSxEvjrLX6cRMDWo/7pyjUqDmeV0T3UqLPD66Gx+Hc5TG//viCuaU6oEqZ4Ru
         u1FVD4fURhxsRz1Ozugu4K0QdIlM0asQtX2luXJcONqebrJDkwoyhWF2ChS7kFr4AwqQ
         7YWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAubjtrPKTMiLdAohWuP+elP8Qnt1CwCSfPA45aVL0yROoKnAoVmh
	fmR4WtItNz2CaUuoE4lRBsU0LV/0RSzHJv4F1ToKaq1+9but4BoR05qiBHdYfPeKAEH381ANoJm
	XyuKU2l8+jIuglgfJsyaoFY0NBjcwWU2gJYUJ1cu+Kiw65629MqAyFyAiMs3GIhN5CQ==
X-Received: by 2002:a2e:9e46:: with SMTP id g6-v6mr1935567ljk.52.1550140539999;
        Thu, 14 Feb 2019 02:35:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ6FNcaYoF9jig6IRDVPQMoQS5/vWGi0NEg4hEDbkgvvsEVvn0THydxER3Rp0Xyrs8mfhKQ
X-Received: by 2002:a2e:9e46:: with SMTP id g6-v6mr1935508ljk.52.1550140538741;
        Thu, 14 Feb 2019 02:35:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550140538; cv=none;
        d=google.com; s=arc-20160816;
        b=Ee7Ay4NBJTfh9PI6RVqwZJ5xAdZX28sivu0k7gmU1NrUgSGY9V9OJEERph97OVJeqS
         mLMFHX9E59aiYtDqlUISv5EOtPBRLtd+JA2GHvNb9HvWvRhK3enn9QD4Z9Mc9I0urGKL
         Wp6QlOte9o90g3slTDeRBArWGyI8zsOsIzbFvcHBfimrrnNiitBAduKk0LO5tU6qEXvj
         +ijEARzGEjAJ1lxmcIqM8RWS52dky2u/6h2gPUvLP/CS9ftmnCESKCxBisrPFZfxF4zI
         Lv/gEZXKcIxcCT5hT1yy5sOILf0EUab58TJ4uZ/7Jz2GRAyKfHniUxKnfGhEl83QL4WI
         hFSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=0f9owyR/NSRzC8ViUPOE6sLF6LKi2n+ogoDsLA3wDhs=;
        b=iKslmxJhhO5mZlh5pcJK5Gh+wPNNs86haV/uccAMFlp1/DIzPkTIjn3VeUiiZK76yp
         2SLhlIVvuaznwY+Dc7qff0Fgzfa+x4PTGjPn0F+jIbSUxIvKC/nowDLwAKu3pPT4v9C9
         J7YNUUQiJ++Bo4oM6uA+t9wUW9Q1K3Y/VPDU7v3y2FibYhWt5x9EXZgF24nqpD4H7hzz
         mJM4U9Ui+uTzh51FuOo1T103MUO4FasN66IVTexvm9NXr0KX1UVtIPA+DNhLmH2h+zHh
         9rv2EuHhZrDI2Sq+qCZK7qcaCpn8qjFNsiYA7DzeQfm6DmZSR2sIvQYC9xnsq39+V5aD
         EZPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id f26si1741352lfk.147.2019.02.14.02.35.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 02:35:38 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1guEMe-00053T-5r; Thu, 14 Feb 2019 13:35:32 +0300
Subject: [PATCH v2 3/4] mm: Remove pages_to_free argument of
 move_active_pages_to_lru()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
 ktkhai@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Thu, 14 Feb 2019 13:35:32 +0300
Message-ID: <155014053202.28944.16316170128712977883.stgit@localhost.localdomain>
In-Reply-To: <155014039859.28944.1726860521114076369.stgit@localhost.localdomain>
References: <155014039859.28944.1726860521114076369.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We may use input argument list as output argument too.
This makes the function more similar to putback_inactive_pages().

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

v2: Fix comment spelling.
---
 mm/vmscan.c |   19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8d7d55e71511..656a9b5af2a4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2004,10 +2004,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
 				     struct list_head *list,
-				     struct list_head *pages_to_free,
 				     enum lru_list lru)
 {
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
+	LIST_HEAD(pages_to_free);
 	struct page *page;
 	int nr_pages;
 	int nr_moved = 0;
@@ -2034,12 +2034,17 @@ static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
 				(*get_compound_page_dtor(page))(page);
 				spin_lock_irq(&pgdat->lru_lock);
 			} else
-				list_add(&page->lru, pages_to_free);
+				list_add(&page->lru, &pages_to_free);
 		} else {
 			nr_moved += nr_pages;
 		}
 	}
 
+	/*
+	 * To save our caller's stack, now use input list for pages to free.
+	 */
+	list_splice(&pages_to_free, list);
+
 	return nr_moved;
 }
 
@@ -2129,8 +2134,10 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
-	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
+	nr_activate = move_active_pages_to_lru(lruvec, &l_active, lru);
+	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, lru - LRU_ACTIVE);
+	/* Keep all free pages in l_active list */
+	list_splice(&l_inactive, &l_active);
 
 	__count_vm_events(PGDEACTIVATE, nr_deactivate);
 	__count_memcg_events(lruvec_memcg(lruvec), PGDEACTIVATE, nr_deactivate);
@@ -2138,8 +2145,8 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&pgdat->lru_lock);
 
-	mem_cgroup_uncharge_list(&l_hold);
-	free_unref_page_list(&l_hold);
+	mem_cgroup_uncharge_list(&l_active);
+	free_unref_page_list(&l_active);
 	trace_mm_vmscan_lru_shrink_active(pgdat->node_id, nr_taken, nr_activate,
 			nr_deactivate, nr_rotated, sc->priority, file);
 }

