Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1086FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:27:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1B0F217F9
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:27:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TJ8CrHqJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1B0F217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40AC78E0004; Tue, 26 Feb 2019 12:27:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BB708E0001; Tue, 26 Feb 2019 12:27:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D24F8E0004; Tue, 26 Feb 2019 12:27:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E39BF8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:27:47 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id b12so10035802pgj.7
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:27:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/vBKQukGrCv9pM+rvi3dEGIzlDrNEuaOu5R8ALF3dKY=;
        b=tFKK8OVxIjC5IYupjvq2HtL0Qqcq1KRUduVbyGFA/C3gzgOrpOUK2nR2pVVuO2tfq/
         DhaJf4wFIXuYEx+836nPr1BPf8iAHZ5deQ828o4uRlprDqaVgmLdIDnt8VEPSSN3RRLQ
         iDcyHjZE+vsU/LrR4jPit4uoQZcmWlPQEEAVryOq6LP71tCbkMuz4qYUbRy8bWJTBtcQ
         BkfEagmdLJ+AcaiI7tUNjNhGwGea5h5BK/2Gez+n377byJhEBf7CQZVKtCJ6MfOX2lyF
         44PdnAz4H03E5eKgZyrxqpfiJYSEyJeYozpYhrU6xtOb2eH00oqQuUHm0ueEIrvrj3Fe
         zDnw==
X-Gm-Message-State: AHQUAub1c6NnGrHBbpquv2nsjF/lusgZKIVDaOuo41kSsLdHqfKRJ3ca
	B7VdZOrmMElffaC5F5a7F0QP/HDrgmqqnUeIEChEyb4WYDEqHJRrSDSpdFL4oue/R695UBuxyln
	lakMUlhT2aFNmpcES3W/KWniphsZ9HENn5RYpZ9z4dPi3hgh49xf+oDvvpd2DmZCa9Q==
X-Received: by 2002:a65:63c1:: with SMTP id n1mr25090004pgv.339.1551202067597;
        Tue, 26 Feb 2019 09:27:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZMU8qcdyyl8W1LPdVg+Aq9cMhbQo2EPGsSZiiBH1jRI2L6Cpz3PjHucMgCr75WQy3Fdz95
X-Received: by 2002:a65:63c1:: with SMTP id n1mr25089939pgv.339.1551202066440;
        Tue, 26 Feb 2019 09:27:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551202066; cv=none;
        d=google.com; s=arc-20160816;
        b=paoipLLn0CaYm4+MZviF0mzZEkiX4OTxfP+tJW43XYj+qbuRbRZPdQHLNuZQCxiK+d
         kqn2xskV8WnQJce5Yxt1jP5MGSgaBJQvZ99VHWaPl+R5CPKzeNzVG9r9Eeb206gqVBgA
         219LNyandHA5eeChvElneiBvms3o3rgpumi6QiinIwmhlAbnW/9unpOJWepnf8l1IJTC
         SKT44GsufjZL8inGyB7QWdUZ4bbU+f20WgNLcSRbDBVXBv7+saRb6TD3sh48GY9SVe7f
         AF1JNUHsgcjll9b3otXcR6reAA1Vjvi7cq7glyP982xCFVvrQL7UgT2dfg7KTWrm4kSk
         hw6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/vBKQukGrCv9pM+rvi3dEGIzlDrNEuaOu5R8ALF3dKY=;
        b=LOxALwEBHsA8h+kP5TBv+WIDVrK5C3rBxaZvxmYpM8JhcLFvxDgZQOGcF5eUB6ElsR
         hiOmSMbQUtJi8XPr/gHp51pz7bkY96CtG5jrLYsA1ZNgX7RTjBW3Ez2Sx9q6hxh6yOMH
         pMW6gsDBy5AytZHE4LM5nif/elF8JHbNmBWvIDmO2Sm0It8wo9XwLb3mg0d5oy7uzS21
         aXaPhozqqW4XxlqJuwFeIB0K5OMZcNKghPIdDnuOazyCu8+2XPyYufLv5kmYa7ucYfNx
         Zgeg31uar7PHd6BDzNNqKn1CtrDYsGYcA1kZu29AM3/5lYc0L7zZ2AHuY8u20cBmD3Ie
         P8wQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TJ8CrHqJ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i12si13316490pfj.236.2019.02.26.09.27.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Feb 2019 09:27:45 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TJ8CrHqJ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=/vBKQukGrCv9pM+rvi3dEGIzlDrNEuaOu5R8ALF3dKY=; b=TJ8CrHqJSZFzh3fhiNsEw34O9
	wUQytjFB5jM547+jQnJaJqoIACqi4GWE6tMJHv07Xv+x/CwhRbCts6GsgSLSLuGd6cGGE6yYVCGO0
	j/XqC6uq7EbAB0Lg6mSvlASqPbnoC9UPTzAuln7FsW8q9bUBgGIw8n2KZyLU+FZNgP+eFIaqqTa2s
	zjeYkSIaA2T3eNF6x0eIuDmsIVkM9u2h4Q+2MMcz8/dNPa3PUOWuUGFZm2dYlNQD6H+I3UaI7tlSZ
	KbAgPDrwkD7+Bnj8WhqJaKBfHn10YlaFPpLDaCY4yR+GOdkPoTHXpe8ibxkOc7jbCvtWzhTH7mp7g
	eGzb9Gm8w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gygW8-0002Kq-Uv; Tue, 26 Feb 2019 17:27:44 +0000
Date: Tue, 26 Feb 2019 09:27:44 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, mgorman@suse.de
Subject: Re: Truncate regression due to commit 69b6c1319b6
Message-ID: <20190226172744.GH11592@bombadil.infradead.org>
References: <20190226165628.GB24711@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226165628.GB24711@quack2.suse.cz>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 05:56:28PM +0100, Jan Kara wrote:
> after some peripeties, I was able to bisect down to a regression in
> truncate performance caused by commit 69b6c1319b6 "mm: Convert truncate to
> XArray".

[...]

> I've gathered also perf profiles but from the first look they don't show
> anything surprising besides xas_load() and xas_store() taking up more time
> than original counterparts did. I'll try to dig more into this but any idea
> is appreciated.

Well, that's a short and sweet little commit.  Stripped of comment
changes, it's just:

-       struct radix_tree_node *node;
-       void **slot;
+       XA_STATE(xas, &mapping->i_pages, index);
 
-       if (!__radix_tree_lookup(&mapping->i_pages, index, &node, &slot))
+       xas_set_update(&xas, workingset_update_node);
+       if (xas_load(&xas) != entry)
                return;
-       if (*slot != entry)
-               return;
-       __radix_tree_replace(&mapping->i_pages, node, slot, NULL,
-                            workingset_update_node);
+       xas_store(&xas, NULL);

I have a few reactions to this:

1. I'm concerned that the XArray may generally be slower than the radix
tree was.  I didn't notice that in my testing, but maybe I didn't do
the right tests.

2. The setup overhead of the XA_STATE might be a problem.
If so, we can do some batching in order to improve things.
I suspect your test is calling __clear_shadow_entry through the
truncate_exceptional_pvec_entries() path, which is already a batch.
Maybe something like patch [1] at the end of this mail.

3. Perhaps we can actually get rid of truncate_exceptional_pvec_entries().
It seems a little daft for page_cache_delete_batch() to skip value
entries, only for truncate_exceptional_pvec_entries() to erase them in
a second pass.  Truncation is truncation, and perhaps we can handle all
of it in one place?

4. Now that calling through a function pointer is expensive, thanks to
Spectre/Meltdown/..., I've been considering removing the general-purpose
update function, which is only used by the page cache.  Instead move parts
of workingset.c into the XArray code and use a bit in the xa_flags to
indicate that the node should be tracked on an LRU if it contains only
value entries.

[1]

diff --git a/mm/truncate.c b/mm/truncate.c
index 798e7ccfb030..9384f48eff2a 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -31,23 +31,23 @@
  * lock.
  */
 static inline void __clear_shadow_entry(struct address_space *mapping,
-				pgoff_t index, void *entry)
+		struct xa_state *xas, void *entry)
 {
-	XA_STATE(xas, &mapping->i_pages, index);
-
-	xas_set_update(&xas, workingset_update_node);
-	if (xas_load(&xas) != entry)
+	if (xas_load(xas) != entry)
 		return;
-	xas_store(&xas, NULL);
+	xas_store(xas, NULL);
 	mapping->nrexceptional--;
 }
 
 static void clear_shadow_entry(struct address_space *mapping, pgoff_t index,
 			       void *entry)
 {
-	xa_lock_irq(&mapping->i_pages);
-	__clear_shadow_entry(mapping, index, entry);
-	xa_unlock_irq(&mapping->i_pages);
+	XA_STATE(xas, &mapping->i_pages, index);
+	xas_set_update(&xas, workingset_update_node);
+
+	xas_lock_irq(&xas);
+	__clear_shadow_entry(mapping, &xas, entry);
+	xas_unlock_irq(&xas);
 }
 
 /*
@@ -59,9 +59,12 @@ static void truncate_exceptional_pvec_entries(struct address_space *mapping,
 				struct pagevec *pvec, pgoff_t *indices,
 				pgoff_t end)
 {
+	XA_STATE(xas, &mapping->i_pages, 0);
 	int i, j;
 	bool dax, lock;
 
+	xas_set_update(&xas, workingset_update_node);
+
 	/* Handled by shmem itself */
 	if (shmem_mapping(mapping))
 		return;
@@ -95,7 +98,8 @@ static void truncate_exceptional_pvec_entries(struct address_space *mapping,
 			continue;
 		}
 
-		__clear_shadow_entry(mapping, index, page);
+		xas_set(&xas, index);
+		__clear_shadow_entry(mapping, &xas, page);
 	}
 
 	if (lock)

