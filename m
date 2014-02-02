Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7FE7B6B0031
	for <linux-mm@kvack.org>; Sun,  2 Feb 2014 01:29:55 -0500 (EST)
Received: by mail-vc0-f178.google.com with SMTP id ik5so3933252vcb.23
        for <linux-mm@kvack.org>; Sat, 01 Feb 2014 22:29:55 -0800 (PST)
Received: from mail-ve0-f169.google.com (mail-ve0-f169.google.com [209.85.128.169])
        by mx.google.com with ESMTPS id tj7si5583654vdc.72.2014.02.01.22.29.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 01 Feb 2014 22:29:54 -0800 (PST)
Received: by mail-ve0-f169.google.com with SMTP id oy12so4244226veb.0
        for <linux-mm@kvack.org>; Sat, 01 Feb 2014 22:29:54 -0800 (PST)
MIME-Version: 1.0
From: Andy Lutomirski <luto@amacapital.net>
Date: Sat, 1 Feb 2014 22:29:34 -0800
Message-ID: <CALCETrVpoMXJ59R6=wa8rPi_ELc5dnkpGFXC72OApa0ooZc1fg@mail.gmail.com>
Subject: dm-crypt unpleasantness during heavy write loads and memory pressure?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux FS Devel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, dm-devel@redhat.com

I've seen a number of anomalies across a few machines.  All of them
have dm-crypt in common.

The most recent example was on Linux 3.8.  I have dm-crypt on top of
hpsa hardware RAID.  (I don't have a whole lot of confidence in hpsa's
performance, but I've seen similar issues on other machines, so this
may not be hpsa's fault.)  I did a big MySQL update.  The update took
a shockingly long time (it took longer than an identical query on a
replica on a much slower machine) and, while it was running, the
machine was basically unusable.

Here's a hypothesis:

dm-crypt appears to take incoming write bios, clone them, allocate
pages for a copy of the data, encrypt the data, and then submit to the
lower layer.  The lower layer (e.g. hpsa's queue) then sorts, merges,
and does real I/O.

Let's suppose that the actual crypto is nice and fast (on this box,
I'm using XTS with AES-NI on seven logical cores at 3.5 GHz), but that
the disks are not quite so impressive (3x 7200rpm SATA drives on
RAID5).  The machine has 16 GB of RAM.  MySQL is I/O-bound.

So... what happens?  If MySQL is willing to queue up a very large
number of writes (which is probably is -- this was one giant
transaction, so MySQL wouldn't need to flush until it filled up all
available buffers), there are only three places that those bios can
wait.  They can wait in dm-crypt's queue (which is unlikely -- AES-NI
is fast), they can block in dm-crypt waiting for free memory, or they
can block on the lower layer's queue.

None of these options are good.  Requests on the lower layer's queue
can be sorted, but they're keeping an entire extra copy of the data
pinned in kernel memory.  (I have no idea how well the writeback
algorithms can handle very large amounts of memory being in use by the
kernel.)  Requests on dm-crypt's queue cannot be intelligently sorted,
causing throughput to drop (which is only going to make the problem
worse).

So... is this a real problem?  Should I blame dm-crypt for stalls
under heavy write load?


I suppose that the situation could be improved if there was a way for
dm-crypt to remap the sector range immediately but defer encryption
until the lower device's queue is nearly ready to submit the IO.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
