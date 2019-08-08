Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 690C3C32756
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 19:20:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E24562173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 19:20:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="fR5j9wfS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E24562173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BBF56B0003; Thu,  8 Aug 2019 15:20:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56AC76B0006; Thu,  8 Aug 2019 15:20:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 433F86B0007; Thu,  8 Aug 2019 15:20:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 081B16B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 15:20:11 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 6so59742457pfi.6
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 12:20:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=gyjAPj2n6Df+meBITnObLks8CStskxi0utl7evTCTTw=;
        b=NI8RXwUNHpNOhVn7gFAisGrEFGH0ydjKIIF9V1WG9k9okLuXIXbL0AYmNNMXPxMMFr
         ToIiMmDqofDgfw/M1tWNHIeMUDkK6BEmbAcHAmLJTYbncRwML6bhsIFwDFrvtBXmlDMk
         aUiUd/uFwvTJ/s4pCoSXvSMo/Ab//L946fEX5Dfky8J1c5JvjhqDC2n+sRY6O6kg8KwZ
         ZRo84ooc2ePyoGfXUuxYpFT6682HGZJyq2VAAACvL50H7gOGAWOdZK9Pfa3RiUFqN2+C
         lCai61X8Z5RKkaV265j+5bAzjEXys2yxayw/EbFP8AW+GD6zeFJEUMAU0ZmFxC0R8YhF
         Id3g==
X-Gm-Message-State: APjAAAVJGWckfo4BvD97Hy+pZrGojOr7rlTuDeKuwrTP3o9G40mHeMuU
	v3hUyFvbxhMs4ibM+ryIFdqHuNZGweSbdojtM5wgHnw4pHgKtAAjaTJuMQO3/nNJSm9Eep1VjK2
	TxckoxWLBv+UyZ2/NWuKA2H/KYH4ZVK7FSvzrkoA3CbHb2eamWj1BOQrgygygRzFoiQ==
X-Received: by 2002:a17:90a:1a0d:: with SMTP id 13mr5348477pjk.99.1565292010624;
        Thu, 08 Aug 2019 12:20:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx63spt33R9G9LPguAlwJ3LDk58M2C6f4nJk4Au5kN76FHAOKOxNzJPMl7T1camR6QGcOHd
X-Received: by 2002:a17:90a:1a0d:: with SMTP id 13mr5348433pjk.99.1565292009837;
        Thu, 08 Aug 2019 12:20:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565292009; cv=none;
        d=google.com; s=arc-20160816;
        b=scvMKzAQa5NMfcm+7R2V7GOShxig9WnId6ZJ3Zl7ukhcvz8W9i5A5ImJnEphvYCzoJ
         UZYNoOaHR1mMqQZqOw1EmG1+5SniXDy15Z0djTEqgBDiXrewb3pqnditnVS3merKIm2v
         XPk0EHP28jx+QUxTKiXfrZTd4xzNUW9z9/u8z9vpBJdbdqMcrUzb/1T5LtZiylAzkTyV
         u18E8CpzpY3vqDJXM3E2/Lk6yr3oyjRq7P5GifYd1AYsq6zOyzDPIv2tSEcBQcGrsAXN
         6LUTMX+eUrwcZBHzpRFmGlx92ATlNXPdXHYFcESGnS7J2jTjCObYhAeIMbLCjWZUTDlB
         KAdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=gyjAPj2n6Df+meBITnObLks8CStskxi0utl7evTCTTw=;
        b=tX8Pq4R/hwxP/YA4gXfK7OusooimemystYrTj7Wap20FoG2eTNB4nrLBIpqVc0uZIP
         hBwae16ariJ2sXkHTt6MH4kUFomcrKtIlJ+V5+TEvw48jQZM8ZNkW8OB72f82ZrrghHO
         KltMHLrSzuz0C6smMsLjXBjZocYCmNFRysZOarWlmOuOteTyeTfqd/PfaMpk8rF7JsAh
         C8eYSE2tvXKglEuI6K7+iNvqAATxpAF24pPgWa8DGx+XB96LtlShAM1K4JIaNmk7wWS/
         hNF6MkyhBSUS1ot5HGAO+GBdN0OvbSUwBnNQpb7yNMWnme1CtZVzVdCq8Y9cVLYTUZgl
         v/2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=fR5j9wfS;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id bh4si49326849plb.198.2019.08.08.12.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 12:20:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=fR5j9wfS;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4c75f30000>; Thu, 08 Aug 2019 12:20:19 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 08 Aug 2019 12:20:09 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 08 Aug 2019 12:20:09 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 8 Aug
 2019 19:20:08 +0000
Subject: Re: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>
CC: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
	<hch@infradead.org>, Ira Weiny <ira.weiny@intel.com>, Jan Kara
	<jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse
	<jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>, Dan Williams
	<dan.j.williams@intel.com>, Daniel Black <daniel@linux.ibm.com>, Matthew
 Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>
References: <20190805222019.28592-1-jhubbard@nvidia.com>
 <20190805222019.28592-2-jhubbard@nvidia.com>
 <20190807110147.GT11812@dhcp22.suse.cz>
 <01b5ed91-a8f7-6b36-a068-31870c05aad6@nvidia.com>
 <20190808062155.GF11812@dhcp22.suse.cz>
 <875dca95-b037-d0c7-38bc-4b4c4deea2c7@suse.cz>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <306128f9-8cc6-761b-9b05-578edf6cce56@nvidia.com>
Date: Thu, 8 Aug 2019 12:20:08 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <875dca95-b037-d0c7-38bc-4b4c4deea2c7@suse.cz>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565292019; bh=gyjAPj2n6Df+meBITnObLks8CStskxi0utl7evTCTTw=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=fR5j9wfSfwQnIbtxsXQwVx4m3yEG1GHbyByYyV5gBzEBx59m1WUifbcholhHCK1Wo
	 yqui8gxSIgvO77jrIShOyraDGi8GvTWgxnIzH9c7B1A2X+bMRJbWsF1PRMy/yqnhfu
	 nVLVHLIhW6NC78g+Pyp30UxKkteVz1hv6VkK3OjkudSDJPyBjdwXgHxeBp+f5b3edQ
	 ucC1fmBED476OuRsEuz+3ClDMQXqRciY6Ae22F230ne/YZWk4EgL+Skzzl5hlJvrho
	 7gV35HBjUQDHyt05Ls6FypCgMmDbJcqXz9Saz9CMNTsAWHln8fS3RvG8Q2UTphHb3Y
	 pKMkidlRP1ZQw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/8/19 4:09 AM, Vlastimil Babka wrote:
> On 8/8/19 8:21 AM, Michal Hocko wrote:
>> On Wed 07-08-19 16:32:08, John Hubbard wrote:
>>> On 8/7/19 4:01 AM, Michal Hocko wrote:
>>>> On Mon 05-08-19 15:20:17, john.hubbard@gmail.com wrote:
>>>>> From: John Hubbard <jhubbard@nvidia.com>
>>> Actually, I think follow_page_mask() gets all the pages, right? And the
>>> get_page() in __munlock_pagevec_fill() is there to allow a pagevec_release() 
>>> later.
>>
>> Maybe I am misreading the code (looking at Linus tree) but munlock_vma_pages_range
>> calls follow_page for the start address and then if not THP tries to
>> fill up the pagevec with few more pages (up to end), do the shortcut
>> via manual pte walk as an optimization and use generic get_page there.
> 

Yes, I see it finally, thanks. :)  

> That's true. However, I'm not sure munlocking is where the
> put_user_page() machinery is intended to be used anyway? These are
> short-term pins for struct page manipulation, not e.g. dirtying of page
> contents. Reading commit fc1d8e7cca2d I don't think this case falls
> within the reasoning there. Perhaps not all GUP users should be
> converted to the planned separate GUP tracking, and instead we should
> have a GUP/follow_page_mask() variant that keeps using get_page/put_page?
>  

Interesting. So far, the approach has been to get all the gup callers to
release via put_user_page(), but if we add in Jan's and Ira's vaddr_pin_pages()
wrapper, then maybe we could leave some sites unconverted.

However, in order to do so, we would have to change things so that we have
one set of APIs (gup) that do *not* increment a pin count, and another set
(vaddr_pin_pages) that do. 

Is that where we want to go...?

I have a tracking patch that only deals with gup/pup. I could post as an RFC,
but I think it might just muddy the waters at this point, anyway it's this one:

    
https://github.com/johnhubbard/linux/commit/a0fb73ce0a39c74f0d1fb6bd9d866f660f762eae


thanks,
-- 
John Hubbard
NVIDIA 

