Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m48EcdNY006059
	for <linux-mm@kvack.org>; Fri, 9 May 2008 00:38:39 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m48EdjDL043770
	for <linux-mm@kvack.org>; Fri, 9 May 2008 00:39:45 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m48EZfTn021954
	for <linux-mm@kvack.org>; Fri, 9 May 2008 00:35:42 +1000
Message-ID: <48230FBB.20105@linux.vnet.ibm.com>
Date: Thu, 08 May 2008 20:05:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 3/4] Add rlimit controller accounting and control
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain> <20080503213814.3140.66080.sendpatchset@localhost.localdomain> <6599ad830805062029m37b507dcue737e1affddeb120@mail.gmail.com>
In-Reply-To: <6599ad830805062029m37b507dcue737e1affddeb120@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Sat, May 3, 2008 at 2:38 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>
>>  This patch adds support for accounting and control of virtual address space
>>  limits. The accounting is done via the rlimit_cgroup_(un)charge_as functions.
>>  The core of the accounting takes place during fork time in copy_process(),
>>  may_expand_vm(), remove_vma_list() and exit_mmap(). There are some special
>>  cases that are handled here as well (arch/ia64/kernel/perform.c,
>>  arch/x86/kernel/ptrace.c, insert_special_mapping())
>>
> 
> The basic idea of the patches looks fine (apart from some
> synchronization issues) but Is calling this the "rlimit" controller a
> great idea? That implies that it handles all (or at least many) of the
> things that setrlimit()/getrlimit() handle.
> 
> While some of the other rlimit things definitely do make sense as
> cgroup controllers, putting them all in the same controller doesn't
> really - paying for the address-space tracking overhead just to get,
> say, the equivalent of RLIMIT_NPROC (max tasks) isn't a great idea.
> 
> Can you instead give this a name that somehow refers to virtual
> address space limits, e.g. "va" or "as". That would still fit if you
> expanded it to deal with locked virtual address space limits too.
> 
> I think that an "rlimit" controller would probably be best for
> representing just those limits that don't really make sense when
> aggregated across different tasks, but apply separately to each task
> (e.g. RLIMIT_FSIZE, RLIMIT_CORE, RLIMIT_NICE, RLIMIT_NOFILE,
> RLIMIT_RTPRIO, RLIMIT_STACK, RLIMIT_SIGPENDING, and maybe RLIMIT_CPU),
> in order to provide an easy way to change these limits on a group of
> running tasks.
> 

I currently intend to use this controller for controlling memory related
rlimits, like address space and mlock'ed memory. How about we use something like
"memrlimit"?


> On a separate note for the address-space tracking, ideally the
> subsystem would track whether or not it was bound to a hierarchy, and
> skip charging/uncharging if not. That way there's no (noticeable)
> overhead for compiling in the subsystem but not using it. At the point
> when the subsystem was bound to a hierarchy, it could at that point
> run through all mms and charge each one's existing address space to
> the appropriate cgroup. (Currently that would only be the root cgroup
> in the hierarchy).

Good suggestion, but it will be hard if not impossible to account the data
correctly as it changes, if we do the accounting/summation at bind time. We'll
need a really big lock to do it, something I want to avoid. Did you have
something else in mind?


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
