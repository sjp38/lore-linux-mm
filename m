Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2E26B005A
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 10:39:19 -0400 (EDT)
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx09.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n74F76CK023694
	for <linux-mm@kvack.org>; Tue, 4 Aug 2009 10:07:24 -0500
Received: from [172.21.41.104] (esdhcp041104.research.nokia.com [172.21.41.104])
	by mgw-sa02.ext.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n74F7WAI005735
	for <linux-mm@kvack.org>; Tue, 4 Aug 2009 18:07:33 +0300
Subject: SysV swapped shared memory calculated incorrectly
From: Niko Jokinen <ext-niko.k.jokinen@nokia.com>
Reply-To: ext-niko.k.jokinen@nokia.com
Content-Type: text/plain
Date: Tue, 04 Aug 2009 18:07:32 +0300
Message-Id: <1249398452.3905.268.camel@niko-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

Tested on 2.6.28 and 2.6.31-rc4

SysV swapped shared memory is not calculated correctly
in /proc/<pid>/smaps and also by parsing /proc/<pid>/pagemap.
Rss value decreases also when swap is disabled, so this is where I am
lost as how shared memory is supposed to behave.

I have test program which makes 32MB shared memory segment and then I
use 'stress -m 1 --vm-bytes 120M', --vm-bytes is increased until rss
size decreases in smaps. Swap value never increases in smaps.

On the other hand shmctl(0, SHM_INFO, ...) does show shared memory in
swap because shm.c shm_get_stat() uses inodes to get values.


When test program is started:

shmctl() printout:
SHM_INFO (sys-wide):       total : 34580 kB
                             rss : 34388 kB
                            swap : 192 kB

smaps printout:
40153000-42153000 rw-s 00000000 00:08 1703949    /SYSV54016264 (deleted)
Size:              32768 kB
Rss:               32768 kB
Pss:               32768 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:     32768 kB
Referenced:        32768 kB
Swap:                  0 kB

------------

After all memory is allocated (without swap smaps is the same, except
SHM_INFO shows 'Swap: 0' like it should), first byte is read hence the
4KB Referenced:

SHM_INFO (sys-wide):       total : 34580 kB
                             rss : 1528 kB
                            swap : 33052 kB


40153000-42153000 rw-s 00000000 00:08 1867789    /SYSV54016264 (deleted)
Size:              32768 kB
Rss:                   4 kB
Pss:                   4 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         4 kB
Private_Dirty:         0 kB
Referenced:            4 kB
Swap:                  0 kB

------------

task_mmu.c, smaps_pte_range():

		if (is_swap_pte(ptent)) {
			mss->swap += PAGE_SIZE;
			continue;
		}

		if (!pte_present(ptent))
			continue;

When all memory is allocated pte_present() returns false for shared
memory. is_swap_pte() is never true for shared memory.

Ideas how to fix?


Br,
Niko Jokinen


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
