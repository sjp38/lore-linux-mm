Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id D85206B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 17:14:53 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id m20so1593451qcx.9
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 14:14:53 -0800 (PST)
Received: from mail-qc0-x229.google.com (mail-qc0-x229.google.com [2607:f8b0:400d:c01::229])
        by mx.google.com with ESMTPS id q51si86009qgd.0.2014.01.28.14.14.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 14:14:51 -0800 (PST)
Received: by mail-qc0-f169.google.com with SMTP id w7so1578992qcr.28
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 14:14:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52E8271B.4030201@linaro.org>
References: <52E709C0.1050006@linaro.org> <52E7298D.5020001@zytor.com>
 <52E80B85.8020302@linaro.org> <52E814FF.6060403@zytor.com>
 <52E819F0.6040806@linaro.org> <CAPXgP11Fv6TU+o2Eui5rVW0A37U7KjwC0DZYbQOJJ8rEAYOiJg@mail.gmail.com>
 <52E81BB3.6060306@linaro.org> <52E81CE2.3030304@zytor.com> <52E8271B.4030201@linaro.org>
From: Kay Sievers <kay@vrfy.org>
Date: Tue, 28 Jan 2014 23:14:30 +0100
Message-ID: <CAPXgP13G14B3YFpaE+m_AtFfFR6NRVSi1JYAvLZSsfftSkgwBQ@mail.gmail.com>
Subject: Re: [RFC] shmgetfd idea
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>

On Tue, Jan 28, 2014 at 10:54 PM, John Stultz <john.stultz@linaro.org> wrote:
> On 01/28/2014 01:10 PM, H. Peter Anvin wrote:
>> On 01/28/2014 01:05 PM, John Stultz wrote:
>>>> General purpose Linux has /dev/shm/ for that already, which will not
>>>> go away anytime soon..
>>> Right, though making /dev/shm/ O_TMPFILE only would likely break things, no?
>> If it isn't, then you already have a writable tmpfs, which is what you
>> said you didn't want.
>
> Well, rather then finding a solution exclusively for Android, I'm trying
> to find an approach that would work more generically.
>
> While classic Linux systems do have writable /dev/shm/, which we *have*
> to preserve, it seem to me that classic linux systems may some day want
> to deal with the issues with writable tmpfs that Android has
> intentionally avoided.
>
> For examples of grumblings on these issues see:
> https://bugzilla.redhat.com/show_bug.cgi?id=693253 (and its dup)
>
> Requiring a binary on/off flag for /dev/shm makes it so you have to
> choose if you are a classic or new-style (android-like) system. By
> avoiding re-using existing convention via providing a new syscall (or
> alternatively with your approach, a new yet to be standardized mount
> point convention), it would allow best practices to be updated, and
> allow for a slow deprecation of the writable /dev/shm, possibly by
> limiting permissions to /dev/shm to only legacy applications, etc.
>
> But yes, alternatively classic systems may be able to get around the
> issues via tmpfs quotas and convincing applications to use O_TMPFILE
> there. But to me this seems less ideal then the Android approach, where
> the lifecycle of the tmpfs fds more limited and clear.

Tmpfs supports no quota, it's all a huge hole and unsafe in that
regard on every system today. But ashmem and kdbus, as they are today,
are not better.

> And my main point being: Both Android's ashmem and kdbus' memfds are
> both utilizing these semantics (though maybe they aren't as
> important/intentional for kdbus?),

We need a way to securely identify an fd that is a memfd in the kernel
and in userspace, and we need to be able to seal it. The rest does not
really matter, we could use O_TMPFILE if we need to, but it still
lacks all the other features.

> so it seems like some generic method
> (which would work in both environments) would generally useful.

Sure, would be nice. There are people from the wayland and X camp, who
asked for a secure semantics and sharing of shmfds too.

> Again, I really do appreciate your feedback here, and I don't mean to be
> panning your idea (I'm quite willing to look further into it if others
> think its the right way)! I just want to explain my point of view and
> motivations a bit better.

I think the most convincing option right now is a new memfd() syscall
or a character device.

We would need more than a create syscall for the sealing/unsealing,
not sure if fcntl() could be (mis-)used/extended for the sealing
interface.

A new character device with ioctls, replacing the current ashmem and
the kdbus memfd part could also work. It has the advantage that it
would just be an optional device driver and it not a primary API with
all the promises, and would provide us with all we need, just the
creation part with the involved ioctl struct definitions is not really
pretty.

Kay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
