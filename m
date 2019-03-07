Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A710AC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 19:17:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6832120449
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 19:17:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6832120449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B5F28E0005; Thu,  7 Mar 2019 14:17:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 065918E0002; Thu,  7 Mar 2019 14:17:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E70368E0005; Thu,  7 Mar 2019 14:17:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id B91168E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 14:17:29 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id a11so13937751qkk.10
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 11:17:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=FFop6gRw3zlL63ls0haN7Gcrf176Q4z+n3NvtK6rzgU=;
        b=f2Dmti2GQBAueoqWaQfaHVJp8EYQa6deVFEFMIKq3Xol3rpSRDdnFCT5eEGidw9BlK
         z8crUq3snyFnZXIvcdyF7NTn2ZkYOeoUUvWc42ahuhZwI5U1GXksHFolHrHM0lAyBJhG
         DPs3MfaW2QpucRoojGEoWfU8RSX4Xuf+LtF/ndoJfLduyCC6tGsgStR11KivleCzLf+O
         NrQrJxippKNXY766ScUku7baA920iwnYJjg7cM9VTA/I+LX8PC9fHUnX1Vt4U+qUaNP0
         cizMi4BIb5OW3XGazOhTthRnC4IwAuNwNA+uW3lSXuZgB402mNXtkXd+tuLEAQEdHVu+
         qPlQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUu3nwINzRa7xyqrVH2vCpr9GWTTZZFTpRcNJSL+A6MZJwT9Pks
	x1TOvrBRZqULtHyDZHDtb3jgbZnARMGo4zqQl2Ty6ERD9FVGm3GZ9RGForeoufkHWkgEEi/04jU
	7C62G/2W0H6XrUHXn2LgMEsIv1UWUVG5mvRV/4XaUcsaFFVRE2ipqHGJgJSOA5/mfkA==
X-Received: by 2002:a37:61d3:: with SMTP id v202mr11078426qkb.217.1551986249471;
        Thu, 07 Mar 2019 11:17:29 -0800 (PST)
X-Google-Smtp-Source: APXvYqzkODASbKmPEelTPvI4J9Z+STrq2ihPnC/ayikJlts0Nxhde7mNgGQyFK3XfgGMohZ6lT7a
X-Received: by 2002:a37:61d3:: with SMTP id v202mr11078379qkb.217.1551986248781;
        Thu, 07 Mar 2019 11:17:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551986248; cv=none;
        d=google.com; s=arc-20160816;
        b=uTeu0QdiAEVlwtkd3TvMP6dXRGLLAhEvcRPxIFeX3232MxkwaWB2720TQ3Ofaf7r9J
         5oAMUxA4Gqo700xDB6r5smA2Aej+OTevCW4CO2XhaIxPsrJOO2j7bhhs56MQkH4W+88d
         df0/p1qQkX3Ewdu1hHwaeOGFEW38Yyi2DnR+20GQ12vEBfN4gTawvfZKDcqMkKfNiHFa
         CMbt37uR3xH1ErSMWZJhIseRRdaqUWewXZzsAAOWleyu0e6UvEbfiyWcA4tyk3nK1G3a
         9ke+TJvxJvTcdiIZJ8Mr36icbW89VG/+jgno3v2JLzF8FwjdgXnNHPU+d3I920bIHUPo
         btDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=FFop6gRw3zlL63ls0haN7Gcrf176Q4z+n3NvtK6rzgU=;
        b=pdnK54oCUXToejuGMIqsTZzajzsP2m4qVkLDIAZmu4HacmTLHcUh8GGvpibidDXTwn
         Cc7IJPhQ4h8A7muXPhKLfXDKO7Ib/9pEOi9Jyj88LhfsgP4gkGA7jz/BEpe2sBI2doYZ
         bcexvTzVLgkNIb0JqHCU2XXhjnLb9fISQ9mhEV3Y5NSYuyXuV6r+7vzD960xuTkFOmmh
         AwpDFQxQW/iCIeP32rFiIA1nSXhzzPjKzvrjmH2Kd5ZmS1N8K8pZeaBoSZky3Rp53Bqo
         88YPGyI1phbSlgIA02y5fDCozT1DuwflbU1Fk/ZuNc7z60FcRl7fjpK7VJxYKUFtBX9x
         tGfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p67si1549523qkd.272.2019.03.07.11.17.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 11:17:28 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F3B5B30718CB;
	Thu,  7 Mar 2019 19:17:27 +0000 (UTC)
Received: from redhat.com (ovpn-125-54.rdu2.redhat.com [10.10.125.54])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id DA17B19C65;
	Thu,  7 Mar 2019 19:17:22 +0000 (UTC)
Date: Thu, 7 Mar 2019 14:17:20 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	aarcange@redhat.com
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190307191720.GF3835@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190307124700-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Thu, 07 Mar 2019 19:17:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 12:56:45PM -0500, Michael S. Tsirkin wrote:
> On Thu, Mar 07, 2019 at 10:47:22AM -0500, Michael S. Tsirkin wrote:
> > On Wed, Mar 06, 2019 at 02:18:12AM -0500, Jason Wang wrote:
> > > +static const struct mmu_notifier_ops vhost_mmu_notifier_ops = {
> > > +	.invalidate_range = vhost_invalidate_range,
> > > +};
> > > +
> > >  void vhost_dev_init(struct vhost_dev *dev,
> > >  		    struct vhost_virtqueue **vqs, int nvqs, int iov_limit)
> > >  {
> > 
> > I also wonder here: when page is write protected then
> > it does not look like .invalidate_range is invoked.
> > 
> > E.g. mm/ksm.c calls
> > 
> > mmu_notifier_invalidate_range_start and
> > mmu_notifier_invalidate_range_end but not mmu_notifier_invalidate_range.
> > 
> > Similarly, rmap in page_mkclean_one will not call
> > mmu_notifier_invalidate_range.
> > 
> > If I'm right vhost won't get notified when page is write-protected since you
> > didn't install start/end notifiers. Note that end notifier can be called
> > with page locked, so it's not as straight-forward as just adding a call.
> > Writing into a write-protected page isn't a good idea.
> > 
> > Note that documentation says:
> > 	it is fine to delay the mmu_notifier_invalidate_range
> > 	call to mmu_notifier_invalidate_range_end() outside the page table lock.
> > implying it's called just later.
> 
> OK I missed the fact that _end actually calls
> mmu_notifier_invalidate_range internally. So that part is fine but the
> fact that you are trying to take page lock under VQ mutex and take same
> mutex within notifier probably means it's broken for ksm and rmap at
> least since these call invalidate with lock taken.
> 
> And generally, Andrea told me offline one can not take mutex under
> the notifier callback. I CC'd Andrea for why.

Correct, you _can not_ take mutex or any sleeping lock from within the
invalidate_range callback as those callback happens under the page table
spinlock. You can however do so under the invalidate_range_start call-
back only if it is a blocking allow callback (there is a flag passdown
with the invalidate_range_start callback if you are not allow to block
then return EBUSY and the invalidation will be aborted).


> 
> That's a separate issue from set_page_dirty when memory is file backed.

If you can access file back page then i suggest using set_page_dirty
from within a special version of vunmap() so that when you vunmap you
set the page dirty without taking page lock. It is safe to do so
always from within an mmu notifier callback if you had the page map
with write permission which means that the page had write permission
in the userspace pte too and thus it having dirty pte is expected
and calling set_page_dirty on the page is allowed without any lock.
Locking will happen once the userspace pte are tear down through the
page table lock.

> It's because of all these issues that I preferred just accessing
> userspace memory and handling faults. Unfortunately there does not
> appear to exist an API that whitelists a specific driver along the lines
> of "I checked this code for speculative info leaks, don't add barriers
> on data path please".

Maybe it would be better to explore adding such helper then remapping
page into kernel address space ?

Cheers,
Jérôme

