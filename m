Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05160C31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 01:46:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABA8E208CA
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 01:46:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="hZ/DTJ5k"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABA8E208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B9FA6B000D; Thu, 13 Jun 2019 21:46:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36BDD6B000E; Thu, 13 Jun 2019 21:46:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 232396B0266; Thu, 13 Jun 2019 21:46:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id F2B5A6B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 21:46:34 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id b188so912913ywb.10
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 18:46:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=aWY+o31YpTUXYNCWR/tUiybGk+oQfQT9Eqi8enXkBOQ=;
        b=RbCsRye16iUlhdxCbx60GZVxQcUNJn1psOx9UjyCxPjl2OmNNrm2oOEm2c7dssKkLc
         houYrozRg7gmHRv53C0XKL6QoYSejNo9a0seIzyZz6h+XF6U29FzGoCzNw3tIK3FSo/b
         JErhA4PjmVC7OttXUmbDI5liJ0RzHJ40UduQmCZavTtdhZBiT6engaXfe15Xsm7aQItE
         OQ0WAN8iLCb4fxMpZtx0QXIwOfNvK+QxUjvj4qc5VG3RhRxa8bgZt0Lwv1gFUSrVvmGX
         URRllR2zORILZMBOuLTG8iZ7SawoiKDQ+4AXoeD1CuZWELcwkOYx++JxZ4TA8l0qW3i1
         XC9Q==
X-Gm-Message-State: APjAAAUgzShB30J/d+FzSsYj+sEcz5mjZ2nrpxlJZ/9UtCMb2ULqIGDJ
	1N7UPs+C73z3zwCABEb1BQ+X72tOrB3AjlTgpZ5vxoUEJsXDMjPJFKpvpIRsYbiVUfg8s4V5uwz
	aZL/TqdF8oshVtjLO8TcH0AHsixmrjjM8JMx7vfQNZOoGwMbSoqdPrPUmBczc2cTfkw==
X-Received: by 2002:a81:d86:: with SMTP id 128mr7763673ywn.514.1560476794738;
        Thu, 13 Jun 2019 18:46:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbsbSTuPH7oXa2PLe5G0w7CNhx1On4lFEQfv0yWlI0qEWme4ODJw4D2sLTmV9gkCZOdRph
X-Received: by 2002:a81:d86:: with SMTP id 128mr7763660ywn.514.1560476794171;
        Thu, 13 Jun 2019 18:46:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560476794; cv=none;
        d=google.com; s=arc-20160816;
        b=RM0LWKIZncVQQ/XvMHFV9yiJ+2MwXtCYDhMzoyiswRsDCqzxueORmK4f8c4lnf7qyc
         LEsIAfe1oR5Pa/KceNEsRL017gwg1R7WYaAsdi8Cg3Nf416YJrdCA9ic1/OCSsUPrcG+
         AXz6HqqUYekOBDAWUvpzvqr4nI1Gu6VIqr87AwE7iFASXJkQO8tai53fmrf8+ERerh2P
         nEK93RKsfR5lfxSR6KlAwGn55x6F83/jfZOke1wSkAwUIqA8mp6lPcfBnogR6HfMM0wA
         j39/1ky8ObUL676mNew6gQ2ozeGk2Pc8LR6kDGfLP7F9dKfipo2bdbAyTv3Et4486DQZ
         0kuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=aWY+o31YpTUXYNCWR/tUiybGk+oQfQT9Eqi8enXkBOQ=;
        b=cDze7yozpRv7K62pQAnltpHr5y8MYjs/Gv8DDkGi1ksDYlDAbWQBvhjKrQIAw5C3tX
         Yea5JF/NDqqjhDxaER4HyI5dqQSk6Oui7iz2w5Qi9IRgi6SmrlumsCPKbBDDehcyqElg
         o8kSJPHMKYfAHGpmXtMd50Vd35Xmj7tH+Q3SAr6RnHtbVoXkTapwoqInSywKepPNpbPt
         WVZqKjpV0RfNneMfh36/LKLJEx23Ys8Ew//ZaFb7QCNElYCFzUvHOfpXO5udeNG5jp5R
         T0JOj2zsW1tWTsJThc1lTcL0BgYfDcvEHotPL31kViE7nUDZdUGSriWeXJAxukYS5zRd
         RkAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="hZ/DTJ5k";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id x71si569846ywx.166.2019.06.13.18.46.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 18:46:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="hZ/DTJ5k";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d02fc790000>; Thu, 13 Jun 2019 18:46:33 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 13 Jun 2019 18:46:33 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 13 Jun 2019 18:46:33 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 14 Jun
 2019 01:46:30 +0000
Subject: Re: [PATCH 04/22] mm: don't clear ->mapping in hmm_devmem_free
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>
CC: <linux-mm@kvack.org>, <nouveau@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <linux-nvdimm@lists.01.org>,
	<linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-5-hch@lst.de>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <b0584ac6-72e3-08d3-6b76-1ac5e5b3bb4f@nvidia.com>
Date: Thu, 13 Jun 2019 18:46:29 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190613094326.24093-5-hch@lst.de>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1560476793; bh=aWY+o31YpTUXYNCWR/tUiybGk+oQfQT9Eqi8enXkBOQ=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=hZ/DTJ5kKqWdpCL12ZwwtnQNfLWFCFSPcl2k46LOsH4pNokmtsOInOl9+GJ8FKmKO
	 hXZGdDzxG+P+INltKZYs7MH3/UvgeCnHg5hunwwq2bHUiutlLY5os0Z0ZWt+qrOuk9
	 K1Cep9JhG5g0OourqoO6QLKWzZukRM6NdlGEbmjrnoEWvH3YVwufa/VDbhQJ2OHW1T
	 paLBoqcpz6yETgLWr50DBrY8lfihmvAJXfVj+3zCeNHjlAyMFyqJD9rLf7d5TUXr4L
	 SqhY59v6TJmTfzJl0WQ5JTwHaXZZRXMzmrFJGWFYPUDt0cJm6MdR4wx/+QlT3y9K7k
	 1VdCdX4iXd9+w==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/13/19 2:43 AM, Christoph Hellwig wrote:
> ->mapping isn't even used by HMM users, and the field at the same offset
> in the zone_device part of the union is declared as pad.  (Which btw is
> rather confusing, as DAX uses ->pgmap and ->mapping from two different
> sides of the union, but DAX doesn't use hmm_devmem_free).
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
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
> 

Yes, I think that line was unnecessary. I see from git history that it was
originally being set to NULL from within __put_devmap_managed_page(), and then
in commit 2fa147bdbf672c53386a8f5f2c7fe358004c3ef8, Dan moved it out of there,
and stashed in specifically here. But it appears to have been unnecessary from
the beginning.

Reviewed-by: John Hubbard <jhubbard@nvidia.com> 

thanks,
-- 
John Hubbard
NVIDIA

