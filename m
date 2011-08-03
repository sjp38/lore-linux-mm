Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C17256B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 10:19:15 -0400 (EDT)
Date: Wed, 3 Aug 2011 09:19:11 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/mempolicy.c: make sys_mbind & sys_set_mempolicy aware
 of task_struct->mems_allowed
In-Reply-To: <20110803123721.GA2892@x61.redhat.com>
Message-ID: <alpine.DEB.2.00.1108030913090.24201@router.home>
References: <20110803123721.GA2892@x61.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

On Wed, 3 Aug 2011, Rafael Aquini wrote:

> Among several other features enabled when CONFIG_CPUSETS is defined, task_struct is enhanced with the nodemask_t mems_allowed element that serves to register/report on which memory nodes the task may obtain memory. Also, two new lines that reflect the value registered at task_struct->mems_allowed are added to the '/proc/[pid]/status' file:
> 	  Mems_allowed:   ...,00000000,0000000f
> 	  Mems_allowed_list:      0-3
>
> The system calls sys_mbind and sys_set_mempolicy, which serve to cope
> with NUMA memory policies, and receive a nodemask_t parameter, do not
> set task_struct->mems_allowed accordingly to their received nodemask,
> when CONFIG_CPUSETS is defined. This unawareness causes unexpected
> values being reported at '/proc/[pid]/status' Mems_allowed fields, for
> applications relying on those syscalls, or spawned by numactl.

That is intentionally so since mbind does not restrict the memory nodes
allowed by the process. mbind means that process is directing its
allocation to a specific set of nodes. The process can still specify a
memory policy for allocation from any other node in mems_allowed.

> Despite not affecting the memory policy operation itself, the
> aforementioned unawareness is source of confusion and annoyance when one
> is trying to figure out which resources are bound to a given task.

Nope this is so for a reason.

> As we can check, the expected reported list would be "1,2", instead of "0-3".

Wrong. The process is allowed to allocate from nodes 0-3. Reporting
anything else would be misleading.

> @@ -1256,7 +1264,10 @@ SYSCALL_DEFINE6(mbind, unsigned long, start, unsigned long, len,
>  	err = get_nodes(&nodes, nmask, maxnode);
>  	if (err)
>  		return err;
> -	return do_mbind(start, len, mode, mode_flags, &nodes, flags);
> +	err = do_mbind(start, len, mode, mode_flags, &nodes, flags);
> +	if (!err)
> +		set_mems_allowed(nodes);
> +	return err;
>  }

Uhhh. set_mems_allowed() suffers from various races and cannot easiy be
used in random locations. Special serialization is required. See
cpuset_mems_allowed() and cpuset_change_task_nodemask

> @@ -1276,7 +1287,10 @@ SYSCALL_DEFINE3(set_mempolicy, int, mode, unsigned long __user *, nmask,
>  	err = get_nodes(&nodes, nmask, maxnode);
>  	if (err)
>  		return err;
> -	return do_set_mempolicy(mode, flags, &nodes);
> +	err = do_set_mempolicy(mode, flags, &nodes);
> +	if (!err)
> +		set_mems_allowed(nodes);
> +	return err;
>  }

Same issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
