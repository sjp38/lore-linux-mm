Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5C4CC742D2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 16:25:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A5722063F
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 16:25:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A5722063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8E898E00DB; Fri, 12 Jul 2019 12:25:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3FAF8E0003; Fri, 12 Jul 2019 12:25:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D060E8E00DB; Fri, 12 Jul 2019 12:25:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id B0D608E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 12:25:55 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id k125so7335340qkc.12
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 09:25:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=BIURRMZkCo13Ia+L7IZ8p69K5ngWdRN7fX/g1dB/OoA=;
        b=LPSn2IDKj6XOMU055J1tEUM24OgEFofjXZku7BgvQiQCTEcrD4DnNbLRNfGOFzmYoU
         gjurMeaNEhGvY+03gsXYhuo/sRupZyCnqUfAbR++ACSfN/sA2IpFzWTSornMlMDa4d1T
         tDhhJWrpHghmI+VFvDzSrW88zWqdq6s2RyC3oJBisCUyljwaPuWkDUkcccIlz2ye8Jlt
         3MiQ6Om+Zk4AfB/GtQlJ1FL+Qci28OW4PAvDL/PZvF6hTeio4867uMXlmnGXBuQnMvEt
         PD/xUn/DQhkqtjAMEdS9qmoFE8aT5vdgQR/uQO1BqXKTo02p8pJhZFhVIFvR06mWCpK3
         zxGQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXR9x7rd7t0W6nRsIAcYaWJ606PbqrgjqN8xoGax/WSDkKgUoqv
	ubFKBFLZFHTdBQcw18f7b42EL3G95AfMQ6yvaFFB5TYe5AMSY19bPfhTOvcg2BAg3bdsURffU+A
	nh79ZRHMVGtLN/qll7l7iDhQyaPeSjL6RC3+kNr6QbCbIT1JQcCtpKXu3eee5+E5Rmg==
X-Received: by 2002:ac8:32e8:: with SMTP id a37mr7289024qtb.231.1562948755447;
        Fri, 12 Jul 2019 09:25:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuo7Dnq0OUtfbO6PT7jrt1R9bM9KfMi/xDLk7A5HeyeZrYt6PgDiPkUMW78HfKSye917T0
X-Received: by 2002:ac8:32e8:: with SMTP id a37mr7288950qtb.231.1562948754356;
        Fri, 12 Jul 2019 09:25:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562948754; cv=none;
        d=google.com; s=arc-20160816;
        b=ug2+0fXlkDxbeODx13+qUF8O3oiDzJ79a9RFf/Rs6CZs5yZdOcci9QqzHNJnerus6O
         T2kp7xxbomJoJVkU0I+3o4WsUdHfC/yzp0m2Ujl95Zr5uZWQaXqyhRCEP3LuTEg9IXmx
         UoT0nG9QWdKouQcrrVAvSxTr0gAWUyf0Cz2ZF4qkOVZDPMFUXfMazWxDiLEEj6efyG81
         lxtzTsnTwhVphazw6IGKdtEDmJ0u+7oJPTPrLrFEUn+H+IAuidYX451nRLDiquOAluAl
         xTJ7ZxWlsJMxW/MgvD/pO1SQ7StnWKF9VG+PcpSXav6VCrqNdsRGSAxds9UenLdF1TYo
         Rhhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=BIURRMZkCo13Ia+L7IZ8p69K5ngWdRN7fX/g1dB/OoA=;
        b=gVPEGw/S3Djz6TtLBC2qar2MR0Xw/wftUcZL1RkakOyaYRe1d/L8uSnMLyCPJcBI3Z
         cF1NH27aReKEjt4VhZNTGfpojJlQJdSgxORSuzAZxPzzV4BTWYO3//RyWy6YPttEtXCX
         WkZQvpYqRn0GSWDYtWbEjQBiTVCrHnORrwEZ1gcgNH4c3y7sFl78R4xVlrUPLfx2W7P8
         Fy9hli3jlWrH4TqH7pbYS9ZzJp6WJoeBLCG4pdgrKFi8J1jSP6hBzHat6cdIULEzg6Xi
         uWyUUUlvzoal871/602jcXP0x7wCGD/DGRYsro3jhg2qkWylS9fSuUza9IJtISe9wIwp
         dzBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k30si5841591qtc.353.2019.07.12.09.25.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 09:25:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 53C38317F31E;
	Fri, 12 Jul 2019 16:25:53 +0000 (UTC)
Received: from [10.40.205.73] (unknown [10.40.205.73])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B14EB1001DF6;
	Fri, 12 Jul 2019 16:25:20 +0000 (UTC)
Subject: Re: [RFC][Patch v11 1/2] mm: page_hinting: core infrastructure
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>,
 john.starks@microsoft.com, Dave Hansen <dave.hansen@intel.com>,
 Michal Hocko <mhocko@suse.com>
References: <20190710195158.19640-1-nitesh@redhat.com>
 <20190710195158.19640-2-nitesh@redhat.com>
 <CAKgT0Ue3mVZ_J0GgMUP4PBW4SUD1=L9ixD5nUZybw9_vmBAT0A@mail.gmail.com>
 <3c6c6b93-eb21-a04c-d0db-6f1b134540db@redhat.com>
 <CAKgT0UcaKhAf+pTeE1CRxqhiPtR2ipkYZZ2+aChetV7=LDeSeA@mail.gmail.com>
 <521db934-3acd-5287-6e75-67feead8ca63@redhat.com>
 <CAKgT0Uf7xsdh9OgBq-kyTkyvh8Qo9kV4uiWTVP7NKqzO4X0wyg@mail.gmail.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <89c65447-f876-9aac-957f-85f30ca43b2f@redhat.com>
Date: Fri, 12 Jul 2019 12:25:17 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAKgT0Uf7xsdh9OgBq-kyTkyvh8Qo9kV4uiWTVP7NKqzO4X0wyg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Fri, 12 Jul 2019 16:25:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/12/19 12:22 PM, Alexander Duyck wrote:
> On Thu, Jul 11, 2019 at 6:13 PM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>>
>> On 7/11/19 7:20 PM, Alexander Duyck wrote:
>>> On Thu, Jul 11, 2019 at 10:58 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>>>> On 7/10/19 5:56 PM, Alexander Duyck wrote:
>>>>> On Wed, Jul 10, 2019 at 12:52 PM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>>>>>> This patch introduces the core infrastructure for free page hinting in
>>>>>> virtual environments. It enables the kernel to track the free pages which
>>>>>> can be reported to its hypervisor so that the hypervisor could
>>>>>> free and reuse that memory as per its requirement.
>>>>>>
>>>>>> While the pages are getting processed in the hypervisor (e.g.,
>>>>>> via MADV_FREE), the guest must not use them, otherwise, data loss
>>>>>> would be possible. To avoid such a situation, these pages are
>>>>>> temporarily removed from the buddy. The amount of pages removed
>>>>>> temporarily from the buddy is governed by the backend(virtio-balloon
>>>>>> in our case).
>>>>>>
>>>>>> To efficiently identify free pages that can to be hinted to the
>>>>>> hypervisor, bitmaps in a coarse granularity are used. Only fairly big
>>>>>> chunks are reported to the hypervisor - especially, to not break up THP
>>>>>> in the hypervisor - "MAX_ORDER - 2" on x86, and to save space. The bits
>>>>>> in the bitmap are an indication whether a page *might* be free, not a
>>>>>> guarantee. A new hook after buddy merging sets the bits.
>>>>>>
>>>>>> Bitmaps are stored per zone, protected by the zone lock. A workqueue
>>>>>> asynchronously processes the bitmaps, trying to isolate and report pages
>>>>>> that are still free. The backend (virtio-balloon) is responsible for
>>>>>> reporting these batched pages to the host synchronously. Once reporting/
>>>>>> freeing is complete, isolated pages are returned back to the buddy.
>>>>>>
>>>>>> There are still various things to look into (e.g., memory hotplug, more
>>>>>> efficient locking, possible races when disabling).
>>>>>>
>>>>>> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
>>> So just FYI, I thought I would try the patches. It looks like there
>>> might be a bug somewhere that is causing it to free memory it
>>> shouldn't be. After about 10 minutes my VM crashed with a system log
>>> full of various NULL pointer dereferences.
>> That's interesting, I have tried the patches with MADV_DONTNEED as well.
>> I just retried it but didn't see any crash. May I know what kind of
>> workload you are running?
> I was running the page_fault1 test on a VM with 80G of memory.
>
>>>  The only change I had made
>>> is to use MADV_DONTNEED instead of MADV_FREE in QEMU since my headers
>>> didn't have MADV_FREE on the host. It occurs to me one advantage of
>>> MADV_DONTNEED over MADV_FREE is that you are more likely to catch
>>> these sort of errors since it zeros the pages instead of leaving them
>>> intact.
>> For development purpose maybe. For the final patch-set I think we
>> discussed earlier why we should keep MADV_FREE.
> I'm still not convinced MADV_FREE is a net win, at least for
> performance. You are still paying the cost for the VMEXIT in order to
> regain ownership of the page. In the case that you are under memory
> pressure it is essentially equivalent to MADV_DONTNEED. Also it
> doesn't really do much to help with the memory footprint of the VM
> itself. With the MADV_DONTNEED the pages are freed back and you have a
> greater liklihood of reducing the overall memory footprint of the
> entire system since you would be more likely to be assigned pages that
> were recently used rather than having to access a cold page.	
>
> <snip>
>
>>>>>> +void page_hinting_enqueue(struct page *page, int order)
>>>>>> +{
>>>>>> +       int zone_idx;
>>>>>> +
>>>>>> +       if (!page_hitning_conf || order < PAGE_HINTING_MIN_ORDER)
>>>>>> +               return;
>>>>> I would think it is going to be expensive to be jumping into this
>>>>> function for every freed page. You should probably have an inline
>>>>> taking care of the order check before you even get here since it would
>>>>> be faster that way.
>>>> I see, I can take a look. Thanks.
>>>>>> +
>>>>>> +       bm_set_pfn(page);
>>>>>> +       if (atomic_read(&page_hinting_active))
>>>>>> +               return;
>>>>> So I would think this piece is racy. Specifically if you set a PFN
>>>>> that is somewhere below the PFN you are currently processing in your
>>>>> scan it is going to remain unset until you have another page freed
>>>>> after the scan is completed. I would worry you can end up with a batch
>>>>> free of memory resulting in a group of pages sitting at the start of
>>>>> your bitmap unhinted.
>>>> True, but that will be hinted next time threshold is met.
>>> Yes, but that assumes that there is another free immediately coming.
>>> It is possible that you have a big application run and then
>>> immediately shut down and have it free all its memory at once. Worst
>>> case scenario would be that it starts by freeing from the end and
>>> works toward the start. With that you could theoretically end up with
>>> a significant chunk of memory waiting some time for another big free
>>> to come along.
>> Any suggestion on some benchmark/test application which I could run to
>> see this kind of behavior?
> Like I mentioned before, try doing a VM with a bigger memory
> footprint. You could probably just do a stack of VMs like what we were
> doing with the memhog test. Basically the longer it takes to process
> all the pages the greater the liklihood that there are still pages
> left when they are freed.
Thanks. Before next posting I will make sure to test with a larger VM
(>64GB).
-- 
Thanks
Nitesh

