Subject: Re: [PATCH 2.6.17-rc1-mm1 0/6] Migrate-on-fault - Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0604111134350.1027@schroedinger.engr.sgi.com>
References: <1144441108.5198.36.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0604111134350.1027@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 11 Apr 2006 16:40:14 -0400
Message-Id: <1144788015.5160.134.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>, ak@suse.com
List-ID: <linux-mm.kvack.org>

On Tue, 2006-04-11 at 11:46 -0700, Christoph Lameter wrote:
> On Fri, 7 Apr 2006, Lee Schermerhorn wrote:
> 
> > Note that this mechanism can be used to migrate page cache pages that 
> > were read in earlier, are no longer referenced, but are about to be
> > used by a new task on another node from where the page resides.  The
> > same mechanism can be used to pull anon pages along with a task when
> > the load balancer decides to move it to another node.  However, that
> > will require a bit more mechanism, and is the subject of another
> > patch series.
> 
> The fundamental assumption in these patchsets is that memory policies are 
> permanently used to control allocation. However, allocation policies may 
> be temporarily set to various allocation methods in order to allocate 
> certain memory structures in special ways. The policy may be reset later 
> and not reflect the allocation wanted for a certain structure when the 
> opportunistic or lazy migration takes place.

Yes, that is the fundamental assumption.  That pages follow their
policies to the extent that the system is capable of enforcing this.  I
have always assumed that applications only played the games with
changing the policies the way you describe because of the limitations of
the current implementation.  If the system always did what you said vis
a vis the policy, then why change it to something that's not what you
want?

> 
> Maybe we can use the memory polices in the way you suggest (my 
> MPOL_MF_MOVE_* flags certainly do the same but they are set by the coder 
> of the user space application who is aware of what is going on !). 
> 
> But there are significant components missing to make this work the right 
> way. In particular file backed pages are not allocated according to vma 
> policy. Only anonymous pages are. So this would only work correctly for 
> anonymous pages that are explicitly shifted onto swap. 

Right.  You mentioned this in the prior mail and in off-list exchanges
we've had.  I agree.  IMO, this is another area where work could be
done.  I'd be willing to tackle that as part of this effort if I can
understand what it is that would be acceptable.

> 
> I think there will be mostly correct behavior for file backed pages. Most 
> processes do not use policies at all and so this will move the file 
> backed page to the node where the process is executing. If the process 
> frequently refers to the page then the effort that was expended is 
> justified. However, if the page is not frequently references then the 
> effort required to migrate the page was not justified.

Well, the migration wouldn't have occurred unless the task just happened
to touch the page at a point where 1) it's in the cache, 2) no tasks
have any pte's referencing the page [mapcount ==0] and 3) its location
does not follow applicable policy--WHATEVER that is.  This is similar to
what would happen for the first task to touch a page after it has been
evicted from the cache for some reason, right?

> 
> For some processes this has the potential to actually decreasing the 
> performance, for other processes that are using memory policies to 
> control the allocation of structures it may allocate the page in a way 
> that the application tried to avoid because it may be using the wrong 
> memory policy.

Probably true.  Just as migrating task away from their memory due to
scheduling load imbalances can decrease the performance of the affected
task and, possibly, tasks on the node where it's left behind memory
resides.  We need to ensure that users who have gone to a great deal of
trouble to layout their application don't get burned.  However, I'd also
like to provide some benefit for applications that haven't been
carefully hand tuned/bound to the configuration.

> 
> Then there is the known deficiency that memory policies do not work with 
> file backed pages. I surely wish that this would be addressed first.

Without more information, I suspect that my approach to that may not be
what you had in mind.  I discussed some ideas in response to other
messages in this series.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
