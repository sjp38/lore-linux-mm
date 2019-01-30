Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1370C282D4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:02:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A398121473
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:02:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A398121473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 442468E0004; Wed, 30 Jan 2019 03:02:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F2738E0001; Wed, 30 Jan 2019 03:02:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 306F88E0004; Wed, 30 Jan 2019 03:02:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id CD6708E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:02:10 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id j30so8923270wre.16
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 00:02:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bSvzEOpTuQZUwQLSOSlYFpmxHnqbqpoLNfEkerIfslQ=;
        b=EW+pCGHM1MYwqfUQvxAYCbMnJfywycXmc4bNPn62QdyoVeCLQHg17YyvNMioobXsP2
         UENkWnNueKcAdcoyXMysB/nevOD+EnI5bN/d4JaROyVlRWfZ/yjArUvIsc9gYs5RINvK
         Q7ijsTg1xE3xk2Qr1YU0lrDB+u5Ngl4QfqiU0gKA2rCb0LIXtKq2E6yaTm4l/paWJ67+
         LqdoSIXmv+XnonAc8cjBT586ukwpkh7A1aB/ptOQEqmhUjXE387aik7v745x3gb5sdc4
         /pyUZRbM09MyGOBpx4IsQ7imo4fxYpGxvyhLafDT+1NSP0E54uWFLi/x3+7BQwXGQky4
         AumA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AJcUukeHevoC2jIzQLbyS7VHWMZNuIPjaBvxq9F+Ycg62uYnAY09DyYd
	K3N5TpIMyV9X05P128lFBlqpWdTwptgmHXNZzYlNdiDgHyfwXMB8+u5pADI4rQnf9zy2pu4pyta
	CsMcjcO43NFsFO8yF1BH0RMHebWfBzuZliWqlYbcN77i3j/AlTSKeWJOQ9qroE10yiQ==
X-Received: by 2002:a1c:4346:: with SMTP id q67mr25464557wma.114.1548835330313;
        Wed, 30 Jan 2019 00:02:10 -0800 (PST)
X-Google-Smtp-Source: ALg8bN560zrVod5boWlhdGeOc3GMa+0oMiPnimMeVmYtWWQogcIc3fzg9+2OjxV96m5dEfK7ehRt
X-Received: by 2002:a1c:4346:: with SMTP id q67mr25464478wma.114.1548835329427;
        Wed, 30 Jan 2019 00:02:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548835329; cv=none;
        d=google.com; s=arc-20160816;
        b=YsyGCtuLJExUP7NUWhcS3tfya5fHQIKsZxAlqr+QscGWgF9AEg8AJSvXB1Z3ac1+u4
         Ch0VxMXtinTEYByy+/YtDhKKLaYX/ugZKUKTOZNoaGahbLKyfODM147tN6O2BN+/a71N
         nKYStO9lW//5AaxmRNldkHthyToH4UotDJRK0X5GQifrcZ6vi/WDNyX7Sl3DyEXGuFW3
         kvnHZdleFNLj7ez9BbHYwRycVWyDXKX5bqg8nwsrolksWIBgoN7ikm9zUOpzGU2ynJXU
         h6f1Pa8UlQk1PmSuAoy2K5LRBeq0jjmGZtrbQEQHjDOAidozdGgFtK0KTDmRwuSDSCRe
         jNBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bSvzEOpTuQZUwQLSOSlYFpmxHnqbqpoLNfEkerIfslQ=;
        b=aBuSG/guPGORMb0Okd5LR0W7N2MLvMjvGL2J+h6xyskK9BwoUT6/TiEPnbBCoD4DtO
         1H8wL05v5d2PHZ5Xl70kEard5T6/kn6udGmSTGsCYFN0n8DNLE4IasByiBob5iwenvqy
         bRf+Nhq2nNq+7kntXzuRXz4296DC90cY387knEqyWo76FYu/eche2APoyWeToFRmf8UL
         JkHrK58HPVhzx2e7Vn3DzgeRG2Xr2DhcIeUtegu/J6ZqiCFjigYeR17GWe6UaQ6KvHHI
         Q/63C3BZ+ZWoyVv9u12jy7rfptXl670vtHn/LOKBe6E4/7p9/5cOkR9T4LOH9J4J0cZz
         3Ibg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id l17si890142wmi.103.2019.01.30.00.02.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 00:02:09 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id BF4D968CEC; Wed, 30 Jan 2019 09:02:08 +0100 (CET)
Date: Wed, 30 Jan 2019 09:02:08 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Logan Gunthorpe <logang@deltatee.com>,
	Jerome Glisse <jglisse@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Message-ID: <20190130080208.GC29665@lst.de>
References: <20190129174728.6430-1-jglisse@redhat.com> <20190129174728.6430-4-jglisse@redhat.com> <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com> <20190129191120.GE3176@redhat.com> <20190129193250.GK10108@mellanox.com> <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com> <20190129205827.GM10108@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129205827.GM10108@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 08:58:35PM +0000, Jason Gunthorpe wrote:
> On Tue, Jan 29, 2019 at 01:39:49PM -0700, Logan Gunthorpe wrote:
> 
> > implement the mapping. And I don't think we should have 'special' vma's
> > for this (though we may need something to ensure we don't get mapping
> > requests mixed with different types of pages...).
> 
> I think Jerome explained the point here is to have a 'special vma'
> rather than a 'special struct page' as, really, we don't need a
> struct page at all to make this work.
> 
> If I recall your earlier attempts at adding struct page for BAR
> memory, it ran aground on issues related to O_DIRECT/sgls, etc, etc.

Struct page is what makes O_DIRECT work, using sgls or biovecs, etc on
it work.  Without struct page none of the above can work at all.  That
is why we use struct page for backing BARs in the existing P2P code.
Not that I'm a particular fan of creating struct page for this device
memory, but without major invasive surgery to large parts of the kernel
it is the only way to make it work.

