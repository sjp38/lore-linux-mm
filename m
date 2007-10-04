Subject: Re: [PATCH] remove throttle_vm_writeout()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1IdR58-0002Fq-00@dorka.pomaz.szeredi.hu>
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
	 <1191501626.22357.14.camel@twins>
	 <E1IdQJn-0002Cv-00@dorka.pomaz.szeredi.hu>
	 <1191504186.22357.20.camel@twins>
	 <E1IdR58-0002Fq-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain
Date: Thu, 04 Oct 2007 18:47:07 +0200
Message-Id: <1191516427.5574.7.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, wfg@mail.ustc.edu.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-04 at 15:49 +0200, Miklos Szeredi wrote:
> > > > Which can only happen when it is larger than 10% of dirty_thresh.
> > > > 
> > > > Which is even more unlikely since it doesn't account nr_dirty (as I
> > > > think it should).
> > > 
> > > I think nr_dirty is totally irrelevant.  Since we don't care about
> > > case 1), and in case 2) nr_dirty doesn't play any role.
> > 
> > Ah, but its correct to have since we compare against dirty_thresh, which
> > is defined to be a unit of nr_dirty + nr_unstable + nr_writeback. if we
> > take one of these out, then we get an undefined amount of space extra.
> 
> Yeah, I guess the point of the function was to limit nr_write to
> _anything_ smaller than the total memory.

*grin*, crude :-/

> > > > As for 2), yes I think having a limit on the total number of pages in
> > > > flight is a good thing.
> > > 
> > > Why?
> > 
> > for my swapping over network thingies I need to put a bound on the
> > amount of outgoing traffic in flight because that bounds the amount of
> > memory consumed by the sending side.
> 
> I guess you will have some request queue with limited length, no?

See below.

> The main problem seems to be if devices use up all the reserved memory
> for queuing write requests.  Limiting the in-flight pages is a very
> crude way to solve this, the assumptions are:
> 
> O: overhead as a fraction of the request size
> T: total memory
> R: reserved memory
> T-R: may be full of anon pages
> 
> so if (T-R)*O > R  we are in trouble.
> 
> if we limit the writeback memory to L and L*O < R we are OK.  But we
> don't know O (it's device dependent).  We can make an estimate
> calculate L based on that, but that will be a number totally
> independent of the dirty threshold.

Yeah, I'm guestimating O on a per device basis, but I agree that the
current ratio limiting is quite crude. I'm not at all sorry to see
throttle_vm_writeback() go, I just wanted to make a point that what it
does is not quite without merrit - we agree that it can be done better
differently.

> > > > But that said, there might be better ways to do that.
> > > 
> > > Sure, if we do need to globally limit the number of under-writeback
> > > pages, then I think we need to do it independently of the dirty
> > > accounting.
> > 
> > It need not be global, it could be per BDI as well, but yes.
> 
> For per-bdi limits we have the queue length.

Agreed, except for:

static int may_write_to_queue(struct backing_dev_info *bdi)
{
	if (current->flags & PF_SWAPWRITE)
		return 1;
	if (!bdi_write_congested(bdi))
		return 1;
	if (bdi == current->backing_dev_info)
		return 1;
	return 0;
}

Which will write to congested queues. Anybody know why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
