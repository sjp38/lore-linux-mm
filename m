Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 7647E6B0070
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 19:31:23 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id t2so12850521qcq.14
        for <linux-mm@kvack.org>; Wed, 28 Nov 2012 16:31:22 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 28 Nov 2012 16:31:22 -0800
Message-ID: <CAA25o9S5zpH_No+xgYuFSAKSRkQ=19Vf_aLgO1UWiajQxtjrpg@mail.gmail.com>
Subject: zram, OOM, and speed of allocation
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>

I am beginning to understand why zram appears to work fine on our x86
systems but not on our ARM systems.  The bottom line is that swapping
doesn't work as I would expect when allocation is "too fast".

In one of my tests, opening 50 tabs simultaneously in a Chrome browser
on devices with 2 GB of RAM and a zram-disk of 3 GB (uncompressed), I
was observing that on the x86 device all of the zram swap space was
used before OOM kills happened, but on the ARM device I would see OOM
kills when only about 1 GB (out of 3) was swapped out.

I wrote a simple program to understand this behavior.  The program
(called "hog") allocates memory and fills it with a mix of
incompressible data (from /dev/urandom) and highly compressible data
(1's, just to avoid zero pages) in a given ratio.  The memory is never
touched again.

It turns out that if I don't limit the allocation speed, I see
premature OOM kills also on the x86 device.  If I limit the allocation
to 10 MB/s, the premature OOM kills stop happening on the x86 device,
but still happen on the ARM device.  If I further limit the allocation
speed to 5 Mb/s, the premature OOM kills disappear also from the ARM
device.

I have noticed a few time constants in the MM whose value is not well
explained, and I am wondering if the code is tuned for some ideal
system that doesn't behave like ours (considering, for instance, that
zram is much faster than swapping to a disk device, but it also uses
more CPU).  If this is plausible, I am wondering if anybody has
suggestions for changes that I could try out to obtain a better
behavior with a higher allocation speed.

Thanks!
Luigi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
