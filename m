Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA87AC7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 13:12:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C9F1218BE
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 13:12:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="THmUzDON"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C9F1218BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 137676B0003; Tue, 23 Jul 2019 09:12:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E9B48E0003; Tue, 23 Jul 2019 09:12:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F19218E0002; Tue, 23 Jul 2019 09:12:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB0986B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 09:12:15 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id j12so21915276pll.14
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 06:12:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=5Xxj9U/zS83HJV13Ata/50176YxMYH+7D4lSiJVniWQ=;
        b=FXPP1/YFtNQ7ilxzmuWZfL5U7LTg3mXMeCrE0HG8Mi7vRLBHH86TinOrgTw6MV7xXY
         V0ZXFnxzkjOQxwRQI9oC4kpjLFKinDj97g55Xc2SCWwzk29vghFKOrpHMGbX9uXXuyNK
         Qw6MWcUBtyWHy/t2oY1lrUwOoqPT7mNFrtJOqVo96RUimW+EtJfVxfZUPq1wrIpxrnbC
         6BFaaaxFvNmDCDCw5s2HdmMTL2j74aWYbwUm6c9VQkZZ3i45YObGPyqhlVaHJRqnPfzC
         d8jSQaWnoXjhjdnKGFkFb4i/M9d62p724bXdNfzUao1SXWOR8eGEFyEBK5KrX1j9Hunp
         dOFg==
X-Gm-Message-State: APjAAAUoUbO0mfHg8bjLqlHfPnVRB3jSN186ETiHAJOrrkX7U3jIgdDx
	cbPdA7Y1ieodCWM0oxDUijD7meVTn5TtQg6Hov54n2U9Kg9cG3zs4tJTxHUcaJLbytiDnMeXKmo
	HN9idxWfv+Y1c62wVJ3JfUK4TZ7qYu4TCxlJpOj7NtU++lNG5DgMTQ+upBIRmWxkSjA==
X-Received: by 2002:a17:902:e202:: with SMTP id ce2mr77620390plb.272.1563887535483;
        Tue, 23 Jul 2019 06:12:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMkrzEAFJmtZtvq1YoYMqC5i/PuwnTsfwU6LXA92Sv6N6O71lOYNTNluxfH+GTJlOyDQPp
X-Received: by 2002:a17:902:e202:: with SMTP id ce2mr77620351plb.272.1563887534911;
        Tue, 23 Jul 2019 06:12:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563887534; cv=none;
        d=google.com; s=arc-20160816;
        b=ILQNLOVK3gOHqSHt3JhrqgTba8qqCoGSkJUh6HVSg1gSyXJRp8PDu4feHIXpV81JQZ
         G0mPvWY3/dz/oSNgrDTvqOrr8bGzdIyQhlcRV0OadMuT5k/JklSjAryCIS3cH2qpH6bi
         0r+olINtdL1JcaMq/X197G3P35GypTkVW62xM9/4cGNcBD4J5mwRmCOE++Q9mxbpb7uI
         gYl5Z7Re1ZuXOTugzyQdRyKLytyw80tGWhWcO/8rsE9Ijfl67PPjNaCDZnsdoFo5BX4o
         6nh/FpRXcdwY7hYr6ngnoIOO8bZXHeXie6qBqk4ft4lklwvy8xG+lmMDdZ1HhcC3x/G6
         VbHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=5Xxj9U/zS83HJV13Ata/50176YxMYH+7D4lSiJVniWQ=;
        b=gtotzeyL1X8vmUSizSNKsxyGANZ/aXQM3LyxJt3YOUpulQPUHwPLq9Q9glF+PJNC27
         DYTjboJz+IFyWBOwlBI2DRKedMrQBv1ATSX4Gfe9Nyi0X1dtUrHJGGsMb8vd1zHeAb+3
         JvEhJlS7Kz3GuLHUafnBcHQ7atpRheIxYbAvrAS+r8akyeKgcHhFLlcC7DF97MY0ZLCx
         7cinM/3bX0pb7ij9pbtk9bkDKG3SPVF7rKcZSp9Dpk/YmnIyQnwh6ijZ5H9nT32LAE2e
         XgOS4hLgxvY0OJUrcwHKrMhyP4EdEWDpzcHeZxFiGdBmYFwKpqujG9z1uj7W6X7G9QcZ
         yeZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=THmUzDON;
       spf=pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jlayton@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r190si11530453pfr.102.2019.07.23.06.12.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 06:12:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=THmUzDON;
       spf=pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jlayton@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DE4EF21734;
	Tue, 23 Jul 2019 13:12:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563887534;
	bh=ZO1wGUmWSLKPo9gdfNOhIY94diLFMvhRrwi5O5KH5Dg=;
	h=From:To:Cc:Subject:Date:From;
	b=THmUzDONEyO1NATBaw9+6OuqUfeHe4ipWbIjPLQ/NzvjO64hlY6DK00Xr6DbflX6/
	 eHD8o9DGxDG+tvbB3DbKvPaYfgNXokZExapLeFB4tkEYOMhESeYkqjI4FrdIWuKFlk
	 zZ2HUxyee8m9rj9ugWJbnV5Hxpfrdt9Qq08x0uwQ=
From: Jeff Layton <jlayton@kernel.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	viro@zeniv.linux.org.uk,
	lhenriques@suse.com,
	cmaiolino@redhat.com
Subject: [PATCH] mm: check for sleepable context in kvfree
Date: Tue, 23 Jul 2019 09:12:12 -0400
Message-Id: <20190723131212.445-1-jlayton@kernel.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A lot of callers of kvfree only go down the vfree path under very rare
circumstances, and so may never end up hitting the might_sleep_if in it.
Ensure that when kvfree is called, that it is operating in a context
where it is allowed to sleep.

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Luis Henriques <lhenriques@suse.com>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 mm/util.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/util.c b/mm/util.c
index e6351a80f248..81ec2a003c86 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -482,6 +482,8 @@ EXPORT_SYMBOL(kvmalloc_node);
  */
 void kvfree(const void *addr)
 {
+	might_sleep_if(!in_interrupt());
+
 	if (is_vmalloc_addr(addr))
 		vfree(addr);
 	else
-- 
2.21.0

