Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B335FC282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:44:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D1B020882
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:44:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D1B020882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 027F28E0002; Tue, 29 Jan 2019 14:44:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F18808E0001; Tue, 29 Jan 2019 14:44:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E07D48E0002; Tue, 29 Jan 2019 14:44:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id B70208E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:44:26 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id m37so25883165qte.10
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:44:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=nQkS3sGBWmLslZw4oFu7yWrDIic6QlifppELyWfZ3X4=;
        b=CskIPs1CA8vbkDFupSThsx5O30XZOrIYqDEuLZk1kUZ/VVOSSNi0TP/ESJ0zDHKr0R
         MfmUS/ivT1A1zBdz2VUG9IuQGkWC+T9fC7tlpbq1XubykTwS9E30SYLUqChDSymDBe3H
         C6k+u46pYut/5HR6hjGB/f1XT0/PqsSW+3lZsYWeUzwQ5JX8raQDPwww0f6sdcLgq6AE
         XafB6MHgxxbUe5exLVaMLoACCfnlBxeNhVE9zNBbLqJx54u769WbK0c6t4Lbj+E73+G2
         7ts2469zW2rhgcfsgXR28GEsZzo9iB6u5AbcaVgOPtpwRMtr0H5rQ0eTzmdreiP9jS7b
         MGDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukdLSKI0YDyT3tZwwJ124W1g0ReDdzBFJ//72D4ZwGNrWxg/KOC8
	bi64odzdTIx907f6V9116GMwCV1Lmvk2ohvrD7Lgon3GUmgtmUYNwTfTKT040sT2qEVJ9tYy/F9
	t+I/b6xnOVpaPA26aow+3SRTsPPiFyit9NPsyrT5tzQRVSFK7ajHf4nHO2cjBGs64vA==
X-Received: by 2002:a05:620a:149c:: with SMTP id w28mr23370080qkj.321.1548791066467;
        Tue, 29 Jan 2019 11:44:26 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6h/eporeNrdjwxu6CmmbLR9D9dGVwXW0I4oU2M4oAaypSaOpxI5lMiZVwRPgnmso0zXvxr
X-Received: by 2002:a05:620a:149c:: with SMTP id w28mr23370043qkj.321.1548791065656;
        Tue, 29 Jan 2019 11:44:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548791065; cv=none;
        d=google.com; s=arc-20160816;
        b=ePwNxcMN8Y/6yCzBLK5uywYDlmsjMgkvuGmvbBFQhNNocvZC61Jz7PUp0HjpB8QWOe
         PMTrGt6qL2n8yktnouPybMTXzev+EjM2g2fKKkKRnAkvXSHhCDhB0ThMwSdyLMcooji7
         04+y8o5FQZZbbK9kzX/vVPW7JGSMt33Y3rM2KE1RzZ0Iw1P9+Om7m7rMVr4q1UhEANzn
         gMqdSYzhnffCPdEiPvvjdgTu967uKnyxrmfIpOaV7z7zzHmtvQy7SjR4AiZHKAPQ/KcU
         hYMbI9P+5Uhzq2+Jev8eEvVLCsEe7pxsYg7kM0Y77M1OgxF/6iLpO7w8Aa8HLprZhtQj
         Filg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=nQkS3sGBWmLslZw4oFu7yWrDIic6QlifppELyWfZ3X4=;
        b=rBXcQ876BHdvXYNQJOqQCkxTg6grdJ3gddEWtAPjBXXRaP3g/nIaBZLs3BgvSKNTMG
         xvfgFFFNQ6wySvgWoKzp5IcX+pPJYKHAhR8c0T9ek3jbm+FofzaTbQkuxoajfxPj/wYs
         tVcjNC1GFfPjDcdtpbWelYYplez2xQItt8k1yx8NT5FxiHjXxmOMuwueufGhwE7n9/CG
         0IIbJw9ffXNGrSY1lPga+zk+K6Dw3h0z2fV94f6xEpGKowVHx3wsqUPIg8mxbPY07edN
         5OHG4j0ZUxsgUhS2WqyLI21iL2Dxho8/w/1CVik65xQhZ/uVM0yFVVCDmyRTAofrQoKu
         ATrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n16si1814663qtr.77.2019.01.29.11.44.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 11:44:25 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3F7F0C002966;
	Tue, 29 Jan 2019 19:44:24 +0000 (UTC)
Received: from redhat.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 0624880D1;
	Tue, 29 Jan 2019 19:44:20 +0000 (UTC)
Date: Tue, 29 Jan 2019 14:44:19 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>, linux-pci@vger.kernel.org,
	dri-devel@lists.freedesktop.org, Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
	iommu@lists.linux-foundation.org
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Message-ID: <20190129194418.GG3176@redhat.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com>
 <c2c02af7-1d6f-e54f-c7fb-99c5b7776014@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c2c02af7-1d6f-e54f-c7fb-99c5b7776014@deltatee.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 29 Jan 2019 19:44:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 12:24:04PM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2019-01-29 12:11 p.m., Jerome Glisse wrote:
> > On Tue, Jan 29, 2019 at 11:36:29AM -0700, Logan Gunthorpe wrote:
> >>
> >>
> >> On 2019-01-29 10:47 a.m., jglisse@redhat.com wrote:
> >>
> >>> +	/*
> >>> +	 * Optional for device driver that want to allow peer to peer (p2p)
> >>> +	 * mapping of their vma (which can be back by some device memory) to
> >>> +	 * another device.
> >>> +	 *
> >>> +	 * Note that the exporting device driver might not have map anything
> >>> +	 * inside the vma for the CPU but might still want to allow a peer
> >>> +	 * device to access the range of memory corresponding to a range in
> >>> +	 * that vma.
> >>> +	 *
> >>> +	 * FOR PREDICTABILITY IF DRIVER SUCCESSFULY MAP A RANGE ONCE FOR A
> >>> +	 * DEVICE THEN FURTHER MAPPING OF THE SAME IF THE VMA IS STILL VALID
> >>> +	 * SHOULD ALSO BE SUCCESSFUL. Following this rule allow the importing
> >>> +	 * device to map once during setup and report any failure at that time
> >>> +	 * to the userspace. Further mapping of the same range might happen
> >>> +	 * after mmu notifier invalidation over the range. The exporting device
> >>> +	 * can use this to move things around (defrag BAR space for instance)
> >>> +	 * or do other similar task.
> >>> +	 *
> >>> +	 * IMPORTER MUST OBEY mmu_notifier NOTIFICATION AND CALL p2p_unmap()
> >>> +	 * WHEN A NOTIFIER IS CALL FOR THE RANGE ! THIS CAN HAPPEN AT ANY
> >>> +	 * POINT IN TIME WITH NO LOCK HELD.
> >>> +	 *
> >>> +	 * In below function, the device argument is the importing device,
> >>> +	 * the exporting device is the device to which the vma belongs.
> >>> +	 */
> >>> +	long (*p2p_map)(struct vm_area_struct *vma,
> >>> +			struct device *device,
> >>> +			unsigned long start,
> >>> +			unsigned long end,
> >>> +			dma_addr_t *pa,
> >>> +			bool write);
> >>> +	long (*p2p_unmap)(struct vm_area_struct *vma,
> >>> +			  struct device *device,
> >>> +			  unsigned long start,
> >>> +			  unsigned long end,
> >>> +			  dma_addr_t *pa);
> >>
> >> I don't understand why we need new p2p_[un]map function pointers for
> >> this. In subsequent patches, they never appear to be set anywhere and
> >> are only called by the HMM code. I'd have expected it to be called by
> >> some core VMA code and set by HMM as that's what vm_operations_struct is
> >> for.
> >>
> >> But the code as all very confusing, hard to follow and seems to be
> >> missing significant chunks. So I'm not really sure what is going on.
> > 
> > It is set by device driver when userspace do mmap(fd) where fd comes
> > from open("/dev/somedevicefile"). So it is set by device driver. HMM
> > has nothing to do with this. It must be set by device driver mmap
> > call back (mmap callback of struct file_operations). For this patch
> > you can completely ignore all the HMM patches. Maybe posting this as
> > 2 separate patchset would make it clearer.
> > 
> > For instance see [1] for how a non HMM driver can export its memory
> > by just setting those callback. Note that a proper implementation of
> > this should also include some kind of driver policy on what to allow
> > to map and what to not allow ... All this is driver specific in any
> > way.
> 
> I'd suggest [1] should be a part of the patchset so we can actually see
> a user of the stuff you're adding.

I did not wanted to clutter patchset with device driver specific usage
of this. As the API can be reason about in abstract way.

> 
> But it still doesn't explain everything as without the HMM code nothing
> calls the new vm_ops. And there's still no callers for the p2p_test
> functions you added. And I still don't understand why we need the new
> vm_ops or who calls them and when. Why can't drivers use the existing
> 'fault' vm_op and call a new helper function to map p2p when appropriate
> or a different helper function to map a large range in its mmap
> operation? Just like regular mmap code...

HMM code is just one user, if you have a driver that use HMM mirror
then your driver get support for this for free. If you do not want to
use HMM then you can directly call this in your driver.

The flow is, device driver want to setup some mapping for a range of
virtual address [va_start, va_end]:
    1 - Lookup vma for the range
    2 - If vma is regular vma (not an mmap of a file) then use GUP
        If vma is a mmap of a file and they are p2p_map call back
        then call p2p_map()
    3 - Use either the result of GUP or p2p_map() to program the
        device

The p2p test function is use by device driver implementing the call
back for instance see:

https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-p2p&id=401a567696eafb1d4faf7054ab0d7c3a16a5ef06

The vm_fault callback is not suited because here we are mapping to
another device so this will need special handling, someone must have
both device struct pointer in end and someone must be allow to make
decission on what to allow and what not to allow.

Moreover exporting driver like GPU driver might have complex policy
in place for which they will only allow export of some memory to a
peer device but not other.

In the end it means that it easier and simpler to add new call back
specificaly for that, so the intention is clear to both the caller
and the callee. The exporting device can then do the proper check
using the core helper (ie checking that the device can actually peer
to each other) and if that works it can then decide wether or not
it wants to allow this other device to access its memory or if it
prefer to use main memory for this.

To add this to the fault callback we would need to define a bunch
of new flags, setup fake page table so that we can populate pte and
then have the importing device re-interpret everything specialy
because it comes from another device. It would look ugly and it
would need to modify bunch of core mm code.

Note that this callback solution also allow an exporting device to
allow peer access while CPU can not access the memory ie the pte
entry for the range are pte_none.

Cheers,
Jérôme

