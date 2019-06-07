Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 765E0C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 23:01:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DBAA206E0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 23:01:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DBAA206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C483B6B0276; Fri,  7 Jun 2019 19:01:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF7436B0278; Fri,  7 Jun 2019 19:01:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B0DFE6B0279; Fri,  7 Jun 2019 19:01:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 79DD66B0276
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 19:01:35 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 30so2360282pgk.16
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 16:01:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=wpNCUiXFj9uivZiJJLtmvfXh8hllPGgRQMg+ExIhfOE=;
        b=ECBMyGYPqqNVQhBuvOvnn4FOEwqhzvy5Z3xen6yQjXVKwm3B6mPvwLW2tn6xOXjQS0
         /IdOW6jXosqQkMJDRGdZrm+CetqQ3CjmXMvOJm5EnGfyDpbuVI2Ieo8Xe/TyjwQRqY+A
         F+JsTo+hYFlRIRYproDVk7iVEXXEy1oJRutVaJAZYyf8skddtU16O5MZLGByR+3Srf+8
         BYJhsu3Q8E+yRsZgZ1HasKWy6KWQxRa70r7qH7MpLd0vl92D+9VqfZCkpBGQtzt8jfh7
         Jc5j5BW9s4cEfS8rdOmTmSLp5Ut500rk2Gg6F+vf1NAb92WXXwhBgTdkGvH8CKd6/F6g
         lCsA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVmQpyvsUMuYSxY5hJeLM0OcAJPZRGxuHN8qIJxRyCbrlM5QbQk
	ztrLSz0Kv3TyAClY8FSqgDXdnm7kpIc2T6gtz1jfSuwN8ZC207bBMC6zAzeSCHng/6Ul1jxe2NA
	kso/xZq9P7hUKSL0o4IrHVdZtZWOVRSPv88+4EMyFQpgyXRswBiZUOFITJgfizoPc+Q==
X-Received: by 2002:a63:f456:: with SMTP id p22mr4288708pgk.34.1559948494968;
        Fri, 07 Jun 2019 16:01:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyOgWF6sMtjoUfM6AMMd6OVkXIXKJD3A9T0kVq8omK+OitkE10YEkFejJtObxHOCJ8Q89Y
X-Received: by 2002:a63:f456:: with SMTP id p22mr4288645pgk.34.1559948494054;
        Fri, 07 Jun 2019 16:01:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559948494; cv=none;
        d=google.com; s=arc-20160816;
        b=p6Ahn8ZmxpcT6Aj7Wbu39c2V+WFZnadBTpQ9qgPuPcpJnx7dDBGeW17QHLYeeBbZV7
         7oobrlTmpmh71UN0JXYI/ckclbLaORiBhQnQWllURKfwuOoc0PJLew8njZ0siS0kkgXl
         WFm/RvgpAB3/ggVUbZBVr4q5GIYTiK6dzQ0FgjAQMuxaVSiYnZTMbFStiSdfGpNXYYFC
         OjN7W/Nvy5fehvnORZ7fCFMfymOYJMQJKNaSKkL9pHRRteRcyGdWE+KB7Noqb9TuK0es
         Yv7O6gU192mNjsvNoVcgorYjdTQKhgcThTs1wBY/iaZHeA/zTiBKEJhyZium0lqKiYi+
         oHqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=wpNCUiXFj9uivZiJJLtmvfXh8hllPGgRQMg+ExIhfOE=;
        b=KmZQ4f9lXNyQGXvHfBW0XP9Vk25Z1t26jlAefGLEGs+hOV8BscNORjHS690NDrvySO
         r1dB/MZHzrr3pzXZEj86/9bnTFKMAJmB8LatBa7/M6huD+rIQR9ZMetPxIaMqQh2wBSv
         aFBreJSTfVnx6bunZ2q+K7cKCmaGzxIlQYClAuU1bOACUwH1s2ZjYmxFtpzoPWaYU8la
         79Limwz1W9om3wkmIPdO9ONGhzBd4wZNhQTJkXt9TqBLQOHbvSLWE7M9+ndajNqr6JC8
         6H5v26G9UHWDC8b1nz0sfklOPm8LMKn/KaFDaFiJlGl31Nmp9WcqUqVoLm9Zogh7Cj/H
         yTbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id l1si3128968pgi.278.2019.06.07.16.01.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 16:01:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 16:01:33 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga006.jf.intel.com with ESMTP; 07 Jun 2019 16:01:32 -0700
Date: Fri, 7 Jun 2019 16:02:46 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH v2 hmm 10/11] mm/hmm: Do not use list*_rcu() for
 hmm->ranges
Message-ID: <20190607230246.GI14559@iweiny-DESK2.sc.intel.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-11-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190606184438.31646-11-jgg@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 03:44:37PM -0300, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> This list is always read and written while holding hmm->lock so there is
> no need for the confusing _rcu annotations.
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

Reviewed-by: Ira Weiny <iweiny@intel.com>

> ---
>  mm/hmm.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index c2fecb3ecb11e1..709d138dd49027 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -911,7 +911,7 @@ int hmm_range_register(struct hmm_range *range,
>  	mutex_lock(&hmm->lock);
>  
>  	range->hmm = hmm;
> -	list_add_rcu(&range->list, &hmm->ranges);
> +	list_add(&range->list, &hmm->ranges);
>  
>  	/*
>  	 * If there are any concurrent notifiers we have to wait for them for
> @@ -941,7 +941,7 @@ void hmm_range_unregister(struct hmm_range *range)
>  		return;
>  
>  	mutex_lock(&hmm->lock);
> -	list_del_rcu(&range->list);
> +	list_del(&range->list);
>  	mutex_unlock(&hmm->lock);
>  
>  	/* Drop reference taken by hmm_range_register() */
> -- 
> 2.21.0
> 

