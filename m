Subject: Couple of questions about mempolicy rebinding
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.00.0803131255150.32474@chino.kir.corp.google.com>
References: <200803122118.03942.ak@suse.de>
	 <alpine.DEB.1.00.0803131219380.28673@chino.kir.corp.google.com>
	 <1205437802.5300.69.camel@localhost>
	 <alpine.DEB.1.00.0803131255150.32474@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Mon, 17 Mar 2008 16:36:47 -0400
Message-Id: <1205786207.5297.30.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>, David Rientjes <rientjes@google.com>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, cpw@sgi.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Paul, David:

Like the subject says, I have a couple of questions that arose while
looking through the mempolicy code for corner cases that might be
affected by some pending cleanup patches.  Nothing major, I think, I
just want to understand.  I'm looking at 25-rc5-mm1 plus the recent
patch:  "disallow static or relative flags for local preferred".

1) In __mpol_copy():  when the "current_cpuset_is_being_rebound", why do
we rebind the old policy policy and then copy it to the new?  Seems like
the old policy will get rebound in due time if, indeed, it needs to be
rebound.  I don't see any usage now, where it won't, but this seems less
general than just rebinding the new copy.  E.g., the old mempolicy being
copied may be a context-free policy that shouln't be rebound.   I think
we should at least add a comment to warn future callers.  Comments?

2) In mpol_rebind_nodemask():  this function is shared by bind and
interleave policy, and is used to rebind both task and vma policies.
However, we unconditionally update current->il_next.  Probably not an
issue for interleave vs bind because, in the case of bind policy,
il_next is meaningless.  However, il_next is used only to interleave
based on task policy [for page cache and slab allocations].  Any
allocation based on a vma policy will use the address offset into the
vma to interleave.  So, I think it's technically incorrect to update
il_next when we're rebinding a vma policy.  It may contain nodes that
are not in the task policy and vice versa.  

If we were to address this, a couple of methods come to mind:

a) add an internal mode flag--e.g., MPOL_F_TASK_POLICY--to indicate task
vs vma policy to the rebind ops, or

b) pass a task vs vma flag parameter to mpol_rebind_policy() and down to
the rebind ops.  However, how would we tell in __mpol_copy() which we're
dealing with?

Comments?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
