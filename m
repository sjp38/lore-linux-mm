Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B997F8D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 08:44:06 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp07.au.ibm.com (8.14.4/8.13.1) with ESMTP id p3KCi0Tr006004
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 22:44:00 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3KCi0ZB2457732
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 22:44:00 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3KCi0Lv008239
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 22:44:00 +1000
Date: Wed, 20 Apr 2011 22:13:53 +0930
From: Christopher Yeoh <cyeoh@au1.ibm.com>
Subject: [Resend] Re: [Resend] Cross Memory Attach v3 [PATCH]
Message-ID: <20110420221353.308ce02d@lilo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, 25 Mar 2011 23:52:25 +1030
cyeoh@ozlabs.au.ibm.com wrote:
> On Thu, 24 Mar 2011 09:20:41 +1030
> Rusty Russell <rusty@rustcorp.com.au> wrote:
>   
> > On Wed, 23 Mar 2011 12:52:13 +1030, Christopher Yeoh
> > <cyeoh@au1.ibm.com> wrote:  
> > > On Sun, 20 Mar 2011 18:55:32 -0700
> > > Andrew Morton <akpm@linux-foundation.org> wrote:  
> > > > On Mon, 21 Mar 2011 12:20:18 +1030 Christopher Yeoh
> > > > <cyeoh@au1.ibm.com> wrote:
> > > >   
> > > > > On Thu, 17 Mar 2011 12:54:27 -0700
> > > > > Andrew Morton <akpm@linux-foundation.org> wrote:  
> > > > > > On Thu, 17 Mar 2011 15:40:26 +1030
> > > > > > Christopher Yeoh <cyeoh@au1.ibm.com> wrote:
> > > > > >   
> > > > > > > > Thinking out loud: if we had a way in which a process
> > > > > > > > can add and remove a local anonymous page into
> > > > > > > > pagecache then other processes could access that page
> > > > > > > > via mmap.  If both processes map the file with a
> > > > > > > > nonlinear vma they they can happily sit there flipping
> > > > > > > > pages into and out of the shared mmap at arbitrary file
> > > > > > > > offsets. The details might get hairy ;) We wouldn't
> > > > > > > > want all the regular mmap semantics of  
> > > > > > > 
> > > > > > > Yea, its the complexity of trying to do it that way that
> > > > > > > eventually lead me to implementing it via a syscall and
> > > > > > > get_user_pages instead, trying to keep things as simple as
> > > > > > > possible.  
> > > > > > 
> > > > > > The pagecache trick potentially gives zero-copy access,
> > > > > > whereas the proposed code is single-copy.  Although the
> > > > > > expected benefits of that may not be so great due to TLB
> > > > > > manipulation overheads.
> > > > > > 
> > > > > > I worry that one day someone will come along and implement
> > > > > > the pagecache trick, then we're stuck with obsolete code
> > > > > > which we have to maintain for ever.  
> > 
> > Since this is for MPI (ie. message passing), they really want copy
> > semantics.  If they didn't want copy semantics, they could just
> > MAP_SHARED some memory and away they go...
> > 
> > You don't want to implement copy semantics with page-flipping; you
> > would need to COW the outgoing pages, so you end up copying *and*
> > trapping.
> > 
> > If you are allowed to replace "sent" pages with zeroed ones or
> > something then you don't have to COW.  Yet even if your messages
> > were a few MB, it's still not clear you'd win; in a NUMA world
> > you're better off copying into a local page and then working on it.
> > 
> > Copying just isn't that bad when it's cache-hot on the sender and
> > you are about to use it on the receiver, as MPI tends to be.  And
> > it's damn simple.
> > 
> > But we should be able to benchmark an approximation to the
> > page-flipping approach anyway, by not copying the data and doing the
> > appropriate tlb flushes in the system call.  
> 
> I've done some hacking on the naturally ordered and randomly ordered
> ring bandwidth tests of hpcc to try to simulate what we'd get with a
> page flipping approach.
> 
> - Modified hpcc so it checksums the data on the receiver. normally it
>   just checks the data in a couple of places but the checksum
> simulates the receiver actually using all of the data
> 
> - For the page flipping scenario
>   - allocate from a shared memory pool for data that is to be
>     transferred
>   - instead of sending the data via OpenMPI send some control data
>     instead which describes where the receiver can read the data in
>     shared memory. Thus "zero copy" with just checksum
>   - Adds tlb flushing for sender/receiver processes
> 
> The results are below (numbers are in MB/s, higher the better). Base
> is double copy via shared memory, CMA is single copy.
> 
> 	                     Num MPI Processes			
> Naturally Ordered	4	8	16	32
> Base	               1152	929	567	370
> CMA	               3682	3071	2753	2548
> Zero Copy	       4634	4039	3149	2852
> 				
>                       	Num MPI Processes
> Randomly Ordered       	4	8	16	32
> Base	                1154	927	588	389
> CMA	                3632	3060	2897	2904
> Zero Copy	        4668	3970	3077	2962
> 
> the benchmarks were run on a 32 way (SMT-off) Power6 machine.
> 
> So we can see that on lower numbers of processes there is a gain in
> performance between single and zero copy (though the big jump is
> between double and single copy), but this reduces as the number of
> processes increases. The difference between the single and zero copy
> approach reduces to almost nothing for when the number of MPI
> processes is equal to the number of processors (for the randomly
> ordered ring bandwidth).  

Andrew - just wondering if you had any more thoughts about this?
Any other information you were looking for?

Regards,

Chris
-- 
cyeoh@au.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
