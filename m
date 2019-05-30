Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33920C28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:54:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1178261F9
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:54:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gFqv4vxW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1178261F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88A396B0271; Thu, 30 May 2019 17:54:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8399A6B0272; Thu, 30 May 2019 17:54:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 728596B0273; Thu, 30 May 2019 17:54:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 48C706B0271
	for <linux-mm@kvack.org>; Thu, 30 May 2019 17:54:15 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id z11so3483588otk.7
        for <linux-mm@kvack.org>; Thu, 30 May 2019 14:54:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=B4jiG1jHnMkQIVQ7CnmS/QGR53dJGB1zbfKCiInlabY=;
        b=XAwggdPuGXjofBxdJfTKxlrPfQAV9alXhbtPGjh3Ds32X/8P15PwF7DanUpk4fjm0X
         bSG5/bD4mY2xyYcu7wn/dMub3RLpelEbjgj81sBwjCvX/GkFz44ZNP69hrAvGh6xvjNA
         fEPEM1Ob9XV27HX/eflSIZwDUilOP3F7FxaZCjotYBcp3E+Xa1nv/TSJimm0cfBgWG2F
         Nk+fXy8zWn6vCPGm/U1Ctm7IscPmHvUgLM1mLSqCM0ricCEYAa9p5V8eOG9+m6ym/DYC
         4kkEWAY2EcF7Tq8vzeFgOkNPt952Y45LyI3wF/Y5hFEfkZ/N+Pvuqv6eQWL/g0UrK9JJ
         ds9w==
X-Gm-Message-State: APjAAAUcI2egfuynwPrm7coNCnJJZQUo4gUTmOURxi1dYw5THCGSYexA
	C44pORWgd/DLh9v3dyt2aJ5Oi2eF565q6B/7JYctV2vtc6l95XnWGn9AKOgxQqV/xRqBseGaEVh
	wGOmnp3ZzpTVJopqsYyZQl8z9nWITZJ5DnquKyJjD2eBbYSbkuwyESaYO3B97C8Zfxg==
X-Received: by 2002:aca:e68f:: with SMTP id d137mr2489041oih.14.1559253254919;
        Thu, 30 May 2019 14:54:14 -0700 (PDT)
X-Received: by 2002:aca:e68f:: with SMTP id d137mr2489012oih.14.1559253254165;
        Thu, 30 May 2019 14:54:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559253254; cv=none;
        d=google.com; s=arc-20160816;
        b=G4pi/vtXLzqcIUVPLHqCtWb0Ezi1XKJ3mL21VhCsTtd6FaUVmIQMB4/qIYQkNl4Mhj
         2DnG0jlSjgmjX3MrwDKov0ABxxcVcWnN6KmeQ2krS41M5pOC2qbdMX8W+worSdnOT8uN
         dljOIFfiyDGQWdkWWasgBD1eAU2/bnavv53fCnkO6KYmqxXvmFhZru3e6ySkgQCLbYzk
         sdieXzD6VbfsT9FakyrLADaOFE8PsUg5AJqzQ0cvtpThrM9iFUuxtcAgqoMH5ejqCKLo
         OABMye5/0IVsKtyFE0j87dseLUFlq5UQHIyPmBemy47WHAi3ehxBgoyrR/Af1vVyJKrf
         hjtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=B4jiG1jHnMkQIVQ7CnmS/QGR53dJGB1zbfKCiInlabY=;
        b=vpU23ZzpQOg6NXP8iFRWhMfs7+tk6hnTJt+8owGI59OM6CTTB0GegxjKlWW1e+jkV/
         8me9oZ2a1YFGpXT5OoWE012FNbgtnAP4zz+dhaUx3e1jZKOIUGpKyARA3H7LNZR9SiYc
         GvZ+fRVP3v2VwcAkPHfcLF/iOvAXmr+3qwI6edS4jMvbRdbdpYSgM+hYrXU/qqrFX+JX
         YwbSU5cpVt3HeTmudo3rRNeW+qpkvIkMH2h8gvcgQ8S7oJTRPNzQcLoEeo9/Hrp1T6+w
         J8wP91Cw19e1V78gtgA/XYQJoIhf7BMKLIq5Y9J7tgYZHs60rQTuWoxzjqH/XHc6dVPL
         gmHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gFqv4vxW;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r67sor1689468oib.117.2019.05.30.14.54.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 14:54:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gFqv4vxW;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=B4jiG1jHnMkQIVQ7CnmS/QGR53dJGB1zbfKCiInlabY=;
        b=gFqv4vxWqkG3q53XLUYxfM48NGGzs7jrJLI7d0NMsnFs3NTQJkvh/fhH7mNOhxNcwm
         Sibve0l8XDYlIMV6OuYkQ6hf2niU43j1ZVnWuTaSLmSd0utr5H6sIS+JtZc+zOty4IZi
         jjpXbccBXneHJ+bauOZ5a1GEd+4AOlJzJF95ua0OmIFggONVmImQ37q6Gp7FU/ZiUdju
         aosW9LUpVAmmvtENAf6doZ+0L5J0NvgSXY9lSqm4aatO01j1LJRrnC/71+cwmr56xVyH
         oy5F4HCSkc722yy8f4DT7yX+LiTTfV7tGD7wAWHkP/5MMiq7ldDQ90Ta2pzoEocPFtCj
         4Ffg==
X-Google-Smtp-Source: APXvYqwuDRLHPeeQeLx6gytguQrqXX7UFDROgnc7qqhaG7g508ei93QI0YTUhPJGvN6SN4xgMuKEFA==
X-Received: by 2002:aca:ec0f:: with SMTP id k15mr3783572oih.43.1559253253781;
        Thu, 30 May 2019 14:54:13 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id w130sm1429402oib.44.2019.05.30.14.54.12
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 14:54:13 -0700 (PDT)
Subject: [RFC PATCH 05/11] mm: Propogate Treated bit when splitting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Thu, 30 May 2019 14:54:11 -0700
Message-ID: <20190530215411.13974.73205.stgit@localhost.localdomain>
In-Reply-To: <20190530215223.13974.22445.stgit@localhost.localdomain>
References: <20190530215223.13974.22445.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

When we are going to call "expand" to split a page into subpages we should
mark those subpages as being "Treated" if the parent page was a "Treated"
page. By doing this we can avoid potentially providing hints on a page that
was already hinted at a larger page size as being unused.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/mmzone.h |    8 ++++++--
 mm/page_alloc.c        |   18 +++++++++++++++---
 2 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 988c3094b686..a55fe6d2f63c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -97,16 +97,20 @@ struct free_area {
 static inline void add_to_free_area(struct page *page, struct free_area *area,
 			     int migratetype)
 {
+	if (PageTreated(page))
+		area->nr_free_treated++;
+	else
+		area->nr_free_raw++;
+
 	list_add(&page->lru, &area->free_list[migratetype]);
-	area->nr_free_raw++;
 }
 
 /* Used for pages not on another list */
 static inline void add_to_free_area_tail(struct page *page, struct free_area *area,
 				  int migratetype)
 {
-	list_add_tail(&page->lru, &area->free_list[migratetype]);
 	area->nr_free_raw++;
+	list_add_tail(&page->lru, &area->free_list[migratetype]);
 }
 
 /* Used for pages which are on another list */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 10eaea762627..f6c067c6c784 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1965,7 +1965,7 @@ void __init init_cma_reserved_pageblock(struct page *page)
  */
 static inline void expand(struct zone *zone, struct page *page,
 	int low, int high, struct free_area *area,
-	int migratetype)
+	int migratetype, bool treated)
 {
 	unsigned long size = 1 << high;
 
@@ -1984,8 +1984,17 @@ static inline void expand(struct zone *zone, struct page *page,
 		if (set_page_guard(zone, &page[size], high, migratetype))
 			continue;
 
-		add_to_free_area(&page[size], area, migratetype);
 		set_page_order(&page[size], high);
+		if (treated)
+			__SetPageTreated(&page[size]);
+
+		/*
+		 * The list we are placing this page in should be empty
+		 * so it should be safe to place it here without worrying
+		 * about creating a block of raw pages floating in between
+		 * two blocks of treated pages.
+		 */
+		add_to_free_area(&page[size], area, migratetype);
 	}
 }
 
@@ -2122,6 +2131,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 	unsigned int current_order;
 	struct free_area *area;
 	struct page *page;
+	bool treated;
 
 	/* Find a page of the appropriate size in the preferred list */
 	for (current_order = order; current_order < MAX_ORDER; ++current_order) {
@@ -2129,8 +2139,10 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 		page = get_page_from_free_area(area, migratetype);
 		if (!page)
 			continue;
+		treated = PageTreated(page);
 		del_page_from_free_area(page, area);
-		expand(zone, page, order, current_order, area, migratetype);
+		expand(zone, page, order, current_order, area, migratetype,
+		       treated);
 		set_pcppage_migratetype(page, migratetype);
 		return page;
 	}

