Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 520496B0038
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 18:25:20 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so39236752pdb.2
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 15:25:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qj4si41823401pac.218.2015.06.24.15.25.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jun 2015 15:25:19 -0700 (PDT)
Date: Wed, 24 Jun 2015 15:25:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: extremely long blockages when doing random writes to SSD
Message-Id: <20150624152518.d3a5408f2bde405df1e6e5c4@linux-foundation.org>
In-Reply-To: <CAA25o9SCnDYZ6vXWQWEWGDiwpV9rf+S_3Np8nJrWqHJ1x6-kMg@mail.gmail.com>
References: <CAA25o9SCnDYZ6vXWQWEWGDiwpV9rf+S_3Np8nJrWqHJ1x6-kMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>

On Wed, 24 Jun 2015 14:54:09 -0700 Luigi Semenzato <semenzato@google.com> wrote:

> Greetings,
> 
> we have an app that writes 4k blocks to an SSD partition with more or
> less random seeks.  (For the curious: it's called "update engine" and
> it's used to install a new Chrome OS version in the background.)  The
> total size of the writes can be a few hundred megabytes.  During this
> time, we see that other apps, such as the browser, block for seconds,
> or tens of seconds.
> 
> I have reproduced this behavior with a small program that writes 2GB
> worth of 4k blocks randomly to the SSD partition.  I can get apps to
> block for over 2 minutes, at which point our hang detector triggers
> and panics the kernel.
> 
> CPU: Intel Haswell i7
> RAM: 4GB
> SSD: 16GB SanDisk
> kernel: 3.8
> 
> >From /proc/meminfo I see that the "Buffers:" entry easily gets over
> 1GB.  The problem goes away completely, as expected, if I use O_SYNC
> when doing the random writes, but then the average size of the I/O
> requests goes down a lot, also as expected.
> 
> First of all, it seems that there may be some kind of resource
> management bug.  Maybe it has been fixed in later kernels?  But, if
> not, is there any way of encouraging some in-between behavior?  That
> is, limit the allocation of I/O buffers to a smaller amount, which
> still give the system a chance to do some coalescing, but perhaps
> avoid the extreme badness that we are seeing?
> 

What kernel version?

Are you able to share that little test app with us?

Which filesystem is being used and with what mount options etc?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
