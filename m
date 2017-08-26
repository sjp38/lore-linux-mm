Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A4A06810D7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 20:23:00 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id s187so4556498ywf.1
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 17:23:00 -0700 (PDT)
Received: from mail-yw0-x22e.google.com (mail-yw0-x22e.google.com. [2607:f8b0:4002:c05::22e])
        by mx.google.com with ESMTPS id d61si1934617ybi.804.2017.08.25.17.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 17:22:59 -0700 (PDT)
Received: by mail-yw0-x22e.google.com with SMTP id h127so6847446ywf.3
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 17:22:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170825144957.5d99dad605fed1dc2550d25c@linux-foundation.org>
References: <20170818011023.181465-1-shakeelb@google.com> <CALvZod444NZaw9wcdSMs5Y60a0cV4j9SEt-TLBJT34OJ_yg3CQ@mail.gmail.com>
 <20170825144957.5d99dad605fed1dc2550d25c@linux-foundation.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 25 Aug 2017 17:22:58 -0700
Message-ID: <CALvZod5nvGtHAduA89Ak5gOofJVMA7bhmXjRrjseTptoqz+cmA@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: fadvise: avoid fadvise for fs without backing device
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 25, 2017 at 2:49 PM, Andrew Morton
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
>> > ramfs.
>
> That sentence makes no sense.  I assume "fadvise(FADV_WILLNEED) will
> create"?
>

Sorry about that, it should be "fadvise(FADV_WILLNEED) can create".

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
