Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <200706291620.07452.ak@suse.de>
References: <20070625195224.21210.89898.sendpatchset@localhost>
	 <Pine.LNX.4.64.0706281840210.9573@schroedinger.engr.sgi.com>
	 <1183123836.5037.25.camel@localhost>  <200706291620.07452.ak@suse.de>
Content-Type: text/plain
Date: Fri, 29 Jun 2007 17:40:13 -0400
Message-Id: <1183153213.4988.16.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-06-29 at 16:20 +0200, Andi Kleen wrote:
> On Friday 29 June 2007 15:30:36 Lee Schermerhorn wrote:
> 
> > Firstly, the "current situation" is deficient for applications that I,
> > on behalf of our customers, care about.
> 
> So what's the specific use case from these applications? How much do 
> they lose by not having this?

Andi:

I had answered [attempted to anyway] the first question in:

	http://marc.info/?l=linux-mm&m=118105384427674&w=4

What do they lose?  The ability to control explicitly and reliably the
location of pages in shared, mapped files without prefaulting.  The only
way an application has today to guarantee the location of a file page is
to: 1) have the file opened exclusively--i.e., be the only task with the
file opened, lest some other task access the file and fault in pages; 2)
set the task policy to bind/prefer/interleave to the appropriate
node[s]; 3) prefault some range of file pages in and lock them down; 4)
change the task policy for the next range and fault that in and lock it
down;  etc, until the entire file is placed correctly--assuming the
entire file fits.  If pages of the file are already in memory, they
don't even have the option of mass migration via mbind().  They'd have
to individually migrate pages, once that sys call wrapper is available.

I'd like to just mbind() the mmap()ed range, set the policy and then
know that, as pages fault in, they'll end up obeying the policy.  If
some pages of the file are already memory resident, they can be migrated
to follow policy.  It seems so simple to me.  The fundamental support is
all there.  

I agree we need to handle some of Christoph's issues so that his
customers can't get themselves confused, playing with shared policies,
or attempting to set policies on files [and shmem!] that don't work in
all the cpusets from which the files/shmem might be accessed.  That's a
hairly problem that containers/cpusets introduce when you try to segment
a system along only 1 or 2 dimensions, leaving the rest of the
dimensions wide open for sharing...

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
