Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id ACA076B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 22:33:44 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id r126so102882145oib.0
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 19:33:44 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id v13si281931itb.79.2016.09.14.19.33.40
        for <linux-mm@kvack.org>;
        Wed, 14 Sep 2016 19:33:41 -0700 (PDT)
Date: Thu, 15 Sep 2016 12:31:33 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Message-ID: <20160915023133.GR22388@dastard>
References: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
 <20160908225636.GB15167@linux.intel.com>
 <20160912052703.GA1897@infradead.org>
 <CAOSf1CHaW=szD+YEjV6vcUG0KKr=aXv8RXomw9xAgknh_9NBFQ@mail.gmail.com>
 <20160912075128.GB21474@infradead.org>
 <20160912180507.533b3549@roar.ozlabs.ibm.com>
 <20160912213435.GD30497@dastard>
 <20160913115311.509101b0@roar.ozlabs.ibm.com>
 <20160914073902.GQ22388@dastard>
 <20160914201936.08315277@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160914201936.08315277@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Oliver O'Halloran <oohall@gmail.com>, Yumei Huang <yuhuang@redhat.com>, Michal Hocko <mhocko@suse.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KVM list <kvm@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Gleb Natapov <gleb@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, mtosatti@redhat.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Stefan Hajnoczi <stefanha@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>

On Wed, Sep 14, 2016 at 08:19:36PM +1000, Nicholas Piggin wrote:
> On Wed, 14 Sep 2016 17:39:02 +1000
> Dave Chinner <david@fromorbit.com> wrote:
> > Ok, looking back over your example, you seem to be suggesting a new
> > page fault behaviour is required from filesystems that has not been
> > described or explained, and that behaviour is triggered
> > (persistently) somehow from userspace. You've also suggested
> > filesystems store a persistent per-block "no fsync" flag
> > in their extent map as part of the implementation. Right?
> 
> This is what we're talking about. Of course a filesystem can't just
> start supporting the feature without any changes.

Sure, but one first has to describe the feature desired before all
parties can discuss it. We need more than vague references and
allusions from you to define the solution you are proposing.

Once everyone understands what is being describing, we might be able
to work out how it can be implemented in a simple, generic manner
rather than require every filesystem to change their on-disk
formats. IOWs, we need you to describe /details/ of semantics,
behaviour and data integrity constraints that are required, not
describe an implementation of something we have no knwoledge about.

> > Reading between the lines, I'm guessing that the "no fsync" flag has
> > very specific update semantics, constraints and requirements.  Can
> > you outline how you expect this flag to be set and updated, how it's
> > used consistently between different applications (e.g. cp of a file
> > vs the app using the file), behavioural constraints it implies for
> > page faults vs non-mmap access to the data in the block, how
> > you'd expect filesystems to deal with things like a hole punch
> > landing in the middle of an extent marked with "no fsync", etc?
> 
> Well that's what's being discussed.  An approach close to what I did is
> to allow the app request a "no sync" type of mmap.

That's not an answer to the questions I asked about about the "no
sync" flag you were proposing. You've redirected to the a different
solution, one that ....

> Filesystem will
> invalidate all such mappings before it does buffered IOs or hole punch,
> and will sync metadata after allocating a new block but before returning
> from a fault.

... requires synchronous metadata updates from page fault context,
which we already know is not a good solution.  I'll quote one of
Christoph's previous replies to save me the trouble:

	"You could write all metadata synchronously from the page
	fault handler, but that's basically asking for all kinds of
	deadlocks."

So, let's redirect back to the "no sync" flag you were talking about
- can you answer the questions I asked above? It would be especially
important to highlight how the proposed feature would avoid requiring
synchronous metadata updates in page fault contexts....

> > [snip]
> > 
> > > If there is any huge complexity or unsolved problem, it is in XFS.
> > > Conceptual problem is simple.  
> > 
> > Play nice and be constructive, please?
> 
> So you agree that the persistent memory people who have come with some
> requirements and ideas for an API should not be immediately shut down
> with bogus handwaving.

Pull your head in, Nick.

You've been absent from the community for the last 5 years. You
suddenly barge in with a massive chip on your shoulder and try to
throw your weight around. You're being arrogant, obnoxious, evasive
and petty. You're belittling anyone who dares to question your
proclamations. You're not listening to the replies you are getting.
You're baiting people to try to get an adverse reaction from them
and when someone gives you the adverse reaction you were fishing
for, you play the victim card.

That's textbook bullying behaviour.

Nick, this behaviour does not help progress the discussion in any
way. It only serves to annoy the other people who are sincerely
trying to understand and determine if/how we can solve the problem
in some way.

So, again, play nice and be constructive, please?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
