Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39613C10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:44:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA4EF205C9
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:44:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA4EF205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 542A46B000D; Wed,  3 Apr 2019 15:44:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F0B66B000E; Wed,  3 Apr 2019 15:44:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 345A26B0010; Wed,  3 Apr 2019 15:44:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 062B26B000D
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 15:44:01 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id v18so166918qtk.5
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 12:44:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=1d4Ho5Lb+N2EQmlLihf4gpUxhbqWd9rIZ3zim+U53ok=;
        b=UNpJX2WItojLemos++Pm43YP/awwNESK8l4ITTr1SIYTDrgzKIUwKdOcdXvxxm//lS
         DHVQeouUE4gNSWqS8IIe0caFdB69Aphe8to3mIEtD5jmkrUfneOC+76/tmu+tM+DYj8A
         CZnhH2635wHA5DHSUOQuAi/oMNQb9QT7/80SrE2yP5v8+6cFHaxMPjW7Se1Ld7BgsmzD
         Bzj2qefc9q9IOvRO6nK9jtfRHTUOuMsmG807EDUW/iYke5mPtpsxGeQAly+RxqwWRKUU
         K3N8y3NZwhsDP1/HZHRX7jf/JgCgXsWTr/IY0NurM+PlVd3pIkdQOynEnPYh6dbVmUH4
         xyYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX59HGEpi91+lX+Bg+MJDJvJhuGGWXOnlQXkzACq5hYpIuP4yZn
	mmIpcj7S1iDbarunFPy5TVDvYOmn1O6TrncElHEeSpGVZmDHKSDPiBm90IP1x4oQKf0jySVECva
	LZld8829DLeQNHdrus0v0G/gAqfe+o914j8MHQbqfBeoA3t3go5C2ByD0pniRSXsh8g==
X-Received: by 2002:a0c:ecca:: with SMTP id o10mr1215008qvq.197.1554320640714;
        Wed, 03 Apr 2019 12:44:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqys8/rnJv3ZYv9H7upiKZrziEvKxalDA+QfBRiqayqcC6rR/E/xqgM57ym0qB8LOztbrCfv
X-Received: by 2002:a0c:ecca:: with SMTP id o10mr1214925qvq.197.1554320639351;
        Wed, 03 Apr 2019 12:43:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554320639; cv=none;
        d=google.com; s=arc-20160816;
        b=dk5IQeqMmfTw52O49Ovtg07DcK+/cpXc8SQeZ6FT5BpMV1BufjthfP+hL5TOE586sF
         PNNQB/vgXVAIpizvvCBav7PZIHgHm47/KlxActxXI4Mt3GkPmLzcx48TamS5lp88QqvA
         arGbqxjYTv6NkuXGRp5DFYgDV0uqmovfsichF3+4E1WJXKLvIU2Ca3hByeF9PYSZKFgI
         6BCXR8+37oGqbM3aCQlWOeWR5TelD2/tVJGd066uN90hcmGt/b7aEOkM/kQQ286HLTP/
         GSvej6FNQV/o6j2vqfCJ3arOhjaf6yxNjnIZWjZmF6noVRMhTGfwRQp3g2IxDll58ry0
         umGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=1d4Ho5Lb+N2EQmlLihf4gpUxhbqWd9rIZ3zim+U53ok=;
        b=joAJaKeUkv91/aslDgcYHnLm0IyPxUDtjMiqLQ7UYP1pbS+bAN5plBN0mYU2pgcMOx
         Vq1v5sCAMCxQIEbKHQuZEPu3zkLc9Ht5Z3Xw5QiWP9c+p68gPrFyUg/utKkhfv07s5sc
         dwoQgbc2GRDBz9Z/6kPCOScYW/OzOHhc93/FHNfnXpJpSdTw385cMN2nsgmzqykcrtOo
         xLK8d3Cu/Xl9KeXfYYW5njmoN1xPeZ4GAIk7IbvVMVrdG1JdNv4rPtRNOMzEdXrmjA+i
         ndO4GaF0LCAPk8/wplZ4CFMaklaAv2/GbFjgxYu6lR73gYEH4jCfi4QqZuWwsvivsa47
         DaRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m138si571085qke.79.2019.04.03.12.43.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 12:43:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 61D9031028FB;
	Wed,  3 Apr 2019 19:43:58 +0000 (UTC)
Received: from [10.36.116.72] (ovpn-116-72.ams2.redhat.com [10.36.116.72])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 057617DF4B;
	Wed,  3 Apr 2019 19:43:48 +0000 (UTC)
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
 <1249f9dd-d22d-9e19-ee33-767581a30021@redhat.com>
 <CAKgT0UeqX8Q8BYAo4COfQ2TQGBduzctAf5Ko+0mUmSw-aemOSg@mail.gmail.com>
 <0fdc41fb-b2ba-c6e6-36b9-97ad5a6eb54c@redhat.com>
 <CAKgT0UcrkXKjMgYy2H3MKQxG71ScNqhwqxwti7QjvPSxtb8FBg@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <ddfd0c7f-b049-bbf7-5151-10d8f02e9f05@redhat.com>
Date: Wed, 3 Apr 2019 21:43:48 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UcrkXKjMgYy2H3MKQxG71ScNqhwqxwti7QjvPSxtb8FBg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 03 Apr 2019 19:43:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03.04.19 01:43, Alexander Duyck wrote:
> On Tue, Apr 2, 2019 at 11:53 AM David Hildenbrand <david@redhat.com> wrote:
>>
>>>>> Why do we need them running in parallel for a single guest? I don't
>>>>> think we need the hints so quickly that we would need to have multiple
>>>>> VCPUs running in parallel to provide hints. In addition as it
>>>>> currently stands in order to get pages into and out of the buddy
>>>>> allocator we are going to have to take the zone lock anyway so we
>>>>> could probably just assume a single thread for pulling the memory,
>>>>> placing it on the ring, and putting it back into the buddy allocator
>>>>> after the hint has been completed.
>>>>
>>>> VCPUs hint when they think the time has come. Hinting in parallel comes
>>>> naturally.
>>>
>>> Actually it doesn't because if we are doing it asynchronously we are
>>> having to pull pages out of the zone which requires the zone lock.
>>
>> Yes, and we already work with zones already when freeing. At least one zone.
>>
>>> That has been one of the reasons why the patches from Nitesh start
>>> dropping in performance when you start enabling more than 1 VCPU. If
>>> we are limited by the zone lock it doesn't make sense for us to try to
>>> do thing in parallel.
>>
>> That is an interesting point and I'd love to see some performance numbers.
> 
> So the last time I ran data it was with the virtio-balloon patch set I
> ended up having to make a number of fixes and tweaks. I believe the
> patches can be found online as I emailed them to the list and Nitesh,
> but I don't have them handy to point to.

AFAIK Nitesh integrated them.

> 
> Results w/ THP
> Baseline
> [root@localhost ~]# cd ~/will-it-scale/; ./runtest.py page_fault1
> tasks,processes,processes_idle,threads,threads_idle,linear
> 0,0,100,0,100,0
> 1,501001,93.72,500312,93.72,501001
> 2,918688,87.49,837092,87.51,1002002
> 3,1300535,81.22,1200746,81.39,1503003
> 4,1718865,75.01,1522041,75.20,2004004
> 5,2032902,68.77,1826264,69.26,2505005
> 6,2309724,62.55,1979819,63.89,3006006
> 7,2609748,56.30,1935436,60.20,3507007
> 8,2705883,50.07,1913416,57.45,4008008
> 9,2738392,43.84,2017198,51.24,4509009
> 10,2913739,37.63,1906649,48.65,5010010
> 11,2996000,31.41,1973332,41.86,5511011
> 12,2930790,25.19,1928318,37.33,6012012
> 13,2876603,18.97,2040026,31.83,6513013
> 14,2820274,12.77,2060417,27.19,7014014
> 15,2729018,6.55,2134531,24.33,7515015
> 16,2682826,0.36,2146440,21.25,8016016
> 
> My Patch Set
> [root@localhost will-it-scale]# cd ~/will-it-scale/; ./runtest.py page_fault1
> tasks,processes,processes_idle,threads,threads_idle,linear
> 0,0,100,0,100,0
> 1,459575,93.74,458546,93.73,459575
> 2,901990,87.47,841478,87.49,919150
> 3,1307078,81.26,1193380,81.43,1378725
> 4,1717429,75.03,1529761,75.30,1838300
> 5,2045371,68.79,1765334,70.01,2297875
> 6,2272685,62.56,1893388,65.42,2757450
> 7,2583919,56.34,2078468,59.85,3217025
> 8,2777732,50.10,2009627,57.08,3676600
> 9,2932699,43.90,1938315,52.00,4136175
> 10,2935508,37.70,1982124,46.55,4595750
> 11,2881811,31.45,2162791,41.36,5055325
> 12,2947880,25.27,2058337,38.93,5514900
> 13,2925530,19.11,1937080,32.13,5974475
> 14,2867833,12.89,2023161,25.80,6434050
> 15,2856156,6.69,2067414,24.67,6893625
> 16,2775991,0.53,2062535,17.46,7353200
> 
> Modified RH Virtio-Balloon based patch set
> [root@localhost ~]# cd ~/will-it-scale/; ./runtest.py page_fault1
> tasks,processes,processes_idle,threads,threads_idle,linear
> 0,0,100,0,100,0
> 1,522672,93.73,524206,93.73,524206
> 2,914612,87.47,828489,87.66,1048412
> 3,1336109,81.25,1156889,82.15,1572618
> 4,1638776,75.01,1419247,76.75,2096824
> 5,1982146,68.77,1676836,71.27,2621030
> 6,2211653,62.57,1865976,65.60,3145236
> 7,2456776,56.33,2111887,57.98,3669442
> 8,2594395,50.10,2101993,54.17,4193648
> 9,2672871,43.90,1864173,53.01,4717854
> 10,2695456,37.69,2152126,45.82,5242060
> 11,2702604,31.44,1962406,42.50,5766266
> 12,2702415,25.22,2078596,35.01,6290472
> 13,2677250,19.02,2068953,35.42,6814678
> 14,2612990,12.80,2053951,30.77,7338884
> 15,2521812,6.67,1876602,26.42,7863090
> 16,2472506,0.53,1957658,20.16,8387296
> 
> Basically when you compare the direct approach from the patch set I
> submitted versus the one using the virtio approach the virtio has
> better single thread performance, but doesn't scale as well as my
> patch set did. That is why I am thinking that if we can avoid trying
> to scale out to per-cpu and instead focus on just having one thread
> handle the feeding of the hints to the virtio device we could avoid
> the scaling penalty and instead get the best of both worlds.
> 

Sounds like a solid analysis to me. Thanks.

[...]
>>> only thing that has any specific limits to it. So I see it easily
>>> being possible for a good portion of memory being consumed by the
>>> queue when you consider that what you have is essentially the maximum
>>> length of the isolated page list multiplied by the number of entries
>>> in a virtqueue.
>>>
>>>> We have something that seems to work. Let's work from there instead of
>>>> scrapping the general design once more, thinking "it is super easy". And
>>>> yes, what you propose is pretty much throwing away the current design in
>>>> the guest.
>>>
>>> Define "work"? The last patch set required massive fixes as it was
>>> causing kernel panics if more than 1 VCPU was enabled and list
>>> corruption in general. I'm sure there are a ton more bugs lurking as
>>> we have only begun to be able to stress this code in any meaningful
>>> way.
>>
>> "work" - we get performance numbers that look promising and sorting out
>> issues in the design we find. This is RFC. We are discussing design
>> details. If there are issues in the design, let's discuss. If there are
>> alternatives, let's discuss. Bashing on the quality of prototypes?
>> Please don't.
> 
> I'm not so much bashing the quality as the lack of data. It is hard to
> say something is "working" when you have a hard time getting it to
> stay up long enough to collect any reasonable data. My concern is that
> the data looks really great when you don't have all the proper
> critical sections handled correctly, but when you add the locking that
> needs to be there it can make the whole point of an entire patch set
> moot.

Yes, and that is something to figure out during review. And you did that
excellently by even sending fixes :)

Not arguing against "quality of the prototype should improve with RFCs".

[...]

> 
>>>
>>>>> waiting on the processing. All I am suggesting is that we can get away
>>>>> from having to deal with both by just walking through the free pages
>>>>> for the higher order and hinting only a few at a time without having
>>>>> to try to provide the host with the hints on what is idle the second
>>>>> it is freed.
>>>>>
>>>>>>>
>>>>>>> I view this all as working not too dissimilar to how a standard Rx
>>>>>>> ring in a network device works. Only we would want to allocate from
>>>>>>> the pool of "Buddy" pages, flag the pages as "Offline", and then when
>>>>>>> the hint has been processed we would place them back in the "Buddy"
>>>>>>> list with the "Offline" value still set. The only real changes needed
>>>>>>> to the buddy allocator would be to add some logic for clearing/merging
>>>>>>> the "Offline" setting as necessary, and to provide an allocator that
>>>>>>> only works with non-"Offline" pages.
>>>>>>
>>>>>> Sorry, I had to smile at the phrase "only" in combination with "provide
>>>>>> an allocator that only works with non-Offline pages" :) . I guess you
>>>>>> realize yourself that these are core-mm changes that might easily be
>>>>>> rejected upstream because "the virt guys try to teach core-MM yet
>>>>>> another special case". I agree that this is nice to play with,
>>>>>> eventually that approach could succeed and be accepted upstream. But I
>>>>>> consider this long term work.
>>>>>
>>>>> The actual patch for this would probably be pretty small and compared
>>>>> to some of the other stuff that has gone in recently isn't too far out
>>>>> of the realm of possibility. It isn't too different then the code that
>>>>> has already done in to determine the unused pages for virtio-balloon
>>>>> free page hinting.
>>>>>
>>>>> Basically what we would be doing is providing a means for
>>>>> incrementally transitioning the buddy memory into the idle/offline
>>>>> state to reduce guest memory overhead. It would require one function
>>>>> that would walk the free page lists and pluck out pages that don't
>>>>> have the "Offline" page type set, a one-line change to the logic for
>>>>> allocating a page as we would need to clear that extra bit of state,
>>>>> and optionally some bits for how to handle the merge of two "Offline"
>>>>> pages in the buddy allocator (required for lower order support). It
>>>>> solves most of the guest side issues with the free page hinting in
>>>>> that trying to do it via the arch_free_page path is problematic at
>>>>> best since it was designed for a synchronous setup, not an
>>>>> asynchronous one.
>>>>
>>>> This is throwing away work. No I don't think this is the right path to
>>>> follow for now. Feel free to look into it while Nitesh gets something in
>>>> shape we know conceptually works and we are starting to know which
>>>> issues we are hitting.
>>>
>>> Yes, it is throwing away work. But if the work is running toward a
>>> dead end does it add any value?
>>
>> "I'm not throwing anything away. " vs. "Yes, it is throwing away work.",
>> now we are on the same page.
>>
>> So your main point here is that you are fairly sure we are are running
>> towards an dead end, right?
> 
> Yes. There is a ton of code here that is adding complexity and bugs
> that I would consider waste. If we can move to a single threaded
> approach the code could become much simpler as we will only have a
> single queue that we have to service and we could get away from 2
> levels of lists and the allocation that goes with them. In addition I
> think we could get away with much more code reuse as the
> get_free_page_and_send function could likely be adapted to provide a
> more generic function for adding a page of a specific size to the
> queue versus the current assumption that the only page size is
> VIRTIO_BALLOON_FREE_PAGE_ORDER.

We could also implement a single-threaded approach on top of the current
approach. Instead of scanning for free pages "blindly", scan the frees
recorder by the vcpus via the arch_free_pages callback or similar. One
issue is, that one can drop hints once the thread can't keep up. Locking
is also something to care about. Maybe recording hints globally per zone
could mitigate the issue, as the zone lock already has to be involved
when freeing. (I remember we used to prototype something like that
before, at least it was similar but different :) )

We could the go into "exception" mode once we drop too many hints, and
go eventually back to normal mode. See below.

> 
>>>
>>> I've been looking into the stuff Nitesh has been doing. I don't know
>>> about others, but I have been testing it. That is why I provided the
>>> patches I did to get it stable enough for me to test and address the
>>> regressions it was causing. That is the source of some of my concern.
>>
>> Testing and feedback is very much appreciated. You have concerns, they
>> are valid. I do like discussing concerns, discussing possible solutions,
>> or finding out that it cannot be solved the easy way. Then throw it away.
>>
>> Coming up with a clean design that considers problems that are not
>> directly visible is something I would like to see. But usually they
>> don't jump at you before prototyping.
>>
>> The simplest approach so far was "scan for zero pages in the
>> hypervisor". No changes in the guest needed except setting pages to zero
>> when freeing. No additional threads in the guest. No hinting. And still
>> we decided against it.
> 
> Right, I get that. There is still going to be a certain amount of
> overhead for zeroing the pages in adding the scanning on the host will
> not come cheap. I had considered something similar when I first looked
> into this.

Interestingly, there are some architectures (e.g. s390x) that can do
zeroing directly in the memory controller using some instructions - at
least that is what I heard. There, the overhead in the guest is very
small. Scanning for zero pages using KSM in the host is then the
problematic part.

But the real problem is that the host has to scan, and when it is
OOM/about to swap, it might be too late to scan random guests to detect
free pages.

> 
>>> I think we have been making this overly complex with all the per-cpu
>>> bits and trying to place this in the free path itself. We really need
>>
>> We already removed complexity, at least that is my impression. There are
>> bugs in there, yes.
> 
> So one of the concerns I have at this point is the sheer number of
> allocations and the list shuffling that is having to take place.
> 
> The design of the last patch set had us enqueueing addresses on the
> per-cpu "free_pages_obj". Then when we hit a certain threshold it will
> call guest_free_page_hinting which is allocated via kmalloc and then
> populated with the pages that can be isolated. Then that function
> calls guest_free_page_report which will yet again kmalloc a hint_req
> object that just contains a pointer to our isolated pages list. If we
> can keep the page count small we could just do away with all of that
> and instead do something more like get_free_page_and_send.

Yes, not denying that more simplifications like this might be possible.
This is what we are looking for :)

> 
>>> to scale this back and look at having a single thread with a walker of
>>> some sort just hinting on what memory is sitting in the buddy but not
>>> hinted on. It is a solution that would work, even in a multiple VCPU
>>> case, and is achievable in the short term.
>> Can you write up your complete proposal and start a new thread. What I
>> understood so far is
>>
>> 1. Separate hinting thread
>>
>> 2. Use virtio-balloon mechanism similar to Nitesh's work
>>
>> 3. Iterate over !offline pages in the buddy. Take them temporarily out
>> of the buddy (similar to Niteshs work). Send them to the hypervisor.
>> Mark them offline, put them back to the buddy.
>>
>> 4. When a page leaves the buddy, drop the offline marker.
> 
> Yep, that is pretty much it. I'll see if I can get a write-up of it tomorrow.

That would be good, I think a sane approach on how to limit hinting
overhead due to scanning in certain corner cases needs quite some thought.

> 
>>
>> Selected issues to be sorted out:
>> - We have to find a way to mask pages offline. We are effectively
>> touching pages we don't own (keeping flags set when returning pages to
>> the buddy). Core MM has to accept this change.
>> - We might teach other users how to treat buddy pages now. Offline
>> always has to be cleared.
>> - How to limit the cycles wasted scanning? Idle guests?
> 
> One thought I had would be to look at splitting nr_free_pages in each
> free_area and splitting it into two free running counters, one for the
> number of pages added, and one for the number of pages removed. Then
> it would be pretty straight forward to determine how many are
> available as we could maintain a free running counter for each free
> area in the balloon driver to determine if we need to scan a given
> area.

When thinking about this, we should always keep in mind some corner
cases that could happen. If you have a  process that simply allocates
and frees 64mb continuously, and could do that in a frequency that could
make hinting

1. Search for the pages
2. Isolate the pages
3. Hint the pages

In a loop, basically consuming 100% of a host CPU just for hinting, then
this would be really bad.

I'm afraid scanning without taking proper actions can result in a lot of
hinting overhead CPU-wise if not done in a smart way.


See my comment above about possible combining both approaches. Once we
drop a lot of hints, switch from using what the CPUs record to scanning
the free list.

This would mean, one hinting thread, minimal work during freeing of
pages (e.g. record into an array per zone), no need to scan with little
activity, don't lose hints on a lot of activity.

Best of both worlds?

> 
>> - How to efficiently scan a list that might always change between
>> hinting requests?
>> - How to avoid OOM that can still happen in corner cases, after all you
>> are taking pages out of the buddy temporarily.
> 
> Yes, but hopefully it should be a small enough amount that nobody will
> notice. In many cases devices such as NICs can consume much more than
> this regularly for just their Rx buffers and it is not an issue. There
> has to be a certain amount of overhead that any given device is
> allowed to consume. If we contain the balloon hinting to just 64M that
> should be a small enough amount that nobody would notice in practice.

Depends on the setup. If your guest has 512MB-1024MB or less, it could
already be problematic, as it would be roughly around 10%. Most probably
you won't find plenty of 2MB/4MB pages either way ... At least it has to
be documented, so people enabling hinting are aware of this. (something
suggested along the lines in this thread by me)


-- 

Thanks,

David / dhildenb

