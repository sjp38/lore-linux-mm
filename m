Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27F5CC48BE1
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 19:36:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED8C720652
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 19:36:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED8C720652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99D4C8E0005; Thu, 20 Jun 2019 15:36:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9262D8E0001; Thu, 20 Jun 2019 15:36:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7EF848E0005; Thu, 20 Jun 2019 15:36:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD238E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 15:36:22 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b33so5606111edc.17
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 12:36:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PnIP632vG0jLqBDO7mTsj/8vvNP4AwN8spzFQsSjLdo=;
        b=tAI+//0o5Q2MbgWTlGmgsvuo1PqQTRSXR95yyKyPQi2objIABh2fTge+nLZo7nOCAI
         8bDXrDi832V1a0nOhnNdIafZsTwAxm+vYWP11WQHosUP4/wG/E0bNo13XMILVdYyF5Cc
         Mu2AwPhA+5zUSQ2zzrkYZk9RB6Mmrqx60bpxEoOm4n61yMRPLbBadYVgs68fLuV5Doau
         uc8rY1EphFHpBVD0vVaGWtVuH121/o9xU3ioGfPFBJI+3bsVjZAHXVaNEVluOpOq2zdB
         jKSjQrTYMrVpOUi5q3AwMhCtncNDHVP5UdTfQXyUKEPLqKKka8hyMiHc+Oc9vu8x3zte
         /sXQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXxf+TzuIT0DvcWBrG8LF0fHv939QlnRUnvhsjzN77+9uZ3ia/K
	wZCte8PW6Dh5wjgGEDzCY9ru2xaxdBIGBBlMbZXPLgpv7m9RS6CLf/H/Gs5Re/uIuJ0NeUlEV25
	dZOl0NrfR6dQnqlbY2/a7zH0n9+E8H45spYgEkZ/lRRzcIwt2FxZh9NlWgWPJ4AI=
X-Received: by 2002:a17:906:5cd:: with SMTP id t13mr7120368ejt.275.1561059381729;
        Thu, 20 Jun 2019 12:36:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx9gQp7LsGOML8E3Qs1sy3dVwp9hIayuFZDyLFJ7/2Z5dYHDRDy+00KynbMndU822mZi6ZU
X-Received: by 2002:a17:906:5cd:: with SMTP id t13mr7120321ejt.275.1561059381057;
        Thu, 20 Jun 2019 12:36:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561059381; cv=none;
        d=google.com; s=arc-20160816;
        b=Q7OMHTsRnWUHWHt2wdAA1f0Y+/uoLGHurhy1c0iDxxM9jFOJn1u8pyiCJoZhJ+hRnP
         NbkO4eMiky8yfWzq0DN4UVDejF/e13lbdndaSZQRtDumUXLIueklaQBcJ6nYDtYNWYtw
         m4dZMuiab8PyuZIuJ/HJkvLQE4+IiKKLfMrBcGnsglhQDtpsgAUWJiFZF7cSb7b5IjRm
         5pUaJi8EzlPyBKQKJr/y1qAHmjplUVtF+jEsUcHkQuwGuOe/J3E6GCuhlOEML/spgBuu
         pA0Iv+hD4hbyhU6W0N2N97JlldKfYYF59ndJzO5YsFpuiTRbUYfflrAxnk023F8pQw9P
         ZoJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PnIP632vG0jLqBDO7mTsj/8vvNP4AwN8spzFQsSjLdo=;
        b=J+KjxwVF03Ectwuk/yM2Pm60uf35DtFVxKDA9ewt6SbKVlckQzKe+kSjJDWMiVssVW
         C91w/hG2IS7odZA8Qp7KvBbJR5KD3UQq7K5hydmPChGag9s/Mf3jyicodXKWAeIX3qKP
         qYDAc/CGjEeTxtGLsjG+rnmR9IKmxfqxDI3D/kvBT30JqeXbQ7ZieFwEbotlsxoqmO9q
         TpwAZefRxDhJF5IMT0z27cpLJBXGjrVUOFbh4O9AvLH+YIYteg2elz8NAba9Jsf4q6H/
         Vs3kDebBH6ECT2LfZdJJ6CC8iZ12vQgjK72emRbmXlQXfWrEf4hy4xIW4j7ntCMz8WIL
         QAaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p6si702996eda.198.2019.06.20.12.36.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 12:36:21 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A71FAAEEC;
	Thu, 20 Jun 2019 19:36:20 +0000 (UTC)
Date: Thu, 20 Jun 2019 21:36:19 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 04/22] mm: don't clear ->mapping in hmm_devmem_free
Message-ID: <20190620193619.GK12083@dhcp22.suse.cz>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-5-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613094326.24093-5-hch@lst.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 13-06-19 11:43:07, Christoph Hellwig wrote:
> ->mapping isn't even used by HMM users, and the field at the same offset
> in the zone_device part of the union is declared as pad.  (Which btw is
> rather confusing, as DAX uses ->pgmap and ->mapping from two different
> sides of the union, but DAX doesn't use hmm_devmem_free).
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

I cannot really judge here but setting mapping here without any comment
is quite confusing. So if this is safe to remove then it is certainly an
improvement.

> ---
>  mm/hmm.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 0c62426d1257..e1dc98407e7b 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -1347,8 +1347,6 @@ static void hmm_devmem_free(struct page *page, void *data)
>  {
>  	struct hmm_devmem *devmem = data;
>  
> -	page->mapping = NULL;
> -
>  	devmem->ops->free(devmem, page);
>  }
>  
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs

