Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A47796B00EE
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 03:11:59 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp08.au.ibm.com (8.14.4/8.13.1) with ESMTP id p6P76lCv015763
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 17:06:47 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6P7BGUF1331454
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 17:11:16 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6P7BscV008837
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 17:11:55 +1000
Date: Mon, 25 Jul 2011 16:41:48 +0930
From: Christopher Yeoh <cyeoh@au1.ibm.com>
Subject: Re: Cross Memory Attach v3
Message-ID: <20110725164148.05a672b0@lilo>
In-Reply-To: <20110721150908.a71a59d6.akpm@linux-foundation.org>
References: <20110719003537.16b189ae@lilo>
	<20110721150908.a71a59d6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-man@vger.kernel.org, linux-arch@vger.kernel.org

On Thu, 21 Jul 2011 15:09:08 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 19 Jul 2011 00:35:37 +0930
> Christopher Yeoh <cyeoh@au1.ibm.com> wrote:
> 
> > +/*
> > + * process_vm_rw_pages - read/write pages from task specified
> > + * @task: task to read/write from
> > + * @mm: mm for task
> > + * @process_pages: struct pages area that can store at least
> > + *  nr_pages_to_copy struct page pointers
> > + * @pa: address of page in task to start copying from/to
> > + * @start_offset: offset in page to start copying from/to
> > + * @len: number of bytes to copy
> > + * @lvec: iovec array specifying where to copy to/from
> > + * @lvec_cnt: number of elements in iovec array
> > + * @lvec_current: index in iovec array we are up to
> > + * @lvec_offset: offset in bytes from current iovec iov_base we
> > are up to
> > + * @vm_write: 0 means copy from, 1 means copy to
> > + * @nr_pages_to_copy: number of pages to copy
> > + */
> > +static ssize_t process_vm_rw_pages(struct task_struct *task,
> > +				   struct mm_struct *mm,
> > +				      - *lvec_offset);
> > .....
> > 
> > +
> > +		target_kaddr = kmap(process_pages[pgs_copied]) +
> > start_offset; +
> > +		if (vm_write)
> > +			ret = copy_from_user(target_kaddr,
> > +
> > lvec[*lvec_current].iov_base
> > +					     + *lvec_offset,
> > +					     bytes_to_copy);
> > +		else
> > +			ret =
> > copy_to_user(lvec[*lvec_current].iov_base
> > +					   + *lvec_offset,
> > +					   target_kaddr,
> > bytes_to_copy);
> > +		kunmap(process_pages[pgs_copied]);
> > +		if (ret) {
> > +			pgs_copied++;
> > +			goto end;
> 
> afacit this will always return -EFAULT, even after copying some
> memory.
> 
> Is this a misdesign?  Would it not be better to return the number of
> bytes actually copied, or -EFAULT is we weren't able to copy any?
> Like read().
> 
> That way, userspace can at least process the data which _was_
> transferred, before retrying and then handling the fault.  With the
> proposed interface this is not possible, and the data is lost.

Perhaps because of how I'm using the interface for MPI I
was thinking that if it fails at this point due to EFAULT then
its an application error and that the partial read/write wouldn't be
used. But I see your point could be true for other uses of the interface
and the next version will return partial read/write information all the
way back to userspace.

> And note that the function's kerneldoc doesn't document the return
> value at all!  kerneldoc sucks that way - there's no formal place in
> the template, so people often ignore this important part of the
> function interface.  Similarly, there's no kerneldoc template for
> preconditions such as irq on/off, locks which must be held, etc.
> So they don't get documented.  But they're part of the interface.
> 

Ok. Will be fixed in next version

> > nr_pages_to_copy);
> > +		start_offset = 0;
> > +
> > +		if (rc < 0)
> > +			return rc;
> 
> It's propagated here.
> 
> (CodingStyleNit: it's conventional to put {} around the single-line
> block in this case, btw).
> 

Fixed now.

> > +
> > +	if (nr_pages == 0)
> > +		return 0;
> > +
> > +	/* For reliability don't try to kmalloc more than 2 pages
> > worth */
> > +	process_pages = kmalloc(min_t(size_t,
> > PVM_MAX_KMALLOC_PAGES,
> > +				      sizeof(struct pages
> > *)*nr_pages),
> > +				GFP_KERNEL);
> 
> You might get some speed benefit by optimising for the small copies
> here.  Define a local on-stack array of N page*'s and point
> process_pages at that if the number of pages is <= N.  Saves a
> malloc/free and is more cache-friendly.  But only if the result is
> measurable!

ok. will do some benchmarking to see if its worth it.

> > +
> > +static ssize_t process_vm_rw_check_iovecs(pid_t pid,
> > +					  const struct iovec
> > __user *lvec,
> > +					  unsigned long liovcnt,
> > +					  const struct iovec
> > __user *rvec,
> > +					  unsigned long riovcnt,
> > +					  unsigned long flags, int
> > vm_write)
> 
> I'm allergic to functions with "check" in their name.  Check for what?
> 
> And one would expect a check_foo() to return a bool or an errno.  This
> one returns a ssize_t!  Weird!  Interface documentation, please. 
> Including return value semantics ;)

That part was split out from the main function because the iovec
checks are different for 32 bit compatibility. Have renamed:

process_vm_rw -> process_vm_rw_core 
process_vm_rw_check_iovecs -> process_vm_rw
compat_process_vm_rw_check_iovecs -> compat_process_vm_rw

...and added more doco - with return value semantics :-)

Chris
-- 
cyeoh@au.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
