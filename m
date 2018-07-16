Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4976B0008
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 11:57:51 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id r11-v6so4886808vke.10
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 08:57:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n2-v6sor12627011uan.254.2018.07.16.08.57.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Jul 2018 08:57:50 -0700 (PDT)
From: Daniel Drake <drake@endlessm.com>
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory, and IO v2
Date: Mon, 16 Jul 2018 10:57:45 -0500
Message-Id: <20180716155745.10368-1-drake@endlessm.com>
In-Reply-To: <20180712172942.10094-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux@endlessm.com, linux-block@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

Hi Johannes,

Thanks for your work on psi! 

We have also been investigating the "thrashing problem" on our Endless
desktop OS. We have seen that systems can easily get into a state where the
UI becomes unresponsive to input, and the mouse cursor becomes extremely
slow or stuck when the system is running out of memory. We are working with
a full GNOME desktop environment on systems with only 2GB RAM, and
sometimes no real swap (although zram-swap helps mitigate the problem to
some extent).

My analysis so far indicates that when the system is low on memory and hits
this condition, the system is spending much of the time under
__alloc_pages_direct_reclaim. "perf trace -F" shows many many page faults
in executable code while this is going on. I believe the kernel is
swapping out executable code in order to satisfy memory allocation
requests, but then that swapped-out code is needed a moment later so it
gets swapped in again via the page fault handler, and all this activity
severely starves the system from being able to respond to user input.

I appreciate the kernel's attempt to keep processes alive, but in the
desktop case we see that the system rarely recovers from this situation,
so you have to hard shutdown. In this case we view it as desirable that
the OOM killer would step in (it is not doing so because direct reclaim
is not actually failing).

I had recently touched upon the cpuset mempressure counter, which
looked promising, but in practice I found that it was not a useful enough
representation of thrashing. It measures the rate at which
__perform_reclaim() is called, but I have observed that as the system gets
deeper and deeper into thrashing, __perform_reclaim() is actually called
at an increasingly slower rate, because each invocation ends up taking
more and more time (after 2 minutes of thrashing it can take close to 1s).

Instead of rate of function call it seems necessary to measure the amount
of work done by that codepath, and that's what you are doing with psi.

I tried psi on a 2GB RAM system with no swap (also no zram-swap) and
was pleased with the results combined with this sample userspace code:

https://gist.github.com/dsd/a8988bf0b81a6163475988120fe8d9cd

It invokes the OOM killer when memory full_avg10 is >=10%, i.e. it kills
if all tasks were blocked on memory management for at least 1s in a 10s
period.

Upon initial tests it is working very well. The system recovers quickly
from thrashing after the daemon steps in and kills a process. I have yet
to see any kills being made prematurely. It would be great to see this
upstream soon.

I also support your ideas to have the kernel offer mechanisms to handle
this directly in future; it would be nice not to have the requirement of
delegating this task to userspace, plus there may be a possibility that
userspace is starved so much that it cannot step in to handle this.

The only question I have is about the format of the data in /proc. The
memory file returns two lines and several values on each line. This
requires a bit more parsing than what I have become accustomed to in recent
years of the "one value per file" approach that seems prevalent in sysfs.
Would it make sense to instead have a single value read from (say)
/proc/pressure/memory/full_avg10 ?

Thanks
Daniel
