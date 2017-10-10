Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 662176B0260
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 14:11:18 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id h7so4363044qth.13
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 11:11:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 61si1861497qta.149.2017.10.10.11.11.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 11:11:17 -0700 (PDT)
Subject: Re: Questions about commit "ipc/shm: Fix shmat mmap nil-page
 protection"
References: <472dbcaa-47b5-7a1b-7c4a-49373db784d3@redhat.com>
 <20170925214438.GU31084@redhat.com>
From: Joe Lawrence <joe.lawrence@redhat.com>
Message-ID: <0d910579-ddef-23c5-7f9c-8393cc4babc1@redhat.com>
Date: Tue, 10 Oct 2017 14:11:11 -0400
MIME-Version: 1.0
In-Reply-To: <20170925214438.GU31084@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 09/25/2017 05:44 PM, Andrea Arcangeli wrote:
> Hello,
> 
> On Mon, Sep 25, 2017 at 03:38:07PM -0400, Joe Lawrence wrote:
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
> Yes, thanks for the accurate summary Joe.
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
> We identified only one positive side effect to such change, it is
> about the semantics of SHM_REMAP when addr < shmlba (and != 0). Before
> the patch SHM_REMAP was erroneously implicit for that virtual
> range. However that's not security related either, and there's no
> mention of SHM_REMAP in the commit message.
> 
> So then we wondered what this CVE is about in the first place, it
> looks a invalid CVE for a not existent security issue. The testcase at
> least shows no malfunction, mapping addr 0 is fine to succeed with
> CAP_SYS_RAWIO.
> 
> From the commit message, testcase and CVE I couldn't get what this
> commit is about.
> 
> Last but not the least, if there was a security problem in calling
> do_mmap_pgoff with addr=0, flags=MAP_FIXED|MAP_SHARED the fix would
> better be moved to do_mmap_pgoff, not in ipc/shm.c.

Gentle ping.

-- Joe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
