Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 722236B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 13:32:21 -0400 (EDT)
Received: by qadc11 with SMTP id c11so80884qad.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 10:32:20 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 28 Sep 2012 10:32:20 -0700
Message-ID: <CAA25o9TmsnR3T+CLk5LeRmXv3s8b719KrSU6C919cAu0YMKPkA@mail.gmail.com>
Subject: zram OOM behavior
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Greetings,

We are experimenting with zram in Chrome OS.  It works quite well
until the system runs out of memory, at which point it seems to hang,
but we suspect it is thrashing.

Before the (apparent) hang, the OOM killer gets rid of a few
processes, but then the other processes gradually stop responding,
until the entire system becomes unresponsive.

I am wondering if anybody has run into this.  Thanks!

Luigi

P.S.  For those who wish to know more:

1. We use the min_filelist_kbytes patch
(http://lwn.net/Articles/412313/)  (I am not sure if it made it into
the standard kernel) and set min_filelist_kbytes to 50Mb.  (This may
not matter, as it's unlikely to make things worse.)

2. We swap only to compressed ram.  The setup is very simple:

 echo ${ZRAM_SIZE_KB}000 >/sys/block/zram0/disksize ||
      logger -t "$UPSTART_JOB" "failed to set zram size"
  mkswap /dev/zram0 || logger -t "$UPSTART_JOB" "mkswap /dev/zram0 failed"
  swapon /dev/zram0 || logger -t "$UPSTART_JOB" "swapon /dev/zram0 failed"

For ZRAM_SIZE_KB, we typically use 1.5 the size of RAM (which is 2 or
4 Gb).  The compression factor is about 3:1.  The hangs happen for
quite a wide range of zram sizes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
