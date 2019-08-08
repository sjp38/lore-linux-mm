Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7B33C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 11:09:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82AB52173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 11:09:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82AB52173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 137966B0003; Thu,  8 Aug 2019 07:09:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C12E6B0006; Thu,  8 Aug 2019 07:09:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7C2D6B0007; Thu,  8 Aug 2019 07:09:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 91E926B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 07:09:23 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d27so58023508eda.9
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 04:09:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=VcAu0vWiaogKbjBYkJMxyEU2lb/0O17kaTeHoDrcCP4=;
        b=W4Cl1WmdqGDhvojnu/6APg1Vxx+JW5oSVabGBv2GlBkOXMApTc5RtMsRb/trNKSrQs
         1Tj5pRcl4I0Q55bQTO3fpWxZ7VU8Rth7DUd5gz/BTy1QVIDFt7Pf6LKfFEJKit1KWbEb
         W52Wm3Vn6O8eZ14eiU6YeMmz/3pAy22ennNPpZ8lYOXs71Uy6Gv+GEXs8GOcPmo/ar5K
         p5vQzFpb0MV2wVuWLvuAhvAvGo2GQLw499akl3yYXaRp7+/TU/XeA8A1gx5Q+LAKQx9O
         DUv26mfxhYhwQjWmWFDVF4OgLg+cfnFAV0KsbiL4loCKjdc2LYlwn7tRsSlpoamZGWnq
         LQnw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAVkRgnxDbY2uv9KzuskQ92OYTEqwDFwhcdjZBXP9J+xepx7Kd16
	CHtUlnTlzQv4pt9borbghX1ROqqDQ7L3inkcXLHB7AvEQzlaCwtxA3G7tKjQ/S2SXMdyUVCdRGO
	ARBWQweZjUH94iHcQf/DQtaVntKej85Ec7gXh8kt1QghbG/t+RJZ5OWPzc+jMTcnj0Q==
X-Received: by 2002:a50:eb96:: with SMTP id y22mr15096755edr.211.1565262563164;
        Thu, 08 Aug 2019 04:09:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxszYRGC1MVs1cDHr07qYduKQmOlEpixzupbFddX6vXzzVMd9kPbL5kxf5UZ+rUsx/SLz/Z
X-Received: by 2002:a50:eb96:: with SMTP id y22mr15096687edr.211.1565262562357;
        Thu, 08 Aug 2019 04:09:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565262562; cv=none;
        d=google.com; s=arc-20160816;
        b=GAqkmrviziej6924Aw2Qtx9zsxzXVOmBMJ5y70vZL0P+WoI8eEwi4u2VVUvlSjMruN
         vZ19YXurkx5XazwlxA+sH9Dy3LY3K/lYYBSSaFXg9yXOPmsUzKVzlklEhCQd6oX1DMvg
         +l2pOMmnHnOrXihuyP4Mfdy7yVKlJBRexEV1NYAjKUrcRsJ4ljx9GyDUY52NnK697IP4
         nemetp9zArpSDJFQwHNGDNIOxqgCFfO5Am5g5sJIsaLGF0j4mszheCNjVfCORjrkazsd
         dvlAZbY7nVZhI9HU7SPtiS5UkDgA4tMgPXWzT5zNVqxQaF8PN75gpvxVi2sRrqkggZAS
         y8wQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=VcAu0vWiaogKbjBYkJMxyEU2lb/0O17kaTeHoDrcCP4=;
        b=t75snamuF4Ifl4oSsKFaPxmyJJGyNHvFgt5CEdHUzLBMFP8u3199FZV5cMxtTIpiLI
         +DzMCEvJGqE4JwtHX9gL+ai+zZQFx56SUcROvx1BoPkVGLXThBjXmAoml+52wNo7nJ8d
         VYbVS5A4L3DjWdYzySRoeSEGE5GljCgMEXcS0F/UjOZR+lSibYLflWXrTa3csqo9+QII
         S8b/My9mY+QqPoq0qx9rmtO/QkPzXCeIXS2XX8R69S0veLioIUWwXFvWM/0pSP5wrbxg
         CTabScAvIuE2N4aFQ1aDfmOdIHSBsrfnBNPeJVAgdR0I09nfkkS2xeMJeUWQBXf/Ud/W
         VmAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f1si31385673ejb.158.2019.08.08.04.09.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 04:09:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8B21DAE16;
	Thu,  8 Aug 2019 11:09:21 +0000 (UTC)
Subject: Re: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
To: Michal Hocko <mhocko@kernel.org>, John Hubbard <jhubbard@nvidia.com>
Cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
 Christoph Hellwig <hch@infradead.org>, Ira Weiny <ira.weiny@intel.com>,
 Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
 Jerome Glisse <jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
 Dan Williams <dan.j.williams@intel.com>, Daniel Black
 <daniel@linux.ibm.com>, Matthew Wilcox <willy@infradead.org>,
 Mike Kravetz <mike.kravetz@oracle.com>
References: <20190805222019.28592-1-jhubbard@nvidia.com>
 <20190805222019.28592-2-jhubbard@nvidia.com>
 <20190807110147.GT11812@dhcp22.suse.cz>
 <01b5ed91-a8f7-6b36-a068-31870c05aad6@nvidia.com>
 <20190808062155.GF11812@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <875dca95-b037-d0c7-38bc-4b4c4deea2c7@suse.cz>
Date: Thu, 8 Aug 2019 13:09:20 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190808062155.GF11812@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/8/19 8:21 AM, Michal Hocko wrote:
> On Wed 07-08-19 16:32:08, John Hubbard wrote:
>> On 8/7/19 4:01 AM, Michal Hocko wrote:
>>> On Mon 05-08-19 15:20:17, john.hubbard@gmail.com wrote:
>>>> From: John Hubbard <jhubbard@nvidia.com>
>>>>
>>>> For pages that were retained via get_user_pages*(), release those pages
>>>> via the new put_user_page*() routines, instead of via put_page() or
>>>> release_pages().
>>>
>>> Hmm, this is an interesting code path. There seems to be a mix of pages
>>> in the game. We get one page via follow_page_mask but then other pages
>>> in the range are filled by __munlock_pagevec_fill and that does a direct
>>> pte walk. Is using put_user_page correct in this case? Could you explain
>>> why in the changelog?
>>>
>>
>> Actually, I think follow_page_mask() gets all the pages, right? And the
>> get_page() in __munlock_pagevec_fill() is there to allow a pagevec_release() 
>> later.
> 
> Maybe I am misreading the code (looking at Linus tree) but munlock_vma_pages_range
> calls follow_page for the start address and then if not THP tries to
> fill up the pagevec with few more pages (up to end), do the shortcut
> via manual pte walk as an optimization and use generic get_page there.

That's true. However, I'm not sure munlocking is where the
put_user_page() machinery is intended to be used anyway? These are
short-term pins for struct page manipulation, not e.g. dirtying of page
contents. Reading commit fc1d8e7cca2d I don't think this case falls
within the reasoning there. Perhaps not all GUP users should be
converted to the planned separate GUP tracking, and instead we should
have a GUP/follow_page_mask() variant that keeps using get_page/put_page?


