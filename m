Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC1A36B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 13:36:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e20so8252903pff.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 10:36:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u20-v6si6502741pgo.294.2018.04.30.10.36.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Apr 2018 10:36:18 -0700 (PDT)
Date: Mon, 30 Apr 2018 10:21:52 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: Questions about commit "ipc/shm: Fix shmat mmap nil-page
 protection"
Message-ID: <20180430172152.nfa564pvgpk3ut7p@linux-n805>
References: <472dbcaa-47b5-7a1b-7c4a-49373db784d3@redhat.com>
 <20170925214438.GU31084@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170925214438.GU31084@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Joe Lawrence <joe.lawrence@redhat.com>, akpm@linux-foundation.org, gareth.evans@contextis.co.uk, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, 25 Sep 2017, Andrea Arcangeli wrote:

Sorry this took so long guys. I had forgotten about this until it recently
resurfaced.

>Hello,
>
>On Mon, Sep 25, 2017 at 03:38:07PM -0400, Joe Lawrence wrote:
>> Hi Davidlohr,
>>
>> I was looking into backporting commit 95e91b831f87 ("ipc/shm: Fix shmat
>> mmap nil-page protection") to a distro kernel and Andrea brought up some
>> interesting questions about that change.
>>
>> We saw that a LTP test [1] was added some time ago to reproduce behavior
>> matching that of the original report [2].  However, Andrea and I are a
>> little confused about that original report and what the upstream commit
>> was intended to fix.  A quick summary of our offlist discussion:
>>
>> - This is only about privileged users (and no SELinux).
>>
>> - We modified the 20170119_shmat_nullpage_poc.c reproducer from [2] to
>>   include MAP_FIXED to prove (as root, no SELinux):
>>
>>     It is possible to mmap 0
>>     It is NOT possible to mmap 1
>>
>> - Andrea points out that mmap(1, ...) fails not because of any
>>   mmap_min_addr checks, but for alignment reasons.
>>
>> - He also wonders about other bogus addr values above 4k, but below
>>   mmap_min_addr and whether this change misses those values
>
>Yes, thanks for the accurate summary Joe.
>
>> Is it possible that the original report noticed that shmat allowed
>> attach to an address of 1, and it was assumed that somehow mmap_min_addr
>> protections were circumvented?  Then commit 95e91b831f87 modified the
>> rounding in do_shmat() so that shmat would fail on similar input (but
>> for apparently different reasons)?
>>
>> I didn't see any discussion when looking up the original commit in the
>> list archives, so any explanations or pointers would be very helpful.
>
>We identified only one positive side effect to such change, it is
>about the semantics of SHM_REMAP when addr < shmlba (and != 0). Before
>the patch SHM_REMAP was erroneously implicit for that virtual
>range. However that's not security related either, and there's no
>mention of SHM_REMAP in the commit message.

Coincidence. I didn't notice the SHM_REMAP, but after looking at it
you appear to be right. I'll send a patch along with the revert
(see below).

>
>So then we wondered what this CVE is about in the first place, it
>looks a invalid CVE for a not existent security issue. The testcase at
>least shows no malfunction, mapping addr 0 is fine to succeed with
>CAP_SYS_RAWIO.

This is exactly the issue. I thought mapping addr=0 with MAP_FIXED
was an issue, including for root. Hence avoiding the round off from
1 to 0. If this is legal, then this commit needs reverted.

In fact, X11[1] seems to rely on this _exact_ case; and this change
breaks semantics.

>
>From the commit message, testcase and CVE I couldn't get what this
>commit is about.
>
>Last but not the least, if there was a security problem in calling
>do_mmap_pgoff with addr=0, flags=MAP_FIXED|MAP_SHARED the fix would
>better be moved to do_mmap_pgoff, not in ipc/shm.c.

Yeah at the time, akpm and I wondered why this was special to security.

[1] https://cgit.freedesktop.org/xorg/xserver/tree/hw/xfree86/os-support/linux/int10/linux.c#n347

Thanks,
Davidlohr
