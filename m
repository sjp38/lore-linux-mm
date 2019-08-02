Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3930DC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 16:19:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC79820644
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 16:19:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC79820644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 888556B0006; Fri,  2 Aug 2019 12:19:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 839D86B0008; Fri,  2 Aug 2019 12:19:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7007D6B000D; Fri,  2 Aug 2019 12:19:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7C06B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 12:19:47 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x7so68418666qtp.15
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 09:19:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=P91EdaxPSqYreVp9PU6tt+Fx7WsUQ6GdDzLqIYCQmCY=;
        b=Ms8xF+DfCiHsU4O0ApIzWqDfyXIn1Vbkd3wE8rpumQLNX97szD521N/gGApBjJR+d1
         c5cs+0c47J0vvjj9ewHX1th6R4Wvr3upGDg08OB7tqLpVOuftJ6JUW0wC4+3Od2Wc9ka
         5aDDgV4pqTRNnW5jJvQ89TCBCx9pl8AiWuWHyONaRRbwJwGtCtBXes9VZ/XtLvAYnPBC
         P9l/yMuNmNzS7NxOOOY5R2gVqobVfypp/7G6vLhT457zrBLCdyYdYnuuyooAvaN6KGxe
         H7B5TLfy0QJPK/sI926CE1aZD1OpmZN7OVFM3r4WUrlxyOA2BFa53QsCGvrBBOCdfSp0
         XjdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXEyw1HyLz+03iQt5ZMNKhotyHOJLhka9XMIPr2xeJ4fvF1s5P4
	EiYggG6i9hB0tyuD3xhE0P8Yl8HcRB5qsxR+Ssuf6+qo6Fq9fXIh/hjxuqRyKroeqNWFUSbhQax
	Wf5IwLA29lkkPT8nvDpKBn1bYVgKM6eFr+xXmXUsU3QZGMmSSQ1r5PQ77cx6jfrj1rQ==
X-Received: by 2002:a0c:b012:: with SMTP id k18mr99491797qvc.74.1564762787066;
        Fri, 02 Aug 2019 09:19:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWos+nGLOpovb1/CM00LSsLjhL9XAePSuEvsRpQGGacFRpUnyjWvEgP2D3OI8CgtiupysD
X-Received: by 2002:a0c:b012:: with SMTP id k18mr99491729qvc.74.1564762786271;
        Fri, 02 Aug 2019 09:19:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564762786; cv=none;
        d=google.com; s=arc-20160816;
        b=zBuiqfWz/o8bR4rYaWITUFSoVloZo9vpfG1L3xc3e+O+2EfZye+rS1QaupJ/AkfasP
         +KvRN/rA/vW7PpaXb6GkwUwB+InDu1d+5b5QoliLKwd4w/HbbdEbBvcH5yFUyf/8I71R
         zzrRvTkuelv5cwkH0sV65nsppU8vUkqafYg35CCuuG3Bp6QGXl1OL65OO4c59SxqQ6vn
         QjrZK5pbpUKhhumgZbHyOz1MTlubWafvIw9VoLlHiK3ATPDsCZxm3s2kvAx3lp2Rn+zt
         vnOgMlBGpkkk0o6yYIfv6HXmNVLGcZklfZQe3DfHj7LjGNgMeeZS2ZqVedQPIg2mTTQ+
         vVEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=P91EdaxPSqYreVp9PU6tt+Fx7WsUQ6GdDzLqIYCQmCY=;
        b=s0xu5mlYklnBTlAlwvLABaxs3zuObFZLYOtfN5plm6gdF9+Q4FDFirzDTiJBPTr1D1
         yx1tisiRNDVSij5rASW2tgjxocYIx1v+atDgaYID6DWfRvk3CXfavWnnRdAFby2Toz3H
         1oFug8DqxeYJoSCf0gcXzflAq2s1ytZd57yFf3ZmNJMQma77jbjiO6R+dQAqGKPKgxRP
         qGCFwELHUnkIcNGeKSE1Rydq/LsA01tI8M7bd/MGxHuHcm5IxrbZMEVbTQ4pFUhSie57
         nYIUYrPXLxfoXnX+NBvam3bXVbDLXWDtSHwSmyuaaz9RW4+jRi2LyX5UeKcZCv7D+fEF
         aauQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v5si43313613qkf.36.2019.08.02.09.19.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 09:19:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F35283CA10;
	Fri,  2 Aug 2019 16:19:44 +0000 (UTC)
Received: from [10.40.204.149] (ovpn-204-149.brq.redhat.com [10.40.204.149])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id BD0C6600F8;
	Fri,  2 Aug 2019 16:19:29 +0000 (UTC)
Subject: Re: [PATCH v3 0/6] mm / virtio: Provide support for unused page
 reporting
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
 david@redhat.com, mst@redhat.com, dave.hansen@intel.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com
References: <20190801222158.22190.96964.stgit@localhost.localdomain>
 <9cddf98d-e2ce-0f8a-d46c-e15a54bc7391@redhat.com>
 <3f6c133ec1eabb8f4fd5c0277f8af254b934b14f.camel@linux.intel.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <291a1259-fd20-1712-0f0f-5abdefdca95f@redhat.com>
Date: Fri, 2 Aug 2019 12:19:25 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <3f6c133ec1eabb8f4fd5c0277f8af254b934b14f.camel@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Fri, 02 Aug 2019 16:19:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 8/2/19 11:13 AM, Alexander Duyck wrote:
> On Fri, 2019-08-02 at 10:41 -0400, Nitesh Narayan Lal wrote:
>> On 8/1/19 6:24 PM, Alexander Duyck wrote:
>>> This series provides an asynchronous means of reporting to a hypervis=
or
>>> that a guest page is no longer in use and can have the data associate=
d
>>> with it dropped. To do this I have implemented functionality that all=
ows
>>> for what I am referring to as unused page reporting
>>>
>>> The functionality for this is fairly simple. When enabled it will all=
ocate
>>> statistics to track the number of reported pages in a given free area=
=2E
>>> When the number of free pages exceeds this value plus a high water va=
lue,
>>> currently 32, it will begin performing page reporting which consists =
of
>>> pulling pages off of free list and placing them into a scatter list. =
The
>>> scatterlist is then given to the page reporting device and it will pe=
rform
>>> the required action to make the pages "reported", in the case of
>>> virtio-balloon this results in the pages being madvised as MADV_DONTN=
EED
>>> and as such they are forced out of the guest. After this they are pla=
ced
>>> back on the free list, and an additional bit is added if they are not=

>>> merged indicating that they are a reported buddy page instead of a
>>> standard buddy page. The cycle then repeats with additional non-repor=
ted
>>> pages being pulled until the free areas all consist of reported pages=
=2E
>>>
>>> I am leaving a number of things hard-coded such as limiting the lowes=
t
>>> order processed to PAGEBLOCK_ORDER, and have left it up to the guest =
to
>>> determine what the limit is on how many pages it wants to allocate to=

>>> process the hints. The upper limit for this is based on the size of t=
he
>>> queue used to store the scatterlist.
>>>
>>> My primary testing has just been to verify the memory is being freed =
after
>>> allocation by running memhog 40g on a 40g guest and watching the tota=
l
>>> free memory via /proc/meminfo on the host. With this I have verified =
most
>>> of the memory is freed after each iteration. As far as performance I =
have
>>> been mainly focusing on the will-it-scale/page_fault1 test running wi=
th
>>> 16 vcpus. With that I have seen up to a 2% difference between the bas=
e
>>> kernel without these patches and the patches with virtio-balloon enab=
led
>>> or disabled.
>> A couple of questions:
>>
>> - The 2% difference which you have mentioned, is this visible for
>>   all the 16 cores or just the 16th core?
>> - I am assuming that the difference is seen for both "number of proces=
s"
>>   and "number of threads" launched by page_fault1. Is that right?
> Really, the 2% is bordering on just being noise. Sometimes it is better=

> sometimes it is worse. However I think it is just slight variability in=

> the tests since it doesn't usually form any specific pattern.
>
> I have been able to tighten it down a bit by actually splitting my gues=
t
> over 2 nodes and pinning the vCPUs so that the nodes in the guest match=
 up
> to the nodes in the host. Doing that I have seen results where I had le=
ss
> than 1% variability between with the patches and without.

Interesting. I usually pin the guest to a single NUMA node to avoid this.=


>
> One thing I am looking at now is modifying the page_fault1 test to use =
THP
> instead of 4K pages as I suspect there is a fair bit of overhead in
> accessing the pages 4K at a time vs 2M at a time. I am hoping with that=
 I
> can put more pressure on the actual change and see if there are any
> additional spots I should optimize.


+1. Right now I don't think will-it-scale touches all the guest memory.
May I know how much memory does will-it-scale/page_fault1, occupies in yo=
ur case
and how much do you get back with your patch-set?

Do you have any plans of running any other benchmarks as well?
Just to see the impact on other sub-systems.

>>> One side effect of these patches is that the guest becomes much more
>>> resilient in terms of NUMA locality. With the pages being freed and t=
hen
>>> reallocated when used it allows for the pages to be much closer to th=
e
>>> active thread, and as a result there can be situations where this pat=
ch
>>> set will out-perform the stock kernel when the guest memory is not lo=
cal
>>> to the guest vCPUs.
>> Was this the reason because of which you were seeing better results fo=
r
>> page_fault1 earlier?
> Yes I am thinking so. What I have found is that in the case where the
> patches are not applied on the guest it takes a few runs for the number=
s
> to stabilize. What I think was going on is that I was running memhog to=

> initially fill the guest and that was placing all the pages on one node=
 or
> the other and as such was causing additional variability as the pages w=
ere
> slowly being migrated over to the other node to rebalance the workload.=

> One way I tested it was by trying the unpatched case with a direct-
> assigned device since that forces it to pin the memory. In that case I =
was
> getting bad results consistently as all the memory was forced to come f=
rom
> one node during the pre-allocation process.
>

I have also seen that the page_fault1 values take some time to get stabil=
ize on
an unmodified kernel.
What I am wondering here is that if on a single NUMA guest doing the foll=
owing
will give the right/better idea or not:

1. Pin the guest to a single NUMA node.
2. Run memhog so that it touches all the guest memory.
3. Run will-it-scale/page_fault1.

Compare/observe the values for the last core (this is considering the oth=
er core
values doesn't drastically differ).


--=20
Thanks
Nitesh

