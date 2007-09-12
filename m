MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18151.20636.425784.226044@stoffel.org>
Date: Tue, 11 Sep 2007 22:36:12 -0400
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [PATCH 21/23] mm: per device dirty threshold
In-Reply-To: <20070911200015.732492000@chello.nl>
References: <20070911195350.825778000@chello.nl>
	<20070911200015.732492000@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Peter> Scale writeback cache per backing device, proportional to its
Peter> writeout speed.  By decoupling the BDI dirty thresholds a
Peter> number of problems we currently have will go away, namely:

Ah, this clarifies my questions!  Thanks!

Peter>  - mutual interference starvation (for any number of BDIs);
Peter>  - deadlocks with stacked BDIs (loop, FUSE and local NFS mounts).

Peter> It might be that all dirty pages are for a single BDI while
Peter> other BDIs are idling. By giving each BDI a 'fair' share of the
Peter> dirty limit, each one can have dirty pages outstanding and make
Peter> progress.

Question, can you change (shrink) the limit on a BDI while it has IO
in flight?  And what will that do to the system?  I.e. if you have one
device doing IO, so that it has a majority of the dirty limit.  Then
another device starts IO, and it's a *faster* device, how
quickly/slowly does the BDI dirty limits change for both the old and
new device?  

Peter> A global threshold also creates a deadlock for stacked BDIs;
Peter> when A writes to B, and A generates enough dirty pages to get
Peter> throttled, B will never start writeback until the dirty pages
Peter> go away. Again, by giving each BDI its own 'independent' dirty
Peter> limit, this problem is avoided.

Peter> So the problem is to determine how to distribute the total
Peter> dirty limit across the BDIs fairly and efficiently. A DBI that

You mean BDI here, not DBI.  

Peter> has a large dirty limit but does not have any dirty pages
Peter> outstanding is a waste.

Peter> What is done is to keep a floating proportion between the DBIs
Peter> based on writeback completions. This way faster/more active
Peter> devices get a larger share than slower/idle devices.

Does a slower device get a BDI which is calculated to keep it's limit
under a certain number of seconds of outstanding IO?  This way no
device can build up more than say 15 seconds of outstanding IO to
flush at any one time.  

Thanks!
John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
