Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <200705252301.00722.ak@suse.de>
References: <20070524172821.13933.80093.sendpatchset@localhost>
	 <Pine.LNX.4.64.0705250914510.6070@schroedinger.engr.sgi.com>
	 <1180114648.5730.64.camel@localhost>  <200705252301.00722.ak@suse.de>
Content-Type: text/plain
Date: Fri, 25 May 2007 17:41:11 -0400
Message-Id: <1180129271.21879.45.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-05-25 at 23:01 +0200, Andi Kleen wrote:
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
> But "you can set policy but we will randomly lose it later" is also
> not very convincing, isn't it? 

My patches don't randomly lose the policy as long as some application
has the file open/mapped.  Yeah, shmem shared policies are slightly more
persistent--they can hang around with no mappers, but you lose the
shared policy on reboot.  So, the first application to attach after
[re]boot has to mbind().  Same thing for shared mapped files.  The first
task to mmap has to set policy.  Applications with multiple tasks that
share shmem segments or application-specific shared, mmap()ed files
usually have one task that sets up the environment that handles this
sort of thing for the rest of the tasks.

> 
> I would like to only go forward if there are actually convincing
> use cases for this.

Consider it maintenance ;-).

> 
> The Tru64 compat argument doesn't seem too strong to me for this because
> I'm sure there are lots of other incompatibilities too.

I'm not looking for "compatibility" as much as functional parity...  And
we're so close to having sensible semantics.  It could "just work"...

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
> In Linux the deal is usually kind of :- the more you care about general
> code maintenance the more we care about your feature wishlists.
> So fixing bugs is usually a good idea.

As I've said, I view this series as addressing a number of problems,
including the numa_maps hang when displaying hugetlb shmem segments with
shared policy [that one by accident, I admit], the incorrect display of
shmem segment policy from different tasks, and the disconnect between
mbind() and mapped, shared files [one person's defect is another's
feature, or vice versa ;-)].  However, I will look at reordering the
series to fix the hang and incorrect display first.

Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
