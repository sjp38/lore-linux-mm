Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46F8BC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 13:46:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6DB220882
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 13:46:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="PZmWxRXG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6DB220882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 609736B0003; Thu,  4 Apr 2019 09:46:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BA376B0005; Thu,  4 Apr 2019 09:46:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FC146B0006; Thu,  4 Apr 2019 09:46:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC7C76B0003
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 09:46:00 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id g26so653393ljd.20
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 06:46:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=aX4bcANLE0qbzEM/DY2hmCSK/Q3OEHPRQfTver3cSSA=;
        b=oprDq3S622J98BuJ7Qw4Qd3TY/u22Bzjrb3vmrGO5R9HPRtnJRYw1zXPlg2E3D0g/L
         PNiOQn2JIPf7gw6pg/5CdixfLaMZJ5ORmlq92unI7deRwSJG/VaZ50eDpHu+BQdOUXaz
         MnjJPOXjYg0uh1yc4NZJScUTVGw9iino2D2I7Ayc6rOMRzvMq8bsgdE4zFKDxzV4qkj8
         tPrtDxm0nJb8b+I11/648Gq+IEkTt6RmOsbktd21hrFubJqeOh3mVKXHocuFmolYt8qe
         xbTncO4VL/X4v72+8pkyIceP6W+NMoey4WD+n+GrMI/HvmAEEeOfMfuKS2Ey9xpm/Vhy
         083A==
X-Gm-Message-State: APjAAAUjHMimBDZmw+MGe0TjrmKHoOBJzFgfieA+eUAVbbtjlldNSKNp
	qgpeTSng430v103FGmb0OKDyyZl7Ov5b9OPWblrLwsjrrXoIxDm5ygQDTltaM+CH4d1OR+/P8qE
	icnP/HfPPBI6xnTRX1oDfpF+xHu3ar+hNAcgn1M78xLESJJmRj3ehPkT0QbhXjhqCuw==
X-Received: by 2002:a2e:1245:: with SMTP id t66mr3602680lje.18.1554385559980;
        Thu, 04 Apr 2019 06:45:59 -0700 (PDT)
X-Received: by 2002:a2e:1245:: with SMTP id t66mr3602623lje.18.1554385558738;
        Thu, 04 Apr 2019 06:45:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554385558; cv=none;
        d=google.com; s=arc-20160816;
        b=baqr8vPcuAl3gobtE3Iz+syjw2+m8lgLuBnBq2MBcpmdguQvMjXzWm7WaDS0LleVQC
         QxdwtKWWWgSrGlGy/aOgmALUv4Yvi3drch30kTBcWCta2Rmz8t6p32tpKzdtz2CZdu6I
         DHcIG1+tAufsU533LNNhqesAy1II+YwY6wGygAn98e5EjFUQckJdYw2wK42RWYXT8ap+
         vQ3MHWwavEX+08j06IbMoxMtRMTfi1csKVqVef6xTVXg9KGUn8EDutFqy1Sq0H/8czJx
         eCo4Y80xt7hAMScg3u5e0U15kFWkoS5i3ESrLfY68eqEeQqwUgmV2/uLtdcAnajtT4en
         7Zyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=aX4bcANLE0qbzEM/DY2hmCSK/Q3OEHPRQfTver3cSSA=;
        b=PJmZEcijSWdg947PeuESNTGH1/veDAnWjYzoI1NMm1bFY03F+E45LJrdxXKroQ0WrB
         HKX3HfJ/YYpzU4IhtQ8/clrT2FR0o2VyYj2OCsnGaR25R/bjxMcm6PKG805mE5jJwqy+
         sopjTyDFeZgU4OVB92BdQaNqTNYjHUZsobO6FoFcvym4tcxQCjUV3JtPvDpgQYLkwRsJ
         7UwNbRijI7yqYbjtqwfpwEHH3I03nNuws+s0s9KYNnoI6rVcyX9ey/YkxXVhrK+03Lne
         /96XqVEvliX/BU/fRBgZOj/W/UKL6+yEqKEwPMlX8k+HIl5QwX6mSF2uLe6YZkSK5G96
         ZgQg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=PZmWxRXG;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e8sor5081567ljk.39.2019.04.04.06.45.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 06:45:58 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=PZmWxRXG;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=aX4bcANLE0qbzEM/DY2hmCSK/Q3OEHPRQfTver3cSSA=;
        b=PZmWxRXGpWcayfSi2kpHJRJoveLRXTjFHKoqxDEfzHy1fOJ2bSpeiv3tiz7KnR66dN
         3Xc1ypiLVSEW+vOvbkBOGFCt8ub6hjlzGjIMhXnRDdjqj+fPsW6XFdn/AaAX5ZYnJxis
         Sv7mHCtYLd2UNEaY9fAjnKYMxZBsFAMEyEB367ga46zqhFkebph3nXrU9Jn8Je9TyAOe
         +z7Hvl8N4MqgHQ7eFwLJJK+31gp1brMnd7wPIsoxEwAmp0MpUMJOKtwhFmNFbh/lH73I
         uZnlAo8qohpd0YLHntEjlo7mPIuGjWB+yQWw+jfMc26ROQaFFyA5Dx3VXIZnxNJA3cTy
         QgFA==
X-Google-Smtp-Source: APXvYqwm2Jmb6aQLc/380YnVbklP1+kuRjTa1UotVecAMc/nlwo+G0qtwJZnHFp9S3z/BKP3BBJnVg==
X-Received: by 2002:a2e:88c1:: with SMTP id a1mr3487516ljk.78.1554385558116;
        Thu, 04 Apr 2019 06:45:58 -0700 (PDT)
Received: from kshutemo-mobl1.localdomain ([178.127.198.154])
        by smtp.gmail.com with ESMTPSA id s67sm3932013lja.57.2019.04.04.06.45.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 06:45:57 -0700 (PDT)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 1387D30039B; Thu,  4 Apr 2019 16:45:54 +0300 (+03)
Date: Thu, 4 Apr 2019 16:45:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Qian Cai <cai@lca.pw>
Cc: Matthew Wilcox <willy@infradead.org>, Huang Ying <ying.huang@intel.com>,
	linux-mm@kvack.org
Subject: Re: page cache: Store only head pages in i_pages
Message-ID: <20190404134553.vuvhgmghlkiw2hgl@kshutemo-mobl1>
References: <20190324030422.GE10344@bombadil.infradead.org>
 <d35bc0a3-07b7-f0ee-fdae-3d5c750a4421@lca.pw>
 <20190329195941.GW10344@bombadil.infradead.org>
 <1553894734.26196.30.camel@lca.pw>
 <20190330030431.GX10344@bombadil.infradead.org>
 <20190330141052.GZ10344@bombadil.infradead.org>
 <20190331032326.GA10344@bombadil.infradead.org>
 <20190401091858.s7clitbvf46nomjm@kshutemo-mobl1>
 <20190401092716.mxw32y4sl66ywc2o@kshutemo-mobl1>
 <1554383410.26196.39.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1554383410.26196.39.camel@lca.pw>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 09:10:10AM -0400, Qian Cai wrote:
> On Mon, 2019-04-01 at 12:27 +0300, Kirill A. Shutemov wrote:
> > What about patch like this? (completely untested)
> > 
> > diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> > index f939e004c5d1..e3b9bf843dcb 100644
> > --- a/include/linux/pagemap.h
> > +++ b/include/linux/pagemap.h
> > @@ -335,12 +335,12 @@ static inline struct page *grab_cache_page_nowait(struct
> > address_space *mapping,
> >  
> >  static inline struct page *find_subpage(struct page *page, pgoff_t offset)
> >  {
> > -	unsigned long index = page_index(page);
> > +	unsigned long mask;
> >  
> >  	VM_BUG_ON_PAGE(PageTail(page), page);
> > -	VM_BUG_ON_PAGE(index > offset, page);
> > -	VM_BUG_ON_PAGE(index + (1 << compound_order(page)) <= offset, page);
> > -	return page - index + offset;
> > +
> > +	mask = (1UL << compound_order(page)) - 1;
> > +	return page + (offset & mask);
> >  }
> >  
> >  struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);
> 
> No, this then leads to a panic below by LTP hugemmap05.  Still reverting the
> whole "mm: page cache: store only head pages in i_pages" commit fixed the
> problem.

Ughh... hugetlb stores pages in page cache differently.

What about this:

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index f939e004c5d1..2e8438a1216a 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -335,12 +335,15 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
 
 static inline struct page *find_subpage(struct page *page, pgoff_t offset)
 {
-	unsigned long index = page_index(page);
+	unsigned long mask;
+
+	if (PageHuge(page))
+		return page;
 
 	VM_BUG_ON_PAGE(PageTail(page), page);
-	VM_BUG_ON_PAGE(index > offset, page);
-	VM_BUG_ON_PAGE(index + (1 << compound_order(page)) <= offset, page);
-	return page - index + offset;
+
+	mask = (1UL << compound_order(page)) - 1;
+	return page + (offset & mask);
 }
 
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);
-- 
 Kirill A. Shutemov

