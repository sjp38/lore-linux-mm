Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5053C04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 19:12:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D5A520881
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 19:12:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="toauLP82"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D5A520881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E68476B0005; Tue, 14 May 2019 15:12:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E192D6B0006; Tue, 14 May 2019 15:12:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE0816B0007; Tue, 14 May 2019 15:12:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 96BEC6B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 15:12:47 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id o12so160030pll.17
        for <linux-mm@kvack.org>; Tue, 14 May 2019 12:12:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Icr/JUIQgdLGqzTPJ4KfZ36tY4wuUxilsg+w4yML4Ng=;
        b=KUiyuVSQfxhhr/NEeqTokOLw11/aH7BPPUCfvgnpymv1k16dyoqCnpXThsr2V9wwSR
         s5UR9uL3FGefuM+mABo4ufEG5ufwloL8F/GFtA+BvFQulGfqE3jvSc6hkyZPjyiiJb7a
         oWz/z6FEstlNCpG0xJa76QMak+Nf1ML2Z5llph3kNRdckZlt+YFPZ1iUmXzJ+lRcuM5z
         Gi6ecEdx2heP4yUfcqmbtMNDYJW1HMo45FjspN+XPkt9hCb4hU+I0vh6fzL762VV4YAm
         rFFxIgP8HhzXOc1+aERrirQCnJ/NM/TP7scuYmTldx+zhYNaQJ82N8Eia6TYiVoRkP/k
         ZPOw==
X-Gm-Message-State: APjAAAXkbNIbFaicoSMJmpcGX+EExGim7UfrhMI096DUYQVL4wAaVA7f
	gNxk/r+E9130NPd8RcoFZlXQMRSXVK3dsUTTOvTISvh7MTwIq7GgWBR0bpq/twdekKPy5+z1QZN
	mq3Z11v8ZvRi2fvu5vCK45nddPq0QlZFh4W2Yt+Llz3A78DAQzBZmL+jJ3ZcK97tjqA==
X-Received: by 2002:a17:902:3fa5:: with SMTP id a34mr12334878pld.297.1557861167193;
        Tue, 14 May 2019 12:12:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEwQUHcz8AFbAhVtod9+h979HFYDBEl0Li01sTZhjJdbcEDejSH/6aLSmSg9BagO0SDBtJ
X-Received: by 2002:a17:902:3fa5:: with SMTP id a34mr12334833pld.297.1557861166492;
        Tue, 14 May 2019 12:12:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557861166; cv=none;
        d=google.com; s=arc-20160816;
        b=0MgqixooH75Rqb6FtUyvhrnN6qCwDZmjHj3tu7yebbO8g8UIdy8eR7IP9l0NhUOF9W
         wqhYky+owBsmwhGLvSn0akf1OrIEOo98XW7QDSyDcvvZLW0zEoYCnAhPIXScwZgI+J75
         sAcvh++wxDBkKZOWMPJveq/hn4wQt4pxrqswncyFkCd4VJI2Y8hipQYYdvyC8fEgN/+N
         vPIcFClNLmiVNbBRaLaYWJQMRm+7xUJQBDSfzdQZyXUNOrLGu3yq85q8w9W/u0ZnBe9L
         btUtjLKmsWv+u+z1EFsnLrieIEUHT0Pf/frYv60NdZrQ9z9Bsj4UR7ONL337VoHjP8CQ
         c01w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Icr/JUIQgdLGqzTPJ4KfZ36tY4wuUxilsg+w4yML4Ng=;
        b=csryVJY9lRhAM/FEl+11IApZNI/rj8sjZqBz0+b1KRH000tLzS1jjoOUsI/t4RRdaZ
         R4cfHZrymCBWPt2itAHmd9bY1jShtyUF+62oI1HZKC/B0MFtw+WYg3h/rNhJGhGpX8Vh
         lv3/myngD6RUJzJ5hgxU4pkrjZ9M3hWAq4DKNoqRd7+B0jC8E3CNWTEWtbWi60nzJyWa
         1k3dHHwtTSOQwOiQoI0bgGcTgQn9VYC+jKRYi8YLLEyaiQQBi0sq//Zt2sPUnXBixPj3
         +3AWtFviI4a7M8jLy9g9wSzmukxyZkrTd6ompuBomRH3uynJpHUxluhobvcaTfmnp59B
         YiUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=toauLP82;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 67si19358528plf.382.2019.05.14.12.12.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 12:12:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=toauLP82;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8AFDD20675;
	Tue, 14 May 2019 19:12:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557861166;
	bh=Dx8fO3TTAFVbhjdjmVSXfGcWo/4xM9XJT2npi4xsxtc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=toauLP82s6SvK8V1KkHf5COFmXqXrCdzvWsSIFzpnOMz7HsK8pGBWSn2riYujnQm3
	 UI2pj0XEpWNT5f3qUGUCkuemRm2ajtG8i/wdw9VqAHsfrUmDKzFPIQ/O90P7kZZGPL
	 U0nCodj8lpkzjPsBWsi9XCyThfy2fiK8twsrFumQ=
Date: Tue, 14 May 2019 21:12:43 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Logan Gunthorpe <logang@deltatee.com>,
	Bjorn Helgaas <bhelgaas@google.com>, Christoph Hellwig <hch@lst.de>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Ira Weiny <ira.weiny@intel.com>, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 1/6] drivers/base/devres: Introduce
 devm_release_action()
Message-ID: <20190514191243.GA17226@kroah.com>
References: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155727336530.292046.2926860263201336366.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155727336530.292046.2926860263201336366.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 04:56:05PM -0700, Dan Williams wrote:
> The devm_add_action() facility allows a resource allocation routine to
> add custom devm semantics. One such user is devm_memremap_pages().
> 
> There is now a need to manually trigger devm_memremap_pages_release().
> Introduce devm_release_action() so the release action can be triggered
> via a new devm_memunmap_pages() api in a follow-on change.
> 
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Bjorn Helgaas <bhelgaas@google.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  drivers/base/devres.c  |   24 +++++++++++++++++++++++-
>  include/linux/device.h |    1 +
>  2 files changed, 24 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/base/devres.c b/drivers/base/devres.c
> index e038e2b3b7ea..0bbb328bd17f 100644
> --- a/drivers/base/devres.c
> +++ b/drivers/base/devres.c
> @@ -755,10 +755,32 @@ void devm_remove_action(struct device *dev, void (*action)(void *), void *data)
>  
>  	WARN_ON(devres_destroy(dev, devm_action_release, devm_action_match,
>  			       &devres));
> -
>  }
>  EXPORT_SYMBOL_GPL(devm_remove_action);
>  
> +/**
> + * devm_release_action() - release previously added custom action
> + * @dev: Device that owns the action
> + * @action: Function implementing the action
> + * @data: Pointer to data passed to @action implementation
> + *
> + * Releases and removes instance of @action previously added by
> + * devm_add_action().  Both action and data should match one of the
> + * existing entries.
> + */
> +void devm_release_action(struct device *dev, void (*action)(void *), void *data)
> +{
> +	struct action_devres devres = {
> +		.data = data,
> +		.action = action,
> +	};
> +
> +	WARN_ON(devres_release(dev, devm_action_release, devm_action_match,
> +			       &devres));

What does WARN_ON help here?  are we going to start getting syzbot
reports of this happening?

How can this fail?

thanks,

greg k-h

