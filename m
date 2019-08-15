Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09453C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 15:10:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A039E206C1
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 15:10:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="lI3y7R44"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A039E206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 046A46B029D; Thu, 15 Aug 2019 11:10:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3B016B029E; Thu, 15 Aug 2019 11:10:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E27F66B029F; Thu, 15 Aug 2019 11:10:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0233.hostedemail.com [216.40.44.233])
	by kanga.kvack.org (Postfix) with ESMTP id C089D6B029D
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 11:10:30 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 6081940DD
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:10:30 +0000 (UTC)
X-FDA: 75824998620.29.fog06_78c3fd76fcd23
X-HE-Tag: fog06_78c3fd76fcd23
X-Filterd-Recvd-Size: 6147
Received: from mail-qk1-f195.google.com (mail-qk1-f195.google.com [209.85.222.195])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:10:29 +0000 (UTC)
Received: by mail-qk1-f195.google.com with SMTP id r21so2144474qke.2
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 08:10:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=xzO7Mshohtsh0MjNCwtfvdaSBmY8e4joFkYT0O9y2JI=;
        b=lI3y7R44OI9cE4EW3AD4mdCTJlQwdhtFMnFulkuEqvQdz88hWBkf/Luz9A97zWh1WM
         6VlnHYIeU9yHzN5gLW2s6pZtC53ZcoK+QYnLyrm71HqORWm7eDtaZclaBxKxBqoBfR6a
         wQh2bKmRFu8C01tUVSEPeeZYrB6Zf+XdIvZRedLH4G7bY1xFFrYAoyZPI6cM+2j3i+UD
         ekO1QrzYXDSKJKdF9J3udmvIveoENdrM4omYutvyVHhrkIapI79MBHNcmw35rsWFNK76
         65B13pG5zrwaNbu2GbqZZmb2GB6hh98QSz3unRjRNSzvxzUILwBIuF3oriB53wVaSEzR
         S8UA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=xzO7Mshohtsh0MjNCwtfvdaSBmY8e4joFkYT0O9y2JI=;
        b=KxBSW/AKG7AFwXjpSH2MHsuIqEHO8gbt2fJc546AY2FWQiE/VGea9BVqzuj/xTHGyd
         iyL5CGArIg4iVBT6ZsRP+0tujljuX2IY7oTgVb2PLYItPdpDV+Z49sxKCqr/yVfc/K+o
         W9Zvk0amPtya1/GKDZ4sKQHC48zNiMdGDIUyFfFmn32QZr9KrFTRxhcGV9/QvU2uv0dx
         Edjn6JM/Nitbd2vSMrw/wLxVfuv3wU6bfwzjA825gu5ojv3FgRdv5r6VrfZnNmyoG0+t
         T9v/vE1HL77u00L/J4uZAdvWOwItQcISZwC0TH/hO10Fu+pJsTltG6YxZpgXXhD9CqRu
         r19w==
X-Gm-Message-State: APjAAAV55yseHT2nua36zGCE4noikt/Ay2jP8IXNs9hyr7FKNVpvbtTB
	tq9as2safaNSB1Uh1RTv36DJKQ==
X-Google-Smtp-Source: APXvYqwzfXMAsx+TimK2Wq4Er/PrNLigk2R/e9axAwMI+6uwPMqruXjP4qCNTiLEsTwOHrOMXcfSYA==
X-Received: by 2002:a37:aa88:: with SMTP id t130mr4635639qke.12.1565881829208;
        Thu, 15 Aug 2019 08:10:29 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id i62sm1568446qke.52.2019.08.15.08.10.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Aug 2019 08:10:28 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyHOW-0005WZ-AT; Thu, 15 Aug 2019 12:10:28 -0300
Date: Thu, 15 Aug 2019 12:10:28 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190815151028.GJ21596@ziepe.ca>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch>
 <20190814134558.fe659b1a9a169c0150c3e57c@linux-foundation.org>
 <20190815084429.GE9477@dhcp22.suse.cz>
 <20190815130415.GD21596@ziepe.ca>
 <CAKMK7uE9zdmBuvxa788ONYky=46GN=5Up34mKDmsJMkir4x7MQ@mail.gmail.com>
 <20190815143759.GG21596@ziepe.ca>
 <CAKMK7uEJQ6mPQaOWbT_6M+55T-dCVbsOxFnMC6KzLAMQNa-RGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKMK7uEJQ6mPQaOWbT_6M+55T-dCVbsOxFnMC6KzLAMQNa-RGg@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 04:43:38PM +0200, Daniel Vetter wrote:

> You have to wait for the gpu to finnish current processing in
> invalidate_range_start. Otherwise there's no point to any of this
> really. So the wait_event/dma_fence_wait are unavoidable really.

I don't envy your task :|

But, what you describe sure sounds like a 'registration cache' model,
not the 'shadow pte' model of coherency.

The key difference is that a regirstationcache is allowed to become
incoherent with the VMA's because it holds page pins. It is a
programming bug in userspace to change VA mappings via mmap/munmap/etc
while the device is working on that VA, but it does not harm system
integrity because of the page pin.

The cache ensures that each initiated operation sees a DMA setup that
matches the current VA map when the operation is initiated and allows
expensive device DMA setups to be re-used.

A 'shadow pte' model (ie hmm) *really* needs device support to
directly block DMA access - ie trigger 'device page fault'. ie the
invalidate_start should inform the device to enter a fault mode and
that is it.  If the device can't do that, then the driver probably
shouldn't persue this level of coherency. The driver would quickly get
into the messy locking problems like dma_fence_wait from a notifier.

It is important to identify what model you are going for as defining a
'registration cache' coherence expectation allows the driver to skip
blocking in invalidate_range_start. All it does is invalidate the
cache so that future operations pick up the new VA mapping.

Intel's HFI RDMA driver uses this model extensively, and I think it is
well proven, within some limitations of course.

At least, 'registration cache' is the only use model I know of where
it is acceptable to skip invalidate_range_end.

Jason

