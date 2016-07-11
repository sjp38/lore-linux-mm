Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6332A6B025F
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 02:41:53 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p41so9837956lfi.0
        for <linux-mm@kvack.org>; Sun, 10 Jul 2016 23:41:53 -0700 (PDT)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id m124si2248264wmm.119.2016.07.10.23.41.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jul 2016 23:41:52 -0700 (PDT)
Received: by mail-wm0-f50.google.com with SMTP id f126so78251465wma.1
        for <linux-mm@kvack.org>; Sun, 10 Jul 2016 23:41:51 -0700 (PDT)
Date: Mon, 11 Jul 2016 08:41:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: bug in memcg oom-killer results in a hung syscall in another
 process in the same cgroup
Message-ID: <20160711064150.GB5284@dhcp22.suse.cz>
References: <CABAubThf6gbi243BqYgoCjqRW36sXJuJ6e_8zAqzkYRiu0GVtQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABAubThf6gbi243BqYgoCjqRW36sXJuJ6e_8zAqzkYRiu0GVtQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shayan Pooya <shayan@liveve.org>
Cc: cgroups mailinglist <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sat 09-07-16 16:49:32, Shayan Pooya wrote:
> I came across the following issue in kernel 3.16 (Ubuntu 14.04) which
> was then reproduced in kernels 4.4 LTS:
> After a couple of of memcg oom-kills in a cgroup, a syscall in
> *another* process in the same cgroup hangs indefinitely.
> 
> Reproducing:
> 
> # mkdir -p strace_run
> #  mkdir /sys/fs/cgroup/memory/1
> # echo 1073741824 > /sys/fs/cgroup/memory/1/memory.limit_in_bytes
> # echo 0 > /sys/fs/cgroup/memory/1/memory.swappiness
> # for i in $(seq 1000); do ./call-mem-hog
> /sys/fs/cgroup/memory/1/cgroup.procs & done
> 
> Where call-mem-hog is:
> #!/bin/sh
> set -ex
> echo $$ > $1
> echo "Adding $$ to $1"
> strace -ff -tt ./mem-hog 2> strace_run/$$
> 
> 
> Initially I thought it was a userspace bug in dash as it only happened
> with /bin/sh (which points to dash) and not with bash. I see the
> following hanging processes:
> 
> USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
> root     20999  0.0  0.0   4508   100 pts/6    S    16:28   0:00
> /bin/sh ./call-mem-hog /sys/fs/cgroup/memory/1/cgroup.procs
> 
> However, when using strace, I noticed that sometimes there is actually
> a mem-hog process hanging on sbrk syscall (Of course the
> memory.oom_control is 0 and this is not expected).
> Sending an ABRT signal to the waiting strace process then resulted in
> the mem-hog process getting oom-killed by the kernel.

Could you post the stack trace of the hung oom victim? Also could you
post the full kernel log?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
