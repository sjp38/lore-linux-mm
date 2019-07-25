Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02B0BC76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 19:54:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9856218D3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 19:54:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9856218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6411A6B0003; Thu, 25 Jul 2019 15:54:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F0C16B0005; Thu, 25 Jul 2019 15:54:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 507936B0006; Thu, 25 Jul 2019 15:54:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C82C6B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 15:54:24 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h3so31354908pgc.19
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 12:54:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=SdMjmK8iF0mB7yTHT03TVjV+HGY1IT0xeAV8t1i/ACs=;
        b=BbgSLKB0lQ2G50qt4PRSIbR1KPzpjMrMkohW63cLgO+rPyd12zLNMem/tL9V+HRjRl
         280iekA/KhnYzfBrylXZeb9vITi8zN1440UTBU4pom0hmyDD7PFJnTCQs+20HP6rthNg
         pysUWuiklwF0OqXBZdzP34vmvTgiWaXv6doO5a56rPFAV4Yuvq6m/AX/TnhHXdIA3eLU
         xQLPjJ9AIHQMww0WWczVIFn/1cGpnnELUhhh/ctTARfCn+3/jBK/+GdbWuxEMSwQZAIC
         hvKFjFEddA5LuVx7PHUTOBwxrPtkalj5R1WIxso+Tbvc89sG4aDZeINrdnqfv0o0mpZ3
         i0GA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX6nX+q4XEPYnLqgfIPwe3KnbttaHPTx8GO8+nFi2iaNZv6oCQz
	3CZ1oGAXm5kIIS+1QlBYj+/OrxO8ng3ggg3rWboG6xvRCKrePoHb5Q7yDfXGFiv66zZNS7I+ZG9
	YZeRCBtV9HaMpin3iR5e5zyiiReN2I/ztG2joj+/XZnil5E2EZLDFwaz1BvWNe1Ry0g==
X-Received: by 2002:a65:458d:: with SMTP id o13mr86571387pgq.34.1564084463727;
        Thu, 25 Jul 2019 12:54:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJtvYdQs5VTz1Pzzxz/uL/Jl35Ntsxmh/SlCUKiDh2QCQp3HQyPqBj3+FzE7i2NkkOfiEk
X-Received: by 2002:a65:458d:: with SMTP id o13mr86571339pgq.34.1564084462931;
        Thu, 25 Jul 2019 12:54:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564084462; cv=none;
        d=google.com; s=arc-20160816;
        b=K4vxAlRQYzSEdaLUQolfuLzj2nxU9AB7FhdY2pRw1Q1YEsBeKRLQ9KaFPU0KwtEi4j
         LdpLSFmwKk6kLOWNVi/e73tYDZvjvb9yAizVOxDn4g/hobjnRpLYIrC4mXS6bzGWA8m/
         8UsniwXNR6oouxMicKO5eznZKUKMrtL/CZs4ECJHGq2PiM7UQ42HVyIGkWNvdUSDh53U
         SHYLCIqRLqPFzZRTRg42GcwhukQ1qRjFyN9mXjA13oEkY1WTQMyiZMK+mNMO/bJFhYoi
         DklVKtuY++IiXFAA97WipcE1Oq+m//OHqu7ExmTIUTeb++Ap6Mun+UdtjAMOK/9ADvpx
         iTXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=SdMjmK8iF0mB7yTHT03TVjV+HGY1IT0xeAV8t1i/ACs=;
        b=DnK6FzjrIHRrnHtHqEm9Txlpn2lAGonAwZ3ZyCB7Qzb/FcTooj6UsAhabnXxQiVuJf
         lfLAg4gFOc4Ldl02cVr84KYlbav45oX5wsKO7iBo5X9+wRVIzudJCrpfv1IwSM8bqhg2
         wsxm22Kqkt1EPKe40a26wwmI6WNa+CxJnIUhMBVh0Wh/j0WLRZeQRz2kG4UAIXMyHJLX
         jO6rIASL3aI25WjMGBZgMOqPpG+wRhozgfzvG00oO1gWpdjsFd+Uo3Q7+VvFX6iWkgki
         FX3J4TLFw9IoKkKl20HBEW0ivR1McgY8TXc6N5izwbOoyMqzrS1tIf84DKBafpFeSzNM
         z0Eg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id b28si19267698pfp.92.2019.07.25.12.54.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 12:54:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 12:54:22 -0700
X-IronPort-AV: E=Sophos;i="5.64,307,1559545200"; 
   d="scan'208";a="175354533"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga006-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 12:54:21 -0700
Message-ID: <0530d9d32a7316adee62e067cb0fb8048f97da84.camel@linux.intel.com>
Subject: Re: [PATCH v2 5/5] virtio-balloon: Add support for providing page
 hints to host
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>, kvm@vger.kernel.org, david@redhat.com, 
	mst@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com, 
	konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com, 
	aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com
Date: Thu, 25 Jul 2019 12:54:21 -0700
In-Reply-To: <fc99b28d-2efd-cd05-59e4-99f35bd37cac@redhat.com>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
	 <20190724170514.6685.17161.stgit@localhost.localdomain>
	 <fc99b28d-2efd-cd05-59e4-99f35bd37cac@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-07-25 at 13:42 -0400, Nitesh Narayan Lal wrote:
> On 7/24/19 1:05 PM, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > 

<snip>

> > @@ -924,12 +956,24 @@ static int virtballoon_probe(struct virtio_device *vdev)
> >  		if (err)
> >  			goto out_del_balloon_wq;
> >  	}
> > +
> > +	vb->ph_dev_info.react = virtballoon_page_hinting_react;
> > +	vb->ph_dev_info.capacity = VIRTIO_BALLOON_ARRAY_HINTS_MAX;
> > +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
> > +		err = page_hinting_startup(&vb->ph_dev_info);
> > +		if (err)
> > +			goto out_unregister_shrinker;
> > +	}
> Any reason why you have kept vb->ph_dev_info.react & vb->ph_dev_info.capacity
> initialization outside the feature check?

I just had them on the outside because it didn't really matter if I
initialized them or not if the feature was not present. So I just
defaulted to initializing them in all cases.

Since I will be updating capacity to be based on the size of the hinting
queue in the next patch set I will move capacity initialization inside of
the check.

