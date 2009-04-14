Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 179D35F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 07:11:57 -0400 (EDT)
Date: Tue, 14 Apr 2009 19:11:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/3] readahead: introduce context readahead algorithm
Message-ID: <20090414111142.GA8793@localhost>
References: <20090412071950.166891982@intel.com> <20090412072052.686760755@intel.com> <87zlej7kwf.fsf@basil.nowhere.org> <20090414092704.GD7001@localhost> <20090414100002.GW14687@one.firstfloor.org> <20090414105824.GA8628@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=gb2312
Content-Disposition: inline
In-Reply-To: <20090414105824.GA8628@localhost>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladislav Bolkhovitin <vst@vlnb.net>, Jens Axboe <jens.axboe@oracle.com>, Jeff Moyer <jmoyer@redhat.com>, Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chenfeng Xu <xcf@ustc.edu.cn>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 14, 2009 at 06:58:24PM +0800, Wu Fengguang wrote:
> On Tue, Apr 14, 2009 at 06:00:02PM +0800, Andi Kleen wrote:
> > > I'll list some possible situations. I guess you are referring to (2.3)?
> > 
> > Yep. Thanks for the detailed analysis.
> 
> You are welcome :-)
> 
> > > 2.3) readahead cache hits: rare case and the impact is temporary
> > > 
> > > The page at @offset-1 does get referenced by this stream, but it's
> > > created by someone else at some distant time ago. The page at
> > > @offset-1 may be lifted to active lru by this second reference, or too
> > > late and get reclaimed - by the time we reference page @offset.
> > > 
> > > Normally its a range of cached pages. We are a) either walking inside the
> > > range and enjoying the cache hits, b) or we walk out of it and restart
> > > readahead by ourself, c) or the range of cached pages get reclaimed
> > > while we are walking on them, and hence cannot find page @offset-1.
> > > 
> > > Obviously (c) is rare and temporary and is the main cause of (2.3).
> > > As soon as we goto the next page at @offset+1, we'll its 'previous'
> > > page at @offset to be cached(it is created by us!). So the context
> > > readahead starts working again - it's merely delayed by one page :-)
> > 
> > Thanks. The question is how much performance impact this has on
> > the stream that is readaheaded.  I guess it would be only a smaller
> > "hickup", with some luck hidden by the block level RA?

No the block level RA wont help here, because there are no disk
accesses at all for the cached pages before @offset: the disk RA have
absolutely no idea on where the IO for page @offset originates from ;-)

> Yes there will be hickup: whenever the stream walks out of the current
> cached page range(or the pages get reclaimed while we are walking in it),
> there will be a 1-page read, followed by a 4-page readahead, and then 8,
> 16, ... page sized readahead, i.e. a readahead window rampup process.
> 
> That's assuming we are doing 1-page reads. For large sendfile() calls,
> the readahead size will be instantly restored to its full size on the
> first cache miss.
> 
> > The other question would be if it could cause the readahead code
> > to do a lot of unnecessary work, but your answer seems to be "no". Fine.
> 
> Right. The readahead will automatically be turned off inside the
> cached page ranges, and restarted after walking out of it.
> 
> > I think the concept is sound.
> 
> ^_^ Thanks for your appreciation!
> 
> 
> Best Regards,
> Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
