Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B650BC43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 13:12:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AC3220651
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 13:12:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AC3220651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 073B48E0004; Wed, 16 Jan 2019 08:12:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0217A8E0002; Wed, 16 Jan 2019 08:12:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E79E58E0004; Wed, 16 Jan 2019 08:12:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4B48E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:12:22 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id m19so2371411edc.6
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 05:12:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=m9WFYxWLI3WqTpeeb+4ZjZnBcvRf9Wsan2NZaJ3LLUc=;
        b=JSZ9eeiAW2JCgWjXwzXAeP9Sifq2JnjwgPx0fwKcyolB9ChkDF125baVioZqtJC0Oh
         KL+US9p+VXqUXHyKL44iD3tsBcfqKYCOXcN5Q9wNIPYgnJhT8rmTJN7dQ9Dn8+iob/Hi
         1ZjKfAbpuvv9eK1zoVhlZzXajjmGMweAGH4pEhgjaHr6b8lY6e7eJt4w0qPl2jVSG+Iz
         SAovEfqiO409HYsHYYIQpFdqecXFiZf/9pLKhFDYgHRoZvm/TsTFohwWPve6mBEQ/w0a
         YkcMNM077NatGGgL7GUYONlo6aQg0zhLmHzRScqwkMgigj4mGCWP9Fb3NdYApM3jYtQ/
         jQ2A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AJcUukcG4o1KopBlFICC9OYL+Doqj63dVUwb/xuvzOx1UWxG/vnJRcDY
	6G/RnYiDx4zrRDMRKbFrY8GSZ9cHmrMuB04qnlDhy5BBW2dLIMbtjdBfm4fU4wxxnFKAFJRFVgx
	R8eEa6LYXLEXr8903iJWqcON1sqczv9P42B8R0hQ+M3luMb/Ex9sL4UNWVuMW1GH4Bg==
X-Received: by 2002:a05:6402:1286:: with SMTP id w6mr7624885edv.53.1547644342040;
        Wed, 16 Jan 2019 05:12:22 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7FoN4J7E/ewxj9JH343C4s7tF3XAYdBMHQ8bcS1X1O+VbFK4uHOeYBw5XDJQBhw46Q3+/w
X-Received: by 2002:a05:6402:1286:: with SMTP id w6mr7624837edv.53.1547644341095;
        Wed, 16 Jan 2019 05:12:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547644341; cv=none;
        d=google.com; s=arc-20160816;
        b=ovq5WEay/Dk7+xfddYQ281pVq6tkbcCAmDjlOfibx0tTD0mDsqLjROjoOq+ZEPRoo9
         ApagX+3KDC1Z1ECs0U/NCWaCZxIuatNEG7rNppEcyR3tu3iW5Dym+1fU6MypVerla2pO
         dMgD9ID3D88IkA5RtHAAd5RGl9xNKt/HguGTAkMfC2NZy+Yb1H0ItlsQvNb11zPvpRct
         d0C1mTk+SKHOYpWNHxncUbSv9QWZPe18d3pWBMOpc2fM3YpjM4y1KrkQnrZH2xl1vGHg
         gEHFRpiux0QuLW54kSekWgSy8XG3wnO1fhLcKuZoleLKxHUZD/KG+HlqTDZn+az//KA9
         /IKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=m9WFYxWLI3WqTpeeb+4ZjZnBcvRf9Wsan2NZaJ3LLUc=;
        b=Esxa4SII2t+Ooc+sID+zUxvSsLzvrSx7MCFJBgwrEBaZeA1scBHCjerzUSKYBzOVtL
         unpe5O6ulgRAeZoXigqnBLovyDa/qfKrC3IREAqqk+Ked4tRUZZKF+op7iq8bWKkt5R0
         7hFvym2J/5zZ2EyKZyeyaFrvlQElN/CJkBzmxOyozw9E8yrzLlZ5TLVESgISZDzC9AOH
         czIY8cYmCXABtjNH5NBaE34mGQRl8hXXjAs1mlSgezVCO34WZ8+jF+pbz+uJihtkp2M/
         qenkoEh4Ha4gYhUZE0QbnALKyIRAom2izl1Qdec4BF30HGODEEIYboFo+oGQEWE/7Fof
         LAUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l17si2867049edq.20.2019.01.16.05.12.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 05:12:20 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 85850AE02;
	Wed, 16 Jan 2019 13:12:20 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 30E551E1580; Wed, 16 Jan 2019 14:12:19 +0100 (CET)
From: Jan Kara <jack@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: <linux-mm@kvack.org>,
	mgorman@suse.de,
	Jan Kara <jack@suse.cz>
Subject: [PATCH] mm: migrate: Make buffer_migrate_page_norefs() actually succeed
Date: Wed, 16 Jan 2019 14:12:17 +0100
Message-Id: <20190116131217.7226-1-jack@suse.cz>
X-Mailer: git-send-email 2.16.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190116131217.62riBJKlVUqUfBNk9d7xMQeGTGmUwFwiknnSgLTJC4Y@z>

Currently, buffer_migrate_page_norefs() was constantly failing because
buffer_migrate_lock_buffers() grabbed reference on each buffer. In fact,
there's no reason for buffer_migrate_lock_buffers() to grab any buffer
references as the page is locked during all our operation and thus
nobody can reclaim buffers from the page. So remove grabbing of buffer
references which also makes buffer_migrate_page_norefs() succeed.

Fixes: 89cb0888ca14 "mm: migrate: provide buffer_migrate_page_norefs()"
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/migrate.c | 5 -----
 1 file changed, 5 deletions(-)

Andrew, can you please merge this patch? Sadly my previous testing only tested
that page migration in general didn't get broken but I forgot to test whether
the new migrate page callback actually results in more successful migrations
for block device pages. So the bug got only revealed by customer testing. Now
I've reproduced the workload internally and verified that the patch indeed
fixes the issue.

diff --git a/mm/migrate.c b/mm/migrate.c
index a16b15090df3..712b231a7376 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -709,7 +709,6 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head,
 	/* Simple case, sync compaction */
 	if (mode != MIGRATE_ASYNC) {
 		do {
-			get_bh(bh);
 			lock_buffer(bh);
 			bh = bh->b_this_page;
 
@@ -720,18 +719,15 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head,
 
 	/* async case, we cannot block on lock_buffer so use trylock_buffer */
 	do {
-		get_bh(bh);
 		if (!trylock_buffer(bh)) {
 			/*
 			 * We failed to lock the buffer and cannot stall in
 			 * async migration. Release the taken locks
 			 */
 			struct buffer_head *failed_bh = bh;
-			put_bh(failed_bh);
 			bh = head;
 			while (bh != failed_bh) {
 				unlock_buffer(bh);
-				put_bh(bh);
 				bh = bh->b_this_page;
 			}
 			return false;
@@ -818,7 +814,6 @@ static int __buffer_migrate_page(struct address_space *mapping,
 	bh = head;
 	do {
 		unlock_buffer(bh);
-		put_bh(bh);
 		bh = bh->b_this_page;
 
 	} while (bh != head);
-- 
2.16.4

