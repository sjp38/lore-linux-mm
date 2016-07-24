Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2596C6B0005
	for <linux-mm@kvack.org>; Sun, 24 Jul 2016 14:38:38 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y134so355363422pfg.1
        for <linux-mm@kvack.org>; Sun, 24 Jul 2016 11:38:38 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id d8si29195207paw.5.2016.07.24.11.38.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Jul 2016 11:38:37 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id i6so10543330pfe.0
        for <linux-mm@kvack.org>; Sun, 24 Jul 2016 11:38:37 -0700 (PDT)
Message-ID: <1469385512.6011.20.camel@debian.org>
Subject: tmpfs ability to shrink and expand
From: Ritesh Raj Sarraf <rrs@debian.org>
Reply-To: rrs@debian.org
Date: Mon, 25 Jul 2016 00:08:32 +0530
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Rohland <cr@sap.com>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Hello,

I am writing to you because you are listed as Maintainers for the tmpfs file
system in the Linux kernel.


Recently, I have had a bug in a general purpose application, where it ran out of
space in $TMPDIR. As is common, these days, most people vote for /tmp on tmpfs,
for obviously good reasons (performance, efficiency etc).

http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=831998


On bringing this bug, and the topic of "TMPDIR on tmpfs" on Debian-Devel,
there's one comment which wasn't clear to me. Hence this email to you.

Even in the description below about tmpfs, it says, "..... to accommodate the
files it contains and is able to swap unneeded pages out to swap space."

When we say "swap unneeded pages out to swap space", as I understand, what is
being referred as "Swappable" here is any process in the kernel's namespace. And
not referring to processes associated with /tmp ? Because those mostly will be
active processes.

The way I observed, it looks like whatever "/tmp on tmpfs" is capped at, from
the VFS point of view, is the standard limit for processes accessing files in
/tmp. And that file system view and limitations won't change (in effect to other
processes being swapped or not).

Consider this example:

rrs@chutzpah:~$ df -h /tmp/
FilesystemA A A A A A SizeA A Used Avail Use% Mounted on
tmpfsA A A A A A A A A A A 3.7GA A 3.7MA A 3.7GA A A 1% /tmp

rrs@chutzpah:~$ dd if=/dev/zero of=/tmp/foo.img bs=1M count=4000
dd: error writing '/tmp/foo.img': No space left on device
3691+0 records in
3690+0 records out
3869605888 bytes (3.9 GB, 3.6 GiB) copied, 1.12808 s, 3.4 GB/s

rrs@chutzpah:~$ free -m
A A A A A A A A A A A A A A totalA A A A A A A A usedA A A A A A A A freeA A A A A A sharedA A buff/cacheA A A available
Mem:A A A A A A A A A A A 7387A A A A A A A A 1882A A A A A A A A 4396A A A A A A A A A 213A A A A A A A A 1108A A A A A A A A 4991
Swap:A A A A A A A A A A 8579A A A A A A A A A 109A A A A A A A A 8470 A 


Here's the description of tmpfs from the latest
linux/Documentation/filesystems/tmpfs.txt


============================================================
Tmpfs is a file system which keeps all files in virtual memory.


Everything in tmpfs is temporary in the sense that no files will be
created on your hard drive. If you unmount a tmpfs instance,
everything stored therein is lost.

tmpfs puts everything into the kernel internal caches and grows and
shrinks to accommodate the files it contains and is able to swap
unneeded pages out to swap space. It has maximum size limits which can
be adjusted on the fly via 'mount -o remount ...'

If you compare it to ramfs (which was the template to create tmpfs)
you gain swapping and limit checking. Another similar thing is the RAM
disk (/dev/ram*), which simulates a fixed size hard disk in physical
RAM, where you have to create an ordinary filesystem on top. Ramdisks
cannot swap and you do not have the possibility to resize them.A 

Since tmpfs lives completely in the page cache and on swap, all tmpfs
pages will be shown as "Shmem" in /proc/meminfo and "Shared" in
free(1). Notice that these counters also include shared memory
(shmem, see ipcs(1)). The most reliable way to get the count is
using df(1) and du(1).

================================================================

- -- 
Ritesh Raj Sarraf | http://people.debian.org/~rrs
Debian - The Universal Operating System
-----BEGIN PGP SIGNATURE-----

iQIcBAEBCgAGBQJXlQsoAAoJEKY6WKPy4XVpgCQP/RRaH8IGhUTQdjF8ao00rPXu
RPo6ORs03Xn8E6zBP9qZbc2zv0FKTBzM9daTyLDRLzTaF91/eOlR6NQk0Gi6B+66
RO2j7/F4OXs/Axp9Yx8LU0aTUt/A9MV8ugqPaaPRgfgVhdwPVD3zi5pP0uZAwpub
fGicjop5vB+lv6PePioDRVOous9eomlI374PF6rP6kE2MSQSqbc+Yw4g8MC7SGZX
Xja6OwOvGQTFkbQiT0M4BOjfKEM5S6BI4Vr7R/m4ivkDCj/dJONXQ05Escc8zDuQ
yI5Rv39psWDxqTqnSPbENbSNTKw8KbswStgQUN66k/JpRQNNl3C+vLA0a5DWB5pQ
q2mSFp66ynGF6DDhlMZOvHpammhecfZpcbFvGBXikuy193SXZfT+k11FJmSSJiVE
Q4Tu6JvhADnGpfA07J9PjzV8kRsv9IdAgvFzWUsQeAi8/73ClOl3E7WHkN/zcdvO
5UkOne7h5hJjBNZD3pboQ2To9Wc4qeUWsdC8uHPN0h90fLp3oHA1v4JsraQ/MdbS
yDozCgfZ7s/M4/V20OWJ+LlWohdhkeEHKHtZVabPqXpKSpU5UkvWg458Tnlzct85
+/WMVztaF3OKsNb+CiSD0nLuLLi7Gu4TxS6JLZQEaJt/+XET7+mXPjou0g0MVg0X
FGEVOJOwFNtQibJY70Qu
=lCVO
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
