Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id AF4AD6B0035
	for <linux-mm@kvack.org>; Sat, 30 Aug 2014 09:59:30 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id m5so3222719qaj.7
        for <linux-mm@kvack.org>; Sat, 30 Aug 2014 06:59:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 10si4284385qaj.81.2014.08.30.06.59.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Aug 2014 06:59:30 -0700 (PDT)
Date: Sat, 30 Aug 2014 15:57:06 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [mmotm:master 123/287] fs/proc/task_mmu.c:1426:27: error:
	'task' undeclared
Message-ID: <20140830135706.GA7371@redhat.com>
References: <54011337.obkqHml8e//Q+mnU%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54011337.obkqHml8e//Q+mnU%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On 08/30, kbuild test robot wrote:
>
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   8f1fc64dc9b39fedb7390e086001ce5ec327e80d
> commit: 8b38b95075137cd18b5e51bc48751c023d16c3fb [123/287] mempolicy: fix show_numa_map() vs exec() + do_set_mempolicy() race
> config: make ARCH=x86_64 allmodconfig
>
> Note: the mmotm/master HEAD 8f1fc64dc9b39fedb7390e086001ce5ec327e80d builds fine.
>       It only hurts bisectibility.
>
> All error/warnings:
>
>    fs/proc/task_mmu.c: In function 'show_numa_map':
> >> fs/proc/task_mmu.c:1426:27: error: 'task' undeclared (first use in this function)
>       pid_t tid = vm_is_stack(task, vma, is_pid);
>                               ^

Thanks!

Looks like, this commit was wrongly reordered with

	proc-maps-make-vm_is_stack-logic-namespace-friendly.patch

Indeed, from "mmotm 2014-08-29-15-15 uploaded":

	* mempolicy-change-alloc_pages_vma-to-use-mpol_cond_put.patch
	* mempolicy-change-get_task_policy-to-return-default_policy-rather-than-null.patch
	* mempolicy-sanitize-the-usage-of-get_task_policy.patch
	* mempolicy-remove-the-task-arg-of-vma_policy_mof-and-simplify-it.patch
	* mempolicy-introduce-__get_vma_policy-export-get_task_policy.patch
	* mempolicy-fix-show_numa_map-vs-exec-do_set_mempolicy-race.patch
	* mempolicy-kill-do_set_mempolicy-down_writemm-mmap_sem.patch
	* mempolicy-unexport-get_vma_policy-and-remove-its-task-arg.patch
	...
	* proc-maps-replace-proc_maps_private-pid-with-struct-inode-inode.patch
	* proc-maps-make-vm_is_stack-logic-namespace-friendly.patch

but "mempolicy" series depends (textually) on the previous "proc-maps" changes.

Oleg.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
