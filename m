Subject: Re: [PATCH] remove throttle_vm_writeout()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1191612196.6715.142.camel@heimdal.trondhjem.org>
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
	 <20071004145640.18ced770.akpm@linux-foundation.org>
	 <E1IdZLg-0002Wr-00@dorka.pomaz.szeredi.hu>
	 <20071004160941.e0c0c7e5.akpm@linux-foundation.org>
	 <E1Ida56-0002Zz-00@dorka.pomaz.szeredi.hu>
	 <20071004164801.d8478727.akpm@linux-foundation.org>
	 <E1Idanu-0002c1-00@dorka.pomaz.szeredi.hu>
	 <20071004174851.b34a3220.akpm@linux-foundation.org>
	 <1191572520.22357.42.camel@twins>
	 <E1IdjOa-0002qg-00@dorka.pomaz.szeredi.hu>
	 <1191577623.22357.69.camel@twins>
	 <E1IdkOf-0002tK-00@dorka.pomaz.szeredi.hu>
	 <1191581854.22357.85.camel@twins>
	 <1191606600.6715.94.camel@heimdal.trondhjem.org>
	 <1191609139.6210.4.camel@lappy>
	 <1191612043.6715.139.camel@heimdal.trondhjem.org>
	 <1191612196.6715.142.camel@heimdal.trondhjem.org>
Content-Type: text/plain
Date: Fri, 05 Oct 2007 23:07:36 +0200
Message-Id: <1191618456.5856.2.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, wfg@mail.ustc.edu.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-10-05 at 15:23 -0400, Trond Myklebust wrote: 
> On Fri, 2007-10-05 at 15:20 -0400, Trond Myklebust wrote:
> > On Fri, 2007-10-05 at 20:32 +0200, Peter Zijlstra wrote:
> > > Well, the thing is, we throttle pageout in throttle_vm_writeout(). As it
> > > stand we can deadlock there because it just waits for the numbers to
> > > drop, and unstable pages don't automagically dissapear. Only
> > > write_inodes() - normally called from balance_dirty_pages() will call
> > > COMMIT.
> > > 
> > > So my thought was that calling pageout() on an unstable page would do
> > > the COMMIT - we're low on memory, otherwise we would not be paging, so
> > > getting rid of unstable pages seems to make sense to me.
> > 
> > Why not rather track which mappings have large numbers of outstanding
> > unstable writes at the VM level, and then add some form of callback to
> > allow it to notify the filesystem when it needs to flush them out?

That would be nice, its just that the pageout throttling is not quite
that sophisticated. But we'll see what we can come up with.

> BTW: Please note that at least in the case of NFS, you will have to
> allow for the fact that the filesystem may not be _able_ to cause the
> numbers to drop. If the server is unavailable, then we're may be stuck
> in unstable page limbo for quite some time.

Agreed, it would be nice if that is handled is such a manner that it
does not take down all other paging.

The regular write path that only bothers with balance_dirty_pages()
already does this nicely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
