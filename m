In-reply-to: <20070424045027.f21a79ae.akpm@linux-foundation.org> (message from
	Andrew Morton on Tue, 24 Apr 2007 04:50:27 -0700)
Subject: Re: [PATCH 10/10] mm: per device dirty threshold
References: <20070420155154.898600123@chello.nl>
	<20070420155503.608300342@chello.nl>
	<17965.29252.950216.971096@notabene.brown>
	<1177398589.26937.40.camel@twins>
	<E1HgGF4-00008p-00@dorka.pomaz.szeredi.hu>
	<1177403494.26937.59.camel@twins>
	<E1HgH69-0000Fl-00@dorka.pomaz.szeredi.hu>
	<1177406817.26937.65.camel@twins>
	<E1HgHcG-0000J5-00@dorka.pomaz.szeredi.hu>
	<20070424030021.a091018d.akpm@linux-foundation.org>
	<1177409538.26937.75.camel@twins>
	<20070424034024.f953f93f.akpm@linux-foundation.org>
	<E1HgJ5u-0000aD-00@dorka.pomaz.szeredi.hu> <20070424045027.f21a79ae.akpm@linux-foundation.org>
Message-Id: <E1HgJnl-0000gD-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 24 Apr 2007 14:07:21 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: miklos@szeredi.hu, a.p.zijlstra@chello.nl, neilb@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

> > No, we _start_ writeback for 1.5*ratelimit_pages pages, but do not
> > wait for those writebacks to finish.
> > 
> > So for a slow device and a fast writer, dirty+writeback can indeed
> > increase beyond the dirty threshold.
> > 
> 
> Nope, try it.
> 
> If a process dirties 1000 pages it'll then go into balance_dirty_pages()
> and start writeback against 1,500 pages.  When we hit dirty_ratio that
> process will be required to write back 1,500 pages for each eight pages
> which it dirtied.  We'll quickly reach the stage where there are no longer
> 1,500 pages to be written back and the process will block in
> balance_dirty_pages() until the dirty+writeback level subsides.

OK.  I was confused by this:

static long ratelimit_pages = 32;

and didn't realize, that that 32 is totally irrelevant.

So I'm still right, that for N dirty pages, the writer is allowed to
dirty N/1500*8 more dirty pages, but I agree, that this isn't really
an issue.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
