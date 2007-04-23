Date: Sun, 22 Apr 2007 23:39:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 10/10] mm: per device dirty threshold
Message-Id: <20070422233936.97d78677.akpm@linux-foundation.org>
In-Reply-To: <E1Hfs3j-0005sN-00@dorka.pomaz.szeredi.hu>
References: <20070420155154.898600123@chello.nl>
	<20070420155503.608300342@chello.nl>
	<20070421025532.916b1e2e.akpm@linux-foundation.org>
	<E1HfCzN-0002dZ-00@dorka.pomaz.szeredi.hu>
	<20070421035444.f7a42fad.akpm@linux-foundation.org>
	<E1HfM9K-0003OA-00@dorka.pomaz.szeredi.hu>
	<1177308889.26937.1.camel@twins>
	<E1Hfs3j-0005sN-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 23 Apr 2007 08:29:59 +0200 Miklos Szeredi <miklos@szeredi.hu> wrote:

> > > What about swapout?  That can increase the number of writeback pages,
> > > without decreasing the number of dirty pages, no?
> > 
> > Could we not solve that by enabling cap_account_writeback on
> > swapper_space, and thereby account swap writeback pages. Then the VM
> > knows it has outstanding IO and need not panic.
> 
> Hmm, I'm not sure that would be right, because then those writeback
> pages would be accounted twice: once for swapper_space, and once for
> the real device.
> 
> So there's a condition, when lots of anonymous pages are turned into
> swap-cache writeback pages, and we should somehow throttle this, because
> 
> >>>     This means that all memory is pinned and unreclaimable and the VM gets
> >>>     upset and goes oom.
> 
> although, it's not quite clear in my mind, how the VM gets upset about
> this.

I've been scratching my head on and off for a couple of days over this.

We've traditionally had reclaim problems when there's a huge amount of
dirty MAP_SHARED data, which the VM didn't know was dirty.  It's the old
"map a file which is the same size as physical memory and write to it all"
stresstest.

But we do not have such problems with anonymous memory, and I'm darned if I
can remember why :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
