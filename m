Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A56E6B0005
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 19:49:35 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id l89so5975754lfi.3
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 16:49:35 -0700 (PDT)
Received: from mail-lf0-x22b.google.com (mail-lf0-x22b.google.com. [2a00:1450:4010:c07::22b])
        by mx.google.com with ESMTPS id n8si953924lfi.264.2016.07.09.16.49.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jul 2016 16:49:33 -0700 (PDT)
Received: by mail-lf0-x22b.google.com with SMTP id f6so48637273lfg.0
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 16:49:33 -0700 (PDT)
MIME-Version: 1.0
From: Shayan Pooya <shayan@liveve.org>
Date: Sat, 9 Jul 2016 16:49:32 -0700
Message-ID: <CABAubThf6gbi243BqYgoCjqRW36sXJuJ6e_8zAqzkYRiu0GVtQ@mail.gmail.com>
Subject: bug in memcg oom-killer results in a hung syscall in another process
 in the same cgroup
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups mailinglist <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

I came across the following issue in kernel 3.16 (Ubuntu 14.04) which
was then reproduced in kernels 4.4 LTS:
After a couple of of memcg oom-kills in a cgroup, a syscall in
*another* process in the same cgroup hangs indefinitely.

Reproducing:

# mkdir -p strace_run
#  mkdir /sys/fs/cgroup/memory/1
# echo 1073741824 > /sys/fs/cgroup/memory/1/memory.limit_in_bytes
# echo 0 > /sys/fs/cgroup/memory/1/memory.swappiness
# for i in $(seq 1000); do ./call-mem-hog
/sys/fs/cgroup/memory/1/cgroup.procs & done

Where call-mem-hog is:
#!/bin/sh
set -ex
echo $$ > $1
echo "Adding $$ to $1"
strace -ff -tt ./mem-hog 2> strace_run/$$


Initially I thought it was a userspace bug in dash as it only happened
with /bin/sh (which points to dash) and not with bash. I see the
following hanging processes:

USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root     20999  0.0  0.0   4508   100 pts/6    S    16:28   0:00
/bin/sh ./call-mem-hog /sys/fs/cgroup/memory/1/cgroup.procs

However, when using strace, I noticed that sometimes there is actually
a mem-hog process hanging on sbrk syscall (Of course the
memory.oom_control is 0 and this is not expected).
Sending an ABRT signal to the waiting strace process then resulted in
the mem-hog process getting oom-killed by the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
