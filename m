Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3D5FC76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 11:08:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B29820821
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 11:08:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="E54nSq8Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B29820821
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C50B8E0001; Mon, 22 Jul 2019 07:08:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 975746B0008; Mon, 22 Jul 2019 07:08:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 864288E0001; Mon, 22 Jul 2019 07:08:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 50DCE6B0007
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 07:08:29 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 6so23647553pfi.6
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 04:08:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=yI6oJAOD8RitgYpGXV7mavr3OofMjIjiw6wkaelvwj4=;
        b=br6Jiv4EX2oU8jZNUZZUxP6mnPNKb7sACnUT8HPCEfb4UsSok2tux4VmEFz4zozFdb
         NpT7oe/RQOnF2cVeHRzbz5YG9TTQOPqo24ZuPBZnyw3DyJnJBRmcQs6DtVTIMsfArY6e
         f5LsGdmdSSuSaUGxcxtFGvIgZVaEFizUnS2rMe8NJNhZv/OtiusPcPXqhBewvJB9I0LN
         zUj6CoSgZIF4vGQuvOYuqEzrQoiEY7YRv9tgSY+gGWrm66iN13ALWlsDIVaMn5y6XHCJ
         jXvtqMJbO1cVI0t5+HrBb7i1fFj/iVtF1DCJ3UY2H66Aj0SJ2uraY1EzhDWmze75slCd
         MaRA==
X-Gm-Message-State: APjAAAUvpwGOrd2r7Ilm/f+jqWn+/d6NXLISSRGdpyC7p7TRgjvS9LOl
	JHfq6e6N9+VXdu1n9NretG3pRiO9LuiVLekYXi5bUVxgPDUk2cODUFWB/24tpa9u4bJ0Jt506TP
	VVomQ7snZ5oBCsqxLO86BX6aT0SJbVuoyze21ke7sSkE2HkX89JJWoldBM2xmoGlACg==
X-Received: by 2002:a63:3112:: with SMTP id x18mr70974000pgx.385.1563793708878;
        Mon, 22 Jul 2019 04:08:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBmwzc4OXzuwe6PO7G98tKt6vtRyTSQYZVO9aam0KAp3VIiNGCOvtKQg3PBQbMLZ72BLzM
X-Received: by 2002:a63:3112:: with SMTP id x18mr70973931pgx.385.1563793708011;
        Mon, 22 Jul 2019 04:08:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563793708; cv=none;
        d=google.com; s=arc-20160816;
        b=0qhOpGCfRjuLdFKd/kQ1AP5xTFOPZ99lJdzZ80jA/b/xqzWRCVPXDvvDaK9E5eKaXZ
         VepS8BIUKBjo4v6XqFuqGt7Q8nB3oJ9WoK5Quwc4r3HsvDn9yXcspEXvtia5Lnylq+kT
         CfiBkv43BBn+kSiuoqvwTJjdwpgiZHt4AQVoc7PzN/kwzMiBzObMKeTt/W6gQkDbB3ja
         p35UfI7e2SiIRwfcNdO+gWFmmpdyLFAGOHUurY23YNGOEoje/hQ1gndPPC52vI5NTqGT
         MtuQqppUKISQlYsncpl1JcR46zU4SPCbGigvGtZ6AsR0OpfouF65cVQKcHiroiHViwdR
         takw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=yI6oJAOD8RitgYpGXV7mavr3OofMjIjiw6wkaelvwj4=;
        b=leo1BTQmSVSsOV7JltVqK76ie1xC8nxXbICcJGfQrUpUHFbPAofiwJZba7C/udRKPe
         osOot5t7RDtWqj5PaixLsgT8mCtWL2cC05toF4r0wyY6Cy1QRWZEFTu/hC5c0MuP102J
         +w+grvpVyQ9ODTt4RD/9fTYBXYUgoKJGbkx03nYsfO1TVJjXQH5IzOKKs6QFx8qie6Dd
         IhcSyhOyKlkc8JbHlskCfDqCo2uJ+lLgQocv+N+60fpBEC07+LKFxnu2VKssVv0F5EoE
         SEtqAT8LF09q/UfFRn4jptyZU8NEMCdgOEePfuSTmkPQzCE3ysVzSLDtOe68cees9xCE
         RCSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=E54nSq8Q;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h9si10168332pju.77.2019.07.22.04.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 04:08:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=E54nSq8Q;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=yI6oJAOD8RitgYpGXV7mavr3OofMjIjiw6wkaelvwj4=; b=E54nSq8QjpaTk0rNt3VrHCO3G
	6kAbY17R0sFpqIBTjoU+pieKC/cHS4iMnbKh8gX3+6PGXNEtD32bKcxKbDVjDeGtIRJLxUcsyn1NN
	3GyiIL+bgEf3zPDOl5k5dcOBYibUyF1CspeuBVydmylD8cU8ReuFqydxCS9WcVgKrGAONFHqfRk3P
	3xKD3XQpielWtJY3iWAQHp8SPP086TCjGdfvdG64iqF/3g5gTd2JtJEO4Xq1DIXdHMHv9HoFO1LyB
	u/WSNkyznbiMOroeS+PsuvJ/+iYGhHxXZC4RdMUKrwj6QdG4S8hrisMyAv6rOmyJ2kVjY7TQY+G1M
	MkPPuOq3Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hpWB7-0002Eh-PH; Mon, 22 Jul 2019 11:08:25 +0000
Date: Mon, 22 Jul 2019 04:08:25 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Lai Jiangshan <jiangshanlai@gmail.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Pekka Enberg <penberg@kernel.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v2 1/3] mm: document zone device struct page field usage
Message-ID: <20190722110825.GD363@bombadil.infradead.org>
References: <20190719192955.30462-1-rcampbell@nvidia.com>
 <20190719192955.30462-2-rcampbell@nvidia.com>
 <20190721160204.GB363@bombadil.infradead.org>
 <20190722051345.GB6157@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722051345.GB6157@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2019 at 10:13:45PM -0700, Ira Weiny wrote:
> On Sun, Jul 21, 2019 at 09:02:04AM -0700, Matthew Wilcox wrote:
> > On Fri, Jul 19, 2019 at 12:29:53PM -0700, Ralph Campbell wrote:
> > > Struct page for ZONE_DEVICE private pages uses the page->mapping and
> > > and page->index fields while the source anonymous pages are migrated to
> > > device private memory. This is so rmap_walk() can find the page when
> > > migrating the ZONE_DEVICE private page back to system memory.
> > > ZONE_DEVICE pmem backed fsdax pages also use the page->mapping and
> > > page->index fields when files are mapped into a process address space.
> > > 
> > > Restructure struct page and add comments to make this more clear.
> > 
> > NAK.  I just got rid of this kind of foolishness from struct page,
> > and you're making it harder to understand, not easier.  The comments
> > could be improved, but don't lay it out like this again.
> 
> Was V1 of Ralphs patch ok?  It seemed ok to me.

Yes, v1 was fine.  This seems like a regression.

