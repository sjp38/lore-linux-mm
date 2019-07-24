Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3497EC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:38:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8AAE21734
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:38:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8AAE21734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BFE08E0008; Wed, 24 Jul 2019 16:38:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76FE38E0002; Wed, 24 Jul 2019 16:38:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 638498E0008; Wed, 24 Jul 2019 16:38:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 42A1B8E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:38:11 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id z13so40415978qka.15
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:38:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=2JDH3UtR2HjuTombjhLX9H5TW9TH6O8Ji3nipFtNjFc=;
        b=tnwxlzYMPLIoivA7Q/21QlFzRp6LbZacKolUxclUADVOS/GmCYrnJpsT5T+n2gDPRp
         tqLPkeMwRTea02A/R1YTQ8JkZCf8Ws57grJ+F4Vv5LdYtDU7aFhzIC/QwHFej4rAajiS
         zcZJd7wQbIK4OWBKSGOrfZ/0Pslp+JJwQwWIVoC3phCdZvxYPnI44jAV2rsxwzlixRw+
         d6dvMG6xm6d4p+M4E8m4bYrl1q7QV42r28qe9kIq9J1wsERfozq1A7NioEXjZhfi7Syn
         WdBWTUIEKw+P2bpKgFNm9xiM5wsMLeKayyRwFMbnC+U1Jys94DmUz7E8dZrXsJ4WBtcW
         CUlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVQsTNtnyS/7+ORenr6CGlnMgiP7jMIuvUe9MeJgkH94t4o3O/+
	O6GNxpQ8QARhoAB/HW+WuaONZ4HlplJEYTw6AnnPMg4xkDAz0Q7e2KiZl88UCdgFPSx2K4CWCcm
	nJmuIz56IEbeipe1Bz46jO1IoUm29QUSh/gdMHb7SckHVe+WP5Na/734OHBrtZRd/Wg==
X-Received: by 2002:a37:ef03:: with SMTP id j3mr8921997qkk.233.1564000690989;
        Wed, 24 Jul 2019 13:38:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwK8TTDB4xRVwhcigSqCk8w/YTLaqYDfPxkYT+RJRuihpHWiw4FDxwDggOGiETscpOVMyAV
X-Received: by 2002:a37:ef03:: with SMTP id j3mr8921974qkk.233.1564000690200;
        Wed, 24 Jul 2019 13:38:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564000690; cv=none;
        d=google.com; s=arc-20160816;
        b=D+cTP1rKeEyES3GqXxGtxIDKxnklPf98249nPYyg0WXi38qn/w2nCPLaNcqkS6+4Rx
         2xmz0oA37XwJIiyVC4CQD1wizYGRZZJk9HdpM6WFk9x98HVu3gfaDkVouTuGNxHFdiYt
         a+dNzSg5LBNiKqN32I2l/E40De9q3TSmw0RBdl2bmx/Kvwt2SrSOfBmDmjxFMkDo1r5W
         jL77qx/8B5ISymOuL/oaUSZ+Fz3d/0ZIw+DRTjXzvDfUMM8gE9Xim8qWbnkfBym0VKxE
         eNxv8OhqBgAGOSPvvT8/vhzP/Zbb9svSupWpJv8pRn/2x99DFxko0CmHqDCWqRkqkWnA
         +e3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=2JDH3UtR2HjuTombjhLX9H5TW9TH6O8Ji3nipFtNjFc=;
        b=mDoRP4rZkUiNeDnuMcTeUqV4DPoFhikGiDw17XBmnysPzwOHAHt5IW4NdawOTaB6UT
         jbqyKMuOd3n1JQ8DCaqokrtnrQrEpRqOMX5bD4fSJQhiKM6+srWdez9RH6+x2Rh+gH82
         Az3QSlpw1hM6YFZnoSVRH290l0jWAhd1Wl7g5O4brpkSKPvunEtifAgaXPpYyR45l/Pe
         2zU/w4+b0cTtHXAbIGMGu7uoX4dod84f14ByIHlu+Kz0g9dbxSY0mvQcy19h/ga7cZM5
         qfFbDbVDTz8mx04ATHmmGzMzCPzijqWbdsurqB3VM0HXqL1j1ROi2jh6SCXl68bjAo5m
         JBwA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l4si17152564qtb.237.2019.07.24.13.38.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 13:38:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3626830B1AD1;
	Wed, 24 Jul 2019 20:38:09 +0000 (UTC)
Received: from [10.18.17.163] (dhcp-17-163.bos.redhat.com [10.18.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 97A2819800;
	Wed, 24 Jul 2019 20:38:01 +0000 (UTC)
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
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <e738fa65-cd1f-a9d2-8db5-318de3e49a81@redhat.com>
Date: Wed, 24 Jul 2019 16:38:00 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <088abe33117e891dd6265179f678847bd574c744.camel@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 24 Jul 2019 20:38:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/24/19 4:27 PM, Alexander Duyck wrote:
> On Wed, 2019-07-24 at 14:40 -0400, Nitesh Narayan Lal wrote:
>> On 7/24/19 12:54 PM, Alexander Duyck wrote:
>>> This series provides an asynchronous means of hinting to a hypervisor=

>>> that a guest page is no longer in use and can have the data associate=
d
>>> with it dropped. To do this I have implemented functionality that all=
ows
>>> for what I am referring to as page hinting
>>>
>>> The functionality for this is fairly simple. When enabled it will all=
ocate
>>> statistics to track the number of hinted pages in a given free area. =
When
>>> the number of free pages exceeds this value plus a high water value,
>>> currently 32,
>> Shouldn't we configure this to a lower number such as 16?
> Yes, we could do 16.
>
>>>  it will begin performing page hinting which consists of
>>> pulling pages off of free list and placing them into a scatter list. =
The
>>> scatterlist is then given to the page hinting device and it will perf=
orm
>>> the required action to make the pages "hinted", in the case of
>>> virtio-balloon this results in the pages being madvised as MADV_DONTN=
EED
>>> and as such they are forced out of the guest. After this they are pla=
ced
>>> back on the free list, and an additional bit is added if they are not=

>>> merged indicating that they are a hinted buddy page instead of a stan=
dard
>>> buddy page. The cycle then repeats with additional non-hinted pages b=
eing
>>> pulled until the free areas all consist of hinted pages.
>>>
>>> I am leaving a number of things hard-coded such as limiting the lowes=
t
>>> order processed to PAGEBLOCK_ORDER,
>> Have you considered making this option configurable at the compile tim=
e?
> We could. However, PAGEBLOCK_ORDER is already configurable on some
> architectures. I didn't see much point in making it configurable in the=

> case of x86 as there are only really 2 orders that this could be used i=
n
> that provided good performance and that MAX_ORDER - 1 and PAGEBLOCK_ORD=
ER.
>
>>>  and have left it up to the guest to
>>> determine what the limit is on how many pages it wants to allocate to=

>>> process the hints.
>> It might make sense to set the number of pages to be hinted at a time =
from the
>> hypervisor.
> We could do that. Although I would still want some upper limit on that =
as
> I would prefer to keep the high water mark as a static value since it i=
s
> used in an inline function. Currently the virtio driver is the one
> defining the capacity of pages per request.
For the upper limit I think we can rely on max vq size. Isn't?
>
>>> My primary testing has just been to verify the memory is being freed =
after
>>> allocation by running memhog 79g on a 80g guest and watching the tota=
l
>>> free memory via /proc/meminfo on the host. With this I have verified =
most
>>> of the memory is freed after each iteration. As far as performance I =
have
>>> been mainly focusing on the will-it-scale/page_fault1 test running wi=
th
>>> 16 vcpus. With that I have seen at most a 2% difference between the b=
ase
>>> kernel without these patches and the patches with virtio-balloon disa=
bled.
>>> With the patches and virtio-balloon enabled with hinting the results
>>> largely depend on the host kernel. On a 3.10 RHEL kernel I saw up to =
a 2%
>>> drop in performance as I approached 16 threads,
>> I think this is acceptable.
>>>  however on the the lastest
>>> linux-next kernel I saw roughly a 4% to 5% improvement in performance=
 for
>>> all tests with 8 or more threads.=20
>> Do you mean that with your patches the will-it-scale/page_fault1 numbe=
rs were
>> better by 4-5% over an unmodified kernel?
> Yes. That is the odd thing. I am wondering if there was some improvemen=
t
> in the zeroing of THP pages or something that is somehow improving the
> cache performance for the accessing of the pages by the test in the gue=
st.
The values you were observing on an unmodified kernel, were they consiste=
nt over
fresh reboot?
Do you have any sort of workload running in the host as that could also i=
mpact
the numbers.
>
>>> I believe the difference seen is due to
>>> the overhead for faulting pages back into the guest and zeroing of me=
mory.
>> It may also make sense to test these patches with netperf to observe h=
ow much
>> performance drop it is introducing.
> Do you have some test you were already using? I ask because I am not su=
re
> netperf would generate a large enough memory window size to really trig=
ger
> much of a change in terms of hinting. If you have some test in mind I
> could probably set it up and run it pretty quick.
Earlier I have tried running netperf on a guest with 2 cores, i.e., netse=
rver
pinned to one and netperf running on the other.
You have to specify a really large packet size and run the test for at le=
ast
15-30 minutes to actually see some hinting work.
>
>>> Patch 4 is a bit on the large side at about 600 lines of change, howe=
ver
>>> I really didn't see a good way to break it up since each piece feeds =
into
>>> the next. So I couldn't add the statistics by themselves as it didn't=

>>> really make sense to add them without something that will either read=
 or
>>> increment/decrement them, or add the Hinted state without something t=
hat
>>> would set/unset it. As such I just ended up adding the entire thing a=
s
>>> one patch. It makes it a bit bigger but avoids the issues in the prev=
ious
>>> set where I was referencing things before they had been added.
>>>
>>> Changes from the RFC:
>>> https://lore.kernel.org/lkml/20190530215223.13974.22445.stgit@localho=
st.localdomain/
>>> Moved aeration requested flag out of aerator and into zone->flags.
>>> Moved bounary out of free_area and into local variables for aeration.=

>>> Moved aeration cycle out of interrupt and into workqueue.
>>> Left nr_free as total pages instead of splitting it between raw and a=
erated.
>>> Combined size and physical address values in virtio ring into one 64b=
 value.
>>>
>>> Changes from v1:
>>> https://lore.kernel.org/lkml/20190619222922.1231.27432.stgit@localhos=
t.localdomain/
>>> Dropped "waste page treatment" in favor of "page hinting"
>> We may still have to try and find a better name for virtio-balloon sid=
e changes.
>> As "FREE_PAGE_HINT" and "PAGE_HINTING" are still confusing.
> We just need to settle on a name. Essentially all this requires is just=
 a
> quick find and replace with whatever name we decide on.
I agree.
--=20
Thanks
Nitesh

