Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 207DB6B0253
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 16:53:07 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id x4so27952911wme.3
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 13:53:07 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id j26si6644958wrc.16.2017.02.07.13.53.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 13:53:05 -0800 (PST)
Date: Tue, 7 Feb 2017 22:53:01 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
In-Reply-To: <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1702072239390.8117@nanos>
References: <CACT4Y+asbKDni4RBavNf0-HwApTXjbbNko9eQbU6zCOgB2Yvnw@mail.gmail.com> <c7658ace-23ae-227a-2ea9-7e6bd1c8c761@suse.cz> <CACT4Y+ZT+_L3deDUcmBkr_Pr3KdCdLv6ON=2QHbK5YnBxJfLDg@mail.gmail.com>
 <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 6 Feb 2017, Dmitry Vyukov wrote:
> On Mon, Jan 30, 2017 at 4:48 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> Unfortunately it does not seem to help.
> Fuzzer now runs on 510948533b059f4f5033464f9f4a0c32d4ab0c08 of
> mmotm/auto-latest
> (git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git):
> 
> commit 510948533b059f4f5033464f9f4a0c32d4ab0c08
> Date:   Thu Feb 2 10:08:47 2017 +0100
>     mmotm: userfaultfd-non-cooperative-add-event-for-memory-unmaps-fix
> 
> The commit you referenced is already there:
> 
> commit 806b158031ca0b4714e775898396529a758ebc2c
> Date:   Thu Feb 2 08:53:16 2017 +0100
>     mm, page_alloc: use static global work_struct for draining per-cpu pages

<SNIP>

> Chain exists of:
>  Possible unsafe locking scenario:
> 
>        CPU0                    CPU1
>        ----                    ----
>   lock(pcpu_alloc_mutex);
>                                lock(cpu_hotplug.lock);
>                                lock(pcpu_alloc_mutex);
>   lock(cpu_hotplug.dep_map);

And that's exactly what happens:

				cpu_up()
    alloc_percpu()		 lock(hotplug.lock)
    lock(&pcpu_alloc_mutex)
    ..				   alloc_percpu()
      drain_all_pages()		     lock(&pcpu_alloc_mutex)
        get_online_cpus()
          lock(hotplug.lock)

Classic deadlock, i.e. you _cannot_ call get_online_cpus() while holding
pcpu_alloc_mutex.

Alternatively you can forbid to do per cpu alloc/free while holding
hotplug.lock. I doubt that this will make people happy :)

Thanks,

	tglx






    

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
