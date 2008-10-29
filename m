Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m9T5ZNNr028290
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 05:35:24 GMT
Received: from rv-out-0708.google.com (rvfb17.prod.google.com [10.140.179.17])
	by zps36.corp.google.com with ESMTP id m9T5ZMqi015725
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 22:35:22 -0700
Received: by rv-out-0708.google.com with SMTP id b17so3073935rvf.36
        for <linux-mm@kvack.org>; Tue, 28 Oct 2008 22:35:21 -0700 (PDT)
Message-ID: <6599ad830810282235w5ad7ff7cx4f8be4e1f58933a5@mail.gmail.com>
Date: Tue, 28 Oct 2008 22:35:21 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [discuss][memcg] oom-kill extension
In-Reply-To: <20081029113826.cc773e21.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081029113826.cc773e21.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 28, 2008 at 7:38 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Under memory resource controller(memcg), oom-killer can be invoked when it
> reaches limit and no memory can be reclaimed.
>
> In general, not under memcg, oom-kill(or panic) is an only chance to recover
> the system because there is no available memory. But when oom occurs under
> memcg, it just reaches limit and it seems we can do something else.
>
> Does anyone have plan to enhance oom-kill ?

We have an in-house implementation of a per-cgroup OOM handler that
we've just ported from cpusets to cgroups. We were considering sending
the patch in as a starting point for discussions - it's a bit of a
kludge as it is.

It's a standalone subsystem that can work with either the memory
cgroup or with cpusets (where memory is constrained by numa nodes).
The features are:

- an oom.delay file that controls how long a thread will pause in the
OOM killer waiting for a response from userspace (in milliseconds)

- an oom.await file that a userspace handler can write a timeout value
to, and be awoken either when a process in that cgroup enters the OOM
killer, or the timeout expires.

If a userspace thread catches and handles the OOM, the OOMing thread
doesn't trigger a kill, but returns to alloc_pages to try again;
alternatively userspace can cause the OOM killer to go ahead as
normal.

We've found it works pretty successfully as a last-ditch notification
to a daemon waiting in a system cgroup which can then expand the
memory limits of the failing cgroup if necessary (potentially killing
off processes from some other cgroup first if necessary to free up
more memory).

I'll try to get someone to send in the patch.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
