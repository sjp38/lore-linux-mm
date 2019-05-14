Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD709C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 09:12:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5325220675
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 09:12:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5325220675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF8D46B026F; Tue, 14 May 2019 05:12:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA91B6B0270; Tue, 14 May 2019 05:12:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B96466B0271; Tue, 14 May 2019 05:12:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 54B946B026F
	for <linux-mm@kvack.org>; Tue, 14 May 2019 05:12:24 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id 17so2213280lfr.14
        for <linux-mm@kvack.org>; Tue, 14 May 2019 02:12:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=RB8yoXW30Wow1zTg31J23rJgqH4zq4zDFZziGNsf208=;
        b=em8a6R1qrvIjnGo43vs2QDNef9R4X2hR1m9PxA5gWOof3YUP1CKEpPr7rRX7YYZMem
         Wy5fozTMjq+H9LkRO6tq9GmrI7cAFa4s24QNn3mtE0+oTTn7t5mlTdkWPN64vQdZSfCR
         gbX6wmYULEtAQ0XVl5fgIUUaHj1zN7nUDmblKJ9PxHkS7OzKx5N17WxFyGjqAywQ3PoK
         /4KXcA1kYLJv9KBz4hXGLPv4vmjjTgWa62VQnFerhUv9tpj3yrLrt3kgI72fmB7x6TB+
         GON922w2Fwjut5iiQ3FhK5DqYdti7p6jmD7I8DWEgW0oIPn6fXZvOY7P6MWAALPr6VPt
         a/Tw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAUEgWKRmLJ5CreUGIcZuPYow4qjXdTxc0bqBKEZtAFuSZqhu4A2
	Qc/nTGYBytoka1eic4UpqlDEBnQF6x7xdQGCTiI7sYrjIe0xyvBz27/2Qx2bniFW2iq+FMbb7n8
	sJcTDD25CrxN7rL4kGvP3ui4QDYFjxRnYcC/TMekKa32Xm6Hg9q/QaQXb6xhF3+YEVg==
X-Received: by 2002:a2e:94c7:: with SMTP id r7mr16608457ljh.91.1557825143539;
        Tue, 14 May 2019 02:12:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx13YFRd9PdOKlo1GQe1XT/8Lb+jjn5cRUjFCggy+Gdq3aj3ARWVrhUE102qh2m5b2jMd3r
X-Received: by 2002:a2e:94c7:: with SMTP id r7mr16608415ljh.91.1557825142335;
        Tue, 14 May 2019 02:12:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557825142; cv=none;
        d=google.com; s=arc-20160816;
        b=vQ1r0gL4cFBXvVg6ogMJmwAqhu/lOILt0fm7rmumUWnZmHqffzn6d53NxxpZH8aUF7
         1+sVAioY78PSXD/pt3CTY7Ptivsp/GrQv3oihTmsQzjwTPB1nIZ3iJinWwYi1kEAJWHH
         riwXLAaqJVQ23uBhPz/KLohi0Zf32pT+e7i7kbqUvjBTW5JPz1VertZ7FsIkse4I6BQ+
         wUn7eTNQej4PDGC4BJPaNdm+ORLxTYPCo7aBXFJYTugtAA0JtUPWyhoGq/Ic/qicckf8
         c1iar42+BVFQuH1TQ2WlEGZRX36AUnlM3ItuQgQlKFBUowrxPUxrTQ2ne0/XDa/wpGoa
         uxpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=RB8yoXW30Wow1zTg31J23rJgqH4zq4zDFZziGNsf208=;
        b=q3jTH2P5MD1gM0NlXlM32n2XQRbSwowBOHcb4rXTWQICQvg17VKZwRoRHlALxi8hq0
         +73owWo9119ItRC8n4Hm4izwnNJxYltmgCXzKr4rGtoayEDZC0ksd0hoBovQif4/kn+h
         PUBb3AO0YmRI1dDvr0mU8XyEnm3nnyTMONz8q/vPeP0ZWCrERETb2IKRpy+uLO7BOs8z
         81K6H3AupdA0MANnXDhkDo3ar6+/+G+yBnPGR5xBh08WrrJlaAhDhKQfMSeVoLT7y/Hh
         wW8TjrpKtdXEs6Isffja8JthqlOZBnOJ/ynIAIK7bvMbBQ6pF0QuputIiS97qAwpgaM9
         OkLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id l15si10720371lfh.2.2019.05.14.02.12.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 02:12:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hQTTt-0001sf-Bj; Tue, 14 May 2019 12:12:17 +0300
Subject: Re: [PATCH RFC 0/4] mm/ksm: add option to automerge VMAs
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>,
 Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Timofey Titovets <nefelim4ag@gmail.com>, Aaron Tomlin <atomlin@redhat.com>,
 linux-mm@kvack.org
References: <20190510072125.18059-1-oleksandr@redhat.com>
 <36a71f93-5a32-b154-b01d-2a420bca2679@virtuozzo.com>
 <20190513113314.lddxv4kv5ajjldae@butterfly.localdomain>
 <a3870e32-3a27-e6df-fcb2-79080cdd167a@virtuozzo.com>
 <20190514063043.ojhsb6d3ohxx4wur@butterfly.localdomain>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <8f146863-5963-81b2-ed20-6428d1da353c@virtuozzo.com>
Date: Tue, 14 May 2019 12:12:16 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190514063043.ojhsb6d3ohxx4wur@butterfly.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 14.05.2019 09:30, Oleksandr Natalenko wrote:
> Hi.
> 
> On Mon, May 13, 2019 at 03:37:56PM +0300, Kirill Tkhai wrote:
>>> Yes, I get your point. But the intention is to avoid another hacky trick
>>> (LD_PRELOAD), thus *something* should *preferably* be done on the
>>> kernel level instead.
>>
>> I don't think so. Does userspace hack introduce some overhead? It does not
>> look so. Why should we think about mergeable VMAs in page fault handler?!
>> This is the last thing we want to think in page fault handler.
>>
>> Also, there is difficult synchronization in page fault handlers, and it's
>> easy to make a mistake. So, there is a mistake in [3/4], and you call
>> ksm_enter() with mmap_sem read locked, while normal way is to call it
>> with write lock (see madvise_need_mmap_write()).
>>
>> So, let's don't touch this path. Small optimization for unlikely case will
>> introduce problems in optimization for likely case in the future.
> 
> Yup, you're right, I've missed the fact that write lock is needed there.
> Re-vamping locking there is not my intention, so lets find another
> solution.
> 
>>> Also, just for the sake of another piece of stats here:
>>>
>>> $ echo "$(cat /sys/kernel/mm/ksm/pages_sharing) * 4 / 1024" | bc
>>> 526
>>
>> This all requires attentive analysis. The number looks pretty big for me.
>> What are the pages you get merged there? This may be just zero pages,
>> you have identical.
>>
>> E.g., your browser want to work fast. It introduces smart schemes,
>> and preallocates many pages in background (mmap + write 1 byte to a page),
>> so in further it save some time (no page fault + alloc), when page is
>> really needed. But your change merges these pages and kills this
>> optimization. Sounds not good, does this?
>>
>> I think, we should not think we know and predict better than application
>> writers, what they want from kernel. Let's people decide themselves
>> in dependence of their workload. The only exception is some buggy
>> or old applications, which impossible to change, so force madvise
>> workaround may help. But only in case there are really such applications...
>>
>> I'd researched what pages you have duplicated in these 526 MB. Maybe
>> you find, no action is required or a report to userspace application
>> to use madvise is needed.
> 
> OK, I agree, this is a good argument to move decision to userspace.
> 
>>> 2) what kinds of opt-out we should maintain? Like, what if force_madvise
>>> is called, but the task doesn't want some VMAs to be merged? This will
>>> required new flag anyway, it seems. And should there be another
>>> write-only file to unmerge everything forcibly for specific task?
>>
>> For example,
>>
>> Merge:
>> #echo $task > /sys/kernel/mm/ksm/force_madvise
> 
> Immediate question: what should be actually done on this? I see 2
> options:
> 
> 1) mark all VMAs as mergeable + set some flag for mmap() to mark all
> further allocations as mergeable as well;
> 2) just mark all the VMAs as mergeable; userspace can call this
> periodically to mark new VMAs.
> 
> My prediction is that 2) is less destructive, and the decision is
> preserved predominantly to userspace, thus it would be a desired option.

Let's see, how we use KSM now. It's good for virtual machines: people
install the same distribution in several VMs, and they have the same
packages and the same files. When you read a file inside VM, its pages
are file cache for the VM, but they are anonymous pages for host kernel.

Hypervisor marks VM memory as mergeable, and host KSM merges the same
anonymous pages together. Many of file cache inside VM is constant
content, so we have good KSM compression on such the file pages.
The result we have is explainable and expected.

But we don't know anything about pages, you have merged on your laptop.
We can't make any assumptions before analysis of applications, which
produce such the pages. Let's check what happens before we try to implement
some specific design (if we really need something to implement).

The rest is just technical details. We may implement everything we need
on top of this (even implement a polling of /proc/[pid]/maps and write
a task and address of vma to force_madvise or similar file).

Kirill

