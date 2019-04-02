Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B4B6C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 15:56:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC67520645
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 15:56:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC67520645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C7D16B0007; Tue,  2 Apr 2019 11:56:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6503B6B0269; Tue,  2 Apr 2019 11:56:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CBEC6B026A; Tue,  2 Apr 2019 11:56:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 253F06B0007
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 11:56:02 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id e31so9658112qtb.0
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 08:56:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=qWShu6FMquZSi7SPPJ0B9j/CAu2hwjMJPOQJMnPfzmA=;
        b=O8awmqTIGVmI91UiFqYruzPV5oL7HMOIuqFthxOgM6mi/YhZ9nb4AZY+2tXruTd0zk
         Ib24RNW4QnN1t5dEzIbint1O+c7hjbSTqWiZb/BM1CtwAsYcwN32phKOP3xl3k2z2TYu
         8CUICf54B3q8S1RvGYQqI+Rk5ITiJvYBYukzhrhU7F83TKCx4bx6gdGj/epZTiLbnlhM
         KBSZMW23mAL4ejG/BAuFTHMfojyDdVVqwMI5GFLYd5vqWCUQxV19ULX+JCJqwGtlSBJv
         QwaXGG7c94rxNErrxcVnhYGnVnRSPprd84QNwHLtJohVxna0/Bzo8zPvboHOCFVyUc6k
         RJfg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW32JEfdLXS6tP0qjG2a6gcwkugdJQYBhELraW46NcI4ZhU8VDb
	MfzjwJPuWDVCuw9kXLStXXHFNf6u/2qnW/mpsqOrO52uhhjLXdC4G+AtGSdHczPv0J/uKR2lpAu
	hzB2vp1VBkkk2eLA5uaQwe/+qCmW7mXBoQX15X7XZEKhsv6/6gEe+7uk+yy+ZQHYboA==
X-Received: by 2002:ac8:38f5:: with SMTP id g50mr59846104qtc.119.1554220561814;
        Tue, 02 Apr 2019 08:56:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMnuUnbpvdFwq5LnnGo+xq6R/zUeCH7hUk1N9RlvIpgjCOxqXtfZXWel2blVXLYoMqlI10
X-Received: by 2002:ac8:38f5:: with SMTP id g50mr59846024qtc.119.1554220560738;
        Tue, 02 Apr 2019 08:56:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554220560; cv=none;
        d=google.com; s=arc-20160816;
        b=npfHNznKNnB+PpIhtDKcaREf57K8bO+EcTJCb1qbYrlEGRanRyEAdSA+PgMbHIdjoj
         kVa5WhRBXyevwID++luZQPjBUIehGhkOYlrirbnltM9+0kDTJBiQzVzy4OmJmuGypOgA
         pOWZvBYTYDmj49cZgnBdRPssHHZu4wqkmjoucUtfGVGrhPsKbw7Wgn3ErvOaQRc0DXCK
         zZ8uavtg+S8NNNaSYFZxzkf7NbNYyxfzoh2qjJ/kT7neSsXPk5f/Iku9At+TNVUoWQWe
         AB4TnKgt4c8lFy0Et3R6kho2C8ad8YMt6akof7C27QhNLLRj591Vahh510ObZOGM2dgz
         Q3ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=qWShu6FMquZSi7SPPJ0B9j/CAu2hwjMJPOQJMnPfzmA=;
        b=Ct4cDZD2tDW6egyWaTtKQeixGJrmjVyGL9hjCi6+hJb5pMfvUt9eevRy8ygVXwu97P
         l0KZqKXNNq/KQWpLL1qd7RsC/qqmOYOj6N9Sa4ys7ZXIkhBSOdltsFP7HXlI2IeojCzh
         RRqB0jPlKXSsUmnk8mecU+GnOlXf1aw7G5fROAwT8IZrEQjmPnLqAr9DcNutDUIng9Vv
         hspSZV7Tk7FdM/2MEOAmHmIazZ41nPEcIC8XmYicFjfkw9lLkEAlRqT1tJzgyp3tWxHy
         YMOSGrmKVDx+ZNVotSDURIi5mag0k8hc4kK0JtTdEOw2u5Z8nJbc67oaaBxJQc3hkon+
         yfwg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h9si4581816qkg.35.2019.04.02.08.56.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 08:56:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8B16D308792B;
	Tue,  2 Apr 2019 15:55:59 +0000 (UTC)
Received: from [10.36.116.151] (ovpn-116-151.ams2.redhat.com [10.36.116.151])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 97B14194AA;
	Tue,  2 Apr 2019 15:55:50 +0000 (UTC)
Subject: Re: On guest free page hinting and OOM
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
 Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
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
 <6a612adf-e9c3-6aff-3285-2e2d02c8b80d@redhat.com>
 <CAKgT0Ue_By3Z0=5ZEvscmYAF2P40Bdyo-AXhH8sZv5VxUGGLvA@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <1249f9dd-d22d-9e19-ee33-767581a30021@redhat.com>
Date: Tue, 2 Apr 2019 17:55:49 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0Ue_By3Z0=5ZEvscmYAF2P40Bdyo-AXhH8sZv5VxUGGLvA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Tue, 02 Apr 2019 15:55:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 02.04.19 17:04, Alexander Duyck wrote:
> On Tue, Apr 2, 2019 at 12:42 AM David Hildenbrand <david@redhat.com> wrote:
>>
>> On 01.04.19 22:56, Alexander Duyck wrote:
>>> On Mon, Apr 1, 2019 at 7:47 AM Michael S. Tsirkin <mst@redhat.com> wrote:
>>>>
>>>> On Mon, Apr 01, 2019 at 04:11:42PM +0200, David Hildenbrand wrote:
>>>>>> The interesting thing is most probably: Will the hinting size usually be
>>>>>> reasonable small? At least I guess a guest with 4TB of RAM will not
>>>>>> suddenly get a hinting size of hundreds of GB. Most probably also only
>>>>>> something in the range of 1GB. But this is an interesting question to
>>>>>> look into.
>>>>>>
>>>>>> Also, if the admin does not care about performance implications when
>>>>>> already close to hinting, no need to add the additional 1Gb to the ram size.
>>>>>
>>>>> "close to OOM" is what I meant.
>>>>
>>>> Problem is, host admin is the one adding memory. Guest admin is
>>>> the one that knows about performance.
>>>
>>> The thing we have to keep in mind with this is that we are not dealing
>>> with the same behavior as the balloon driver. We don't need to inflate
>>> a massive hint and hand that off. Instead we can focus on performing
>>> the hints on much smaller amounts and do it incrementally over time
>>> with the idea being as the system sits idle it frees up more and more
>>> of the inactive memory on the system.
>>>
>>> With that said, I still don't like the idea of us even trying to
>>> target 1GB of RAM for hinting. I think it would be much better if we
>>> stuck to smaller sizes and kept things down to a single digit multiple
>>> of THP or higher order pages. Maybe something like 64MB of total
>>> memory out for hinting.
>>
>> 1GB was just a number I came up with. But please note, as VCPUs hint in
>> parallel, even though each request is only 64MB in size, things can sum up.
> 
> Why do we need them running in parallel for a single guest? I don't
> think we need the hints so quickly that we would need to have multiple
> VCPUs running in parallel to provide hints. In addition as it
> currently stands in order to get pages into and out of the buddy
> allocator we are going to have to take the zone lock anyway so we
> could probably just assume a single thread for pulling the memory,
> placing it on the ring, and putting it back into the buddy allocator
> after the hint has been completed.

VCPUs hint when they think the time has come. Hinting in parallel comes
naturally.

> 
>>>
>>> All we really would need to make it work would be to possibly look at
>>> seeing if we can combine PageType values. Specifically what I would be
>>> looking at is a transition that looks something like Buddy -> Offline
>>> -> (Buddy | Offline). We would have to hold the zone lock at each
>>> transition, but that shouldn't be too big of an issue. If we are okay
>>> with possibly combining the Offline and Buddy types we would have a
>>> way of tracking which pages have been hinted and which have not. Then
>>> we would just have to have a thread running in the background on the
>>> guest that is looking at the higher order pages and pulling 64MB at a
>>> time offline, and when the hinting is done put them back in the "Buddy
>>> | Offline" state.
>>
>> That approach may have other issues to solve (1 thread vs. many VCPUs,
>> scanning all buddy pages over and over again) and other implications
>> that might be undesirable (hints performed even more delayed, additional
>> thread activity). I wouldn't call it the ultimate solution.
> 
> So the problem with trying to provide the hint sooner is that you end
> up creating a bottle-neck or you end up missing hints on pages
> entirely and then have to fall back to such an approach. By just
> letting the thread run in the background reporting the idle memory we
> can avoid much of that.
> 
> Also there isn't a huge priority to report idle memory in real time.
> That would be kind of pointless as it might be pulled back out and
> reused as soon as it is added. What we need is to give the memory a
> bit of time to "cool" so that we aren't constantly hinting away memory
> that is still in use.

Depending on the setup, you don't want free memory lying around for too
long in your guest.

> 
>> Your approach sounds very interesting to play with, however
>> at this point I would like to avoid throwing away Nitesh work once again
>> to follow some other approach that looks promising. If we keep going
>> like that, we'll spend another ~10 years working on free page hinting
>> without getting anything upstream. Especially if it involves more
>> core-MM changes. We've been there, we've done that. As long as the
>> guest-host interface is generic enough, we can play with such approaches
>> later in the guest. Important part is that the guest-host interface
>> allows for that.
> 
> I'm not throwing anything away. One of the issues in Nitesh's design
> is that he is going to either miss memory and have to run an
> asynchronous thread to clean it up after the fact, or he is going to
> cause massive OOM errors and/or have to start halting VCPUs while

1. how are we going to miss memory. We are going to miss memory because
we hint on very huge chunks, but we all agreed to live with that for now.

2. What are the "massive OOM" errors you are talking about? We have the
one scenario we described Nitesh was not even able to reproduce yet. And
we have ways to mitigate the problem (discussed in this thread).

We have something that seems to work. Let's work from there instead of
scrapping the general design once more, thinking "it is super easy". And
yes, what you propose is pretty much throwing away the current design in
the guest.

> waiting on the processing. All I am suggesting is that we can get away
> from having to deal with both by just walking through the free pages
> for the higher order and hinting only a few at a time without having
> to try to provide the host with the hints on what is idle the second
> it is freed.
> 
>>>
>>> I view this all as working not too dissimilar to how a standard Rx
>>> ring in a network device works. Only we would want to allocate from
>>> the pool of "Buddy" pages, flag the pages as "Offline", and then when
>>> the hint has been processed we would place them back in the "Buddy"
>>> list with the "Offline" value still set. The only real changes needed
>>> to the buddy allocator would be to add some logic for clearing/merging
>>> the "Offline" setting as necessary, and to provide an allocator that
>>> only works with non-"Offline" pages.
>>
>> Sorry, I had to smile at the phrase "only" in combination with "provide
>> an allocator that only works with non-Offline pages" :) . I guess you
>> realize yourself that these are core-mm changes that might easily be
>> rejected upstream because "the virt guys try to teach core-MM yet
>> another special case". I agree that this is nice to play with,
>> eventually that approach could succeed and be accepted upstream. But I
>> consider this long term work.
> 
> The actual patch for this would probably be pretty small and compared
> to some of the other stuff that has gone in recently isn't too far out
> of the realm of possibility. It isn't too different then the code that
> has already done in to determine the unused pages for virtio-balloon
> free page hinting.
> 
> Basically what we would be doing is providing a means for
> incrementally transitioning the buddy memory into the idle/offline
> state to reduce guest memory overhead. It would require one function
> that would walk the free page lists and pluck out pages that don't
> have the "Offline" page type set, a one-line change to the logic for
> allocating a page as we would need to clear that extra bit of state,
> and optionally some bits for how to handle the merge of two "Offline"
> pages in the buddy allocator (required for lower order support). It
> solves most of the guest side issues with the free page hinting in
> that trying to do it via the arch_free_page path is problematic at
> best since it was designed for a synchronous setup, not an
> asynchronous one.

This is throwing away work. No I don't think this is the right path to
follow for now. Feel free to look into it while Nitesh gets something in
shape we know conceptually works and we are starting to know which
issues we are hitting.

-- 

Thanks,

David / dhildenb

