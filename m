Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id A60A96B0044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 18:53:58 -0400 (EDT)
Received: by wgbds10 with SMTP id ds10so813956wgb.26
        for <linux-mm@kvack.org>; Wed, 21 Mar 2012 15:53:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120316144028.036474157@chello.nl>
References: <20120316144028.036474157@chello.nl>
Date: Wed, 21 Mar 2012 15:53:56 -0700
Message-ID: <CAOhV88NafiU7hseTzQfApthMk3X=_GT09gEM2Zzx5OJ=8z6vvw@mail.gmail.com>
Subject: Re: [RFC][PATCH 00/26] sched/numa
From: Nish Aravamudan <nish.aravamudan@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Peter,

Sorry if this has already been reported, but

On Fri, Mar 16, 2012 at 7:40 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wr=
ote:
>
> Hi All,
>
> While the current scheduler has knowledge of the machine topology, includ=
ing
> NUMA (although there's room for improvement there as well [1]), it is
> completely insensitive to which nodes a task's memory actually is on.
>
> Current upstream task memory allocation prefers to use the node the task =
is
> currently running on (unless explicitly told otherwise, see
> mbind()/set_mempolicy()), and with the scheduler free to move the task ab=
out at
> will, the task's memory can end up being spread all over the machine's no=
des.
>
> While the scheduler does a reasonable job of keeping short running tasks =
on a
> single node (by means of simply not doing the cross-node migration very o=
ften),
> it completely blows for long-running processes with a large memory footpr=
int.
>
> This patch-set aims at improving this situation. It does so by assigning =
a
> preferred, or home, node to every process/thread_group. Memory allocation=
 is
> then directed by this preference instead of the node the task might actua=
lly be
> running on momentarily. The load-balancer is also modified to prefer runn=
ing
> the task on its home-node, although not at the cost of letting CPUs go id=
le or
> at the cost of execution fairness.
<snip>

> =A0[24/26] mm, mpol: Implement numa_group RSS accounting

I was going to try and test this on power, but it fails to build:

  mm/filemap_xip.c: In function =91__xip_unmap=92:
  mm/filemap_xip.c:199: error: implicit declaration of function
=91numa_add_vma_counter=92

and I think


> =A0[26/26] sched, numa: A few debug bits

introduced a new warning:

  kernel/sched/numa.c: In function =91process_cpu_runtime=92:
  kernel/sched/numa.c:210: warning: format =91%lu=92 expects type =91long
unsigned int=92, but argument 3 has type =91u64=92
  kernel/sched/numa.c:210: warning: format =91%lu=92 expects type =91long
unsigned int=92, but argument 4 has type =91u64=92

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
