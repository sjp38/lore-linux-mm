Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE8EBC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 14:00:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5285620815
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 14:00:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5285620815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE0846B0003; Fri, 24 May 2019 10:00:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D68F66B0005; Fri, 24 May 2019 10:00:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C09DB6B0006; Fri, 24 May 2019 10:00:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5426C6B0003
	for <linux-mm@kvack.org>; Fri, 24 May 2019 10:00:46 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id r63so496017lfe.7
        for <linux-mm@kvack.org>; Fri, 24 May 2019 07:00:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=QpTJZZY+MTFqqbxx4mMAvnADTWSX8F9Xt/OK6AUUwgg=;
        b=sJlfxfT/f9yBcfATGLzUEFN3RwacEClmCcTD3pdkjiHjKKf480KJPypL7i6ReeSxlL
         BWx8H0pSWZ+BJZT8kkGgi6y5eS2VyEtpNS4l4EZpQS6I2zl21EBKVhJ9SzZiI/R/UoZC
         Md7s9Vval23TbOc4bYP3MY0/gr/T28jtE53wsrW55eH1Zfh1OKkCnO5POOi2LQQl/qPh
         nG3VyHDw5LOub/E2zHs9NaPys5NiWGz5OJPfgN8jTS/TryLoGPmFOA0JQeo6Himcqi+b
         SNsThe+euswSLzEoESIXKjpSaIVUSyA2P7XRlFeiXJFbvEJHcWP6uvRr+1beNsG7BlVl
         tj2g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAV0friILI8/cO0/d4sAWorlD2kxYzH+pp2DW8vETklrH3ZROnE4
	P2fA0GVZ24E97oyIT2SN6PTRsi1MK9XMqJZ/0golyTi+6K7lE6H8YxB3LtEReXlJqq6IGKqXQBV
	7b0U75ycK+Q84a8IzeokB24h2qmin+RrjZtGC8JW/WbVk1WFhv252/Xnw5QhFNvM3JQ==
X-Received: by 2002:a19:740e:: with SMTP id v14mr45529996lfe.144.1558706445630;
        Fri, 24 May 2019 07:00:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTJVEEgUpzp6SpkwRMxfpbD+r6nqY1b3BWVSwlCaBUmgsa4b1HHi0lSYdHbUFUOwG4PAci
X-Received: by 2002:a19:740e:: with SMTP id v14mr45529936lfe.144.1558706444564;
        Fri, 24 May 2019 07:00:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558706444; cv=none;
        d=google.com; s=arc-20160816;
        b=DuTnhPjLjmE++YxTmTAPX0o6qNN47klsDTlLxgFmxBywVrvb1IOVFQEjtjd3oap19D
         mmz+P4Uo62vd1oLaRBywcNpTVa90cxhXpOW1OMgZIYEKd7bEQxqGqxYI/CSqNNFzGu3G
         cLF6jhOcrKqgSLd/7bJSjsuQpc0Z4DDpz2mguB1VEMdsSun/8vBH9oKBMEY+yzF0xCEM
         HFlvh4aWwo9pdhWcHiJB99hBzRFEeR8V7DFmr6zywfXaoAVtotYJvXzVwhhrccunllCS
         unGRYJiVl1y0WWmX0t2tO3tOCKs2YLGo2U9kutzzcvnU3KA52bVxZCj1+7rocupnx91C
         BlKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=QpTJZZY+MTFqqbxx4mMAvnADTWSX8F9Xt/OK6AUUwgg=;
        b=GMWz6wMZNmQua5kwzmRPSR5nZynPnjyGzBCgrWBBfszvLPXUApbWZ07qo5gVyln0u7
         LpdqMlrW4z1p8VlcN502idIKT/fuwCE/ixBnW9iD2Drev0AUD5fICp7DManLOItITrC4
         sl53Mng9s5nWvs0nrC27BTUgYm6zRwtoUwRD6ONKO/P49add/Mn603d34SJJY80uZxig
         uk+K7J5pjvfI37sgI0MRPiDDF0mzKfb0l3UWAi18EQ9Gq+suSstwAkmPccH1wIaQiCxp
         wYiY7GVqxdOXMj9BbCW+BD0u0jW5WzcNZajnJC8w5rngYbezPWjeCZXQsSuRNhE+EuYA
         amUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id s22si2393494ljh.180.2019.05.24.07.00.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 07:00:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hUAkL-0006lR-1n; Fri, 24 May 2019 17:00:33 +0300
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
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <c3cd3719-0a5e-befe-89f2-328526bb714d@virtuozzo.com>
Date: Fri, 24 May 2019 17:00:32 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190524115239.ugxv766doolc6nsc@box>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 24.05.2019 14:52, Kirill A. Shutemov wrote:
> On Fri, May 24, 2019 at 01:45:50PM +0300, Kirill Tkhai wrote:
>> On 22.05.2019 18:22, Kirill A. Shutemov wrote:
>>> On Mon, May 20, 2019 at 05:00:01PM +0300, Kirill Tkhai wrote:
>>>> This patchset adds a new syscall, which makes possible
>>>> to clone a VMA from a process to current process.
>>>> The syscall supplements the functionality provided
>>>> by process_vm_writev() and process_vm_readv() syscalls,
>>>> and it may be useful in many situation.
>>>
>>> Kirill, could you explain how the change affects rmap and how it is safe.
>>>
>>> My concern is that the patchset allows to map the same page multiple times
>>> within one process or even map page allocated by child to the parrent.
>>>
>>> It was not allowed before.
>>>
>>> In the best case it makes reasoning about rmap substantially more difficult.
>>>
>>> But I'm worry it will introduce hard-to-debug bugs, like described in
>>> https://lwn.net/Articles/383162/.
>>
>> Andy suggested to unmap PTEs from source page table, and this make the single
>> page never be mapped in the same process twice. This is OK for my use case,
>> and here we will just do a small step "allow to inherit VMA by a child process",
>> which we didn't have before this. If someone still needs to continue the work
>> to allow the same page be mapped twice in a single process in the future, this
>> person will have a supported basis we do in this small step. I believe, someone
>> like debugger may want to have this to make a fast snapshot of a process private
>> memory (when the task is stopped for a small time to get its memory). But for
>> me remapping is enough at the moment.
>>
>> What do you think about this?
> 
> I don't think that unmapping alone will do. Consider the following
> scenario:
> 
> 1. Task A creates and populates the mapping.
> 2. Task A forks. We have now Task B mapping the same pages, but
> write-protected.
> 3. Task B calls process_vm_mmap() and passes the mapping to the parent.
> 
> After this Task A will have the same anon pages mapped twice.

Ah, sure.

> One possible way out would be to force CoW on all pages in the mapping,
> before passing the mapping to the new process.

This will pop all swapped pages up, which is the thing the patchset aims
to prevent.

Hm, what about allow remapping only VMA, which anon_vma::rb_root contain
only chain and which vma->anon_vma_chain contains single entry? This is
a vma, which were faulted, but its mm never were duplicated (or which
forks already died).

Thanks,
Kirill

