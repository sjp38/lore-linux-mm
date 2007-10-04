Date: Thu, 4 Oct 2007 11:54:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] remove throttle_vm_writeout()
Message-Id: <20071004115458.10897e51.akpm@linux-foundation.org>
In-Reply-To: <1191521410.5574.36.camel@lappy>
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
	<1191501626.22357.14.camel@twins>
	<E1IdQJn-0002Cv-00@dorka.pomaz.szeredi.hu>
	<1191504186.22357.20.camel@twins>
	<E1IdR58-0002Fq-00@dorka.pomaz.szeredi.hu>
	<1191516427.5574.7.camel@lappy>
	<20071004104650.d158121f.akpm@linux-foundation.org>
	<1191521410.5574.36.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: miklos@szeredi.hu, wfg@mail.ustc.edu.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 04 Oct 2007 20:10:10 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> 
> On Thu, 2007-10-04 at 10:46 -0700, Andrew Morton wrote:
> > On Thu, 04 Oct 2007 18:47:07 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > > static int may_write_to_queue(struct backing_dev_info *bdi)
> > > {
> > > 	if (current->flags & PF_SWAPWRITE)
> > > 		return 1;
> > > 	if (!bdi_write_congested(bdi))
> > > 		return 1;
> > > 	if (bdi == current->backing_dev_info)
> > > 		return 1;
> > > 	return 0;
> > > }
> > > 
> > > Which will write to congested queues. Anybody know why?
> 
> OK, I guess I could have found that :-/

Nice changelog, if I do say so myself ;)

> >     One fix for this would be to add an additional "really congested"
> >     threshold in the request queues, so kswapd can still perform
> >     nonblocking writeout.  This gives kswapd priority over pdflush while
> >     allowing kswapd to feed many disk queues.  I doubt if this will be
> >     called for.
> 
> I could do that.

I guess first you'd need to be able to reproduce the problem which that
patch fixed, then check that it remains fixed.

Sigh.  That problem was fairly subtle.  We could re-break reclaim in
this way and not find out about it for six months.  There's a lesson here. 
Several.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
