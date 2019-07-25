Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 471FAC76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 12:09:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2CA2218F0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 12:09:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2CA2218F0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AF4E8E006E; Thu, 25 Jul 2019 08:09:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85F8F8E0059; Thu, 25 Jul 2019 08:09:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7270F8E006E; Thu, 25 Jul 2019 08:09:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4F3D78E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 08:09:06 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id l9so44186560qtu.12
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 05:09:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=+DEUCqv3RuqkXPjjOyd/tzU5msUkLDsAuo7V1PrO1Ik=;
        b=r7Xv2dcMfNCZHUOy5x2SvtQoI6jBi0KiD5kjwBzLYqB79iMWzEy5II8tBe2IN6OiRL
         b2BmsKJoTmUivLvGsugd5CcidzrOUa9crrdCQchEnzzAp9cauAyoKHx6aLiZXROhp2i7
         pg54LRlx81DqMowBvQjPfFoCMV6l0PzDEvXylht5th8cfsp5iTaMh2jbdy2ZIJX/tN1w
         FVjuVNpNxKa80Mz0tuda7K7yNOoC8muwn4kTrHQ2c5LkU91UEcnJCVyYQOs4Lea3DP25
         cA3Z3WKJRrJ132Tbh9hugyQGcg8DTl+kAGXjLAWwrKey8MSpGgkt/45+TIpJCDX8cBPM
         3C4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXapx/A1itFrE+F6aLnQlNhclXl7BLhspn8O68PKAlhIvnTq4ZU
	Gs+bxQdc0rN/04hjL+eO8jIpRgvYJT5+XRgXgNyHXCt7jb0oPP2v083PqiOX4PvPbxFwZ60CKtd
	9J0Mv7xSjIGOO+0yaU/Gfx/yJX4jg8bu+mRNEn4eHTR7AKclTuik5uHzfV2WHupWDqw==
X-Received: by 2002:a37:48d8:: with SMTP id v207mr54945197qka.316.1564056546012;
        Thu, 25 Jul 2019 05:09:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8Sc+r7AMP7zb791vicaMCFx54ZA6kvZ2Ma5fEcxG9wUBuvACcbMLSGKvi9J6b6asthxfn
X-Received: by 2002:a37:48d8:: with SMTP id v207mr54945100qka.316.1564056544793;
        Thu, 25 Jul 2019 05:09:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564056544; cv=none;
        d=google.com; s=arc-20160816;
        b=cmHCcanEgMBG3Y540mFwlLmWs4X+9fS31QUtlKwItu0lIzuIIrnLUrGxbmpVl2iE3d
         LUJ029KlsBENNslO0/ciaIvmzqaodZGUYkwL/dXQyi3RnTuJyjMuh5aZvJFCD+DSestq
         zIVVwG+RInOU1dvZa9QkYroGJOTxJiVH0GSa/hebgUWS9I865ykWBLyyYbnixCrD3cup
         UcP9GMEb/ZMafnQn+uR16LPQLmVykkYNzrGb7+sjb0iiC/GL4aq7Iz1s4/5VbyOdVApv
         uh+JehOj4HhLQ603oyrFSnNTB536ahygTFzCEo1l23jBKhk2Ak/1uQy1uTVMN2CK0Gaw
         o/Lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=+DEUCqv3RuqkXPjjOyd/tzU5msUkLDsAuo7V1PrO1Ik=;
        b=BveXUjxBPm1FAfuSMympxdQjwdc2fmUdJi4FEl5OilDPU3wS/M8A6MXYmC7cQCSn7R
         /aCHZzc1HvL5xwfJcyZfm5tnjjitCxGKuS1qkpPJ6B7L98zYeB9tuGpWrglL15a2ASdZ
         Q3OCsYFo0Dx5NYtrZL17NeBR5Es+I6h3p7soudyFLdBvaF8wZYYRXMjhNNxLjfhhjgmS
         oynIv/IMiz8IzKSY8b06QZMXvrphAK8pL7vRte9ttUKo3BzkMKbPQOPBre1+OxGiAoRE
         cYOHEinveQVxaOcz84kDtn0KNd8VBQZpAXmtfV8w6TqsKZX5g7CGgPNbh/aS9F2RDh4q
         70gg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 8si30033685qkp.128.2019.07.25.05.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 05:09:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DD62A300CA39;
	Thu, 25 Jul 2019 12:09:03 +0000 (UTC)
Received: from [10.18.17.163] (dhcp-17-163.bos.redhat.com [10.18.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A21735DC1A;
	Thu, 25 Jul 2019 12:08:53 +0000 (UTC)
Subject: Re: [PATCH v2 0/5] mm / virtio: Provide support for page hinting
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
 david@redhat.com, mst@redhat.com, dave.hansen@intel.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <0c520470-4654-cdf2-cf4d-d7c351d25e8b@redhat.com>
 <088abe33117e891dd6265179f678847bd574c744.camel@linux.intel.com>
 <e738fa65-cd1f-a9d2-8db5-318de3e49a81@redhat.com>
 <c5f6c247f9a28d374678bae01952ca7fd2c044b2.camel@linux.intel.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <e5ac0bff-ffb4-0c42-6431-49e53bbea59b@redhat.com>
Date: Thu, 25 Jul 2019 08:08:52 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <c5f6c247f9a28d374678bae01952ca7fd2c044b2.camel@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Thu, 25 Jul 2019 12:09:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/24/19 5:00 PM, Alexander Duyck wrote:
> On Wed, 2019-07-24 at 16:38 -0400, Nitesh Narayan Lal wrote:
>> On 7/24/19 4:27 PM, Alexander Duyck wrote:
>>> On Wed, 2019-07-24 at 14:40 -0400, Nitesh Narayan Lal wrote:
>>>> On 7/24/19 12:54 PM, Alexander Duyck wrote:
>>>>> This series provides an asynchronous means of hinting to a hypervis=
or
>>>>> that a guest page is no longer in use and can have the data associa=
ted
>>>>> with it dropped. To do this I have implemented functionality that a=
llows
>>>>> for what I am referring to as page hinting
>>>>>
>>>>> The functionality for this is fairly simple. When enabled it will a=
llocate
>>>>> statistics to track the number of hinted pages in a given free area=
=2E When
>>>>> the number of free pages exceeds this value plus a high water value=
,
>>>>> currently 32,
>>>> Shouldn't we configure this to a lower number such as 16?
>>> Yes, we could do 16.
>>>
>>>>>  it will begin performing page hinting which consists of
>>>>> pulling pages off of free list and placing them into a scatter list=
=2E The
>>>>> scatterlist is then given to the page hinting device and it will pe=
rform
>>>>> the required action to make the pages "hinted", in the case of
>>>>> virtio-balloon this results in the pages being madvised as MADV_DON=
TNEED
>>>>> and as such they are forced out of the guest. After this they are p=
laced
>>>>> back on the free list, and an additional bit is added if they are n=
ot
>>>>> merged indicating that they are a hinted buddy page instead of a st=
andard
>>>>> buddy page. The cycle then repeats with additional non-hinted pages=
 being
>>>>> pulled until the free areas all consist of hinted pages.
>>>>>
>>>>> I am leaving a number of things hard-coded such as limiting the low=
est
>>>>> order processed to PAGEBLOCK_ORDER,
>>>> Have you considered making this option configurable at the compile t=
ime?
>>> We could. However, PAGEBLOCK_ORDER is already configurable on some
>>> architectures. I didn't see much point in making it configurable in t=
he
>>> case of x86 as there are only really 2 orders that this could be used=
 in
>>> that provided good performance and that MAX_ORDER - 1 and PAGEBLOCK_O=
RDER.
>>>
>>>>>  and have left it up to the guest to
>>>>> determine what the limit is on how many pages it wants to allocate =
to
>>>>> process the hints.
>>>> It might make sense to set the number of pages to be hinted at a tim=
e from the
>>>> hypervisor.
>>> We could do that. Although I would still want some upper limit on tha=
t as
>>> I would prefer to keep the high water mark as a static value since it=
 is
>>> used in an inline function. Currently the virtio driver is the one
>>> defining the capacity of pages per request.
>> For the upper limit I think we can rely on max vq size. Isn't?
> I would still want to limit how many pages could be pulled. Otherwise w=
e
> have the risk of a hypervisor that allocates a vq size of 1024 or
> something like that and with 4M pages that could essentially OOM a 4G
> guest.
>
> That is why I figure what we probably should do is base the upper limit=
 of
> either 16 or 32 so that we only have at most something like 64M or 128M=
 of
> memory being held by the driver while it is being "reported". If we lea=
ve
> spare room in the ring so be it, better that then triggering unneeded O=
OM
> conditions.
>
>>>>> My primary testing has just been to verify the memory is being free=
d after
>>>>> allocation by running memhog 79g on a 80g guest and watching the to=
tal
>>>>> free memory via /proc/meminfo on the host. With this I have verifie=
d most
>>>>> of the memory is freed after each iteration. As far as performance =
I have
>>>>> been mainly focusing on the will-it-scale/page_fault1 test running =
with
>>>>> 16 vcpus. With that I have seen at most a 2% difference between the=
 base
>>>>> kernel without these patches and the patches with virtio-balloon di=
sabled.
>>>>> With the patches and virtio-balloon enabled with hinting the result=
s
>>>>> largely depend on the host kernel. On a 3.10 RHEL kernel I saw up t=
o a 2%
>>>>> drop in performance as I approached 16 threads,
>>>> I think this is acceptable.
>>>>>  however on the the lastest
>>>>> linux-next kernel I saw roughly a 4% to 5% improvement in performan=
ce for
>>>>> all tests with 8 or more threads.=20
>>>> Do you mean that with your patches the will-it-scale/page_fault1 num=
bers were
>>>> better by 4-5% over an unmodified kernel?
>>> Yes. That is the odd thing. I am wondering if there was some improvem=
ent
>>> in the zeroing of THP pages or something that is somehow improving th=
e
>>> cache performance for the accessing of the pages by the test in the g=
uest.
>> The values you were observing on an unmodified kernel, were they consi=
stent over
>> fresh reboot?
>> Do you have any sort of workload running in the host as that could als=
o impact
>> the numbers.
> The host was an unmodified linux-next kernel. What I was doing is I wou=
ld
> reboot, load the guest run one kernel, swap the kernel in the guest and=

> just reboot the guest, run the next kernel, and then switch back to the=

> first kernel to make certain there wasn't anything that changed between=

> the runs.


As long as the host kernel and environment remain the same for the guest =
kernel
with hinting patches and without hinting patches. We should be fine in co=
mparing
the two? We would expect the will-it-scale/page_fault1 number in these tw=
o cases
to be close to one another.


>
> I still need to do more research though. I'm still suspecting it has
> something to do with the page zeroing on faults though as that was what=

> was showing up on a perf top when we hit about 8 or more threads active=
 in
> the guest.
>>>>> I believe the difference seen is due to
>>>>> the overhead for faulting pages back into the guest and zeroing of =
memory.
>>>> It may also make sense to test these patches with netperf to observe=
 how much
>>>> performance drop it is introducing.
>>> Do you have some test you were already using? I ask because I am not =
sure
>>> netperf would generate a large enough memory window size to really tr=
igger
>>> much of a change in terms of hinting. If you have some test in mind I=

>>> could probably set it up and run it pretty quick.
>> Earlier I have tried running netperf on a guest with 2 cores, i.e., ne=
tserver
>> pinned to one and netperf running on the other.
>> You have to specify a really large packet size and run the test for at=
 least
>> 15-30 minutes to actually see some hinting work.
> I can take a look. I am not expecting much though.
>
>>>>> Patch 4 is a bit on the large side at about 600 lines of change, ho=
wever
>>>>> I really didn't see a good way to break it up since each piece feed=
s into
>>>>> the next. So I couldn't add the statistics by themselves as it didn=
't
>>>>> really make sense to add them without something that will either re=
ad or
>>>>> increment/decrement them, or add the Hinted state without something=
 that
>>>>> would set/unset it. As such I just ended up adding the entire thing=
 as
>>>>> one patch. It makes it a bit bigger but avoids the issues in the pr=
evious
>>>>> set where I was referencing things before they had been added.
>>>>>
>>>>> Changes from the RFC:
>>>>> https://lore.kernel.org/lkml/20190530215223.13974.22445.stgit@local=
host.localdomain/
>>>>> Moved aeration requested flag out of aerator and into zone->flags.
>>>>> Moved bounary out of free_area and into local variables for aeratio=
n.
>>>>> Moved aeration cycle out of interrupt and into workqueue.
>>>>> Left nr_free as total pages instead of splitting it between raw and=
 aerated.
>>>>> Combined size and physical address values in virtio ring into one 6=
4b value.
>>>>>
>>>>> Changes from v1:
>>>>> https://lore.kernel.org/lkml/20190619222922.1231.27432.stgit@localh=
ost.localdomain/
>>>>> Dropped "waste page treatment" in favor of "page hinting"
>>>> We may still have to try and find a better name for virtio-balloon s=
ide changes.
>>>> As "FREE_PAGE_HINT" and "PAGE_HINTING" are still confusing.
>>> We just need to settle on a name. Essentially all this requires is ju=
st a
>>> quick find and replace with whatever name we decide on.
>> I agree.
> I will probably look at seeing if I can keep the kernel feature as free=

> page hinting and just make the virtio feature page reporting. It should=
 be
> pretty straight forward as I could just replace the mentions of react w=
ith
> report and only have to tweak a few bits of patch 5.


I still think that we should stick with the same name for the kernel and =
the
virtio. But as you said this is not a blocker and the just requires a qui=
ck find
and replace.


>
--=20
Thanks
Nitesh

