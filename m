Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A63F2C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 20:53:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E7532147C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 20:53:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="FwG9l/cw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E7532147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB41B8E0002; Thu, 14 Feb 2019 15:53:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3B648E0001; Thu, 14 Feb 2019 15:53:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB58F8E0002; Thu, 14 Feb 2019 15:53:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 88E4D8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 15:53:34 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id j32so5184280pgm.5
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:53:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=H5PwboSGGlAokqw0PAd/z7ak2peDcf4SeLlrGYA5fKc=;
        b=dkjkWB4mE37DX+ZtyNGX0m+lrz12vJM5xGjsZ0Yw+l4mrqN8o3uLALnarLX3NTGOyg
         TQgil8NqlYhx8KvFQe9ABa3uA4YHdH1pY9mHqpEuPd/PyYh2ePYd/XGo3G09GpvGi1F5
         fs5zwhzqXV6Zl+w0cdZaj8v/Vpr6KLnY10d+Ou4d7L/Nwh459MITLQ5MH7nT7PakNNxy
         njNYKkTDMFPwCchS6LkjLCrT6cQ0f0uQ9eqEUWw0nr35QRTVJA7/xvZBKRWmX1MCM1Lj
         mRTlQp1D7zY0thDkJLCTy25yDmQbCbUPpzoB/VtJRvcC8lwpYwWo+H/1ws67WVCFT8ye
         JOwA==
X-Gm-Message-State: AHQUAuZGLkLjZFBoj/epU+pmU4r/ZoFRukpB8J4xx+Cw0YOIkWPlADAU
	fWvR+yDV3Ji4UabbTJylQwE1OIm0VgMjyAWqcwN1Hl5JTjDniHv6yyCu3BPuVQZRuB9Xpw3MNDy
	ojk7u8S4igeYXM8HOfrlvlTygxPGTVHvrCR2i6A5tZ0LWV+pgswKxAqz+3SY5h1m3lg==
X-Received: by 2002:a65:5301:: with SMTP id m1mr1747815pgq.90.1550177614234;
        Thu, 14 Feb 2019 12:53:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia57G7fec8oJb4dURi5ztVtCAhwOMQNGzyqbWU8VHvB2DmoFT0po8bUZ0LSf2AElB8mEfl9
X-Received: by 2002:a65:5301:: with SMTP id m1mr1747766pgq.90.1550177613402;
        Thu, 14 Feb 2019 12:53:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550177613; cv=none;
        d=google.com; s=arc-20160816;
        b=hqujDpn8SjV9syJ07IMsWc6Vgm6KGFuid6DqFIxkmO4jIpEE+F8yxzxYKwPyoDQpuI
         +L0ntLCvjAwNitVEfR6O+MEdCYJGmUvDNu+3T0CeoCBmOktNCUVz2oiL182DaqqvnSjV
         DLbmudL8oKFZLdar3cyMnDPVLuQgrhH+u/JeP45xIRd7bgwprdCob9x55LB+lF7yfCOR
         3EdUi06PaF1cyiy8yKZn63cSGNtrgeC32YvsVBnEIc4Z0qq+whReg8k1/hTEY7bLZE2/
         lYqaMrQWTH+nP5dMoUXxaSeXtSclfew6BRoEoEJuz8v24slkJndRfZmyJ0QggA+5hu2M
         +Kiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=H5PwboSGGlAokqw0PAd/z7ak2peDcf4SeLlrGYA5fKc=;
        b=EgrKO0zuV3WtMHJ9ih1efNp8qhEWvvGncn3AgMHqBBj2wfnV8Eg9n0y1W1l2TnY/Qg
         SLDpSyr0zgts2Kkxjsa7HrCnp+8HpU+xI5uHtfafC4rEgB+2bjWLPcUlzGYM/l22Kzz/
         Ljj0xCPLlnMGDdT8sJCGJgPzW3zoMh8kvheVjWj2rq596TKmsqm3s53O3atQDWlbLmpv
         8uLFpbbJS7/Pzq1HRPgnODns8Zi2t/J8Z+YYrVbjtTdP4SS9zW9Mak/GX7N9Ntu/NX9N
         IzGWLiTdR3Zs7sjiS/RHVCsu21zjfx8ieHr/ggtDCO4h0MBn8z9Rp3u9NkGtvUZSn1jt
         oq5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="FwG9l/cw";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f35si2522521plh.399.2019.02.14.12.53.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 12:53:33 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="FwG9l/cw";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=H5PwboSGGlAokqw0PAd/z7ak2peDcf4SeLlrGYA5fKc=; b=FwG9l/cwKw99N/a85Vxl2XbDF
	arzXbJEm8WPhghxy2F7l7b2b6ZaAsD5htaICiiNvJ/KszTVFGvX/xErj3SxWM9SBaAJ2AN9Sd3OzA
	OczKBPIUWVtB3CPK4D0chSxdZl2+DQc4fvcycZPlpG5oVH4jK/fL/tA7Vrngh9NoMYAsus5bhYcS+
	x/rKjAC5W2uNAfEYhQ3zpjIdpskaytmXZnJNf9z6dd1ZT9A2JzWhrQUml6bkeb9j3dFCOtXP+W+vw
	jLGilcbdijy5V80jtkEPBOQh7cOmwG06L3Pgs5yG4y1XH23h8RQpELjnQpeRo4jicBNpmJEZt0ofN
	hYkiMH4Uw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1guO0i-0000Wi-2r; Thu, 14 Feb 2019 20:53:32 +0000
Date: Thu, 14 Feb 2019 12:53:31 -0800
From: Matthew Wilcox <willy@infradead.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH v2] page cache: Store only head pages in i_pages
Message-ID: <20190214205331.GD12668@bombadil.infradead.org>
References: <20190212183454.26062-1-willy@infradead.org>
 <20190214133004.js7s42igiqc5pgwf@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214133004.js7s42igiqc5pgwf@kshutemo-mobl1>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 04:30:04PM +0300, Kirill A. Shutemov wrote:
>  - page_cache_delete_batch() will blow up on
> 
> 			VM_BUG_ON_PAGE(page->index + HPAGE_PMD_NR - tail_pages
> 					!= pvec->pages[i]->index, page);

Quite right.  I decided to rewrite page_cache_delete_batch.  What do you
(and Jan!) think to this?  Compile-tested only.

diff --git a/mm/filemap.c b/mm/filemap.c
index 0d71b1acf811..facaa6913ffa 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -279,11 +279,11 @@ EXPORT_SYMBOL(delete_from_page_cache);
  * @pvec: pagevec with pages to delete
  *
  * The function walks over mapping->i_pages and removes pages passed in @pvec
- * from the mapping. The function expects @pvec to be sorted by page index.
+ * from the mapping. The function expects @pvec to be sorted by page index
+ * and is optimised for it to be dense.
  * It tolerates holes in @pvec (mapping entries at those indices are not
  * modified). The function expects only THP head pages to be present in the
- * @pvec and takes care to delete all corresponding tail pages from the
- * mapping as well.
+ * @pvec.
  *
  * The function expects the i_pages lock to be held.
  */
@@ -292,40 +292,36 @@ static void page_cache_delete_batch(struct address_space *mapping,
 {
 	XA_STATE(xas, &mapping->i_pages, pvec->pages[0]->index);
 	int total_pages = 0;
-	int i = 0, tail_pages = 0;
+	int i = 0;
 	struct page *page;
 
 	mapping_set_update(&xas, mapping);
 	xas_for_each(&xas, page, ULONG_MAX) {
-		if (i >= pagevec_count(pvec) && !tail_pages)
+		if (i >= pagevec_count(pvec))
 			break;
+
+		/* A swap/dax/shadow entry got inserted? Skip it. */
 		if (xa_is_value(page))
 			continue;
-		if (!tail_pages) {
-			/*
-			 * Some page got inserted in our range? Skip it. We
-			 * have our pages locked so they are protected from
-			 * being removed.
-			 */
-			if (page != pvec->pages[i]) {
-				VM_BUG_ON_PAGE(page->index >
-						pvec->pages[i]->index, page);
-				continue;
-			}
-			WARN_ON_ONCE(!PageLocked(page));
-			if (PageTransHuge(page) && !PageHuge(page))
-				tail_pages = HPAGE_PMD_NR - 1;
+		/*
+		 * A page got inserted in our range? Skip it. We have our
+		 * pages locked so they are protected from being removed.
+		 */
+		if (page != pvec->pages[i]) {
+			VM_BUG_ON_PAGE(page->index > pvec->pages[i]->index,
+					page);
+			continue;
+		}
+
+		WARN_ON_ONCE(!PageLocked(page));
+
+		if (page->index == xas.xa_index)
 			page->mapping = NULL;
-			/*
-			 * Leave page->index set: truncation lookup relies
-			 * upon it
-			 */
+		/* Leave page->index set: truncation lookup relies on it */
+
+		if (page->index + (1UL << compound_order(page)) - 1 ==
+				xas.xa_index)
 			i++;
-		} else {
-			VM_BUG_ON_PAGE(page->index + HPAGE_PMD_NR - tail_pages
-					!= pvec->pages[i]->index, page);
-			tail_pages--;
-		}
 		xas_store(&xas, NULL);
 		total_pages++;
 	}

