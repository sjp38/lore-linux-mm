Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11065C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:12:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C472020B7C
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:12:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C472020B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59B046B0005; Fri,  9 Aug 2019 04:12:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54D526B0006; Fri,  9 Aug 2019 04:12:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 413A46B0007; Fri,  9 Aug 2019 04:12:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E71FF6B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 04:12:51 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k37so3081114eda.7
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 01:12:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=XUvyotqe3fQ7dhcA47fXsABRFPA8wA61EZCSfXXG8EE=;
        b=dMNCET84Z7bJ2G70x6aK9yVUSNKf/x0WclR9x8uC2C8AYBUdQLEy8UE0CXhi6rYPiA
         uDhky5v4hFwgRQIktwF0YP3YXE9xKkLzNFFUJZrvcU2PIbrUGTJ/7nlKpbZHfAxTAZqn
         rn3kIhmJNs7vcOI9rxW7lE/x/a636pgecizxZK2pgzjPUehD0YvHFYzpFR7Jz1iwQsax
         YZxmTQeKGpYh25NJ5brntXhtPBKUeDKtumoiqRxSvIS2RjZylbmQGzw+oI3NkswgxVKc
         ZAX6EpBNNp91wGXIXkaJIjpW2+QEyKW90pcHW+rXdInGQ2CJhMVwXvjhBhQ9KSxoPA1Y
         sHRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAWIBpgLtt5+J5UC1+Hm5dWPILg8EUrJ61nVXLB2nkKnCYXMOH6E
	E581woW5lXteIDBKfsilDdIuoFY9m9iHNElJJ+N3RrPyDiS28hSuvgYV5R2MlhJKMYEr+gPzgBe
	ApUMH7HdNsjfmBtH1EN4bb978X6pk5VM7LJY3f4/TJqiiD24zHhuxCtvXEW+wg+3ddg==
X-Received: by 2002:a50:f4d8:: with SMTP id v24mr20764901edm.166.1565338371498;
        Fri, 09 Aug 2019 01:12:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxr0S8WB4t85QONZ4zoHwpMamlbjH6S71eZJ77cpnx4Xwbw1+naA7oDI6R4ukHuxi4+YPw
X-Received: by 2002:a50:f4d8:: with SMTP id v24mr20764866edm.166.1565338370802;
        Fri, 09 Aug 2019 01:12:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565338370; cv=none;
        d=google.com; s=arc-20160816;
        b=BaGgRClErHEfDMXrSewUv0vQSi1vi+5ub7gsTIIfUjG4bgRCZ2KKDy/2V0qNcLT88f
         DQW9IG8CGIYmJjCQzq693xwydjE9fq2Yd3M16m6pPNYd5PdfTa2gxMyumkg7hxfL2mrZ
         CJ+4oAHnm3Kzj0K5ms0+TQ5CcyliOEomiDl4dCA+RkVtHC/1YzpVnFNQx4UhAEYW+0gK
         X0YCBOh9fPKCdwLIPXi6ZG7BNsfRSGPazNaS9izlvhdHuM3eRQQ4p+LkQCEeqX89lWRw
         ou+edQVO3B4YqzhbVD1120UfAhPg888FK62BpvKcvJYragQjGbCHfLElV9lrs6SsGyFc
         z89Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=XUvyotqe3fQ7dhcA47fXsABRFPA8wA61EZCSfXXG8EE=;
        b=OwWCkC17L3KoJ4q/Ad5Rdw7p3D7TG35wY5ViC9gUN1yRAJPUZ7G/XuS9aqJx9+1ZOg
         HUn2YpxZM0kUIAhJn8Kz7aeVfIxZ0KtrqYpsdtVj81D0Z+moXC5kp1LdZZAXAZh7U6kR
         ciLh/1AOukM26AlHW9a26JRD4e6s+vLVvQJBG33tm4XHFSXeJ6XZ8p6mX5p97k7eUo7v
         EcbBaAHNXZXeFBFbA+7M66Vy5J2e9JIm9lzIgAzEIG6fcRu5KOv36cjKEeHDe9xZf6+H
         9A2bE1cFq2Ul+3bYBf3AB7iOBn3obF3gXd86Gd5F7HdafnqKuRhN7R1J36C/Y2ND62un
         e4Uw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p12si36884176eda.385.2019.08.09.01.12.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 01:12:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C4131AF61;
	Fri,  9 Aug 2019 08:12:49 +0000 (UTC)
Subject: Re: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
To: John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
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
 <875dca95-b037-d0c7-38bc-4b4c4deea2c7@suse.cz>
 <306128f9-8cc6-761b-9b05-578edf6cce56@nvidia.com>
 <d1ecb0d4-ea6a-637d-7029-687b950b783f@nvidia.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <420a5039-a79c-3872-38ea-807cedca3b8a@suse.cz>
Date: Fri, 9 Aug 2019 10:12:48 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <d1ecb0d4-ea6a-637d-7029-687b950b783f@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/9/19 12:59 AM, John Hubbard wrote:
>>> That's true. However, I'm not sure munlocking is where the
>>> put_user_page() machinery is intended to be used anyway? These are
>>> short-term pins for struct page manipulation, not e.g. dirtying of page
>>> contents. Reading commit fc1d8e7cca2d I don't think this case falls
>>> within the reasoning there. Perhaps not all GUP users should be
>>> converted to the planned separate GUP tracking, and instead we should
>>> have a GUP/follow_page_mask() variant that keeps using get_page/put_page?
>>>  
>>
>> Interesting. So far, the approach has been to get all the gup callers to
>> release via put_user_page(), but if we add in Jan's and Ira's vaddr_pin_pages()
>> wrapper, then maybe we could leave some sites unconverted.
>>
>> However, in order to do so, we would have to change things so that we have
>> one set of APIs (gup) that do *not* increment a pin count, and another set
>> (vaddr_pin_pages) that do. 
>>
>> Is that where we want to go...?
>>

We already have a FOLL_LONGTERM flag, isn't that somehow related? And if
it's not exactly the same thing, perhaps a new gup flag to distinguish
which kind of pinning to use?

> Oh, and meanwhile, I'm leaning toward a cheap fix: just use gup_fast() instead
> of get_page(), and also fix the releasing code. So this incremental patch, on
> top of the existing one, should do it:
> 
...
> @@ -411,7 +409,13 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
>                 if (PageTransCompound(page))
>                         break;
>  
> -               get_page(page);
> +               /*
> +                * Use get_user_pages_fast(), instead of get_page() so that the
> +                * releasing code can unconditionally call put_user_page().
> +                */
> +               ret = get_user_pages_fast(start, 1, 0, &page);

Um the whole reason of __munlock_pagevec_fill() was to avoid the full
page walk cost, which made a 14% difference, see 7a8010cd3627 ("mm:
munlock: manual pte walk in fast path instead of follow_page_mask()")
Replacing simple get_page() with page walk to satisfy API requirements
seems rather suboptimal to me.

> +               if (ret != 1)
> +                       break;
>                 /*
>                  * Increase the address that will be returned *before* the
>                  * eventual break due to pvec becoming full by adding the page
> 
> 
> thanks,
> 

