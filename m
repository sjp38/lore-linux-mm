Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50BCFC0044B
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 20:17:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08E3F222AC
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 20:17:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="T5RyWRDU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08E3F222AC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA1128E0002; Wed, 13 Feb 2019 15:17:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A50C68E0001; Wed, 13 Feb 2019 15:17:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 940218E0002; Wed, 13 Feb 2019 15:17:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 570798E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 15:17:18 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id n24so2443399pgm.17
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:17:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2HC/AVySH17dcJ1eOjuqITZP6s+yGuGkZUMcpGJBHoA=;
        b=rUgaDx3tGPVFCrZyT4TV2qo7pnvGZolx6AikQecb8MfJkCjbymeCbvj2V3ve/bZKXG
         dm6sGPs3dhwxOsutttsIufxsaor9Y7sE6ZKlZQRVH35dQrpPBKB+Es/QKYKHTM1e24g3
         T4ZZgmbp7OIapMhrriHLXixzRD4fgOnKCPUIzXlBIKCq9UZXtS+eKpn1dbvfjinJ3GdF
         3VNeZUPxIit9nPtCHeHp+dbLgHZT+ddOpdrWyqP12eKGG3ndt7JGnxW6POZDHkEz5STq
         MBtqzUFONr9u4+suIUTkwIsdCu8f14mYI8GYk2CDocgNz30z0i4UaMZFIykbj1kTMozd
         x0rw==
X-Gm-Message-State: AHQUAubApW8pceaz2a44JotiFjjadtcxC642uQuVXhy/NLSO0BF2zloN
	hbau8DNb/FbgKz7qw2Y4SNcFn0XajPWh1hS+hSJ8LKb8p1/mHN6qnBcO6sUMPHwonqfkMhMe5SQ
	YNsaEGm2XjKOCEieG05lZCw1q68lPEL2ru9NbEF5BNHeky+8HSvjNwf5JUJ7WtchpPw==
X-Received: by 2002:a17:902:8a:: with SMTP id a10mr2342067pla.158.1550089038024;
        Wed, 13 Feb 2019 12:17:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZbxxMGrofwx5hAnbL7nBGun+U3xenMnwf/Ta6o+EVOHRXhc7tdgw9o/qibk4/dpbeYCgGF
X-Received: by 2002:a17:902:8a:: with SMTP id a10mr2341997pla.158.1550089037128;
        Wed, 13 Feb 2019 12:17:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550089037; cv=none;
        d=google.com; s=arc-20160816;
        b=YPFaDLQlU4iX0nuRNl80XOhBlqmPF1VmZdJsp7wEst/5ZeTcwwKiJ0qp/6XywrZt/Y
         ttUc0/2yOLGrmIKeiEtfV7GIUWiO1zKYE8eBJ300MqFBcCz7pK6H7P3cdCWvgLVvicD3
         smE4ypr1RBksU5rkyCqDn+VB2N2/N2Ey1p35bot6XGPV+ci1aVqGD9nKFkhI1eXqOIIH
         G8InHMfvKerdY84fHuVs3yC8fnmur/2HhybjHfBzdZaXhHf1fiuS2tjE+h34kCzyRyPG
         jTKZV6Dku3yN0ZJ/nDCQEaEKgFkJ2pmlqux8KxN6WUd0OAYbRNokM6c1Poj4LT8Zbqie
         L8fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2HC/AVySH17dcJ1eOjuqITZP6s+yGuGkZUMcpGJBHoA=;
        b=OedYxvaioEmNyULIxtLfvqWHnWjbnkgPh9WxsqTCqjkE8rjTlUCcciXENVeAMFEW8h
         p/+C5g/lewjd9neMrzDgtnpoGzx0N96ZmZL8apRTsTMMupYqvEh8rmAl+fFEs72BxtE2
         SA8fhLFzCrPdBbkxSh8v4nmeNASQrHCmTyUOf20zWhlTkAiPdiWMBHD1lNKMF/eR8ite
         od14EOaeoXdfjnKguOGn95hyNuKk6DzWJ5f0notqS90JZRjA0/nPwZYce2AHMFcJcAnw
         6XjvDQcQJsBkOQYg7xBjjHmQTRPxwz10VJ+OIZT6aIgUGMz/xlth+XdW+JXLNco8m9tI
         HSew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=T5RyWRDU;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l7si221675pgm.129.2019.02.13.12.17.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 12:17:17 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=T5RyWRDU;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=2HC/AVySH17dcJ1eOjuqITZP6s+yGuGkZUMcpGJBHoA=; b=T5RyWRDUQkXyAIUCElyhQ3Jhp
	bH/HvPWbtTW8d2AqknG8JEyVi9nmhcszo7/sALatw7nh9S3jgQpfbMIemIKv7j3kXoes3jQr4SqBF
	iJmHF/5SqtJAOFf0saSHLF2Y3M9gon++aqPvFAJKTxIyQWOV29L1yoIyLNJK9FgadABtwuA8shsXZ
	JVJIXPnAVX0eR3ORsMxcjEB66ktIn1UYYQRCCpWHnR7UT1BtMothiJhHmYTE4IEKZSgn1KCKZxMxF
	pCfHHxc0XBpmzsdj3Ee84P0oEuCHsUy1Gc2pPwAI4birJMpq2LJyspeyRWYvtDEDbZn1FkSUJy/Wg
	2/nd/jzGA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gu0y4-00038t-2d; Wed, 13 Feb 2019 20:17:16 +0000
Date: Wed, 13 Feb 2019 12:17:15 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Jan Kara <jack@suse.cz>
Cc: "Kirill A . Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hugh Dickins <hughd@google.com>,
	William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH v2] page cache: Store only head pages in i_pages
Message-ID: <20190213201715.GU12668@bombadil.infradead.org>
References: <20190212183454.26062-1-willy@infradead.org>
 <20190213144102.GA18351@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213144102.GA18351@quack2.suse.cz>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 03:41:02PM +0100, Jan Kara wrote:
> On Tue 12-02-19 10:34:54, Matthew Wilcox wrote:
> > Transparent Huge Pages are currently stored in i_pages as pointers to
> > consecutive subpages.  This patch changes that to storing consecutive
> > pointers to the head page in preparation for storing huge pages more
> > efficiently in i_pages.
> > 
> > Large parts of this are "inspired" by Kirill's patch
> > https://lore.kernel.org/lkml/20170126115819.58875-2-kirill.shutemov@linux.intel.com/
> > 
> > Signed-off-by: Matthew Wilcox <willy@infradead.org>
> 
> I like the idea!

Thanks!  It's a step towards reducing the overhead of huge pages in the
page cache from (on x86) 520 pointers to a mere 8.  Still not as good as
hugetlbfs, but I'm working on that too.

> > -		pages[ret] = page;
> > +		pages[ret] = find_subpage(page, xas.xa_index);
> >  		if (++ret == nr_pages) {
> >  			*start = page->index + 1;
> >  			goto out;
> >  		}
> 
> So this subtly changes the behavior because now we will be returning in
> '*start' a different index. So you should rather use 'pages[ret]->index'
> instead.

You're right, I made a mistake there.  However, seeing this:
https://lore.kernel.org/lkml/20190110030838.84446-1-yuzhao@google.com/

makes me think that I should be using xa_index + 1 there.

> Otherwise the patch looks good to me so feel free to add:
> 
> Acked-by: Jan Kara <jack@suse.cz>
> 
> after fixing these two.

Thanks!

