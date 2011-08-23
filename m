Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 762FE6B016A
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 23:53:40 -0400 (EDT)
Date: Tue, 23 Aug 2011 11:53:35 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] writeback: IO-less balance_dirty_pages()
Message-ID: <20110823035335.GA26739@localhost>
References: <20110816022006.348714319@intel.com>
 <20110816022329.190706384@intel.com>
 <20110819020637.GA13597@redhat.com>
 <20110819025406.GA13365@localhost>
 <20110819190037.GJ18656@redhat.com>
 <20110821034657.GA30747@localhost>
 <20110822172230.GB17833@redhat.com>
 <20110823010721.GB7332@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110823010721.GB7332@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> >   Because task_ratelimit_0 is initial value to begin with and we will
> >   keep on coming with new value every 200ms, we should be able to write
> >   above as follows.
> > 
> > 						      write_bw
> >   bdi->dirty_ratelimit_n = bdi->dirty_ratelimit_n-1 * --------  (8)
> > 						      dirty_bw
> > 
> >   Effectively we start with an initial value of task_ratelimit_0 and
> >   then keep on updating it based on rate change feedback every 200ms.

Ah sorry, based on the reply to Peter, there is no inherent dependency
between balanced_rate_n and balanced_rate_(n-1). bdi->dirty_ratelimit does
track balanced_rate in small steps, and hence will have some relationship
with its previous value other than equation (8).

So, although you may conduct equation (8) for balanced_rate, we'd
better not understand things in that way. Keep this fundamental
formula in mind and don't try to complicate it:

        balanced_rate = task_ratelimit_200ms * write_bw / dirty_rate

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
