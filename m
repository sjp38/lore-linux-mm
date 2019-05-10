Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19F93C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:51:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CCF92216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:51:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="EghpAUZR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCF92216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3DB76B029D; Fri, 10 May 2019 09:50:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEDA66B02A2; Fri, 10 May 2019 09:50:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB6D76B02A3; Fri, 10 May 2019 09:50:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 54DF66B029D
	for <linux-mm@kvack.org>; Fri, 10 May 2019 09:50:47 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j1so4184034pff.1
        for <linux-mm@kvack.org>; Fri, 10 May 2019 06:50:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=RHY5H5dgXN4b1oxgjV6Sg58kOntjndk6XpDrn2FN3c0=;
        b=WWlsXMhVYsaau73kJuhJKQWzYjGx48Vy6o8ey1xIXGkWInr5642t42uka0c6AB9tFl
         S0FNbB2mdYZGpRm8PC6o1sk8WIXMJgET8a/yVyjUZcN4ztFn4DklRxWTX6fyllIIhXR+
         bGxY5kiOaSt5H+mbWRvvn7Tr4oy5CVGux+qrVQ7rfFjNF9LFPFEBKHPNN6KQd0PKKFTi
         b2jVEgFa6TO69El2b+ilToN+j1hP0asF6arVTPhPi5yaIME/LW+BP8HVSk3Q3DKrtjXc
         Tjh4w43wCTEfg0BafrZHXs93DIjGCh044AgaBs3xldc8006awG5Pkq/nEiUzMiTk+8y8
         fDXA==
X-Gm-Message-State: APjAAAUy9TnPMmaReXRBu3lgBUV+FppxOe7ANrPnl+Z7TB8vnuYjP/G5
	5kn3ufDGDoLibpkrxK8PKGmBhBNhRzWP9Cdz9vowARkD6kq1VEYPFBZ7UDyVaIYgPEkIS6rQOqm
	Re9VtsfOMe/CI1qy/I0Z/wack2lI8wFEdW/STgT/0DYymTor4OVhsXX6m1dvIjX4ung==
X-Received: by 2002:aa7:9242:: with SMTP id 2mr14439234pfp.230.1557496246947;
        Fri, 10 May 2019 06:50:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDojYAIq6AuFZDA/uJBlZgCiCC9qH47ui+stwseRnKOXbvqoU8yDL4NgX+w60ZYw5J3/hG
X-Received: by 2002:aa7:9242:: with SMTP id 2mr14439038pfp.230.1557496245490;
        Fri, 10 May 2019 06:50:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557496245; cv=none;
        d=google.com; s=arc-20160816;
        b=U/vGD2DMoANejckZQ+1QKlKQD4DRrIo1UprKeQxz/Eb6XQnCGLXWhskUlYmg3l7+oT
         W0fepdltWykVTvvqHjxYTNK6Ytt1hreOA1+OaxvLC0E5RdlKmwBGb2rqh9QOU26xhaB7
         yvaMgjNM7zdGwIsLkJm2sHTVDyCiPrzKYK+zs+WqDanKS5IFUGS9hxpa2ACxeLQ7nHdI
         5rt660gbrTfEHK6jJSYA8LtIxlSHJFzNatFho0Fy7QXdHGsMHXqmqghBO6gT7/EYju22
         8T6E5TOA0OAbcjRGUe4KsIV/SbOTVA/D+OrfkBBb+mleimqdu/5VhTJMxQEjmCzw3R8O
         AioQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=RHY5H5dgXN4b1oxgjV6Sg58kOntjndk6XpDrn2FN3c0=;
        b=YF8ww5xES98/bgRDo0r9/5WuctfIG3F18/IX/6GqjZUR1JoOGFw6PJDRQukwKPjL0C
         UwhBvY4luo2s7byo46/tvXeEXWSpyx8yHUo2cL+IJ/ubleow9SqQxVPuSqueMUwv2mCk
         c+OcM8pEfVCeGF4OJcDfcCbwXVEoEAQfdfmFcK3CoOlfH3NEsiB41iTcmn2/Olx690PR
         APKkAPjJgWHNbHSLCVIwiyi3vo4p2mWTPCaZ8abEJDT5GpuWGIHYkk2AK1MLAVtbSLQZ
         FjuY8ukfi9tRLNKg2Ar4asiSmdL7hvV+FnJE5kwu2JSeL75yLc+JPBrrqasXZHkW4SZg
         NzVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=EghpAUZR;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k1si7257233pld.322.2019.05.10.06.50.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 06:50:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=EghpAUZR;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=RHY5H5dgXN4b1oxgjV6Sg58kOntjndk6XpDrn2FN3c0=; b=EghpAUZRUQe+I6NeuIG8k97L8
	KdICvvmNkLrSP++jajBlIUDmGiQ4yge0cNQ9zwyHmKhW7RcICo2exbauD7E/ZW2xwBR/dHSm06PzL
	0xpPteMm3M/kaAzdGO2SUDIFhzK6MXPVWzIFKggGAEdN9g7oKUMYjFyUu+0/xjt+B2qCc/NrjYsZq
	ZT0bAaftQw/cTwJhgSmrgRNETCukt3drqRhLTU9iFBJ/AJ8bDMvhuNopw0otdXNyradj/EWry2qre
	NxH5tyNs2afWiwkmIa3+fIMM02SrBCmLbiaOirn4tp9lZZGwZEA7c+/124eB1IPco0F08ESPnQJDP
	XjjMba8Rw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP5v6-0004Te-Ns; Fri, 10 May 2019 13:50:40 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH v2 04/15] mm: Pass order to alloc_page_interleave in GFP flags
Date: Fri, 10 May 2019 06:50:27 -0700
Message-Id: <20190510135038.17129-5-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
In-Reply-To: <20190510135038.17129-1-willy@infradead.org>
References: <20190510135038.17129-1-willy@infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Matches the change to the __alloc_pages_nodemask API.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 mm/mempolicy.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0a22f106edb2..8d5375cdd928 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2006,12 +2006,11 @@ bool mempolicy_nodemask_intersects(struct task_struct *tsk,
 
 /* Allocate a page in interleaved policy.
    Own path because it needs to do special accounting. */
-static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
-					unsigned nid)
+static struct page *alloc_page_interleave(gfp_t gfp, unsigned nid)
 {
 	struct page *page;
 
-	page = __alloc_pages(gfp | __GFP_ORDER(order), nid);
+	page = __alloc_pages(gfp, nid);
 	/* skip NUMA_INTERLEAVE_HIT counter update if numa stats is disabled */
 	if (!static_branch_likely(&vm_numa_stat_key))
 		return page;
@@ -2062,7 +2061,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
 		mpol_cond_put(pol);
-		page = alloc_page_interleave(gfp, order, nid);
+		page = alloc_page_interleave(gfp | __GFP_ORDER(order), nid);
 		goto out;
 	}
 
@@ -2128,7 +2127,8 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 	 * nor system default_policy
 	 */
 	if (pol->mode == MPOL_INTERLEAVE)
-		page = alloc_page_interleave(gfp, order, interleave_nodes(pol));
+		page = alloc_page_interleave(gfp | __GFP_ORDER(order),
+				interleave_nodes(pol));
 	else
 		page = __alloc_pages_nodemask(gfp | __GFP_ORDER(order),
 				policy_node(gfp, pol, numa_node_id()),
-- 
2.20.1

