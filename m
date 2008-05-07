Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id m473TpMQ003489
	for <linux-mm@kvack.org>; Wed, 7 May 2008 04:29:51 +0100
Received: from an-out-0708.google.com (ancc37.prod.google.com [10.100.29.37])
	by zps76.corp.google.com with ESMTP id m473TnLe020344
	for <linux-mm@kvack.org>; Tue, 6 May 2008 20:29:50 -0700
Received: by an-out-0708.google.com with SMTP id c37so73602anc.42
        for <linux-mm@kvack.org>; Tue, 06 May 2008 20:29:49 -0700 (PDT)
Message-ID: <6599ad830805062029m37b507dcue737e1affddeb120@mail.gmail.com>
Date: Tue, 6 May 2008 20:29:49 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm][PATCH 3/4] Add rlimit controller accounting and control
In-Reply-To: <20080503213814.3140.66080.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain>
	 <20080503213814.3140.66080.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sat, May 3, 2008 at 2:38 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>
>  This patch adds support for accounting and control of virtual address space
>  limits. The accounting is done via the rlimit_cgroup_(un)charge_as functions.
>  The core of the accounting takes place during fork time in copy_process(),
>  may_expand_vm(), remove_vma_list() and exit_mmap(). There are some special
>  cases that are handled here as well (arch/ia64/kernel/perform.c,
>  arch/x86/kernel/ptrace.c, insert_special_mapping())
>

The basic idea of the patches looks fine (apart from some
synchronization issues) but Is calling this the "rlimit" controller a
great idea? That implies that it handles all (or at least many) of the
things that setrlimit()/getrlimit() handle.

While some of the other rlimit things definitely do make sense as
cgroup controllers, putting them all in the same controller doesn't
really - paying for the address-space tracking overhead just to get,
say, the equivalent of RLIMIT_NPROC (max tasks) isn't a great idea.

Can you instead give this a name that somehow refers to virtual
address space limits, e.g. "va" or "as". That would still fit if you
expanded it to deal with locked virtual address space limits too.

I think that an "rlimit" controller would probably be best for
representing just those limits that don't really make sense when
aggregated across different tasks, but apply separately to each task
(e.g. RLIMIT_FSIZE, RLIMIT_CORE, RLIMIT_NICE, RLIMIT_NOFILE,
RLIMIT_RTPRIO, RLIMIT_STACK, RLIMIT_SIGPENDING, and maybe RLIMIT_CPU),
in order to provide an easy way to change these limits on a group of
running tasks.

On a separate note for the address-space tracking, ideally the
subsystem would track whether or not it was bound to a hierarchy, and
skip charging/uncharging if not. That way there's no (noticeable)
overhead for compiling in the subsystem but not using it. At the point
when the subsystem was bound to a hierarchy, it could at that point
run through all mms and charge each one's existing address space to
the appropriate cgroup. (Currently that would only be the root cgroup
in the hierarchy).

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
