Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id D6CF86B03A0
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 09:02:58 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id p66so56526199vkd.5
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 06:02:58 -0700 (PDT)
Received: from mail-vk0-x22b.google.com (mail-vk0-x22b.google.com. [2607:f8b0:400c:c05::22b])
        by mx.google.com with ESMTPS id 61si1632650uav.125.2017.03.28.06.02.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 06:02:57 -0700 (PDT)
Received: by mail-vk0-x22b.google.com with SMTP id s68so86804805vke.3
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 06:02:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAC5umyi0Yq7spQW=nQEEnkZ1Ar7VBwaZPPdstThnyJzg2tSKUg@mail.gmail.com>
References: <20170324200837.82451-1-dvyukov@google.com> <CAC5umyi0Yq7spQW=nQEEnkZ1Ar7VBwaZPPdstThnyJzg2tSKUg@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 28 Mar 2017 15:02:36 +0200
Message-ID: <CACT4Y+arx7_g4k60G-orVoV2r=kyEjCDO99OhYDjyp6MnvgNeA@mail.gmail.com>
Subject: Re: [PATCH] fault-inject: support systematic fault injection
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, syzkaller <syzkaller@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sat, Mar 25, 2017 at 10:54 AM, Akinobu Mita <akinobu.mita@gmail.com> wrote:
> 2017-03-25 5:08 GMT+09:00 Dmitry Vyukov <dvyukov@google.com>:
>> Add /sys/kernel/debug/fail_once file that allows failing 0-th, 1-st, 2-nd
>> and so on calls systematically. Excerpt from the added documentation:
>>
>> ===
>> Write to this file of integer N makes N-th call in the current task fail
>> (N is 0-based). Read from this file returns a single char 'Y' or 'N'
>> that says if the fault setup with a previous write to this file was
>> injected or not, and disables the fault if it wasn't yet injected.
>> Note that this file enables all types of faults (slab, futex, etc).
>> This setting takes precedence over all other generic settings like
>> probability, interval, times, etc. But per-capability settings
>> (e.g. fail_futex/ignore-private) take precedence over it.
>> This feature is intended for systematic testing of faults in a single
>> system call. See an example below.
>> ===
>
> The "/sys/kernel/debug/fail_once" contains per-task data.
>
> Should we introduce new per-task file like "/proc/<pid>/fail-nth"
> instead of adding a single global debugfs file?

Mailed v2 that uses /proc/self/task/tid/fail-nth.


>> Why adding new setting:
>> 1. Existing settings are global rather than per-task.
>>    So parallel testing is not possible.
>> 2. attr->interval is close but it depends on attr->count
>>    which is non reset to 0, so interval does not work as expected.
>> 3. Trying to model this with existing settings requires manipulations
>>    of all of probability, interval, times, space, task-filter and
>>    unexposed count and per-task make-it-fail files.
>> 4. Existing settings are per-failure-type, and the set of failure
>>    types is potentially expanding.
>> 5. make-it-fail can't be changed by unprivileged user and aggressive
>>    stress testing better be done from an unprivileged user.
>>    Similarly, this would require opening the debugfs files to the
>>    unprivileged user, as he would need to reopen at least times file
>>    (not possible to pre-open before dropping privs).
>>
>> The proposed interface solves all of the above (see the example).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
