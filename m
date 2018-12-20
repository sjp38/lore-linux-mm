Return-Path: <SRS0=PcJq=O5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BE91C43612
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 16:54:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E82D0218C3
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 16:54:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E82D0218C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C6AF8E0003; Thu, 20 Dec 2018 11:54:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9771B8E0001; Thu, 20 Dec 2018 11:54:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83E578E0003; Thu, 20 Dec 2018 11:54:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 536E08E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:54:39 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id p24so2499386qtl.2
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:54:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=cna/gLZl2qw+KgHdi13OSNyF5RUMDhiX5TUU4T5oeE4=;
        b=PJKHu2sfJO7lV2ZG0RE4mE9CZNs9I1nCDxLm9peDSTwMFaBOqmZGKxsx6GkzrjCH+H
         aFxrMGsaDk6s3umRjtbz1/aWYUtmDYo0MdJx1egXPQfl3Ae/2KvzznTlSrJVdxUl75pA
         0yluLTpSAEb0WFLmqOtChp+8jnOWz0Szn4alBUeih/zGRD+C0kMsDKj2JFs+lsQR2NwN
         uFhbNNOvZVohyJQSAdUsIRZFclFnCSkQSqU1K1pQnACodfe07+mLyeULO23yjjgzk6UM
         9shJcRjqsFaEbknLT5u5gzi3qLaLZaXeeaeV2+KArVnBRhPE4yafoCKodhdBNnnTbgYT
         tKmQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AA+aEWZq0da5vaeOpx4o87+hh8HOlSwncvrjufzhGXYvEYkObFuqDTZw
	4OSr62WYLv0z8mzvha4y//CYxYXDfgawAkbOfY56DeMr/2+jRcAlG3GUVBlA1nd3Yt4lB/yDZDQ
	q7Z9QCuBxonz5gVSGx6c2n3lwCpsm3NRd2ilMsMAGjiqcyVsz6JRUxCba1x7YitAbvw==
X-Received: by 2002:a37:2d82:: with SMTP id t124mr11660998qkh.189.1545324879090;
        Thu, 20 Dec 2018 08:54:39 -0800 (PST)
X-Google-Smtp-Source: AFSGD/WTTIiJQAMaVsgYTtGbZNFHfHa7bs6N5mwRU6n0q3FYzSpZ5TyaSydN19aoaVEMGE+I/mW3
X-Received: by 2002:a37:2d82:: with SMTP id t124mr11660958qkh.189.1545324878362;
        Thu, 20 Dec 2018 08:54:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545324878; cv=none;
        d=google.com; s=arc-20160816;
        b=MzIP3AIwmBziDq3PAvdf7wtdM2iVKG4V1JpHW31k57v865ZK+J9pRlo7bra2ZfwISf
         ncsVJ0a3GMyRnbwVw7gnaPgxY8a+Q1/ap87afCyW9GuS5E0qBIQadQC+jT9yexp/UQwZ
         G/El4RVMZebWvbj/nhJ5cu064a+usb6O1UOMoq/iO/MhHeg9Y1ot2D+zBBVBO07TxN8D
         9AluFl57/q+K1NktDuNlwKKLDbJBfFFBez0EVTAbkxVp39ELEcdHn+g8FVoPzO7LwI3Y
         BXhLK8cQR7JXdRXlFzIuKui9JUlj6x5C5POSMjE2xXI9/ZhU2deqdCdwaCLhptYziChj
         tx0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=cna/gLZl2qw+KgHdi13OSNyF5RUMDhiX5TUU4T5oeE4=;
        b=Bli0qdYjUPTUFi/G1OxzrJ0VGnSVOpQsOSOlLZXnW0oAqnY1xOpYbqltRc/9RkD0b5
         amqHwXRaLVSZNXRFGvSpXEyVELBh9Q56OkzcFnou0NognJ1EFf0MPTAAutxUIFk0/g7G
         F0cumdYn9akZPeJr6NpQYozXkeNUffGzmVGOXGoYHz6Eym7LfXmFdd1KKqZ7Ud0srRcG
         rjdBxwl+XpQixAHho8ljNLxtXnxpId01e9+/fOLsfza8qbE8PtdAk6PgzS5VAiLZSDwR
         MUykncr6M29CoESw+ChWZjUwOhq4DuzIArYY8Q2SZ7yptPeoffcHlUrjo+tHw4hIbKC9
         bboA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n189si2334496qkc.170.2018.12.20.08.54.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 08:54:38 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 296A4C0A1984;
	Thu, 20 Dec 2018 16:54:37 +0000 (UTC)
Received: from redhat.com (ovpn-123-95.rdu2.redhat.com [10.10.123.95])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C67D226FDC;
	Thu, 20 Dec 2018 16:54:34 +0000 (UTC)
Date: Thu, 20 Dec 2018 11:54:32 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	John Hubbard <jhubbard@nvidia.com>,
	Matthew Wilcox <willy@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	John Hubbard <john.hubbard@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, tom@talpey.com,
	Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	"Dalessandro, Dennis" <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com,
	rcampbell@nvidia.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181220165432.GD3963@redhat.com>
References: <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
 <20181218103306.GC18032@quack2.suse.cz>
 <20181218234254.GC31274@dastard>
 <20181219030329.GI21992@ziepe.ca>
 <20181219102825.GN6311@dastard>
 <20181219113540.GC18345@quack2.suse.cz>
 <20181219223312.GP6311@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181219223312.GP6311@dastard>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 20 Dec 2018 16:54:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181220165432.hKItALefxH_pi-N9xtvcsI9wnF2hwn1TxJ8GvHwBxw4@z>

On Thu, Dec 20, 2018 at 09:33:12AM +1100, Dave Chinner wrote:
> On Wed, Dec 19, 2018 at 12:35:40PM +0100, Jan Kara wrote:
> > On Wed 19-12-18 21:28:25, Dave Chinner wrote:
> > > On Tue, Dec 18, 2018 at 08:03:29PM -0700, Jason Gunthorpe wrote:
> > > > On Wed, Dec 19, 2018 at 10:42:54AM +1100, Dave Chinner wrote:
> > > > 
> > > > > Essentially, what we are talking about is how to handle broken
> > > > > hardware. I say we should just brun it with napalm and thermite
> > > > > (i.e. taint the kernel with "unsupportable hardware") and force
> > > > > wait_for_stable_page() to trigger when there are GUP mappings if
> > > > > the underlying storage doesn't already require it.
> > > > 
> > > > If you want to ban O_DIRECT/etc from writing to file backed pages,
> > > > then just do it.
> > > 
> > > O_DIRECT IO *isn't the problem*.
> > 
> > That is not true. O_DIRECT IO is a problem. In some aspects it is easier
> > than the problem with RDMA but currently O_DIRECT IO can crash your machine
> > or corrupt data the same way RDMA can.
> 
> It's not O_DIRECT - it's a ""transient page pin". Yes, there are
> problems with that right now, but as we've discussed the issues can
> be avoided by:
> 
> 	a) stable pages always blocking in ->page_mkwrite;
> 	b) blocking in write_cache_pages() on an elevated map count
> 	when WB_SYNC_ALL is set; and
> 	c) blocking in truncate_pagecache() on an elevated map
> 	count.
> 
> That prevents:
> 	a) gup pinning a page that is currently under writeback and
> 	modifying it while IO is in flight;
> 	b) a dirty page being written back while it is pinned by
> 	GUP, thereby turning it clean before the gup reference calls
> 	set_page_dirty() on DMA completion; and
> 	c) truncate/hole punch for pulling the page out from under
> 	the gup operation that is ongoing.
> 
> This is an adequate solution for a short term transient pins. It
> doesn't break fsync(), it doesn't change how truncate works and it
> fixes the problem where a mapped file is the buffer for an O_DIRECT
> IO rather than the open fd and that buffer file gets truncated.
> IOWs, transient pins (and hence O_DIRECT) is not really the problem
> here.
> 
> The problem with this is that blocking on elevated map count does
> not work for long term pins (i.e. gup_longterm()) which are defined
> as:
> 
>  * "longterm" == userspace controlled elevated page count lifetime.
>  * Contrast this to iov_iter_get_pages() usages which are transient.
> 
> It's the "userspace controlled" part of the long term gup pin that
> is the problem we need to solve. If we treat them the same as a
> transient pin, then this leads to fsync() and truncate either
> blocking for a long time waiting for userspace to drop it's gup
> reference, or having to be failed with something like EBUSY or
> EAGAIN.
> 
> This is the problem revokable file layout leases solve. The NFS
> server is already using this for revoking delegations from remote
> clients. Userspace holding long term GUP references is essentially
> the same thing - it's a delegation of file ownership to userspace
> that the filesystem must be able to revoke when it needs to run
> internal and/or 3rd-party requested operations on that delegated
> file.
> 
> If the hardware supports page faults, then we can further optimise
> the long term pin case to relax stable page requirements and allow
> page cleaning to occur while there are long term pins. In this case,
> the hardware will write-fault the clean pages appropriately before
> DMA is initiated, and hence avoid the need for data integrity
> operations like fsync() to trigger lease revocation. However,
> truncate/hole punch still requires lease revocation to work sanely,
> especially when we consider DAX *must* ensure there are no remaining
> references to the physical pmem page after the space has been freed.

truncate does not requires lease recovations for faulting hardware,
truncate will trigger a mmu notifier callback which will invalidate
the hardware page table. On next access the hardware will fault and
this will turn into a regular page fault from kernel point of view.

So truncate/reflink and all fs expectation for faulting hardware do
hold. It is exactly as the CPU page table. So if CPU page table is
properly updated then so will be the hardware one.

Note that such hardware also abive by munmap() so hardware mapping
does not outlive vma.


Cheers,
Jérôme

