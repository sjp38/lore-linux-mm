Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B895C282D8
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 22:58:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 320A120857
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 22:58:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 320A120857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D81418E0002; Wed, 30 Jan 2019 17:58:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D09F18E0001; Wed, 30 Jan 2019 17:58:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAC2F8E0002; Wed, 30 Jan 2019 17:58:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A19C8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 17:58:57 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id f2so1437355qtg.14
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:58:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=SslJD5HCZnE33m8/+nrfokiGSZS9ZeZ9Mbb5q5yPKwc=;
        b=CLeUd+m8L9JpOittDfm6q2t/lyS8jDkcMcYEnuUCVEYm55w0LK5w5uCfITNrkgqba4
         IFG/TbrRmwq+hTP38uiDMTJcEnIyW5ximMyypsZcG/V2qhRvQZKTGSAtt5OJN+J0jKQd
         Bo2jV3EE6mEbcLoxkpC2toTYlDsWigCwCbIljrIFdlFqvxriLd3tA/XM0P9KTWzjkjlK
         u+aHo857YyQ1F98Nkjj5T52mjB1HBQdCqFpm0VAsvY/CVSCQD0uCP8XqtKb30Jii2k0t
         SkrWr4wcZUBgnoG8bZ/svtHpuq/3wsNfEdd1aDDZ37y71IdtPaH7kZemS1Ghu5Hms8g8
         oOPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukd8MmVefApct/Tm4Df1my3xEHQO3x/APlOUYJXmxwdoz5xaH14N
	y3vwyT+SZfx6y9Smx1MbYvqzmCq69MGSZgRNcb+HPWo1/JPjByLuBDh7z+rNEjOliRfDGDyTdL4
	vmyuycjPzaZNTqCoRMpchAp2R7FuACb014eVmcUzhUvlnrcxOTK6h51c4yui+dvhdwg==
X-Received: by 2002:ac8:ecf:: with SMTP id w15mr31712730qti.359.1548889137340;
        Wed, 30 Jan 2019 14:58:57 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4zHcarRoXrgwC8gMaHdMfTeKxW4a7IyBzN0uFF+0Wq1h1ygwtueQ62eSZq02EJnGI0T+sm
X-Received: by 2002:ac8:ecf:: with SMTP id w15mr31712705qti.359.1548889136720;
        Wed, 30 Jan 2019 14:58:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548889136; cv=none;
        d=google.com; s=arc-20160816;
        b=HWqXhA7isND6xl8Z+DUHhSo83yvXQxH5TYOKNYU+YBs5FPT8nNtCNZR/6ZOhAzx8dg
         k0CJU+dE6UDxI+NK+ickiHlkCpHLjWKYHRYY/Uki6doxHqc1lE6lIjwJB8oWAaZppFWd
         jXN1LACeTILT6vTHdpeXRT67r06On+eN47y5ldXTBmeiJJkSEDlbgDX9oBGY1Qc0de7a
         ZHOWf3w9AvZi6ulyzJ4zKYDc7I8F9TVb8GI7/6jO85EqsCh8sljL1pxTxn1llFbHMacU
         Qt1fFhes+/yQnO0S3oFTotyaj0w6D5zl5oIY4XBjZXhPX04GEHmRdURaUfCR8/RcZbJM
         nCqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=SslJD5HCZnE33m8/+nrfokiGSZS9ZeZ9Mbb5q5yPKwc=;
        b=E3tLzw8QZePCNC32gPKzW1evCNygEZGk7BurTDpOOSp23526B1oOFx3sB/ZmZu+p2d
         krancRKyc7AHB1pB9gtbElskA9sSL2QUj+ccevmzOsNtR3azYGje0T5ZPA8n0p3BrYjg
         jQG8fRdTl/v71YiAeRA9B6Uow76tHcvCCKdNBEjxDvylZ3j21nhMFxGo1speWWRIxVrb
         SzjNB/HPi6LOqvI9/vyhRQUD0UYtjhm1CdZ+CAGdAsWR9ruTZPsc+yLFjmj2tIcI72Ts
         s+BMielAxr5MpMGCjsoIo0rhbPc3FPBByk8DiudK0MSW9ETjbJBI18zGFElxnRM+pPd5
         WnBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i54si2021229qvh.107.2019.01.30.14.58.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 14:58:56 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 80C3086671;
	Wed, 30 Jan 2019 22:58:55 +0000 (UTC)
Received: from redhat.com (ovpn-126-0.rdu2.redhat.com [10.10.126.0])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id EACAF608E5;
	Wed, 30 Jan 2019 22:58:51 +0000 (UTC)
Date: Wed, 30 Jan 2019 17:58:50 -0500
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
Message-ID: <20190130225849.GJ5061@redhat.com>
References: <db873687-ff80-4758-0b9f-973f27db5335@deltatee.com>
 <20190130201114.GB17915@mellanox.com>
 <20190130204332.GF5061@redhat.com>
 <20190130204954.GI17080@mellanox.com>
 <20190130214525.GG5061@redhat.com>
 <20190130215600.GM17080@mellanox.com>
 <20190130223027.GH5061@redhat.com>
 <20190130223258.GB25486@mellanox.com>
 <20190130224705.GI5061@redhat.com>
 <20190130225148.GC25486@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190130225148.GC25486@mellanox.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Wed, 30 Jan 2019 22:58:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 10:51:55PM +0000, Jason Gunthorpe wrote:
> On Wed, Jan 30, 2019 at 05:47:05PM -0500, Jerome Glisse wrote:
> > On Wed, Jan 30, 2019 at 10:33:04PM +0000, Jason Gunthorpe wrote:
> > > On Wed, Jan 30, 2019 at 05:30:27PM -0500, Jerome Glisse wrote:
> > > 
> > > > > What is the problem in the HMM mirror that it needs this restriction?
> > > > 
> > > > No restriction at all here. I think i just wasn't understood.
> > > 
> > > Are you are talking about from the exporting side - where the thing
> > > creating the VMA can really only put one distinct object into it?
> > 
> > The message i was trying to get accross is that HMM mirror will
> > always succeed for everything* except for special vma ie mmap of
> > device file. For those it can only succeed if a p2p_map() call
> > succeed.
> > 
> > So any user of HMM mirror might to know why the mirroring fail ie
> > was it because something exceptional is happening ? Or is it because
> > i was trying to map a special vma which can be forbiden.
> > 
> > Hence why i assume that you might want to know about such p2p_map
> > failure at the time you create the umem odp object as it might be
> > some failure you might want to report differently and handle
> > differently. If you do not care about differentiating OOM or
> > exceptional failure from p2p_map failure than you have nothing to
> > worry about you will get the same error from HMM for both.
> 
> I think my hope here was that we could have some kind of 'trial'
> interface where very eary users can call
> 'hmm_mirror_is_maybe_supported(dev, user_ptr, len)' and get a failure
> indication.
> 
> We probably wouldn't call this on the full address space though

Yes we can do special wrapper around the general case that allow
caller to differentiate failure. So at creation you call the
special flavor and get proper distinction between error. Afterward
during normal operation any failure is just treated in a same way
no matter what is the reasons (munmap, mremap, mprotect, ...).


> Beyond that it is just inevitable there can be problems faulting if
> the memory map is messed with after MR is created.
> 
> And here again, I don't want to worry about any particular VMA
> boundaries..

You do not have to worry about boundaries HMM will return -EFAULT
if there is no valid vma behind the address you are trying to map
(or if the vma prot does not allow you to access it). So then you
can handle that failure just like you do now and as my ODP HMM
patch preserve.

Cheers,
Jérôme

