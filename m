Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2BE8C4CECD
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 21:57:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6263121852
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 21:57:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="eXGoqnFp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6263121852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1FBB6B0007; Tue, 17 Sep 2019 17:57:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD1336B0008; Tue, 17 Sep 2019 17:57:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBEFE6B000A; Tue, 17 Sep 2019 17:57:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0013.hostedemail.com [216.40.44.13])
	by kanga.kvack.org (Postfix) with ESMTP id A456D6B0007
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 17:57:50 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 226FC180AD809
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 21:57:50 +0000 (UTC)
X-FDA: 75945775500.16.range81_445031cc0273d
X-HE-Tag: range81_445031cc0273d
X-Filterd-Recvd-Size: 3997
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com [216.228.121.143])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 21:57:49 +0000 (UTC)
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d8156dd0001>; Tue, 17 Sep 2019 14:57:49 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 17 Sep 2019 14:57:47 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 17 Sep 2019 14:57:47 -0700
Received: from DRHQMAIL107.nvidia.com (10.27.9.16) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 17 Sep
 2019 21:57:47 +0000
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by DRHQMAIL107.nvidia.com
 (10.27.9.16) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 17 Sep
 2019 21:57:47 +0000
Subject: Re: [PATCH v6] mm/pgmap: Use correct alignment when looking at first
 pfn from a region
To: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, <dan.j.williams@intel.com>,
	<akpm@linux-foundation.org>
CC: <linux-nvdimm@lists.01.org>, <linux-mm@kvack.org>
References: <20190917153129.12905-1-aneesh.kumar@linux.ibm.com>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <c7a444fd-d000-27f1-1e03-8ca969ee794b@nvidia.com>
Date: Tue, 17 Sep 2019 14:57:47 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190917153129.12905-1-aneesh.kumar@linux.ibm.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 DRHQMAIL107.nvidia.com (10.27.9.16)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1568757469; bh=NRd/KLsUXIk95j9cFf8vqfZYjuyqqW4KmVN38ZaghQ8=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=eXGoqnFpfPiV2hoNjp/Aeyq0v6cu5e26GQ9/Dr/yAljB21hnXxIo3Uf//tJuMLMXy
	 7nSqkHx2OeceNbY8cLfb65Qi7QUzbJ3rCevwoPyiyQ4R9xaffwoSvR1VBm1fq5z+a+
	 31t9jxYqaG3CaQ5O/NZE0a79ha7H3PWSiKcnF/OKjOCZs0mxDOcDG+FBW4HFLHE3+n
	 RBp55VlR5weLuuGfsWgk1n5otZyXOhM/cJG4BETQUj6ANoduZfi2MjkjX9UY2ABSfS
	 baw5ye3xWTbJhDb6X/6eFtjwdIJMrX+NKtcUCOyqQEqVOB58D/U5WJEnmir+cfT+9K
	 R9ZmBuXUrpMWA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 9/17/19 8:31 AM, Aneesh Kumar K.V wrote:
> vmem_altmap_offset() adjust the section aligned base_pfn offset.
> So we need to make sure we account for the same when computing base_pfn.
> 
> ie, for altmap_valid case, our pfn_first should be:
> 
> pfn_first = altmap->base_pfn + vmem_altmap_offset(altmap);
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
> * changes from v5
> * update commit subject and use linux-mm for merge
> 
>   mm/memremap.c | 12 ++++++++++--
>   1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memremap.c b/mm/memremap.c
> index ed70c4e8e52a..233908d7df75 100644
> --- a/mm/memremap.c
> +++ b/mm/memremap.c
> @@ -54,8 +54,16 @@ static void pgmap_array_delete(struct resource *res)
>   
>   static unsigned long pfn_first(struct dev_pagemap *pgmap)
>   {
> -	return PHYS_PFN(pgmap->res.start) +
> -		vmem_altmap_offset(pgmap_altmap(pgmap));
> +	const struct resource *res = &pgmap->res;
> +	struct vmem_altmap *altmap = pgmap_altmap(pgmap);
> +	unsigned long pfn;
> +
> +	if (altmap) {
> +		pfn = altmap->base_pfn + vmem_altmap_offset(altmap);
> +	} else

A nit: you don't need the '{}'s

> +		pfn = PHYS_PFN(res->start);
> +
> +	return pfn;
>   }
>   
>   static unsigned long pfn_end(struct dev_pagemap *pgmap)
> 

