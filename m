Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8CDC86B009D
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 05:02:21 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6U92JVs015666
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 30 Jul 2009 18:02:19 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CBAB45DE60
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 18:02:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 23BBA45DE59
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 18:02:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CB3C4E0800A
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 18:02:16 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 53AB5E08005
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 18:02:16 +0900 (JST)
Date: Thu, 30 Jul 2009 18:00:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
Message-Id: <20090730180029.c4edcc09.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Jul 2009 21:27:15 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> It's helpful to be able to specify an oom_adj value for newly forked
> children that do not share memory with the parent.
> 
> Before making oom_adj values a characteristic of a task's mm in
> 2ff05b2b4eac2e63d345fc731ea151a060247f53, it was possible to change the
> oom_adj value of a vfork() child prior to execve() without implicitly
> changing the oom_adj value of the parent.  With the new behavior, the
> oom_adj values of both threads would change since they represent the same
> memory.
> 
> That change was necessary to fix an oom killer livelock which would occur
> when a child would be selected for oom kill prior to execve() and the
> task could not be killed because it shared memory with an OOM_DISABLE
> parent.  In fact, only the most negative (most immune) oom_adj value for
> all threads sharing the same memory would actually be used by the oom
> killer, leaving inconsistencies amongst all other threads having
> different oom_adj values (and, thus, incorrectly exported
> /proc/pid/oom_score values).
> 
> This patch adds a new per-process parameter: /proc/pid/oom_adj_child.
> This defaults to mirror the value of /proc/pid/oom_adj but may be changed
> so that mm's initialized by their children are preferred over the parent
> by the oom killer.  Setting oom_adj_child to be less (i.e. more immune)
> than the task's oom_adj value itself is governed by the CAP_SYS_RESOURCE
> capability.
> 
> When a mm is initialized, the initial oom_adj value will be set to the
> parent's oom_adj_child.  This allows tasks to elevate the oom_adj value
> of a vfork'd child prior to execve() before the execution actually takes
> place.
> 
> Furthermore, /proc/pid/oom_adj_child is inherited from the task that
> forked it.
> 
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Paul Menage <menage@google.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  Documentation/filesystems/proc.txt |   38 ++++++++++++++++----
>  fs/proc/base.c                     |   68 ++++++++++++++++++++++++++++++++++++
>  include/linux/sched.h              |    1 +
>  kernel/fork.c                      |    3 +-
>  4 files changed, 101 insertions(+), 9 deletions(-)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -34,10 +34,11 @@ Table of Contents
>  
>    3	Per-Process Parameters
>    3.1	/proc/<pid>/oom_adj - Adjust the oom-killer score
> -  3.2	/proc/<pid>/oom_score - Display current oom-killer score
> -  3.3	/proc/<pid>/io - Display the IO accounting fields
> -  3.4	/proc/<pid>/coredump_filter - Core dump filtering settings
> -  3.5	/proc/<pid>/mountinfo - Information about mounts
> +  3.2	/proc/<pid>/oom_adj_child - Change default oom_adj for children
> +  3.3	/proc/<pid>/oom_score - Display current oom-killer score
> +  3.4	/proc/<pid>/io - Display the IO accounting fields
> +  3.5	/proc/<pid>/coredump_filter - Core dump filtering settings
> +  3.6	/proc/<pid>/mountinfo - Information about mounts
>  
>  
>  ------------------------------------------------------------------------------
> @@ -1206,7 +1207,28 @@ The task with the highest badness score is then selected and its children
>  are killed, process itself will be killed in an OOM situation when it does
>  not have children or some of them disabled oom like described above.
>  
> -3.2 /proc/<pid>/oom_score - Display current oom-killer score
> +
> +3.2 /proc/<pid>/oom_adj_child - Change default oom_adj for children
> +-------------------------------------------------------------------
> +
> +This file can be used to change the default oom_adj value for children when a
> +new mm is initialized.  The oom_adj value for a child's mm is typically the
> +task's oom_adj value itself, however this value can be altered by writing to
> +this file.
> +
> +This is particularly helpful when a child is vfork'd and its mm following exec
> +should have a higher priority oom_adj value than its parent.  The new mm will
> +default to oom_adj_child of the parent task.
> +
> +oom_adj_child will mirror oom_adj whenever the latter changes for all tasks
> +that share its memory.  This avoids having to set both values when simply
> +tuning oom_adj and that value should be inherited by all children.
> +
> +Setting oom_adj_child to be more immune than the task's mm itself (i.e. less
> +than oom_adj) is governed by the CAP_SYS_RESOURCE capability.
> +
a few comments.

1. IIUC, the name is strange.

At job scheduler, which does this.

if (vfork() == 0) {
	/* do some job */
	execve(.....)
}

Then, when oom_adj_child can be effective is after execve().
IIUC, the _child_ means a process created by vfork().

2. More simple plan is like this, IIUC.

  fix oom-killer's select_bad_process() not to be in deadlock.

rather than this new stupid interface.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
