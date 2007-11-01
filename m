Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA1Jr1aP024764
	for <linux-mm@kvack.org>; Thu, 1 Nov 2007 15:53:01 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA1Jr1ok467078
	for <linux-mm@kvack.org>; Thu, 1 Nov 2007 15:53:01 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA1Jr0ZL004548
	for <linux-mm@kvack.org>; Thu, 1 Nov 2007 15:53:01 -0400
Subject: Re: [RFC][PATCH 1/3] [RFC][PATCH] Fix procfs task exe symlinks
From: Matt Helsley <matthltc@us.ibm.com>
In-Reply-To: <20071101122509.f26225bb.akpm@linux-foundation.org>
References: <20071101033508.720885000@us.ibm.com>
	 <20071101044124.209949000@us.ibm.com>
	 <20071101122509.f26225bb.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 01 Nov 2007 12:52:56 -0700
Message-Id: <1193946776.16995.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@ftp.linux.org.uk, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-11-01 at 12:25 -0700, Andrew Morton wrote:
> On Wed, 31 Oct 2007 20:35:09 -0700
> Matt Helsley <matthltc@us.ibm.com> wrote:
> 
> > +++ linux-2.6.23/include/linux/sched.h
> > @@ -430,10 +430,13 @@ struct mm_struct {
> >  	struct completion *core_startup_done, core_done;
> >  
> >  	/* aio bits */
> >  	rwlock_t		ioctx_list_lock;
> >  	struct kioctx		*ioctx_list;
> > +
> > +	/* store ref to file /proc/<pid>/exe symlink points to */
> > +	struct file *exe_file;
> >  };
> 
> I guess with a little work this could be made conditional on
> CONFIG_PROC_FS.  ie: change get_mm_exe_file() to

Sorry, I thought ifdefs were generally frowned upon in structs. I'll add
them here and make sure everthing still works properly.

> void get_mm_exe_file(struct mm_struct *newmm, struct mm_struct *old_mm);
> 
> > @@ -1716,10 +1744,14 @@ static void remove_vma_list(struct mm_st
> >  
> >  		mm->total_vm -= nrpages;
> >  		if (vma->vm_flags & VM_LOCKED)
> >  			mm->locked_vm -= nrpages;
> >  		vm_stat_account(mm, vma->vm_flags, vma->vm_file, -nrpages);
> > +		if (mm->exe_file && (vma->vm_file == mm->exe_file)) {
> > +			fput(mm->exe_file);
> > +			mm->exe_file = NULL;
> > +		}
> >  		vma = remove_vma(vma);
> >  	} while (vma);
> >  	validate_mm(mm);
> >  }
> 
> hm, fput() while holding mmap_sem.  I wonder if that's a problem.
> 
> I assume you've runtime tested this with lockdep enabled, but fput() is one
> of those funny things which can call all sorts of things which one least
> expects and where testers hit things which developers don't.

It's being used under the mmap semaphore in remove_vma() so, even if
fput() with mmap_sem held is a bug, I'm not introducing any new bugs :).

Thanks,
	-Matt Helsley


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
