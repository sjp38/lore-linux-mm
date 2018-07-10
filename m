Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 10FA96B0007
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 08:08:00 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w21-v6so9498003wmc.6
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 05:08:00 -0700 (PDT)
Received: from mail.nethype.de (mail.nethype.de. [5.9.56.24])
        by mx.google.com with ESMTPS id t11-v6si17309058wre.25.2018.07.10.05.07.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Jul 2018 05:07:57 -0700 (PDT)
Date: Tue, 10 Jul 2018 14:07:56 +0200
From: Marc Lehmann <schmorp@schmorp.de>
Subject: post linux 4.4 vm oom kill, lockup and thrashing woes
Message-ID: <20180710120755.3gmin4rogheqb3u5@schmorp.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@kernel.org>

(I am not subscribed)

Hi!

While reporting another (not strictly related) kernel bug
(https://bugzilla.kernel.org/show_bug.cgi?id=3D199931) I was encouraged to
report my problem here, even though, in my opinion, I don't have enough
hard data for a good bug report, so bear with me, please.

Basically, the post 4.4 VM system (I think my troubles started around 4.6
or 4.7) is nearly unusable on all of my (very different) systems that
actually do some work, with symptoms being frequent OOM kills with many
gigabytes of available memory, extended periods of semi-freezing with
thrashing, and apparent hard lockups, almost certainly related to memory
usage.

I have experienced this with both debians and ubuntus precompiled kernels
(4.9 being the most unstable for me) as well as with my own. Booting 4.4
makes the problems go away in all cases.

Since I kept losing my logs due to the other kernel bug caused by my
workaround, I don't have a lot of good logs, so this is mostly anecdotal,
but I hope this is of some use, especially since I found a workaround for
each case that reduces or alleviates the problem, and so might shed some
light on the underlying issue(s).

I present three "case studies" of how I can create/trigger these problems
on three very different systems, a server, a desktop, and a very old
memory-starved laptop, all of which becomes close to unusable for daily
work under post 4.4 kernels.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
Case #1, the home server, frequent unexpected oom kills
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D

The first system is a server which does a lot of heavy lifting with a lot
of data (>60TB of disk, a lot of activity). It has 32GB of RAM, and almost
never uses more than 8GB of it, the rest usually being disk cache, e.g.:

		  total        used        free      shared  buff/cache   available
    Mem:       32888772     1461060      813500       13740    30614212    =
30956016
    Swap:       4194300       54016     4140284

Under 4.4, it runs "mostly" rock stable. With debian's 4.9, mysql usually
is killed within a single night. 4.14 is much better, but when doing
backups or other memory intensive jobs, it usually gets killed. Many
times. Usually with >>16GB of "available" memory that linux could use
instead, if it weren't so fragmented or it could free some of it.

Here are some oom reports, all happened during my nightly backup, under
4.14.33:

    http://data.plan9.de/oom-mysql-4.14-201806.txt

This specific OOM kill series happened during backup, which mainly does a
lot of stat() calls (as in, a hundred million+), but while this helps
triggering oom killls, it is by no means the required trigger.

I lost all of the previous OOM kill reports, but AFAICR, they are
invariably caused by higher order allocations, often by the nvidia driver,
which just loves higher order allocations, but they do happen with other
subsystems (such as btrfs) too, and were often triggered by measly order 1
allocations as well.

I have tried various workarounds, and under 4.14, I found that doing this
every hour or so greatly reduced the oom kills (and unfortunately also
causes file corruptiopn, but that's unrelated :):

    echo 1 > /proc/sys/vm/drop_caches

I have tried various other things that didn't work: "echo 1
>/proc/sys/vm/compact_memory", every minute, increasing min_free_kbytes,
setting swappiness to 1 or 100, setting vfs_cache_pressure to 50 or 150
reducing extfrag_threshold.

Clearly, the server has enough memory, but linux has enourmous troubles
making use of it under 4.6+ (or so), while it works fine under
4.4. Naively speaking, linux should obviously drop some cache rather than
drop dead some processes, although I am aware that things are not as
simple as that especially when fragmentation is involved.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
Case #2, my work desktop, frequent unexpected oom kills, frequent lockups
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D

My work desktop (16GB RAM) also suffers from the same problems as my home
server, with chromium usually being the thing that gets killed first, due
to it's increased oom_score_adjust value, which made me run chromium more
often as a sacrifice process. Clearly a bad thing.

However, under post-4.4 kernels, I also have frequent freezes, which seem
to be hard lockups (I did let it run for 5 to 15 minutes a few times, and
it didn't sem to recover - maybe it's thrashing to the SSD, but I can't
hear that :).

I found a pretty reliable way to get OOM kills or freezes (but they
happen on their own as well, just not as reproducible): mmap a large
file. I have written a simple nbd-based caching program that writes dirty
write data to a separate log file, to be applied later. While it lets
me reproduce the freezes, I don't know if that is the only cause, as I
don't run this cache program very often, but get a lockup every few days
regardless, depending on how heavy I use this machine.

This is a simple simulation of what the cache program does to cause the
problem:

    http://data.plan9.de/mmap-problem-testcase

What this does is create a large 35GB file, mmap it, and then read through
the mappped region, i.e. page it into memory.

Situation before:

		  total        used        free      shared  buff/cache   available
    Mem:       16426820     2455612     1872868       11200    12098340    =
13623920
    Swap:       8388604       26368     8362236

Situation after starting the problem, when it hangs in sleep 9999:

    7ff72e8e2000-7fffee8e2000 rw-s 00000000 00:17 3746909                  =
  /cryptroot/test
    Size:           36700160 kB
    KernelPageSize:        4 kB
    MMUPageSize:           4 kB
    Rss:             7886400 kB
    Pss:             7886400 kB
    Shared_Clean:          0 kB
    Shared_Dirty:          0 kB
    Private_Clean:   7886400 kB
    Private_Dirty:         0 kB
    Referenced:      7886400 kB
    Anonymous:             0 kB
    LazyFree:              0 kB
    AnonHugePages:         0 kB
    ShmemPmdMapped:        0 kB
    Shared_Hugetlb:        0 kB
    Private_Hugetlb:       0 kB
    Swap:                  0 kB
    SwapPss:               0 kB
    Locked:          7886400 kB
    VmFlags: rd wr sh mr mw me ms sd

		  total        used        free      shared  buff/cache   available
    Mem:       16426820     2391784     5845592        7888     8189444    =
13734508
    Swap:       8388604       26368     8362236

So, not much changed here one would think, just a bunch of clean pages
that could be freed when memory is needed. Maybe it's notworthy that
I have 8GB buff/cache despite issueing a drop_caches, most of which I
suspect is the non-dirty mmap area.

However, starting kvm with a 8GB memory size in this situation instantly
freezes my box, when it should just work:

   kvm -m 8000 ...

Which is unexpected, with 13GB of "available" memory.

(don't get confused by the Locked: value, since change
493b0e9d945fa9dfe96be93ae41b4ca4b6fdb317, linux always reports Locked
=3D=3D Pss. I've emailed dancol@google.com about this but never got a
response. There is no mlocking involved, and this confused the heck out of
me for a while).

There is an easy way to make it not freeze: unmap the file, and
immediately mmap it again, which makes all those Private_Clean pages go
away and makes my actual caching program usable, which only has to scan
through the file once during start up and afterwards only has to touch
random pages within.

So, linux 4.14 has trouble freeing these pages, even though they are not
dirty, and instead effectively freezes.

This happens with the mmapped file both on XFS-on-lvm and
BTRFS-on-dmcrypt-on-dmcache-on-lvm, so doesn't seem to be a specific fs
issue.

Another workaround is to create smaller but increasingly sized processes,
e.g.:

   perl -e '1 x 1_000_000_000'
   perl -e '1 x 2_000_000_000'
   perl -e '1 x 4_000_000_000'
   perl -e '1 x 6_000_000_000'
   perl -e '1 x 8_000_000_000'

This manages to recover the "lost" memory somewhat, after which I am able
to start my 8GB vm without causing a freeze:

    7ff72e8e2000-7fffee8e2000 rw-s 00000000 00:17 3746909                  =
  /cryptroot/test
    Size:           36700160 kB
    Rss:             5583036 kB
    Pss:             5583036 kB
    Private_Clean:   5583036 kB
    Referenced:      5583036 kB

The Pss size also reduces slowly over time during normal activity, so
it's clearly not locked by the kernel. The kernel is merely setting its
priorities to freeze rather than free it quickly :)

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
Case #3, the 10 year old laptop, thrashing semi freezes
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D

The last case I present is the laptop at my bed with 2GB of RAM and
8GB of swap. It's used for image/movie viewing, e-book-reading and
firefoxing. The root filesystem is sometimes on a 4GB USB stick and
sometimes on a 16GB SD card, and it has a somewhat broken 32GB SSD used
exclusively for swapping and a dmcache. I know it's weird, but it works.

It's not doing any heavy work, but it uses a lot more memory than it has
RAM for. Its quite amazing: under 4.4, despite constantly using 2+GB
of swap (typically 3.5GB swap is in use), it works _very well_ indeed,
with only occasional split-second pauses due to swapping when switching
desktops for example.

Under 4.14, it freezes for 5-10 minutes every few minutes, but always
recovers. Mouse pointer moves a bit every minuite or so when I am
lucky. So not fun to use when all you wanted to do is to flip pages in
fbreader and suddenly have to pause for 10 minutes. And no, I am not
exaggerating, I stopped it a few times and it really hangs for this long
every few minutes.

While it freezes, there is heavy disk activity. Looking at dstat output
afterwards, it is clear that there is little to no write activity, and all
read activity is to the root filesystem, not swap. swap almost doesn't get
used under 4.14 on this box.

=46rom the little data I have, I would guess that linux runs out of
memory and then throws away code pages, just to immediatelly read them
again. This would explain the heavy read-only disk activity and also why
the box is more or less frozen during these episodes, it's in classic full
thrashing mode.

No amount of tinkering with /proc/sys/vm seems to make a difference (I
owuld have hoped setting swappiness to 100 to help, but nope), but I did
find a workaround that almost completely fixes the problem... wait for
it...

   while sleep 10; do perl -e '1 x 300_000_000';done

i.e., create a dummy 300MB process every 10 seconds. I have no clue why
this works, but it changes the behaviour drastically:

    1. swap gets used, not as aggressively as under 4.4, but it does get us=
ed
    2. the box thrash-freezes much less often
    3. if it freezes, it usually recovers after 1-2 minutes, and the mouse
       pointer sometimes moves as well during this time. yay.

It also is very similar to my workaround on my desktop box, although the
mix of programs I run is very different and the memory situation is very
different. Still, I feel linux on my other boxes is just as reluctant to
use swap and rather oom kills or freezes instead.

4.4 in the same box with exactly the same root filesystem has none of
these problems, it simply swaps out stuff when memory gets tight.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
Summary
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D

So, while this is mostly anecdotal, I think there is a real issue with
post 4.4 kernels. Given the wide range of configurations I run into memory
issues, I think this is not an isolated hardware or config issue, some of
these problems I can reproduce with a debian boot cd as well, so it's not
anything in my config.

I found that around 4.8-4.9 the behaviour was worst - 4.9 makes trouble on
most of my boxes, not just these three, while 4.14 is greatly improved and
works fine on a lot of much more idle servers I have.

I hope this is somewhat useful in finding this issue. Thanks for staying
with me and reading this :)

If requested, I can try to produce more info and do more experimenting,
although maybe not in a very timely matter.

Greetings,

--=20
                The choice of a       Deliantra, the free code+content MORPG
      -----=3D=3D-     _GNU_              http://www.deliantra.net
      ----=3D=3D-- _       generation
      ---=3D=3D---(_)__  __ ____  __      Marc Lehmann
      --=3D=3D---/ / _ \/ // /\ \/ /      schmorp@schmorp.de
      -=3D=3D=3D=3D=3D/_/_//_/\_,_/ /_/\_\
