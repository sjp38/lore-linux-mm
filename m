Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69155C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 18:26:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C773A214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 18:26:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C773A214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6199E6B0003; Fri,  9 Aug 2019 14:26:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A3796B0007; Fri,  9 Aug 2019 14:26:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 499BD6B000C; Fri,  9 Aug 2019 14:26:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB436B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 14:26:21 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i2so61981672pfe.1
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 11:26:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=ibOu//LijPNVdiTontKhY3FyvQypT4asDWaT8UoUjgc=;
        b=IRkpu3wdgRIzcJqTjfq9+L6Q/xjfPsFtGK9OL/NNyNFNPGW/pXQub1nrLj2lLNnEMg
         JexVrxAihzUzUGLDfaxRkBkkHw7pN5Ml2/bqqNFkpMov9iztnCslkKsSzwbLV9U+fQQW
         iEUkjbeHmgVaIWnsEUDs+08emyaMjUFFC1fGyyjF8aOSc0eJ1PRBCiRXbE+b4CZXP1x0
         zE1rrDQp+x9uiWeHLnDEMTHCsmD7XtULkcFH7Jf1TiJW57grrgfwId8Tgptsd3n+sjK9
         RY7pNoDbdNX4QfgyBPWEs6E79lk2wzIzf8eAsA0hNiIWxcUg/sFICN+qrpkPqcQKy7AS
         vOiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXvciwgJAAHdy1rYo25IeEzNYJmeRs8vrzr6hXigJt+zlWjuK9j
	bJFY47oGdhwDoSFWkkwu1T6SVab0QV4WgKdn3so5GCr4rx1MTGcvA7Y2vniZMAHvlEKN168Th0E
	MnIdyb3LM/IeAl245JRiMp6fRb2Wwi/SSDuPVz0rOT7O3JkbtzQ5zhZxa6AO+Ypl8+g==
X-Received: by 2002:a62:7890:: with SMTP id t138mr22490844pfc.238.1565375180716;
        Fri, 09 Aug 2019 11:26:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjqGD8fnIpq0kZupc5BDfkqCOTyuikcZthcwPG+jPlU3t92pRpx5Ut/8TsdmQOoHrtcST7
X-Received: by 2002:a62:7890:: with SMTP id t138mr22490793pfc.238.1565375179850;
        Fri, 09 Aug 2019 11:26:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565375179; cv=none;
        d=google.com; s=arc-20160816;
        b=pX+0FI6IabkhWXnEcXWiXQqj3pgU/WJEnr2dIzEA14r7bjaxf87HWJxQPZbN2NOBcu
         rVkl3xFvjX98jyBhvPaOYshZL2wb/+kpKKtIGc1k/+1GpPYj+zLsk9TG2YNz+lucfQcc
         1r7nUa4o1maoJZZu2roGPVodL0qrNYtrn5JWjp1T3C9nKlvVnZssHCc7xrasSkAP60d2
         zWY0DTHX3kwytj+qrIsBMKnrdOiyd1HO9iHwWtR2KstUlETqL+OKnDo7BsyQbtp0ndB+
         7IrmBu3bke6nUzVxf2aoMR6mNFL7PIgz58+bqvQzGsDfUDydb5pp5Js1eqjWkrkINdm/
         XJdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ibOu//LijPNVdiTontKhY3FyvQypT4asDWaT8UoUjgc=;
        b=Qhripj310Tno/HgQnNtYgxaWZo+sFU4Bh6OvbgI6YCwlsVX/0zDxuIgM30oKdokUMM
         rCqXL1acMtNAbaaJOMx+oZvXqOlbuIIZ1jnUnewuu/VzKR7nS/GDDg11d/Cqb9dv4bhy
         26Nn6AgeOd3gBF/s6GNEG9QNdfatCFEiIG0dz1onMewzXHF5SDdM4CODwXxebMtxI6Ga
         AJ5YXUgG0wG1vAw0zwbLDU/XqosLc2BZIMdCgKx7j2z3LbrsllOAXsQmj3VuubLEmErg
         N/E/yEYB0IsoF+rEbrde91dLia7BIhBtSpaq0AP/rTkiGA1/+a6voPY18yddhNWDWGKH
         jDeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id l36si29408656pgb.292.2019.08.09.11.26.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 11:26:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R491e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TZ1vktP_1565375173;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TZ1vktP_1565375173)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 10 Aug 2019 02:26:17 +0800
Subject: Re: [RESEND PATCH 1/2 -mm] mm: account lazy free pages separately
To: Michal Hocko <mhocko@kernel.org>
Cc: kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, vbabka@suse.cz,
 rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1565308665-24747-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190809083216.GM18351@dhcp22.suse.cz>
 <1a3c4185-c7ab-8d6f-8191-77dce02025a7@linux.alibaba.com>
 <20190809180238.GS18351@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <79c90f6b-fcac-02e1-015a-0eaa4eafdf7d@linux.alibaba.com>
Date: Fri, 9 Aug 2019 11:26:13 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190809180238.GS18351@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 8/9/19 11:02 AM, Michal Hocko wrote:
> On Fri 09-08-19 09:19:13, Yang Shi wrote:
>>
>> On 8/9/19 1:32 AM, Michal Hocko wrote:
>>> On Fri 09-08-19 07:57:44, Yang Shi wrote:
>>>> When doing partial unmap to THP, the pages in the affected range would
>>>> be considered to be reclaimable when memory pressure comes in.  And,
>>>> such pages would be put on deferred split queue and get minus from the
>>>> memory statistics (i.e. /proc/meminfo).
>>>>
>>>> For example, when doing THP split test, /proc/meminfo would show:
>>>>
>>>> Before put on lazy free list:
>>>> MemTotal:       45288336 kB
>>>> MemFree:        43281376 kB
>>>> MemAvailable:   43254048 kB
>>>> ...
>>>> Active(anon):    1096296 kB
>>>> Inactive(anon):     8372 kB
>>>> ...
>>>> AnonPages:       1096264 kB
>>>> ...
>>>> AnonHugePages:   1056768 kB
>>>>
>>>> After put on lazy free list:
>>>> MemTotal:       45288336 kB
>>>> MemFree:        43282612 kB
>>>> MemAvailable:   43255284 kB
>>>> ...
>>>> Active(anon):    1094228 kB
>>>> Inactive(anon):     8372 kB
>>>> ...
>>>> AnonPages:         49668 kB
>>>> ...
>>>> AnonHugePages:     10240 kB
>>>>
>>>> The THPs confusingly look disappeared although they are still on LRU if
>>>> you are not familair the tricks done by kernel.
>>> Is this a fallout of the recent deferred freeing work?
>> This series follows up the discussion happened when reviewing "Make deferred
>> split shrinker memcg aware".
> OK, so it is a pre-existing problem. Thanks!
>
>> David Rientjes suggested deferred split THP should be accounted into
>> available memory since they would be shrunk when memory pressure comes in,
>> just like MADV_FREE pages. For the discussion, please refer to:
>> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg2010115.html
> Thanks for the reference.
>
>>>> Accounted the lazy free pages to NR_LAZYFREE, and show them in meminfo
>>>> and other places.  With the change the /proc/meminfo would look like:
>>>> Before put on lazy free list:
>>> The name is really confusing because I have thought of MADV_FREE immediately.
>> Yes, I agree. We may use a more specific name, i.e. DeferredSplitTHP.
>>
>>>> +LazyFreePages: Cleanly freeable pages under memory pressure (i.e. deferred
>>>> +               split THP).
>>> What does that mean actually? I have hard time imagine what cleanly
>>> freeable pages mean.
>> Like deferred split THP and MADV_FREE pages, they could be reclaimed during
>> memory pressure.
>>
>> If you just go with "DeferredSplitTHP", these ambiguity would go away.
> I have to study the code some more but is there any reason why those
> pages are not accounted as proper THPs anymore? Sure they are partially
> unmaped but they are still THPs so why cannot we keep them accounted
> like that. Having a new counter to reflect that sounds like papering
> over the problem to me. But as I've said I might be missing something
> important here.

I think we could keep those pages accounted for NR_ANON_THPS since they 
are still THP although they are unmapped as you mentioned if we just 
want to fix the improper accounting.

Here the new counter is introduced for patch 2/2 to account deferred 
split THPs into available memory since NR_ANON_THPS may contain 
non-deferred split THPs.

I could use an internal counter for deferred split THPs, but if it is 
accounted by mod_node_page_state, why not just show it in /proc/meminfo? 
Or we fix NR_ANON_THPS and show deferred split THPs in /proc/meminfo?

>

