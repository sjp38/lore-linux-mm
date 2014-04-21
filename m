Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id C46076B0035
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 10:31:41 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so3731347eei.28
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 07:31:41 -0700 (PDT)
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
        by mx.google.com with ESMTPS id y6si54724694eep.317.2014.04.21.07.31.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Apr 2014 07:31:40 -0700 (PDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so3739398eek.3
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 07:31:39 -0700 (PDT)
From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH 0/4] ipc/shm.c: increase the limits for SHMMAX, SHMALL
Date: Mon, 21 Apr 2014 16:26:33 +0200
Message-Id: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>

Hi all,

the increase of SHMMAX/SHMALL is now a 4 patch series.
I don't have ideas how to improve it further.

The change itself is trivial, the only problem are interger overflows.
The overflows are not new, but if we make huge values the default,
then the code should be free from overflows.

SHMMAX:

- shmmem_file_setup places a hard limit on the segment size:
  MAX_LFS_FILESIZE.

  On 32-bit, the limit is > 1 TB, i.e. 4 GB-1 byte segments are
  possible. Rounded up to full pages the actual allocated size
  is 0. --> must be fixed, patch 3

- shmat:
  - find_vma_intersection does not handle overflows properly.
    --> must be fixed, patch 1

  - the rest is fine, do_mmap_pgoff limits mappings to TASK_SIZE
    and checks for overflows (i.e.: map 2 GB, starting from
    addr=2.5GB fails).

SHMALL:
- after creating 8192 segments size (1L<<63)-1, shm_tot overflows and
  returns 0.  --> must be fixed, patch 2.

User space:
- Obviuosly, there could be overflows in user space. There is nothing
  we can do, only use values smaller than ULONG_MAX.
  I ended with "ULONG_MAX - 1L<<24":

  - TASK_SIZE cannot be used because it is the size of the current
    task. Could be 4G if it's a 32-bit task on a 64-bit kernel.

  - The maximum size is not standardized across archs:
    I found TASK_MAX_SIZE, TASK_SIZE_MAX and TASK_SIZE_64.

  - Just in case some arch revives a 4G/4G split, nearly
    ULONG_MAX is a valid segment size.

  - Using "0" as a magic value for infinity is even worse, because
    right now 0 means 0, i.e. fail all allocations.

Andrew: Could you add it into -akpm and move it towards linux-next?

--
	Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
