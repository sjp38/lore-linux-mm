Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5002A6B025E
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 12:07:05 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id m203so303982965iom.6
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 09:07:05 -0800 (PST)
Received: from mail-io0-x244.google.com (mail-io0-x244.google.com. [2607:f8b0:4001:c06::244])
        by mx.google.com with ESMTPS id y196si2775153itb.101.2016.11.29.09.07.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 09:07:04 -0800 (PST)
Received: by mail-io0-x244.google.com with SMTP id j92so30748014ioi.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 09:07:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161129163406.treuewaqgt4fy4kh@merlins.org>
References: <20161121154336.GD19750@merlins.org> <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org> <20161122160629.uzt2u6m75ash4ved@merlins.org>
 <48061a22-0203-de54-5a44-89773bff1e63@suse.cz> <CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com>
 <20161123063410.GB2864@dhcp22.suse.cz> <20161128072315.GC14788@dhcp22.suse.cz>
 <20161129155537.f6qgnfmnoljwnx6j@merlins.org> <20161129160751.GC9796@dhcp22.suse.cz>
 <20161129163406.treuewaqgt4fy4kh@merlins.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 29 Nov 2016 09:07:03 -0800
Message-ID: <CA+55aFzNe=3e=cDig+vEzZS5jm2c6apPV4s5NKG4eYL4_jxQjQ@mail.gmail.com>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc MERLIN <marc@merlins.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Tue, Nov 29, 2016 at 8:34 AM, Marc MERLIN <marc@merlins.org> wrote:
> Now, to be fair, this is not a new problem, it's just varying degrees of
> bad and usually only happens when I do a lot of I/O with btrfs.

One situation where I've seen something like this happen is

 (a) lots and lots of dirty data queued up
 (b) horribly slow storage
 (c) filesystem that ends up serializing on writeback under certain
circumstances

The usual case for (b) in the modern world is big SSD's that have bad
worst-case behavior (ie they may do gbps speeds when doing well, and
then they come to a screeching halt when their buffers fill up and
they have to do rewrites, and their gbps throughput drops to mbps or
lower).

Generally you only find that kind of really nasty SSD in the USB stick
world these days.

The usual case for (c) is "fsync" or similar - often on a totally
unrelated file - which then ends up waiting for everything else to
flush too. Looks like btrfs_start_ordered_extent() does something kind
of like that, where it waits for data to be flushed.

The usual *fix* for this is to just not get into situation (a).

Sadly, our defaults for "how much dirty data do we allow" are somewhat
buggered. The global defaults are in "percent of memory", and are
generally _much_ too high for big-memory machines:

    [torvalds@i7 linux]$ cat /proc/sys/vm/dirty_ratio
    20
    [torvalds@i7 linux]$ cat /proc/sys/vm/dirty_background_ratio
    10

says that it only starts really throttling writes when you hit 20% of
all memory used. You don't say how much memory you have in that
machine, but if it's the same one you talked about earlier, it was
24GB. So you can have 4GB of dirty data waiting to be flushed out.

And we *try* to do this per-device backing-dev congestion thing to
make things work better, but it generally seems to not work very well.
Possibly because of inconsistent write speeds (ie _sometimes_ the SSD
does really well, and we want to open up, and then it shuts down).

One thing you can try is to just make the global limits much lower. As in

   echo 2 > /proc/sys/vm/dirty_ratio
   echo 1 > /proc/sys/vm/dirty_background_ratio

(if you want to go lower than 1%, you'll have to use the
"dirty_*ratio_bytes" byte limits instead of percentage limits).

Obviously you'll need to be root for this, and equally obviously it's
really a failure of the kernel. I'd *love* to get something like this
right automatically, but sadly it depends so much on memory size,
load, disk subsystem, etc etc that I despair at it.

On x86-32 we "fixed" this long ago by just saying "high memory is not
dirtyable", so you were always limited to a maximum of 10/20% of 1GB,
rather than the full memory range. It worked better, but it's a sad
kind of fix.

(See commit dc6e29da9162: "Fix balance_dirty_page() calculations with
CONFIG_HIGHMEM")

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
