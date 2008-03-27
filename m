Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2R883O0013049
	for <linux-mm@kvack.org>; Thu, 27 Mar 2008 19:08:03 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2R88Ogm4645022
	for <linux-mm@kvack.org>; Thu, 27 Mar 2008 19:08:24 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2R88N3R003602
	for <linux-mm@kvack.org>; Thu, 27 Mar 2008 19:08:23 +1100
Message-ID: <47EB5528.8070800@linux.vnet.ibm.com>
Date: Thu, 27 Mar 2008 13:34:56 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][0/3] Virtual address space control for cgroups (v2)
References: <20080326184954.9465.19379.sendpatchset@localhost.localdomain> <6599ad830803261522p45a9daddi8100a0635c21cf7d@mail.gmail.com>
In-Reply-To: <6599ad830803261522p45a9daddi8100a0635c21cf7d@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Wed, Mar 26, 2008 at 11:49 AM, Balbir Singh
> <balbir@linux.vnet.ibm.com> wrote:
>>  The changelog in each patchset documents what has changed in version 2.
>>  The most important one being that virtual address space accounting is
>>  now a config option.
>>
>>  Reviews, Comments?
>>
> 
> I'm still of the strong opinion that this belongs in a separate
> subsystem. (So some of these arguments will appear familiar, but are
> generally because they were unaddressed previously).
> 

I thought I addressed some of those by adding a separate config option. You
could enable just the address space control, by letting memory.limit_in_bytes at
the maximum value it is at (at the moment).

> 
> The basic philosophy of cgroups is that one size does not fit all
> (either all users, or all task groups), hence the ability to
> pick'n'mix subsystems in a hierarchy, and have multiple different
> hierarchies. So users who want physical memory isolation but not
> virtual address isolation shouldn't have to pay the cost (multiple
> atomic operations on a shared structure) on every mmap/munmap or other
> address space change.
> 

Yes, I agree with the overhead philosophy. I suspect that users will enable
both. I am not against making it a separate controller. I am still hopeful of
getting the mm->owner approach working

> 
> Trying to account/control physical memory or swap usage via virtual
> address space limits is IMO a hopeless task. Taking Google's
> production clusters and the virtual server systems that I worked on in
> my previous job as real-life examples that I've encountered, there's
> far too much variety of application behaviour (including Java apps
> that have massive sparse heaps, jobs with lots of forked children
> sharing pages but not address spaces with their parents, and multiple
> serving processes mapping large shared data repositories from SHM
> segments) that saying VA = RAM + swap is going to break lots of jobs.
> But pushing up the VA limit massively makes it useless for the purpose
> of preventing excessive swapping. If you want to prevent excessive
> swap space usage without breaking a large class of apps, you need to
> limit swap space, not virtual address space.
> 
> Additionally, you suggested that VA limits provide a "soft-landing".
> But I'm think that the number of applications that will do much other
> than abort() if mmap() returns ENOMEM is extremely small - I'd be
> interested to hear if you know of any.
> 

What happens if swap is completely disabled? Should the task running be OOM
killed in the container? How does the application get to know that it is
reaching its limit? I suspect the system administrator will consider
vm.overcommit_ratio while setting up virtual address space limits and real page
usage limit. As far as applications failing gracefully is concerned, my opinion is

1. Lets not be dictated by bad applications to design our features
2. Autonomic computing is forcing applications to see what resources
applications do have access to
3. Swapping is expensive, so most application developers, I spoken to at
conferences, recently, state that they can manage their own memory, provided
they are given sufficient hints from the OS. An mmap() failure, for example can
force the application to free memory it is not currently using or trigger the
garbage collector in a managed environment.


> I'm not going to argue that there are no good reasons for VA limits,
> but I think my arguments above will apply in enough cases that VA
> limits won't be used in the majority of cases that are using the
> memory controller, let alone all machines running kernels with the
> memory controller configured (e.g. distro kernels). Hence it should be
> possible to use the memory controller without paying the full overhead
> for the virtual address space limits.
> 

Yes, the overhead part is a compelling reason to split out the controllers. But
then again, we have a config option to disable the overhead.

> 
> And in cases that do want to use VA limits, can you be 100% sure that
> they're going to want to use the same groupings as the memory
> controller? I'm not sure that I can come up with a realistic example
> of why you'd want to have VA limits and memory limits in different
> hierarchies (maybe tracking memory leaks in subgroups of a job and
> using physical memory control for the job as a whole?), but any such
> example would work for free if they were two separate subsystems.
> 
> The only real technical argument against having them in separate
> subsystems is that there needs to be an extra pointer from mm_struct
> to a va_limit subsystem object if they're separate, since the VA
> limits can no longer use mm->mem_cgroup. This is basically 8 bytes of
> overhead per process (not per-thread) which is minimal, and even that
> could go away if we were to implement the mm->owner concept.
>

Yes, the mm->owner patches would help split the controller out more easily. Let
me see if I can get another revision of that working and measure the overhead of
finding the next mm->owner.


> 
> Paul


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
