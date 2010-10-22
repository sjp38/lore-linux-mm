Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BBD066B004A
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 04:07:31 -0400 (EDT)
Date: Fri, 22 Oct 2010 16:07:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
Message-ID: <20101022080725.GA22594@localhost>
References: <AANLkTimVu+5gTDs8przJVP2EbWC=FX-zWW7aH08BtrHC@mail.gmail.com>
 <20101020055717.GA12752@localhost>
 <20101020150346.1832.A69D9226@jp.fujitsu.com>
 <20101020092739.GA23869@localhost>
 <4CBEE888.2090606@kernel.dk>
 <20101022053755.GB16804@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101022053755.GB16804@localhost>
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <axboe@kernel.dk>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Torsten Kaiser <just.for.lkml@googlemail.com>, Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

> > We surely need 1 set aside for each level of that stack that will
> > potentially consume one. 1 should be enough for the generic pool, and
> > then clones will use a separate pool. So md and friends should really
> > have a pool per device, so that stacking will always work properly.
> 
> Agreed for the deadlock problem.
> 
> > There should be no throughput concerns, it should purely be a safe guard
> > measure to prevent us deadlocking when doing IO for reclaim.
> 
> It's easy to verify whether the minimal size will have negative
> impacts on IO throughput. In Torsten's case, increase BIO_POOL_SIZE
> by one and check how it performs.

Sorry it seems simply increasing BIO_POOL_SIZE is not enough to fix
possible deadlocks. We need adding new mempool(s). Because when there
BIO_POOL_SIZE=2 and there are two concurrent reclaimers each take 1
reservation, they will deadlock each other when trying to take the
next bio at the raid1 level.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
