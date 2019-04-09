Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99C8DC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 09:20:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2256D20818
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 09:20:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2256D20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE97D6B000C; Tue,  9 Apr 2019 05:20:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A995B6B000D; Tue,  9 Apr 2019 05:20:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 962146B0010; Tue,  9 Apr 2019 05:20:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 74D156B000C
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 05:20:53 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id m8so13910379qka.10
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 02:20:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=Xe+hfYdJggKQTjeuEVUY2BmIq0F0w8jXqNm7nRPanVM=;
        b=VjuSt8lc4DIupgBWTdVhkMYmWKoJIoDyEln+9RKIlFjwFC/X2zW83pqF7gz/iS/p2K
         V28/dDkivdW5cpReMd7JhSHd/XZA+O0/n1cTzUgHryb81mgjMLDmKl3uegH1EF7MtANG
         FZvz3vmoxlXzJDDo1hSg1zT+X4D/YBtQbi92PtmuNBHx0gc8wthLqpc7miCwZlm6KDlH
         STyPtWdOn48K6JMo+3/eOOoDBEkLNNfERh2i+4bmZq38IUt1ICNwxRxSVlln0Lnh7+Tn
         CO9USyJksTzzu7dlB9hVHAuo5BAInAtsLPCp2G9C2eQY2EzUU8dCkDJ0SVBtPrgLPnjV
         q1RA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUBnhpkVcX2PjgnBZM6hgYzFkF2YYlJrvGBVosg4KFxTFukla0C
	dWQEvNYR2Ux4SW1eu7wcvEnq6G0O6LLXV1cHfBXAkd0L0mtupVEyMQ1Dj4x6q3PCTvn/w6xfuFq
	dTfNARsyM33Ch8Ty7YlSNznMCoMoFBCX0Xiwui4cUE3Bg6J2gHdZLVZUE8Rp47SKDQw==
X-Received: by 2002:ac8:66d0:: with SMTP id m16mr4669151qtp.215.1554801653078;
        Tue, 09 Apr 2019 02:20:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxh5aPy/O54GNGzEKoRzvDgqs3Jwz9koORzWLy+c11ugxC+xArk0Ys/cd7nZYUi0w82KToa
X-Received: by 2002:ac8:66d0:: with SMTP id m16mr4669112qtp.215.1554801652427;
        Tue, 09 Apr 2019 02:20:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554801652; cv=none;
        d=google.com; s=arc-20160816;
        b=YwqwuZyONB9dGZy8JQ4NYEMEJH4H5HXNPDd5BJ6jzOfmmfiBZzhYFlabQwFYaLBBZO
         uUMwl42ewQmEsirtuS8R8QmmRjBP5aYqHTatk6YEwcpLeRll6EsldZjYZWkANiVbnJ1v
         0t7Jlyqzsln/92pq1wZckihazpdlhpWytDkJRuC/LxN8+KLp/iPaHmKtjyZXkLOrUZ/l
         CAqDP6tKARLIRUAawhm5DER8b7O1aBrWLCT9+u8SqF05luBY0r/pL6TMsOaJBPJ8u001
         On/DIavWfIdXEf5UUfKdAMqErPuk9zabfC1lRm/zJqLzj0lUr9UV/xMBvnj1GH93izhL
         bNSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=Xe+hfYdJggKQTjeuEVUY2BmIq0F0w8jXqNm7nRPanVM=;
        b=lbJDjIlmdU/khoX2WrrMtgghUsNK4VMDhdIUMyRlpOWco9zkA8V6027iLV41k3gugG
         vG4vBS87LMhwyyHECxnaDXpASqqDiVykffO3YBSaQ0ymzYjVTA4OtaREF5qhxk956ViM
         OWvq+3uiqQVhUjCdO/10ChpVWsUSrelXD4NPEOz2lZY/PIwtidMtJeGHxnEtHgWYhZAk
         LgAOtFY8sdewqEMTAvs8auG3Sj38nqcQu1YAHQo1KmOZBFycx2P5314a2nbs0wOVZm9x
         0LU4UTWpRty8wblzOyfEkqAg4m4nDT1YFJrvee2vFfDiECB2J+UsKXWzN0NQWxXVzH5B
         k57A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 15si4063807qkj.154.2019.04.09.02.20.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 02:20:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B830A3086237;
	Tue,  9 Apr 2019 09:20:50 +0000 (UTC)
Received: from [10.36.117.49] (ovpn-117-49.ams2.redhat.com [10.36.117.49])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7E69D608A7;
	Tue,  9 Apr 2019 09:20:37 +0000 (UTC)
Subject: Re: Thoughts on simple scanner approach for free page hinting
To: Alexander Duyck <alexander.duyck@gmail.com>,
 "Michael S. Tsirkin" <mst@redhat.com>, Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <d2413648-8943-4414-708a-9442ab4b9e65@redhat.com>
Date: Tue, 9 Apr 2019 11:20:36 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Tue, 09 Apr 2019 09:20:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> With that said I have a few ideas that may help to address the 4
> issues called out above. The basic idea is simple. We use a high water
> mark based on zone->free_area[order].nr_free to determine when to wake
> up a thread to start hinting memory out of a given free area. From
> there we allocate non-"Offline" pages from the free area and assign
> them to the hinting queue up to 64MB at a time. Once the hinting is
> completed we mark them "Offline" and add them to the tail of the
> free_area. Doing this we should cycle the non-"Offline" pages slowly
> out of the free_area. In addition the search cost should be minimal
> since all of the "Offline" pages should be aggregated to the tail of
> the free_area so all pages allocated off of the free_area will be the
> non-"Offline" pages until we shift over to them all being "Offline".
> This should be effective for MAX_ORDER - 1 and MAX_ORDER - 2 pages
> since the only real consumer of add_to_free_area_tail is
> __free_one_page which uses it to place a page with an order less than
> MAX_ORDER - 2 on the tail of a free_area assuming that it should be
> freeing the buddy of that page shortly. The only other issue with
> adding to tail would be the memory shuffling which was recently added,
> but I don't see that as being something that will be enabled in most
> cases so we could probably just make the features mutually exclusive,
> at least for now.
> 
> So if I am not mistaken this would essentially require a couple
> changes to the mm infrastructure in order for this to work.
> 
> First we would need to split nr_free into two counters, something like
> nr_freed and nr_bound. You could use nr_freed - nr_bound to get the
> value currently used for nr_free. When we pulled the pages for hinting
> we would reduce the nr_freed value and then add back to it when the
> pages are returned. When pages are allocated they would increment the
> nr_bound value. The idea behind this is that we can record nr_free
> when we collect the pages and save it to some local value. This value
> could then tell us how many new pages have been added that have not
> been hinted upon.
> 
> In addition we will need some way to identify which pages have been
> hinted on and which have not. The way I believe easiest to do this
> would be to overload the PageType value so that we could essentially
> have two values for "Buddy" pages. We would have our standard "Buddy"
> pages, and "Buddy" pages that also have the "Offline" value set in the
> PageType field. Tracking the Online vs Offline pages this way would
> actually allow us to do this with almost no overhead as the mapcount
> value is already being reset to clear the "Buddy" flag so adding a
> "Offline" flag to this clearing should come at no additional cost.

BTW I like the idea of allocating pages that have already been hinted as
last "choice", allocating pages that have not been hinted yet first.

-- 

Thanks,

David / dhildenb

