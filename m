Date: Sun, 10 Jul 2005 18:58:36 -0700 (PDT)
From: Paul Jackson <pj@sgi.com>
Message-Id: <20050711015835.23183.40213.sendpatchset@tomahawk.engr.sgi.com>
Subject: [PATCH 0/4] cpusets mems_allowed and oom
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dinakar Guniguntala <dino@in.ibm.com>, Erich Focht <efocht@hpce.nec.com>, Simon Derr <Simon.Derr@bull.net>
Cc: linux-mm@kvack.org, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

Time to make better use of the cpuset mem_exclusive  flag ...

Dinakar has made good use of cpu_exclusive, by tying it to sched
domains.  Good.

Now I'd like use mem_exclusive, to support cpuset configurations that
allow GFP_KERNEL allocations to come from a potentially larger set
of memory nodes than GFP_USER allocations.

Here's an example usage scenario.  For a few hours or more, a large
NUMA system at a University is to be divided in two halves, with a
bunch of student jobs running in half the system under some form
of batch manager, and with a big research project running in the
other half.  Each of the student jobs is placed in a small cpuset, but
should share the classic Unix time share facilities, such as buffered
pages of files in /bin and /usr/lib.  The big research project wants no
interference whatsoever from the student jobs, and has highly tuned,
unusual memory and i/o patterns that intend to make full use of all
the main memory on the nodes available to it.

In this example, we have two big sibling cpusets, one of which is
further divided into a more dynamic set of child cpusets.

We want kernel memory allocations constrained by the two big cpusets,
and user allocations constrained by the smaller child cpusets where
present.

I propose to use the 'mem_exclusive' flag of cpusets to provide a flag
to control a solution for such scenarios.  Let memory allocations
for user space (GFP_USER) be constrained by a tasks current cpuset,
but memory allocations for kernel space (GFP_KERNEL) by constrained
by the nearest mem_exclusive ancestor of the current cpuset, even
though kernel space allocations will still _prefer_ to remain within
the current tasks cpuset, if memory is easily available.

The current constraints imposed on setting mem_exclusive are unchanged.
A cpuset may only be mem_exclusive if its parent is also mem_exclusive,
and a mem_exclusive cpuset may not overlap any of its siblings
memory nodes.

With this, one can configure a system so that allocations for kernel
use can come from a superset of the node allowed for user allocations.

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
