Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB555C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 09:28:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 853BF21741
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 09:28:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 853BF21741
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 249946B0008; Mon, 18 Mar 2019 05:28:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A7B86B000A; Mon, 18 Mar 2019 05:28:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 097CB6B000C; Mon, 18 Mar 2019 05:28:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 98BF96B0008
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 05:28:18 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id 6so4387lje.9
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 02:28:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=mxNbg2U9QVpDsyt9B3ggL6erGUHadMnByeZtoBypyi4=;
        b=UmBN1SOBAzrAypt4GlthbnZ9DQ3YCY/BiTcaxNoVyqEiBrLvXGvJbEcbcFwigGi8DL
         X1fgnWHQ/s5nRpHQQuMl61WENWhz8bT3Kb3vvt5WiMEZOxK2fWMLksSWgsVhMfUW4pRN
         LEDvTs0R/EdG3pS77jHA/5W5+gqA1frMvzT1IbGYzAN1lPBPMvdB+Ne7gPabagCb79o7
         zYZUfajTK5V+72uQ/l9/93iWzaog3DkJnh6XGO2DCLgCKEKBdD76BLU6cbTQZQNQQMZY
         vX/6otMimr8sfP2BkMdSTcR96FUW+U5kld3MtJSSk+b6Cdp0eo1R5R0Usw1u1hNzDggy
         YOEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAX2pOKIopJhwrEEVOZXzJ44B7kQnPK0CzhXTO+9Zzm9WRtzYVe9
	4Z3CTI4eFrp4wAmUQ0IHqRepAvZs9LbkEGSI6pACRav65HeGxRTZd/zYVv+WKp3mTvAJ+DPFIgX
	5wjo9gb4NFVmoRRbnrEJvt7Cdb2Yn+cOETjQBxPuHSt8Q/yxvEg8B7ZrUrsFgeMymVw==
X-Received: by 2002:a2e:9e57:: with SMTP id g23mr6213727ljk.124.1552901297897;
        Mon, 18 Mar 2019 02:28:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTwuO7Eq6oPaoidt0hWl9uGQSr4DKGW8z3Kg3ZT3hY3hRt1LilvSx9Sj7HZMiWSZlokgqS
X-Received: by 2002:a2e:9e57:: with SMTP id g23mr6213663ljk.124.1552901296260;
        Mon, 18 Mar 2019 02:28:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552901296; cv=none;
        d=google.com; s=arc-20160816;
        b=uY4eUMwD4iQ/jvin7nfzsEOoeaLk4vLjwat0B2I5ZbkK0olobFb9/Y5XL98XH8/V0+
         KQh+Lyuh14K92TkbricwO86Urh+eMzHBU8vBVahKJeXPRIBvjPwtlSZFeo6NQp7vC9T2
         ahnHC7fDPSXSiWxSJrpXDlCIDrdIO+aUQtxVW3xoGXTSEpzfN6slLKn51OB9hLtAXXrz
         GZRw509Z7XfnEnis9u1KtxCLzc8gBsRRlkSuVy8w9lKhUTwpoQJ/LLweoxEixU9ExgSr
         itmsQJZRA/AtprdD4wYaVIvGNDLfi7/UBuHG/5Lt+oK18VmELpSIifm3uw1lr2cEw4IP
         MeAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=mxNbg2U9QVpDsyt9B3ggL6erGUHadMnByeZtoBypyi4=;
        b=yKeSCfHB9GXqwzzY6d8ssJS5Tzx+JkGHM6jbN1nu/xsJyZTbDGG2/Zo1CFtywQOicU
         O48VsB94O9SsQGN+uXW2GkkJIW772Gb1g2733kUFdJWZDt5i6wkfBV8P6fSJBG382jay
         DqWl0lg7oo25dpjAUTAn3GZrq+ZWm4fymQr5v5a4n2JjVG3LFfGzHFjATvu9BSQOiAH4
         B5ku8R79XrGAilV9BnMEUvG64lPhZxF3Gcb3kiYoYKZBecKa1OCoqK6rd30MXOx6E/Ye
         h4/pYkvF52DgAWxMGq7u08VSWxhKGzwyOPvQIfJaHozVYkZm0fl1KvLK0oAjxV2vuMpW
         SwVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id 1si7239935ljd.130.2019.03.18.02.28.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 02:28:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1h5oZ1-00055N-4M; Mon, 18 Mar 2019 12:28:11 +0300
Subject: [PATCH REBASED 3/4] mm: Remove pages_to_free argument of
 move_active_pages_to_lru()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
 ktkhai@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Mon, 18 Mar 2019 12:28:10 +0300
Message-ID: <155290129079.31489.16180612694090502942.stgit@localhost.localdomain>
In-Reply-To: <155290113594.31489.16711525148390601318.stgit@localhost.localdomain>
References: <155290113594.31489.16711525148390601318.stgit@localhost.localdomain>
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
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>

v2: Fix comment spelling.
---
 mm/vmscan.c |   19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d2adabe4457d..1794ec7b21d8 100644
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

