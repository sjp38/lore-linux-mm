Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF10BC282C7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 00:08:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A353E2082C
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 00:08:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A353E2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F6108E0004; Tue, 29 Jan 2019 19:08:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37DB68E0001; Tue, 29 Jan 2019 19:08:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F7E58E0004; Tue, 29 Jan 2019 19:08:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id E3B9D8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 19:08:12 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id x125so23431103qka.17
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 16:08:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=8gNKBgbktTfcbrcGncM8LPRSd+TxOgwdRYY/7R/mIRs=;
        b=DHRfx2WbMs8lYlPnRzBQFCPXmRq2eCSJNSxgwjCP6M5oRy0lwQI9ic8dOw2nntsIEi
         pgWRCqxj7qDGqZCg9oZ8c0VB6CCjdxwuRpMZcPWvCmD1a9VsmtyQIF5pEqqY7e4QYQ4A
         Zqr2pV8R7vUnPTGoUOoZQA5DYl2bL0dyV0vGtLZ9O2IPXUw/6VhOPVXeAjP6CiW2NjkM
         xk17aHuP2k4lSNuoKG3tGpvvpgaZjJpJz5UTZkoqZo75c5DMw/3ZilOEDWe4YyOWk3Sb
         AQ0mUock4+pHozTv5ZXAxOkG5RatJWBGwK79dwu2yto8RndMKwcrObOBBE9m7gumIhLx
         yi5Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukcWBEBvqhupPONmIMCERUfaKlawcmjltSw9y4PQzsuyoYg9TABa
	ISqDFTXrHzwYywrxApuVkLLzpVdz6Bom5XeBzb4KjiXnfmjODI7oNk97h3QX37GXy3G/nt0VhKX
	+X25IauiIVi5rq+WDMaZuddqLMXzO4pe/XxtQkXE+8uz5TiTR027uMuF4x5E+YBzUrg==
X-Received: by 2002:ac8:f6f:: with SMTP id l44mr28795347qtk.158.1548806892637;
        Tue, 29 Jan 2019 16:08:12 -0800 (PST)
X-Google-Smtp-Source: ALg8bN688FW7jAmlge/KGWeWnXipN/a5RBXF7mDBI3Dm/UpmSmqisW8UsUWmfBvyjsrXKRUSRmPK
X-Received: by 2002:ac8:f6f:: with SMTP id l44mr28795312qtk.158.1548806891994;
        Tue, 29 Jan 2019 16:08:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548806891; cv=none;
        d=google.com; s=arc-20160816;
        b=sIvBfhpsGu/0E3bjALXCEbCbY8FVIi+WcUbEHLUld0nyhBYFXS9TuOb/uxjlgeoAuN
         4SMcr37FngE4wo04hUDQFK4sFm2XbgC/u1dzFitpymP1a40/Ie8VadQ5BD+BoyeRJvn4
         doZSlWLpv2kkK+fQ37dUJFQqoroouZY9ALMBFR638LdLfyifhwrIyC5KzZdh5n3BUYnQ
         WUFLXOUZlycWCFx78cHolSL+ZAqzVWaNxz8yEcVktb8v419YRDVZQaYTod0h4scSekk2
         aanl6ocCgJE81BiBN26GL06iHXMye/LeiuMIhLeHurD5+Cmg+QW1AXBTta2rf0aqBM41
         Puzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=8gNKBgbktTfcbrcGncM8LPRSd+TxOgwdRYY/7R/mIRs=;
        b=W1LBpKzhg0iDFLCTaaEh9bQ9pUD/jZKYNVWcq8QBf9tDGZ+PI5ToijxNbHL7H3J5yu
         q/iRj4+PRYoxFQKbjrEm1yn8RxjjSFhgCHECw4kadzTPtE+afU3O0N/2tUim+dZO/PrZ
         2oFohnI9cfDWlMzOg6sA2HSOjmE3NVW02GdXOozZbcvavGMf6Oe2xYXNpNRyVOGvDcD2
         qJ35gkg7BJ2NXxpI6bavrWNOUrj7gTVnVTFX7AitB5gvnoTgqM+252cgwBANJvU/0QAa
         fYyoZxjMI2fiREvXHawhzjKN3oWYu2TWFnvKV0mgav8BDmHs/n/gn4dzSPe2jNO3MKAC
         PpmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r32si5122191qvj.117.2019.01.29.16.08.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 16:08:11 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 98862BDD0;
	Wed, 30 Jan 2019 00:08:10 +0000 (UTC)
Received: from redhat.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3216E53;
	Wed, 30 Jan 2019 00:08:08 +0000 (UTC)
Date: Tue, 29 Jan 2019 19:08:06 -0500
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
Message-ID: <20190130000805.GS3176@redhat.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com>
 <20190129193250.GK10108@mellanox.com>
 <20190129195055.GH3176@redhat.com>
 <20190129202429.GL10108@mellanox.com>
 <20190129204359.GM3176@redhat.com>
 <20190129224016.GD4713@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190129224016.GD4713@mellanox.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 30 Jan 2019 00:08:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 11:02:25PM +0000, Jason Gunthorpe wrote:
> On Tue, Jan 29, 2019 at 03:44:00PM -0500, Jerome Glisse wrote:
> 
> > > But this API doesn't seem to offer any control - I thought that
> > > control was all coming from the mm/hmm notifiers triggering p2p_unmaps?
> > 
> > The control is within the driver implementation of those callbacks. 
> 
> Seems like what you mean by control is 'the exporter gets to choose
> the physical address at the instant of map' - which seems reasonable
> for GPU.
> 
> 
> > will only allow p2p map to succeed for objects that have been tagged by the
> > userspace in some way ie the userspace application is in control of what
> > can be map to peer device.
> 
> I would have thought this means the VMA for the object is created
> without the map/unmap ops? Or are GPU objects and VMAs unrelated?

GPU object and VMA are unrelated in all open source GPU driver i am
somewhat familiar with (AMD, Intel, NVidia). You can create a GPU
object and never map it (and thus never have it associated with a
vma) and in fact this is very common. For graphic you usualy only
have hand full of the hundreds of GPU object your application have
mapped.

The control for peer to peer can also be a mutable properties of the
object ie userspace do ioctl on the GPU driver which create an object;
Some times after the object is created the userspace do others ioctl
to allow to export the object to another specific device again this
result in ioctl to the device driver, those ioctl set flags and
update GPU object kernel structure with all the info.

In the meantime you have no control on when other driver might call
the vma p2p call backs. So you must have register the vma with
vm_operations that include the p2p_map and p2p_unmap. Those driver
function will check the object kernel structure each time they get
call and act accordingly.



> > For moving things around after a successful p2p_map yes the exporting
> > device have to call for instance zap_vma_ptes() or something
> > similar.
> 
> Okay, great, RDMA needs this flow for hotplug - we zap the VMA's when
> unplugging the PCI device and we can delay the PCI unplug completion
> until all the p2p_unmaps are called...
> 
> But in this case a future p2p_map will have to fail as the BAR no
> longer exists. How to handle this?

So the comment above the callback (i should write more thorough guideline
and documentation) state that export should/(must?) be predictable ie
if an importer device calls p2p_map() once on a vma and it does succeed
then if the same device calls again p2p_map() on the same vma and if the
vma is still valid (ie no unmap or does not correspond to a different
object ...) then the p2p_map() should/(must?) succeed.

The idea is that the importer would do a first call to p2p_map() when it
setup its own object, report failure to userspace if that fails. If it
does succeed then we should never have an issue next time we call p2p_map()
(after mapping being invalidated by mmu notifier for instance). So it will
succeed just like the first call (again assuming the vma is still valid).

Idea is that we can only ask exporter to be predictable and still allow
them to fail if things are really going bad.


> > > I would think that the importing driver can assume the BAR page is
> > > kept alive until it calls unmap (presumably triggered by notifiers)?
> > > 
> > > ie the exporting driver sees the BAR page as pinned until unmap.
> > 
> > The intention with this patchset is that it is not pin ie the importer
> > device _must_ abide by all mmu notifier invalidations and they can
> > happen at anytime. The importing device can however re-p2p_map the
> > same range after an invalidation.
> >
> > I would like to restrict this to importer that can invalidate for
> > now because i believe all the first device to use can support the
> > invalidation.
> 
> This seems reasonable (and sort of says importers not getting this
> from HMM need careful checking), was this in the comment above the
> ops?

I think i put it in the comment above the ops but in any cases i should
write something in documentation with example and thorough guideline.
Note that there won't be any mmu notifier to mmap of a device file
unless the device driver calls for it or there is a syscall like munmap
or mremap or mprotect well any syscall that work on vma.

So assuming the application is no doing something stupid, nor the
driver. Then the result of p2p_map can stay valid until the importer
is done and call p2p_unmap of its own free will. This is what i do
expect for this. But for GPU i would still like to allow GPU driver
to evict (and thus invalidate importer mapping) to main memory or
defragment their BAR address space if the GPU driver feels a pressing
need to do so.

If we ever want to support full pin then we might have to add a
flag so that GPU driver can refuse an importer that wants things
pin forever.

Cheers,
Jérôme

