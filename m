Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5ADADC41514
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 01:01:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1405A2067D
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 01:01:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="ajEzn9uW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1405A2067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FBFD8E0005; Tue, 30 Jul 2019 21:01:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8858B8E0001; Tue, 30 Jul 2019 21:01:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74D148E0005; Tue, 30 Jul 2019 21:01:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F3D58E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 21:01:16 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id f1so50459208ybq.3
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 18:01:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=OHyHSrA6JVDY2Oejcs6WpJIunzrly1fjS6RVFY7YqjM=;
        b=IWfuAJ8SNNp0+36n/De3PORWX64nVwqD1GDqdF1jjR9VFFszvvqAQ2l6xYw6UoKZ0H
         RF93IN4GPgqdlHdQjSpusQAEmPJX4GGtSNnV9Fd9GeZuVCeDo4A36U3NCANaikxwyBm6
         yPw/sgj92TBP2djMy7BEU+dQj6LQ4QBei/79cq7Aa+3jv7EjwMzRy93L5ahPInG6KUq2
         5qyImeUJXJxe3KDzh85IXcnK9AUoWzVTSjIqAg5fCh28ihAYuE2G1ICErv6pkcp0A4u0
         ZXBUAum8r8CqtpzGdgonrwPr6a497PuZButdoaFY9bzgnJSPFha7wWQwIp6sOhLKdX/Z
         36yA==
X-Gm-Message-State: APjAAAUizNzi4AH/P1wpf8l2kQrLbePkte/p+lTlEyWVjp5DzuJ3TgN8
	l8/N0TCkR9D+EJ5/t1Ekrto5XvEfq/L1+GwaI5DEQ0puxIGaGwy1sf8iGwQVOmCE7jyvtfJ0mAZ
	lm1E5uv6roPR7xDPVGZbHj/F2A7nePrMt5NjqxA55FFYcB50H8K5DB/PXcgKrZXi1VA==
X-Received: by 2002:a81:2905:: with SMTP id p5mr72453638ywp.357.1564534876019;
        Tue, 30 Jul 2019 18:01:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOmS9UbHJ4xkyFkMhtYl3Vi0AfcbvpmfbCAlQXQ0I71+ync2AvAcLVjvAZnWbaZ/p0E+wp
X-Received: by 2002:a81:2905:: with SMTP id p5mr72453587ywp.357.1564534875313;
        Tue, 30 Jul 2019 18:01:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564534875; cv=none;
        d=google.com; s=arc-20160816;
        b=JPJOBLFkq/gOpUqBqM90vMnTLNTVvHTCmlFp+yOuoAwJ9YplzOdnS7hjTVQNJ+Q3jX
         Zkx42Bj2Xxi4RqueSGp1eLqfDWjBg2EkfMyCtLU2WxkPInWlhudBbNauswhuzzAUkK4N
         UwRihVFSN91lAdJCqvNGlH/8ajJeoh35ojiUXVPSSUXGvqYL06wacXcMhAZnrRZaYC2o
         axZhz/beKDHnUIhSm2j1Zk5DfXfjvwy8zCnIMB9suvy7BW9DWdPnmDZrtk85A74PPSHI
         RGDQY4eNTqOlKGZZQDJC3Ld5qc8+jlGGrXmv/hAoyORPWJHzkSURRfeGxt9dPXHuyFnZ
         AZaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=OHyHSrA6JVDY2Oejcs6WpJIunzrly1fjS6RVFY7YqjM=;
        b=08wWYtedfmdQB6jBTO8Juni8NGAL0Kax81EzGxuujKjOG+L6bXEq0qPC6Co7FEMQNf
         Yu2hx1iqWgfFfoNTVtdWGbsPElooJpk8ZD9MGMXc/GZ6tqUEZ7sYRKd+aYpfRu5Bz4Vt
         yOn/ToC40Dj6UanTTt8As1dfN3rjW+Krvj7jm0hiKPfmc8MZ0NThDZn6/INW7f/4cMNc
         gNkOXhTH+HjSVZwfZ64aGTNw027YXD/ZDEev2r7biGUbHiqakuUCrTMUbC0Vmr8FwtTU
         75I/UnnlWN6C6KEP/cYGHfC97mrWNmiaI4sNpj38DJEz6qG3/44fEeR13fZuvmADlqc9
         zUNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ajEzn9uW;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id e67si18047292ybe.425.2019.07.30.18.01.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 18:01:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ajEzn9uW;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d40e8620000>; Tue, 30 Jul 2019 18:01:23 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 30 Jul 2019 18:01:14 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 30 Jul 2019 18:01:14 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 31 Jul
 2019 01:01:11 +0000
Subject: Re: [PATCH 08/13] mm: remove the mask variable in
 hmm_vma_walk_hugetlb_entry
To: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs
	<bskeggs@redhat.com>, Felix Kuehling <Felix.Kuehling@amd.com>
CC: <linux-mm@kvack.org>, <nouveau@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <amd-gfx@lists.freedesktop.org>,
	<linux-kernel@vger.kernel.org>
References: <20190730055203.28467-1-hch@lst.de>
 <20190730055203.28467-9-hch@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <5f8e6310-5e97-3e57-bfbf-5eef553b4d91@nvidia.com>
Date: Tue, 30 Jul 2019 18:01:11 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190730055203.28467-9-hch@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564534883; bh=OHyHSrA6JVDY2Oejcs6WpJIunzrly1fjS6RVFY7YqjM=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=ajEzn9uWQgkCJeHEaoBa1ebIKX456rMGd39kWLEC/7A9cOmd9kLxD/rfHhXnnzvtr
	 p8dxFxMmc9Ht+btkwqvj95qMs6DnmoOqgpiDmTYwV4dQWlBWsw5Les1qXHiV0VM+pc
	 6eLW+qk0O9HGG/H3cFIxfLKOcWS5roJB4JnQLeWEgBgvU0eJQEGHKIwFkwqHg8yEvK
	 UqHAkGFEpMKcWKCnqFErM2grwMv5QR13mPLqhQIdIi6Nq4GCA2AI47+gTlrUlw3Bz/
	 teNwUz4zv3BXuhvbEzfoJagndrzFIMXS9QDwkJi6PrOjJJZYCP5Xb7mMbAmAJq3QId
	 Pp062/GoAjfpg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/29/19 10:51 PM, Christoph Hellwig wrote:
> The pagewalk code already passes the value as the hmask parameter.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>   mm/hmm.c | 7 ++-----
>   1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index f26d6abc4ed2..88b77a4a6a1e 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -771,19 +771,16 @@ static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
>   				      struct mm_walk *walk)
>   {
>   #ifdef CONFIG_HUGETLB_PAGE
> -	unsigned long addr = start, i, pfn, mask;
> +	unsigned long addr = start, i, pfn;
>   	struct hmm_vma_walk *hmm_vma_walk = walk->private;
>   	struct hmm_range *range = hmm_vma_walk->range;
>   	struct vm_area_struct *vma = walk->vma;
> -	struct hstate *h = hstate_vma(vma);
>   	uint64_t orig_pfn, cpu_flags;
>   	bool fault, write_fault;
>   	spinlock_t *ptl;
>   	pte_t entry;
>   	int ret = 0;
>   
> -	mask = huge_page_size(h) - 1;
> -
>   	ptl = huge_pte_lock(hstate_vma(vma), walk->mm, pte);
>   	entry = huge_ptep_get(pte);
>   
> @@ -799,7 +796,7 @@ static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
>   		goto unlock;
>   	}
>   
> -	pfn = pte_pfn(entry) + ((start & mask) >> PAGE_SHIFT);
> +	pfn = pte_pfn(entry) + ((start & hmask) >> PAGE_SHIFT);

This needs to be "~hmask" so that the upper bits of the start address
are not added to the pfn. It's the middle bits of the address that
offset into the huge page that are needed.

>   	for (; addr < end; addr += PAGE_SIZE, i++, pfn++)
>   		range->pfns[i] = hmm_device_entry_from_pfn(range, pfn) |
>   				 cpu_flags;
> 

