Subject: Re: [PATCH] remove throttle_vm_writeout()
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1191581854.22357.85.camel@twins>
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
Content-Type: text/plain
Date: Fri, 05 Oct 2007 13:50:00 -0400
Message-Id: <1191606600.6715.94.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, wfg@mail.ustc.edu.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-10-05 at 12:57 +0200, Peter Zijlstra wrote:
> In this patch I totally ignored unstable, but I'm not sure that's the
> proper thing to do, I'd need to figure out what happens to an unstable
> page when passed into pageout() - or if its passed to pageout at all.
> 
> If unstable pages would be passed to pageout(), and it would properly
> convert them to writeback and clean them, then there is nothing wrong.

Why would we want to do that? That would be a hell of a lot of work
(locking pages, setting flags, unlocking pages, ...) for absolutely no
reason.

Unstable writes are writes which have been sent to the server, but which
haven't been written to disk on the server. A single RPC command is then
sent (COMMIT) which basically tells the server to call fsync(). After
that is successful, we can free up the pages, but we do that with no
extra manipulation of the pages themselves: no page locks, just removal
from the NFS private radix tree, and freeing up of the NFS private
structures.

We only need to touch the pages again in the unlikely case that the
COMMIT fails because the server has rebooted. In this case we have to
resend the writes, and so the pages are marked as dirty, so we can go
through the whole writepages() rigmarole again...

So, no. I don't see sending pages through pageout() as being at all
helpful.

Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
