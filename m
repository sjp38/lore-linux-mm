Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id m2QMMlbr021502
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 15:22:47 -0700
Received: from py-out-1112.google.com (pych31.prod.google.com [10.34.109.31])
	by zps76.corp.google.com with ESMTP id m2QMMWJv003981
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 15:22:47 -0700
Received: by py-out-1112.google.com with SMTP id h31so4238621pyc.23
        for <linux-mm@kvack.org>; Wed, 26 Mar 2008 15:22:47 -0700 (PDT)
Message-ID: <6599ad830803261522p45a9daddi8100a0635c21cf7d@mail.gmail.com>
Date: Wed, 26 Mar 2008 15:22:47 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][0/3] Virtual address space control for cgroups (v2)
In-Reply-To: <20080326184954.9465.19379.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080326184954.9465.19379.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 26, 2008 at 11:49 AM, Balbir Singh
<balbir@linux.vnet.ibm.com> wrote:
>
>  The changelog in each patchset documents what has changed in version 2.
>  The most important one being that virtual address space accounting is
>  now a config option.
>
>  Reviews, Comments?
>

I'm still of the strong opinion that this belongs in a separate
subsystem. (So some of these arguments will appear familiar, but are
generally because they were unaddressed previously).


The basic philosophy of cgroups is that one size does not fit all
(either all users, or all task groups), hence the ability to
pick'n'mix subsystems in a hierarchy, and have multiple different
hierarchies. So users who want physical memory isolation but not
virtual address isolation shouldn't have to pay the cost (multiple
atomic operations on a shared structure) on every mmap/munmap or other
address space change.


Trying to account/control physical memory or swap usage via virtual
address space limits is IMO a hopeless task. Taking Google's
production clusters and the virtual server systems that I worked on in
my previous job as real-life examples that I've encountered, there's
far too much variety of application behaviour (including Java apps
that have massive sparse heaps, jobs with lots of forked children
sharing pages but not address spaces with their parents, and multiple
serving processes mapping large shared data repositories from SHM
segments) that saying VA = RAM + swap is going to break lots of jobs.
But pushing up the VA limit massively makes it useless for the purpose
of preventing excessive swapping. If you want to prevent excessive
swap space usage without breaking a large class of apps, you need to
limit swap space, not virtual address space.

Additionally, you suggested that VA limits provide a "soft-landing".
But I'm think that the number of applications that will do much other
than abort() if mmap() returns ENOMEM is extremely small - I'd be
interested to hear if you know of any.

I'm not going to argue that there are no good reasons for VA limits,
but I think my arguments above will apply in enough cases that VA
limits won't be used in the majority of cases that are using the
memory controller, let alone all machines running kernels with the
memory controller configured (e.g. distro kernels). Hence it should be
possible to use the memory controller without paying the full overhead
for the virtual address space limits.


And in cases that do want to use VA limits, can you be 100% sure that
they're going to want to use the same groupings as the memory
controller? I'm not sure that I can come up with a realistic example
of why you'd want to have VA limits and memory limits in different
hierarchies (maybe tracking memory leaks in subgroups of a job and
using physical memory control for the job as a whole?), but any such
example would work for free if they were two separate subsystems.

The only real technical argument against having them in separate
subsystems is that there needs to be an extra pointer from mm_struct
to a va_limit subsystem object if they're separate, since the VA
limits can no longer use mm->mem_cgroup. This is basically 8 bytes of
overhead per process (not per-thread) which is minimal, and even that
could go away if we were to implement the mm->owner concept.


Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
