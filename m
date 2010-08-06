Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 945ED6B02A7
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 20:28:10 -0400 (EDT)
Date: Thu, 5 Aug 2010 17:27:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] writeback: Adding pages_dirtied and
 pages_entered_writeback
Message-Id: <20100805172711.87c802ca.akpm@linux-foundation.org>
In-Reply-To: <20100806091548.31ED.A69D9226@jp.fujitsu.com>
References: <20100806084928.31DE.A69D9226@jp.fujitsu.com>
	<AANLkTimD4jkkPpnhQhR+OF=6=dWV2dJj4M_DGfAmHgRQ@mail.gmail.com>
	<20100806091548.31ED.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Michael Rubin <mrubin@google.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, david@fromorbit.com, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Fri,  6 Aug 2010 09:18:59 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > On Thu, Aug 5, 2010 at 4:56 PM, KOSAKI Motohiro
> > <kosaki.motohiro@jp.fujitsu.com> wrote:
> > > /proc/vmstat already have both.
> > >
> > > cat /proc/vmstat |grep nr_dirty
> > > cat /proc/vmstat |grep nr_writeback
> > >
> > > Also, /sys/devices/system/node/node0/meminfo show per-node stat.
> > >
> > > Perhaps, I'm missing your point.
> > 
> > These only show the number of dirty pages present in the system at the
> > point they are queried.
> > The counter I am trying to add are increasing over time. They allow
> > developers to see rates of pages being dirtied and entering writeback.
> > Which is very helpful.
> 
> Usually administrators get the data two times and subtract them. Isn't it sufficient?
> 

Nope.  The existing nr_dirty is "number of pages dirtied since boot"
minus "number of pages cleaned since boot".  If you do the
wait-one-second-then-subtract thing on nr_dirty, the result is
dirtying-bandwidth minus cleaning-bandwidth, and can't be used to
determine dirtying-bandwidth.

I can see that a graph of dirtying events versus time could be an
interesting thing.  I don't see how it could be obtained using the
existing instrumentation.  tracepoints, probably..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
