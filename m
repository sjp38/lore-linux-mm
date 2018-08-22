Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4CE0E6B24E5
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 10:46:52 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g11-v6so1021102edi.8
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 07:46:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f15-v6si145502edf.160.2018.08.22.07.46.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 07:46:50 -0700 (PDT)
Date: Wed, 22 Aug 2018 07:46:40 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: using range locks instead of mm_sem
Message-ID: <20180822144640.GB3677@linux-r8p5>
References: <9ea84ad8-0404-077e-200d-14ad749cb784@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <9ea84ad8-0404-077e-200d-14ad749cb784@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shady Issa <shady.issa@oracle.com>
Cc: Alex Kogan <alex.kogan@oracle.com>, Dave Dice <dave.dice@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, ldufour@linux.vnet.ibm.com, jack@suse.com, linux-mm@kvack.org

On Wed, 22 Aug 2018, Shady Issa wrote:

>
>Hi Davidlohr,
>
>I am interested in the idea of using range locks to replace mm_sem. I 
>wanted to
>start trying out using more fine-grained ranges instead of the full 
>range acquisitions
>that are used in this patch (https://lkml.org/lkml/2018/2/4/235). 
>However, it does not
>seem straight forward to me how this is possible.
>
>First, the ranges that can be defined before acquiring the range lock 
>based on the
>caller's input(i.e. ranges supplied by mprotect, mmap, munmap, etc.) 
>are oblivious of
>the underlying VMAs. Two non-overlapping ranges can fall within the 
>same VMA and
>thus should not be allowed to run concurrently in case they are writes.

Yes. This is a _big_ issue with range locking the addr space. I have yet
to find a solution other than delaying vma modifying ops to avoid the races,
which is fragile. Obviously locking the full range in such scenarios cannot
be done either.

>
>Second, even if ranges from the caller function are aligned with VMAs, 
>the extent of the
>effect of operation is unknown. It is probable that an operation 
>touching one VMA will
>end up performing modifications to the VMAs rbtree structure due to 
>splits, merges, etc.,
>which requires the full range acquisition and is unknown beforehand.

Yes, this is similar to the above as well.

>
>I was wondering if I am missing something with this thought process, 
>because with the
>current givings, it seems to me that range locks will boil down to 
>just r/w semaphore.
>I would also be very grateful if you can point me to any more recent 
>discussions regarding
>the use of range locks after this patch from February.

You're on the right page.

Thanks,
Davidlohr
