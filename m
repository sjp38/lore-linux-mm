Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC806B0038
	for <linux-mm@kvack.org>; Sat, 25 Mar 2017 05:54:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c87so13988496pfl.6
        for <linux-mm@kvack.org>; Sat, 25 Mar 2017 02:54:40 -0700 (PDT)
Received: from mail-pg0-x22a.google.com (mail-pg0-x22a.google.com. [2607:f8b0:400e:c05::22a])
        by mx.google.com with ESMTPS id x6si5905515plm.183.2017.03.25.02.54.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Mar 2017 02:54:39 -0700 (PDT)
Received: by mail-pg0-x22a.google.com with SMTP id 21so6645747pgg.1
        for <linux-mm@kvack.org>; Sat, 25 Mar 2017 02:54:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170324200837.82451-1-dvyukov@google.com>
References: <20170324200837.82451-1-dvyukov@google.com>
From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Sat, 25 Mar 2017 18:54:18 +0900
Message-ID: <CAC5umyi0Yq7spQW=nQEEnkZ1Ar7VBwaZPPdstThnyJzg2tSKUg@mail.gmail.com>
Subject: Re: [PATCH] fault-inject: support systematic fault injection
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, syzkaller@googlegroups.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

2017-03-25 5:08 GMT+09:00 Dmitry Vyukov <dvyukov@google.com>:
> Add /sys/kernel/debug/fail_once file that allows failing 0-th, 1-st, 2-nd
> and so on calls systematically. Excerpt from the added documentation:
>
> ===
> Write to this file of integer N makes N-th call in the current task fail
> (N is 0-based). Read from this file returns a single char 'Y' or 'N'
> that says if the fault setup with a previous write to this file was
> injected or not, and disables the fault if it wasn't yet injected.
> Note that this file enables all types of faults (slab, futex, etc).
> This setting takes precedence over all other generic settings like
> probability, interval, times, etc. But per-capability settings
> (e.g. fail_futex/ignore-private) take precedence over it.
> This feature is intended for systematic testing of faults in a single
> system call. See an example below.
> ===

The "/sys/kernel/debug/fail_once" contains per-task data.

Should we introduce new per-task file like "/proc/<pid>/fail-nth"
instead of adding a single global debugfs file?

> Why adding new setting:
> 1. Existing settings are global rather than per-task.
>    So parallel testing is not possible.
> 2. attr->interval is close but it depends on attr->count
>    which is non reset to 0, so interval does not work as expected.
> 3. Trying to model this with existing settings requires manipulations
>    of all of probability, interval, times, space, task-filter and
>    unexposed count and per-task make-it-fail files.
> 4. Existing settings are per-failure-type, and the set of failure
>    types is potentially expanding.
> 5. make-it-fail can't be changed by unprivileged user and aggressive
>    stress testing better be done from an unprivileged user.
>    Similarly, this would require opening the debugfs files to the
>    unprivileged user, as he would need to reopen at least times file
>    (not possible to pre-open before dropping privs).
>
> The proposed interface solves all of the above (see the example).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
