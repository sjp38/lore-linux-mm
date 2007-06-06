Subject: Re: [PATCH 2/4] audit: rework execve audit
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070605163915.e9cc7bc8.akpm@linux-foundation.org>
References: <20070605150523.786600000@chello.nl>
	 <20070605151203.626442000@chello.nl>
	 <20070605163915.e9cc7bc8.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 06 Jun 2007 07:52:27 +0200
Message-Id: <1181109147.7348.142.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ollie Wild <aaw@google.com>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>, linux-audit@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 2007-06-05 at 16:39 -0700, Andrew Morton wrote:
> On Tue, 05 Jun 2007 17:05:25 +0200
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > The purpose of audit_bprm() is to log the argv array to a userspace daemon at
> > the end of the execve system call. Since user-space hasn't had time to run,
> > this array is still in pristine state on the process' stack; so no need to copy
> > it, we can just grab it from there.
> > 
> > In order to minimize the damage to audit_log_*() copy each string into a
> > temporary kernel buffer first.
> > 
> > Currently the audit code requires that the full argument vector fits in a
> > single packet. So currently it does clip the argv size to a (sysctl) limit, but
> > only when execve auditing is enabled.
> > 
> > If the audit protocol gets extended to allow for multiple packets this check
> > can be removed.
> > 
> > ...
> >  
> 
> Please try to avoid trigger-happiness with the BUG_ON()s..
> 
> >  struct audit_aux_data_socketcall {
> > @@ -834,6 +834,47 @@ static int audit_log_pid_context(struct 
> >  	return rc;
> >  }
> >  
> > +static void audit_log_execve_info(struct audit_buffer *ab,
> > +		struct audit_aux_data_execve *axi)
> > +{
> > +	int i;
> > +	long len;
> > +	const char __user *p = (const char __user *)axi->mm->arg_start;
> > +
> > +	if (axi->mm != current->mm)
> > +		return; /* execve failed, no additional info */
> > +
> > +	for (i = 0; i < axi->argc; i++, p += len) {
> > +		long ret;
> > +		char *tmp;
> > +
> > +		len = strnlen_user(p, MAX_ARG_PAGES*PAGE_SIZE);
> > +		/*
> > +		 * We just created this mm, if we can't find the strings
> > +		 * we just copied in something is _very_ wrong.
> > +		 */
> > +		BUG_ON(!len);
> > +
> > +		tmp = kmalloc(len, GFP_KERNEL);
> > +		if (!tmp) {
> > +			audit_panic("out of memory for argv string\n");
> > +			break;
> > +		}
> > +
> > +		ret = copy_from_user(tmp, p, len);
> > +		/*
> > +		 * There is no reason for this copy to be short.
> > +		 */
> > +		BUG_ON(ret);
> 
> You sure?  What happens if another thread does munmap() in parallel?
> 
> I think I'll make this WARN_ON just out of principle.

This is right after the execve call, and before we've hit userspace, so
at this time there is no runnable context with access to the memory
(except this one).


> > @@ -1208,9 +1209,11 @@ int do_execve(char * filename,
> >  	if (retval < 0)
> >  		goto out;
> >  
> > +	tmp = bprm->p;
> >  	retval = copy_strings(bprm->argc, argv, bprm);
> >  	if (retval < 0)
> >  		goto out;
> > +	bprm->argv_len = tmp - bprm->p;
> 
> 
> 
> 
> 
> --- a/include/linux/kernel.h~a
> +++ a/include/linux/kernel.h
> @@ -5,6 +5,8 @@
>   * 'kernel.h' contains some often-used function prototypes etc
>   */
>  
> +#define tmp don't call your variables tmp!
> +
>  #ifdef __KERNEL__
>  
>  #include <stdarg.h>

Fair enough. :-/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
