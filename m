Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id F1A1A6B03BD
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 13:26:13 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a77so32120378qkb.8
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 10:26:13 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id u39si5611828qtb.313.2017.08.18.10.26.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 10:26:12 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm,fork: introduce MADV_WIPEONFORK
References: <20170811212829.29186-1-riel@redhat.com>
 <20170811212829.29186-3-riel@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <de749ffc-02ca-bb23-346b-d56d0b3b5271@oracle.com>
Date: Fri, 18 Aug 2017 10:25:07 -0700
MIME-Version: 1.0
In-Reply-To: <20170811212829.29186-3-riel@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, linux-kernel@vger.kernel.org
Cc: mhocko@kernel.org, linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com, linux-api@vger.kernel.org, torvalds@linux-foundation.org, willy@infradead.org

On 08/11/2017 02:28 PM, riel@redhat.com wrote:
> From: Rik van Riel <riel@redhat.com>
> 
> Introduce MADV_WIPEONFORK semantics, which result in a VMA being
> empty in the child process after fork. This differs from MADV_DONTFORK
> in one important way.
> 
> If a child process accesses memory that was MADV_WIPEONFORK, it
> will get zeroes. The address ranges are still valid, they are just empty.
> 
> If a child process accesses memory that was MADV_DONTFORK, it will
> get a segmentation fault, since those address ranges are no longer
> valid in the child after fork.
> 
> Since MADV_DONTFORK also seems to be used to allow very large
> programs to fork in systems with strict memory overcommit restrictions,
> changing the semantics of MADV_DONTFORK might break existing programs.
> 
> MADV_WIPEONFORK only works on private, anonymous VMAs.
> 
> The use case is libraries that store or cache information, and
> want to know that they need to regenerate it in the child process
> after fork.
> 
> Examples of this would be:
> - systemd/pulseaudio API checks (fail after fork)
>   (replacing a getpid check, which is too slow without a PID cache)
> - PKCS#11 API reinitialization check (mandated by specification)
> - glibc's upcoming PRNG (reseed after fork)
> - OpenSSL PRNG (reseed after fork)
> 
> The security benefits of a forking server having a re-inialized
> PRNG in every child process are pretty obvious. However, due to
> libraries having all kinds of internal state, and programs getting
> compiled with many different versions of each library, it is
> unreasonable to expect calling programs to re-initialize everything
> manually after fork.
> 
> A further complication is the proliferation of clone flags,
> programs bypassing glibc's functions to call clone directly,
> and programs calling unshare, causing the glibc pthread_atfork
> hook to not get called.
> 
> It would be better to have the kernel take care of this automatically.
> 
> This is similar to the OpenBSD minherit syscall with MAP_INHERIT_ZERO:
> 
>     https://man.openbsd.org/minherit.2
> 
> Reported-by: Florian Weimer <fweimer@redhat.com>
> Reported-by: Colm MacCA!rtaigh <colm@allcosts.net>
> Signed-off-by: Rik van Riel <riel@redhat.com>

My primary concern with the first suggested patch was trying to define
semantics if MADV_WIPEONFORK was applied to a shared or file backed
mapping.  This is no longer allowed.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

> ---
>  arch/alpha/include/uapi/asm/mman.h     |  3 +++
>  arch/mips/include/uapi/asm/mman.h      |  3 +++
>  arch/parisc/include/uapi/asm/mman.h    |  3 +++
>  arch/xtensa/include/uapi/asm/mman.h    |  3 +++
>  fs/proc/task_mmu.c                     |  1 +
>  include/linux/mm.h                     |  2 +-
>  include/trace/events/mmflags.h         |  8 +-------
>  include/uapi/asm-generic/mman-common.h |  3 +++
>  kernel/fork.c                          | 10 ++++++++--
>  mm/madvise.c                           | 13 +++++++++++++
>  10 files changed, 39 insertions(+), 10 deletions(-)
> 
> diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
> index 02760f6e6ca4..2a708a792882 100644
> --- a/arch/alpha/include/uapi/asm/mman.h
> +++ b/arch/alpha/include/uapi/asm/mman.h
> @@ -64,6 +64,9 @@
>  					   overrides the coredump filter bits */
>  #define MADV_DODUMP	17		/* Clear the MADV_NODUMP flag */
>  
> +#define MADV_WIPEONFORK 18		/* Zero memory on fork, child only */
> +#define MADV_KEEPONFORK 19		/* Undo MADV_WIPEONFORK */
> +
>  /* compatibility flags */
>  #define MAP_FILE	0
>  
> diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
> index 655e2fb5395b..d59c57d60d7d 100644
> --- a/arch/mips/include/uapi/asm/mman.h
> +++ b/arch/mips/include/uapi/asm/mman.h
> @@ -91,6 +91,9 @@
>  					   overrides the coredump filter bits */
>  #define MADV_DODUMP	17		/* Clear the MADV_NODUMP flag */
>  
> +#define MADV_WIPEONFORK 18		/* Zero memory on fork, child only */
> +#define MADV_KEEPONFORK 19		/* Undo MADV_WIPEONFORK */
> +
>  /* compatibility flags */
>  #define MAP_FILE	0
>  
> diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
> index 5979745815a5..e205e0179642 100644
> --- a/arch/parisc/include/uapi/asm/mman.h
> +++ b/arch/parisc/include/uapi/asm/mman.h
> @@ -60,6 +60,9 @@
>  					   overrides the coredump filter bits */
>  #define MADV_DODUMP	70		/* Clear the MADV_NODUMP flag */
>  
> +#define MADV_WIPEONFORK 71		/* Zero memory on fork, child only */
> +#define MADV_KEEPONFORK 72		/* Undo MADV_WIPEONFORK */
> +
>  /* compatibility flags */
>  #define MAP_FILE	0
>  #define MAP_VARIABLE	0
> diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
> index 24365b30aae9..ed23e0a1b30d 100644
> --- a/arch/xtensa/include/uapi/asm/mman.h
> +++ b/arch/xtensa/include/uapi/asm/mman.h
> @@ -103,6 +103,9 @@
>  					   overrides the coredump filter bits */
>  #define MADV_DODUMP	17		/* Clear the MADV_NODUMP flag */
>  
> +#define MADV_WIPEONFORK 18		/* Zero memory on fork, child only */
> +#define MADV_KEEPONFORK 19		/* Undo MADV_WIPEONFORK */
> +
>  /* compatibility flags */
>  #define MAP_FILE	0
>  
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index b836fd61ed87..2591e70216ff 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -651,6 +651,7 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
>  		[ilog2(VM_NORESERVE)]	= "nr",
>  		[ilog2(VM_HUGETLB)]	= "ht",
>  		[ilog2(VM_ARCH_1)]	= "ar",
> +		[ilog2(VM_WIPEONFORK)]	= "wf",
>  		[ilog2(VM_DONTDUMP)]	= "dd",
>  #ifdef CONFIG_MEM_SOFT_DIRTY
>  		[ilog2(VM_SOFTDIRTY)]	= "sd",
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 7550eeb06ccf..58788c1b9e9d 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -189,7 +189,7 @@ extern unsigned int kobjsize(const void *objp);
>  #define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
>  #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
>  #define VM_ARCH_1	0x01000000	/* Architecture-specific flag */
> -#define VM_ARCH_2	0x02000000
> +#define VM_WIPEONFORK	0x02000000	/* Wipe VMA contents in child. */
>  #define VM_DONTDUMP	0x04000000	/* Do not include in the core dump */
>  
>  #ifdef CONFIG_MEM_SOFT_DIRTY
> diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
> index 8e50d01c645f..4c2e4737d7bc 100644
> --- a/include/trace/events/mmflags.h
> +++ b/include/trace/events/mmflags.h
> @@ -125,12 +125,6 @@ IF_HAVE_PG_IDLE(PG_idle,		"idle"		)
>  #define __VM_ARCH_SPECIFIC_1 {VM_ARCH_1,	"arch_1"	}
>  #endif
>  
> -#if defined(CONFIG_X86)
> -#define __VM_ARCH_SPECIFIC_2 {VM_MPX,		"mpx"		}
> -#else
> -#define __VM_ARCH_SPECIFIC_2 {VM_ARCH_2,	"arch_2"	}
> -#endif
> -
>  #ifdef CONFIG_MEM_SOFT_DIRTY
>  #define IF_HAVE_VM_SOFTDIRTY(flag,name) {flag, name },
>  #else
> @@ -162,7 +156,7 @@ IF_HAVE_PG_IDLE(PG_idle,		"idle"		)
>  	{VM_NORESERVE,			"noreserve"	},		\
>  	{VM_HUGETLB,			"hugetlb"	},		\
>  	__VM_ARCH_SPECIFIC_1				,		\
> -	__VM_ARCH_SPECIFIC_2				,		\
> +	{VM_WIPEONFORK,			"wipeonfork"	},		\
>  	{VM_DONTDUMP,			"dontdump"	},		\
>  IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
>  	{VM_MIXEDMAP,			"mixedmap"	},		\
> diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
> index 8c27db0c5c08..49e2b1d78093 100644
> --- a/include/uapi/asm-generic/mman-common.h
> +++ b/include/uapi/asm-generic/mman-common.h
> @@ -58,6 +58,9 @@
>  					   overrides the coredump filter bits */
>  #define MADV_DODUMP	17		/* Clear the MADV_DONTDUMP flag */
>  
> +#define MADV_WIPEONFORK 18		/* Zero memory on fork, child only */
> +#define MADV_KEEPONFORK 19		/* Undo MADV_WIPEONFORK */
> +
>  /* compatibility flags */
>  #define MAP_FILE	0
>  
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 17921b0390b4..06376ae4877d 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -654,7 +654,12 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
>  		retval = dup_userfaultfd(tmp, &uf);
>  		if (retval)
>  			goto fail_nomem_anon_vma_fork;
> -		if (anon_vma_fork(tmp, mpnt))
> +		if (tmp->vm_flags & VM_WIPEONFORK) {
> +			/* VM_WIPEONFORK gets a clean slate in the child. */
> +			tmp->anon_vma = NULL;
> +			if (anon_vma_prepare(tmp))
> +				goto fail_nomem_anon_vma_fork;
> +		} else if (anon_vma_fork(tmp, mpnt))
>  			goto fail_nomem_anon_vma_fork;
>  		tmp->vm_flags &= ~(VM_LOCKED | VM_LOCKONFAULT);
>  		tmp->vm_next = tmp->vm_prev = NULL;
> @@ -698,7 +703,8 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
>  		rb_parent = &tmp->vm_rb;
>  
>  		mm->map_count++;
> -		retval = copy_page_range(mm, oldmm, mpnt);
> +		if (!(tmp->vm_flags & VM_WIPEONFORK))
> +			retval = copy_page_range(mm, oldmm, mpnt);
>  
>  		if (tmp->vm_ops && tmp->vm_ops->open)
>  			tmp->vm_ops->open(tmp);
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 9976852f1e1c..9b82cfa88ccf 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -80,6 +80,17 @@ static long madvise_behavior(struct vm_area_struct *vma,
>  		}
>  		new_flags &= ~VM_DONTCOPY;
>  		break;
> +	case MADV_WIPEONFORK:
> +		/* MADV_WIPEONFORK is only supported on anonymous memory. */
> +		if (vma->vm_file || vma->vm_flags & VM_SHARED) {
> +			error = -EINVAL;
> +			goto out;
> +		}
> +		new_flags |= VM_WIPEONFORK;
> +		break;
> +	case MADV_KEEPONFORK:
> +		new_flags &= ~VM_WIPEONFORK;
> +		break;
>  	case MADV_DONTDUMP:
>  		new_flags |= VM_DONTDUMP;
>  		break;
> @@ -689,6 +700,8 @@ madvise_behavior_valid(int behavior)
>  #endif
>  	case MADV_DONTDUMP:
>  	case MADV_DODUMP:
> +	case MADV_WIPEONFORK:
> +	case MADV_KEEPONFORK:
>  #ifdef CONFIG_MEMORY_FAILURE
>  	case MADV_SOFT_OFFLINE:
>  	case MADV_HWPOISON:
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
