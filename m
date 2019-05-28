Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91E3EC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 09:15:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B196208C3
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 09:15:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B196208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E03BD6B0275; Tue, 28 May 2019 05:15:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB4246B0276; Tue, 28 May 2019 05:15:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC9966B0278; Tue, 28 May 2019 05:15:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2CC6B0275
	for <linux-mm@kvack.org>; Tue, 28 May 2019 05:15:29 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id r63so2067050lfe.7
        for <linux-mm@kvack.org>; Tue, 28 May 2019 02:15:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=OS0xkeEd8XGIxPbXYjfzWVTE6GiW3R/9ma+V64SahZ4=;
        b=Bdq0jE9ldUHSfUBEdZljyk9thawhWM5UbbPtNtC0uMt0DcMOgRHDnYTb1WUwECiBKv
         1z9GqwGHwD3gFBbI/1rXp/pIuxlfAIlVNBcHfuMotQ7S0BOlfrXg9qUJHc6G3ALsS/EB
         R7CYUEgy/hUe4TfFsbyLZt+4wISTTxe++EpVgjMuwNGA57XXmmBNt5dHdxX8tm53brNr
         3ABMMefcMtiHjLLTL0ik8uzw5dvjf+KZ3ytn8aa8AL/QXtgxKTa1Ax+kZj7WziBtFa+E
         tzcN7KwzxRZGwjYS4nIGfhTAQaniQWmcVpXRD5JKIekEcRpyYFMLNkWpYJwywap5kq/R
         M0ZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWL0rxgXTG7IqFYl09Z1/6250l6fJTL1qfSQq8/vKciKOMFNNH/
	XrNX+gzobr/h6Uiwvva76q7xC1QfOv6Ut/12mvW1ccXtk0UUEpqP7TfgiCJWIswq0XGhu4+isj6
	Ouwj1rg4SUzbH6MS7DwgD92dlDLhssVYvClsA/gtrG2Dk69VfKa1DFb5oyp91TMgqag==
X-Received: by 2002:a2e:95d2:: with SMTP id y18mr41566501ljh.167.1559034928905;
        Tue, 28 May 2019 02:15:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSm2GfFj67AvDKAM92MkPw4Nme+ColbXVE447mtUZSNwKfApmxQyVwoYdSTqrcc5xd+WSM
X-Received: by 2002:a2e:95d2:: with SMTP id y18mr41566460ljh.167.1559034928012;
        Tue, 28 May 2019 02:15:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559034928; cv=none;
        d=google.com; s=arc-20160816;
        b=GvZaW54hpeOuY0a4F8qy35JbfrQM2iz4Hmm4oI7TPdpooDukEeAn1nTOTItvpj96Av
         x5IizFSJS4kZIrqyrsFYqdbANQNN6Slpq+ZQU5BDeGZ6vXWCY6uP89xn2CYiyk7FOUZZ
         lLB5pngGvEI1y70RmxiAeR7S9vBlgb0Z0Pf38hj6nc2p9xafUrNaIc3IKQxev7UldHWn
         NonRBdf6XEUukRm6UeU7OWbDy4rKAOFg4bpfnqZjzIN/n0b9n7Od9IW1j3WRgKk4pNWs
         6jgtLva+woPgnNO4ow1EuUUfpiuukLXbHv3oBEuQHfI9AwEflolO1GtXqLnJlMfkQN96
         PXVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=OS0xkeEd8XGIxPbXYjfzWVTE6GiW3R/9ma+V64SahZ4=;
        b=fhZ5cHL/mF2GfQ72qDkBz7eYiF1jcpYgiFUiw0TUJBRgpp/t6577XAh44xyCTV+AIW
         lT9ikA+K/X/7XAfG1ZGxl0fqHl6pH8LV/aWUZSVFWWc8TEVH6TDNWRczuFL4TtQrjYJE
         fqN17ta1h3G/P7OdZOLHiVXUNIf8LaSh9u3l8XqJamCe062hkT1mAjTRAFEsroFJSlq8
         2cwIc4Anc4Myx1k7Q47Mx+IM1Wlsh2f6ihtScFi5DfJi+wEq4Q6XeH1fYNpdCUw7oNMc
         PzKZu84Fu6JLydIU/uqM2b1gE2BeWsXPXlTKDykd1jpwR31oLPjMDJfHpl8Owez9pVlv
         TbQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id j13si12918535ljh.217.2019.05.28.02.15.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 02:15:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hVYCS-0001wY-MQ; Tue, 28 May 2019 12:15:16 +0300
Subject: Re: [PATCH v2 0/7] mm: process_vm_mmap() -- syscall for duplication a
 process mapping
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com,
 keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 alexander.h.duyck@linux.intel.com, ira.weiny@intel.com,
 andreyknvl@google.com, arunks@codeaurora.org, vbabka@suse.cz, cl@linux.com,
 riel@surriel.com, keescook@chromium.org, hannes@cmpxchg.org,
 npiggin@gmail.com, mathieu.desnoyers@efficios.com, shakeelb@google.com,
 guro@fb.com, aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
 mgorman@techsingularity.net, daniel.m.jordan@oracle.com, jannh@google.com,
 kilobyte@angband.pl, linux-api@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
 <20190522152254.5cyxhjizuwuojlix@box>
 <358bb95e-0dca-6a82-db39-83c0cf09a06c@virtuozzo.com>
 <20190524115239.ugxv766doolc6nsc@box>
 <c3cd3719-0a5e-befe-89f2-328526bb714d@virtuozzo.com>
 <20190527233030.hpnnbi4aqnu34ova@box>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <de6e4e89-66ac-da2f-48a6-4d98a728687a@virtuozzo.com>
Date: Tue, 28 May 2019 12:15:16 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190527233030.hpnnbi4aqnu34ova@box>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28.05.2019 02:30, Kirill A. Shutemov wrote:
> On Fri, May 24, 2019 at 05:00:32PM +0300, Kirill Tkhai wrote:
>> On 24.05.2019 14:52, Kirill A. Shutemov wrote:
>>> On Fri, May 24, 2019 at 01:45:50PM +0300, Kirill Tkhai wrote:
>>>> On 22.05.2019 18:22, Kirill A. Shutemov wrote:
>>>>> On Mon, May 20, 2019 at 05:00:01PM +0300, Kirill Tkhai wrote:
>>>>>> This patchset adds a new syscall, which makes possible
>>>>>> to clone a VMA from a process to current process.
>>>>>> The syscall supplements the functionality provided
>>>>>> by process_vm_writev() and process_vm_readv() syscalls,
>>>>>> and it may be useful in many situation.
>>>>>
>>>>> Kirill, could you explain how the change affects rmap and how it is safe.
>>>>>
>>>>> My concern is that the patchset allows to map the same page multiple times
>>>>> within one process or even map page allocated by child to the parrent.
>>>>>
>>>>> It was not allowed before.
>>>>>
>>>>> In the best case it makes reasoning about rmap substantially more difficult.
>>>>>
>>>>> But I'm worry it will introduce hard-to-debug bugs, like described in
>>>>> https://lwn.net/Articles/383162/.
>>>>
>>>> Andy suggested to unmap PTEs from source page table, and this make the single
>>>> page never be mapped in the same process twice. This is OK for my use case,
>>>> and here we will just do a small step "allow to inherit VMA by a child process",
>>>> which we didn't have before this. If someone still needs to continue the work
>>>> to allow the same page be mapped twice in a single process in the future, this
>>>> person will have a supported basis we do in this small step. I believe, someone
>>>> like debugger may want to have this to make a fast snapshot of a process private
>>>> memory (when the task is stopped for a small time to get its memory). But for
>>>> me remapping is enough at the moment.
>>>>
>>>> What do you think about this?
>>>
>>> I don't think that unmapping alone will do. Consider the following
>>> scenario:
>>>
>>> 1. Task A creates and populates the mapping.
>>> 2. Task A forks. We have now Task B mapping the same pages, but
>>> write-protected.
>>> 3. Task B calls process_vm_mmap() and passes the mapping to the parent.
>>>
>>> After this Task A will have the same anon pages mapped twice.
>>
>> Ah, sure.
>>
>>> One possible way out would be to force CoW on all pages in the mapping,
>>> before passing the mapping to the new process.
>>
>> This will pop all swapped pages up, which is the thing the patchset aims
>> to prevent.
>>
>> Hm, what about allow remapping only VMA, which anon_vma::rb_root contain
>> only chain and which vma->anon_vma_chain contains single entry? This is
>> a vma, which were faulted, but its mm never were duplicated (or which
>> forks already died).
> 
> The requirement for the VMA to be faulted (have any pages mapped) looks
> excessive to me, but the general idea may work.
> 
> One issue I see is that userspace may not have full control to create such
> VMA. vma_merge() can merge the VMA to the next one without any consent
> from userspace and you'll get anon_vma inherited from the VMA you've
> justed merged with.
> 
> I don't have any valid idea on how to get around this.

Technically it is possible by creating boundary 1-page VMAs with another protection:
one above and one below the desired region, then map the desired mapping. But this
is not comfortable.

I don't think it's difficult to find a natural limitation, which prevents mapping
a single page twice if we want to avoid this at least on start. Another suggestion:

prohibit to map a remote process's VMA only in case of its vm_area_struct::anon_vma::root
is the same as root of one of local process's VMA.

What about this?

Thanks,
Kirill

