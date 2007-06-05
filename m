Subject: Re: [PATCH] Document Linux Memory Policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706041444010.26764@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>
	 <1180976571.5055.24.camel@localhost>
	 <Pine.LNX.4.64.0706041003040.23603@schroedinger.engr.sgi.com>
	 <200706042223.41681.ak@suse.de>
	 <Pine.LNX.4.64.0706041444010.26764@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 05 Jun 2007 10:30:04 -0400
Message-Id: <1181053804.5144.69.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Gleb Natapov <glebn@voltaire.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-06-04 at 14:51 -0700, Christoph Lameter wrote:
> On Mon, 4 Jun 2007, Andi Kleen wrote:
> 
> > > The other issues will still remain! This is a fundamental change to the
> > > nature of memory policies. They are no longer under the control of the
> > > task but imposed from the outside. 
> > 
> > To be fair this can already happen with tmpfs (and hopefully soon hugetlbfs
> > again -- i plan to do some other work there anyways and will put 
> > that in too) . But with first touch it is relatively benign.
> 
> Well this is pretty restricted for now so the control issues are not that
> much of a problem. Both are special areas of memory that only see limited 
> use.
> 
> But in general the association of memory policies with files is not that 
> clean and it would be best to avoid things like that unless we first clean 
> up the semantics.

Check out the behavior of mmap(MAP_ANONYMOUS|MAP_SHARED) and mbind().
You get a shared file with shared policies.  Andi's shared policy
infrastructure works fine with all file objects to which it has been
applied.  Exactly the semantics one would expect with a shared object. 

I agree that for this usage, control issues are essentially non-existent
because the file is private to the application.   And, I don't know how
wide spread the use of mmap(MAP_ANONYMOUS|MAP_SHARED) is, but I would
expect it to be used fairly widely by a multi-process application.

We can discuss semantics, clean or otherwise, when we have more shared
context vis a vis the models.

>  
> > > If one wants to do this then the whole 
> > > scheme of memory policies needs to be reworked and rethought in order to
> > > be consistent and usable. For example you would need the ability to clear
> > > a memory policy.
> > 
> > That's just setting it to default.
> 
> Default does not allow to distinguish between no memory policy set and 
> the node local policy. This becomes important if you need to arbitrate 
> multiple processes setting competing memory policies on a file page range. 

I agree with Christoph here.  I haven't started the patch yet, but I
think we can define a 'MPOL_DELETE' policy that deletes any policies on
object in the specified virtual address range for mbind().  This would
provide an interface for removing policy from shared, mapped files if
one wanted the policies to persist after last unmap.

For set_mempolicy() it can simply remove the task policy, restoring it
to system default.

Persistence is another area that I agree needs work.  As I see it, the
options are:

1) let the policies persist until the inode is recycled.  This can only
happen when there are no mappers.  This is, in fact, what my patches do
today.  I'm not suggesting this is the right way.  I just haven't
decided, nor has anyone suggested to me, what the desirable semantics
would be.

2) remove the policy on last unmap.  We'll need a way to detect last
unmap, but shouldn't be too difficult.

3) require the inode to persist while any policies are attached.  Then,
we'd need a way to list the files hanging around because policies exist,
and a way to remove the policies.  The latter is the easier of the two,
I think:  enhance numactl to take a --delete <file-path> option that
mmaps() the entire file range shared and issues mbind() with the
MPOL_DELETE mode mentioned above.  I'll have to look into listing files
with just a policy reference holding the inode.  

I think #2 is relatively easy to do and has the semantics I need, where
the shared policy is established at application startup.  #3 is the most
work, and therefore should have a compelling use case.  One use case
would be to set shared file policy via numactl and have it persist after
numactl exits w/o risk of the inode being recycled before you could
start the application for which you've set up the file policy.  Maybe
this is what Andi has been thinking but not saying?

> Right now we are ducking issues here it seems. If a process with higher 
> rights sets the node local policy then another process with lower right 
> should not be able to change that etc.

Yes, we must solve access control if you think this is a problem.  We
have file permissions for controlling access to the contents of files.
If you think it necessary, we can require, say, write permission to set
policy.  After all a task with write permission can corrupt the
contents.  Seems much more serious, to me, than setting the policy
behind some other task's back.

> 
> > Frankly I think this whole discussion is quite useless without discussing 
> > concrete use cases. So far I haven't heard any where this any file policy
> > would be a great improvement. Any further complication of the code which
> > is already quite complex needs a very good rationale.

Andi:

The use case is multi-process applications that use memory mapped files
as initialized shared memory regions with writeback semantics.  We have
customers with applications that do this.  The files tend to be large
and cache behavior relatively poor--so locality matters.  Typically,
even predating NUMA, these applications have had a single process that
sets up the environment at application start up.  Where these
applications use uninitialized shared memory [SysV shmem], the init task
would create that, if necessary [they don't survive reboot], mmap shared
files, ... When NUMA came along, the init task was the logical place to
establish locality on shmem and shared files.  After that, "first touch"
faults in the pages.  In the shared objects that have explicit policy,
that policy controls the placement, as desired.  For process heap,
stack, ... where no policy has been applied, the process gets local
allocation, as desired.

I don't think this complicates the code.  I'd like to think that my
patches actually clean things up a bit [no disrespect intended ;-)].
The basic shared policy infrastructure supports the desired semantics on
all shared files [all page cache pages!] except disk back files.  These
are the "odd-man" out.  I'd love to get down to discussing the technical
aspects of the patches, but I understand that we need to agree on the
models and use cases first.

> 
> In general I agree (we have now operated for years with the current 
> mempolicy semantics and I am concerned about any changes causing churn for 
> our customers) but there is also the consistency issue. Memory policies do 
> not work in mmapped page cache ranges which is surprising and not 
> documented.

I am willing to update the documentation for the new behavior.  That's
why I started the documenation thread.  I have already sent you a patch
to update the policy man pages to define current behavior.  

Default behavior would continue to be as it is today.  If any programs
are setting policy on address ranges backed by files mapped shared, they
aren't getting what they expect today.   The policy is ignored.  They
can't expect that, else why would then have called mbind() or one of the
libnuma wrappers().  In fact the 2.51 man pages that I grabbed from
Michael Kerrisk states in the mbind.2 NOTES section that mbind() isn't
supported on file mappings.  I enhanced that a bit to indicate that this
is true for files mapped with MAP_SHARED.  I should update the patch to
emphasize that it's only true for regular disk backed files.

If none of your customers are using shared mapped files this way today,
then it won't affect them.  This is why I don't understand the
objections on behavioral grounds [I do understand we have a disconnect
on the model of processes/address spaces/memory objects/... that we need
to sort out].  However, it such applications do exist that will be
surprised if shared file policies suddenly start working, we could make
them controllable on a per cpuset [container] basis.  Might be a good
idea in any case... if we can sort out the model issue.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
