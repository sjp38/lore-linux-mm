Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9CAAD6B0031
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 07:43:58 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so2288473eek.23
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 04:43:57 -0700 (PDT)
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
        by mx.google.com with ESMTPS id u5si44535616een.233.2014.04.19.04.43.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 04:43:56 -0700 (PDT)
Received: by mail-ee0-f48.google.com with SMTP id b57so2300687eek.21
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 04:43:56 -0700 (PDT)
From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH 0/4] ipc/shm.c: increase the limits for SHMMAX, SHMALL
Date: Sat, 19 Apr 2014 13:43:37 +0200
Message-Id: <1397907821-29319-1-git-send-email-manfred@colorfullife.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>

Hi all,

the increase of SHMMAX/SHMALL is now a 4 patch series, and still
not ready for merging (see at the end, TASK_SIZE and s390).

If we increase the default limits for SHMMAX and SHMALL,
integer overflows could happen:

SHMMAX:

- shmmem_file_setup places a hard limit on the segment size:
	MAX_LFS_FILESIZE.

	on 32-bit, the limit is > 1 TB.
	--> 32-bit: 4 GB-1 segments are possible.
		Rounded up to full pages the actual allocated size
                is 0.
		--> patch 3

	on 64-bit, this is 0x7fff ffff ffff ffff
		--> no chance for an overflow.

- shmat:
	- find_vma_intersection does not handle overflows properly
		--> patch 1.

	- do_mmap_pgoff limits mappings to TASK_SIZE
		3 GB on 32-bit (assuming x86)
		47 bits on 64-bit (assuming x86)

	- do_mmap_pgoff checks for overflows:
		map 2 GB, starting from addr=2.5GB fails.

SHMALL:

- after creating 8192 segments size (1L<<63)-1, shm_tot
  overflows and returns 0.
	--> patch 2.

And finally:
Patch 4, increase the limits to ULONG_MAX

Open points:
- Better ideas to handle uapi: Is it worth the effort to get
  access to TASK_SIZE? I would say no.
- Better ideas with regards to SHMALL? The values are probably
  large enough, but still arbitrary.

- The TASK_SIZE definition for e.g. S390 differs: It's not
  a constant, instead it is the current task size for current.
  And it seems that the task size can change based on
  (virtual) memory pressure (s390_mmap_check()).
  For new namespaces, this might have interesting effects, i.e.
  this must be fixed.

--
	Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
