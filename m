Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEC15C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 11:37:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1A2E20645
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 11:37:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1A2E20645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41F038E0003; Fri, 28 Jun 2019 07:37:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D0488E0002; Fri, 28 Jun 2019 07:37:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BE6B8E0003; Fri, 28 Jun 2019 07:37:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0AB9D8E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 07:37:18 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c207so6081584qkb.11
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 04:37:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=d7uQFoih6avPf22aLAk/kXLh+VrxPbBOHBQ7tX/ydtQ=;
        b=YpkY5iRGr6WQ14W6UAfND7PJxPcTrBCDAiRWUNFs+gi44JrtMdpBC0WwvHrzYGiudl
         z0Wljei790h2G8phyBB3+YVma6LFeIV1votptG9XMFv5O/Xhc0wLZz1SBpyxdY6LOWC6
         TZkCCX8ZjmNiHAS9ix/yKnkQp8Z8RdJl5nDfSSaDZO/IzyU1p4TMREzXu/gfbFV+a8Yu
         Ctfd5Fd5lH7yT86MWpJhPc46WdQ69+6C6pmzRM01is7+rRNwpeGLH/bjfMCHYWNqTa0p
         YV84xsmtn+GyHMt52tjc9+rTnxav7LyD3mKD6cV2AEbZlDwECFVlMD5PWJG8Lhh8mz5h
         Pl+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWEGl8fYD6Hci/IoCf2sDBeDeon6n6c7SHuNr5XRmj/auLKJKqE
	pWV1Lm4ZGwFQnFqhpwckQHYBIPmL0aCS/GvE/S4f3kqgtmyxt2KEXabYnxJGIoewcZaTbdqYOgW
	KVegb+7oO5Ati45kWM0oXPyOOlHq8E1yFgS2bXisiItz06GALRZwV71uXqmVpvNAT4Q==
X-Received: by 2002:a37:4ac3:: with SMTP id x186mr7856410qka.138.1561721837833;
        Fri, 28 Jun 2019 04:37:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjb/T8f3TTlE9pATHem1l1bFUd2c+I1FD7NHfJR/PyVasA916mTi5q8eiQta9gCJBy6XRg
X-Received: by 2002:a37:4ac3:: with SMTP id x186mr7856377qka.138.1561721837309;
        Fri, 28 Jun 2019 04:37:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561721837; cv=none;
        d=google.com; s=arc-20160816;
        b=KqHQ+wnZ/mape3lVv7vNWHOCnLjD1QOnXIO7h7rsHZpSllhtfVNnaw35BapBAB8oB+
         I5KsR6ci3AXofjR4e3YFvQYvvUhiWZqvyUWiZAsj2jBGzz+Qx6iw5RVzuf4ZYjF3gTsT
         GauEsyM1fnlgoRbSgkX1wjIawP3L3w6WXgjGIktfrmxuqY/reU8EGKSMTAF7k8zMACej
         D/38CpxDt7e4F0+7T+NRtGX9yc0gw5CrxPZgnR5z6igUPpUXN4jqBrU7SxH61Y8V26cy
         gVRMzNDaZ4aH4nT9PQuwWSpuQr9a1N1Njvvg3t28nTgSbv+/lUdEEyljjYcPfM1Eci9l
         Wybg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=d7uQFoih6avPf22aLAk/kXLh+VrxPbBOHBQ7tX/ydtQ=;
        b=vmY83gqEUp7VIwMYmdjNzM0ikFal2dHRu+bqWmJAnTV0bsLViIGnjOfX1Sm8ws2/V5
         XWrasK2LVk6DhxmpM9znbMhBK5yGv1UqoBWP5rtNxuyulyRUIqk9LkO3SyuooBf0Jrvk
         7jRnnFQ2SvTsUhiZfmYOSHCV1odAr/Y+TjCoCLW69C4zt+o7ITGvvegUFEhTLj7dF2xL
         Vq8mN/lm8MAZVmbA2SkX+Rm822e15cc7BN18jGJVH0rGLcbF9GbWHu9FyS1QVSHGC1f1
         LcmRkzlCWMMMVFOi9EOLsR20fSat+L5Y7RGiXhk/fyCNZnlkRIJZOhsM2xe+YbZMSQ5T
         Dk7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b52si1550570qtk.327.2019.06.28.04.37.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 04:37:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4C1C687620;
	Fri, 28 Jun 2019 11:37:11 +0000 (UTC)
Received: from [10.36.116.156] (ovpn-116-156.ams2.redhat.com [10.36.116.156])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B82C7608CA;
	Fri, 28 Jun 2019 11:37:08 +0000 (UTC)
Subject: Re: [PATCH v2 1/3] mm: Trigger bug on if a section is not found in
 __section_nr
To: Michal Hocko <mhocko@kernel.org>, Alastair D'Silva <alastair@d-silva.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pavel Tatashin <pasha.tatashin@oracle.com>,
 Oscar Salvador <osalvador@suse.de>, Mike Rapoport <rppt@linux.ibm.com>,
 Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>,
 Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <20190626061124.16013-1-alastair@au1.ibm.com>
 <20190626061124.16013-2-alastair@au1.ibm.com>
 <20190626062113.GF17798@dhcp22.suse.cz>
 <d4af66721ea53ce7df2d45a567d17a30575672b2.camel@d-silva.org>
 <20190626065751.GK17798@dhcp22.suse.cz>
 <e66e43b1fdfbff94ab23a23c48aa6cbe210a3131.camel@d-silva.org>
 <20190627080724.GK17798@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <634a6b8e-3113-f0af-f8d3-9b766f8cd376@redhat.com>
Date: Fri, 28 Jun 2019 13:37:07 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190627080724.GK17798@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 28 Jun 2019 11:37:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 27.06.19 10:10, Michal Hocko wrote:
> On Thu 27-06-19 10:50:57, Alastair D'Silva wrote:
>> On Wed, 2019-06-26 at 08:57 +0200, Michal Hocko wrote:
>>> On Wed 26-06-19 16:27:30, Alastair D'Silva wrote:
>>>> On Wed, 2019-06-26 at 08:21 +0200, Michal Hocko wrote:
>>>>> On Wed 26-06-19 16:11:21, Alastair D'Silva wrote:
>>>>>> From: Alastair D'Silva <alastair@d-silva.org>
>>>>>>
>>>>>> If a memory section comes in where the physical address is
>>>>>> greater
>>>>>> than
>>>>>> that which is managed by the kernel, this function would not
>>>>>> trigger the
>>>>>> bug and instead return a bogus section number.
>>>>>>
>>>>>> This patch tracks whether the section was actually found, and
>>>>>> triggers the
>>>>>> bug if not.
>>>>>
>>>>> Why do we want/need that? In other words the changelog should
>>>>> contina
>>>>> WHY and WHAT. This one contains only the later one.
>>>>>  
>>>>
>>>> Thanks, I'll update the comment.
>>>>
>>>> During driver development, I tried adding peristent memory at a
>>>> memory
>>>> address that exceeded the maximum permissable address for the
>>>> platform.
>>>>
>>>> This caused __section_nr to silently return bogus section numbers,
>>>> rather than complaining.
>>>
>>> OK, I see, but is an additional code worth it for the non-development
>>> case? I mean why should we be testing for something that shouldn't
>>> happen normally? Is it too easy to get things wrong or what is the
>>> underlying reason to change it now?
>>>
>>
>> It took me a while to identify what the problem was - having the BUG_ON
>> would have saved me a few hours.
>>
>> I'm happy to just have the BUG_ON 'nd drop the new error return (I
>> added that in response to Mike Rapoport's comment that the original
>> patch would still return a bogus section number).
> 
> Well, BUG_ON is about the worst way to handle an incorrect input. You
> really do not want to put a production environment down just because
> there is a bug in a driver, right? There are still many {VM_}BUG_ONs
> in the tree and there is a general trend to get rid of many of them
> rather than adding new ones.

VM_BUG_ON is only really active with CONFIG_DEBUG_VM. On
!CONFIG_DEBUG_VM it translated to BUILD_BUG_ON_INVALID(), which is a
compile-time only check.

Or am I missing something?

-- 

Thanks,

David / dhildenb

