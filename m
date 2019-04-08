Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1307BC10F14
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 20:47:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 939B720880
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 20:47:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 939B720880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D45836B000A; Mon,  8 Apr 2019 16:47:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF59F6B000C; Mon,  8 Apr 2019 16:47:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBDEC6B000E; Mon,  8 Apr 2019 16:47:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 95B576B000A
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 16:47:22 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id f15so13814348qtk.16
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 13:47:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=xef8B79Okmiccc5bP3vCgDVQFXeltJ4WGK5PPtcRGXg=;
        b=ldhHJiVj8+SEiQK7G0XZI+rkygNrbWPRQ1RoakLzUtaBYc3YMGuD15xwpUQV5teiKS
         6JflWnjbcMLY6xTX/iclPVGXh73KhE9z7/kmvOeB7dLTA7awB41nHkKBaMB9SMREKqSu
         8b7GK+CgaSEQXVIvPV09M2YvZKSSeIRxWczhR6PnuF1XV32iGPCW2dUaYTMd/Atw9vW7
         LEG1RbFwYD9R3nGTZNuH4HosVUOGTcyeO7+nzXPvuebb6O5X7mrZtHD0KHrmfk+a1ihg
         tMtsmPUQjdeghRfeEmP/Bk3b+kk1nFOX88/EJfpUuim+KdzjyCeESeqameDVAFK0tk/e
         HUVw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWfFMA56ElXlsGUsT34lLOJhYCVGzFb1xO324wvUfgA+E+cYsCs
	ngaLpkQsoQ7Io0ft77pgwpf9daUp0X7rBU/f4Iy4G6CirdX6hjPUeDNcASiJSmTuqJjfilUCwn+
	vVHas9xLMkVgZdxOOgTrMFRNnUv04SCc8tw5VSdIxdkf4mS+SJeGaSLMTVZhZ3VJAgA==
X-Received: by 2002:a0c:9524:: with SMTP id l33mr25820354qvl.41.1554756442373;
        Mon, 08 Apr 2019 13:47:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKKPjJsYfxwKj1jNNXJlTbrEgFcGwyFkXMd2J9EKSwC8rtyIbeuBPHNH+sD8M6yM5YGVpO
X-Received: by 2002:a0c:9524:: with SMTP id l33mr25820306qvl.41.1554756441638;
        Mon, 08 Apr 2019 13:47:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554756441; cv=none;
        d=google.com; s=arc-20160816;
        b=jssrcanLRG28+qM8oEp1iQpx0via7uZDxLQWmBinum0eWIGyyEEjxoO5BNUdHRiWf2
         wgJ9IT3PxonxLkPgD5wRN19BP51qNE79AqePnK+ABu/ZNgQ6VxWFKMEli6KH0rjaLS/O
         ym9ez/w23sBaYRT09X1UiTRCgC+XuwvqPCPCMaGE7x2AYDZDjlnZW4G6tNS114b4s+1n
         C4ECVtnSyWb6/fsAuuVW6DHtwPnyHCS5Xlzex033kqXjVbhm3FP6bW5KkK0Jr/lvUj0s
         kVNXSkVCtND6p5huz0/4ExKHi+KI1YtbmzDX3lNCb82TZodK+6V004256D6fHUXnCsUi
         cUag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=xef8B79Okmiccc5bP3vCgDVQFXeltJ4WGK5PPtcRGXg=;
        b=VsFXgr8x7Er0i5lxGO0/CjipSE6DhjDyvukePYucOID5q2tCaFpBm5cFJKH6xOye5f
         fi4dvm5pfDvuSsxnsbnVRFy6FFWwwUbg/1hAVfEmKfLYFi/jutc1fvWrQPVS7J894XZg
         YT5xRQNLy3M5PfeFFfWZT5qWEmztFN2rS21BuG7Lz7H2Gao85fgNwcJdDqyLBmxfaaRI
         83c+3ZJPFMBBpqcl4MGvwwo1//PdiPFUKKqMKh1eD/bD3HasRVdqf0fyvIRtRb5JauPD
         uPoPfPcTPWzA1QR2FKlIIOHhkVL1h2S3878ix9XVjRFocrP6amdJdLgkCSYOlmQ8QCzd
         0WCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y10si1240076qkl.86.2019.04.08.13.47.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 13:47:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A84D0308213E;
	Mon,  8 Apr 2019 20:47:20 +0000 (UTC)
Received: from [10.36.116.113] (ovpn-116-113.ams2.redhat.com [10.36.116.113])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BC86E5D719;
	Mon,  8 Apr 2019 20:47:10 +0000 (UTC)
Subject: Re: Thoughts on simple scanner approach for free page hinting
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
 Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
 <01d5f4e8-742b-33f5-6d91-0c7c396d1cfc@redhat.com>
 <CAKgT0UfbVS2iupbf4Dfp91PAdgHNHwZ-RNyL=mcPsS_68Ly_9Q@mail.gmail.com>
 <ef4c219f-6686-f5f6-fd22-d1da0b1720f3@redhat.com>
 <CAKgT0Ucp1nt4roC1xdZEMcD17TvJovsDKBdkRK6vA_4bUM8bdw@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <b86e69f8-88b9-d579-f318-097203a73673@redhat.com>
Date: Mon, 8 Apr 2019 22:47:09 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0Ucp1nt4roC1xdZEMcD17TvJovsDKBdkRK6vA_4bUM8bdw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Mon, 08 Apr 2019 20:47:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08.04.19 22:10, Alexander Duyck wrote:
> On Mon, Apr 8, 2019 at 11:40 AM David Hildenbrand <david@redhat.com> wrote:
>>
>>>>>
>>>>> In addition we will need some way to identify which pages have been
>>>>> hinted on and which have not. The way I believe easiest to do this
>>>>> would be to overload the PageType value so that we could essentially
>>>>> have two values for "Buddy" pages. We would have our standard "Buddy"
>>>>> pages, and "Buddy" pages that also have the "Offline" value set in the
>>>>> PageType field. Tracking the Online vs Offline pages this way would
>>>>> actually allow us to do this with almost no overhead as the mapcount
>>>>> value is already being reset to clear the "Buddy" flag so adding a
>>>>> "Offline" flag to this clearing should come at no additional cost.
>>>>
>>>> Just nothing here that this will require modifications to kdump
>>>> (makedumpfile to be precise and the vmcore information exposed from the
>>>> kernel), as kdump only checks for the the actual mapcount value to
>>>> detect buddy and offline pages (to exclude them from dumps), they are
>>>> not treated as flags.
>>>>
>>>> For now, any mapcount values are really only separate values, meaning
>>>> not the separate bits are of interest, like flags would be. Reusing
>>>> other flags would make our life a lot easier. E.g. PG_young or so. But
>>>> clearing of these is then the problematic part.
>>>>
>>>> Of course we could use in the kernel two values, Buddy and BuddyOffline.
>>>> But then we have to check for two different values whenever we want to
>>>> identify a buddy page in the kernel.
>>>
>>> Actually this may not be working the way you think it is working.
>>
>> Trust me, I know how it works. That's why I was giving you the notice.
>>
>> Read the first paragraph again and ignore the others. I am only
>> concerned about makedumpfile that has to be changed.
>>
>> PAGE_OFFLINE_MAPCOUNT_VALUE
>> PAGE_BUDDY_MAPCOUNT_VALUE
>>
>> Once you find out how these values are used, you should understand what
>> has to be changed and where.
> 
> Ugh. Is there an official repo I am supposed to refer to for makedumpfile?
> 
> As far as the changes needed I don't think this would necessitate
> additional exports. We could probably just get away with having
> makedumpfile generate a new value by simply doing an "&" of the two
> values to determine what an offline buddy would be. If need be I can
> submit a patch for that. I find it kind of annoying that the kernel is
> handling identifying these bits one way, and makedumpfile is doing it
> another way. It should have been setup to handle this all the same
> way.

Here you go:

https://sourceforge.net/p/makedumpfile/code/ci/master/tree/

for now we only had one type at a time, so it wasn't an issue. E.g.
Buddy or Offline were never used in combination with other types. They
had distinct mapcount values.

-- 

Thanks,

David / dhildenb

