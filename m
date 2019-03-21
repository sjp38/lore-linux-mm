Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6C99C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 23:25:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D21C21902
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 23:25:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D21C21902
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9220E6B0003; Thu, 21 Mar 2019 19:25:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D0BC6B0006; Thu, 21 Mar 2019 19:25:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E5BB6B0007; Thu, 21 Mar 2019 19:25:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7686B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 19:25:32 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id v3so355769pgk.9
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 16:25:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=DC1C3MF319z3zNQMotYrUbRtBdypZGE9iml4I4ItdfI=;
        b=QochKgo0qRaXMDDGB3GZqqelzWK/GjZBvrhopgXrjgKqvz9VJzoArOO3ZaikE1OPw+
         RtcNuCH3zuRuH+6/HF4KcFEG2oSM5ydGijMP9lgNs9yLnpMMWvJZ3Y1jFBqhKfp+g94z
         t7nLmJK6W6GNBad1LIuHgkBfMdaGP//o7AAZl9+GX/iTl2ezYdheL2YP0m+J/YOrWPir
         VFmBMCeI6HjSFaJ1g11lyHd5NTeIM/UlE+9n6JjfTLTRCu3hlvg2nE25alJ4r9X0FDlD
         FbKQI8tcKlFqmh2J0/SuIsXXFNdBLgoJMTpW9Ex4ATNcZAxCZE+VQyJfv+j7Ra1p86Yj
         JXhA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAV1ucLRnXZzD8zfVHd8nUhHvR1KhPXkHqdR7jrK+L8BfAqC9/TS
	dj5PhS/lOOs6Ymhdwj2BljfaEkV/9mM+1NohnxJcwql4fsfCIWpiDWkVmUebA5r41R97BETLY77
	fQuVdvRmVQfp8TdOrPQoxtNufEElvrGqcBxALpCmndBjATNjd/vQyE5k+NGDSpBc81Q==
X-Received: by 2002:a63:4616:: with SMTP id t22mr5180016pga.217.1553210731792;
        Thu, 21 Mar 2019 16:25:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRyoc3h6yReI1vV+upIBghZsGGGbsBK2AFUunDP5Lg5e8CgK7dIubKlcrupzWqvEnslLms
X-Received: by 2002:a63:4616:: with SMTP id t22mr5179949pga.217.1553210730657;
        Thu, 21 Mar 2019 16:25:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553210730; cv=none;
        d=google.com; s=arc-20160816;
        b=EGevQAoyQ+aafHCGAKzl6o/N7S6drPebrF5f+TRLXbPQvTaQt/nkrM7l9NEf6PuJxG
         3mWXgGTiGnlHlooYAkn9/or3DZb6XCV1Df9GKn6nMnD2VgL0Pkquk+UKNRq71dmDdDVY
         nHumgfAQbB2aCQW+czjdnooWQpA+iNfJMAbKqjonyE/gXYMdkEv8/TQFEBkj8gjK3Yi3
         2BLp6NqUZCFfkTTblSPwbBrIK5M5KcRdpAilw8Y6RqgyTkVzsO1laooKbyp1ovpIB7pZ
         QdVg7A/kaZKZhgPOJSj6vsP4H04GWy58OW8WfI0a142veGrpX43Le0+W1TEWIeA2hx5u
         fD3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=DC1C3MF319z3zNQMotYrUbRtBdypZGE9iml4I4ItdfI=;
        b=HMuVLngwuov4d/nsnwFybOYNBjc1G/rP/Sqc4sUxJFcSv+Ik5OUjfXBItLnRYsey1S
         iyYGV1yqrknDhvc+DkJMaW+MG1krgr9s7MdI/oKI5aH41+gQfnwdQH23r5V4Ut4ZT58i
         2vv/E49VfrF4kyfk7xIoNMjOkYXuXvYHRxS+2pvx/pQrHaTTqF01TkvFlf0W5BmMfSiA
         ngGgEwJ0acpkrNUd1fgkuTKd0FbtvCdoC5dpVVwPgUw2Y3OyHN2fykOk2cY888ZbZkdG
         o3tL2cbLRzEe/jTHzwgJeJw3slju0076wSQleYDap4uOIymVSog7d2SQ/SUUwEDvCDax
         VSiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id s19si5518576plq.253.2019.03.21.16.25.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 16:25:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TNJJX9z_1553210725;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNJJX9z_1553210725)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 22 Mar 2019 07:25:27 +0800
Subject: Re: [RFC PATCH] mm: mempolicy: remove MPOL_MF_LAZY
To: Michal Hocko <mhocko@kernel.org>
Cc: mgorman@techsingularity.net, vbabka@suse.cz, akpm@linux-foundation.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1553041659-46787-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190321145745.GS8696@dhcp22.suse.cz>
 <75059b39-dbc4-3649-3e6b-7bdf282e3f53@linux.alibaba.com>
 <20190321165112.GU8696@dhcp22.suse.cz>
 <60ef6b4a-4f24-567f-af2f-50d97a2672d6@linux.alibaba.com>
 <20190321194539.GY8696@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <2cbd2f5c-4cb9-457a-6a0a-8ae99ca5eb6e@linux.alibaba.com>
Date: Thu, 21 Mar 2019 16:25:24 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190321194539.GY8696@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/21/19 12:45 PM, Michal Hocko wrote:
> On Thu 21-03-19 10:25:08, Yang Shi wrote:
>>
>> On 3/21/19 9:51 AM, Michal Hocko wrote:
>>> On Thu 21-03-19 09:21:39, Yang Shi wrote:
>>>> On 3/21/19 7:57 AM, Michal Hocko wrote:
>>>>> On Wed 20-03-19 08:27:39, Yang Shi wrote:
>>>>>> MPOL_MF_LAZY was added by commit b24f53a0bea3 ("mm: mempolicy: Add
>>>>>> MPOL_MF_LAZY"), then it was disabled by commit a720094ded8c ("mm:
>>>>>> mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now")
>>>>>> right away in 2012.  So, it is never ever exported to userspace.
>>>>>>
>>>>>> And, it looks nobody is interested in revisiting it since it was
>>>>>> disabled 7 years ago.  So, it sounds pointless to still keep it around.
>>>>> The above changelog owes us a lot of explanation about why this is
>>>>> safe and backward compatible. I am also not sure you can change
>>>>> MPOL_MF_INTERNAL because somebody still might use the flag from
>>>>> userspace and we want to guarantee it will have the exact same semantic.
>>>> Since MPOL_MF_LAZY is never exported to userspace (Mel helped to confirm
>>>> this in the other thread), so I'm supposed it should be safe and backward
>>>> compatible to userspace.
>>> You didn't get my point. The flag is exported to the userspace and
>>> nothing in the syscall entry path checks and masks it. So we really have
>>> to preserve the semantic of the flag bit for ever.
>> Thanks, I see you point. Yes, it is exported to userspace in some sense
>> since it is in uapi header. But, it is never documented and MPOL_MF_VALID
>> excludes it. mbind() does check and mask it. It would return -EINVAL if
>> MPOL_MF_LAZY or any other undefined/invalid flag is set. See the below code
>> snippet from do_mbind():
>>
>> ...
>> #define MPOL_MF_VALID    (MPOL_MF_STRICT   |     \
>>               MPOL_MF_MOVE     |     \
>>               MPOL_MF_MOVE_ALL)
>>
>> if (flags & ~(unsigned long)MPOL_MF_VALID)
>>          return -EINVAL;
>>
>> So, I don't think any application would really use the flag for mbind()
>> unless it is aimed to test the -EINVAL. If just test program, it should be
>> not considered as a regression.
> I have overlook that MPOL_MF_VALID doesn't include MPOL_MF_LAZY. Anyway,
> my argument still holds that the bit has to be reserved for ever because
> it used to be valid at some point of time and not returning EINVAL could
> imply you are running on the kernel which supports the flag.

I'd say it is not valid since very beginning. MPOL_MF_LAZY was added by 
commit b24f53a0bea3 ("mm: mempolicy: Add
MPOL_MF_LAZY"), then it was hidden by commit a720094ded8c ("mm:
mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now"). 
And, git describe --contains shows:

US-143344MP:linux yang.s$ git describe --contains b24f53a0bea3
v3.8-rc1~92^2~27
US-143344MP:linux yang.s$ git describe --contains a720094ded8c
v3.8-rc1~92^2~25

This is why I thought it is never ever exported to userspace.

>   
>>>> I'm also not sure if anyone use MPOL_MF_INTERNAL or not and how they use it
>>>> in their applications, but how about keeping it unchanged?
>>> You really have to. Because it is an offset of other MPLO flags for
>>> internal usage.
>>>
>>> That being said. Considering that we really have to preserve
>>> MPOL_MF_LAZY value (we cannot even rename it because it is in uapi
>>> headers and we do not want to break compilation). What is the point of
>>> this change? Why is it an improvement? Yes, nobody is probably using
>>> this because this is not respected in anything but the preferred mem
>>> policy. At least that is the case from my quick glance. I might be still
>>> wrong as it is quite easy to overlook all the consequences. So the risk
>>> is non trivial while the benefit is not really clear to me. If you see
>>> one, _document_ it. "Mel said it is not in use" is not a justification,
>>> with all due respect.
>> As I elaborated above, mbind() syscall does check it and treat it as an
>> invalid flag. MPOL_PREFERRED doesn't use it either, but just use MPOL_F_MOF
>> directly.
> As Mel already pointed out. This doesn't really sound like a sound
> argument. Say we would remove those few lines of code and preserve the
> flag for future reservation of the flag bit. I would bet my head that it
> will not be long before somebody just goes and clean it up and remove
> because the flag is unused. So you would have to put a note explaining
> why this has to be preserved. Maybe the current code is better to
> document that. It would be much more sound to remove the code if it was
> causing a measurable overhead or a maintenance burden. Is any of that
> the case?

As what I found out, I just thought it may be dead code, if so why not 
remove it otherwise we may have to keep maintaining the unused code.

Thanks,
Yang

>

