Subject: Re: Poor DBT-3 pgsql 8way numbers on recent 2.6 mm kernels
From: Mary Edie Meredith <maryedie@osdl.org>
Reply-To: maryedie@osdl.org
In-Reply-To: <20040313134842.78695cc6.akpm@osdl.org>
References: <1079130684.2961.134.camel@localhost>
	 <20040312233900.0d68711e.akpm@osdl.org> <405379ED.A7D6B1E4@us.ibm.com>
	 <20040313134842.78695cc6.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1079369109.2961.181.camel@localhost>
Mime-Version: 1.0
Date: Mon, 15 Mar 2004 08:45:10 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: badari <pbadari@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sat, 2004-03-13 at 13:48, Andrew Morton wrote:
> badari <pbadari@us.ibm.com> wrote:
> >
> > Andrew,
> > 
> > We don't see any degradation with -mm trees with DSS workloads.
Is your database using direct I/O?  PostgreSQL does not and 
that could be the difference.  Also we are doing very little
I/O during this part of the run--only at the beginning of
the Throughput part until the database gets cached in the
page cache.  The database size is very small compared to 
most DSS workloads.  

> > Meredith mentioned that the workload is "cached". Not much
> > IO activity. I wonder how it can be related to readahead ?
If by readahead you mean file system readahead, then I do not
think that would make a difference with this part of the 
workload, as there is not much Physical IO in the throughput
part of the workload. (I am assuming that fs readahead would
result in physical I/O's but I admit some degree of 
ignorance about file system behavior). 
> 
> Well I don't know what "cached" means really.  

On the 8way STP systems there is a total of 8GB of memory.
The memory remaining after database structures leave 
enough such that most of the database will fit
in page cache. Thus once it is read, any further references
by the database will pull from the page cache rather than
do a physical I/O.  This is what I mean by "cached".  

> That's a reoccurring problem
> with these complex performance tests which some groups are running: lack of
> the really detailed information which kernel developers can use, long
> turnaround times in gathering followup information, even slow email
> turnaround times.  It's been a bit frustrating from that point of view.

Sorry,  I could list why this is, but it wouldn't change the fact.  I
hope that I can provide some clarity.  
> 
> I read the dbt3-pgsql setup docs.  It looks pretty formidable.  For a
> start, it provides waaaaaaaaaay too many options.  Sure, tell people how to
> tweak things, but provide some simple, standardised setup with works
> out-of-the-box.  Maybe it does, I don't know.
Yes, there are many options.  That's why we set it up on STP in a way
that makes sense for that machine characteristic. The
setting used by STP (what I called the default) is what is
reasonable for that system size.
> 
> 
> 
> Anyway, if it means that the database is indeed in pagecache and this test
> is not using direct-io then presumably there's a lot of synchronous write
> traffic happening and not much reading?   A vmstat strace would tell.
> 
There is little to no synch write activity.  There are no 
database transactions after the first few minutes of the
throughput phase when the updates occur. After that it 
is all reads, so there is no logging, which would be 
the cause of synch writes.

vmstat info is at:
http://khack.osdl.org/stp/289860/results/plot/thuput.vmstat.txt

In fact at that top level URL:
http://khack.osdl.org/stp/289860/

You can get more stats (sar for example).  Be sure to look at
things referenced as "throughput" or "thuput" as the problem
is in this part of the test.  The "load" and "power" portions
are fine.  (The power portion is the single stream part - one
process running a query).  



> And if that is indeed the case I'd be suspecting the CPU scheduler.  But
> then, Meredith's profiles show almost completely idle CPUs.
> 
> The simplest way to hunt this down is the old binary-search-through-the-patches process.  But that requires some test which takes just a few minutes.

If you are referring to a binary search to find when the
performance changed, I can do this with STP.  It may take 
some time, but I'm willing.  I didnt want to do that if 
the problem was a known problem.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
