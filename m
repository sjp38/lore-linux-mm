Date: Thu, 18 Sep 2008 13:54:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm][PATCH 4/4] Add memrlimit controller accounting and
 control (v4)
Message-Id: <20080918135430.e2979ab1.akpm@linux-foundation.org>
In-Reply-To: <20080514130951.24440.73671.sendpatchset@localhost.localdomain>
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain>
	<20080514130951.24440.73671.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 14 May 2008 18:39:51 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> This patch adds support for accounting and control of virtual address space
> limits.


Large changes in linux-next's arch/x86/kernel/ptrace.c caused damage to
the memrlimit patches.

I decided to retain the patches because it looks repairable.  The
problem is this reject from
memrlimit-add-memrlimit-controller-accounting-and-control.patch:

***************
*** 808,828 ****
  
  	current->mm->total_vm  -= old_size;
  	current->mm->locked_vm -= old_size;
  
  	if (size == 0)
  		goto out;
  
  	rlim = current->signal->rlim[RLIMIT_AS].rlim_cur >> PAGE_SHIFT;
  	vm = current->mm->total_vm  + size;
  	if (rlim < vm) {
  		ret = -ENOMEM;
  
  		if (!reduce_size)
- 			goto out;
  
  		size = rlim - current->mm->total_vm;
  		if (size <= 0)
- 			goto out;
  	}
  
  	rlim = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur >> PAGE_SHIFT;
--- 809,833 ----
  
  	current->mm->total_vm  -= old_size;
  	current->mm->locked_vm -= old_size;
+ 	memrlimit_cgroup_uncharge_as(mm, old_size);
  
  	if (size == 0)
  		goto out;
  
+ 	if (memrlimit_cgroup_charge_as(current->mm, size))
+ 		goto out;
+ 
  	rlim = current->signal->rlim[RLIMIT_AS].rlim_cur >> PAGE_SHIFT;
  	vm = current->mm->total_vm  + size;
  	if (rlim < vm) {
  		ret = -ENOMEM;
  
  		if (!reduce_size)
+ 			goto out_uncharge;
  
  		size = rlim - current->mm->total_vm;
  		if (size <= 0)
+ 			goto out_uncharge;
  	}
  
  	rlim = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur >> PAGE_SHIFT;
***************
*** 831,851 ****
  		ret = -ENOMEM;
  
  		if (!reduce_size)
- 			goto out;
  
  		size = rlim - current->mm->locked_vm;
  		if (size <= 0)
- 			goto out;
  	}
  
  	ret = ds_allocate((void **)&child->thread.ds_area_msr,
  			  size << PAGE_SHIFT);
  	if (ret < 0)
- 		goto out;
  
  	current->mm->total_vm  += size;
  	current->mm->locked_vm += size;
  
  out:
  	if (child->thread.ds_area_msr)
  		set_tsk_thread_flag(child, TIF_DS_AREA_MSR);
--- 836,859 ----
  		ret = -ENOMEM;
  
  		if (!reduce_size)
+ 			goto out_uncharge;
  
  		size = rlim - current->mm->locked_vm;
  		if (size <= 0)
+ 			goto out_uncharge;
  	}
  
  	ret = ds_allocate((void **)&child->thread.ds_area_msr,
  			  size << PAGE_SHIFT);
  	if (ret < 0)
+ 		goto out_uncharge;
  
  	current->mm->total_vm  += size;
  	current->mm->locked_vm += size;
  
+ out_uncharge:
+ 	if (ret < 0)
+ 		memrlimit_cgroup_uncharge_as(mm, size);
  out:
  	if (child->thread.ds_area_msr)
  		set_tsk_thread_flag(child, TIF_DS_AREA_MSR);



could you plese take a look at today's mmotm and see what needs to be
done to salvage it?  Most of the code you were altering got moved into
arch/x86/kernel/ds.c and got changed rather a lot.


Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
