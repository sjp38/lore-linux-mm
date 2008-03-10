Subject: Re: Regression:  Re: [patch -mm 2/4] mempolicy: create
	mempolicy_operations structure
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.00.0803081403460.12095@chino.kir.corp.google.com>
References: <alpine.DEB.1.00.0803061135001.18590@chino.kir.corp.google.com>
	 <alpine.DEB.1.00.0803061135560.18590@chino.kir.corp.google.com>
	 <1204922646.5340.73.camel@localhost>
	 <alpine.DEB.1.00.0803071341090.26765@chino.kir.corp.google.com>
	 <1205002171.4918.2.camel@localhost>
	 <alpine.DEB.1.00.0803081403460.12095@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Mon, 10 Mar 2008 10:58:48 -0400
Message-Id: <1205161128.5579.16.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Jackson <pj@sgi.com>, Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Sat, 2008-03-08 at 14:09 -0800, David Rientjes wrote: 
> On Sat, 8 Mar 2008, Lee Schermerhorn wrote:
> 
> > > Excuse me, but there was significant discussion about this on LKML and I 
> > > eventually did force MPOL_DEFAULT to require a non-empty nodemask 
> 
> Correction: s/non-empty/empty

That makes more sense.  I agree.  more below... 
> 
> > > specifically because of your demand that it should.  It didn't originally 
> > > require this in my patchset, and now you're removing the exact same 
> > > requirement that you demanded.
> > > 
> > > You said on February 13:
> > > 
> > > 	1) we've discussed the issue of returning EINVAL for non-empty
> > > 	nodemasks with MPOL_DEFAULT.  By removing this restriction, we run
> > > 	the risk of breaking applications if we should ever want to define
> > > 	a semantic to non-empty node mask for MPOL_DEFAULT.
> > > 
> > > If you want to remove this requirement now (please get agreement from 
> > > Paul) and are sure of your position, you'll at least need an update to 
> > > Documentation/vm/numa-memory-policy.txt.
> > 
> > Excuse me.  I thought that the discussion--my position, anyway--was
> > about preserving existing behavior for MPOL_DEFAULT which is to require
> > an EMPTY [or NULL--same effect] nodemask.  Not a NON-EMPTY one.  See:
> > http://www.kernel.org/doc/man-pages/online/pages/man2/set_mempolicy.2.html
> > It does appear that your patches now require a non-empty nodemask.  This
> > was intentional?
> > 
> 
> The first and second set did not have this requirement, but the third set 
> does (not currently in -mm), so I've changed it back.  Hopefully there's 
> no confusion and we can settle on a solution without continuously 
> revisiting the topic.
> 
> My position was originally to allow any type of nodemask to be passed with 
> MPOL_DEFAULT since its not used.  You asked for strict argument checking 
> and so after some debate I changed it to require an empty nodemask mainly 
> because I didn't want the patchset to stall on such a minor point.  But in 
> your regression fix, you expressed the desire once again to allow it to 
> accept any nodemask because the testsuite does not check for it.

Not a desire.  Just that when I fixed the MPOL_PREFERRED with empty node
mask regression, I also fixed mpol_new() not to require a non-empty
nodemask with MPOL_DEFAULT.  I didn't go the extra step to require an
empty one.  I'm tiring of the subject, as I think you are, and didn't
want to argue it anymore.  So, I was willing to "cave" on that point.

> 
> So if you'd like to do that, I'd encourage you to submit it as a separate 
> patch and open it up for review.

No, I'm quite happy if, after your patches, the APIs retain the previous
behavior w/rt nodemask error checking.

> 
> What is currently in -mm and what I will be posting shortly is the updated 
> regression fix.  All of these patches require that MPOL_DEFAULT include a 
> NULL pointer or empty nodemask passed via the two syscalls.
> 
> > Note:  in the subject patch, I didn't enforce this behavior because your
> > patch didn't [it enforced just the opposite], and I've pretty much given
> > up.  Although I prefer current behavior [before your series], if we
> > change it, we will need to change the man pages to remove the error
> > condition for non-empty nodemasks with MPOL_DEFAULT.
> > 
> 
> With my patches it still requires a NULL pointer or empty nodemask and 
> I've updated Documentation/vm/numa_memory_policy.txt to explicitly say its 
> an error if a non-empty nodemask is passed.

Good.

Do you intend for your patch entitled "[patch -mm v2] mempolicy:
disallow static or relative flags for local preferred mode" to replace
the patch that I sent in to repair the regression?  Looks that way.
I'll replace it in my tree and retest.

Lee




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
