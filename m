Message-ID: <4213D1B3.4050607@sgi.com>
Date: Wed, 16 Feb 2005 17:05:23 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: manual page migration -- issue list
References: <42128B25.9030206@sgi.com> <20050215165106.61fd4954.pj@sgi.com> <20050216015622.GB28354@lnx-holt.americas.sgi.com> <20050215202214.4b833bf3.pj@sgi.com> <20050216092011.GA6616@lnx-holt.americas.sgi.com>
In-Reply-To: <20050216092011.GA6616@lnx-holt.americas.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, ak@muc.de, haveblue@us.ibm.com, marcello@cyclades.com, stevel@mwwireless.net, peterc@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

Robin Holt wrote:
> On Tue, Feb 15, 2005 at 08:22:14PM -0800, Paul Jackson wrote:
> 
>>Robin wrote:
>>
>>>If you do that for each job with the shared mapping and have overlapping
>>>node lists, you end up combining two nodes and not being able to seperate
>>>them.
>>
>>I don't see the problem.  Just don't move a task onto a node
>>until you moved the one that was already there, if any, off.
>>
>>Say, for example, you want to move a job from nodes 4, 5 and 6 to nodes
>>5, 6 and 7, respectively.  First move 6 to 7, then 5 to 6, then 4 to 5.
>>Or save some migration, and just move what's on 4 to 7, leaving 5 and
>>6 as is.
>

The customers I have talked to about this tell me that they never
imagine having a set of old and new nodes overlap.  I agree it is more
general to allow this, but resistance to the original system call I
proposed appears to be somewhat stiff.

> 
> Moving 4 to 7 will likely change the node to node distance for the
> processes within that job.  You will probably need to do the 6-7, 5-6, 4-5
> to keep relative distances the same.  Again, the batch scheduler will tell
> us whether a simple 4-7 move is possible or whether we need to shift each.
> 
> I should correct my earlier add.  As long as you have a seperate node
> in the new list that is not in the old, you could accomplish it with a
> one-at-a-time fashion.  What that would result in is a syscall for each
> non-overlapping vma per node.  Multiple that by the number of nodes with
> each system call going over that same shared vma.
> 
> For the sake of discussion, lets assume this is a 256p job using 128 nodes
> and a shared message block of 2GB per task.  You will have a 512GB shared
> mapping which will have some holes punched in it (no single task will
> have the entire mapping unscathed).  Again, for the sake of discussion,
> let's assume that 96% of the shared buffer is intact for the process we
> choose to do the initial migration on.  Compare the single node method
> to the array method.

Would we really ever migrate something that big?  I had the same concerns
about large address spaces and the like, but it just seems to me that if
something is that big, we'd leave it alone.  :-)

> 
> Array method:
> 1) Call system call with pid, va_start, va_end, 128, [2,3,4,5...], [32,33,34,...].
>    This will scan the page tables _ONCE_ and migrate the pages to their
>    new destination.
> 2) Call system call on second pid to cover 1/2 of the remaining
>    4% of address space.  Again single scan over that portion of
>    address space.
> 3) Call system call on third pid to cover last portion of address
>    space.
> 
> With this, we have made 3 system calls and scanned the entire address
> range 1 time.
> 
> Single parameter method:
> 1) For a single pid, cal system call 128 times with pid, va_start, va_end, from, to
>    which scans the 96% chunk 128 times.
> 2) Repeat 128 times with second pid.
> 3) Repeat 128 times with third pid.
> 
> We have now made the system call 384 times, scanned the entire address
> range 128 times.
> 
> Do you see why I called this insane.  This is all because you don't like
> to pass in a complex array of integers.  That seems like a very small
> thing to ask to save 127 scans of a 512GB address space.
> 

I agree, it sounds like a lot of work.  Perhaps we should try this with
my prototype code and see how long it takes.  But, I really think this is
a contrived example.  I don't think anyone would migrate a job that big.
To my way of thinking, the largest job we would ever migrate would be on
the order of 1/8th to 1/4 of the machine.  Not 1/2.  If it is 1/2 of
the machine, lets just leave the darn thing where it is.  :-)  (I always
try to let large sleepling dogs lie...)

> I believe that is what I called insane earlier.  I reserve the right to
> be wrong.
> 
> 
>>At any point, either there is at least one new node not currently
>>occupied by some not yet migrated task, or else you're just reshuffling
>>a set of tasks on the same set of nodes, which I presume would be
>>without purpose and so we don't need to support.  If we did need to
>>support shuffling a job on its current node set, I'd have to plead
>>insanity, and reintroduce the temporary node hack.
>>
>>
>>
>>>Unfortunately it does happen often for stuff like shared file mappings
>>>that a different job is using in conjuction with this job.
>>
>>This might be the essential detail I'm missing.  I'm not sure what you
>>mean here (see P.S., at end), but it seems that you are telling me you
>>must have the ability to avoid moving parts of a job.  That for a given
>>task, pinned to a given cpu, with various physical pages on the node
>>local to that cpu, some of those pages must not move, because they are
>>used in conjunction with some other job, that is not being migrated at
>>this time.
> 
> 
> For the simple case assume a sysV shared memory segment that was created
> by a previous job being used by this one.  The memory placement for
> the segment will depend entirely on whether the previous job touched a
> particular page and where that job ran.  It may get migrated depending
> upon if any other jobs anywhere else are on the system and are using it
> and any of the pages are on the jobs old node list.
> 
> These types of mappings have always given us issues (Irix as well as
> Linux) and are difficult to handle.  The one additional nice feature to
> having an external migration facility is we might be able to use this
> type of thing from a command line to move the shared memory segment
> over to nodes that the job is using.  This has just been off the cuff
> thinking lately and hasn't been fully thought through.
> 
> 
>>P.S. - or perhaps what you're telling me with the bit about shared file
>>mappings is not that you must not move any such shared file pages as
>>well, but that you'd rather not, as there are perhaps many such pages,
>>and the time spent moving them would be wasted.  Are you saying that you
>>want to move some subset of a jobs pages, as an optimization, because
>>for a large chunk of pages, such as for some files and libraries shared
>>with other jobs, the expense of migrating them would not be paid back?
> 
> 
> I believe Ray's proposed userland piece would migrate shared libraries
> used exclusively by this job.  Was that right Ray?
>

Yes, that was the intent.

> Here is my real question.  How much opposition is there to the array
> of integers?  This does not seem like a risky interface to me.  If there
> is not a lot of opposition to the arrays, can we discuss the rest of
> the proposal and accept the arrays for the time being?  The array can
> be addressed once we know that the syscall for migrating idea is sound.
> 
> 
> Thanks,
> Robin
> 


-- 
-----------------------------------------------
Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
	 so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
