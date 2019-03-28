Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32FD2C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 13:38:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9232206BA
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 13:38:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9232206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C6456B0003; Thu, 28 Mar 2019 09:38:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 150246B0006; Thu, 28 Mar 2019 09:38:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0E126B0007; Thu, 28 Mar 2019 09:38:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C25F36B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 09:38:21 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id k21so17551718qkg.19
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 06:38:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=68Ae/hcg/gOg8S/kCLG6XoFyW3LgvupzpHdVnH9j5tQ=;
        b=VCsNrsUc46iauGwHP9bXb/LMvTI8ec7FxaF8hTLG0MppEZU5bxucYZx+pfHeZcbbMz
         F5RIFw6rPngLiTT5+jyGWE0/jzrqHq/Q+j46m5Jmr7CXRqUtJrq9tlOQe3WBkGnjqbPa
         eAfQkUdA3PcmjHFczazDwqlG03WzujPonV7vlrGqjPxgwQBalP0mNo7MKkWE17sWyb/u
         2WqGZ/X5TOyHsPGFwBal8uOyiKGWbH4o5Gkk7mXGyuxJmh3mi15PI26c7UlG+21Nr/yO
         ciu/ybpBNA1RvXvh0QuhKSvyvyhyU4NjuZxAgVRPzmE8s/cE8WIdATEBzOWGOPuzH6cW
         QO0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVRuf7x5OfQmaPy6xhJJpacNxHJTbQmctJ3p3F+L7e4IjyQ5XDG
	eP50saiW0UK/SP93AA/bCLggS6Eo8QHZohCa1Oc0f3ldmAF3elE4fKT49UxddS6hVq/zZLI0hDE
	N2SqUydKfuFYeZOmcPrrxAgoW+lCCfok6XWw23ilCKq/7Kx4DvaSUgPLlnwSFCsKkgw==
X-Received: by 2002:a0c:d498:: with SMTP id u24mr36171446qvh.117.1553780301467;
        Thu, 28 Mar 2019 06:38:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwqPPlbu/TCpWcQ0cURW2+eKhzx+ZzPQFp1CTyy4wdY1eQ0BF6wk0ctfroKBw/CiDsGxIXr
X-Received: by 2002:a0c:d498:: with SMTP id u24mr36171382qvh.117.1553780300536;
        Thu, 28 Mar 2019 06:38:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553780300; cv=none;
        d=google.com; s=arc-20160816;
        b=WOUbakEBnTic7v/olQcjheoUGNJF+HrOk9iId9PV58DkeZ+0rfS6Xfmwe63FPxqh/6
         fwLqfit7hl1KLjhxNEJgRtPqZ/eZ1+MTXyEya0vdygkkUdAP4DZ1J33LAYKeaylA+UmM
         JqFMvPWoEBvqf1cB0Qj785lcqK+k9l9B/zQnQYtDydWCGjaI62ufLBw3VjvND2cfbCVI
         icXleu7kfIHVXWGzuNFMgZtzWfNmijTod+bQKIuKOk/YRBAM90JbGcePF8VAdXXzE+jA
         iE9fvq9FXGCXX79MgsYW4DXR3ANVQbyIXUO+IrKX5HmvXBfnDH1zQDpRIjrqmvdLW+C7
         5RAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=68Ae/hcg/gOg8S/kCLG6XoFyW3LgvupzpHdVnH9j5tQ=;
        b=pX0QKdcxch7CZ2hPSK6JzW5ucTpkLRziquEvMuMnp8W9Wbg0FPZQtzqB/XQhiLgb8p
         gjBLoSgxlOj4ImIeogZk+BnvtglCY1evL0CXsi93pRrbXs51tBfwWR/GOw8vm4rOVUHr
         5qb608l0DC85b2J/t7rYCKT5KBW6U/ZDQRZqH2a4RkEUqnXjuVQ10KTEflbs2VDx7ySV
         49naPEtd1LFwrElup/an6PGUbvcfH6TjKnqr1ZztqOcDxp9Yw3QMyNzly6WgSrrHWHED
         n0x1+FQKKT3pDoTjnWLvdmwmAqXo/ZkRwoseCi8UrGHWhSpCP3wnT+GjO6UyETRzEtk2
         A0mA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z11si362271qka.196.2019.03.28.06.38.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 06:38:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 76F5C308794D;
	Thu, 28 Mar 2019 13:38:19 +0000 (UTC)
Received: from [10.36.117.191] (ovpn-117-191.ams2.redhat.com [10.36.117.191])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EB29E437F;
	Thu, 28 Mar 2019 13:38:15 +0000 (UTC)
Subject: Re: [PATCH v5 00/10] mm: Sub-section memory hotplug support
To: Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>,
 Jeff Moyer <jmoyer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>,
 stable <stable@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
 linux-nvdimm <linux-nvdimm@lists.01.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190322180532.GM32418@dhcp22.suse.cz>
 <CAPcyv4gBGNP95APYaBcsocEa50tQj9b5h__83vgngjq3ouGX_Q@mail.gmail.com>
 <20190325101945.GD9924@dhcp22.suse.cz>
 <CAPcyv4iJCgu-akJM_O8ZtscqWQt=CU-fvx-ViGYeau-NJufmSQ@mail.gmail.com>
 <20190326080408.GC28406@dhcp22.suse.cz>
 <CAPcyv4jUeUPwbfToWQtWX1AxfgFLNpBUhm8BvgJ2Hv1RbNPiog@mail.gmail.com>
 <20190327161306.GM11927@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <9e769f3d-00f2-a8bb-2d8d-097735cb2a6d@redhat.com>
Date: Thu, 28 Mar 2019 14:38:15 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190327161306.GM11927@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Thu, 28 Mar 2019 13:38:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 27.03.19 17:13, Michal Hocko wrote:
> On Tue 26-03-19 17:20:41, Dan Williams wrote:
>> On Tue, Mar 26, 2019 at 1:04 AM Michal Hocko <mhocko@kernel.org> wrote:
>>>
>>> On Mon 25-03-19 13:03:47, Dan Williams wrote:
>>>> On Mon, Mar 25, 2019 at 3:20 AM Michal Hocko <mhocko@kernel.org> wrote:
>>> [...]
>>>>>> User-defined memory namespaces have this problem, but 2MB is the
>>>>>> default alignment and is sufficient for most uses.
>>>>>
>>>>> What does prevent users to go and use a larger alignment?
>>>>
>>>> Given that we are living with 64MB granularity on mainstream platforms
>>>> for the foreseeable future, the reason users can't rely on a larger
>>>> alignment to address the issue is that the physical alignment may
>>>> change from one boot to the next.
>>>
>>> I would love to learn more about this inter boot volatility. Could you
>>> expand on that some more? I though that the HW configuration presented
>>> to the OS would be more or less stable unless the underlying HW changes.
>>
>> Even if the configuration is static there can be hardware failures
>> that prevent a DIMM, or a PCI device to be included in the memory map.
>> When that happens the BIOS needs to re-layout the map and the result
>> is not guaranteed to maintain the previous alignment.
>>
>>>> No, you can't just wish hardware / platform firmware won't do this,
>>>> because there are not enough platform resources to give every hardware
>>>> device a guaranteed alignment.
>>>
>>> Guarantee is one part and I can see how nobody wants to give you
>>> something as strong but how often does that happen in the real life?
>>
>> I expect a "rare" event to happen everyday in a data-center fleet.
>> Failure rates tend towards 100% daily occurrence at scale and in this
>> case the kernel has everything it needs to mitigate such an event.
>>
>> Setting aside the success rate of a software-alignment mitigation, the
>> reason I am charging this hill again after a 2 year hiatus is the
>> realization that this problem is wider spread than the original
>> failing scenario. Back in 2017 the problem seemed limited to custom
>> memmap= configurations, and collisions between PMEM and System RAM.
>> Now it is clear that the collisions can happen between PMEM regions
>> and namespaces as well, and the problem spans platforms from multiple
>> vendors. Here is the most recent collision problem:
>> https://github.com/pmem/ndctl/issues/76, from a third-party platform.
>>
>> The fix for that issue uncovered a bug in the padding implementation,
>> and a fix for that bug would result in even more hacks in the nvdimm
>> code for what is a core kernel deficiency. Code review of those
>> changes resulted in changing direction to go after the core
>> deficiency.
> 
> This kind of information along with real world examples is exactly what
> you should have added into the cover letter. A previous very vague
> claims were not really convincing or something that can be considered a
> proper justification. Please do realize that people who are not working
> with the affected HW are unlikely to have an idea how serious/relevant
> those problems really are.
> 
> People are asking for a smaller memory hotplug granularity for other
> usecases (e.g. memory ballooning into VMs) which are quite dubious to
> be honest and not really worth all the code rework. If we are talking
> about something that can be worked around elsewhere then it is preferred
> because the code base is not in an excellent shape and putting more on
> top is just going to cause more headaches.

At least for virtio-mem, it will be handled similar to xen-balloon and
hyper-v balloon, where whole actions are added and some parts are kept
"soft-offline". But there, one device "owns" the complete section, it
does not overlap with other devices. One section only has one owner.

As we discussed a similar approach back then with virtio-mem
(online/offline of smaller blocks), you had a pretty good point that
such complexity is better avoided in core MM. Sections really seem to be
the granularity with which core MM should work. At least speaking about
!pmem memory hotplug.

> 
> I will try to find some time to review this more deeply (no promises
> though because time is hectic and this is not a simple feature). For the
> future, please try harder to write up a proper justification and a
> highlevel design description which tells a bit about all important parts
> of the new scheme.
> 


-- 

Thanks,

David / dhildenb

