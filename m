Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA05CC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:31:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9791721726
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:31:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9791721726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B4848E0005; Thu,  1 Aug 2019 03:31:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2650D8E0001; Thu,  1 Aug 2019 03:31:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1075B8E0005; Thu,  1 Aug 2019 03:31:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E634E8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 03:31:15 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id k31so63986148qte.13
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 00:31:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=XpiQ6TwTXce795bbnPzHI7n4KNP3Iu7eAjihinDuR3I=;
        b=HA99oAIL+1PN6/wMi1NJY2Fwt1QKoad0wEazsqwk8mMJWaD3Mt6Z18yb1nOnPOd1hF
         6YQLwaHEBk9P3E5xxA35eOAHcI2mBu3DCdHoOYsOGDFzke9bvcKqx9gVA+EC/KuFro9C
         EnU7IwZz6LHZ4+R8V7zKOrWFifwkxxWabTpo41ejV42v10p5B1+4sG8w4+jVH2k0cF+L
         gXBoMMHEVNuUf+v9lJRTEXks4KncJHuNG8lnJ+ZX65TZvRMSB8Mfve9XZo6bqYhEhVSb
         J7LxyOsJ6JRmO/dUcqtJTYTwx93i63L1AL0C3NXrrywW23XTx6OshWA7MgpV5Va1e8ad
         oWiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV69CTcGU81bVov42yaK0n7mUgUVn2SBt59L7oVnYuoVpfChkeW
	FOkRmCLA41I7de2KLVLBHHUd/OLdhEI06nD5BPcP+RT7kvwwDaAiVrC+nvl6bSMc//yUctr8wdK
	W5tlnLomBl/BPjNbwAcX1Choq3x3BbDFOVu9pz93c2NY2XZPNZ5i0YTrLT7w7X3rY0A==
X-Received: by 2002:ae9:ee0b:: with SMTP id i11mr79664059qkg.424.1564644675712;
        Thu, 01 Aug 2019 00:31:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyi/LvModF1ZB28Vc5YHj2LA+Bqqi/W9B1lfUgUdo6vX2ro86EDPSK1F9g0CsXx1gLVEFT
X-Received: by 2002:ae9:ee0b:: with SMTP id i11mr79664020qkg.424.1564644675181;
        Thu, 01 Aug 2019 00:31:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564644675; cv=none;
        d=google.com; s=arc-20160816;
        b=PSVJiubI6YNT8xdElj5E31W1TQId8AsDgi0MyK9t5YTR1GgSwHYntoCIti3dqpdOtA
         Es8Hl48eHpgJCu54OQdKbEAzzS22UcHDzzEI4J6FHj+Yu8XQF/ChnJ/g3kAHNaFTXcui
         yOQ7LE0PhF5w0xf0fyweqB0xPBuiTNYlXAo1dFVHKavjwflIaUcaEyHGSuzi2/+Q4PJ9
         SYWrNjdEyiRia8/N76uku7eLUtYaVqjMxRpJ06bTTqPwIviMo0/jEL7OdVdpOq+91yGo
         5SYxJLh0wthjBtTN5bPf7HlhXCJ527SJ13NtniyhpRN7kDp2s9RniLOnMDXEOO9McmDh
         goUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp
         :references:cc:to:from:subject;
        bh=XpiQ6TwTXce795bbnPzHI7n4KNP3Iu7eAjihinDuR3I=;
        b=h25xELiFw/rNUlc5ZHoUCjorcvAp4XeJCbY8FJ+lFpZLkxuhDSEJGlpA8j10AHw73R
         arD42SEOq1LJ4sMXGWSS+JhUp5RC1lYIcOXptuKJ5/6O3b34bYsNOZQNIzIy1B5E5NOO
         0PON5mirwbIadWno+3IGNEPK/RS9XWij653SXAJSuhV885cCUworAo/U2mW18MLNwajF
         BKubX78sJcRB9aL31VcEu++w0oifCwtyh8GTR3eWU6WVjbqXJbx/GVAJxGXGY559rjCc
         RppmgZ+THfEUhuUL7oIzz8HJwk0Bq0F8ssPIOYNOjO2YxIEb8tBklzNmqQBAojUYbFSf
         BjQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t64si39774646qkb.359.2019.08.01.00.31.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 00:31:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 47F593B71F;
	Thu,  1 Aug 2019 07:31:13 +0000 (UTC)
Received: from [10.36.116.245] (ovpn-116-245.ams2.redhat.com [10.36.116.245])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5C4B25D6A7;
	Thu,  1 Aug 2019 07:31:10 +0000 (UTC)
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
From: David Hildenbrand <david@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Rashmica Gupta <rashmica.g@gmail.com>, Oscar Salvador
 <osalvador@suse.de>, Andrew Morton <akpm@linux-foundation.org>,
 Dan Williams <dan.j.williams@intel.com>, pasha.tatashin@soleen.com,
 Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
 Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
 <20190626081516.GC30863@linux>
 <887b902e-063d-a857-d472-f6f69d954378@redhat.com>
 <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com>
 <20190702074806.GA26836@linux>
 <CAC6rBskRyh5Tj9L-6T4dTgA18H0Y8GsMdC-X5_0Jh1SVfLLYtg@mail.gmail.com>
 <20190731120859.GJ9330@dhcp22.suse.cz>
 <4ddee0dd719abd50350f997b8089fa26f6004c0c.camel@gmail.com>
 <20190801071709.GE11627@dhcp22.suse.cz>
 <9bcbd574-7e23-5cfe-f633-646a085f935a@redhat.com>
 <20190801072430.GF11627@dhcp22.suse.cz>
 <e654aa97-6ab1-4069-60e6-fc099539729e@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <5e6137c9-5269-5756-beaa-d116652be8b9@redhat.com>
Date: Thu, 1 Aug 2019 09:31:09 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <e654aa97-6ab1-4069-60e6-fc099539729e@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 01 Aug 2019 07:31:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01.08.19 09:26, David Hildenbrand wrote:
> On 01.08.19 09:24, Michal Hocko wrote:
>> On Thu 01-08-19 09:18:47, David Hildenbrand wrote:
>>> On 01.08.19 09:17, Michal Hocko wrote:
>>>> On Thu 01-08-19 09:06:40, Rashmica Gupta wrote:
>>>>> On Wed, 2019-07-31 at 14:08 +0200, Michal Hocko wrote:
>>>>>> On Tue 02-07-19 18:52:01, Rashmica Gupta wrote:
>>>>>> [...]
>>>>>>>> 2) Why it was designed, what is the goal of the interface?
>>>>>>>> 3) When it is supposed to be used?
>>>>>>>>
>>>>>>>>
>>>>>>> There is a hardware debugging facility (htm) on some power chips.
>>>>>>> To use
>>>>>>> this you need a contiguous portion of memory for the output to be
>>>>>>> dumped
>>>>>>> to - and we obviously don't want this memory to be simultaneously
>>>>>>> used by
>>>>>>> the kernel.
>>>>>>
>>>>>> How much memory are we talking about here? Just curious.
>>>>>
>>>>> From what I've seen a couple of GB per node, so maybe 2-10GB total.
>>>>
>>>> OK, that is really a lot to keep around unused just in case the
>>>> debugging is going to be used.
>>>>
>>>> I am still not sure the current approach of (ab)using memory hotplug is
>>>> ideal. Sure there is some overlap but you shouldn't really need to
>>>> offline the required memory range at all. All you need is to isolate the
>>>> memory from any existing user and the page allocator. Have you checked
>>>> alloc_contig_range?
>>>>
>>>
>>> Rashmica mentioned somewhere in this thread that the virtual mapping
>>> must not be in place, otherwise the HW might prefetch some of this
>>> memory, leading to errors with memtrace (which checks that in HW).
>>
>> Does anything prevent from unmapping the pfn range from the direct
>> mapping?
> 
> I am not sure about the implications of having
> pfn_valid()/pfn_present()/pfn_online() return true but accessing it
> results in crashes. (suspend, kdump, whatever other technology touches
> online memory)

(oneidea: we could of course go ahead and mark the pages PG_offline
before unmapping the pfn range to work around these issues)

> 
> (sounds more like a hack to me than just going ahead and
> removing/readding the memory via a clean interface we have)
> 


-- 

Thanks,

David / dhildenb

