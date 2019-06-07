Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 851D7C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:51:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D36F208C0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:51:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D36F208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C66C86B0005; Fri,  7 Jun 2019 14:51:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C17CD6B000A; Fri,  7 Jun 2019 14:51:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADF0B6B000C; Fri,  7 Jun 2019 14:51:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 76BA76B0005
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 14:51:42 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d2so1913491pla.18
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 11:51:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=AGNUj2kvaqRp73j7azbJjqoUPm22WX5j3ORc3XR2wm8=;
        b=YkjUeBEvRTkEEzCqdpN/H5BSRDGxz5zFi3XX0yB+Olb6/pTiwgVeYLoAoxaJmu9bYf
         dVjTdRipLFe6lkwK8B4To3Viu/3Wz5I9V271BnAA/Qrp0dECRG3qVXUFZzhsmujsYyN1
         NBWTCtHvDdoW6QER6RUma757HNOtiNVEX89kuCcXPIxWKiH1HqybcDRcPvIjSwxzPmxN
         shhcqEhsFlhP5CAPGDUxN/lCPGRNh6LxhTJxFmRbLCRGj8nFUPZhCEuHvwqU2IkGQtyt
         PgenunV5Y+giUdTv3acBdzPJQuX4+6ArxNZp1n2KzbWUTz2ECPSOqa3eM657kfsg5RnY
         1Avw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVsQeMCQAGXLYFoGcxGh11sAVfwQ3rP9H8CVcVI03m7jwAhHMOL
	AnOt0lhSyYVC44lSM9K76uWlIQCZD3t65ShugHrJuv/85mbvlr2PfVMpgqWXR3QQ0EqLCUOL5Px
	bvMdW3CWoj+cKiRT6uRNwpZuHF+TBNc7fTh+4Ch5Hu5hwrHdY+KqU1KsQKGIm+gTaqg==
X-Received: by 2002:a17:902:3fa5:: with SMTP id a34mr55622132pld.317.1559933502129;
        Fri, 07 Jun 2019 11:51:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdV0HBPjD4yqUqNZJbdhsAmz+LeBLz6xXVZCOKHnNVYhpn/k4bj46GcJMHp+3VLh1Qma6y
X-Received: by 2002:a17:902:3fa5:: with SMTP id a34mr55622089pld.317.1559933501115;
        Fri, 07 Jun 2019 11:51:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559933501; cv=none;
        d=google.com; s=arc-20160816;
        b=Nj+52gje5+zgvlxqYN6K3Xfq+MrlCyyHkQbTqT8zNnuFkwc33qpyTg/OTxIGmOuOkF
         Myp5Kn8IuXrhPLatScTmMs8oRw7+SB0VxBXRKZIESorWyuUOsz0rfksgZPW2A1MXoHhn
         0Zhx8dgWn8BsL49x5AGGsQfdaRhNOHpk224sbIvDwHIc5Y4/ogaaNymauJHbWEe/yY+X
         p37X0aA4veB6aPhJr9RSyt4w4Fcd7c4zecdl8xZFKlQfZK8T6KFPNlX7gFJF723DpLcb
         2ZrkE+/ju3TprnQSm8Zw8y4ss6YES9My9i2Efnl7e791peMz3R+ouaz2FA0nkUdZY3WQ
         P5OA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=AGNUj2kvaqRp73j7azbJjqoUPm22WX5j3ORc3XR2wm8=;
        b=OWjFytAAoqphcGfUqBkFTlfg1spA36DTF3V5Kc4TvirQVx27q3TEXJnz54XvSDYNtN
         oZ0x8LMDC4mod0ldoRQ15TM3FCNH+RVxJqMtAkwWM48+DudGyyNZ57xo34zGq7H8zirp
         4KZdZdGURHDePv7CVLdHM67cCjp/n1gQ3p9/CkUNCrt41RXi+JOq4sezF0c61iff5OqX
         icPTa5BsZofY+QRf4A3w2F/4LOQH9TFPAcPoeT8nlBg8QYPVsNEx4oY/4MZxTBb117aI
         gpHKBKq8RdliTA28p38nyJpYZy94UgwseJLIzappwiEnl3G1787qC3hQw/Vf7yj67BZ+
         1D4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id x22si2735748pgj.271.2019.06.07.11.51.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 11:51:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TTeuMkB_1559933482;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TTeuMkB_1559933482)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 08 Jun 2019 02:51:25 +0800
Subject: Re: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@kernel.org>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz,
 rientjes@google.com, kirill@shutemov.name, akpm@linux-foundation.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190423175252.GP25106@dhcp22.suse.cz>
 <5a571d64-bfce-aa04-312a-8e3547e0459a@linux.alibaba.com>
 <859fec1f-4b66-8c2c-98ee-2aee9358a81a@linux.alibaba.com>
 <20190507104709.GP31017@dhcp22.suse.cz>
 <ec8a65c7-9b0b-9342-4854-46c732c99390@linux.alibaba.com>
 <217fc290-5800-31de-7d46-aa5c0f7b1c75@linux.alibaba.com>
 <alpine.LSU.2.11.1906070314001.1938@eggly.anvils>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <f5b9e7f5-20e7-76a7-e014-891d34780dc5@linux.alibaba.com>
Date: Fri, 7 Jun 2019 11:51:22 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1906070314001.1938@eggly.anvils>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/7/19 3:57 AM, Hugh Dickins wrote:
> On Thu, 6 Jun 2019, Yang Shi wrote:
>> On 5/7/19 10:10 AM, Yang Shi wrote:
>>> On 5/7/19 3:47 AM, Michal Hocko wrote:
>>>> [Hmm, I thought, Hugh was CCed]
>>>>
>>>> On Mon 06-05-19 16:37:42, Yang Shi wrote:
>>>>> On 4/28/19 12:13 PM, Yang Shi wrote:
>>>>>> On 4/23/19 10:52 AM, Michal Hocko wrote:
>>>>>>> On Wed 24-04-19 00:43:01, Yang Shi wrote:
>>>>>>>> The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility
>>>>>>>> for each
>>>>>>>> vma") introduced THPeligible bit for processes' smaps. But, when
>>>>>>>> checking
>>>>>>>> the eligibility for shmem vma, __transparent_hugepage_enabled()
>>>>>>>> is
>>>>>>>> called to override the result from shmem_huge_enabled().  It may
>>>>>>>> result
>>>>>>>> in the anonymous vma's THP flag override shmem's.  For example,
>>>>>>>> running a
>>>>>>>> simple test which create THP for shmem, but with anonymous THP
>>>>>>>> disabled,
>>>>>>>> when reading the process's smaps, it may show:
>>>>>>>>
>>>>>>>> 7fc92ec00000-7fc92f000000 rw-s 00000000 00:14 27764 /dev/shm/test
>>>>>>>> Size:               4096 kB
>>>>>>>> ...
>>>>>>>> [snip]
>>>>>>>> ...
>>>>>>>> ShmemPmdMapped:     4096 kB
>>>>>>>> ...
>>>>>>>> [snip]
>>>>>>>> ...
>>>>>>>> THPeligible:    0
>>>>>>>>
>>>>>>>> And, /proc/meminfo does show THP allocated and PMD mapped too:
>>>>>>>>
>>>>>>>> ShmemHugePages:     4096 kB
>>>>>>>> ShmemPmdMapped:     4096 kB
>>>>>>>>
>>>>>>>> This doesn't make too much sense.  The anonymous THP flag should
>>>>>>>> not
>>>>>>>> intervene shmem THP.  Calling shmem_huge_enabled() with checking
>>>>>>>> MMF_DISABLE_THP sounds good enough.  And, we could skip stack and
>>>>>>>> dax vma check since we already checked if the vma is shmem
>>>>>>>> already.
>>>>>>> Kirill, can we get a confirmation that this is really intended
>>>>>>> behavior
>>>>>>> rather than an omission please? Is this documented? What is a
>>>>>>> global
>>>>>>> knob to simply disable THP system wise?
>>>>>> Hi Kirill,
>>>>>>
>>>>>> Ping. Any comment?
>>>>> Talked with Kirill at LSFMM, it sounds this is kind of intended
>>>>> behavior
>>>>> according to him. But, we all agree it looks inconsistent.
>>>>>
>>>>> So, we may have two options:
>>>>>       - Just fix the false negative issue as what the patch does
>>>>>       - Change the behavior to make it more consistent
>>>>>
>>>>> I'm not sure whether anyone relies on the behavior explicitly or
>>>>> implicitly
>>>>> or not.
>>>> Well, I would be certainly more happy with a more consistent behavior.
>>>> Talked to Hugh at LSFMM about this and he finds treating shmem objects
>>>> separately from the anonymous memory. And that is already the case
>>>> partially when each mount point might have its own setup. So the primary
>>>> question is whether we need a one global knob to controll all THP
>>>> allocations. One argument to have that is that it might be helpful to
>>>> for an admin to simply disable source of THP at a single place rather
>>>> than crawling over all shmem mount points and remount them. Especially
>>>> in environments where shmem points are mounted in a container by a
>>>> non-root. Why would somebody wanted something like that? One example
>>>> would be to temporarily workaround high order allocations issues which
>>>> we have seen non trivial amount of in the past and we are likely not at
>>>> the end of the tunel.
>>> Shmem has a global control for such use. Setting shmem_enabled to "force"
>>> or "deny" would enable or disable THP for shmem globally, including non-fs
>>> objects, i.e. memfd, SYS V shmem, etc.
>>>
>>>> That being said I would be in favor of treating the global sysfs knob to
>>>> be global for all THP allocations. I will not push back on that if there
>>>> is a general consensus that shmem and fs in general are a different
>>>> class of objects and a single global control is not desirable for
>>>> whatever reasons.
>>> OK, we need more inputs from Kirill, Hugh and other folks.
>> [Forgot cc to mailing lists]
>>
>> Hi guys,
>>
>> How should we move forward for this one? Make the sysfs knob
>> (/sys/kernel/mm/transparent_hugepage/enabled) to be global for both anonymous
>> and tmpfs? Or just treat shmem objects separately from anon memory then fix
>> the false-negative of THP eligibility by this patch?
> Sorry for not getting back to you sooner on this.
>
> I don't like to drive design by smaps. I agree with the word "mess" used
> several times of THP tunings in this thread, but it's too easy to make
> that mess worse by unnecessary changes, so I'm very cautious here.
>
> The addition of "THPeligible" without an "Anon" in its name was
> unfortunate. I suppose we're two releases too late to change that.

The smaps shows it is anon vma or shmem vma for the most cases.

>
> Applying process (PR_SET_THP_DISABLE) and mm (MADV_*HUGEPAGE)
> limitations to shared filesystem objects doesn't work all that well.

The THP eligibility indicator is per vma, it just reports whether THP is 
eligible for a specific vma. So, I'm supposed it should keep consistent 
with MMF_DISABLE_THP and MADV_*HUGEPAGE setting.

The current implementation in shmem and kuhugepaged also checks these.

>
> I recommend that you continue to treat shmem objects separately from
> anon memory, and just make the smaps "THPeligible" more often accurate.
>
> Is your v2 patch earlier in this thread the best for that?

The v2 patch treats shmem objects separately from anon memory and it 
makes the "THPeligible" more often accurate.

> No answer tonight, I'll re-examine later in the day.
>
> Hugh

