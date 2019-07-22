Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B57EC76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:37:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AE552229B
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:37:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AE552229B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01DF86B000E; Mon, 22 Jul 2019 05:37:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE9FF6B0010; Mon, 22 Jul 2019 05:37:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD9458E0001; Mon, 22 Jul 2019 05:37:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC8A6B000E
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:37:00 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id r4so19016874wrt.13
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 02:37:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mmZRiqitlzPnFP6lL8KXsx5adnNkpZSEncnm9dPbhN4=;
        b=J+Al96/gUNwl1lwy4+PoTCmWQmbCwdhIXnpBJw6FLziDICV1/C5p7XCZ1ijJMBZX0g
         i6hrrFnhwfwb2clvAIcYeQj6hSVS7vNcO7mi6CPHTnt3oZsjCjGTfF3EeyO6k3RPAShh
         f+Eb4k74NQ2uuxtzSoCJby20nboU6oWN07RVqWyw4kn2VdHhd/dxG7zrXZaO/oXhWe4q
         sVHsgXwE7MQz+MfspyPsspGGMgVNX9D/AeqaDGFhgqPSPh15mAQStcrLBk8Z76G/lDYD
         9sfTXt/d44wM19llEUrSFHiIrK7ItImocDVJHe18/7536Y8AXzqK5NE53qoTFK2RcmjO
         HS8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXNA/qTDxeLT60XaTQEQ1xikxNtWHhkQzd9nH49n+M5vP1uz6lS
	2tjJ2btdokJStHB1h6aulfHxEwef2Zran+LQPFE2UpDnnpFUDkFsLIGXBhEz3nnbgMZreYacA+R
	EtUUxfB2dlzWzLOH2WNVqD7lKuHuFQE7lhtYgAGNzd/M056yoqDcl1Ya29SiuiPN5hQ==
X-Received: by 2002:a5d:4602:: with SMTP id t2mr60975050wrq.340.1563788220192;
        Mon, 22 Jul 2019 02:37:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaXFmr2mjiUcsgaKtORsDIPgAutUhbkgNorFV+Getbp/kpLzZUdnQrAt5c+noJQKiSi135
X-Received: by 2002:a5d:4602:: with SMTP id t2mr60974986wrq.340.1563788219348;
        Mon, 22 Jul 2019 02:36:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563788219; cv=none;
        d=google.com; s=arc-20160816;
        b=EP3dV0q21blO6neTc/lcfqYo4tiV8fMsEeqejTNvsI/Qcj7/+S1935KV2W3PXSeh/P
         OwTSmvd3deSXCPyWxfK67LPfBpB3PjYHW6ka2MjsIVS4ey3YmAx8+TmpQy/poxO1XJZY
         D+kZaKjonI0HI6Q9BY8ouBUrYF67wRLUnQQVGcBn5KtOp7AbdHriaK6FWAD+BdQ//ait
         43D6hcLt22y7s44Kljoy5pEg26/udmZUYqUCuua85n8BxenheELjLOM62EvpKsNkkrS4
         YbWlgJhi88IDKwwmW5/dSALSQ9mwOIYa01KPgrg8NydfLKhO7Msh4Vmub31DMZq9Efc9
         z6KQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mmZRiqitlzPnFP6lL8KXsx5adnNkpZSEncnm9dPbhN4=;
        b=OaRNToaoI1IldllyinQBBlrOjreJfuPrebSF+9JnlsSCChDi1TYd+yGdMD0FsCCiFx
         6uF+klA1PcFhRQW7cq9fcLsOseJso6sEuL7iSpM5n2d+0TqzeIsTifodT60mihut1AoA
         R8lewMU3wWdOmGSumZcoVolVi48ElF6gCLR4sETQoRByjeFvxAgB6aLY+hBBLMyjlBA+
         xJtqTai5xPGVeM9a8OhRm4pTyMkmXiaHi0WYcuPXaSw4/TOudYMSlqTuBrnx2JpDwLA7
         dtvoNDWG7+CKEOxCoboRuhd9j7kOSd9B/27Y0jPsxKAIsOqP3KeLBprrXpIDP4/sTVUQ
         E4EQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id g133si29883049wmf.83.2019.07.22.02.36.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 02:36:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id F1AF268B20; Mon, 22 Jul 2019 11:36:56 +0200 (CEST)
Date: Mon, 22 Jul 2019 11:36:56 +0200
From: Christoph Hellwig <hch@lst.de>
To: Matthew Wilcox <willy@infradead.org>
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
Message-ID: <20190722093656.GD29538@lst.de>
References: <20190719192955.30462-1-rcampbell@nvidia.com> <20190719192955.30462-2-rcampbell@nvidia.com> <20190721160204.GB363@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190721160204.GB363@bombadil.infradead.org>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2019 at 09:02:04AM -0700, Matthew Wilcox wrote:
> On Fri, Jul 19, 2019 at 12:29:53PM -0700, Ralph Campbell wrote:
> > Struct page for ZONE_DEVICE private pages uses the page->mapping and
> > and page->index fields while the source anonymous pages are migrated to
> > device private memory. This is so rmap_walk() can find the page when
> > migrating the ZONE_DEVICE private page back to system memory.
> > ZONE_DEVICE pmem backed fsdax pages also use the page->mapping and
> > page->index fields when files are mapped into a process address space.
> > 
> > Restructure struct page and add comments to make this more clear.
> 
> NAK.  I just got rid of this kind of foolishness from struct page,
> and you're making it harder to understand, not easier.  The comments
> could be improved, but don't lay it out like this again.

This comes over pretty agressive.  Please explain how making the
layout match how the code actually is used vs the previous separation
that is actively misleading and confused multiple people is "foolishness".

