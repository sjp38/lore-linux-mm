Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7D30C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:36:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B395208CB
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:36:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B395208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DBDD8E000A; Wed, 26 Jun 2019 08:36:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 165B38E0005; Wed, 26 Jun 2019 08:36:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 005828E000A; Wed, 26 Jun 2019 08:36:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A83AD8E0005
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:36:26 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s5so3052786eda.10
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:36:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FYF6RSAtq6Q8NO3o3rNNecbEL+XtN/rC1H8tS2QMUnY=;
        b=FRNHThhwmfggrNjBNUpubmLQQcF9rD2kezYo+dlmA3mBTHJTKLj+85rCdbzkjlo0le
         uk9aarGVtG/fdpuGSvPc76o0Z9RvvRNJZrN3W1isZa0va/uPT6kA0uWcnFxKHh09U3vW
         MET2Y2rZXy0Yc9YevizT+AzcIDrGx1jcGH5s0eXQgQtWBocFrPAzW4s0C3ee4paOAnuC
         Wl7UFZ4IGB5KBw/Zbbz54ZZ3CGo4Byh+axi+wvvkOu1Y3FZgiY8XyVXogRmkUFfqafKR
         xgC6OWBSk5L9KU7jSHAe3XV7x50uOt4jZJ4C83hsjWCI51kqsj8S2O8Uc31YCU21J8ui
         EdqA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXmcvdXj4QB4wHIgsK5j5HAsa3j6i2+QCYJ1++n3iNPWc+05FK+
	gT6GOh1QRzDP7/vt09eWOGkQkd1wJHgo1dbsH2UxIDXfU8oaflvc6JourUJewfOHt9rdpwwNhoY
	gKXB1HE1ivVMcwMKLFSI0fyu6Xm2eJ9zpXFBUCOH9H7DmGBLbGCeGauktclYUeMM=
X-Received: by 2002:a50:a53a:: with SMTP id y55mr5087684edb.147.1561552586271;
        Wed, 26 Jun 2019 05:36:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0Z0UF5P0JPlljECYMkqbjtZ3EztdpHfFcBTo8TViXxI+PesZUwcjt8AvpTysK5CS4a8os
X-Received: by 2002:a50:a53a:: with SMTP id y55mr5087636edb.147.1561552585633;
        Wed, 26 Jun 2019 05:36:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552585; cv=none;
        d=google.com; s=arc-20160816;
        b=BylMfE7cDviVBYHJEoD9khwqhkyti/+sYv1wLDyi7vhHDZ2CoSwiGXXqCWfECSuADp
         P2t4dCoQqO5qWLr3D/LbS9B5fJf8FSE+w3TI4QnfCnt3UwMlx94aU9sD9/5Pu+jbWbOh
         YRtWw077OIIsl21hjSDYcekISXg3QTORvoZuBSYSPI7/eZ1grS7m1I4g4IO7nJ7qm6v2
         HRmRG2zfRCAjKn2DA4JuHWIUQaSEFanj0EmgrJ5C6iRnTqKu7yAipePrV+dXngMuELxN
         dtjyw2Rf3HA3AXVZCKq7XN7gQD4vkNE4FpchJ4pemOLht+z0rNpZPlS9kItqN3D78UBq
         C25Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FYF6RSAtq6Q8NO3o3rNNecbEL+XtN/rC1H8tS2QMUnY=;
        b=frFwRGtUujWCY4jaik6vOWA9bKF6GXthRG2UNltAVgdkoyi29TU6SmrBnowUncOLt7
         PuetgM1a/u/PPoRWeZ8fd9E4ASZtH/51Xw0BD4mCQHF8d1LKOh8QtjM7MAgQCDwm60oG
         ogcGt78wPx/iEoAdPgvFmr3Rks4F5iJauRyuXUMK6dRO+cdnmvEAWYh/dOca9ZeeZMs4
         eJzQQFOrBqTZDjp6fwvQ/dF7DwtCwkK/fcYLFftqey/fZ+rajPz63stMJ3SJmOoXxDbI
         AlTmTmTBeVG0BLFywIilFNXiynndjC6RlmNR9eEdcRENao6rjR1rD7qZaEvC4p92cfCh
         Jzfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y11si2674015ejp.213.2019.06.26.05.36.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 05:36:25 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A640BAD78;
	Wed, 26 Jun 2019 12:36:24 +0000 (UTC)
Date: Wed, 26 Jun 2019 14:36:23 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 06/25] mm: export alloc_pages_vma
Message-ID: <20190626123623.GU17798@dhcp22.suse.cz>
References: <20190626122724.13313-1-hch@lst.de>
 <20190626122724.13313-7-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626122724.13313-7-hch@lst.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 26-06-19 14:27:05, Christoph Hellwig wrote:
> nouveau is currently using this through an odd hmm wrapper, and I plan
> to switch it to the real thing later in this series.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/mempolicy.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 01600d80ae01..f48569aa1863 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2098,6 +2098,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>  out:
>  	return page;
>  }
> +EXPORT_SYMBOL(alloc_pages_vma);
>  
>  /**
>   * 	alloc_pages_current - Allocate pages.
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs

