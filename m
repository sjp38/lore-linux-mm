Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2D93C10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 12:15:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B56720857
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 12:15:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B56720857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38AA76B000E; Tue,  9 Apr 2019 08:15:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 339016B0010; Tue,  9 Apr 2019 08:15:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 250F26B0266; Tue,  9 Apr 2019 08:15:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id E25386B000E
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 08:15:21 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id b133so1560310wmg.7
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 05:15:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=InwDDaGERqM5PmC5EVaKLRH0+h0MTybOuaKikdO/eao=;
        b=WSvpn099NcJjZ/SDvILuqD/bArtmr2BU+3vS1drgnbl5gIRHSUsBBfz30ohgt4xbp/
         LgajljyBiuS5mPW/sIeZbLm52IeQEDdjKahDQ4ayvuxmyVFpEOCDd1yBIEsDERuQiZqr
         30jB0Bs6pQ6Lbab4krht3dTW4ioMmvRr9b3y+hPFnELx+nsiqa52eSzL/LDlaCSvSx4t
         n19rSh7FK3yYNrBSFJQre7XT46Of1LRTGQMyuSs6wZnm4IZfhha/eTtborIk6Ik8tqbi
         j/ueOdvl9ixPMqZzFSyeWwy7BEEoeIhHhCk/B1jFN+Dua9VxZbtPzaJCHame/G+ZyiR7
         orkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVTdSDZPoVdOpZB7FtkFbbfP/ELv9HCARXsw2PrUPKc8ELp9US7
	jcW7jLM/oNpEN86r3H3zJM7tRkdoRY2xrtoayrwa39QqQxGDWeMIvTvjMgzGZ+shYdaAq+zbWze
	bDz3rbkwQxJ1t06R8vBD1oezaaG5MjAQVAry6rIhndbWk8JTu1bT9mo0jwyau5xnAqQ==
X-Received: by 2002:a05:6000:1292:: with SMTP id f18mr21887502wrx.115.1554812121412;
        Tue, 09 Apr 2019 05:15:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+trbPtw56UZN5ITN+jvIkmMRIZRvKKiTMhu9XaUKoZ2lP7IJz5gCGDFxwr081+ACohzya
X-Received: by 2002:a05:6000:1292:: with SMTP id f18mr21887461wrx.115.1554812120631;
        Tue, 09 Apr 2019 05:15:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554812120; cv=none;
        d=google.com; s=arc-20160816;
        b=CcZXkzJSDroUnctYUIRVnPjrnMiFmLRcXDUX5wZ6ISHHrzi1SN9Yi+CT9/zKNYj1W1
         YGqKwj7PxHYQIfpMNxkCpXrQlg3W67p1ecNt2Y/eGFyShOvuCRrCrqwY36N+tNelVPQr
         y789KGRs1gdK7GugN8bM9rmQxFE8vHGGCx2m06z3nBXumRL76xr4pKCiwp2n+JP3xsVS
         SXmZV2xwqZQlL/PfqG8vEpLIKVLQJnmrS2LG5gEh7R2v2AgPRnRQhoWYs1ZzZxK09XJD
         kHV9XCDf+nmXihMUiwqTdmLMrnybmLm32oDSTJ70DFaHvCJNBseACvamoUrk6F3FsVG9
         rv9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=InwDDaGERqM5PmC5EVaKLRH0+h0MTybOuaKikdO/eao=;
        b=maHvO1OMtF/kGT4tbCNLkulJ1X7KjPQIzqBAqXFDo4xDKK5iVLuPzAGq7SgBvDBOAx
         pEOGClfxGfYbyTMPiJrCHZb+KylsvMBYctLQqmSPlE9r3RusZXMbAx0Fopi7rTldvMLd
         l10Pit0hOSJdtElRZ4HRkdBgyvYlfufboQaXvhaZqbVCydfp2zv70u8cM6fi80UTmiqH
         YviLE5xPgN47KweVV6O9pWjjNlhsu5vBU4TKgVNAko2OnoKnCrLZyZbYHePo/Nn7JcEX
         LES50U5R5gbof3HnkZEJMZwOfzh88Y/0X6U0c1KmbXOhcFu7uT99Jg305l5dJ7eBxiTx
         QxFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id w4si21192104wrp.127.2019.04.09.05.15.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 05:15:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 3AFA168B02; Tue,  9 Apr 2019 14:15:09 +0200 (CEST)
Date: Tue, 9 Apr 2019 14:15:09 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jan Kara <jack@suse.cz>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
	Christoph Hellwig <hch@lst.de>,
	cluster-devel <cluster-devel@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org
Subject: Re: gfs2 iomap dealock, IOMAP_F_UNBALANCED
Message-ID: <20190409121508.GA9532@lst.de>
References: <20190321131304.21618-1-agruenba@redhat.com> <20190328165104.GA21552@lst.de> <CAHc6FU49oBdo8mAq7hb1greR+B1C_Fpy5JU7RBHfRYACt1S4wA@mail.gmail.com> <20190407073213.GA9509@lst.de> <CAHc6FU7kgm4OyrY-KRb8H2w6LDrWDSJ2p=UgZeeJ8YrHynKU2w@mail.gmail.com> <20190408134405.GA15023@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190408134405.GA15023@quack2.suse.cz>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 08, 2019 at 03:44:05PM +0200, Jan Kara wrote:
> > We won't be able to do a log flush while another transaction is
> > active, but that's what's needed to clean dirty pages. iomap doesn't
> > allow us to put the block allocation into a separate transaction from
> > the page writes; for that, the opposite to the page_done hook would
> > probably be needed.
> 
> I agree that a ->page_prepare() hook would be probably the cleanest
> solution for this.

That doesn't sound too bad to me.

