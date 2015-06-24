Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 52A556B0038
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 17:54:10 -0400 (EDT)
Received: by oigb199 with SMTP id b199so39737678oig.3
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 14:54:10 -0700 (PDT)
Received: from mail-ob0-x229.google.com (mail-ob0-x229.google.com. [2607:f8b0:4003:c01::229])
        by mx.google.com with ESMTPS id h129si18297620oia.93.2015.06.24.14.54.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jun 2015 14:54:09 -0700 (PDT)
Received: by obbop1 with SMTP id op1so35517094obb.2
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 14:54:09 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 24 Jun 2015 14:54:09 -0700
Message-ID: <CAA25o9SCnDYZ6vXWQWEWGDiwpV9rf+S_3Np8nJrWqHJ1x6-kMg@mail.gmail.com>
Subject: extremely long blockages when doing random writes to SSD
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>

Greetings,

we have an app that writes 4k blocks to an SSD partition with more or
less random seeks.  (For the curious: it's called "update engine" and
it's used to install a new Chrome OS version in the background.)  The
total size of the writes can be a few hundred megabytes.  During this
time, we see that other apps, such as the browser, block for seconds,
or tens of seconds.

I have reproduced this behavior with a small program that writes 2GB
worth of 4k blocks randomly to the SSD partition.  I can get apps to
block for over 2 minutes, at which point our hang detector triggers
and panics the kernel.

CPU: Intel Haswell i7
RAM: 4GB
SSD: 16GB SanDisk
kernel: 3.8

>From /proc/meminfo I see that the "Buffers:" entry easily gets over
1GB.  The problem goes away completely, as expected, if I use O_SYNC
when doing the random writes, but then the average size of the I/O
requests goes down a lot, also as expected.

First of all, it seems that there may be some kind of resource
management bug.  Maybe it has been fixed in later kernels?  But, if
not, is there any way of encouraging some in-between behavior?  That
is, limit the allocation of I/O buffers to a smaller amount, which
still give the system a chance to do some coalescing, but perhaps
avoid the extreme badness that we are seeing?

Thank you for any insight!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
