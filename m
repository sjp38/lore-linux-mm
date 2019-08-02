Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57915C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 04:36:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E743C206A2
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 04:36:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E743C206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51A4F6B0266; Fri,  2 Aug 2019 00:36:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C9FE6B026B; Fri,  2 Aug 2019 00:36:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B8016B026D; Fri,  2 Aug 2019 00:36:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E52616B0266
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 00:36:55 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a5so46177751edx.12
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 21:36:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=GLZjJf/KAYQXPmcVnRlgokZDUTWpduGIGbM80MmMICo=;
        b=HolywzthkegsD6ryMtfMyVtqlqkGxW8sQXA3lkyuaoYfphbQSTmiygM0LAv7QzSD1e
         FChm7nCUi9p5lEEcI+faJeSoB6HdDc5J9pH0+NJORMAli30OhgoDYcbIUUq/Ey48S4xd
         aJCKS3qTFZsY9bZH2Iq1O7pU0zQkw27bAhL1i5diyb9gYOic9Kna2pCTV0zEjU83tcez
         wDQp+kmwrx2/qwajsmdP+8IlAYLL2hYNXlaRbQDziRlA5afB7m0NUaEEV5bF29YztpdM
         shozBLUH/ykMSrhuYFE7NLKfhQP8ynWYbKWQY7M4rV8L7WVjWJ7WKild89GkhtHcdQUo
         Tj+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: APjAAAVbdjbFknRPMhd5sJIIqoal4aR5CtQ5L9/an0Hg5DzW3hfpoZI6
	Kizda0DPS8snp/2PPtWNWplB23ec2lCzc6Hd+6NFrSUPnvmrn3vE+00JJnn3t3IHRCkTy84lotv
	R9eHCDl1mchT/J/Ofz+M2T4V+cybNs2zdDj31fnNWubxgVu7GwxzbM6n47634ZY/pdw==
X-Received: by 2002:a05:6402:1355:: with SMTP id y21mr40771535edw.169.1564720615467;
        Thu, 01 Aug 2019 21:36:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxA9Cs+H+vnL4Uk3WAO7xqaUvwPWts5/Xxw/bEEDJr8ueKdU3S1xeH18RCQyfHjUqZiWXEO
X-Received: by 2002:a05:6402:1355:: with SMTP id y21mr40771502edw.169.1564720614692;
        Thu, 01 Aug 2019 21:36:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564720614; cv=none;
        d=google.com; s=arc-20160816;
        b=OqOu4DL/s7bE8oROnrdgpW3qhFiQ0eAFCRVpLj9++jPSi7KWY1PNnP2LsezFIXAC6o
         ZttrR1vXZMjCplhimjbGKP7/HJ9eMugxmQmE2T+JB9cmwC55OqDuwKIpE/ZV3rRuCXyu
         PGsXrB2pDjOClCTl/BBOmVqVsHRhz5q686kf7jKtyq9/uJ2fqyQQia4mMCMsDBoXYT70
         jyubmlgqJk5Qo+y3rSv6PkGSqtgyZb6LuWN+CRbUt1sPrCN671y1wOgsp75fMUuJLFQf
         0UsbhASdVtei847UrAWClr7agYRXJDBrZMn6HG8gEN0z2sqh8ZWlMdNumKIhTH0luIJo
         K7Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=GLZjJf/KAYQXPmcVnRlgokZDUTWpduGIGbM80MmMICo=;
        b=dAvg5MdcQN82YwE7x27NbFnPBkk8A9ksZGFzIvI7uDfeyVeHrmBIQuBIxYih8Wxwiu
         lDLAE3l0Hgh9SI6eMaeS3Nqhuhd1h1uzCsCBCDnqmUbS7X4evFXztQlfsk8BtlylZ0ja
         sQOkQnWc90SCybRlco6zxqYGZdmI2GQhaZADD96Q2ME4Dfwoyh9ftMWvwlN3nIK0DEM5
         EmQ8Vvlg15Zy/ATvTWYR6J9h4/P+cDbxtwwAq6eDe8/CJ1RJmovbWHvI0RLQkF0zlso3
         6k7TK7ALOaojCS4dCJ+NtUgQ9uYGb44n9yy6lj1cNe/FkFjDEVEXIlo67hZHsXYoE8dA
         QFww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a7si24282932eda.219.2019.08.01.21.36.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 21:36:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 56E85AD2B;
	Fri,  2 Aug 2019 04:36:53 +0000 (UTC)
Subject: Re: [PATCH 20/34] xen: convert put_page() to put_user_page*()
To: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: devel@driverdev.osuosl.org, Dave Chinner <david@fromorbit.com>,
 Christoph Hellwig <hch@infradead.org>,
 Dan Williams <dan.j.williams@intel.com>, Ira Weiny <ira.weiny@intel.com>,
 x86@kernel.org, linux-mm@kvack.org, Dave Hansen
 <dave.hansen@linux.intel.com>, amd-gfx@lists.freedesktop.org,
 dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org,
 linux-arm-kernel@lists.infradead.org, linux-rpi-kernel@lists.infradead.org,
 devel@lists.orangefs.org, xen-devel@lists.xenproject.org,
 John Hubbard <jhubbard@nvidia.com>,
 Boris Ostrovsky <boris.ostrovsky@oracle.com>, rds-devel@oss.oracle.com,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, kvm@vger.kernel.org,
 linux-block@vger.kernel.org, linux-crypto@vger.kernel.org,
 linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 LKML <linux-kernel@vger.kernel.org>, linux-media@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
 linux-xfs@vger.kernel.org, netdev@vger.kernel.org,
 sparclinux@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802022005.5117-21-jhubbard@nvidia.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <4471e9dc-a315-42c1-0c3c-55ba4eeeb106@suse.com>
Date: Fri, 2 Aug 2019 06:36:51 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190802022005.5117-21-jhubbard@nvidia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 02.08.19 04:19, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: Juergen Gross <jgross@suse.com>
> Cc: xen-devel@lists.xenproject.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>   drivers/xen/gntdev.c  | 5 +----
>   drivers/xen/privcmd.c | 7 +------
>   2 files changed, 2 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> index 4c339c7e66e5..2586b3df2bb6 100644
> --- a/drivers/xen/gntdev.c
> +++ b/drivers/xen/gntdev.c
> @@ -864,10 +864,7 @@ static int gntdev_get_page(struct gntdev_copy_batch *batch, void __user *virt,
>   
>   static void gntdev_put_pages(struct gntdev_copy_batch *batch)
>   {
> -	unsigned int i;
> -
> -	for (i = 0; i < batch->nr_pages; i++)
> -		put_page(batch->pages[i]);
> +	put_user_pages(batch->pages, batch->nr_pages);
>   	batch->nr_pages = 0;
>   }
>   
> diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
> index 2f5ce7230a43..29e461dbee2d 100644
> --- a/drivers/xen/privcmd.c
> +++ b/drivers/xen/privcmd.c
> @@ -611,15 +611,10 @@ static int lock_pages(
>   
>   static void unlock_pages(struct page *pages[], unsigned int nr_pages)
>   {
> -	unsigned int i;
> -
>   	if (!pages)
>   		return;
>   
> -	for (i = 0; i < nr_pages; i++) {
> -		if (pages[i])
> -			put_page(pages[i]);
> -	}
> +	put_user_pages(pages, nr_pages);

You are not handling the case where pages[i] is NULL here. Or am I
missing a pending patch to put_user_pages() here?


Juergen

