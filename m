Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D794C10F00
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 07:42:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E105220833
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 07:42:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E105220833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7795B6B000D; Tue,  2 Apr 2019 03:42:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 729CD6B000E; Tue,  2 Apr 2019 03:42:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EFD86B0010; Tue,  2 Apr 2019 03:42:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3916B000D
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 03:42:36 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n10so12620070qtk.9
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 00:42:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=8/M9CJialdhaemT5dlCUtynUln/8XsiWjs99mKnZnnE=;
        b=aXGvtaiAEwKsuWNwe62z08yxy5vY+C4uTOD/tPswH8epRDfLy74WdfrfPi6HEnIJrk
         uD500BF+kk7qjkFPgLrkPizAT4AqsQXnk4TWSvJNXvbcDrpyYZi0pvyIjlwEkCEv5L3H
         ss8uEs65jCiIsd00m0BoiHXSi2V+NlpWKKnNYIRA9I+weyVCw/OB3Y4bIX9jutja/K1j
         MAuSJAHz7EjrrgjZdUMwLMVhI7Vfgf6mwODzNMErcCvKDAbutY9cP1u+rC3IxJWuVZvD
         3zOpWj2SarD4P+lH+VvFhexwOoXnPBLiZh6fpHEIBiGfjL8B24vbZkgS7DPHx/q357Ca
         l25Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVvDXUivxTmwjzCZ7dpTsHo9QUuTeBoacVGDacNPoMKCOsvAWoA
	XWbnnEc5Eazxazyh442TzOCf7VB2S7B/vwOAyu4MYe4COd+xL+Znr/iZdTQfAv3RP5Y8N6i57KD
	6d7D8J9CZE59YWscFPkxAbaUFVB25HQecnYz8U05H4lChWIq7IqW+eSJeaEcWxUiOpw==
X-Received: by 2002:ac8:170d:: with SMTP id w13mr56790199qtj.220.1554190955976;
        Tue, 02 Apr 2019 00:42:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFyBL4Ees9SOzgpYKahrKdp9bKChRkHJGigAWkKgknA70eHiqRTerRWdXX95Yl44+s9PDf
X-Received: by 2002:ac8:170d:: with SMTP id w13mr56790168qtj.220.1554190955293;
        Tue, 02 Apr 2019 00:42:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554190955; cv=none;
        d=google.com; s=arc-20160816;
        b=JJCpDQmQARde3VU25eqWG6C/uCdAc6WEBdt4b4PUj+cDcAGDqNZ78w9FUA3sbsrx0d
         v0TZekZxqx/F0ZzcJtTT21nXXgasGMMAlfgXZFOFHpetCUZ3TLtNpj9/RVNr/ION2RW6
         Kk7d4tTtV3qYyQL6NTSiZvZcrwEoqFGe2Qy4qD8FCU/+JKNBxQJ8XnTtkrpBw739WXzT
         eJ2jklvYzKg/s/A4c/R2/cZL99iiSqQkTN+qo02gwhLbmObh6/NexJTSMQjCmucJcnYY
         zh0adXn4/ZGehsQJ9GFpXKGTlkgX/vx5NeuYHV584dWmnjF8DTzLS2x/fLxzDz24xZef
         71Iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=8/M9CJialdhaemT5dlCUtynUln/8XsiWjs99mKnZnnE=;
        b=LKHdRTli7JZSaD/r91zsGn7z26T2JtW70DB25+Vwpp6DeTyCiIN29UaMdjMEop9wLA
         AcwIkAvnGL6RWYCLjJ74CVe+wQ1nh1LIEN9duUJud9kdzJnF9ZpQjiaxXW0S0RSnThVZ
         2zArogedQrT9uDYsQKrRPmI4cc34NbUfxgKWGHbmRVBpx5dUPXvlCO9MG3w92ES13mgg
         Ti3cFU0mDQCjz5iFYlmoVKOD3EI+i8E6qF3tcGIDuiVmOlGl28dxWDVVcR8lebFzYb8q
         cayoLSVxOJ/rLzhBYIuksyj/by4UGpoLFY5FOhOdNZBE8TvIBYsp2dS3tzObZM8ReFQg
         ZM6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d16si2204777qto.126.2019.04.02.00.42.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 00:42:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 742B23078AA8;
	Tue,  2 Apr 2019 07:42:34 +0000 (UTC)
Received: from [10.36.117.141] (ovpn-117-141.ams2.redhat.com [10.36.117.141])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7E34960BFC;
	Tue,  2 Apr 2019 07:42:23 +0000 (UTC)
Subject: Re: On guest free page hinting and OOM
To: Alexander Duyck <alexander.duyck@gmail.com>,
 "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <20190329084058-mutt-send-email-mst@kernel.org>
 <f6332928-d6a4-7a75-245d-2c534cf6e710@redhat.com>
 <20190329104311-mutt-send-email-mst@kernel.org>
 <7a3baa90-5963-e6e2-c862-9cd9cc1b5f60@redhat.com>
 <f0ee075d-3e99-efd5-8c82-98d53b9f204f@redhat.com>
 <20190329125034-mutt-send-email-mst@kernel.org>
 <fb23fd70-4f1b-26a8-5ecc-4c14014ef29d@redhat.com>
 <20190401073007-mutt-send-email-mst@kernel.org>
 <29e11829-c9ac-a21b-b2f1-ed833e4ca449@redhat.com>
 <dc14a711-a306-d00b-c4ce-c308598ee386@redhat.com>
 <20190401104608-mutt-send-email-mst@kernel.org>
 <CAKgT0UcJuD-t+MqeS9geiGE1zsUiYUgZzeRrOJOJbOzn2C-KOw@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <6a612adf-e9c3-6aff-3285-2e2d02c8b80d@redhat.com>
Date: Tue, 2 Apr 2019 09:42:21 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UcJuD-t+MqeS9geiGE1zsUiYUgZzeRrOJOJbOzn2C-KOw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Tue, 02 Apr 2019 07:42:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01.04.19 22:56, Alexander Duyck wrote:
> On Mon, Apr 1, 2019 at 7:47 AM Michael S. Tsirkin <mst@redhat.com> wrote:
>>
>> On Mon, Apr 01, 2019 at 04:11:42PM +0200, David Hildenbrand wrote:
>>>> The interesting thing is most probably: Will the hinting size usually be
>>>> reasonable small? At least I guess a guest with 4TB of RAM will not
>>>> suddenly get a hinting size of hundreds of GB. Most probably also only
>>>> something in the range of 1GB. But this is an interesting question to
>>>> look into.
>>>>
>>>> Also, if the admin does not care about performance implications when
>>>> already close to hinting, no need to add the additional 1Gb to the ram size.
>>>
>>> "close to OOM" is what I meant.
>>
>> Problem is, host admin is the one adding memory. Guest admin is
>> the one that knows about performance.
> 
> The thing we have to keep in mind with this is that we are not dealing
> with the same behavior as the balloon driver. We don't need to inflate
> a massive hint and hand that off. Instead we can focus on performing
> the hints on much smaller amounts and do it incrementally over time
> with the idea being as the system sits idle it frees up more and more
> of the inactive memory on the system.
> 
> With that said, I still don't like the idea of us even trying to
> target 1GB of RAM for hinting. I think it would be much better if we
> stuck to smaller sizes and kept things down to a single digit multiple
> of THP or higher order pages. Maybe something like 64MB of total
> memory out for hinting.

1GB was just a number I came up with. But please note, as VCPUs hint in
parallel, even though each request is only 64MB in size, things can sum up.

> 
> All we really would need to make it work would be to possibly look at
> seeing if we can combine PageType values. Specifically what I would be
> looking at is a transition that looks something like Buddy -> Offline
> -> (Buddy | Offline). We would have to hold the zone lock at each
> transition, but that shouldn't be too big of an issue. If we are okay
> with possibly combining the Offline and Buddy types we would have a
> way of tracking which pages have been hinted and which have not. Then
> we would just have to have a thread running in the background on the
> guest that is looking at the higher order pages and pulling 64MB at a
> time offline, and when the hinting is done put them back in the "Buddy
> | Offline" state.

That approach may have other issues to solve (1 thread vs. many VCPUs,
scanning all buddy pages over and over again) and other implications
that might be undesirable (hints performed even more delayed, additional
thread activity). I wouldn't call it the ultimate solution.

Your approach sounds very interesting to play with, however
at this point I would like to avoid throwing away Nitesh work once again
to follow some other approach that looks promising. If we keep going
like that, we'll spend another ~10 years working on free page hinting
without getting anything upstream. Especially if it involves more
core-MM changes. We've been there, we've done that. As long as the
guest-host interface is generic enough, we can play with such approaches
later in the guest. Important part is that the guest-host interface
allows for that.

> 
> I view this all as working not too dissimilar to how a standard Rx
> ring in a network device works. Only we would want to allocate from
> the pool of "Buddy" pages, flag the pages as "Offline", and then when
> the hint has been processed we would place them back in the "Buddy"
> list with the "Offline" value still set. The only real changes needed
> to the buddy allocator would be to add some logic for clearing/merging
> the "Offline" setting as necessary, and to provide an allocator that
> only works with non-"Offline" pages.

Sorry, I had to smile at the phrase "only" in combination with "provide
an allocator that only works with non-Offline pages" :) . I guess you
realize yourself that these are core-mm changes that might easily be
rejected upstream because "the virt guys try to teach core-MM yet
another special case". I agree that this is nice to play with,
eventually that approach could succeed and be accepted upstream. But I
consider this long term work.

-- 

Thanks,

David / dhildenb

