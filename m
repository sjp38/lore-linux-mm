Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 115586B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 11:10:49 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id a1so1281219wgh.11
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 08:10:49 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id kb4si5641607wjc.46.2014.10.24.08.10.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 24 Oct 2014 08:10:48 -0700 (PDT)
Date: Fri, 24 Oct 2014 17:10:35 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 10/12] x86, mpx: add prctl commands PR_MPX_ENABLE_MANAGEMENT,
 PR_MPX_DISABLE_MANAGEMENT
In-Reply-To: <alpine.DEB.2.11.1410241436560.5308@nanos>
Message-ID: <alpine.DEB.2.11.1410241710020.5308@nanos>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-11-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241436560.5308@nanos>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiaowei Ren <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On Fri, 24 Oct 2014, Thomas Gleixner wrote:
> On Sun, 12 Oct 2014, Qiaowei Ren wrote:
> > +int mpx_enable_management(struct task_struct *tsk)
> > +{
> > +	struct mm_struct *mm = tsk->mm;
> > +	void __user *bd_base = MPX_INVALID_BOUNDS_DIR;
> 
> What's the point of initializing bd_base here. I had to look twice to
> figure out that it gets overwritten by task_get_bounds_dir()
> 
> > @@ -285,6 +285,7 @@ dotraplinkage void do_bounds(struct pt_regs *regs, long error_code)
> >  	struct xsave_struct *xsave_buf;
> >  	struct task_struct *tsk = current;
> >  	siginfo_t info;
> > +	int ret = 0;
> >  
> >  	prev_state = exception_enter();
> >  	if (notify_die(DIE_TRAP, "bounds", regs, error_code,
> > @@ -312,8 +313,35 @@ dotraplinkage void do_bounds(struct pt_regs *regs, long error_code)
> >  	 */
> >  	switch (status & MPX_BNDSTA_ERROR_CODE) {
> >  	case 2: /* Bound directory has invalid entry. */
> > -		if (do_mpx_bt_fault(xsave_buf))
> > +		down_write(&current->mm->mmap_sem);
> 
> The handling of mm->mmap_sem here is horrible. The only reason why you
> want to hold mmap_sem write locked in the first place is that you want
> to cover the allocation and the mm->bd_addr check.
> 
> I think it's wrong to tie this to mmap_sem in the first place. If MPX
> is enabled then you should have mm->bd_addr and an explicit mutex to
> protect it.
> 
> So the logic would look like this:
> 
>    mutex_lock(&mm->bd_mutex);
>    if (!kernel_managed(mm))
>       do_trap();
>    else if (do_mpx_bt_fault())
>       force_sig();
>    mutex_unlock(&mm->bd_mutex);
>    
> No tricks with mmap_sem, no special return value handling. Straight
> forward code instead of a convoluted and error prone mess.

After thinking about the deallocation issue, this would be mm->bd_sem.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
