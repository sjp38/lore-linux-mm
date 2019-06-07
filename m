Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB834C2BA1D
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 00:44:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 913A820840
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 00:44:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="YFPe9L12"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 913A820840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18D386B0302; Thu,  6 Jun 2019 20:44:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 117586B0304; Thu,  6 Jun 2019 20:44:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF88E6B0305; Thu,  6 Jun 2019 20:44:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id C43666B0302
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 20:44:18 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id d13so163509oth.20
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 17:44:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=+Mit/5a+rC2Wlxiu6u6imSr0LN6DP+ltnocf5OY9+X8=;
        b=HMHNb9ZEGV3Zk4etdNl8m44FEjMt74hVvq6d7KfG+ICE8/JCVEyP/cqkrvXY425Nnc
         AWx8QT2xAGWpk6EgcazCa6ItDtq/bjmGOCvidf4n80N9wQVw3e8c606gq0bUi9R/iDof
         1DfbMWl0cDSnEBcDjSI1F0sLRtlN4n+IEHxky9k0YqvQcTgD+9rUI7y1KLGOX9kW1iHZ
         JVYVGzvKuAvQhUaael0h86uFmYqPLRxtaa0+ZOLy+G7Xo47Wdyd5DkGN7yS7B5V0S3FV
         G208gpUicREK8j/MyhYtw4LH1fV7oVP3CByWPk0TyhkOPtP0jQYiteARWnjYqxZKXRXq
         2UpQ==
X-Gm-Message-State: APjAAAXW1Ip3xyxF1/3t/ROSWS1w4lmYGW+2cN4DK11HCkmhDclvu7KN
	SqZ4Lb2atJXjlh5iFcewtvRaFfPI4so+PbiWH04JH9vuMi7JStgh9qhgBu1MdzyNe94YyS2TPle
	UsKc1MGTOTZjq8V8uUe2VsNg492o7/lRin2Y52KlXuVEtaZ2bNN8Qbu3GtYqhnv0V0g==
X-Received: by 2002:a9d:7c8b:: with SMTP id q11mr9867834otn.161.1559868258361;
        Thu, 06 Jun 2019 17:44:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHDF6a4gVw/RoFZ4123zbtZqRpmJW3K2VLPuRnyXEvuWszqfghw3NAGch1kjC88fo8/hah
X-Received: by 2002:a9d:7c8b:: with SMTP id q11mr9867801otn.161.1559868257646;
        Thu, 06 Jun 2019 17:44:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559868257; cv=none;
        d=google.com; s=arc-20160816;
        b=aXA422Zy9rt73I8D5VYZhSbAApRNMW2xg0EcCdwo6cNdrVUQqp75KMjfYD6DFi++wn
         ORWCzALoES1YwNCw4J+UyeiEJwr6WnwFLgAZybXAS5/84ol2JWatZIMV5g/8Vs/wekvD
         Ey5LQ3lOFPa6HZBwfjtHnH0A6qKpm6tCkyh+uGsxU/jxal4KMoXCWa4uY1770EH0mkHX
         83MmVtO7XDSvtEd0RnOmWO0RpBk7DTWKqtYkwfAtvG/10kkztrdlL121iORGdvEbMKCa
         WxWcvUf2iBevSrjM60KlUgpqk9KXUxT0AHRdySq6GVFlsyPJjnl25v6jz8BXYLjLnDlz
         fCtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=+Mit/5a+rC2Wlxiu6u6imSr0LN6DP+ltnocf5OY9+X8=;
        b=P8LTfkaGFzDinWlLlpsZnXwkyry6WbJ0NkFyENrLmTsd/td0knHEfeBw641zQRz2yj
         AYVzsR7NQ1g50IN1xJffjZrs4ejO9d4N1UuOk91dTLI/5GNsoYwr5zV/HY8aNgWX1UTv
         xtAm6CBErx3O3GdyOTXkqE3+to/DeWpU3mBROsIZlmzRJD6lJabe9uUho89fMuiAw05h
         nuUAEn8zfY+LZshYNURC7t/bVIn9ERYR2W3wMFyZQvLZyzmLmQi9z7y6mGC4MjkywOs1
         m0jHHbnpSs/BA9kSy7v4cxxD7h6r+NF44b8zJ9EQ7uwKKREqV/c7YgH+cQqNx17gt42L
         yPGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YFPe9L12;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id c90si313814otb.198.2019.06.06.17.44.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 17:44:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YFPe9L12;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf9b35e0000>; Thu, 06 Jun 2019 17:44:14 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 06 Jun 2019 17:44:16 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 06 Jun 2019 17:44:16 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 00:44:16 +0000
Subject: Re: [PATCH 2/5] mm/hmm: Clean up some coding style and comments
To: Jason Gunthorpe <jgg@ziepe.ca>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, John Hubbard
	<jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>, Dan Williams
	<dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh
	<bsingharora@gmail.com>, Dan Carpenter <dan.carpenter@oracle.com>, "Matthew
 Wilcox" <willy@infradead.org>, Souptick Joarder <jrdr.linux@gmail.com>,
	"Andrew Morton" <akpm@linux-foundation.org>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
 <20190506232942.12623-3-rcampbell@nvidia.com>
 <20190606155719.GA8896@ziepe.ca>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <3a91e9a7-e533-863b-ee5f-c34f1e10433c@nvidia.com>
Date: Thu, 6 Jun 2019 17:44:15 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190606155719.GA8896@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559868254; bh=+Mit/5a+rC2Wlxiu6u6imSr0LN6DP+ltnocf5OY9+X8=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=YFPe9L12IwlVFW/uqZXMuLBzFKRY4kU3BNWs7W76LnhmesrNFPJru/HQ0xy/VzFq7
	 iFqW/b8g6EGJGXC3ipAcfMEEgdVqJ+2B5Qrod5NcuYzHnGO2makj85RecVap7Qahsq
	 BGrWOKjjUAkZ9dSKp0uN3V8bf9uCsZsafyvSRsDFxFbttruxdRiTJU0P0vlCIES0Jy
	 UoY9M63J7l2A0EenhMJegmbfcEg45stvVce39dcwAUUokWhazrFOCWYNSymbJwfZMD
	 dh2Q/lRs3T5Mp7NDJS/TJOPEhmq8AGBKL4clWVFq1oVY9AUEPnTAWftTnLu646cdCo
	 uu6whBYo7fVGg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/6/19 8:57 AM, Jason Gunthorpe wrote:
> On Mon, May 06, 2019 at 04:29:39PM -0700, rcampbell@nvidia.com wrote:
>> @@ -924,6 +922,7 @@ int hmm_range_register(struct hmm_range *range,
>>   		       unsigned page_shift)
>>   {
>>   	unsigned long mask = ((1UL << page_shift) - 1UL);
>> +	struct hmm *hmm;
>>   
>>   	range->valid = false;
>>   	range->hmm = NULL;
> 
> I was finishing these patches off and noticed that 'hmm' above is
> never initialized.
> 
> I added the below to this patch:
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 678873eb21930a..8e7403f081f44a 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -932,19 +932,20 @@ int hmm_range_register(struct hmm_range *range,
>   	range->start = start;
>   	range->end = end;
>   
> -	range->hmm = hmm_get_or_create(mm);
> -	if (!range->hmm)
> +	hmm = hmm_get_or_create(mm);
> +	if (!hmm)
>   		return -EFAULT;
>   
>   	/* Check if hmm_mm_destroy() was call. */
> -	if (range->hmm->mm == NULL || range->hmm->dead) {
> -		hmm_put(range->hmm);
> +	if (hmm->mm == NULL || hmm->dead) {
> +		hmm_put(hmm);
>   		return -EFAULT;
>   	}
>   
>   	/* Initialize range to track CPU page table updates. */
> -	mutex_lock(&range->hmm->lock);
> +	mutex_lock(&hmm->lock);
>   
> +	range->hmm = hmm;
>   	list_add_rcu(&range->list, &hmm->ranges);
>   
>   	/*
> 
> Which I think was the intent of adding the 'struct hmm *'. I prefer
> this arrangement as it does not set an leave an invalid hmm pointer in
> the range if there is a failure..
> 
> Most probably the later patches fixed this up?
> 
> Please confirm, thanks
> 
> Regards,
> Jason
> 

Yes, you understand correctly. That was the intended clean up.
I must have split my original patch set incorrectly.

