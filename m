Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 392A8C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 15:03:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0582321902
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 15:03:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0582321902
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 669F18E0002; Thu, 31 Jan 2019 10:03:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 619628E0001; Thu, 31 Jan 2019 10:03:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E2918E0002; Thu, 31 Jan 2019 10:03:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0BF8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 10:03:17 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id v64so3497145qka.5
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 07:03:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=rs3oN6Cgis2sEIVAEEL1k5NHgW/iTqDQVy8NtENwSQg=;
        b=BX+FduDyYwuSlx+A9qsQitg+7Cx/U3VHbViAy8cTJ885ycVI4vZ7Tfg0CTeQi1kBAb
         dEAoGP9qlLDYxOEk05yQR0nFKrB42mPvR3F4SYaWdSNjhZLLZlRMY8Bahz2UAsFMcQuJ
         W8cUKrTXEP4fx5O5wgnw+NkB5seOqTCfQFlEftvYL3WemWAgnGwkUkPicuFkftuDTJZm
         MUll7XxYFvfbsErKg9kQNN8qNQFJlRwUOiOoBCxGUMK3i5yYvPq8aRIoqkxBo2HYuYt4
         MIRc7H/uLxSb+ZSo/jI4WVOzuy1Ovo5s9tsY9OGeuVGaY3KBbHSTjX/pwDI5YsR38A2h
         qXOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukejNMmHTMwFvYrd38AhLHuYxu5pMLFGJrIMh87bcdl+CAYAMhTp
	7oMrr0WiKNCWrfLdQOiZXiGfyKH2sAzbAoWluyYe+ywBMRCm52e04eY7WLfU6JSkVEsOD3e1M47
	skmyKoDdM3zrjYa/9AO3wi5HYDy11SE9Q2aHRqfm3eQNozoIBsOrb0o/tlUqkDudMjw==
X-Received: by 2002:a37:9286:: with SMTP id u128mr32905898qkd.0.1548946996826;
        Thu, 31 Jan 2019 07:03:16 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6O7WUvmm1MZawUCuKHpaitH2zweKnGphAciBONQEP53nJCvi2+eqigL+tKcNJSfcyVTJMP
X-Received: by 2002:a37:9286:: with SMTP id u128mr32905841qkd.0.1548946996204;
        Thu, 31 Jan 2019 07:03:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548946996; cv=none;
        d=google.com; s=arc-20160816;
        b=RAY7m4uoBjZswLTGSDcXXdiRCjNjkG6zwqtLYLziLgS1aM9yE0HQrOVsi8Xww9yBj4
         NZ3SvYc27RWnOaboQVFjP5meNZj0D3y8/9EvnH7hRih2Spp0FQ36m9zD1MM0wJAyAf1H
         25GWzoeN7mSXNYxDFDX8CvveGUps3fUbnJYsJEdf0i/D591T03ikVCrqQo9XaDsc+yaa
         75jS58yf3adwFVJf7Iah1Z2PnQuwPy/gl3OffeX95AmQEwKy3oyp0In3ROx5tNS8an0+
         wsuyCFN7478296nF+rCpQflDAzm1Y68hSVDHibzcXi++HIQ+ltO3JMqi/EPOwMIebBh8
         V4GA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=rs3oN6Cgis2sEIVAEEL1k5NHgW/iTqDQVy8NtENwSQg=;
        b=BcRBM1Z64XgLLMKxHFANjo80NY2JhksaxTgyC3tjrnPbRzXVkCjn2qviIslxi7L4GS
         aliCV1MZCG8nWM1noH/tvjxACxmHa1f1Bkou2Tjw9CINLr8I/LMNvuo030M7U3317sx+
         4Ksf7nB9vbqs94S1uC8bK2XGhdxGVCCvvUBfaE/GT7KQjyVTNiuIg0uXaDxSsSHa0lwN
         Bf2FJMIHNvs3Ss34OBqSr1SOQ3uVsolp0hMFYf+EOjC+OfbTvNzV3Zi1MXlxHKYjV99Y
         30WgWIHH1qtTnjhu9nLhktn+DKJ3JBPhcKu/hccKt+Av4neZllDaqtK3K3epKHIvVNc0
         FuRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 10si3414878qto.215.2019.01.31.07.03.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 07:03:16 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8CF68445E1;
	Thu, 31 Jan 2019 15:03:13 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 343405C479;
	Thu, 31 Jan 2019 15:03:11 +0000 (UTC)
Date: Thu, 31 Jan 2019 10:03:09 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Logan Gunthorpe <logang@deltatee.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Message-ID: <20190131150309.GB4619@redhat.com>
References: <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com>
 <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205827.GM10108@mellanox.com>
 <20190130080208.GC29665@lst.de>
 <20190130174424.GA17080@mellanox.com>
 <bcbdfae6-cfc6-c34f-4ff2-7bb9a08f38af@deltatee.com>
 <20190130185027.GC5061@redhat.com>
 <20190131080203.GA26495@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190131080203.GA26495@lst.de>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 31 Jan 2019 15:03:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 09:02:03AM +0100, Christoph Hellwig wrote:
> On Wed, Jan 30, 2019 at 01:50:27PM -0500, Jerome Glisse wrote:
> > I do not see how VMA changes are any different than using struct page
> > in respect to userspace exposure. Those vma callback do not need to be
> > set by everyone, in fact expectation is that only handful of driver
> > will set those.
> > 
> > How can we do p2p between RDMA and GPU for instance, without exposure
> > to userspace ? At some point you need to tell userspace hey this kernel
> > does allow you to do that :)
> 
> To do RDMA on a memory region you need struct page backіng to start
> with..

No you do not with this patchset and there is no reason to tie RDMA to
struct page it does not provide a single feature we would need. So as
it can be done without and they are not benefit of using one i do not
see why we should use one.

Cheers,
Jérôme

