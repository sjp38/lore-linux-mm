Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0127C282D4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 07:52:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 985D221852
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 07:52:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 985D221852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35F168E0003; Wed, 30 Jan 2019 02:52:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30DFF8E0001; Wed, 30 Jan 2019 02:52:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 225E98E0003; Wed, 30 Jan 2019 02:52:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id D5CD18E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 02:52:58 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id f18so8968985wrt.1
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 23:52:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0VbjHPROoNx2a7cxBhsVfJCPgi6qgdLAAcjRouY8Dvw=;
        b=Pv2ksbtXUxEiAdE+35w4qooDfiBcbd/1Yu9a8ybUzerZkLPArto0SunEK3XNl/3Px5
         2KzpCfY8IbGDLPWo5YMJSUv8RgB0RKYEzKtr8P1Ca00EexoKuRrxT1O1vUduZ8BRsotr
         JmJseoGDbipaA9mybGcUksg3vAujW/qvydzHwgOLMgJjjdkH9Yv1rp0TiLNcguI75Jdr
         U/V+WDUEQ3iijupz556b6y3KT4ab94k2LNTxIxRq32s+4mAvVAwE8cpCsKEexaCv/xW4
         Jlsq0tQouNjliWR/z1nWqaNcSjd33IppNeb0+bZbjML3wOFk3KykJRdDG4oOFbAK5u2L
         kLFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AJcUukdQRyWjq4pgtVoYvb4LKsXbC0uxFg27ZEHhltF3GTDLX4DbdcNu
	wk5ktr8BbwIIKyLkd7Q2gynDzbnqzr+BdYi3vH825hvS2OAFg92GYbzZvIBgH5s/MoS1Vg+iUYB
	EjvlL6RwxxzFttHooSVRExtPpdDd2wPFA7IssfIISMcHwefTl8f9Hhyn/SxFco31e/w==
X-Received: by 2002:a1c:c707:: with SMTP id x7mr23422923wmf.120.1548834778438;
        Tue, 29 Jan 2019 23:52:58 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5IURrYtZ2+9N7T8zX5m08azgF5JycHogBefFCEvaIUZjMvunLE1Ar0Xfw0li0+vjMXkFfk
X-Received: by 2002:a1c:c707:: with SMTP id x7mr23422882wmf.120.1548834777610;
        Tue, 29 Jan 2019 23:52:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548834777; cv=none;
        d=google.com; s=arc-20160816;
        b=WAQ4yg4EnarhJ449wjQwpAsCxgLBnuGpGzy99BRQW8ZDU9oT2R2ZQD3pid8jSO+hk1
         erS9jsAtPP+aM+Cw574IvkBqpjgXGWse0/DSmxfLvNNN1vgdqkirWtHJkcpVP6JDdrtB
         Rft4sJ+VWk2XCqlQDTaMl5b01xEgiDet7EIynmH7kmUyGjqRxR2dYlaRRl6ZtAfIeAbY
         U0YfSSSc3JnYOdmM7mnIQwY114IwsDTeUdq6pl+CCocrUiVhh1upLilLZ2CbPA8tRF2t
         2QPdwBwvGehuGf3R/7+zvOvc99SP73tGJ/7YyU0RAZDX5TyCbq4ap6JfDvDQOi2KypL0
         Wavg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0VbjHPROoNx2a7cxBhsVfJCPgi6qgdLAAcjRouY8Dvw=;
        b=M037nEvAg9gdG7LhYjsoXIdkQ469taBDnWQ04O4/bFMnotEYSgZlZzW68XkHpYL024
         bmjtn57r9IagQUcHOlc139xtemieNELOapUMvQe1LfQczPXlbBN6wLKD5EhFT0BINcfE
         VbS/SWhn6APl4I/Eg1mjjhBSiooY4EoE9nLeJYJ5aUN8L4nXqw4guZzwof+iwZqKew2D
         ogROJ67+p7149j8N+gSqRymlK451nrlLtyhAKblBdd+NBcm8Nw3eKGictl/4oTlCqU/9
         g2G6l7YzJC6byoKprwanLOS7VPu4gcEEbVTAg28xuS+NlPxdkWwr19bi693Wl7rj2vHe
         Wmcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id u185si796379wmg.131.2019.01.29.23.52.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 23:52:57 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id C07BF68CEC; Wed, 30 Jan 2019 08:52:56 +0100 (CET)
Date: Wed, 30 Jan 2019 08:52:56 +0100
From: Christoph Hellwig <hch@lst.de>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
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
Message-ID: <20190130075256.GA29665@lst.de>
References: <20190129174728.6430-1-jglisse@redhat.com> <20190129174728.6430-4-jglisse@redhat.com> <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com> <20190129191120.GE3176@redhat.com> <c2c02af7-1d6f-e54f-c7fb-99c5b7776014@deltatee.com> <20190129194418.GG3176@redhat.com> <b3264844-2c04-6c34-f1e7-6b3bf9849a75@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b3264844-2c04-6c34-f1e7-6b3bf9849a75@deltatee.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 01:43:02PM -0700, Logan Gunthorpe wrote:
> It's hard to reason about an interface when you can't see what all the
> layers want to do with it. Most maintainers (I'd hope) would certainly
> never merge code that has no callers, and for much the same reason, I'd
> rather not review patches that don't have real use case examples.

Yes, we should never review, nevermind merge code without users.
We had one example recently where this was not followed, which was HMM
and that turned out to be a desaster.

