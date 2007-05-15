Subject: Re: [PATCH 00/15] per device dirty throttling -v6
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <17993.15236.442636.502640@notabene.brown>
References: <20070510100839.621199408@chello.nl>
	 <17993.15236.442636.502640@notabene.brown>
Content-Type: text/plain
Date: Tue, 15 May 2007 09:44:49 +0200
Message-Id: <1179215089.6810.128.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 2007-05-15 at 14:48 +1000, Neil Brown wrote:
> On Thursday May 10, a.p.zijlstra@chello.nl wrote:
> > The latest version of the per device dirty throttling patches.
> > 
> > I put in quite a few comments, and added an patch to do per task dirty
> > throttling as well, for RFCs sake :-)
> > 
> > I haven't yet come around to do anything but integrety testing on this code
> > base, ie. it built a kernel. I hope to do more tests shorty if time permits...
> > 
> > Perhaps the people on bugzilla.kernel.org #7372 might be willing to help out
> > there.
> > 
> > Oh, patches are against 2.6.21-mm2
> > 
> > -- 
> 
> Patch 12 has:
>   +#include <linux/proportions.h>
> 
> But that file isn't added until patch 14.

Oops :-)

> Splitting the "proportions" stuff out into lib/ is a good idea.
> You have left some remnants of it's origin though, which mentions of
>    BDI
>    pages
>    total page writeback
> 
> The "proportions" library always uses a percpu counter, which is
> perfect of the per-bdi counter, but seems wrong when you use the same
> code for per-task throttling.  Have a percpu counter in struct task
> seems very wasteful.  You don't need to lock the access to this
> counter as it is only ever access as current-> so a simple "long"
> (or "long long") would do.  The global "vm_dirties" still needs to be
> percpu....  I'm not sure what best to do about this.

Right, I did it just to quickly reuse the concept. The task throttling
is very much an RFC (I even had that in the subject, but it magically
got lost in sending).
   
But if you like it, I could put this patch before the per bdi affair and
clean it up. I though having only 1 user would not warrant its own lib/
file.

> The per-task throttling is interesting.
> You reduce the point where a task has to throttle by up to half, based
> on the fraction of recently dirtied pages that the task is responsible
> for.
> So if there is one writer, it now gets only half the space that it
> used to.  That is probably OK, we can just increase the space
> available...
> If there are two equally eager writers, they can both use up to the
> 75% mark, so they probably each get 37%, which is reasonable.
> If there is one fast an one slow writer where the slow writer is
> generating dirty pages well below the writeout rate of the device, the
> fast writer will throttle at around 50% and the slow writer will never
> block.  That is nice.

Yes, if only ext3's fsync would not be global... :-/

> If you have two writers A and B writing aggressively to two devices X
> and Y with different speeds, say X twice the speed of Y, then in the
> steady state, X gets 2/3 of the space and Y gets 1/3.
> A will dirty twice the pages that B dirties so A will get to use
> 1 - (2/3)/2 == 2/3 of that space or 4/9, and B will get to use 1 - (1/3)/2 ==
> 5/6 of that space or 5/18.  Did I get that right?
> So they will each reduce the space available to the other, even though
> they aren't really competing.   That might not be a problem, but it is
> interesting... 

Indeed, quite an interesting scenario. /me must ponder this; per bdi
task proportions are way overkill...

> It seems that the 'one half' is fairly arbitrary.  It could equally
> well be 3/4.  That would simply mean there is less differentiation
> between the more and less aggressive writer.  I would probably lean
> towards a higher number like 3/4.  It should still give reasonable
> differentiation without cutting max amount of dirty memory in half for
> the common 1-writer case.

Yes its pulled from a dark place,... pretty much anything would do, I
even ran into someone who wanted it to be almost 1 - so that heavy
writers would act almost synchonous.

> A couple of years ago Andrea Arcangeli wrote a patch that did per-task
> throttling, which it is worth comparing with.
>   http://lwn.net/Articles/152277/
> 
> It takes each task separately, measure rate-of-dirtying over a fixed
> time period, and throttle when that rate would put the system over the
> limit soon.  Thus slower dirtiers throttle later.
> 
> Having to configure the fixed number (the period) is always awkward,
> and I think your floating average is better suited for the task.
> I doubt if Andrea's patch still applies so a direct comparison might
> be awkward, but it might not hurt to read through it if you haven't
> already. 

I remember now, thanks for the pointer, I'll see if I can come up with
something hybrid here.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
