Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2264BC4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 18:53:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6C032070D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 18:53:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6C032070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A7BC6B0273; Tue,  2 Apr 2019 14:53:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5578B6B0274; Tue,  2 Apr 2019 14:53:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D3496B0275; Tue,  2 Apr 2019 14:53:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 15EBF6B0273
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 14:53:45 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id l26so14217471qtk.18
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 11:53:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=VTMTgW9hOvgt81k2UXIx25aXhPsXNLHYEfRoEnk3yro=;
        b=NsZ7PS8aginXuJK37Yhi3LmxlMAfRkVgwV+jCcSDGXrA6KBXI2PnroR46ZI4a0KGy7
         hLgMczFTYW+XQ4bMrhzx01hrgCVbpQr/5p8Iun9Hcn6MFDF8WdvyVfw3l2YRnShsHBC7
         tiFLc4ea1mOEQ++HYrRPCuEZ97AaCWVBfKZYFpegMPFt5yR1YusYoDrc/ABUnmNR/vWK
         Nb4d8mFtwtG5YVdsxg1wm3teOo13nGo0b1WTnx0LE17CCSe7iVKiggNh6iH3/7F/iw5k
         P4HRszfYb9KXin6t9ZowiQwwGrEapudnSIWiuWg+X/Z9Fjp/5cHIrAzoeegvVh4y3SVO
         DwRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV9/CVBFMqy+zwp8y57WmpmIOXWuQ0m0ysAkrLeJqwwradW0KJv
	ZdCN/rjmHFta8lz1/y0rzPp3X+hu5usbscKidWqEoAHcVK2K/Ah9QZ7VlpHyX/2r4tXX+p3iZx0
	S+8Q7bCymGt/EZeWExeVMkFm53f004//aHvAw69hBUlT7sDZvNxEK4UIHP0fijFX2vg==
X-Received: by 2002:a37:9d06:: with SMTP id g6mr58145058qke.25.1554231224780;
        Tue, 02 Apr 2019 11:53:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypKUhCNj/yMxz/lPisUL1tupWHYOopn5D/4GQgGllbXXdGTSr7mKXEcEABSGkPbaOtc/y1
X-Received: by 2002:a37:9d06:: with SMTP id g6mr58145009qke.25.1554231223725;
        Tue, 02 Apr 2019 11:53:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554231223; cv=none;
        d=google.com; s=arc-20160816;
        b=fOzadWwYWR9ZKxdbI6HIApSL92Svae1NJQ8pmDMU+IryC8w1xk5yjHXLITmPy/8gLt
         d1I4UYt2WC8mhja7jsU8wLV0UURQksd4C6k4eFd0z6qRDfG/2c6SP/7I/PNwYXcH3we4
         1/v3apLylhTiMwgqEytQCb3o4u/so8Mr7SRAiXnwEjS2J5C/QohRfZBDCl6zlWP1lK6w
         qeNEGTSnpkgbo7vTa8z2P9bC89p9t3TRZ71Q72TDEvNGqY1m4bpCXShCm5RnDZYfHgVJ
         2HywS43yJ2L5uVNLZRJdV/7z9WHW2o4ZvYqPqgQxXkx8R0DAucwrUKMv2O6Ezi41xIER
         HVNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=VTMTgW9hOvgt81k2UXIx25aXhPsXNLHYEfRoEnk3yro=;
        b=a0x6iPFPxByT/Xds4wyvr65gzqJKVwgWe8I9X5bzEKF5dFQd3H/JWCMeRAuaNFNnV2
         LYXD8ZTJpfaWwFeJY33k7d6merj4QVpkhUYk43AEP+BKyYde4PenoWX4Bp4/6c+imToP
         MGCMHh2jH4MJ0XXfgCdA7Y69uHld4DpLTQUh/o7tXCkHwyNR8+rONp+Gl3bLDkjyRgmj
         Szsuy8W43KLPWzbgXBpickJ8KRgHCp2DWwsqeFisVESdxFzGACt8sWWmqnXUnDMGSDAf
         yZAlOB3voHkchdc+6t/t8VQgd7xJcDAZyuhK7UbpbTvZ4hIz+avYBM1UECipKVMzTNtE
         mWRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y7si3077056qka.108.2019.04.02.11.53.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 11:53:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BFA7C88302;
	Tue,  2 Apr 2019 18:53:42 +0000 (UTC)
Received: from [10.36.116.90] (ovpn-116-90.ams2.redhat.com [10.36.116.90])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0DC831001DDC;
	Tue,  2 Apr 2019 18:53:32 +0000 (UTC)
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
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <0fdc41fb-b2ba-c6e6-36b9-97ad5a6eb54c@redhat.com>
Date: Tue, 2 Apr 2019 20:53:32 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UeqX8Q8BYAo4COfQ2TQGBduzctAf5Ko+0mUmSw-aemOSg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Tue, 02 Apr 2019 18:53:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>>> Why do we need them running in parallel for a single guest? I don't
>>> think we need the hints so quickly that we would need to have multiple
>>> VCPUs running in parallel to provide hints. In addition as it
>>> currently stands in order to get pages into and out of the buddy
>>> allocator we are going to have to take the zone lock anyway so we
>>> could probably just assume a single thread for pulling the memory,
>>> placing it on the ring, and putting it back into the buddy allocator
>>> after the hint has been completed.
>>
>> VCPUs hint when they think the time has come. Hinting in parallel comes
>> naturally.
> 
> Actually it doesn't because if we are doing it asynchronously we are
> having to pull pages out of the zone which requires the zone lock.

Yes, and we already work with zones already when freeing. At least one zone.

> That has been one of the reasons why the patches from Nitesh start
> dropping in performance when you start enabling more than 1 VCPU. If
> we are limited by the zone lock it doesn't make sense for us to try to
> do thing in parallel.

That is an interesting point and I'd love to see some performance numbers.

>>> Also there isn't a huge priority to report idle memory in real time.
>>> That would be kind of pointless as it might be pulled back out and
>>> reused as soon as it is added. What we need is to give the memory a
>>> bit of time to "cool" so that we aren't constantly hinting away memory
>>> that is still in use.
>>
>> Depending on the setup, you don't want free memory lying around for too
>> long in your guest.
> 
> Right, but you don't need it as soon as it is freed either. If it is
> idle in the guest for a few seconds that shouldn't be an issue. The
> free page hinting will hurt performance if we are doing it too often
> simply because we are going to be triggering a much higher rate of
> page faults.

Valid point.

> 
>>>
>>>> Your approach sounds very interesting to play with, however
>>>> at this point I would like to avoid throwing away Nitesh work once again
>>>> to follow some other approach that looks promising. If we keep going
>>>> like that, we'll spend another ~10 years working on free page hinting
>>>> without getting anything upstream. Especially if it involves more
>>>> core-MM changes. We've been there, we've done that. As long as the
>>>> guest-host interface is generic enough, we can play with such approaches
>>>> later in the guest. Important part is that the guest-host interface
>>>> allows for that.
>>>
>>> I'm not throwing anything away. One of the issues in Nitesh's design
>>> is that he is going to either miss memory and have to run an
>>> asynchronous thread to clean it up after the fact, or he is going to
>>> cause massive OOM errors and/or have to start halting VCPUs while
>>
>> 1. how are we going to miss memory. We are going to miss memory because
>> we hint on very huge chunks, but we all agreed to live with that for now.
> 
> What I am talking about is that some application frees gigabytes of
> memory. As I recall the queue length for a single cpu is only like 1G.
> Are we going to be sitting on the backlog of most of system memory
> while we process it 1G at a time?

I think it is something around "pages that fit into a request" *
"numbers of entries in a virtqueue".

> 
>> 2. What are the "massive OOM" errors you are talking about? We have the
>> one scenario we described Nitesh was not even able to reproduce yet. And
>> we have ways to mitigate the problem (discussed in this thread).
> 
> So I am referring to the last patch set I have seen. Last I knew all
> the code was doing was assembling lists if isolated pages and placing
> them on a queue. I have seen no way that this really limits the length
> of the virtqueue, and the length of the isolated page lists is the

Ah yes, we are discussing something towards possible capping in this
thread. Once there would be too much being hinted already, skip hinting
for now. Which might have good and bad sides. Different discussion.

> only thing that has any specific limits to it. So I see it easily
> being possible for a good portion of memory being consumed by the
> queue when you consider that what you have is essentially the maximum
> length of the isolated page list multiplied by the number of entries
> in a virtqueue.
> 
>> We have something that seems to work. Let's work from there instead of
>> scrapping the general design once more, thinking "it is super easy". And
>> yes, what you propose is pretty much throwing away the current design in
>> the guest.
> 
> Define "work"? The last patch set required massive fixes as it was
> causing kernel panics if more than 1 VCPU was enabled and list
> corruption in general. I'm sure there are a ton more bugs lurking as
> we have only begun to be able to stress this code in any meaningful
> way.

"work" - we get performance numbers that look promising and sorting out
issues in the design we find. This is RFC. We are discussing design
details. If there are issues in the design, let's discuss. If there are
alternatives, let's discuss. Bashing on the quality of prototypes?
Please don't.

> 
> For example what happens if someone sits on the mm write semaphore for
> an extended period of time on the host? That will shut down all of the
> hinting until that is released, and at that point once again any
> hinting queues will be stuck on the guest until they can be processed
> by the host.

I remember that is why we are using asynchronous requests. Combined with
dropping hints when in such a situation (posted hints not getting
processed), nobody would be stuck. Or am I missing something? Yes, then
the issue of dropped hints arises, and that is a different discussion.

> 
>>> waiting on the processing. All I am suggesting is that we can get away
>>> from having to deal with both by just walking through the free pages
>>> for the higher order and hinting only a few at a time without having
>>> to try to provide the host with the hints on what is idle the second
>>> it is freed.
>>>
>>>>>
>>>>> I view this all as working not too dissimilar to how a standard Rx
>>>>> ring in a network device works. Only we would want to allocate from
>>>>> the pool of "Buddy" pages, flag the pages as "Offline", and then when
>>>>> the hint has been processed we would place them back in the "Buddy"
>>>>> list with the "Offline" value still set. The only real changes needed
>>>>> to the buddy allocator would be to add some logic for clearing/merging
>>>>> the "Offline" setting as necessary, and to provide an allocator that
>>>>> only works with non-"Offline" pages.
>>>>
>>>> Sorry, I had to smile at the phrase "only" in combination with "provide
>>>> an allocator that only works with non-Offline pages" :) . I guess you
>>>> realize yourself that these are core-mm changes that might easily be
>>>> rejected upstream because "the virt guys try to teach core-MM yet
>>>> another special case". I agree that this is nice to play with,
>>>> eventually that approach could succeed and be accepted upstream. But I
>>>> consider this long term work.
>>>
>>> The actual patch for this would probably be pretty small and compared
>>> to some of the other stuff that has gone in recently isn't too far out
>>> of the realm of possibility. It isn't too different then the code that
>>> has already done in to determine the unused pages for virtio-balloon
>>> free page hinting.
>>>
>>> Basically what we would be doing is providing a means for
>>> incrementally transitioning the buddy memory into the idle/offline
>>> state to reduce guest memory overhead. It would require one function
>>> that would walk the free page lists and pluck out pages that don't
>>> have the "Offline" page type set, a one-line change to the logic for
>>> allocating a page as we would need to clear that extra bit of state,
>>> and optionally some bits for how to handle the merge of two "Offline"
>>> pages in the buddy allocator (required for lower order support). It
>>> solves most of the guest side issues with the free page hinting in
>>> that trying to do it via the arch_free_page path is problematic at
>>> best since it was designed for a synchronous setup, not an
>>> asynchronous one.
>>
>> This is throwing away work. No I don't think this is the right path to
>> follow for now. Feel free to look into it while Nitesh gets something in
>> shape we know conceptually works and we are starting to know which
>> issues we are hitting.
> 
> Yes, it is throwing away work. But if the work is running toward a
> dead end does it add any value?

"I'm not throwing anything away. " vs. "Yes, it is throwing away work.",
now we are on the same page.

So your main point here is that you are fairly sure we are are running
towards an dead end, right?

> 
> I've been looking into the stuff Nitesh has been doing. I don't know
> about others, but I have been testing it. That is why I provided the
> patches I did to get it stable enough for me to test and address the
> regressions it was causing. That is the source of some of my concern.

Testing and feedback is very much appreciated. You have concerns, they
are valid. I do like discussing concerns, discussing possible solutions,
or finding out that it cannot be solved the easy way. Then throw it away.

Coming up with a clean design that considers problems that are not
directly visible is something I would like to see. But usually they
don't jump at you before prototyping.

The simplest approach so far was "scan for zero pages in the
hypervisor". No changes in the guest needed except setting pages to zero
when freeing. No additional threads in the guest. No hinting. And still
we decided against it.

> I think we have been making this overly complex with all the per-cpu
> bits and trying to place this in the free path itself. We really need

We already removed complexity, at least that is my impression. There are
bugs in there, yes.

> to scale this back and look at having a single thread with a walker of
> some sort just hinting on what memory is sitting in the buddy but not
> hinted on. It is a solution that would work, even in a multiple VCPU
> case, and is achievable in the short term.
Can you write up your complete proposal and start a new thread. What I
understood so far is

1. Separate hinting thread

2. Use virtio-balloon mechanism similar to Nitesh's work

3. Iterate over !offline pages in the buddy. Take them temporarily out
of the buddy (similar to Niteshs work). Send them to the hypervisor.
Mark them offline, put them back to the buddy.

4. When a page leaves the buddy, drop the offline marker.


Selected issues to be sorted out:
- We have to find a way to mask pages offline. We are effectively
touching pages we don't own (keeping flags set when returning pages to
the buddy). Core MM has to accept this change.
- We might teach other users how to treat buddy pages now. Offline
always has to be cleared.
- How to limit the cycles wasted scanning? Idle guests?
- How to efficiently scan a list that might always change between
hinting requests?
- How to avoid OOM that can still happen in corner cases, after all you
are taking pages out of the buddy temporarily.

-- 

Thanks,

David / dhildenb

