Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id A45116B0031
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 02:55:21 -0400 (EDT)
Received: by mail-ob0-f172.google.com with SMTP id wo20so2573768obc.3
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 23:55:21 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id ny4si24429592obb.164.2014.04.18.23.55.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 23:55:21 -0700 (PDT)
Message-ID: <1397890512.19331.21.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] ipc/shm: Increase the defaults for SHMALL, SHMMAX to
 infinity
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Fri, 18 Apr 2014 23:55:12 -0700
In-Reply-To: <1397812720-5629-1-git-send-email-manfred@colorfullife.com>
References: <1397812720-5629-1-git-send-email-manfred@colorfullife.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <davidlohr.bueso@hp.com>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org, mtk.manpages@gmail.com

On Fri, 2014-04-18 at 11:18 +0200, Manfred Spraul wrote:
> System V shared memory
> 
> a) can be abused to trigger out-of-memory conditions and the standard
>    measures against out-of-memory do not work:
> 
>     - it is not possible to use setrlimit to limit the size of shm segments.
> 
>     - segments can exist without association with any processes, thus
>       the oom-killer is unable to free that memory.
> 
> b) is typically used for shared information - today often multiple GB.
>    (e.g. database shared buffers)
> 
> The current default is a maximum segment size of 32 MB and a maximum total
> size of 8 GB. This is often too much for a) and not enough for b), which
> means that lots of users must change the defaults.
> 
> This patch increases the default limits to ULONG_MAX, which is perfect for
> case b). The defaults are used after boot and as the initial value for
> each new namespace.
> 
> Admins/distros that need a protection against a) should reduce the limits
> and/or enable shm_rmid_forced.
> 
> Further notes:
> - The patch only changes the boot time default, overrides behave as before:
> 	# sysctl kernel/shmall=33554432
>   would recreate the previous limit for SHMMAX (for the current namespace).
> 
> - Disabling sysv shm allocation is possible with:
> 	# sysctl kernel.shmall=0
>   (not a new feature, also per-namespace)
> 
> - ULONG_MAX is not really infinity, but 18 Exabyte segment size and
>   75 Zettabyte total size. This should be enough for the next few weeks.
>   (assuming a 64-bit system with 4k pages)
> 
> Risks:
> - The patch breaks installations that use "take current value and increase
>   it a bit". [seems to exist, http://marc.info/?l=linux-mm&m=139638334330127]

This really scares me. The probability of occurrence is now much higher,
and not just theoretical. It would legitimately break userspace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
