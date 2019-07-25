Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF63BC41517
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:33:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89FA222BEF
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:33:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89FA222BEF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 210B66B0003; Thu, 25 Jul 2019 14:33:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C0EC8E0003; Thu, 25 Jul 2019 14:33:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 088CA8E0002; Thu, 25 Jul 2019 14:33:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id DAD186B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:33:05 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id z13so43148732qka.15
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:33:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=sXXIMYIo2bd+TRQq8Hnay+P0i/dC8N+OflRpvTIGX5Q=;
        b=Sl1rZwwvn9/tV1sEduNmdbhAHoJU7sNEFe3jaNXAJWMqCztYUFkVrK8Sx3ufVAAT9D
         qVcVNnx+mdqSiEtnKV3gu3YiJZkSC/T0ITrlalmXd9D+tACCOdRK+fG9unB/h7dvYl0i
         nyTHpDLR/S1CmCWDJKlbhxSYvfjhdiHjo0i8FaZDQkS/Jk0AOADeCe0y1NKBqmiwrFMl
         tVPodGs8QYavGXl8XP4K5Ebkmtbe4UXDsDTcdG499jZvxXbY/beJwO6zf2wM21spejOv
         rvdxGB/OafGt5inf59EqYhbWLnEnqWHVHH0cS2jxN8V1zDq+j7hdNtmwmQVaCChU5JgL
         GgLw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVtkUngwIa/07HmTcuueHFugnOFQaEPLTkGXHp+y3bFeYwEseuS
	3bA5Po8TzBnJBS++zqYkVzWmUnQvTgmjulhF5emWFdU5wbCGSSLkmiYO7j1j7u9BmTgR9Ygyvmm
	qeXgHK6s8IWRLKop5606NsMy+ONCMz5j6GvQJQdbAOjkzvjvj7utcM0FDNHz1t1JEdw==
X-Received: by 2002:a0c:c96a:: with SMTP id v39mr63592410qvj.121.1564079585635;
        Thu, 25 Jul 2019 11:33:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwO7MuQyCAkMc0j9YMWqcNla9LRRhYKT4lHkmaAZtMs6LebFrT3gmLkWM1W6fqCQyNECuuu
X-Received: by 2002:a0c:c96a:: with SMTP id v39mr63592373qvj.121.1564079585007;
        Thu, 25 Jul 2019 11:33:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564079585; cv=none;
        d=google.com; s=arc-20160816;
        b=P9oDYHe+GVDfUXddaKIHjGvlvW9a0fwg+X7ny1CuZ6fjJfe/GN8HPtjMk739KNJT0n
         pGh5Ls2wK6NBCNNQBcqySPi+zfaLDobUB3gsEC79ztG9gBGKjFtTqP8teHV5G807W2mj
         VpUTw1JHqGfB3nkr0sL7Cam1ibkOyDM9TJvt0xR3esXKq/5PnYtU+bvbRjlP4Sgx5yTb
         QntZZRXdJAQoKaFP5rnlEHw7H7f+1Ydu+QS4OQ6Q63oSEwhGX/j+vj74q9suWeHyjwnV
         5NttCAzEA4a26XXENpxbekpibTaVTDsG4vXJ56IRVFOsSs8y9kDIX0tQhsuZMVBHSe+8
         1pjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=sXXIMYIo2bd+TRQq8Hnay+P0i/dC8N+OflRpvTIGX5Q=;
        b=IvQ0Yb3n4Fne8JUPVUp+Nrh2wiIRG84iX/FQrcRUcVGElKVqAyJXiZYhnZBFYUgFxZ
         R8Dj0rZF0MKSnKlFZEMzu45J8uGUlM5spXPi5DUrpQ2cBQIr9h3uNhbsz5/Iazf3VuFi
         I8O8S3U/x5046PStQpTZf0qYA7ainH92vgOyq9KwP6acmxH1Ninx1F7m/sI9lCsaZjFy
         Bc44fA/dLs4Sb3vtXViDGKD520XKwTmbvC4on/OWE7v1Vu26OjxfhEtnqI9K0grP6w+Z
         eZlY6nNelZUrM4g9V2xj9ojKwjhabxe4JoEYUXRmPrv6F66MyFweG6PFHInzRFPlckTk
         gPJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v37si33083831qtk.200.2019.07.25.11.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 11:33:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1878459440;
	Thu, 25 Jul 2019 18:33:04 +0000 (UTC)
Received: from [10.36.116.69] (ovpn-116-69.ams2.redhat.com [10.36.116.69])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 61F015C542;
	Thu, 25 Jul 2019 18:32:51 +0000 (UTC)
Subject: Re: [PATCH v2 4/5] mm: Introduce Hinted pages
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 Alexander Duyck <alexander.duyck@gmail.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
 "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com,
 Rik van Riel <riel@surriel.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com,
 wei.w.wang@intel.com, Andrea Arcangeli <aarcange@redhat.com>,
 Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com,
 Matthew Wilcox <willy@infradead.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724170259.6685.18028.stgit@localhost.localdomain>
 <a9f52894-52df-cd0c-86ac-eea9fbe96e34@redhat.com>
 <CAKgT0Ud-UNk0Mbef92hDLpWb2ppVHsmd24R9gEm2N8dujb4iLw@mail.gmail.com>
 <f0ac7747-0e18-5039-d341-5dfda8d5780e@redhat.com>
 <b3568a5422d0f6b88f7c5cb46577db1a43057c04.camel@linux.intel.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <c200d5cf-90f7-9dca-5061-b6e0233ca089@redhat.com>
Date: Thu, 25 Jul 2019 20:32:50 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <b3568a5422d0f6b88f7c5cb46577db1a43057c04.camel@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 25 Jul 2019 18:33:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.07.19 19:38, Alexander Duyck wrote:
> On Thu, 2019-07-25 at 18:48 +0200, David Hildenbrand wrote:
>> On 25.07.19 17:59, Alexander Duyck wrote:
>>> On Thu, Jul 25, 2019 at 1:53 AM David Hildenbrand <david@redhat.com> wrote:
>>>> On 24.07.19 19:03, Alexander Duyck wrote:
>>>>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>>>
> 
> <snip>
> 
>>>> Can't we reuse one of the traditional page flags for that, not used
>>>> along with buddy pages? E.g., PG_dirty: Pages that were not hinted yet
>>>> are dirty.
>>>
>>> Reusing something like the dirty bit would just be confusing in my
>>> opinion. In addition it looks like Xen has also re-purposed PG_dirty
>>> already for another purpose.
>>
>> You brought up waste page management. A dirty bit for unprocessed pages
>> fits perfectly in this context. Regarding XEN, as long as it's not used
>> along with buddy pages, no issue.
> 
> I would rather not have to dirty all pages that aren't hinted. That starts
> to get too invasive. Ideally we only modify pages if we are hinting on
> them. That is why I said I didn't like the use of a dirty bit. What we
> want is more of a "guaranteed clean" bit.

Not sure if that is too invasive, but fair enough.

> 
>> FWIW, I don't even thing PG_offline matches to what you are using it
>> here for. The pages are not logically offline. They were simply buddy
>> pages that were hinted. (I'd even prefer a separate page type for that
>> instead - if we cannot simply reuse one of the other flags)
>>
>> "Offline pages" that are not actually offline in the context of the
>> buddy is way more confusing.
> 
> Right now offline and hinted are essentially the same thing since the
> effect is identical.

No they are not the same thing. Regarding virtio-balloon: You are free
to reuse any hinted pages immediate. Offline pages (a.k.a. inflated) you
might not generally reuse before deflating.

> 
> There may be cases in the future where that is not the case, but with the
> current patch set they both result in the pages being evicted from the
> guest.
> 
>>> If anything I could probably look at seeing if the PG_private flags
>>> are available when a page is in the buddy allocator which I suspect
>>> they probably are since the only users I currently see appear to be
>>> SLOB and compound pages. Either that or maybe something like PG_head
>>> might make sense since once we start allocating them we are popping
>>> the head off of the boundary list.
>>
>> Would also be fine with me.
> 
> Actually I may have found an even better bit if we are going with the
> "reporting" name. I could probably use "PG_uptodate" since it looks like
> most of its uses are related to filesystems. I will wait till I hear from
> Matthew on what bits would be available for use before I update things.

Also fine with me. In the optimal case we (in my opinion)
a) Don't reuse PG_offline
b) Don't use another page type

-- 

Thanks,

David / dhildenb

