Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB1E6C76196
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 17:50:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB94921849
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 17:50:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="CV5RjjFY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB94921849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 483B06B0007; Wed, 17 Jul 2019 13:50:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 462D86B000C; Wed, 17 Jul 2019 13:50:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F9208E0001; Wed, 17 Jul 2019 13:50:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0FD726B0007
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 13:50:28 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id 63so17658043ybl.12
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 10:50:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=SWBqWTLtRGRFAUZCgh3lTPUjJRJ6jQ100pAZoV0UM5g=;
        b=gmqLUoXQ30T3wpvlGz7oy4X31Nmg8+kCjMrJVnWKtwV+N1kngjHOqfAFc5+RnNnwma
         nGiRRVEZomc4IoZMThRyd7NMcUqDmwc9kNGNGP8S9iINeql3ZyP69pIrvSZ+Z2/dJFt9
         5KS7PJxZwPhtO6y0vfbfr0vTwZbMbE850aY75re6ruStQmjLO+UoAeSICU8gVApejtIj
         9dI4/C7yGC8V9tVxxjzWu9KaRp0m9/SJ+rG08nZamqojLpU+9W2jC4Gw3h7xmLmY0kLS
         AqQo0oaOLxAMQxPGE2F5Ng73a5p4s1usYiotUE9rmWW2L+DPCGMS77iBxsvjOM22/o2z
         bJNg==
X-Gm-Message-State: APjAAAVsZfNS8h0/eLm3mzT/+R/oXvtvSyhPEXnzIUqMeOT5/oTNuSKX
	EClBqDaq2VRluHhprTcM+Yd4YmLU0/LzpEVyMBElYZjUEYIHnhLmWscRfq7WcaB7aGDLvEbWG42
	Dy3UX3ZtVefiGx7XXxcPQwFMCu6NKEPwTaxXVSpxC/IFLy5Fda94wdQeeim0QL7Wa7Q==
X-Received: by 2002:a81:9b43:: with SMTP id s64mr25818763ywg.73.1563385827803;
        Wed, 17 Jul 2019 10:50:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyle0Ej7gfwatQsxvGRhlbobrdV2Mp7IkIl9WpY7FhwJ8FYK6t+Bz2VZni7YTrMsEAhPwlJ
X-Received: by 2002:a81:9b43:: with SMTP id s64mr25818726ywg.73.1563385827153;
        Wed, 17 Jul 2019 10:50:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563385827; cv=none;
        d=google.com; s=arc-20160816;
        b=MFXn3onCK6DeeR3dyL6qiLdaCCY6CCECXpW3Eaot0UVtdu6MmUpT1QdPjYidwpyU2t
         w6c/XawBj3JueQUQvOupF1gCZrh+PRDejfUCGbOB8tIsLngpI3YCDPiocFzgBHy69fDO
         qSekwk/QawMFczCBXbi46P0j2SRSQ1mJicq9Ppv6lE75EPJ79UKpjyMJxwz0okFxB6TL
         ETXESw5VsKMULKk958A3c90EwiZqlf2Zj0iY40qumbICOrovEWq41D1XQNOBroD7yNVG
         5yQaflVf41PNdtRrjVx9eGcUZ61hxozeink4iE8Pbb++eSXhQh9HrhPzbnHsj7yol5qp
         4hOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=SWBqWTLtRGRFAUZCgh3lTPUjJRJ6jQ100pAZoV0UM5g=;
        b=ePEzHXcxyMBUv8pl+B3brT4lMNJ8kaZlMDjVO23kF30AiuLyWQSoY3o74A84omqDN8
         ZnS3Sn6N/o5vdylaq4AE0gW+V2wjlDEtKCbDfSil+BjV3XeTQvEIPVCeDtoNmIHHH+e/
         TxXZinhOG4DXJ4Lqrg+G3Mm0pzxOqC/XZM7kOkAXci4Q8s6302whnL/Ws5K9xYS/WNOo
         xRB1XEoDH2PKLBxhTgsZvQTPXeEvYmS5EdTwcChbQUxPWfFppclsmPSCzw4IKjuRcry4
         CowGfEbIsHjYxH1zWxIUc0nEeVqsx+D6LbqRCi+lQpnEMXl6UCOhf1/7L2i/tSzDQZMs
         IMHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=CV5RjjFY;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id q188si11034025ybc.18.2019.07.17.10.50.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 10:50:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=CV5RjjFY;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d2f5fdf0000>; Wed, 17 Jul 2019 10:50:23 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 17 Jul 2019 10:50:25 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 17 Jul 2019 10:50:25 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 17 Jul
 2019 17:50:21 +0000
Subject: Re: [PATCH 1/3] mm: document zone device struct page reserved fields
To: Christoph Hellwig <hch@lst.de>, John Hubbard <jhubbard@nvidia.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter
	<cl@linux.com>, Dave Hansen <dave.hansen@linux.intel.com>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "Kirill A . Shutemov"
	<kirill.shutemov@linux.intel.com>, Lai Jiangshan <jiangshanlai@gmail.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>, Pekka Enberg
	<penberg@kernel.org>, Randy Dunlap <rdunlap@infradead.org>, Andrey Ryabinin
	<aryabinin@virtuozzo.com>, Jason Gunthorpe <jgg@mellanox.com>, Andrew Morton
	<akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
References: <20190717001446.12351-1-rcampbell@nvidia.com>
 <20190717001446.12351-2-rcampbell@nvidia.com>
 <26a47482-c736-22c4-c21b-eb5f82186363@nvidia.com>
 <20190717042233.GA4529@lst.de>
 <ae3936eb-2c08-c4a4-f670-10f25c7e0ed8@nvidia.com>
 <20190717043824.GA4755@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <4295112b-e5ff-f9ad-defc-597ad3bc49a1@nvidia.com>
Date: Wed, 17 Jul 2019 10:50:20 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190717043824.GA4755@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563385823; bh=SWBqWTLtRGRFAUZCgh3lTPUjJRJ6jQ100pAZoV0UM5g=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=CV5RjjFYrtxJBPx50YvgVwuu37aXkSWSWDX7gZc9Perx7pREk/ltNltuoF01N12nF
	 fbcGNahPv9Pu7cj2VWx7kgYouKXYLs74/GvanmWlQgzAEpDd+r92oWoAmxifsQSOjY
	 IZCfGm6yu8dITo783GAtU7Q+sH2EPk3XJuBReBiHhao9nODGOnDHYbAxPp59+502lb
	 1vSZkgb7BwefFsx24B8sNYTUZW17BtBCGEjl7ecTuX83NvLUYsDv8AWDDqHZBPf1J2
	 lV2g4EFQ6YMntYjOwT54R0Kw2q3EvgtT+HYCrx1u69MVIzVv+IMtetkOAJZcos5+bY
	 UxIthrioLOHeQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/16/19 9:38 PM, Christoph Hellwig wrote:
> On Tue, Jul 16, 2019 at 09:31:33PM -0700, John Hubbard wrote:
>> OK, so just delete all the _zd_pad_* fields? Works for me. It's misleading to
>> calling something padding, if it's actually unavailable because it's used
>> in the other union, so deleting would be even better than commenting.
>>
>> In that case, it would still be nice to have this new snippet, right?:
> 
> I hope willy can chime in a bit on his thoughts about how the union in
> struct page should look like.  The padding at the end of the sub-structs
> certainly looks pointless, and other places don't use it either.  But if
> we are using the other fields it almost seems to me like we only want to
> union the lru field in the first sub-struct instead of overlaying most
> of it.
>

I like this approach.
I'll work on an updated patch that makes "struct list_head lru" part
of a union with the ZONE_DEVICE struct without the padding and update
the comments and change log.

I will also wait a day or two for others to add their comments.

