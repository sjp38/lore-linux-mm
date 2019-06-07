Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52194C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 11:36:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24D8320B7C
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 11:36:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24D8320B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=glider.be
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B14F96B0273; Fri,  7 Jun 2019 07:36:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC7AF6B0274; Fri,  7 Jun 2019 07:36:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DF056B0275; Fri,  7 Jun 2019 07:36:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 66AA76B0273
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 07:36:02 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a21so2690438edt.23
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 04:36:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=8BEH63pJowSJondu7VQfqmwLGsRDd66vdDZ7KSYW/0k=;
        b=gwqkqVBBrlI7BuRRo/22NSGn84+LqV9NDQqnq0zYjrR8+fxXi13BMzg3wGW8fhKsIg
         NoZUp7toJ5RCuvHYapSSAFk1grHu5nGFM02kxoGzrtNB/0HFcnDS9K1MdoyUodBc3IXr
         MKAdldvXv00Pfjtaa9rGADhfrlXF4T1NSN8GzUdNn1C+Qt4rrMOLOwGYTCB7HWVvWmqo
         UqJez9ee8KfukLHPEQbQFh4AX2JuUC1tlAUk9CznvEzdW9ODKFT3xYmHo1fD1o4pWeKY
         PtkYJxuGeAzFmfYEpmRB2QVvvwJoBR+mklFZ4tNls3z96bOa9o/K7L1roRs0rv+vuc41
         v5UA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2a02:1800:120:4::f00:14 is neither permitted nor denied by best guess record for domain of geert@linux-m68k.org) smtp.mailfrom=geert@linux-m68k.org
X-Gm-Message-State: APjAAAUhVcyadh626jxYIoVGuE8OMDDRYXPUv0JJviCSD7pq2QiX+uYq
	1BUmJAL/hfcwJA+YK+NioUkK7DK4DojnYzXQt0CSVQIMBNUMOgdryf+kD0Fb4oCfUOLT0qTD30G
	j5MIaxziNs+luId82Gf6PuKMo9J4RGzWcxhbtM7pBrYvjMjHLFWzC91sswdXYC80=
X-Received: by 2002:a17:906:4482:: with SMTP id y2mr45928803ejo.201.1559907361933;
        Fri, 07 Jun 2019 04:36:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5v0P39UaSIxv7NtbDrJAPK0hkxQaqJ/cpkzSC/8RRaSiaeGPLuTlLbObDgn7QB3VszXkT
X-Received: by 2002:a17:906:4482:: with SMTP id y2mr45928763ejo.201.1559907361062;
        Fri, 07 Jun 2019 04:36:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559907361; cv=none;
        d=google.com; s=arc-20160816;
        b=nja1r+NbVc/QTzN47GgTq8Bdm2GOEgV1Q7fmWdIa6RVYIFVZLROYtyMVhNujg0MnWe
         EpCeJXj3bkdxvYO8se0VidNUgf81K0sh7P0GIlJPfSKUDdwNMJOXzHmEu2LhS5iZaXzs
         pfGzQV/EFfclAANch1LFnOMR4Zbr10JQ3IcU2iqlUtzkc5i1aC6zenlrmztaQv5CwDO4
         /B8hz6OWkqCJffrtCYbn8Ds8t29OVS85P9hOAb371Az8yWBoPt9YUR+Xhg1CjxaS0cCN
         PPdwusU3Q4Jfs8Xe3VOn+rsoKlUjgvM+MdCnU/3QsL05r5iZ4zd1GEUNnsr9B8OtadJ+
         Yyqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=8BEH63pJowSJondu7VQfqmwLGsRDd66vdDZ7KSYW/0k=;
        b=U1a/KzFQQNcottJGWuSILw+gIiXLYX77RBxzH3h94n/2xbpS3moo2EZl4UJCQeAgdx
         APqdsSAPotAbDaInNJZx02Fo+jLwEmpGbvaKoBCCsXMfC6FHEhLnhU7tBIn1437q447i
         pvDT/DchBVtGLDCviQY5unBUqdBhX1fs9QFxPuDelJFHwV4Cgc8Gp+caUWfKq8/BRV8q
         G+YWBB85E5zXpOzsZVd01EDjvnVaQobXD+b92YpJDZ5hn2jp65phUJBfolI1E+clJ0KL
         /xrF34JdcLfEwb9pwVGxo4AR2BtM7PC1fVTwuGj8SwyhvqPOS40rMN1NPYHEAMCvw76v
         oumg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2a02:1800:120:4::f00:14 is neither permitted nor denied by best guess record for domain of geert@linux-m68k.org) smtp.mailfrom=geert@linux-m68k.org
Received: from xavier.telenet-ops.be (xavier.telenet-ops.be. [2a02:1800:120:4::f00:14])
        by mx.google.com with ESMTPS id u37si400249edm.447.2019.06.07.04.36.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 04:36:01 -0700 (PDT)
Received-SPF: neutral (google.com: 2a02:1800:120:4::f00:14 is neither permitted nor denied by best guess record for domain of geert@linux-m68k.org) client-ip=2a02:1800:120:4::f00:14;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2a02:1800:120:4::f00:14 is neither permitted nor denied by best guess record for domain of geert@linux-m68k.org) smtp.mailfrom=geert@linux-m68k.org
Received: from ramsan ([84.194.111.163])
	by xavier.telenet-ops.be with bizsmtp
	id Mnc02000C3XaVaC01nc0EL; Fri, 07 Jun 2019 13:36:00 +0200
Received: from rox.of.borg ([192.168.97.57])
	by ramsan with esmtp (Exim 4.90_1)
	(envelope-from <geert@linux-m68k.org>)
	id 1hZDA8-0004Fz-5g; Fri, 07 Jun 2019 13:36:00 +0200
Received: from geert by rox.of.borg with local (Exim 4.90_1)
	(envelope-from <geert@linux-m68k.org>)
	id 1hZDA8-0003wW-3R; Fri, 07 Jun 2019 13:36:00 +0200
From: Geert Uytterhoeven <geert+renesas@glider.be>
To: "Michael S . Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Jiri Kosina <trivial@kernel.org>
Cc: virtualization@lists.linux-foundation.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH trivial] mm/balloon_compaction: Grammar s/the its/its/
Date: Fri,  7 Jun 2019 13:35:59 +0200
Message-Id: <20190607113559.15115-1-geert+renesas@glider.be>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 mm/balloon_compaction.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index ba739b76e6c52e55..17ac81d8d26bcb50 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -60,7 +60,7 @@ EXPORT_SYMBOL_GPL(balloon_page_enqueue);
 
 /*
  * balloon_page_dequeue - removes a page from balloon's page list and returns
- *			  the its address to allow the driver release the page.
+ *			  its address to allow the driver to release the page.
  * @b_dev_info: balloon device decriptor where we will grab a page from.
  *
  * Driver must call it to properly de-allocate a previous enlisted balloon page
-- 
2.17.1

