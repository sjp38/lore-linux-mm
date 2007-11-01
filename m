Date: Thu, 1 Nov 2007 12:25:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH 1/3] [RFC][PATCH] Fix procfs task exe symlinks
Message-Id: <20071101122509.f26225bb.akpm@linux-foundation.org>
In-Reply-To: <20071101044124.209949000@us.ibm.com>
References: <20071101033508.720885000@us.ibm.com>
	<20071101044124.209949000@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@ftp.linux.org.uk, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 31 Oct 2007 20:35:09 -0700
Matt Helsley <matthltc@us.ibm.com> wrote:

> +++ linux-2.6.23/include/linux/sched.h
> @@ -430,10 +430,13 @@ struct mm_struct {
>  	struct completion *core_startup_done, core_done;
>  
>  	/* aio bits */
>  	rwlock_t		ioctx_list_lock;
>  	struct kioctx		*ioctx_list;
> +
> +	/* store ref to file /proc/<pid>/exe symlink points to */
> +	struct file *exe_file;
>  };

I guess with a little work this could be made conditional on
CONFIG_PROC_FS.  ie: change get_mm_exe_file() to

void get_mm_exe_file(struct mm_struct *newmm, struct mm_struct *old_mm);

> @@ -1716,10 +1744,14 @@ static void remove_vma_list(struct mm_st
>  
>  		mm->total_vm -= nrpages;
>  		if (vma->vm_flags & VM_LOCKED)
>  			mm->locked_vm -= nrpages;
>  		vm_stat_account(mm, vma->vm_flags, vma->vm_file, -nrpages);
> +		if (mm->exe_file && (vma->vm_file == mm->exe_file)) {
> +			fput(mm->exe_file);
> +			mm->exe_file = NULL;
> +		}
>  		vma = remove_vma(vma);
>  	} while (vma);
>  	validate_mm(mm);
>  }

hm, fput() while holding mmap_sem.  I wonder if that's a problem.

I assume you've runtime tested this with lockdep enabled, but fput() is one
of those funny things which can call all sorts of things which one least
expects and where testers hit things which developers don't.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
