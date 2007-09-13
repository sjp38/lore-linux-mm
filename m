Subject: Re: [PATCH/RFC 4/5] Mem Policy:  cpuset-independent interleave
	policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <46E85825.4050505@google.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
	 <20070830185122.22619.56636.sendpatchset@localhost>
	 <46E85825.4050505@google.com>
Content-Type: text/plain
Date: Thu, 13 Sep 2007 09:26:59 -0400
Message-Id: <1189690019.5013.12.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, clameter@sgi.com, eric.whitney@hp.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-09-12 at 14:20 -0700, Ethan Solomita wrote:
> 	Hi Lee -- sorry for the delay in responding. Yes, this provides exactly 
> the feature set I was interested in. One question regarding:
> 
> Lee Schermerhorn wrote:
> > 
> > However, this will involve testing possibly several words of
> > bitmask in the allocation path.  Instead, I chose to encode the
> > "context-dependent policy" indication in the upper bits of the
> > policy member of the mempolicy structure.  This member must
> > already be tested to determine the policy mode, so no extra
> > memory references should be required.  However, for testing the
> > policy--e.g., in the several switch() and if() statements--the
> > context flag must be masked off using the policy_mode() inline
> > function.  On the upside, this allows additional flags to be so
> > encoded, should that become useful.
> 
> 	Instead of creating MPOL_CONTEXT, did you consider instead creating a 
> new MPOL for this, such as MPOL_INTERLEAVE_ALL? If the only intended 
> user of the MPOL_CONTEXT "flag" is just MPOL_INTERLEAVE_ALL, it seems 
> like you'll have simpler code this way.

I did think about it, and I did see your mail about this.  I guess
"simpler code" is in the eye of the beholder.  I consider "cpuset
independent interleave" to be an instance of MPOL_INTERLEAVE using a
context dependent nodemask.  If we have a separate policy for this
[really should be MPOL_INTERLEAVE_ALLOWED, don't you think?], would we
then want a separate policy for "local preferred"--e.g.,
MPOL_PREFERRED_LOCAL?  If we did this internally, I wouldn't want to
expose it via the APIs.  We already have an established way to indicate
"local preferred"--the NULL/empty nodemask.  Can't break the API, so I
chose to use the same way to indicate "all allowed" interleave.

I agree that the MPOL_CONTEXT flag looks a bit odd [could be renamed
MPOL_ALLOWED?], but the policy_mode() wrapper hides this; and looks OK
to me.  Keeps the number of cases in the switch and comparisons to
MPOL_INTERLEAVE the same in most places.  Anyway, the MPOL_CONTEXT flag
may go away after Mel Gorman's zonelist patches get merged.  We have
some ideas for further work on the policies that may give us a different
way to indicate this.   I don't expect the policy patches to proceed
until Mel's patches settle down and get merged.  Then we can revisit
this.

Thanks,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
