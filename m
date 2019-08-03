Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A66BC31E40
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 07:06:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA38621783
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 07:06:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Rlojk96g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA38621783
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A6646B0003; Sat,  3 Aug 2019 03:06:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32F666B0005; Sat,  3 Aug 2019 03:06:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D0836B0006; Sat,  3 Aug 2019 03:06:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D73926B0003
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 03:06:51 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e25so49748740pfn.5
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 00:06:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Obo/y4Dpq63FMkyaJZCs5TBVDb68o4UUZ5vLVSyqQ9w=;
        b=cRFWZmdQX0ZdX5NQlZKgylfLoMnrDtJlxY3O5iWN9JG//lwBm6mRtrngaCUzZ0BGuu
         FNU3DZbHlOxMGi/NbpX7GUmCQ5FcAM7hAM31LvKMiv0tnSNrj6qC09GEAcgaeWv3ladt
         6vEN05wyypHqM/wio9E0X7Tr/ynQvpt0ZBNbsfFx9R/S+I5H9aps7dxob4OFl+XcD6S7
         mWITTY1e5DdXZOa18C4HrWRxQcL+cZNwfgiol/Bql+Ay5d3HNg6dEGYxUspo/QadAL3E
         AvL6WmkUY3KpVTdco0B6cPgdAXSd3EVm+v8elHE1u5nyyg7GmGUJQWsw8snsbnz3agCH
         6krQ==
X-Gm-Message-State: APjAAAVsiLcGnicRQkbQzaKGLUD/7x+UrZRLmzZG79ZZzrWB/OLfE6Ck
	6CW94pKcl6pMMExVQImH7r122qXyaRBkxAR9C+cnaUdBEpHqQZb4X8HJAdoD/bkpGT7A/rMfgkz
	DwKQAgtDjzq3oar3S4pa4TR+hP0hifpPgjKOr/jQYBIoQn6mNa9Hy4zBdXlwfSTyqxw==
X-Received: by 2002:a17:90a:2486:: with SMTP id i6mr7869787pje.125.1564816011207;
        Sat, 03 Aug 2019 00:06:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyp60ysf6aUJUrhJsYzOCSmSWQsvJoL4vtKAqk0pbjEIb0ZTgJ7SohRzXY1QD5i0r57P+On
X-Received: by 2002:a17:90a:2486:: with SMTP id i6mr7869739pje.125.1564816010371;
        Sat, 03 Aug 2019 00:06:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564816010; cv=none;
        d=google.com; s=arc-20160816;
        b=miTornbJRzwHYEtCsUzvzzEJa8TTVhdkw73NUcl2Tj2BSrTHKOKm5cJqtgQwXLGUft
         vemtvUyM0f06++oOEBQ6ymPZIuCH8aIUkXk4q4JQcN5cJ52aIi/nb5RAuabILE3llwv+
         dZC2Zq1a8EKVP9oGPGzipyew1PuB+eL5h2TWtRwbl/gNkxp4WJ0ZlRpVoUoZtfuLjKZK
         5pSVgqopg6Oh9LeC6df488yXGbRCR3LT81RuzpDHw1QYNr3ZmnMShUG0ZSzZEtcY3Se1
         Ba8WU4sMln+qR1ASksvhppgP+EXKXXj5CmekY/mbgF9pcRvvBwsh1hHd20StO456Cy+l
         RmVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Obo/y4Dpq63FMkyaJZCs5TBVDb68o4UUZ5vLVSyqQ9w=;
        b=cZSDRIL0TK8eQbu/xynW7fYk7DHI3zW3JzpZY/X/0Td0vfDBHJTVRsziZG12tuqmFy
         UiUBTJ7jqA9J4bv2JqTB2kq/j2ipn5n1nDCCvPUeRRepbgw3buGgfjWx13JrWKuUypf0
         rV1YNmyydY6vWwOtStBC+DcLjDYyGuPwrJfLwWIdXtTD6m62NvE/mOexpA15L3L/B+WH
         VZfKD09NDc28/cpBQ16p3P+j4Ek/zpnE5bYV7TxuRgS7jtF3l1gIN71o8uzl4Bq2MF7T
         E5sQT6jaMz3CLfJmm44cs4AaBjU2bVTD6RS40E3ZOsp5OpOF0mqiEoH+lTrhJXXZbNJY
         AT6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Rlojk96g;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g10si6197241pgs.146.2019.08.03.00.06.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Aug 2019 00:06:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Rlojk96g;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 08D01206A2;
	Sat,  3 Aug 2019 07:06:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564816009;
	bh=pPLKovyN1NMpp946XJreXv1Y0yg1S4P9Y162ukSMn64=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=Rlojk96gVoiyivb+U7yrIkDTuHtioqnhmcEmMjAk1MQVJmXSmgcGRpi/2JLag+Dd6
	 M19hr//PiOu9iNAJPJwAfgv2wtT5dx2nyCeRHoSIIHS1qKxvoiJQ2X4AR13zqgfnZk
	 KxaPAYdBHbY01Ff9SDG1UhnB5NnA5pYpWqC1XkA0=
Date: Sat, 3 Aug 2019 09:06:21 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fbdev@vger.kernel.org,
	Jan Kara <jack@suse.cz>, kvm@vger.kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Dave Chinner <david@fromorbit.com>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, sparclinux@vger.kernel.org,
	ceph-devel@vger.kernel.org, devel@driverdev.osuosl.org,
	rds-devel@oss.oracle.com, linux-rdma@vger.kernel.org,
	Suniel Mahesh <sunil.m@techveda.org>, x86@kernel.org,
	amd-gfx@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Mihaela Muraru <mihaela.muraru21@gmail.com>,
	xen-devel@lists.xenproject.org, devel@lists.orangefs.org,
	linux-media@vger.kernel.org, Stefan Wahren <stefan.wahren@i2se.com>,
	John Hubbard <jhubbard@nvidia.com>, intel-gfx@lists.freedesktop.org,
	Kishore KP <kishore.p@techveda.org>, linux-block@vger.kernel.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-rpi-kernel@lists.infradead.org,
	Dan Williams <dan.j.williams@intel.com>,
	Sidong Yang <realwakka@gmail.com>,
	linux-arm-kernel@lists.infradead.org, linux-nfs@vger.kernel.org,
	Eric Anholt <eric@anholt.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org,
	linux-crypto@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH 15/34] staging/vc04_services: convert put_page() to
 put_user_page*()
Message-ID: <20190803070621.GA2508@kroah.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802022005.5117-16-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802022005.5117-16-jhubbard@nvidia.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 07:19:46PM -0700, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> Cc: Eric Anholt <eric@anholt.net>
> Cc: Stefan Wahren <stefan.wahren@i2se.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Mihaela Muraru <mihaela.muraru21@gmail.com>
> Cc: Suniel Mahesh <sunil.m@techveda.org>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Cc: Sidong Yang <realwakka@gmail.com>
> Cc: Kishore KP <kishore.p@techveda.org>
> Cc: linux-rpi-kernel@lists.infradead.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: devel@driverdev.osuosl.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>  .../vc04_services/interface/vchiq_arm/vchiq_2835_arm.c | 10 ++--------
>  1 file changed, 2 insertions(+), 8 deletions(-)

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

