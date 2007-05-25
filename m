Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0705251156460.7281@schroedinger.engr.sgi.com>
References: <20070524172821.13933.80093.sendpatchset@localhost>
	 <200705242241.35373.ak@suse.de> <1180040744.5327.110.camel@localhost>
	 <Pine.LNX.4.64.0705241417130.31587@schroedinger.engr.sgi.com>
	 <1180104952.5730.28.camel@localhost>
	 <Pine.LNX.4.64.0705250823260.5850@schroedinger.engr.sgi.com>
	 <1180109165.5730.32.camel@localhost>
	 <Pine.LNX.4.64.0705250914510.6070@schroedinger.engr.sgi.com>
	 <1180114648.5730.64.camel@localhost>
	 <Pine.LNX.4.64.0705251156460.7281@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 25 May 2007 17:12:32 -0400
Message-Id: <1180127552.21879.15.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-05-25 at 12:10 -0700, Christoph Lameter wrote:
> On Fri, 25 May 2007, Lee Schermerhorn wrote:
> 
> > I knew that!  There is no existing practice.  However, I think it is in
> > our interests to ease the migration of applications to Linux.  And,
> > again, [trying to choose words carefully], I see this as a
> > defect/oversight in the API.  I mean, why provide mbind() at all, and
> > then say, "Oh, by the way, this only works for anonymous memory, SysV
> > shared memory and private file mappings. You can't use this if you
> > mmap() a file shared.  For that you have to twiddle your task policy,
> > fault in and lock down the pages to make sure they don't get paged out,
> > because, if they do, and you've changed the task policy to place some
> > other mapped file that doesn't obey mbind(), the kernel doesn't remember
> > where you placed them.  Oh, and for those private mappings--be sure to
> > write to each page in the range because if you just read, the kernel
> > will ignore your vma policy."
> > 
> > Come on!  
> 
> Well if this patch would simplify things then I would agree but it 
> introduces new cornercases.

I don't think this is the case, but I could have missed something.  I've
kept the behavior identical, I think, for the default case when no
explicit shared policy is applied.  And the remaining corner case
involves those funky private mappings.  The behavior there is the same
as the current behavior.  

I have a fix for that, but it involves forcing early COW break when the
private mapping has a vma policy and the page cache page doesn't match
the policy.  I haven't posted that because: 1) is DOES add additional
checks in the nopage fault path and 2) it depends on the misplacement
check in my "migrate on fault" series.  I didn't want to muddy the water
with that yet.

> 
> The current scheme is logical if you consider the pagecache as something 
> separate. It is after all already controlled via the memory spreading flag 
> in cpusets. There is already limited control by the process.

Yes, but I have to treat some parts of my address space [mapped shared
files] differently, when it's unnecessary.

> 
> Also allowing vma based memory policies to control shared mapping is 
> problematic because they are shared. Concurrent processes may set 
> different policies. 

But with the shared policy infrastructure, all shared mappers see the
same policy [or policies].  The last one set on any given range of the
underlying file [address_space] is the one that is currently in
effect--just like shmem.  If that wasn't clear from my description, I
need to fix that.

> This would make sense if the policy could be set at a 
> filesystem level.

??? Why?  Different processes could set different policies on the file
in the file system.  The last one [before the file was mapped?] would
rule.

> 
> > And as for fixing the numa_maps behavior, hey, I didn't post the
> > defective code.  I'm just pointing out that my patches happen to fix
> > some existing suspect behavior along the way.  But, if some patch
> > submittal standard exists that says one must fix all known outstanding
> > bugs before submitting anything else [Andrew would probably support
> > that ;-)], please point it out to me... and everyone else.  And, as I've
> > said before, I see this patch set as one big fix to missing/broken
> > behavior.  
> 
> I still have not found a bug in there....

I'll send you a memtoy script to demonstrate the issue.  Next week...

> 
> Convention is that fixes precede enhancements in a patchset.

Seems like a lot of extra effort that could be applied to other tasks,
but you've worn me down.  I'll debug the numa_maps hang with hugetlb
shmem segments with shared policy in the current code base, and reorder
the patch set to handle correct display of shmem policy from all tasks
first.  Next week or so.  

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
