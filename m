Subject: Re: [PATCH 2.6.24-mm1]  Mempolicy:  silently restrict nodemask to
	allowed nodes V3
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.00.0802121632170.3291@chino.kir.corp.google.com>
References: <alpine.LFD.1.00.0802092340400.2896@woody.linux-foundation.org>
	 <1202748459.5014.50.camel@localhost>
	 <20080212091910.29A0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <alpine.DEB.1.00.0802111649330.6119@chino.kir.corp.google.com>
	 <1202828903.4974.8.camel@localhost>
	 <alpine.DEB.1.00.0802121100211.9649@chino.kir.corp.google.com>
	 <1202861240.4974.25.camel@localhost>
	 <alpine.DEB.1.00.0802121632170.3291@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Wed, 13 Feb 2008 09:32:43 -0700
Message-Id: <1202920363.4978.69.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-02-12 at 16:42 -0800, David Rientjes wrote:
> On Tue, 12 Feb 2008, Lee Schermerhorn wrote:
> 
> > > MPOL_DEFAULT is the default system-wide policy that does not require a 
> > > nodemask as a parameter.  Both the man page (set_mempolicy(2)) and the 
> > > documentation (Documentation/vm/numa_memory_policy.txt) state that.
> > > 
> > > It makes no sense in the future to assign a meaning to a nodemask passed 
> > > along with MPOL_DEFAULT.  None at all.  
> > 
> > Again, you're stating an opinion, to which you're entitled, or
> > expressing a limitation to your clairvoyance, for which I can't fault
> > you.  Indeed, I tend to agree with you on this particular point--my own
> > opinion and/or lack of vision.  However, I've been burned in the past by
> > just this scenario--wanting to assign meaning to something that was
> > ignored--because it could break existing applications.  So, on general
> > principle, I like to be fairly strict with argument checking [despite my
> > natural libertarian tendencies].
> > 
> 
> It's currently undefined behavior.  Neither the Linux documentation 
> (Documentation/vm/numa_memory_policy.txt) nor the man page 
> (set_mempolicy(2)) state the meaning of a nodemask passed with 
> MPOL_DEFAULT.
> 
> The man page simply says the nodemask should be passed as NULL and the 
> documentation state that MPOL_DEFAULT "does not use the optional set of 
> nodes."
> 
> So what we do with that nodemask is an implementation detail that does not 
> need to conform to any pre-defined API or even the possibility that one 
> day it will become useful.  In the context of the documentation, it is 
> logical that any nodemask that is passed with MPOL_DEFAULT is valid since 
> it's not used at all.
> 
> As you know, mempolicies can already morph into being effected over a 
> subset of nodes that was passed with set_mempolicy() or mbind() without 
> knowledge to the user.  That requires get_mempolicy() to determine.  
> Changing a non-empty nodemask passed with MPOL_DEFAULT to an empty 
> nodemask because it has no logical meaning is nothing new.

I think we're beating a dead horse here.  However, one more
consideration:

I'm not sure why you don't want to require the nodemask to be NULL/empty
in the case of MPOL_DEFAULT.  Perhaps it's from a code complexity
viewpoint.  Or maybe you think we're being kind to the programmer by
cutting them some slack.  Vis a vis the latter, I would argue that we're
not doing a programmer any favor by letting this slide by.  MPOL_DEFAULT
takes no nodemask.  So, if a non-empty nodemask is passed, the
programmer has done something wrong. 

Perhaps this was intentional:  Say, they did a cut and paste of another
set_mempolicy() call, changed the policy to DEFAULT and left the
nodemask args refering to a non-empty node mask.   In that case,
allowing it does no harm.

But, perhaps they intended a different policy and forgot to change the
MPOL_DEFAULT to that policy.  If we didn't complain about the non-empty
node mask, this could be a very tricky bug to diagnose.  

Since it's easy [and, IMO, advisable] for the kernel to be strict about
argument checking, I say do it.  I understand if you or other don't
agree.  I just want us to understand where each other is coming from
[and own up to our opinions as such].  I think this will be useful in
future interactions, of which I hope there are many.

> 
> > > The policy is simply the 
> > > equivalent of default_policy and, as the system default, a nodemask 
> > > parameter to the system default policy is wrong be definition.  
> > > 
> > > So, logically, we can either allow all nodemasks to be passed with a 
> > > MPOL_DEFAULT policy or none at all (it must be NULL).  Empty nodemasks 
> > > don't have any logical relationship with MPOL_DEFAULT.
> > 
> > Ah, maybe this explains our disconnect.  Internally, a NULL nodemask
> > pointer specified by the application is equivalent to an empty nodemask
> > is equivalent to maxnode == 0.  See get_nodes().  By the time
> > mpol_check_policy() or mpol_new() get called, all they have is a pointer
> > to the cleared nodemask in the stack frame of sys_set_mempolicy() or
> > sys_mbind().  So, the existing code's error checking doesn't require one
> > to specify a non-NULL, but empty nodemask.  It just requires that one
> > does not specify any nodes with MPOL_DEFAULT.  
> > 
> 
> You were previously arguing from an API or "reserved for future-use" 
> standpoint and now you're arguing from an implementation standpoint.  Both 
> of which are very different from each other.
> 
> The implementation can change to deal with this however we want (as I did 
> in my patchset), so arguing in support of what mpol_new() or 
> mpol_check_policy() currently do is irrelevant.  


Sorry.  I wasn't "arguing" here.  I interpreted your last couple of
paragraphs as indicating that you thought I was advocating a non-NULL,
but empty nodemask.  Based on that interpretation, I was pointing out
that the implementation hands mpol_check_policy() [now in mpol_new()]
and empty nodemask in all three equivalent cases mentioned above.  So,
by testing that, we can determine whether or not the user specified a
non-NULL, non-empty nodemask with MPOL_DEFAULT.  That's all I meant.

Lee
> 
> 		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
