Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id A81BF6B04B3
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 19:17:24 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id s143so175083136ywg.3
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 16:17:24 -0700 (PDT)
Received: from mail-yw0-x22e.google.com (mail-yw0-x22e.google.com. [2607:f8b0:4002:c05::22e])
        by mx.google.com with ESMTPS id x188si1760727yba.492.2017.08.18.16.17.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 16:17:23 -0700 (PDT)
Received: by mail-yw0-x22e.google.com with SMTP id u207so67100618ywc.3
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 16:17:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170818143450.7584a3f86abf96f4c43fccd0@linux-foundation.org>
References: <20170818011023.181465-1-shakeelb@google.com> <CALvZod444NZaw9wcdSMs5Y60a0cV4j9SEt-TLBJT34OJ_yg3CQ@mail.gmail.com>
 <20170818143450.7584a3f86abf96f4c43fccd0@linux-foundation.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 18 Aug 2017 16:17:22 -0700
Message-ID: <CALvZod6q=6vVOjsKNX9ktpRpcv_Dhj=Zo3L8SPVvRW2SrgfCDw@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: fadvise: avoid fadvise for fs without backing device
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 18, 2017 at 2:34 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 17 Aug 2017 18:20:17 -0700 Shakeel Butt <shakeelb@google.com> wrote:
>
>> +linux-mm, linux-kernel
>>
>> On Thu, Aug 17, 2017 at 6:10 PM, Shakeel Butt <shakeelb@google.com> wrote:
>> > The fadvise() manpage is silent on fadvise()'s effect on
>> > memory-based filesystems (shmem, hugetlbfs & ramfs) and pseudo
>> > file systems (procfs, sysfs, kernfs). The current implementaion
>> > of fadvise is mostly a noop for such filesystems except for
>> > FADV_DONTNEED which will trigger expensive remote LRU cache
>> > draining. This patch makes the noop of fadvise() on such file
>> > systems very explicit.
>> >
>> > However this change has two side effects for ramfs and one for
>> > tmpfs. First fadvise(FADV_DONTNEED) can remove the unmapped clean
>> > zero'ed pages of ramfs (allocated through read, readahead & read
>> > fault) and tmpfs (allocated through read fault). Also
>> > fadvise(FADV_WILLNEED) on create such clean zero'ed pages for
>> > ramfs. This change removes these two interfaces.
>> >
>
> It doesn't sound like a risky change to me, although perhaps someone is
> depending on the current behaviour for obscure reasons, who knows.
>
> What are the reasons for this change?  Is the current behaviour causing
> some sort of problem for someone?

Yes, one of our generic library does fadvise(FADV_DONTNEED). Recently
we observed high latency in fadvise() and notice that the users have
started using tmpfs files and the latency was due to expensive remote
LRU cache draining. For normal tmpfs files (have data written on
them), fadvise(FADV_DONTNEED) will always trigger the un-needed remote
cache draining.

>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
