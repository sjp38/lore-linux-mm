Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1009DC282C7
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:44:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA85E21874
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:44:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA85E21874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 723D08E0003; Tue, 29 Jan 2019 15:44:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D4B88E0001; Tue, 29 Jan 2019 15:44:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EC428E0003; Tue, 29 Jan 2019 15:44:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 357E78E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:44:08 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id m37so26089977qte.10
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:44:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Qm6F6LIQzbfAPKu+FJsQKTjSZW7u/O5X81/WBnpGURM=;
        b=e7Z2nI2GMSaTKK3MRX8XpHxKuo45DJqzoL2HItHnDBTWqUM7PDo1HuNGpRShxeFMYU
         87saTSh8nCRuXKkzUkXhnWvDFJ+IxWnrN54nks3JhsbV7UuACErZjAWB+MDTBXApwRKD
         mCQrO1386M4o2KLWKDGqX3N/J6vYhtvBLSizYa9dsHfA2O1HIPl/CJHHyZKw419tThmB
         WTtnGrGSGnTl783ckSS5XMQ1GT8xCE1Faj2p9ng2Q2L73y1DE16wyKubrAXEsZeUmBgD
         qe+YLQfHVdG73ttjFtdPvK/SLmEwy4q46mBZFeYhCTvqha3VHKyghCwvPQZPR9KmSIXQ
         B1fg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukfL0Jv0HzNHxb0fWLUc/XIx6bqlFPdohpJqvJt/hVXu1mT77/71
	hKecfujSTbWOJIk/Yg0gleCMSPMOlm+brkEAwiYoIbp4WvlbRny6MnG0VaaPxCBLGoIsg7DnOf2
	v4UlSDuIPy/BBHRh3LajegjgFXtKV9U9WrBGEwn2nK9Jt1tFg4iCsH3t5Nm0IENjXgA==
X-Received: by 2002:a0c:9292:: with SMTP id b18mr25924992qvb.187.1548794647977;
        Tue, 29 Jan 2019 12:44:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6NcJCRK1fZoXyktrtjMkfaph34gsoBS0XojAfltnGTJXZmYxJbW0bSnY7gaXv6W/cC8uuy
X-Received: by 2002:a0c:9292:: with SMTP id b18mr25924966qvb.187.1548794647310;
        Tue, 29 Jan 2019 12:44:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548794647; cv=none;
        d=google.com; s=arc-20160816;
        b=gKWW4oybjUZXlvEePHaOXsyt2QYSODTK84zmpXPfQSyUkYbEQGha6MC62cqDhwiHXM
         F9fEZYkS65J7TCvPl3hc3HQKZp8U9Y08wvX220A4T3hR6CA8fEBNcPm3YogwHjWS3iJA
         ma2fFWbdbiFIYxJAunK2FOhkLdyVx60kPsa/oTok7G4F17ovcepk8QAH4wzqNEwqauHl
         bDPghvxH1PKaSyVpBQhUNlVzJb3V2ijbzbqfmXP7Jk69iY9ali7R8OJVwp0v5IyNT218
         EiCFMyH5vS3yWvzpvJLN9Jf1CZxLHXhjQG50M+aifJbk9sqWUN2IsJP2k86+4rBh6fSD
         vdPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Qm6F6LIQzbfAPKu+FJsQKTjSZW7u/O5X81/WBnpGURM=;
        b=uvCdjwvvrtD+skT+5UACPQ+uoLYcVYCty39C+BEVxrLHLKYkCiXr1+sgP3UBLWJYau
         /jcLTe58Jnf6WjRmNhOZ1f2iUQbGtFvsVjwsND9uQpBJrpcV7hh7praWvhTYPmEjWLN2
         kDeLFoZy2zO06i8Z0I3MEM7ScXOk7JD2XkSrRTD5kNrnP6iofOqfka8qZtiXYHXOOk21
         CDvBabAI9HH6OzPBoqSUzK/unOw1NrlGh/3T8RpcfMbeQ6LSwmhK0OvTpGNQvU+lBkIc
         5WZVr6q4vv2qgVqfezpsPbaEeLWkj6yPfXmy8uefa9RF9Ue1ubXLelq6G4D2Ey16s1aG
         wUoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x14si5101721qts.71.2019.01.29.12.44.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 12:44:07 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0BCDF80503;
	Tue, 29 Jan 2019 20:44:05 +0000 (UTC)
Received: from redhat.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 598275F7C2;
	Tue, 29 Jan 2019 20:44:02 +0000 (UTC)
Date: Tue, 29 Jan 2019 15:44:00 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Logan Gunthorpe <logang@deltatee.com>,
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
Message-ID: <20190129204359.GM3176@redhat.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com>
 <20190129193250.GK10108@mellanox.com>
 <20190129195055.GH3176@redhat.com>
 <20190129202429.GL10108@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190129202429.GL10108@mellanox.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 29 Jan 2019 20:44:06 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 08:24:36PM +0000, Jason Gunthorpe wrote:
> On Tue, Jan 29, 2019 at 02:50:55PM -0500, Jerome Glisse wrote:
> 
> > GPU driver do want more control :) GPU driver are moving things around
> > all the time and they have more memory than bar space (on newer platform
> > AMD GPU do resize the bar but it is not the rule for all GPUs). So
> > GPU driver do actualy manage their BAR address space and they map and
> > unmap thing there. They can not allow someone to just pin stuff there
> > randomly or this would disrupt their regular work flow. Hence they need
> > control and they might implement threshold for instance if they have
> > more than N pages of bar space map for peer to peer then they can decide
> > to fall back to main memory for any new peer mapping.
> 
> But this API doesn't seem to offer any control - I thought that
> control was all coming from the mm/hmm notifiers triggering p2p_unmaps?

The control is within the driver implementation of those callbacks. So
driver implementation can refuse to map by returning an error on p2p_map
or it can decide to use main memory by migrating its object to main memory
and populating the dma address array with dma_page_map() of the main memory
pages. Driver like GPU can have policy on top of that for instance they
will only allow p2p map to succeed for objects that have been tagged by the
userspace in some way ie the userspace application is in control of what
can be map to peer device. This is needed for GPU driver as we do want
userspace involvement on what object are allowed to have p2p access and
also so that we can report to userspace when we are running out of BAR
addresses for this to work as intended (ie not falling back to main memory)
so that application can take appropriate actions (like decide what to
prioritize).

For moving things around after a successful p2p_map yes the exporting
device have to call for instance zap_vma_ptes() or something similar.
This will trigger notifier call and the importing device will invalidate
its mapping. Once it is invalidated then the exporting device can
point new call of p2p_map (for the same range) to new memory (obviously
the exporting device have to synchronize any concurrent call to p2p_map
with the invalidation).

> 
> I would think that the importing driver can assume the BAR page is
> kept alive until it calls unmap (presumably triggered by notifiers)?
> 
> ie the exporting driver sees the BAR page as pinned until unmap.

The intention with this patchset is that it is not pin ie the importer
device _must_ abide by all mmu notifier invalidations and they can
happen at anytime. The importing device can however re-p2p_map the
same range after an invalidation.

I would like to restrict this to importer that can invalidate for
now because i believe all the first device to use can support the
invalidation.

Also when using HMM private device memory we _can not_ pin virtual
address to device memory as otherwise CPU access would have to SIGBUS
or SEGFAULT and we do not want that. So this was also a motivation to
keep thing consistent for the importer for both cases.

Cheers,
Jérôme

