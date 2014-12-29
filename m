Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 367646B006E
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 13:49:42 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id v10so17536527pde.26
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 10:49:41 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id ot2si27425233pbb.123.2014.12.29.10.49.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Dec 2014 10:49:40 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so18065531pab.18
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 10:49:40 -0800 (PST)
Date: Mon, 29 Dec 2014 10:49:32 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Memory / swap leak?
In-Reply-To: <54A0A3BB.1070908@ubuntu.com>
Message-ID: <alpine.LSU.2.11.1412291026140.2692@eggly.anvils>
References: <54A0A3BB.1070908@ubuntu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phillip Susi <psusi@ubuntu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, 28 Dec 2014, Phillip Susi wrote:
> 
> Something seems to be eating up all of my swap, but it defies explanation:
> 
> root@faldara:~# free -m
>              total       used       free     shared    buffers     cached
> Mem:          3929       2881       1048        146        192       1314
> - -/+ buffers/cache:       1374       2555
> Swap:         2047       2047          0
> 
> root@faldara:~# (for file in /proc/*/status ; do cat $file ; done) |
> awk '/VmSwap/{sum += $2}END{ print sum}'
> 151804
> 
> So according to free, my entire 2 gb of swap is used, yet according to
> proc, the total swap used by all processes in the system is only 151
> mb.  How can this be?

shmem (tmpfs) uses swap, when it won't all fit in memory.  df or du on
tmpfs mounts in /proc/mounts will report on some of it (and the difference
between df and du should show if there are unlinked but still open files).
ipcs -m will report on SysV SHM.  /sys/kernel/debug/dri/*/i915_gem_objects
or similar should report on GEM objects.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
