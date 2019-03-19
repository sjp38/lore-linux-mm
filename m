Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18055C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 13:33:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9B9E2083D
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 13:33:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9B9E2083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A4A26B0003; Tue, 19 Mar 2019 09:33:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47ADC6B0006; Tue, 19 Mar 2019 09:33:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 343686B0007; Tue, 19 Mar 2019 09:33:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0463C6B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 09:33:23 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e1so19495314qth.23
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 06:33:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=Ol7wmFYC0yt2J8Enw0IUeOjUWirB7fs5SbBFtEMBCog=;
        b=WHTlx3NUSIKQ3f8IoivNTEjVoY01m1ZO4VOUrNaBO4hD9QJYBGK/3EJZfU56DhMH6O
         H4DtWohavr+xM81ih7hIlXoWK+fV8GXwXmHldMF5539K/hrCKhNomYki4lUn6mk2K8mO
         jo6P0I/mr2UBqYxxoRbz+8kMfIyiAF67NiPhMbP1r1ecJsz7CqWP2v+FKTCoVw6FHjs/
         SOJPc35CgSDFWwUViUh6mgrsppirvl27Sp9slgoltYVht3lXRQqkNoKv6bMXhpXt3cil
         qyMHD26IW6lYt0FJJOQ8ktFX6HZFSeR1gFN3kfUkZCJwJmZ0coqRBtt/Or2cmOzdGUJ9
         J6TA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWUfn4+4m0XBrfxsEZIslji8iqMbzBSv6BaP7cWqnY7K4/5N9M4
	OFLUMdLxvZnX6LTYG/WIkIYjKgEwzdtsSFj/zct6UPy7t7Gyj6p8s5p8OPqbbNrMv7tSn++NsH+
	oXDgSgiuRDfvN2pIIcxLLK5rIj/FY7kkR378z5Z/CTlfMZhE0O9Ij3NUPgIS+1L3pdw==
X-Received: by 2002:a37:f506:: with SMTP id l6mr1914525qkk.110.1553002402737;
        Tue, 19 Mar 2019 06:33:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVkgJZFpcXHRwVk8CZcKqfB20W+mXGHXmsnJKxtxO5PchDC0sLFQAVSsV52siE4qazArS4
X-Received: by 2002:a37:f506:: with SMTP id l6mr1914384qkk.110.1553002401119;
        Tue, 19 Mar 2019 06:33:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553002401; cv=none;
        d=google.com; s=arc-20160816;
        b=ghbuH1VKHzGboHpyfBzhbYGHRxY6e9/YgeigfaeEjto6pxHkMajcBC1DMSJptuNqQB
         MpVW7LQeUpeLEU1BezWbYJ63gXsoB3M/BtuB0LTRhJoWyOF7bUP/mj31IVscqxUVWL3s
         IlwjyP0I1lTiRAwgrvyyeXcTX1OytaRME/cE5RZVexbEUzuww5rtNAM8atJc04AzpiuT
         CtmLiGmOf/J+vXucc+MBdAz4jGhIl7sAKkq2HQ00PeFYPGVKu9GkYkGj3RKylLDsL2Qd
         o1wRddi1kbb0rKkijG50y/rQib24WNBdFQLFvfP9X+ziwtQahIe/xc8q6Devc1ANCQlZ
         MlIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=Ol7wmFYC0yt2J8Enw0IUeOjUWirB7fs5SbBFtEMBCog=;
        b=rLXIcMsZDeqyjfI0bg/jvAHnvEtDGo5UcU6PPTsZ3ZFVlWtfldfuK1f/3dmgbQK4to
         BQ8z1fSwXwYjYk4DpwFrEdIft+RAlXpJbv2v+9QciC9YE7IJEOZoYbKa/VrTNgcAaqXQ
         Ov5N6Mkas2uqxvuKcv26of2l3QP4NK6buNB/VNnc6m41d+JigXiuo/woaems4TuSIaPu
         Exh1URQM3rOr9mcISJFI4sZuElLwoYoxecV/w2wSR0czn+GcDMMpYyuXreqqAQQE2Ldh
         GOPHzOeKiJOLAQIS4q+L7ks+1yJO+yG2qNO8dDlTpucHkaEckwxG6V/CPkO4x9ZcXJYt
         yssw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m5si1806241qkd.82.2019.03.19.06.33.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 06:33:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4D5C53089E61;
	Tue, 19 Mar 2019 13:33:19 +0000 (UTC)
Received: from [10.36.117.99] (ovpn-117-99.ams2.redhat.com [10.36.117.99])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 55C1C282F5;
	Tue, 19 Mar 2019 13:33:01 +0000 (UTC)
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
To: Nitesh Narayan Lal <nitesh@redhat.com>,
 Alexander Duyck <alexander.duyck@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com>
 <20190306130955-mutt-send-email-mst@kernel.org>
 <ce55943e-87b6-c102-9827-2cfd45b7192c@redhat.com>
 <CAKgT0UcGCFNQRZFmp8oMkG+wKzRtwN292vtFWgyLsdyRnO04gQ@mail.gmail.com>
 <ed9f7c2e-a7e3-a990-bcc3-459e4f2b4a44@redhat.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <4bd54f8b-3e9a-3493-40be-668962282431@redhat.com>
Date: Tue, 19 Mar 2019 14:33:00 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <ed9f7c2e-a7e3-a990-bcc3-459e4f2b4a44@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Tue, 19 Mar 2019 13:33:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 18.03.19 16:57, Nitesh Narayan Lal wrote:
> On 3/14/19 12:58 PM, Alexander Duyck wrote:
>> On Thu, Mar 14, 2019 at 9:43 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>>>
>>> On 3/6/19 1:12 PM, Michael S. Tsirkin wrote:
>>>> On Wed, Mar 06, 2019 at 01:07:50PM -0500, Nitesh Narayan Lal wrote:
>>>>> On 3/6/19 11:09 AM, Michael S. Tsirkin wrote:
>>>>>> On Wed, Mar 06, 2019 at 10:50:42AM -0500, Nitesh Narayan Lal wrote:
>>>>>>> The following patch-set proposes an efficient mechanism for handing freed memory between the guest and the host. It enables the guests with no page cache to rapidly free and reclaims memory to and from the host respectively.
>>>>>>>
>>>>>>> Benefit:
>>>>>>> With this patch-series, in our test-case, executed on a single system and single NUMA node with 15GB memory, we were able to successfully launch 5 guests(each with 5 GB memory) when page hinting was enabled and 3 without it. (Detailed explanation of the test procedure is provided at the bottom under Test - 1).
>>>>>>>
>>>>>>> Changelog in v9:
>>>>>>>    * Guest free page hinting hook is now invoked after a page has been merged in the buddy.
>>>>>>>         * Free pages only with order FREE_PAGE_HINTING_MIN_ORDER(currently defined as MAX_ORDER - 1) are captured.
>>>>>>>    * Removed kthread which was earlier used to perform the scanning, isolation & reporting of free pages.
>>>>>>>    * Pages, captured in the per cpu array are sorted based on the zone numbers. This is to avoid redundancy of acquiring zone locks.
>>>>>>>         * Dynamically allocated space is used to hold the isolated guest free pages.
>>>>>>>         * All the pages are reported asynchronously to the host via virtio driver.
>>>>>>>         * Pages are returned back to the guest buddy free list only when the host response is received.
>>>>>>>
>>>>>>> Pending items:
>>>>>>>         * Make sure that the guest free page hinting's current implementation doesn't break hugepages or device assigned guests.
>>>>>>>    * Follow up on VIRTIO_BALLOON_F_PAGE_POISON's device side support. (It is currently missing)
>>>>>>>         * Compare reporting free pages via vring with vhost.
>>>>>>>         * Decide between MADV_DONTNEED and MADV_FREE.
>>>>>>>    * Analyze overall performance impact due to guest free page hinting.
>>>>>>>    * Come up with proper/traceable error-message/logs.
>>>>>>>
>>>>>>> Tests:
>>>>>>> 1. Use-case - Number of guests we can launch
>>>>>>>
>>>>>>>    NUMA Nodes = 1 with 15 GB memory
>>>>>>>    Guest Memory = 5 GB
>>>>>>>    Number of cores in guest = 1
>>>>>>>    Workload = test allocation program allocates 4GB memory, touches it via memset and exits.
>>>>>>>    Procedure =
>>>>>>>    The first guest is launched and once its console is up, the test allocation program is executed with 4 GB memory request (Due to this the guest occupies almost 4-5 GB of memory in the host in a system without page hinting). Once this program exits at that time another guest is launched in the host and the same process is followed. We continue launching the guests until a guest gets killed due to low memory condition in the host.
>>>>>>>
>>>>>>>    Results:
>>>>>>>    Without hinting = 3
>>>>>>>    With hinting = 5
>>>>>>>
>>>>>>> 2. Hackbench
>>>>>>>    Guest Memory = 5 GB
>>>>>>>    Number of cores = 4
>>>>>>>    Number of tasks         Time with Hinting       Time without Hinting
>>>>>>>    4000                    19.540                  17.818
>>>>>>>
>>>>>> How about memhog btw?
>>>>>> Alex reported:
>>>>>>
>>>>>>     My testing up till now has consisted of setting up 4 8GB VMs on a system
>>>>>>     with 32GB of memory and 4GB of swap. To stress the memory on the system I
>>>>>>     would run "memhog 8G" sequentially on each of the guests and observe how
>>>>>>     long it took to complete the run. The observed behavior is that on the
>>>>>>     systems with these patches applied in both the guest and on the host I was
>>>>>>     able to complete the test with a time of 5 to 7 seconds per guest. On a
>>>>>>     system without these patches the time ranged from 7 to 49 seconds per
>>>>>>     guest. I am assuming the variability is due to time being spent writing
>>>>>>     pages out to disk in order to free up space for the guest.
>>>>>>
>>>>> Here are the results:
>>>>>
>>>>> Procedure: 3 Guests of size 5GB is launched on a single NUMA node with
>>>>> total memory of 15GB and no swap. In each of the guest, memhog is run
>>>>> with 5GB. Post-execution of memhog, Host memory usage is monitored by
>>>>> using Free command.
>>>>>
>>>>> Without Hinting:
>>>>>                  Time of execution    Host used memory
>>>>> Guest 1:        45 seconds            5.4 GB
>>>>> Guest 2:        45 seconds            10 GB
>>>>> Guest 3:        1  minute               15 GB
>>>>>
>>>>> With Hinting:
>>>>>                 Time of execution     Host used memory
>>>>> Guest 1:        49 seconds            2.4 GB
>>>>> Guest 2:        40 seconds            4.3 GB
>>>>> Guest 3:        50 seconds            6.3 GB
>>>> OK so no improvement. OTOH Alex's patches cut time down to 5-7 seconds
>>>> which seems better. Want to try testing Alex's patches for comparison?
>>>>
>>> I realized that the last time I reported the memhog numbers, I didn't
>>> enable the swap due to which the actual benefits of the series were not
>>> shown.
>>> I have re-run the test by including some of the changes suggested by
>>> Alexander and David:
>>>     * Reduced the size of the per-cpu array to 32 and minimum hinting
>>> threshold to 16.
>>>     * Reported length of isolated pages along with start pfn, instead of
>>> the order from the guest.
>>>     * Used the reported length to madvise the entire length of address
>>> instead of a single 4K page.
>>>     * Replaced MADV_DONTNEED with MADV_FREE.
>>>
>>> Setup for the test:
>>> NUMA node:1
>>> Memory: 15GB
>>> Swap: 4GB
>>> Guest memory: 6GB
>>> Number of core: 1
>>>
>>> Process: A guest is launched and memhog is run with 6GB. As its
>>> execution is over next guest is launched. Everytime memhog execution
>>> time is monitored.
>>> Results:
>>>     Without Hinting:
>>>                  Time of execution
>>>     Guest1:    22s
>>>     Guest2:    24s
>>>     Guest3: 1m29s
>>>
>>>     With Hinting:
>>>                 Time of execution
>>>     Guest1:    24s
>>>     Guest2:    25s
>>>     Guest3:    28s
>>>
>>> When hinting is enabled swap space is not used until memhog with 6GB is
>>> ran in 6th guest.
>> So one change you may want to make to your test setup would be to
>> launch the tests sequentially after all the guests all up, instead of
>> combining the test and guest bring-up. In addition you could run
>> through the guests more than once to determine a more-or-less steady
>> state in terms of the performance as you move between the guests after
>> they have hit the point of having to either swap or pull MADV_FREE
>> pages.
> I tried running memhog as you suggested, here are the results:
> Setup for the test:
> NUMA node:1
> Memory: 15GB
> Swap: 4GB
> Guest memory: 6GB
> Number of core: 1
> 
> Process: 3 guests are launched and memhog is run with 6GB. Results are
> monitored after 1st-time execution of memhog. Memhog is launched
> sequentially in each of the guests and time is observed after the
> execution of all 3 memhog is over.
> 
> Results:
> Without Hinting
>     Time of Execution   
> 1.    6m48s                   
> 2.    6m9s               
> 
> With Hinting
> Array size:16 Minimum Threshold:8
> 1.    2m57s           
> 2.    2m20s           
> 
> The memhog execution time in the case of hinting is still not that low
> as we would have expected. This is due to the usage of swap space.
> Although wrt to non-hinting when swap used space is around 3.5G, with
> hinting it remains to around 1.1-1.5G.
> I did try using a zone free page barrier which prevented hinting when
> free pages of order HINTING_ORDER goes below 256. This further brings
> down the swap usage to 100-150 MB. The tricky part of this approach is
> to configure this barrier condition for different guests.
> 
> Array size:16 Minimum Threshold:8
> 1.    1m16s       
> 2.    1m41s
> 
> Note: Memhog time does seem to vary a little bit on every boot with or
> without hinting.
> 

I don't quite understand yet why "hinting more pages" (no free page
barrier) should result in a higher swap usage in the hypervisor
(1.1-1.5GB vs. 100-150 MB). If we are "hinting more pages" I would have
guessed that runtime could get slower, but not that we need more swap.

One theory:

If you hint all MAX_ORDER - 1 pages, at one point it could be that all
"remaining" free pages are currently isolated to be hinted. As MM needs
more pages for a process, it will fallback to using "MAX_ORDER - 2"
pages and so on. These pages, when they are freed, you won't hint
anymore unless they get merged. But after all they won't get merged
because they can't be merged (otherwise they wouldn't be "MAX_ORDER - 2"
after all right from the beginning).

Try hinting a smaller granularity to see if this could actually be the case.

-- 

Thanks,

David / dhildenb

