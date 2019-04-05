Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFF99C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 13:37:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7358921852
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 13:37:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="kfqjbeK4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7358921852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 140406B026B; Fri,  5 Apr 2019 09:37:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EFD76B026C; Fri,  5 Apr 2019 09:37:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFB7B6B026D; Fri,  5 Apr 2019 09:37:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8861A6B026B
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 09:37:48 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id g2so660424lfh.6
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 06:37:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=E0muO+Novkm5hVzyWai7J+6iG5LjzDoURw6tq4KX2tY=;
        b=pdZBGmhPZ3ysNoFqiK4W/TWdZgTdmHDegiCwJ0SHKQ5/L0/2aHkMeBEtJ4ttkoJMZg
         h1yFaNFFYQknLUX+RhdYbf3FEhhl9U5BAkR7iL7HDfUqv5fn+DfOjEck7Pj2RPqdVjm6
         C6S13XQ7uvf4HQKxybfnTsO4R7GtP+3nRlNLUQBfq6SNpN7wcnxhS0V+M2IxsVaUu6Oy
         PS2y3d/XRl0HF9rnfEAKIpHp4MUlDg5G4G18eR7wWlghWr/sxFSu+6gmcZpLRwb7yDHU
         5oJYrF5A27V5r9vx6eVNZDM2SH92lDDpNsDLk2fkg/XZYWeROFjMx/YCxXq5hKuVLUzo
         kaDw==
X-Gm-Message-State: APjAAAUAoYtPGmS3BQCJYryyZDEkO2RHRpgD0SSh+CIFI/M4tPseWI8b
	Y5SE7l+E7mNezx8wEZHn7UQvYxYHAr6iUwO8t9XJAf50y7pKmiFa3lv/V7abUDNdIgjIA+zSFQ+
	nTsF6GI6V+f2E15hGYGcmPMx2igAxRej36cDXSDB8CeWoJDNHKRKrN7PKaqX0+KX6OQ==
X-Received: by 2002:a2e:8347:: with SMTP id l7mr7041018ljh.17.1554471467688;
        Fri, 05 Apr 2019 06:37:47 -0700 (PDT)
X-Received: by 2002:a2e:8347:: with SMTP id l7mr7040972ljh.17.1554471466894;
        Fri, 05 Apr 2019 06:37:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554471466; cv=none;
        d=google.com; s=arc-20160816;
        b=vurxHHhrgNnr6DtXvTXLBbyv0tNevXX+BDmUo4Lloztc/D9B1FW9C9XBvnK+2RQEON
         m7UhSBOEObHG8Q7PA17b2d2xiNE3LyioPXAdG/gsnTPFsLvy/Oi0S4NuVscg7T2BdNbh
         lDC+PUpJ5i+SkifRemdXUvSgR6XEdRLcFyXLpDdM0Qbr2dpQNPXmI5V/+jj9omRA7XxT
         ChL8QbuguN6LYKio2uI7rjhp45hWYC/5LKFvwqdEcPJH1p0AgyZVrPQkNPj9jlJ4IMc8
         nKmLjXFm/to4GcLD9/TCGacmQXC0o7+0Sy6x+pzgtYGZNnHD+mS3+TJbqQu0pkKoEJwI
         3lpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=E0muO+Novkm5hVzyWai7J+6iG5LjzDoURw6tq4KX2tY=;
        b=sbap34FaIWj33lJoKjoV2XXYqh+P4VLy8oR7jI1UiPqlNnktpkWL2LFqi7mV2SA/ar
         M8ogevuT0P/S80lTy0C764h7zwmmLpCaWJg3K2tlODbtjphjSdy44U+c6yM12GMA7Il4
         +hEkqY+9oLhbYxU33jhp3vfZnsUgsJ0Vzm7fuxuVUHtXfeL86SUMV54ezZROwodqvErO
         IPNqcVI+TPLArZFL93RCwXotWhL3GRo1d6IMWec77m5JYr7F/Fwl+aa2YfRkzIS/RW51
         84FM01yoBTNJ31gDDd7Mz0BRntuhh293J6J0bQ2+E3z+33U7/mACASDU8i/mOqzisPo3
         m6xg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=kfqjbeK4;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v16sor6231163lfi.32.2019.04.05.06.37.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Apr 2019 06:37:46 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=kfqjbeK4;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=E0muO+Novkm5hVzyWai7J+6iG5LjzDoURw6tq4KX2tY=;
        b=kfqjbeK4svFQQZ3TYPE0Q/bTitqLMsIzhx1KSiEACWF8IX062N5um2XVdUt+NuvLrT
         lY2C20GCJ+ASJ/0VB3ytybzi2QD2zO67EcE7B38pflEonQ5UP6+NEkH9m9gbf5RvExLZ
         XtvHfDfNqoIjf5sa800RS4636SOX0Ax4XhpqLP3Lqg2xEO8LDPQYE3LseCEXjGGIOFxR
         Z5DMIqiMyW0vhQQfV2AxCwFyRWOlDDw/fa/OvgaPYC9nPmiHoO4mOzPObhnY2q5DqF4E
         i46D4IO58lh5L9ACeTHo9vdoNgVWBvnHB5N1PngpylCFkTccniKxspNYntC9dtEJQ97b
         kV9w==
X-Google-Smtp-Source: APXvYqwtXVMAmYpQa5Benqs8bxw8z6Kxt8PfvJT0s/9svw7Sr+vvGRJyhaFCPwK/mx2RU6Mg1Rm70Q==
X-Received: by 2002:a19:e003:: with SMTP id x3mr6966307lfg.66.1554471466384;
        Fri, 05 Apr 2019 06:37:46 -0700 (PDT)
Received: from kshutemo-mobl1.localdomain ([178.127.198.154])
        by smtp.gmail.com with ESMTPSA id r27sm4360773lfn.87.2019.04.05.06.37.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 06:37:45 -0700 (PDT)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id DF64530039B; Fri,  5 Apr 2019 16:37:42 +0300 (+03)
Date: Fri, 5 Apr 2019 16:37:42 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Qian Cai <cai@lca.pw>
Cc: Matthew Wilcox <willy@infradead.org>, Huang Ying <ying.huang@intel.com>,
	linux-mm@kvack.org
Subject: Re: page cache: Store only head pages in i_pages
Message-ID: <20190405133742.goqgpxvbc4jsasz5@kshutemo-mobl1>
References: <20190329195941.GW10344@bombadil.infradead.org>
 <1553894734.26196.30.camel@lca.pw>
 <20190330030431.GX10344@bombadil.infradead.org>
 <20190330141052.GZ10344@bombadil.infradead.org>
 <20190331032326.GA10344@bombadil.infradead.org>
 <20190401091858.s7clitbvf46nomjm@kshutemo-mobl1>
 <20190401092716.mxw32y4sl66ywc2o@kshutemo-mobl1>
 <1554383410.26196.39.camel@lca.pw>
 <20190404134553.vuvhgmghlkiw2hgl@kshutemo-mobl1>
 <1554413282.26196.40.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1554413282.26196.40.camel@lca.pw>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 05:28:02PM -0400, Qian Cai wrote:
> On Thu, 2019-04-04 at 16:45 +0300, Kirill A. Shutemov wrote:
> > What about this:
> > 
> > diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> > index f939e004c5d1..2e8438a1216a 100644
> > --- a/include/linux/pagemap.h
> > +++ b/include/linux/pagemap.h
> > @@ -335,12 +335,15 @@ static inline struct page *grab_cache_page_nowait(struct
> > address_space *mapping,
> >  
> >  static inline struct page *find_subpage(struct page *page, pgoff_t offset)
> >  {
> > -	unsigned long index = page_index(page);
> > +	unsigned long mask;
> > +
> > +	if (PageHuge(page))
> > +		return page;
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
> It works fine.

Nice.

Matthew, does it look fine to you?

-- 
 Kirill A. Shutemov

