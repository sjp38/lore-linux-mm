Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8F5426B0087
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 04:25:43 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp03.au.ibm.com (8.14.4/8.13.1) with ESMTP id oAN9LNZX003733
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 20:21:23 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAN9PWhV1933358
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 20:25:33 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAN9PW8W022100
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 20:25:32 +1100
Date: Tue, 23 Nov 2010 19:55:23 +1030
From: Christopher Yeoh <cyeoh@au1.ibm.com>
Subject: Re: [RFC][PATCH] Cross Memory Attach v2 (resend)
Message-ID: <20101123195523.46e6addb@lilo>
In-Reply-To: <20101122130527.c13c99d3.akpm@linux-foundation.org>
References: <20101122122847.3585b447@lilo>
 <20101122130527.c13c99d3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Brice Goglin <Brice.Goglin@inria.fr>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Nov 2010 13:05:27 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:
> We have a bit of a track record of adding cool-looking syscalls and
> then regretting it a few years later.  Few people use them, and maybe
> they weren't so cool after all, and we have to maintain them for
> ever. Bugs (sometimes security-relevant ones) remain undiscovered for
> long periods because few people use (or care about) the code.
> 
> So I think the bar is a high one - higher than it used to be.
> Convince us that this feature is so important that it's worth all
> that overhead and risk?

Well there are the benchmark results to show that there is
real improvement for MPI implementations (well at least for those
benchmarks ;-) There's also been a few papers written on something
quite similar (KNEM) which goes into more detail on the potential gains.

http://runtime.bordeaux.inria.fr/knem/

I've also heard privately that something very similar has been used in
at least one device driver to support intranode operations for quite a
while, but maintaining this out of tree as the mm has changed has been
quite painful. 

And I can get it down to just one syscall by using the flags parameter
if that helps at all.

> > HPCC results:
> > =============
> > 
> > MB/s			Num Processes	
> > Naturally Ordered	4	8	16	32
> > Base			1235	935	622	419
> > CMA			4741	3769	1977	703
> > 
> > 			
> > MB/s			Num Processes	
> > Randomly Ordered	4	8	16	32
> > Base			1227	947	638	412
> > CMA			4666	3682	1978	710
> > 				
> > MB/s			Num Processes	
> > Max Ping Pong		4	8	16	32
> > Base			2028	1938	1928	1882
> > CMA			7424	7510	7598	7708
> 
> So with the "Naturally ordered" testcase, it got 4741/1235 times
> faster with four processes?

Yes, thats correct.

> > +asmlinkage long sys_process_vm_writev(pid_t pid,
> > +				      const struct iovec __user
> > *lvec,
> > +				      unsigned long liovcnt,
> > +				      const struct iovec __user
> > *rvec,
> > +				      unsigned long riovcnt,
> > +				      unsigned long flags);
> 
> I have a vague feeling that some architectures have issues with six or
> more syscall args.  Or maybe it was seven.

There seem to be quite a few syscalls around with 6 args and none with
7 so I suspect (or at least hope) its 7. 

> > +		bytes_to_copy = min(PAGE_SIZE - start_offset,
> > +				    len - bytes_copied);
> > +		bytes_to_copy = min((size_t)bytes_to_copy,
> > +				    lvec[*lvec_current].iov_len -
> > *lvec_offset);
> 
> Use of min_t() is conventional.

ok

> It might be a little more efficient to do
> 
> 
> 	if (vm_write) {
> 		for (j = 0; j < pages_pinned; j++) {
> 			if (j < i)
> 				set_page_dirty_lock(process_pages[j]);
> 			put_page(process_pages[j]);
> 	} else {
> 		for (j = 0; j < pages_pinned; j++)
> 			put_page(process_pages[j]);
> 	}
> 
> and it is hopefully more efficient still to use release_pages() for
> the second loop.
> 
> This code would have been clearer if a better identifier than `i' had
> been chosen.

ok.
 
> > +			 struct page **process_pages,
> > +			 struct mm_struct *mm,
> > +			 struct task_struct *task,
> > +			 unsigned long flags, int vm_write)
> > +{
> > +	unsigned long pa = addr & PAGE_MASK;
> > +	unsigned long start_offset = addr - pa;
> > +	int nr_pages;
> > +	unsigned long bytes_copied = 0;
> > +	int rc;
> > +	unsigned int nr_pages_copied = 0;
> > +	unsigned int nr_pages_to_copy;
> 
> What prevents me from copying more than 2^32 pages?

Yea it should support that... will fix.

> > +		if (rc == -EFAULT)
> 
> It would be more future-safe to use
> 
> 		if (rc < 0)
> 
> > +			goto free_mem;

ok.

> > +	int i;
> > +	int rc;
> > +	int bytes_copied;
> 
> This was unsigned long in process_vm_rw().  Please review all these
> types for appropriate size and signedness.
> 

ok, will do.

Thanks for looking over the patch!

Chris
-- 
cyeoh@au1.ibm.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
