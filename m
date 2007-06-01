Subject: Re: [PATCH] Document Linux Memory Policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706011242250.3598@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>
	 <200705312243.20242.ak@suse.de> <20070601093803.GE10459@minantech.com>
	 <200706011221.33062.ak@suse.de> <1180718106.5278.28.camel@localhost>
	 <Pine.LNX.4.64.0706011140330.2643@schroedinger.engr.sgi.com>
	 <1180726713.5278.80.camel@localhost>
	 <Pine.LNX.4.64.0706011242250.3598@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 01 Jun 2007 17:05:43 -0400
Message-Id: <1180731944.5278.146.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Gleb Natapov <glebn@voltaire.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-06-01 at 12:48 -0700, Christoph Lameter wrote:
> On Fri, 1 Jun 2007, Lee Schermerhorn wrote:
> 
> > > Same here and I wish we had a clean memory region based implementation.
> > > But that is just what your patches do *not* provide. Instead they are file 
> > > based. They should be memory region based.
> > > 
> > > Would you please come up with such a solution?
> > 
> > Christoph:
> > 
> > I don't understand what you mean by "memory region based".
> 
> Memory policies are controlling allocations for regions of memory of a 
> process. They are not file based policies (they may have been on Tru64).

By "regions of memory of a process" do you mean VMAs?  These are not
shared between processes, so installing a policy in a VMA of one task
will not affect pages faulted in by other cooperating tasks of the
application.

Actually, in Tru64, policies were attached to those "memory
object"--separate from the inode, but still shared by all mappings of
the file in separate tasks.  [Bob Picco's design, IIRC.]  Doesn't matter
where you attach the policies.  You need to share them between tasks and
they need to control allocations of pages for the mapping--pages that
happen to live in the page cache.

> 
> > So, for a shared memory mapped file, the inode+address_space--i.e., the
> > in-memory incarnation of the file--is as close to a "memory region" as
> 
> Not at all. Consider a mmapped memory region by a database. The database
> is running on nodes 5-8 and has specified an interleave policy for the 
> data.

If the memory region is a shared mmap'd file and the data base consists
of multiple tasks, you can't do this today if you don't want to prefault
in the entire file]--especially if you want to keep your task policy
default/local so that task heap and stack pages stay local.  

Maybe you're thinking of a multithreaded task?  You're right.  You don't
need shared policy.  You've only got one address space mapping the file.
And one page table...  Somewhat problematic on NUMA systems, as you've
pointed out in the context of Nick's page cache replication patch/rfc.
One reason to use separate tasks sharing files and shmem on a NUMA
system.

> 
> Now another process starts on node 1 and it also mapped to mmap the same 
> file used by the database. It specifies allocation on node 1 and then 
> terminates.
> 
> Now the database will attempt to satisfy its big memory needs from node 1?
> 
> This scheme is not working.

Red Herring.  The same scenario can occur with shmem today.  And don't
try to play the "shmem is different" card.  For this scenario, they're
the same.  If "node 1 task" can mmap your file and specify a different
policy, it can attach your shmem segment and specify a different policy,
with the same result.

And, why would the task on node 1 do that?  In this scenario, these are
not cooperating tasks; or it's an application bug.  You want to penalize
well behaved, cooperating tasks that are part of a single application,
sharing application private files because you can come up with scenarios
based on non-cooperating or buggy tasks to which you've allowed access
to your application's files?  

As it stands today, and as we've been discussing with Gleb, a multitask
application cannot map a file shared and place different ranges on
different nodes reliably without prefaulting in all of the pages.  Gleb
was even willing to install the identical policies from each
task--something I don't think he should have to do--but even this would
not achieve his desired results.  This is much more serious shortcoming
than the scenario you describe above.  We CAN prevent your scenario.
Just don't give non-cooperating tasks access to files whose
policy/location you care about?  Same as for shmem.

> 
> > You're usually gung-ho about locality on a NUMA platform, avoiding off
> > node access or page allocations, respecting the fast path, ...  Why the
> > resistance here?
> 
> Yes I want consistent memory policies. There are already consistency 
> issues that need to be solved. Forcing in a Tru64 concept of file memory 
> allocation policies will just make the situation worse.

It's NOT a Tru64 concept, Christoph.  Another Red Herring.  It's about
consistent support of memory policies on any object that I can map into
my address space.   And if that object is a disk-based file that lives
in the page cache, and we want to preserve coherency between file
descriptor and shared, memory mapped access [believe me, we do], then
the policy applied to the object needs to affect all page allocations
for that file--even those caused by non-cooperating or buggy tasks, if
we allow them access to the files.

> 
> And shmem is not really something that should be taken as a general rule. 

I disagree.  The shared policy support that shmem is exactly what I want
for shared mmaped files.  I'm willing to deal with the same issues that
shmem has in order to get shared, mapped file semantics for my shared
regions.

> Shmem allocations can be controlled via a kernel boot option. They exist 
> even after a process terminates. etc etc.

Once again.  If you have a use case for shared file policies persisting
after the process terminates [and I suspect not, 'cause you don't even
want them in the first place] then raise that as a requirement.  We can
add that--as a subsequent patch.  If you have a use case for policies
persisting over system reboot [shmem policies don't, by the way], I
expect the file system folks could come up with a way to attach policies
to files that get loaded when the file is opened or when mmap'ed.  It
would still require the in-kernel mechanism to attach policies to the
in-memory structure[s].  This capability is useful without either.

And, Christoph, again, adding shared policy support to shared file
mappings doesn't add any warts or inconsistent behavior that isn't
already there with policy applied to mmap'ed files.  Default behavior is
the same--wart-for-wart.  Yes, shared policies on mmaped files will have
the same risks as shared policy on shmem does today--e.g., your
scenario--but we find the shared policies on shmem useful enough that
we've all been willing to manage that.  

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
