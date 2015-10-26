Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 937986B0038
	for <linux-mm@kvack.org>; Mon, 26 Oct 2015 17:38:14 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so208333586pac.3
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 14:38:14 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id rb8si55978781pbb.243.2015.10.26.14.38.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Oct 2015 14:38:13 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so199607640pad.1
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 14:38:13 -0700 (PDT)
Date: Mon, 26 Oct 2015 14:38:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom_kill: add option to disable dump_stack()
In-Reply-To: <1445634150-27992-1-git-send-email-arozansk@redhat.com>
Message-ID: <alpine.DEB.2.10.1510261424290.12408@chino.kir.corp.google.com>
References: <1445634150-27992-1-git-send-email-arozansk@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aristeu Rozanski <arozansk@redhat.com>
Cc: linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri, 23 Oct 2015, Aristeu Rozanski wrote:

> One of the largest chunks of log messages in a OOM is from dump_stack() and in
> some cases it isn't even necessary to figure out what's going on. In
> systems with multiple tenants/containers with limited resources each
> OOMs can be way more frequent and being able to reduce the amount of log
> output for each situation is useful.
> 
> This patch adds a sysctl to allow disabling dump_stack() during an OOM while
> keeping the default to behave the same way it behaves today.
> 
> Cc: Greg Thelen <gthelen@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: linux-mm@kvack.org
> Cc: cgroups@vger.kernel.org
> Signed-off-by: Aristeu Rozanski <arozansk@redhat.com>

There's lots of information in the oom log that is irrelevant depending on 
the context in which the oom condition occurred.  Removing the stack trace 
would have made things like commit 9a185e5861e8 ("/proc/stat: convert to 
single_open_size()") harder to fix.  In that case, we were calling the oom 
killer on large file reads from procfs when we could have easily have 
used vmalloc() instead.

When you have a memcg oom kill, the state of the system's memory can 
usually be suppressed because it only occurred because a memcg hierarchy 
reached its limit and has nothing to do with the exhaustion of RAM.

We already control oom output with global sysctls like vm.oom_dump_tasks 
and memcg tunables like memory.oom_verbose.  I'm not sure that adding more 
and more tunables simply to control the oom killer output is in the best 
interest of either procfs or a long-term maintainable kernel.

I can understand the usefulness of having a very small amount of output to 
the kernel log and then enabling tunables to investigate why oom kills are 
happening, but in many situations I've found to only have the oom killer 
output left behind in a kernel log and the situation is not on-going so I 
can't start diagnosing the problem if I don't know what triggered it.

I think adding additional sysctls to control oom killer output is in the 
wrong direction.  I do agree with removing anything that is irrelevant in 
all situations, however.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
