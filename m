Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A23566B0325
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 07:28:05 -0400 (EDT)
Date: Fri, 20 Aug 2010 07:27:57 -0400
From: Jeff Layton <jlayton@redhat.com>
Subject: Re: why are WB_SYNC_NONE COMMITs being done with FLUSH_SYNC set ?
Message-ID: <20100820072757.6ae9741a@tlielax.poochiereds.net>
In-Reply-To: <20100820091904.GB20138@infradead.org>
References: <20100819101525.076831ad@barsoom.rdu.redhat.com>
	<20100819143710.GA4752@infradead.org>
	<20100819235553.GB22747@localhost>
	<20100820091904.GB20138@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Wu Fengguang <fengguang.wu@gmail.com>, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Aug 2010 05:19:04 -0400
Christoph Hellwig <hch@infradead.org> wrote:

> On Fri, Aug 20, 2010 at 07:55:53AM +0800, Wu Fengguang wrote:
> > Since migration and pageout still set nonblocking for ->writepage, we
> > may keep them in the near future, until VM does not start IO on itself.
> 
> Why does pageout() and memory migration need to be even more
> non-blocking than the already non-blockig WB_SYNC_NONE writeout?
> 

Just an idle thought on this...

I think a lot of the confusion here comes from the fact that we have
sync_mode and a bunch of flags, and it's not at all clear how
filesystems are supposed to treat the union of them. There are also
possible unions of flags/sync_modes that never happen in practice. It's
not always obvious though and as filesystem implementors we have to
consider the possibility that they might occur (consider WB_SYNC_ALL +
for_background).

Perhaps a lot of this confusion could be lifted by getting rid of the
extra flags and adding new sync_mode's. Maybe something like:

WB_SYNC_ALL /* wait on everything to complete */
WB_SYNC_NONE /* don't wait on anything */
WB_SYNC_FOR_RECLAIM /* sync for reclaim */
WB_SYNC_FOR_KUPDATED /* sync by kupdate */
...etc...

That does mean that all of the filesystem specific code may need to be
touched when new modes are added and removed. I think it would be
clearer though about what you're supposed to do in ->writepages.

-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
