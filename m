Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 435F4C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 17:47:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA0632184B
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 17:47:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="FfbPZT6Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA0632184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F6CE6B028F; Thu, 23 May 2019 13:47:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A8686B0291; Thu, 23 May 2019 13:47:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6976B6B0293; Thu, 23 May 2019 13:47:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4BB056B028F
	for <linux-mm@kvack.org>; Thu, 23 May 2019 13:47:40 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id d10so5850566ybs.23
        for <linux-mm@kvack.org>; Thu, 23 May 2019 10:47:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=cJu+WJeaivnLRPXuXP9NC7KepKeSbgIbtxawo6JxqHQ=;
        b=Qs56Vk/VrSLntwzUdvFlo2x9IBzpNl26PZkZMrci/oOOk2wndC+sqz/DNV9toxovkf
         caV+xnxuWMmjOqkmkd9DuXcbHY4nZbZ2yrgVcQ9t4I8uPzq2tEk1j1Qhh+37dtgSAw2Y
         rvUvIZ7iO699irOVavmB5HXnzJ6RPw1noOz2Ifd7oz5gl1vgqy8Tu+nC3QLq0BHqrM0f
         busZAT0kGrnyrfZbN8yDXRpmL+JpanD1/xN/6kljJ1pZwW7IbHZ6dv3bGqTTTCx7QtFs
         F+Irfy9J1KRal2DtZlQAdwoC7jbNSvCJBtbrYDyUrvjzXHDGA/3BhGpJM7NLxa8FmMzi
         aNEw==
X-Gm-Message-State: APjAAAWjgds0xW+10yow73wFobRBZ1hdRLtzawpRNzpeWf1SY3pseqo3
	NtWKxTSpw1IpJfID31rEyygFzRZsk+bp49GQqBtR/2Izb7akiEuLtXLHjbw+jnbF0UMwD+YA9gE
	Co72LYwm/bKcuLmK3+SW1Qm6PAND8UAF7uCmOE+zV+YkrlVM3FPA+ZnH/FuQR/iCO9A==
X-Received: by 2002:a81:5741:: with SMTP id l62mr37688631ywb.4.1558633659938;
        Thu, 23 May 2019 10:47:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLeigXKggaD4Puj/EK7vM+hCAZ13JUToL0OAH4ec5AsD5Wqlwk06GlStZdxhQaIsyQh/TF
X-Received: by 2002:a81:5741:: with SMTP id l62mr37688607ywb.4.1558633659326;
        Thu, 23 May 2019 10:47:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558633659; cv=none;
        d=google.com; s=arc-20160816;
        b=FFm/wnyNxElYcS16PBjhYhDraZsu6vDx4zM3NtrZYSfqsgBzuY88Sm3+BJu91sFlmY
         iWrLJR37R4MoD3RwQf0ysMXap+C7HGUGNmxaPDkbmmBTW8vfKKqg7uFdD7CQbJMsVUPo
         RqWRby7Q0Cbf7KogaEjAwSTD67TRpuMHmWdQGe+IC/y2e2yFrQF6pQj3kJpSmoMyAiW5
         md468JP8IEJya8CEzv2PIDSvdv2Isg/iVW63hiPzoKJ3oFyuCOmYZTakygsYDwpxQGWY
         Dyi/ZowI5OErKMdUto/oQ8d5wUjaTLxI7r/IjE/lvkYWoCKj8lHadke4bBvG/Wm7Y4vK
         47Yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=cJu+WJeaivnLRPXuXP9NC7KepKeSbgIbtxawo6JxqHQ=;
        b=Dr6YSIP62xl0POXdfHHbMylRNtdCUYIU0IBqPaEYDvKOTIfMWZWjR1qREZCLtPiWS8
         QFi2rR0t12LlAQ5i5+q3FVi6vECWHyiwFDguMTMs2/StYw5/kpTTvmwtpGYJwTKTM+aJ
         dv6lQTlaGUlAtX63Bc6lvx3cSJPsecPbS6s/YFZrrlotvcauLNAPJ6vzSkI4Yr1oubaf
         +RNxL13QtRFLDOHXPouRR2IrAXGqEKacYX8n0I7y8CHE0PRQ2JwE7yHZdIn7nAc7HWOP
         rr60Ha2/9KH792et+Nux00+tWPstYVbZbHM3i/NAMc7xJ8FMSQgxYIcIS5LibyQyJBBP
         sSrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=FfbPZT6Q;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id u17si8840900ywu.114.2019.05.23.10.47.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 10:47:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=FfbPZT6Q;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5ce6dcb50001>; Thu, 23 May 2019 10:47:33 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 23 May 2019 10:47:38 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 23 May 2019 10:47:38 -0700
Received: from [10.2.169.219] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 23 May
 2019 17:47:34 +0000
Subject: Re: [PATCH 1/1] infiniband/mm: convert put_page() to put_user_page*()
To: Jason Gunthorpe <jgg@mellanox.com>, Ira Weiny <ira.weiny@intel.com>
CC: "john.hubbard@gmail.com" <john.hubbard@gmail.com>, Andrew Morton
	<akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML
	<linux-kernel@vger.kernel.org>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>, Doug Ledford <dledford@redhat.com>, "Mike
 Marciniszyn" <mike.marciniszyn@intel.com>, Dennis Dalessandro
	<dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>, "Jan
 Kara" <jack@suse.cz>
References: <20190523072537.31940-1-jhubbard@nvidia.com>
 <20190523072537.31940-2-jhubbard@nvidia.com>
 <20190523172852.GA27175@iweiny-DESK2.sc.intel.com>
 <20190523173222.GH12145@mellanox.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <fa6d7d7c-13a3-0586-6384-768ebb7f0561@nvidia.com>
Date: Thu, 23 May 2019 10:46:38 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190523173222.GH12145@mellanox.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1558633653; bh=cJu+WJeaivnLRPXuXP9NC7KepKeSbgIbtxawo6JxqHQ=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=FfbPZT6QVH6VAlR1feLRskrMhm5Y90TbypPeesLGrfGfd7gw4yml32K5pWQRTfTer
	 D4rsycEUWb1uIuGiI+4NyFotZpYk072iAv6M8985uVUZB5YnFvYcHUzwdOgwYBYvk7
	 Oie7zgGrFj5klPYmfYYnJLwI+Mge3sPjjJ59YitQTd/QDOLRYLZpNkZ9gYH2Sva3tp
	 kd7kFGqP9BgfExZaQ8g6ePlt9zkuiWwkJurGW+wpfiR6jXlQTPjLzyq2/ZAvuAl/Gj
	 VgraXs1B91kLLWDN9ZQ5eNpaxgFv9Xv1QqMz+EDdPjAXr0uclLOfBp+7vD31LhjHgI
	 35gTwnCDBIXBQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/23/19 10:32 AM, Jason Gunthorpe wrote:
> On Thu, May 23, 2019 at 10:28:52AM -0700, Ira Weiny wrote:
>>>   
>>> @@ -686,8 +686,8 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
>>>   			 * ib_umem_odp_map_dma_single_page().
>>>   			 */
>>>   			if (npages - (j + 1) > 0)
>>> -				release_pages(&local_page_list[j+1],
>>> -					      npages - (j + 1));
>>> +				put_user_pages(&local_page_list[j+1],
>>> +					       npages - (j + 1));
>>
>> I don't know if we discussed this before but it looks like the use of
>> release_pages() was not entirely correct (or at least not necessary) here.  So
>> I think this is ok.
> 
> Oh? John switched it from a put_pages loop to release_pages() here:
> 
> commit 75a3e6a3c129cddcc683538d8702c6ef998ec589
> Author: John Hubbard <jhubbard@nvidia.com>
> Date:   Mon Mar 4 11:46:45 2019 -0800
> 
>      RDMA/umem: minor bug fix in error handling path
>      
>      1. Bug fix: fix an off by one error in the code that cleans up if it fails
>         to dma-map a page, after having done a get_user_pages_remote() on a
>         range of pages.
>      
>      2. Refinement: for that same cleanup code, release_pages() is better than
>         put_page() in a loop.
>      
> 
> And now we are going to back something called put_pages() that
> implements the same for loop the above removed?
> 
> Seems like we are going in circles?? John?
> 

put_user_pages() is meant to be a drop-in replacement for release_pages(),
so I made the above change as an interim step in moving the callsite from
a loop, to a single call.

And at some point, it may be possible to find a way to optimize put_user_pages()
in a similar way to the batching that release_pages() does, that was part
of the plan for this.

But I do see what you mean: in the interim, maybe put_user_pages() should
just be calling release_pages(), how does that change sound?


thanks,
-- 
John Hubbard
NVIDIA

