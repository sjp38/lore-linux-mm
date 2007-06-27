Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706261517050.21844@schroedinger.engr.sgi.com>
References: <20070625195224.21210.89898.sendpatchset@localhost>
	 <Pine.LNX.4.64.0706261517050.21844@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 27 Jun 2007 14:14:37 -0400
Message-Id: <1182968078.4948.30.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, 2007-06-26 at 15:21 -0700, Christoph Lameter wrote:
> On Mon, 25 Jun 2007, Lee Schermerhorn wrote:
> 
> > Also note that because we can remove a shared policy from a "live"
> > inode, we need to handle potential races with another task performing
> > a get_file_policy() on the same file via a file descriptor access
> > [read()/write()/...].  Patch #9 handles this by defining an RCU reader
> > critical region in get_file_policy() and by synchronizing with this
> > in mpol_free_shared_policy().
> 
> You are sure that this works? 

Well, I DO need to ask Dr. RCU [Paul McK.] to take a look at the patch,
but this is how I understand RCU to work...

Paul:  could you take a look at patch #9 of the Shared Policy series?

> Just by looking at the description: It 
> cannot work. Any allocator use of a memory policy must use rcu locks 
> otherwise the memory policy can vanish from under us while allocating a 
> page. 

The only place we need to worry about is "get_file_policy()", and--that
is the only place one can attempt to lookup a shared policy w/o holding
the [user virtual] address space locked [mmap_sem] which pins the shared
mapping of the file, so the i_mmap_writable count can't go to zero, so
we can't attempt to free the policy.  And even then, it's only an issue
for file descriptor accessed page cache allocs.  Lookups called from the
fault path do have the user vas locked during the fault, so the policy
can't go away.  But, because __page_cache_alloc() calls
get_file_policy() to lookup the policy at the faulting page offset, it
uses RCU on the read side, anyway.   I should probably write up the
entire locking picture for this, huh?

> This means you need to add this to alloc_pages_current 
> and alloc_pages_node.  Possible all of __alloc_pages must be handled 
> under RCU. This is a significant increase of RCU use.

alloc_pages_current() doesn't look up shared policy--not even vma
policy.  It just grabs the task's current policy, falling back to the
[statically defined] system default_policy if no task/process policy.

alloc_pages_node() doesn't use policy at all.  Just looks up the
zonelist based on the nid and the gfp_zone()--sort of an abbreviated,
in-line zonelist_policy() call.

But, I think RCU could be used to access/free the task policy and allow
changes to the policy from outside the task.  Probably for vma policies
as well.

> 
> If we can make this work then RCU should be used for all policies so that 
> we can get rid of the requirement that policies can only be modified from 
> the task context that created it.

Yean, I think that's possible...

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
