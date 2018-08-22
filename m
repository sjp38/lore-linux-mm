Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3216B249B
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 09:38:50 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id p22-v6so1505677ioh.7
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 06:38:50 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id m69-v6si1323425itm.92.2018.08.22.06.38.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 06:38:49 -0700 (PDT)
From: Shady Issa <shady.issa@oracle.com>
Subject: using range locks instead of mm_sem
Message-ID: <9ea84ad8-0404-077e-200d-14ad749cb784@oracle.com>
Date: Wed, 22 Aug 2018 09:51:19 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@stgolabs.net
Cc: Alex Kogan <alex.kogan@oracle.com>, Dave Dice <dave.dice@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, ldufour@linux.vnet.ibm.com, jack@suse.com, linux-mm@kvack.org


Hi Davidlohr,

I am interested in the idea of using range locks to replace mm_sem. I 
wanted to
start trying out using more fine-grained ranges instead of the full 
range acquisitions
that are used in this patch (https://lkml.org/lkml/2018/2/4/235). 
However, it does not
seem straight forward to me how this is possible.

First, the ranges that can be defined before acquiring the range lock 
based on the
caller's input(i.e. ranges supplied by mprotect, mmap, munmap, etc.) are 
oblivious of
the underlying VMAs. Two non-overlapping ranges can fall within the same 
VMA and
thus should not be allowed to run concurrently in case they are writes.

Second, even if ranges from the caller function are aligned with VMAs, 
the extent of the
effect of operation is unknown. It is probable that an operation 
touching one VMA will
end up performing modifications to the VMAs rbtree structure due to 
splits, merges, etc.,
which requires the full range acquisition and is unknown beforehand.

I was wondering if I am missing something with this thought process, 
because with the
current givings, it seems to me that range locks will boil down to just 
r/w semaphore.
I would also be very grateful if you can point me to any more recent 
discussions regarding
the use of range locks after this patch from February.

Best regards
Shady Issa
