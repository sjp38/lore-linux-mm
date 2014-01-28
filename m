Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8ED1E6B0038
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 16:54:41 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so913149pab.6
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 13:54:41 -0800 (PST)
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
        by mx.google.com with ESMTPS id xf4si6006pab.220.2014.01.28.13.54.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 13:54:40 -0800 (PST)
Received: by mail-pd0-f179.google.com with SMTP id q10so878105pdj.10
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 13:54:39 -0800 (PST)
Message-ID: <52E8271B.4030201@linaro.org>
Date: Tue, 28 Jan 2014 13:54:35 -0800
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [RFC] shmgetfd idea
References: <52E709C0.1050006@linaro.org> <52E7298D.5020001@zytor.com> <52E80B85.8020302@linaro.org> <52E814FF.6060403@zytor.com> <52E819F0.6040806@linaro.org> <CAPXgP11Fv6TU+o2Eui5rVW0A37U7KjwC0DZYbQOJJ8rEAYOiJg@mail.gmail.com> <52E81BB3.6060306@linaro.org> <52E81CE2.3030304@zytor.com>
In-Reply-To: <52E81CE2.3030304@zytor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Kay Sievers <kay@vrfy.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>

On 01/28/2014 01:10 PM, H. Peter Anvin wrote:
> On 01/28/2014 01:05 PM, John Stultz wrote:
>>> General purpose Linux has /dev/shm/ for that already, which will not
>>> go away anytime soon..
>> Right, though making /dev/shm/ O_TMPFILE only would likely break things, no?
> If it isn't, then you already have a writable tmpfs, which is what you
> said you didn't want.

Well, rather then finding a solution exclusively for Android, I'm trying
to find an approach that would work more generically.

While classic Linux systems do have writable /dev/shm/, which we *have*
to preserve, it seem to me that classic linux systems may some day want
to deal with the issues with writable tmpfs that Android has
intentionally avoided.

For examples of grumblings on these issues see:
https://bugzilla.redhat.com/show_bug.cgi?id=693253 (and its dup)

Requiring a binary on/off flag for /dev/shm makes it so you have to
choose if you are a classic or new-style (android-like) system. By
avoiding re-using existing convention via providing a new syscall (or
alternatively with your approach, a new yet to be standardized mount
point convention), it would allow best practices to be updated, and
allow for a slow deprecation of the writable /dev/shm, possibly by
limiting permissions to /dev/shm to only legacy applications, etc.

But yes, alternatively classic systems may be able to get around the
issues via tmpfs quotas and convincing applications to use O_TMPFILE
there. But to me this seems less ideal then the Android approach, where
the lifecycle of the tmpfs fds more limited and clear.

And my main point being: Both Android's ashmem and kdbus' memfds are
both utilizing these semantics (though maybe they aren't as
important/intentional for kdbus?), so it seems like some generic method
(which would work in both environments) would generally useful.

Again, I really do appreciate your feedback here, and I don't mean to be
panning your idea (I'm quite willing to look further into it if others
think its the right way)! I just want to explain my point of view and
motivations a bit better.

thanks!
-john



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
