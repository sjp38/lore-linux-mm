Subject: Re: [RFC PATCH] discarding swap
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0809121631050.5142@blonde.site>
References: <Pine.LNX.4.64.0809092222110.25727@blonde.site>
	 <20080910173518.GD20055@kernel.dk>
	 <Pine.LNX.4.64.0809102015230.16131@blonde.site>
	 <1221082117.13621.25.camel@macbook.infradead.org>
	 <Pine.LNX.4.64.0809121154430.12812@blonde.site>
	 <1221228567.3919.35.camel@macbook.infradead.org>
	 <Pine.LNX.4.64.0809121631050.5142@blonde.site>
Content-Type: text/plain
Date: Fri, 12 Sep 2008 09:22:08 -0700
Message-Id: <1221236528.21323.22.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-09-12 at 16:52 +0100, Hugh Dickins wrote:
> On Fri, 12 Sep 2008, David Woodhouse wrote:
> > On Fri, 2008-09-12 at 13:10 +0100, Hugh Dickins wrote:
> > > So long as the I/O schedulers guarantee that a WRITE bio submitted
> > > to an area already covered by a DISCARD_NOBARRIER bio cannot pass that
> > > DISCARD_NOBARRIER - ...
> > 
> > > That seems a reasonable guarantee to me, and perhaps it's trivially
> > > obvious to those who know their I/O schedulers; but I don't, so I'd
> > > like to hear such assurance given.
> > 
> > No, that's the point. the I/O schedulers _don't_ give you that guarantee
> > at all. They can treat DISCARD_NOBARRIER just like a write. That's all
> > it is, really -- a special kind of WRITE request without any data.
> 
> Hmmm.  In that case I'll need to continue with DISCARD_BARRIER,
> unless/until I rejig swap allocation to wait for discard completion,
> which I've no great desire to do.
> 
> Is there any particular reason why DISCARD_NOBARRIER shouldn't be
> enhanced to give the intuitive guarantee I suggest?  It is distinct
> from a WRITE, I don't see why it has to be treated in the same way
> if that's unhelpful to its users.

The semantics we want would be something like "when a WRITE or DISCARD
request is submitted, automatically turn it into a soft barrier if there
is already an outstanding WRITE or DISCARD request overlapping the same
sectors".

Detecting overlap isn't hard in the single-queue case, but things like
CFQ make it interesting -- you'd have to search _every_ queue. And you
couldn't just do it when inserting barriers -- you need a write to gain
the barrier flag, if it's inserted after a discard. So we really do care
about the performance.

I agree it would be nice to have if we can do it cheaply enough, though.

> I expect the answer will be: it could be so enhanced, but we really
> don't know if it's worth adding special code for that without the
> experience of more users.

That too. We don't yet really know how much the DISCARD requests buy us
in terms of performance or device lifetime. It'll depend a lot on the
internals of the devices, and we don't get told a lot about that.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
