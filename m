Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD353C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 18:14:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EF1C2087C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 18:14:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EF1C2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=citrix.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D556B8E0003; Tue, 12 Mar 2019 14:14:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D05408E0002; Tue, 12 Mar 2019 14:14:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCDB18E0003; Tue, 12 Mar 2019 14:14:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE0F68E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 14:14:09 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a1so1462841edx.4
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:14:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=jcH8r1UPvtN5pBGCt43Ie/+3l+YDA8LvhavfOaiHAIU=;
        b=TXuBx86ctZ2tqQsOZKfYpRgRbO6Bam5BBfHw/qUAh4u+bTlAWZmTD5xzMygE1L6DaQ
         GmSk3Hp5R0wgOw2uMkQ1bsFsRfMuKILU9mshvz0MJ8AeCO9d7BjVgL/niY2OUncjxWyZ
         de1it9x9UC+7F/cNP7P7xH21ajc1lzfCVBReeRBmNtqaYFzMQWp/HgRehaYCQNOTrVhA
         MNz9h1viOngJDZXbDV2f5m2Md3uHL7HwJZeMA0mdOFSQTHDIP7O3TDxLTxQa1sNLn3Pr
         PlgQqoaTch3bhAL9HvS8pXgd0VeMm2uq4s5z/bajbYiaWFdpHmv7lksFbT6HwRdz7m/W
         tW6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of prvs=9679d707e=andrew.cooper3@citrix.com designates 185.25.65.24 as permitted sender) smtp.mailfrom="prvs=9679d707e=Andrew.Cooper3@citrix.com"
X-Gm-Message-State: APjAAAUrGQCzP1joYCHMwWD3ztfzCvqmJSSybgoJyDipVysIPeIQ2Y5M
	JxwvO1MtKXzS25aEzIG7Lk+63x95Ao46u12b7635FOpk40xY4Ud6g25MA4dI158HU4mI1ho0B2s
	B4awiHCm3apJdYHqO9X1Hj6FcbtEgf3C6OvL2WXxLVd/uzuTDn1TsdyVBafr0ejduIw==
X-Received: by 2002:a17:906:6b15:: with SMTP id q21mr6697516ejr.193.1552414449398;
        Tue, 12 Mar 2019 11:14:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBOxLdOm9a4TFVkMyn2jzYziUppkhAuLEvx4w2Kxx4JfMWl5QaoUnGcse9a4uSG+6vHn63
X-Received: by 2002:a17:906:6b15:: with SMTP id q21mr6697475ejr.193.1552414448351;
        Tue, 12 Mar 2019 11:14:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552414448; cv=none;
        d=google.com; s=arc-20160816;
        b=C1pwkKPf/6rVln4Jnz9h0UZ+nwdjSo48wJCCVGruQZwcDiYHMAXnWHXvrez9dIO5+n
         sEMmx54W6j/PlMMULQ2JPmQ3XB2BEpA++PuDgk1MzjYno4ZQOFfFPVPQ3VW/QDfyL7QU
         zyuPlu/hjTb+y4xmwphQ/yeWCL3wLG4A1jtHU/9CVI94C01ZwHiVFggiH1JgYV4ip+fW
         duI55pxph0GMWUpVmfM5tMS/aVWXgiVIoPzTanin1h40D/+lHdFnaI/RLtJ/Deo4XUBU
         RGKuu4OmoK8OaJaImvaNeqgt5N/1VpO2rrd6o+b1b+WNZgRX47LxpXNSxfdva57L5EGe
         8SoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=jcH8r1UPvtN5pBGCt43Ie/+3l+YDA8LvhavfOaiHAIU=;
        b=cMQf/5sEmj3A0lvG2DreQ/95QuY5mt8lqonubYUaEdIVV5ZWDcVvoeQ3uEiknS+wNB
         b4vlUr+7Hs+oA7w+EFy1w9aJIjRn81B62GtHrGP0ZMUjGv4m8BGWA+vzXpi5dJeXzgIm
         ylpa+w54A8TCuOB34UW3xVS4AubDIYf8db60f6RV3VeKWVD9Z2nRbIhbDU9lzWN0sh1v
         EZ+VfsYllZpTwQNrBUXz+9+5VIPaFQGaD54Kczt1xRl9qX627isSvnKoaeR3SlOO2NQR
         hOgtdK+aP1QYFZOWZo3tCYik1/JDsJ15OtQ0CFNeOhjySas839tcUUx5mmQPxei9mm8j
         Y6lw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of prvs=9679d707e=andrew.cooper3@citrix.com designates 185.25.65.24 as permitted sender) smtp.mailfrom="prvs=9679d707e=Andrew.Cooper3@citrix.com"
Received: from SMTP.EU.CITRIX.COM (smtp.eu.citrix.com. [185.25.65.24])
        by mx.google.com with ESMTPS id q15si2685542ejs.5.2019.03.12.11.14.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 11:14:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=9679d707e=andrew.cooper3@citrix.com designates 185.25.65.24 as permitted sender) client-ip=185.25.65.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of prvs=9679d707e=andrew.cooper3@citrix.com designates 185.25.65.24 as permitted sender) smtp.mailfrom="prvs=9679d707e=Andrew.Cooper3@citrix.com"
X-IronPort-AV: E=Sophos;i="5.58,471,1544486400"; 
   d="scan'208";a="87173174"
Subject: Re: [Xen-devel] xen: Can't insert balloon page into VM userspace (WAS
 Re: [linux-linus bisection] complete test-arm64-arm64-xl-xsm)
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Hildenbrand
	<david@redhat.com>, Matthew Wilcox <willy@infradead.org>, Julien Grall
	<julien.grall@arm.com>
CC: Juergen Gross <jgross@suse.com>, <k.khlebnikov@samsung.com>, Stefano
 Stabellini <sstabellini@kernel.org>, Kees Cook <keescook@chromium.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "VMware, Inc."
	<pv-drivers@vmware.com>, osstest service owner
	<osstest-admin@xenproject.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>, Julien Freche
	<jfreche@vmware.com>, Nadav Amit <namit@vmware.com>,
	<xen-devel@lists.xenproject.org>
References: <E1h3Uiq-0002L6-Ij@osstest.test-lab.xenproject.org>
 <80211e70-5f54-9421-8e8f-2a4fc758ce39@arm.com>
 <46118631-61d4-adb6-6ffc-4e7c62ea3da9@arm.com>
 <20190312171421.GJ19508@bombadil.infradead.org>
 <e0b64793-260d-5e70-0544-e7290509b605@redhat.com>
 <45323ea0-2a50-8891-830e-e1f8a8ed23ea@citrix.com>
 <f4b40d91-9c41-60ed-6b4e-df47af8e5292@oracle.com>
From: Andrew Cooper <andrew.cooper3@citrix.com>
Openpgp: preference=signencrypt
Autocrypt: addr=andrew.cooper3@citrix.com; prefer-encrypt=mutual; keydata=
 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
 6+ahAA==
Message-ID: <6e5309b3-2910-b556-da8d-05b529de1d18@citrix.com>
Date: Tue, 12 Mar 2019 18:11:14 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <f4b40d91-9c41-60ed-6b4e-df47af8e5292@oracle.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-ClientProxiedBy: AMSPEX02CAS02.citrite.net (10.69.22.113) To
 AMSPEX02CL02.citrite.net (10.69.22.126)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 12/03/2019 18:02, Boris Ostrovsky wrote:
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
> Yes. And its name is alloc_xenballooned_pages().

FWIW, I did express my views that this was a BadIdea(tm) when that logic
was first introduced.

But yes - now is clearly the time to fix this properly.

~Andrew

