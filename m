Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 658F2C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 14:02:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C9302168B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 14:02:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Adj/ubhV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C9302168B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA2F26B0003; Fri, 14 Jun 2019 10:02:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7AB06B000A; Fri, 14 Jun 2019 10:02:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A90A26B027F; Fri, 14 Jun 2019 10:02:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 71D086B0003
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 10:02:44 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id c18so1956397pgk.2
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 07:02:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=k6W9GaC0b5Ud9KVLDewJufm7RMAkbd9q3vEJ3tzJCRc=;
        b=BGZkoHRUJ/In6OWhL/a5E4x7krEf+pnYgcPVFoLEpn0ouCzp8k5/rIAUtGhid224Jq
         olxi/Nb8nqx8vFrwo4WvQncObVwjJMGfI0YtHZvsYQNtse0wexWBQH/W7VqT9zxae7W4
         2owHbNK2d/zGnaEz6KqMDCc6d1/4r5A2QW1CcaPDIKXrSJL6kxCnQ814sqgsndKxtsrt
         pelZaea0oXY+//15XXTOvT6dyB4SmMzQhOKLbAmkBBP6iW/IDUJXyMSvxQM0cw+ZI0C+
         g7yhjRN4xdlVKF0bjNrNwbbmP5IswsgxtuI/PUj1l2Ji8K7VAnCBYG9iGdedFzkoVIoT
         Z7bQ==
X-Gm-Message-State: APjAAAXnNJKXOV/Uy2T3MlqfLyDtgqcMoeIWdKtmWRuLjqJpkVLtXBUD
	SiOG4U0SLYTrxSK2c6bePPBnDBrkZcxPcNGobPB1QuFCHMwd44mQz9v63ANeYW7BwxdO7beBvLm
	Q3z8VICVfZ3CeE01X9JK2i8LFo/DiPcsQsXH9MZNG/KQF9EYWn+dpKgkzQbyuxICCbg==
X-Received: by 2002:a63:dc56:: with SMTP id f22mr20513620pgj.305.1560520964060;
        Fri, 14 Jun 2019 07:02:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7IY3J7MJQfL3l+Up2QKwCHmCiKn4TLAWwWUM5mxAVEfKjEdOj2FJLAOkAhkNOsTUjI1Ww
X-Received: by 2002:a63:dc56:: with SMTP id f22mr20513437pgj.305.1560520962022;
        Fri, 14 Jun 2019 07:02:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560520962; cv=none;
        d=google.com; s=arc-20160816;
        b=iEmWgD+jpEUWC2XQOSBZfIWV1eU+9qP6LHEMRQ3OcYu4lVCDydEYAJwuiio3wYpONB
         qq8eNN9odeFCSwu3q7tY6vWwS9Y6gtPZt6jARcSLyvhqw1mGIXnbjVO0iH2C6B4VPozj
         sjj1Kq40QGAE0XXcDA0J/JbxGeyaaEy1kvNai1xB+XMQ3KJ2iTrnK7hHzeNICuKVCzAT
         xAtLGcy43uWxfq7vyR2zK8LbcbDCrVQdbmaTL5U0tPiVdh0cVq60kb4ZUBt41KSw5rdL
         pel+8JoyT070gg9E+erkxQMUuQUN8giiYizZs5JA5C6uA9jIgjbr1U6H+71JPEBwJGjj
         Gt5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=k6W9GaC0b5Ud9KVLDewJufm7RMAkbd9q3vEJ3tzJCRc=;
        b=AP/D02ccmby4hf1JR4gc+2M0Ana1eIvqXbrAAMbj0IOB2Fmn6M8druC8pJ4tRXkHmk
         BIKr4TitpE4esW3pfuCcrXCGjObgvSmpc3q+DQri6MN3IUHlQ8XtPSjsvql71/m4COUA
         TuuRVrHRcQtyaYn9v4OsY7QHpJVfIzHov6BVg1q/yIArVtOdnG3LwR2PLiXtpAzgXzU+
         UXHArmfqtKJ5XhfswI1gs0KLo3cIsCPLMAUEbomJzpXLcB7tEKFW7hjbiQIy6uXuVB5e
         YJ7i21bkwc3gqTK6yMmcI03IyCVdaAj7Qujfjsnl19kXQP3HO26+oaBvo8s6yPiC4Fyu
         qp5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="Adj/ubhV";
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b35si2361597plb.249.2019.06.14.07.02.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 07:02:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="Adj/ubhV";
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id F10F42064A;
	Fri, 14 Jun 2019 14:02:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560520961;
	bh=yuQRJdK0c0k8QDLCPmaaUBPA4Gh5iMSc87ydddzUjLY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=Adj/ubhVrddpf3XNZqH7bla3F/OQLtlWktGpnu78fRXaEWJVclE8EAVB7iVcwuXIj
	 MgEu3GKKHjwm4kv6V7mrBTfmdB65iAPolSabTzDn8Y8MigqQqnxVgShMq6aUvnqaEX
	 cqT5x9DBfftx8QKc8qPay9S9idxZcSOh+UlLdp+0=
Date: Fri, 14 Jun 2019 16:02:39 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>, David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>,
	devel@driverdev.osuosl.org, linux-s390@vger.kernel.org,
	Intel Linux Wireless <linuxwifi@intel.com>,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	intel-gfx@lists.freedesktop.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	"moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>,
	linux-media@vger.kernel.org
Subject: Re: [PATCH 12/16] staging/comedi: mark as broken
Message-ID: <20190614140239.GA7234@kroah.com>
References: <20190614134726.3827-1-hch@lst.de>
 <20190614134726.3827-13-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614134726.3827-13-hch@lst.de>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 03:47:22PM +0200, Christoph Hellwig wrote:
> comedi_buf.c abuse the DMA API in gravely broken ways, as it assumes it
> can call virt_to_page on the result, and the just remap it as uncached
> using vmap.  Disable the driver until this API abuse has been fixed.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/staging/comedi/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/staging/comedi/Kconfig b/drivers/staging/comedi/Kconfig
> index 049b659fa6ad..e7c021d76cfa 100644
> --- a/drivers/staging/comedi/Kconfig
> +++ b/drivers/staging/comedi/Kconfig
> @@ -1,6 +1,7 @@
>  # SPDX-License-Identifier: GPL-2.0
>  config COMEDI
>  	tristate "Data acquisition support (comedi)"
> +	depends on BROKEN

Um, that's a huge sledgehammer.

Perhaps a hint as to how we can fix this up?  This is the first time
I've heard of the comedi code not handling dma properly.

thanks,

greg k-h

