Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f47.google.com (mail-oa0-f47.google.com [209.85.219.47])
	by kanga.kvack.org (Postfix) with ESMTP id 76E4D6B005A
	for <linux-mm@kvack.org>; Sat,  8 Feb 2014 14:43:23 -0500 (EST)
Received: by mail-oa0-f47.google.com with SMTP id m1so5765070oag.20
        for <linux-mm@kvack.org>; Sat, 08 Feb 2014 11:43:23 -0800 (PST)
Received: from mail-oa0-x22f.google.com (mail-oa0-x22f.google.com [2607:f8b0:4003:c02::22f])
        by mx.google.com with ESMTPS id p8si4919989oeq.56.2014.02.08.11.43.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 08 Feb 2014 11:43:22 -0800 (PST)
Received: by mail-oa0-f47.google.com with SMTP id m1so5793117oag.34
        for <linux-mm@kvack.org>; Sat, 08 Feb 2014 11:43:22 -0800 (PST)
MIME-Version: 1.0
Reply-To: for.poige+linux@gmail.com
From: Igor Podlesny <for.poige+linux@gmail.com>
Date: Sun, 9 Feb 2014 03:42:52 +0800
Message-ID: <CA+sTkh7LzDSvhDyYX2Ybi=Z32OuJoK_F1VVHEBsW5Ly-4wa8Bg@mail.gmail.com>
Subject: Re: That greedy Linux VM cache
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 3 February 2014 18:55, Michal Hocko <mhocko@suse.cz> wrote:
> [Adding linux-mm to the CC]

[...]

> This means that the page has to be written back in order to be dropped.
> How much dirty memory you have (comparing to the total size of the page
> cache)?

   Not too many. May be you missed that part, but I said, that disk is
being mostly READ, NOT written.
   I also said, that READing is going from system partition (it was Btrfs).

> What does your /proc/sys/vm/dirty_ratio say?

   10

> How fast is your storage?

   Was 5400 HDD, today I installed SSD.

> Also, is this 32b or 64b system?

   Kernel is x86_64 or sometimes 32, userspace is 32 -- full x86_64
setup is simply not usable on 2 GiB,
you can run just one program, like in MS-DOS era. :) (I'd give a try
to x32, but alas, it's not really ready yet.)

>>    * How to analyze it? slabtop doesn't mention even 100 MiB of slab
>
> snapshoting /proc/meminfo and /proc/vmstat every second or two while
> your load is bad might tell us more.
>
>>    * Why that's possible?
>
> That is hard to tell withou some numbers. But it might be possible that
> you are seeing the same issue as reported and fixed here:
> http://marc.info/?l=linux-kernel&m=139060103406327&w=2

   No, there's no such amount of dirty data.

> Especially when you are using tmpfs (e.g. as a backing storage for /tmp)

   I use it, yeah, but it has ridiculously low occupied space ~ 1--2 MiB.

   *** Okay, so I've said I decided to try SSD. The issue stays
absolutely the same and is seen even more clearer: when swappiness is
0, Btrfs-endio is heating up processor constantly taking almost all
CPU resources (storage is fast, CPU's saturated), but when I set it
higher, thus allowing to swap, it helps -- ~ 250 MiB got swapped out
(quickly -- SSD rules) and the system became responsive again. As
previously it didn't try to reduce cache at all. I never saw it to be
even 250 MiB, always higher (~ 25 % of RAM). So, actually it's better
using swappiness = 100 in these circumstances.

   I think the problem should be easily reproducible -- kernel allows
you to limit available RAM. ;)

   P. S. The only thing's left as a theory is "Intel Corporation
Mobile GM965/GL960 Integrated Graphics Controller" with i915 kernel
module. I don't know much about it, but it should have had bitten a
good part of system RAM, right? Since it's Ubuntu, there's compiz by
default and pmap -d `pgrep compiz` shows lots of similar lines:

...
e0344000      20 rw-s- 0000000102e33000 000:00005 card0
e0479000      56 rw-s- 0000000102bf4000 000:00005 card0
e0487000      48 rw-s- 0000000102be8000 000:00005 card0
e0493000      56 rw-s- 0000000102bda000 000:00005 card0
e04a1000      56 rw-s- 0000000102bcc000 000:00005 card0
e04af000      48 rw-s- 0000000102bc0000 000:00005 card0
e04bb000      56 rw-s- 0000000102bb2000 000:00005 card0
e04c9000      48 rw-s- 0000000102d64000 000:00005 card0
e04d5000     192 rw-s- 0000000102ce5000 000:00005 card0
e0505000      80 rw-s- 0000000102de7000 000:00005 card0
e0519000      20 rw-s- 0000000102ccc000 000:00005 card0
e051e000     160 rw-s- 0000000102ca4000 000:00005 card0
e0546000      20 rw-s- 0000000102c9f000 000:00005 card0
e054b000      48 rw-s- 0000000102c93000 000:00005 card0
e0557000      20 rw-s- 0000000102c8e000 000:00005 card0
e055c000      20 rw-s- 0000000102c89000 000:00005 card0
...

   I have a suspicion... (I also dislike the sizes of those mappings)
... that a valuable amount of that "cached memory" can be related to
this i915. How can I check it?...

-- 
End of message. Next message?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
