Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BCF8C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:54:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06A5C20665
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:54:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06A5C20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82EF46B0007; Wed, 24 Jul 2019 15:54:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DFE38E0002; Wed, 24 Jul 2019 15:54:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A69B6B000A; Wed, 24 Jul 2019 15:54:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 46B326B0007
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:54:14 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id v126so20874001vkv.20
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:54:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=FWpu2qEQucB218gQEf2JtEf9l0ObGxypBZiVY6jm5hQ=;
        b=uWxLBk5GbUFbF1rjONJpiL6OUiHF2aEJjdBwZ9CMp16rXpoCiM1XsFL0e7Juhk0znw
         njRDKz8UIT9I3U/6LhYxGwsVr2dnnxmii62JKbmbsItTtdQ9C04sIsXzdM9KVVAvpsCe
         PB1QBjEYgbnH87gUZKsCTYGi1ifdlsA8uHIZmB8MD5Ni02inWfSR469xEbe9FGQLcC3M
         a6UedROTwqehoA5H0MwAy0F6X6QCJ/0X7fHUTt7HAMMFvNsYyOAddtoFFo0eqxDpfJHH
         h3Km9SLVepjVGvlVNP+6+dK9BIiBsFaE8Gi6uRGKO5ixqR2c7CH/p7flI2o97zojo9FK
         JhLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXRafINxeHTxxLRM4gl1w2MlJFQYjlz5AmM9y0jZDgpbYFUWj+A
	BAqjz2fbWuqbXeAlRBtStHbz6J/2z0p8V4jABBrf4olU+R5KQoP8cOeHw7IJ0gMjcq33FKW+G7+
	7zwEEZPawKOp5h+JjqxjJF5Oj3rbrlKnZHwIOK2bTM+Kk+jeLmluRuuiEEzZjN7C6hA==
X-Received: by 2002:a67:b14c:: with SMTP id z12mr50563539vsl.11.1563998054004;
        Wed, 24 Jul 2019 12:54:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyE8zPkJKqFYgeXalyIcpaLu9hHOnO/QjDTn/+6Os9ZWXzTcLkW277Bmy1XiDrj9LhmgKg3
X-Received: by 2002:a67:b14c:: with SMTP id z12mr50563478vsl.11.1563998053368;
        Wed, 24 Jul 2019 12:54:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563998053; cv=none;
        d=google.com; s=arc-20160816;
        b=WoCYDpbhB5OqC3BnI/7E5KkYJv2SP2mBrDiF6ZAuXVtnd1pWCLmasLoJWWFptL15bY
         rd5HILZAthbUs0SCUHUu90Wrpj6yvBTA3DxjtDnTC1XIsW1R/cb3LzCTNjUKqE9SgRkC
         MC0jyGJHPDKGpkN47EnTU7kuzDWCk7SqqJOWuydFOEYoGqp2GviXqCBBQbONLg3oxXZw
         ImUG5KVVnYgAQVqVSK/RE0xNX/F5xsNoSGNilZ/jaIj9Okj1rMfv/OxWd9EO8lxBtKnW
         +wa1J/c1zwRHq6YGiHCyZH5MTY9zV6CHeY/Xss2m8Q8mreGsk2SMl0h/BjHo2UOjih5r
         lQNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=FWpu2qEQucB218gQEf2JtEf9l0ObGxypBZiVY6jm5hQ=;
        b=xVr3QjPsqz2psnx1BK5bP4NVQlUeWd8RS8TsXo+EKgT7vU2ro9aK4y2k5gFyFHN9qN
         Yv/5WLvujW2Ej4jDAom6nKLC3LPqUUXF2uIcP2EPj4zYmzjXFN3QBLCEdEjlbYtNgXKB
         CwT1lWfqZraaoBbVbQiNe/YhEpkjxMXxOpMWWBELiLsRLEh3+eqi9SwapNDN4ril9MI/
         hCfYErELFygv0A3Fi5kjnm8xHcB0wnxku7U8Lpe/5ChAqR1WTHEjT+szWONcqgQFjWWf
         B/B12iJXwatW1RkvZJDO0mjWS0jAVD7eOXz5LGdei7L97+66rQxVIZACD65a7QcLQ0tL
         J3WQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e6si12175719vsl.282.2019.07.24.12.54.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 12:54:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 52C83308620B;
	Wed, 24 Jul 2019 19:54:12 +0000 (UTC)
Received: from [10.18.17.163] (dhcp-17-163.bos.redhat.com [10.18.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 501D560A35;
	Wed, 24 Jul 2019 19:54:06 +0000 (UTC)
Subject: Re: [PATCH v2 0/5] mm / virtio: Provide support for page hinting
To: David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin"
 <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, yang.zhang.wz@gmail.com, pagupta@redhat.com,
 riel@surriel.com, konrad.wilk@oracle.com, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <0c520470-4654-cdf2-cf4d-d7c351d25e8b@redhat.com>
 <f7578309-dd36-bda0-6a30-34a6df21faca@redhat.com>
 <20190724153003-mutt-send-email-mst@kernel.org>
 <b3279b70-7a64-a456-cbfa-2a5ec3e9468e@redhat.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <b81da61b-164d-ccb7-9251-9c2f1a3dfb9d@redhat.com>
Date: Wed, 24 Jul 2019 15:54:05 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <b3279b70-7a64-a456-cbfa-2a5ec3e9468e@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 24 Jul 2019 19:54:12 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/24/19 3:47 PM, David Hildenbrand wrote:
> On 24.07.19 21:31, Michael S. Tsirkin wrote:
>> On Wed, Jul 24, 2019 at 08:41:33PM +0200, David Hildenbrand wrote:
>>> On 24.07.19 20:40, Nitesh Narayan Lal wrote:
>>>> On 7/24/19 12:54 PM, Alexander Duyck wrote:
>>>>> This series provides an asynchronous means of hinting to a hypervisor
>>>>> that a guest page is no longer in use and can have the data associated
>>>>> with it dropped. To do this I have implemented functionality that allows
>>>>> for what I am referring to as page hinting
>>>>>
>>>>> The functionality for this is fairly simple. When enabled it will allocate
>>>>> statistics to track the number of hinted pages in a given free area. When
>>>>> the number of free pages exceeds this value plus a high water value,
>>>>> currently 32,
>>>> Shouldn't we configure this to a lower number such as 16?
>>>>>  it will begin performing page hinting which consists of
>>>>> pulling pages off of free list and placing them into a scatter list. The
>>>>> scatterlist is then given to the page hinting device and it will perform
>>>>> the required action to make the pages "hinted", in the case of
>>>>> virtio-balloon this results in the pages being madvised as MADV_DONTNEED
>>>>> and as such they are forced out of the guest. After this they are placed
>>>>> back on the free list, and an additional bit is added if they are not
>>>>> merged indicating that they are a hinted buddy page instead of a standard
>>>>> buddy page. The cycle then repeats with additional non-hinted pages being
>>>>> pulled until the free areas all consist of hinted pages.
>>>>>
>>>>> I am leaving a number of things hard-coded such as limiting the lowest
>>>>> order processed to PAGEBLOCK_ORDER,
>>>> Have you considered making this option configurable at the compile time?
>>>>>  and have left it up to the guest to
>>>>> determine what the limit is on how many pages it wants to allocate to
>>>>> process the hints.
>>>> It might make sense to set the number of pages to be hinted at a time from the
>>>> hypervisor.
>>>>> My primary testing has just been to verify the memory is being freed after
>>>>> allocation by running memhog 79g on a 80g guest and watching the total
>>>>> free memory via /proc/meminfo on the host. With this I have verified most
>>>>> of the memory is freed after each iteration. As far as performance I have
>>>>> been mainly focusing on the will-it-scale/page_fault1 test running with
>>>>> 16 vcpus. With that I have seen at most a 2% difference between the base
>>>>> kernel without these patches and the patches with virtio-balloon disabled.
>>>>> With the patches and virtio-balloon enabled with hinting the results
>>>>> largely depend on the host kernel. On a 3.10 RHEL kernel I saw up to a 2%
>>>>> drop in performance as I approached 16 threads,
>>>> I think this is acceptable.
>>>>>  however on the the lastest
>>>>> linux-next kernel I saw roughly a 4% to 5% improvement in performance for
>>>>> all tests with 8 or more threads. 
>>>> Do you mean that with your patches the will-it-scale/page_fault1 numbers were
>>>> better by 4-5% over an unmodified kernel?
>>>>> I believe the difference seen is due to
>>>>> the overhead for faulting pages back into the guest and zeroing of memory.
>>>> It may also make sense to test these patches with netperf to observe how much
>>>> performance drop it is introducing.
>>>>> Patch 4 is a bit on the large side at about 600 lines of change, however
>>>>> I really didn't see a good way to break it up since each piece feeds into
>>>>> the next. So I couldn't add the statistics by themselves as it didn't
>>>>> really make sense to add them without something that will either read or
>>>>> increment/decrement them, or add the Hinted state without something that
>>>>> would set/unset it. As such I just ended up adding the entire thing as
>>>>> one patch. It makes it a bit bigger but avoids the issues in the previous
>>>>> set where I was referencing things before they had been added.
>>>>>
>>>>> Changes from the RFC:
>>>>> https://lore.kernel.org/lkml/20190530215223.13974.22445.stgit@localhost.localdomain/
>>>>> Moved aeration requested flag out of aerator and into zone->flags.
>>>>> Moved bounary out of free_area and into local variables for aeration.
>>>>> Moved aeration cycle out of interrupt and into workqueue.
>>>>> Left nr_free as total pages instead of splitting it between raw and aerated.
>>>>> Combined size and physical address values in virtio ring into one 64b value.
>>>>>
>>>>> Changes from v1:
>>>>> https://lore.kernel.org/lkml/20190619222922.1231.27432.stgit@localhost.localdomain/
>>>>> Dropped "waste page treatment" in favor of "page hinting"
>>>> We may still have to try and find a better name for virtio-balloon side changes.
>>>> As "FREE_PAGE_HINT" and "PAGE_HINTING" are still confusing.
>>> We should have named that free page reporting, but that train already
>>> has left.
>> I think VIRTIO_BALLOON_F_FREE_PAGE_HINT is different and arguably
>> actually does provide hints.
> I guess it depends on the point of view (e.g., getting all free pages
> feels more like a report). But I could also live with using the term
> reporting in this context.
>
> We could go ahead and name it all "page reporting", would also work for me.
I think that should work.
Having two separate names one for the kernel and the other for the virtio
interface will cause unnecessary confusion.
-- 
Thanks
Nitesh

