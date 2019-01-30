Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 190E8C282D9
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 15:43:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A05C321473
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 15:43:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A05C321473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 137798E0005; Wed, 30 Jan 2019 10:43:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C01C8E0001; Wed, 30 Jan 2019 10:43:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC9AF8E0005; Wed, 30 Jan 2019 10:43:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id C09E78E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:43:36 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id q3so29217596qtq.15
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 07:43:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=FiNXaRqJ1dbbuKe+tCceLGZfvgXru4OWvI53KLeFUU4=;
        b=HJiIZM+/zEpmOE4jak8MsTWe1RsuvEFVUudRZKoz6E2Vk6wStMLeYlgUJyKAVy39Qa
         c1S9PP+ntIGy0NmenL6Is76zmK9TFhBxoC79twXCfCTSg80goTW563dULf7Hl7GTUQlK
         0vRrQ9HYGCI0e1hGw+l6fM4S8XA2oTodN8DMlYlTaC6t/iC3+WA3yMtpaVEHEQUgbdJU
         w8y5GcFo0uxYOdoZ6B8uWNugmE9UvMiexvNxTBbZHeSlCWsyzNrHumbZnfVR7F95L+yW
         aheOEahi5lW+EUwaHC46wCeu7MZaLHWRTCDvFDWQaHlBdKLHcI5LNOhxUXE/zINyt+Bf
         H7Og==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukdZvKuOuz0diqD+fGQK2jj0FQxlTBvZcGnJpPULw6M3od3NXBWv
	q0o/MtEaZ+UQ92Zr5WlLDcvs/n9QOnenRj58np7VeGYHfhbFjcTOAqxCWzvVj6ZspDg6HxSb0je
	ZVgZRfLKKyNx9HRuN4U71/vEY6KlI1Ic0JYFcERz9Dc8yV/L+V8rXNVmOQs9fOFBzTw==
X-Received: by 2002:a37:492:: with SMTP id 140mr27684367qke.95.1548863016396;
        Wed, 30 Jan 2019 07:43:36 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6ZaupJtr5epklc/YQ8QZUxGDj2nFFPYsdDEQVnddRA7TgCp5AJiSmfiE4K3zpCaZaOa6jS
X-Received: by 2002:a37:492:: with SMTP id 140mr27684325qke.95.1548863015388;
        Wed, 30 Jan 2019 07:43:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548863015; cv=none;
        d=google.com; s=arc-20160816;
        b=SINWPixGC6NX+tAfF5c0MC31HKTvPoZQKksDj0DfAN9Uc0vbynCyLLIJreem22KGLU
         d0NQZ+Qk60khOjVE7aSeQB8d3Z1m53DZk93N/lGL+Ey5lH9mZKVt8lUMHvX+lLU/mSRD
         y8vln3zinXtqmLYWjN8iZB8j5WVvZXAIjxHhpnQiULN/ufV16La/u3eFM9jRhQUlGe4M
         C7tYZu9dMSaAYWVtSjH0cXtM0e2x7+4E+nKy4nLgWabD+33k9ijjAqpWUQNHOC8qus+/
         p0oJdyAz1406ajcH4jb+BtDsxPRrIl4kskplrbV1XP20Jnfstkn6gw+wOQxha42qWNo3
         M4Eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=FiNXaRqJ1dbbuKe+tCceLGZfvgXru4OWvI53KLeFUU4=;
        b=SYsh5mvS6v+v9F7VsU1v2I7qHC6UwD1tBtL9AG1UgIvR+9gSyzLxDuzVsrk3yP2V/S
         Ko+WndGn2afu/I24kVi59GJfKjQ1jn4Dwo4bNqipZHFjkr11dCeW5vTgL+ZXaLMBm0OD
         1V8ztP3olhKwO68qqdFKDI1XClj78HPeY87lOoLwxr8lwgT73hxjn1wGAD5HQLNzJpuA
         tL7Gq4wxc7q5msOQIzaq9o9NP8A3upfa3MSy5iUayo5G84Eqxt7Yo0mDq7529+C9Mzfw
         ZYU+JLodzBBiJi/h2wtH2mLrQ0Urx8ZVlBZkBQqL/c+5CEmVEGp2pyhpzTRcSLFuFgaQ
         CLNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w27si39126qvc.39.2019.01.30.07.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 07:43:35 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 28003368E6;
	Wed, 30 Jan 2019 15:43:34 +0000 (UTC)
Received: from redhat.com (ovpn-126-0.rdu2.redhat.com [10.10.126.0])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id CB9FC5D96F;
	Wed, 30 Jan 2019 15:43:31 +0000 (UTC)
Date: Wed, 30 Jan 2019 10:43:29 -0500
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
Message-ID: <20190130154328.GA3177@redhat.com>
References: <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com>
 <20190129193250.GK10108@mellanox.com>
 <20190129195055.GH3176@redhat.com>
 <20190129202429.GL10108@mellanox.com>
 <20190129204359.GM3176@redhat.com>
 <20190129224016.GD4713@mellanox.com>
 <20190130000805.GS3176@redhat.com>
 <20190130043020.GC30598@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190130043020.GC30598@mellanox.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 30 Jan 2019 15:43:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 04:30:27AM +0000, Jason Gunthorpe wrote:
> On Tue, Jan 29, 2019 at 07:08:06PM -0500, Jerome Glisse wrote:
> > On Tue, Jan 29, 2019 at 11:02:25PM +0000, Jason Gunthorpe wrote:
> > > On Tue, Jan 29, 2019 at 03:44:00PM -0500, Jerome Glisse wrote:
> > > 
> > > > > But this API doesn't seem to offer any control - I thought that
> > > > > control was all coming from the mm/hmm notifiers triggering p2p_unmaps?
> > > > 
> > > > The control is within the driver implementation of those callbacks. 
> > > 
> > > Seems like what you mean by control is 'the exporter gets to choose
> > > the physical address at the instant of map' - which seems reasonable
> > > for GPU.
> > > 
> > > 
> > > > will only allow p2p map to succeed for objects that have been tagged by the
> > > > userspace in some way ie the userspace application is in control of what
> > > > can be map to peer device.
> > > 
> > > I would have thought this means the VMA for the object is created
> > > without the map/unmap ops? Or are GPU objects and VMAs unrelated?
> > 
> > GPU object and VMA are unrelated in all open source GPU driver i am
> > somewhat familiar with (AMD, Intel, NVidia). You can create a GPU
> > object and never map it (and thus never have it associated with a
> > vma) and in fact this is very common. For graphic you usualy only
> > have hand full of the hundreds of GPU object your application have
> > mapped.
> 
> I mean the other way does every VMA with a p2p_map/unmap point to
> exactly one GPU object?
> 
> ie I'm surprised you say that p2p_map needs to have policy, I would
> have though the policy is applied when the VMA is created (ie objects
> that are not for p2p do not have p2p_map set), and even for GPU
> p2p_map should really only have to do with window allocation and pure
> 'can I even do p2p' type functionality.

All userspace API to enable p2p happens after object creation and in
some case they are mutable ie you can decide to no longer share the
object (userspace application decision). The BAR address space is a
resource from GPU driver point of view and thus from userspace point
of view. As such decissions that affect how it is use an what object
can use it, can change over application lifetime.

This is why i would like to allow kernel driver to apply any such
access policy, decided by the application on its object (on top of
which the kernel GPU driver can apply its own policy for GPU resource
sharing by forcing some object to main memory).


> 
> > Idea is that we can only ask exporter to be predictable and still allow
> > them to fail if things are really going bad.
> 
> I think hot unplug / PCI error recovery is one of the 'really going
> bad' cases..

GPU can hang and all data becomes _undefined_, it can also be suspended
to save power (think laptop with discret GPU for instance). GPU threads
can be kill ... So they are few cases i can think of where either you
want to kill the p2p mapping and make sure the importer is aware and
might have a change to report back through its own userspace API, or
at very least fallback to dummy pages. In some of the above cases, for
instance suspend, you just want to move thing around to allow to shut
down device memory.


> > I think i put it in the comment above the ops but in any cases i should
> > write something in documentation with example and thorough guideline.
> > Note that there won't be any mmu notifier to mmap of a device file
> > unless the device driver calls for it or there is a syscall like munmap
> > or mremap or mprotect well any syscall that work on vma.
> 
> This is something we might need to explore, does calling
> zap_vma_ptes() invoke enough notifiers that a MMU notifiers or HMM
> mirror consumer will release any p2p maps on that VMA?

Yes it does.

> 
> > If we ever want to support full pin then we might have to add a
> > flag so that GPU driver can refuse an importer that wants things
> > pin forever.
> 
> This would become interesting for VFIO and RDMA at least - I don't
> think VFIO has anything like SVA so it would want to import a p2p_map
> and indicate that it will not respond to MMU notifiers.
> 
> GPU can refuse, but maybe RDMA would allow it...

Ok i will add a flag field in next post. GPU could allow pin but they
would most likely use main memory for any such object, hence it is no
longer really p2p but at least both device look at the same data.

Cheers,
Jérôme

