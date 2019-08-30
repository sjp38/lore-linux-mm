Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B692C3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 03:57:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE1BF23426
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 03:57:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="moQeQIKo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE1BF23426
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 642406B000A; Thu, 29 Aug 2019 23:57:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CB386B000C; Thu, 29 Aug 2019 23:57:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 492FD6B000D; Thu, 29 Aug 2019 23:57:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0192.hostedemail.com [216.40.44.192])
	by kanga.kvack.org (Postfix) with ESMTP id 2272D6B000A
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 23:57:24 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id BA612181AC9AE
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 03:57:23 +0000 (UTC)
X-FDA: 75877734366.20.loaf80_4085f48188012
X-HE-Tag: loaf80_4085f48188012
X-Filterd-Recvd-Size: 3770
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com [209.85.215.193])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 03:57:23 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id w10so2803721pgj.7
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 20:57:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=/HuFXkowcP+PhyYkveYBzv+j/h0vppynxHJvt6n2HAk=;
        b=moQeQIKoaJ93ePUYq94t6PADnGL2q3riHOwSm1XVfTZMGiQo4fV69WkpUmcqt5BP1W
         3cXgke7tr09maxVWa/iWQThO8rMN8byoSkxy29BLEpAGyRjswKoA6rRn+/9t3swI74ck
         mctaSLZRJ8NQaePEYastuGIEt4okwxK8PPu2KNj8oMV1j5OasElKppOurLrr0yw6/ruK
         Ld/RXGOilFBM3dlmGUqgBPgrKY+Xu3ACWyMq2Dr/Z7jnkbrsg/i8HpBCWqdMiBp5mchU
         jLsel04EOud3NkxXoSEGSPRAT8Fw7U+5nyRCZrrRhrPGvgh44xPJZbmZWnv/ZF4W/Ji7
         XhZA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:mime-version
         :content-disposition:user-agent;
        bh=/HuFXkowcP+PhyYkveYBzv+j/h0vppynxHJvt6n2HAk=;
        b=Xa4aXr2L8nKc11hgU/T5A9d6aNQ/lOIevkSxwNixHPLxZTdtmTs5Ue/OCZwRUliNaE
         +9lQUepmYxbA5cVd9t8ZjI7K+juGFdvnUK9JxLHazLQ0FmmFXuOPfUN3Dv5W20BACsqc
         ye+kOkQogW73K6PlZ4KLH85J87npt6p26YFGhaipcd9CICk8+MwfGKalCXoisQJ9zIVo
         OmQ81JYXx/VTYq3E6IoN0ZiR6GXxL5js5Pkx+dm9cN980zr+tO02PEeBQa0PLDCmQETJ
         aOsOlhSuou8r2NI2FTzFdywGviwpWF1TJEhUgBZzUdp4vNDg5g+E7unMIm69UGFyYsBf
         GjGg==
X-Gm-Message-State: APjAAAVabhHPjZaB79fdD3W81JTPD+ezEf1ekIQWvhZQ3CoxoCBhmos6
	oIskUXcK4IcvduQYhmXjAYI=
X-Google-Smtp-Source: APXvYqwNoLkKDpIBufzzAa4LKNrJHjHtc25D+dzgQpL88XmdY4FUFnHk06c63DKPdWP8/ES4ZAV4LQ==
X-Received: by 2002:a17:90a:fa82:: with SMTP id cu2mr13917778pjb.85.1567137442010;
        Thu, 29 Aug 2019 20:57:22 -0700 (PDT)
Received: from LGEARND20B15 ([27.122.242.75])
        by smtp.gmail.com with ESMTPSA id o1sm3024519pjp.0.2019.08.29.20.57.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Aug 2019 20:57:21 -0700 (PDT)
Date: Fri, 30 Aug 2019 12:57:16 +0900
From: Austin Kim <austindh.kim@gmail.com>
To: akpm@linux-foundation.org, urezki@gmail.com, guro@fb.com,
	rpenyaev@suse.de, mhocko@suse.com, rick.p.edgecombe@intel.com,
	rppt@linux.ibm.com, aryabinin@virtuozzo.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	austindh.kim@gmail.com
Subject: [PATCH] mm/vmalloc: move 'area->pages' after if statement
Message-ID: <20190830035716.GA190684@LGEARND20B15>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If !area->pages statement is true where memory allocation fails, 
area is freed.

In this case 'area->pages = pages' should not executed.
So move 'area->pages = pages' after if statement.

Signed-off-by: Austin Kim <austindh.kim@gmail.com>
---
 mm/vmalloc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index b810103..af93ba6 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2416,13 +2416,15 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	} else {
 		pages = kmalloc_node(array_size, nested_gfp, node);
 	}
-	area->pages = pages;
-	if (!area->pages) {
+
+	if (!pages) {
 		remove_vm_area(area->addr);
 		kfree(area);
 		return NULL;
 	}
 
+	area->pages = pages;
+
 	for (i = 0; i < area->nr_pages; i++) {
 		struct page *page;
 
-- 
2.6.2


