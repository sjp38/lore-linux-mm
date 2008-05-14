Message-ID: <482AE9FA.4080004@openvz.org>
Date: Wed, 14 May 2008 17:32:42 +0400
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 4/4] Add memrlimit controller accounting and control
 (v4)
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain> <20080514130951.24440.73671.sendpatchset@localhost.localdomain>
In-Reply-To: <20080514130951.24440.73671.sendpatchset@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> This patch adds support for accounting and control of virtual address space
> limits. The accounting is done via the rlimit_cgroup_(un)charge_as functions.
> The core of the accounting takes place during fork time in copy_process(),
> may_expand_vm(), remove_vma_list() and exit_mmap(). There are some special
> cases that are handled here as well (arch/ia64/kernel/perform.c,
> arch/x86/kernel/ptrace.c, insert_special_mapping())
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  arch/ia64/kernel/perfmon.c      |    6 ++
>  arch/x86/kernel/ptrace.c        |   17 +++++--
>  fs/exec.c                       |    5 ++
>  include/linux/memrlimitcgroup.h |   21 ++++++++
>  kernel/fork.c                   |    8 +++
>  mm/memrlimitcgroup.c            |   94 ++++++++++++++++++++++++++++++++++++++++
>  mm/mmap.c                       |   11 ++++
>  7 files changed, 157 insertions(+), 5 deletions(-)
> 
> diff -puN arch/ia64/kernel/perfmon.c~memrlimit-controller-address-space-accounting-and-control arch/ia64/kernel/perfmon.c
> --- linux-2.6.26-rc2/arch/ia64/kernel/perfmon.c~memrlimit-controller-address-space-accounting-and-control	2008-05-14 18:09:32.000000000 +0530
> +++ linux-2.6.26-rc2-balbir/arch/ia64/kernel/perfmon.c	2008-05-14 18:09:32.000000000 +0530
> @@ -40,6 +40,7 @@
>  #include <linux/capability.h>
>  #include <linux/rcupdate.h>
>  #include <linux/completion.h>
> +#include <linux/memrlimitcgroup.h>
>  
>  #include <asm/errno.h>
>  #include <asm/intrinsics.h>
> @@ -2294,6 +2295,9 @@ pfm_smpl_buffer_alloc(struct task_struct
>  
>  	DPRINT(("sampling buffer rsize=%lu size=%lu bytes\n", rsize, size));
>  
> +	if (memrlimit_cgroup_charge_as(mm, size >> PAGE_SHIFT))
> +		return -ENOMEM;
> +

AFAIS you didn't cover all the cases when VM expands. At least all
the arch/ia64/ia32/binfmt_elf32.c is missed.

I'd insert this charge into insert_vm_struct. This would a) cover
all of the missed cases and b) reduce the amount of places to patch.

[snip the rest of the patch]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
