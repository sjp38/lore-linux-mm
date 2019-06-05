Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F354EC28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 09:10:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC4702075B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 09:10:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qsKJodQe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC4702075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32B626B0008; Wed,  5 Jun 2019 05:10:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B3866B000A; Wed,  5 Jun 2019 05:10:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12DBD6B000C; Wed,  5 Jun 2019 05:10:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C90896B0008
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 05:10:44 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g11so15711753plt.23
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 02:10:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=A0F5TwKY/VCSLcp+XKNpiRnciFopNfIc4l3QtF9bGnE=;
        b=rOrbHj5qh+5WjaQzJ9ccATU00EAR62BVoQLd0G+AxiaWzqSl1KYckw5IlBE47nacLZ
         IFHN4lUalf1SZ5CK8BCSj4x4d6f9/E7wi2iYXBpIj1AMeyPJm70GNK4hQ0Tr9JbBRzNs
         nQon3cehkKmqgYtNL8HAUWVG35iKSA0fmKfl4Kviox2+eD/eENw1iBzVaC0iB/+LdOD2
         3uhByLBpUDj1NBmKLtbf1yAr4NqFS9N237bAXUWZ06DEz5NPMOrN0C+d4A27ISeV4p4/
         j57zzltbBK7X5oQNzsXBlHU2szoGV/o0plydV+yy8ZGnY0PNX5O5wrBBhbAKz7JPCZ/V
         7YjQ==
X-Gm-Message-State: APjAAAWQgtDqfk4bQ9m4Kwu6tVw/fClQFSvaHXKqvqzrbQg5T8aMAYUa
	fJ0AgZyyFE4O4rSX0MjJ7nBvernJHMdGc4NPc65kZGlcfDbII237qOVAGOjCsmE58v7mpUvdQO9
	jj/DxqdupDxWgwK7DJN3eyr1423ngX3v0DVuuqA6U140VjLRPYEIMfDAKM72qVc7Esw==
X-Received: by 2002:a17:90a:bf02:: with SMTP id c2mr15758723pjs.73.1559725844285;
        Wed, 05 Jun 2019 02:10:44 -0700 (PDT)
X-Received: by 2002:a17:90a:bf02:: with SMTP id c2mr15758625pjs.73.1559725843221;
        Wed, 05 Jun 2019 02:10:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559725843; cv=none;
        d=google.com; s=arc-20160816;
        b=HsxivcSQFrwPc0pdfo72pDex3DHLJa/GoNDvPHbjba4VZOdjtIQASEu1uBEZJaPoQn
         RWu0Ki3LyIRlwB2SwVMtLJu8I8v/HzGN74LK2js6M48xLBAd3hfvZkDk+PmJtVOYOLA7
         pqS5+aYMLo1U61mexcBsDMjtQ8oOHv4dX+ghwXgFxZJd9+NCgaHleM2WQ9hQehxh9+m3
         neb0wem3IBYxcDQqwrgbkjFyR0XtoD2PUXOatPLNbcpdaxaWOpNTHO4jUh+zZfKALnxb
         4g8r/SFaJkccLsg7TFHRs0vsOL/SFYI5PM1S0x7pDEAecWHgf7PBaMuNKtn4yOLGGnJ9
         yF+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=A0F5TwKY/VCSLcp+XKNpiRnciFopNfIc4l3QtF9bGnE=;
        b=UUIJORyAeziuQCjLbpW95g+TbhgKqBXueyABs/a/3/XtqatTMHEGhrB9OULsqqjZXF
         zKu72B8KqlBm15YDse9J9aB2lZpvP+QKpy9rI+qti7MYy9vsi8q21GTza7ypI6bdIU+n
         BNRxfN+WTeXqZwCvXslpE+Mper06JZWETV6ziOy21es+3/E8cUXfIwektzTw5xgu6mMw
         07+WO+NJ6tEKkeUqSaWz5VtFYyb6r/+blpWPvdOrziBnzlTD4OSoLODxDXszWpStHeV9
         EslFLhxhjz5ojBc4VlVq8fwgd5Ys2ZabwUV+vaZXHr8GVDZt0KxBNvx9bTW2HLuvsmVX
         Iulw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qsKJodQe;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m32sor10391289pld.47.2019.06.05.02.10.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 02:10:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qsKJodQe;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=A0F5TwKY/VCSLcp+XKNpiRnciFopNfIc4l3QtF9bGnE=;
        b=qsKJodQeWHQrpBSUsCV/81Z7vFl9IiPrLe7Wx+TTMYwOb8vRhY7qMbyumwt8N6nzUp
         huDpz/WgJhGZQJNcubX5sDMOT5m/6LbguxcPIte89UJaj/B9lKADRPVtqIepVB+oX5sd
         hnXgkLK8L2MAW5lPvWDC99pJ4HSaC8QE332V5c6l5n9kmFfM5U7iJgD+3HoP8nJY6/oe
         T2TGY4+lUrdaa/iyrZ9+h1U0EN1aUJNorBJTwurwt7/FrvQoDKhFU75jWXstBB47BFp4
         vZG8Ouj9I7fWnXUOm8nkebeHXwU6K1NcK2iJ+B0SMP3aK6IXE+yb2bmKcQto4teTeueg
         RHKw==
X-Google-Smtp-Source: APXvYqwPrprfYIFcfp2U4RhBi6aA36+dRA/hHPLVJndUrShnel3Up//HynanoblmvqR0aoxy92SoVg==
X-Received: by 2002:a17:902:624:: with SMTP id 33mr42733906plg.325.1559725842640;
        Wed, 05 Jun 2019 02:10:42 -0700 (PDT)
Received: from mylaptop.nay.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id w36sm11844525pgl.62.2019.06.05.02.10.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 02:10:39 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>,
	Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org
Subject: [PATCHv3 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in get_user_pages_fast()
Date: Wed,  5 Jun 2019 17:10:19 +0800
Message-Id: <1559725820-26138-1-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As for FOLL_LONGTERM, it is checked in the slow path
__gup_longterm_unlocked(). But it is not checked in the fast path, which
means a possible leak of CMA page to longterm pinned requirement through
this crack.

Place a check in the fast path.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org
---
 mm/gup.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index f173fcb..0e59af9 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2196,6 +2196,26 @@ static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
 	return ret;
 }
 
+#ifdef CONFIG_CMA
+static inline int reject_cma_pages(int nr_pinned, struct page **pages)
+{
+	int i;
+
+	for (i = 0; i < nr_pinned; i++)
+		if (is_migrate_cma_page(pages[i])) {
+			put_user_pages(pages + i, nr_pinned - i);
+			return i;
+		}
+
+	return nr_pinned;
+}
+#else
+static inline int reject_cma_pages(int nr_pinned, struct page **pages)
+{
+	return nr_pinned;
+}
+#endif
+
 /**
  * get_user_pages_fast() - pin user pages in memory
  * @start:	starting user address
@@ -2236,6 +2256,9 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 		ret = nr;
 	}
 
+	if (unlikely(gup_flags & FOLL_LONGTERM) && nr)
+		nr = reject_cma_pages(nr, pages);
+
 	if (nr < nr_pages) {
 		/* Try to get the remaining pages with get_user_pages */
 		start += nr << PAGE_SHIFT;
-- 
2.7.5

