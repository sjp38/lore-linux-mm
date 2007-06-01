Date: Fri, 1 Jun 2007 14:56:04 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Document Linux Memory Policy
In-Reply-To: <1180731944.5278.146.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706011445380.5009@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>  <200705312243.20242.ak@suse.de>
 <20070601093803.GE10459@minantech.com>  <200706011221.33062.ak@suse.de>
 <1180718106.5278.28.camel@localhost>  <Pine.LNX.4.64.0706011140330.2643@schroedinger.engr.sgi.com>
  <1180726713.5278.80.camel@localhost>  <Pine.LNX.4.64.0706011242250.3598@schroedinger.engr.sgi.com>
 <1180731944.5278.146.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, Gleb Natapov <glebn@voltaire.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 1 Jun 2007, Lee Schermerhorn wrote:

> > > I don't understand what you mean by "memory region based".
> > 
> > Memory policies are controlling allocations for regions of memory of a 
> > process. They are not file based policies (they may have been on Tru64).
> 
> By "regions of memory of a process" do you mean VMAs?  These are not
> shared between processes, so installing a policy in a VMA of one task
> will not affect pages faulted in by other cooperating tasks of the
> application.

Right. Thats how it should be.

> > Not at all. Consider a mmapped memory region by a database. The database
> > is running on nodes 5-8 and has specified an interleave policy for the 
> > data.
> 
> If the memory region is a shared mmap'd file and the data base consists
> of multiple tasks, you can't do this today if you don't want to prefault
> in the entire file]--especially if you want to keep your task policy
> default/local so that task heap and stack pages stay local.  

Well the point was that your approach leads to pretty inconsistent 
behavior that is very weird and counterintuitive for those runing the 
software.

> Red Herring.  The same scenario can occur with shmem today.  And don't
> try to play the "shmem is different" card.  For this scenario, they're
> the same.  If "node 1 task" can mmap your file and specify a different
> policy, it can attach your shmem segment and specify a different policy,
> with the same result.

Sure it shmem is different. I think it was a mistake to allow memory 
policy changes of shmem through the regular memory policy change API.
Shmem also has permissions so you can prevent the above listed scenario 
from occurring.

> And, why would the task on node 1 do that?  In this scenario, these are

Because it is a smaller version of the database that is run for some minor 
update purpose?

> not cooperating tasks; or it's an application bug.  You want to penalize
> well behaved, cooperating tasks that are part of a single application,
> sharing application private files because you can come up with scenarios
> based on non-cooperating or buggy tasks to which you've allowed access
> to your application's files?  

I do not want to penalize anyone. I want consitent and easily 
understable memory policy behavior.

> > Yes I want consistent memory policies. There are already consistency 
> > issues that need to be solved. Forcing in a Tru64 concept of file memory 
> > allocation policies will just make the situation worse.
> 
> It's NOT a Tru64 concept, Christoph.  Another Red Herring.  It's about
> consistent support of memory policies on any object that I can map into
> my address space.   And if that object is a disk-based file that lives
> in the page cache, and we want to preserve coherency between file
> descriptor and shared, memory mapped access [believe me, we do], then
> the policy applied to the object needs to affect all page allocations
> for that file--even those caused by non-cooperating or buggy tasks, if
> we allow them access to the files.

The scenario that I just described cannot occur with vma based policies.
And this is just one additional example of weird behaviors resulting from 
file based policies.

> > And shmem is not really something that should be taken as a general rule. 
> 
> I disagree.  The shared policy support that shmem is exactly what I want
> for shared mmaped files.  I'm willing to deal with the same issues that
> shmem has in order to get shared, mapped file semantics for my shared
> regions.

I think the current shmem policy approach can only be tolerated because 
shmem has other means of control that do not exist for page cache pages.

> And, Christoph, again, adding shared policy support to shared file
> mappings doesn't add any warts or inconsistent behavior that isn't
> already there with policy applied to mmap'ed files.  Default behavior is
> the same--wart-for-wart.  Yes, shared policies on mmaped files will have
> the same risks as shared policy on shmem does today--e.g., your
> scenario--but we find the shared policies on shmem useful enough that
> we've all been willing to manage that.  

Of course it adds lots of wards. Repeating:

1. Another process can modify the memory policies of a running process.

2. Policies persist after a process terminates. I.e. file is bound to node 
1, where we run a performance critical application. Now a process starts 
on node 4 using the same file that does not use memory policies but its 
allocations are redirected to node 1 where the mission critical app 
suddenly has no memory available anymore.

2. It is not clear when the file policies will vanish. The point of 
reclaim is indeterminate for the user. So sometimes the policy will vanish 
in other cases it will not.

Sorry but these semantics are not acceptable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
