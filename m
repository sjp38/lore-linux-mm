Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E334C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 18:23:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E00D32087C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 18:23:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E00D32087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F6298E0003; Tue, 12 Mar 2019 14:23:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A5358E0002; Tue, 12 Mar 2019 14:23:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66DF88E0003; Tue, 12 Mar 2019 14:23:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B86E8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 14:23:57 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s8so3067802qth.18
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:23:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=lrzRuOwX8mL9GtniwEJab8F6fOP/UJfwqTuK7x3cgVE=;
        b=AG0e967kAUuNELslz1R9HJFTmHStds9x6XK/DPksKSpibnQBP3C+s7/GgCSdE3kqXg
         a2D9ZQ9YN5MhEMYfO/VFdMvgPFGfRvtIWP62dQXi8a39z4jUi+qWuj87G9nMq2smupOk
         yLLzXz6G0rTP+QIPINmyix9i2RF+NxpfyKKfv/CwyATRNPLUgKchZuXuikFhjdiAUCXY
         Kbd61WgPdjEyQm/aQ0F6zQ08wCEH9q9hTgEyEWZqyFBpjKtkJbiLtN4h3ALdy7VyXDq2
         Fak4i1WSzkXtDHRwLfC42UD99Cliy6psL3Dr1gj7cI623SjZz/oUnALKfJtxPIo6coHR
         fMGQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWDDXu7MOZra/RYXa9U5x2xXLHCiffSaJ2cf96iNdzuObKMwZZc
	KswuQ3LIaBjb/kjMNOLYbmi1ExkugQOld92BGRppM7FWEdVQxhWrpeE6kbte7NWXD3zcFNCLElR
	iIPvkZC/cH82EgWs0tz9suSOQ3mzXyiJMIKHaKFeWvYm8ejXLye1ULEIx755NkKyRWQ==
X-Received: by 2002:ac8:2d56:: with SMTP id o22mr3097266qta.321.1552415037007;
        Tue, 12 Mar 2019 11:23:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdZoGpUFg2VL6ZNgQqfulrrBCJMHfpk1k4OoBU/bwnGm0jBKuzQSNKXqDrXetVRq6mrgQG
X-Received: by 2002:ac8:2d56:: with SMTP id o22mr3097201qta.321.1552415036178;
        Tue, 12 Mar 2019 11:23:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552415036; cv=none;
        d=google.com; s=arc-20160816;
        b=i8fkuyrK9oWXHruAhCJ5us65UM0BfEaB7uYFETTkTPf+ad3DcaL9S0VQIHD0qhlS60
         FvMMeUGQqWa4VAJoMUrdQSrs0rUQ0ujLBu4g2Q413lu09C4v1lD145+AzIbqIWFWnmZ4
         lFG7uEqJg/CvazZAgPwfJJ3iEU1cUVTamOYmRHfpybzw+TtFwcI4Tah52oVP7Ow73/N4
         82+VKaKRlVRldDRxPQxTyU2ngJyN+QliOblc6/mj2a2DRajvd4Xn3IKXYLc6lFVB1/PO
         oF0BcZErGVEdR+AyM0LTmakd62h1uR6Fa2c1UD5E6g+Z/blMShoNNAbxScs0lz17p/0N
         7ZIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=lrzRuOwX8mL9GtniwEJab8F6fOP/UJfwqTuK7x3cgVE=;
        b=HFoF5Fr8ZpKimh4sLXfAoxfasmUxfrJqZ9TlWtq6f6rEpFVpvOUtcSQoW5tYLSf4QB
         PLX5qysFRRDU3tdchzT/O6VoUmmyGsU03beYBQkxFg+s+WVtp6ZJM/KhrGBNngr+Iq3r
         +twJg6uF8ygG0Sos587yaNGR/mTc5w2bqkD/RYc34d4Sb3fNfgHwAJwb5HcKK6k8IZK4
         vWLyHiRw98ytqHrzZs6tKQpXLKJEhmzAtnhP2/FcvTDWnJItF0BLS+q2r8njbR3mriXA
         YS/dulQ7Gd3p60aF5UVZnDVthjMX+ZlAnZR0xGIpibh9tdN+1AOeypxK0WuGJDXDocec
         Ju/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l25si5644269qve.97.2019.03.12.11.23.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 11:23:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E66D5356E4;
	Tue, 12 Mar 2019 18:23:54 +0000 (UTC)
Received: from [10.36.117.44] (ovpn-117-44.ams2.redhat.com [10.36.117.44])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5E1101001DC3;
	Tue, 12 Mar 2019 18:23:51 +0000 (UTC)
Subject: Re: [Xen-devel] xen: Can't insert balloon page into VM userspace (WAS
 Re: [linux-linus bisection] complete test-arm64-arm64-xl-xsm)
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>,
 Andrew Cooper <andrew.cooper3@citrix.com>,
 Matthew Wilcox <willy@infradead.org>, Julien Grall <julien.grall@arm.com>
Cc: Juergen Gross <jgross@suse.com>, k.khlebnikov@samsung.com,
 Stefano Stabellini <sstabellini@kernel.org>,
 Kees Cook <keescook@chromium.org>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 "VMware, Inc." <pv-drivers@vmware.com>,
 osstest service owner <osstest-admin@xenproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 linux-mm@kvack.org, Julien Freche <jfreche@vmware.com>,
 Nadav Amit <namit@vmware.com>, xen-devel@lists.xenproject.org
References: <E1h3Uiq-0002L6-Ij@osstest.test-lab.xenproject.org>
 <80211e70-5f54-9421-8e8f-2a4fc758ce39@arm.com>
 <46118631-61d4-adb6-6ffc-4e7c62ea3da9@arm.com>
 <20190312171421.GJ19508@bombadil.infradead.org>
 <e0b64793-260d-5e70-0544-e7290509b605@redhat.com>
 <45323ea0-2a50-8891-830e-e1f8a8ed23ea@citrix.com>
 <f4b40d91-9c41-60ed-6b4e-df47af8e5292@oracle.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <9a40e1ff-7605-e822-a1d2-502a12d0fba7@redhat.com>
Date: Tue, 12 Mar 2019 19:23:50 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <f4b40d91-9c41-60ed-6b4e-df47af8e5292@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 12 Mar 2019 18:23:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 12.03.19 19:02, Boris Ostrovsky wrote:
> On 3/12/19 1:24 PM, Andrew Cooper wrote:
>> On 12/03/2019 17:18, David Hildenbrand wrote:
>>> On 12.03.19 18:14, Matthew Wilcox wrote:
>>>> On Tue, Mar 12, 2019 at 05:05:39PM +0000, Julien Grall wrote:
>>>>> On 3/12/19 3:59 PM, Julien Grall wrote:
>>>>>> It looks like all the arm test for linus [1] and next [2] tree
>>>>>> are now failing. x86 seems to be mostly ok.
>>>>>>
>>>>>> The bisector fingered the following commit:
>>>>>>
>>>>>> commit 0ee930e6cafa048c1925893d0ca89918b2814f2c
>>>>>> Author: Matthew Wilcox <willy@infradead.org>
>>>>>> Date:   Tue Mar 5 15:46:06 2019 -0800
>>>>>>
>>>>>>      mm/memory.c: prevent mapping typed pages to userspace
>>>>>>      Pages which use page_type must never be mapped to userspace as it would
>>>>>>      destroy their page type.  Add an explicit check for this instead of
>>>>>>      assuming that kernel drivers always get this right.
>>>> Oh good, it found a real problem.
>>>>
>>>>> It turns out the problem is because the balloon driver will call
>>>>> __SetPageOffline() on allocated page. Therefore the page has a type and
>>>>> vm_insert_pages will deny the insertion.
>>>>>
>>>>> My knowledge is quite limited in this area. So I am not sure how we can
>>>>> solve the problem.
>>>>>
>>>>> I would appreciate if someone could provide input of to fix the mapping.
>>>> I don't know the balloon driver, so I don't know why it was doing this,
>>>> but what it was doing was Wrong and has been since 2014 with:
>>>>
>>>> commit d6d86c0a7f8ddc5b38cf089222cb1d9540762dc2
>>>> Author: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
>>>> Date:   Thu Oct 9 15:29:27 2014 -0700
>>>>
>>>>     mm/balloon_compaction: redesign ballooned pages management
>>>>
>>>> If ballooned pages are supposed to be mapped into userspace, you can't mark
>>>> them as ballooned pages using the mapcount field.
>>>>
>>> Asking myself why anybody would want to map balloon inflated pages into
>>> user space (this just sounds plain wrong but my understanding to what
>>> XEN balloon driver does might be limited), but I assume the easy fix
>>> would be to revert
>> I suspect the bug here is that the balloon driver is (ab)used for a
>> second purpose
> 
> Yes. And its name is alloc_xenballooned_pages().
> 

Haven't had a look at the code yet, but would another temporary fix be
to clear/set PG_offline when allocating/freeing a ballooned page?
(assuming here that only such pages will be mapped to user space)

-- 

Thanks,

David / dhildenb

