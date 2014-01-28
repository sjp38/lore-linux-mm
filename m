Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 850696B0036
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 18:14:43 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id f11so1443479qae.21
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 15:14:43 -0800 (PST)
Received: from mail-qc0-x231.google.com (mail-qc0-x231.google.com [2607:f8b0:400d:c01::231])
        by mx.google.com with ESMTPS id i3si71101qcn.71.2014.01.28.15.14.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 15:14:42 -0800 (PST)
Received: by mail-qc0-f177.google.com with SMTP id i8so1625516qcq.8
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 15:14:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52E83719.9060709@zytor.com>
References: <52E709C0.1050006@linaro.org> <52E7298D.5020001@zytor.com>
 <52E80B85.8020302@linaro.org> <52E814FF.6060403@zytor.com>
 <52E819F0.6040806@linaro.org> <CAPXgP11Fv6TU+o2Eui5rVW0A37U7KjwC0DZYbQOJJ8rEAYOiJg@mail.gmail.com>
 <52E81BB3.6060306@linaro.org> <52E81CE2.3030304@zytor.com>
 <52E8271B.4030201@linaro.org> <CAPXgP13G14B3YFpaE+m_AtFfFR6NRVSi1JYAvLZSsfftSkgwBQ@mail.gmail.com>
 <52E83719.9060709@zytor.com>
From: Kay Sievers <kay@vrfy.org>
Date: Wed, 29 Jan 2014 00:14:22 +0100
Message-ID: <CAPXgP116TBZx82=J_pKxgSqJsy4HY1nofMOkUtZELBYvcFhDcw@mail.gmail.com>
Subject: Re: [RFC] shmgetfd idea
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: John Stultz <john.stultz@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>

On Wed, Jan 29, 2014 at 12:02 AM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 01/28/2014 02:14 PM, Kay Sievers wrote:
>>>
>>> But yes, alternatively classic systems may be able to get around the
>>> issues via tmpfs quotas and convincing applications to use O_TMPFILE
>>> there. But to me this seems less ideal then the Android approach, where
>>> the lifecycle of the tmpfs fds more limited and clear.
>>
>> Tmpfs supports no quota, it's all a huge hole and unsafe in that
>> regard on every system today. But ashmem and kdbus, as they are today,
>> are not better.
>
> We can fix that aspect in tmpfs.  Creating new file objcts outside of
> filesystems really doesn't make things any better, since our toolbox
> around this stuff largely revolves around filesystems.

Sure, it should be fixed, not doubt, even when not in this context,
it's something that we should have.

Back to the topic, let's say, if we would require a tmpfs mount to get
to an unlinked shmemfd, which sounds acceptable if we can solve the
other features in a nice way.

What would be the interface for additional functionality like
sealing/unsealing that thing, that no operation can destruct its
content as long as there is more than a single owner? That would be a
new syscall or fcntl() with specific shmemfd options?

We also need to solve the problem that the inode does not show up in
/proc/$PID/fd/, so that nothing can create a new file for it which we
don't catch with the "single owner" logic. Or we could determine the
"single owner" state from the inode itself?

Kay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
