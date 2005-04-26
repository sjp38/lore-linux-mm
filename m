From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17006.4715.211258.938496@gargle.gargle.HOWL>
Date: Tue, 26 Apr 2005 14:05:31 +0400
Subject: Re: [PATCH]: VM 5/8 async-writepage
In-Reply-To: <20050426013632.55e958c8.akpm@osdl.org>
References: <16994.40662.865338.484778@gargle.gargle.HOWL>
	<20050425205706.55fe9833.akpm@osdl.org>
	<17005.64094.860824.34597@gargle.gargle.HOWL>
	<20050426013632.55e958c8.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:
 > Nikita Danilov <nikita@clusterfs.com> wrote:
 > >
 > >  > 
 > >   > I don't understand this at all.  ->writepage() is _already_ asynchronous. 
 > >   > It will only block under rare circumstances such as needing to perform a
 > >   > metadata read or encountering disk queue congestion.
 > > 
 > >  This patch tries to decrease latency of direct reclaim by avoiding
 > > 
 > >    - occasional stalls you mentioned, and
 > > 
 > >    - CPU cost of ->writepage().
 > 
 > Seems a bit pointless then?

Err.. why? With this patch, if there is small memory shortage, and dirty
pages on the end of the inactive list are rare (usual case),
alloc_pages() will return quickly after reclaiming clean pages, allowing
memory consuming operation to complete faster. If there is severe memory
shortage (priority < KPGOUT_PRIORITY), ->writepage() calls are done
synchronously, so there is no risk of deadlock.

 > 
 > Have you quantified this?

Yes, (copied from original message that introduced patches):

before after
  45.4  45.8
 214.4 204.3
 199.1 194.8
 208.3 194.9
 199.5 197.7
 206.8 195.0
 200.8 199.4
 204.7 196.3

In that micro-benchmark memory pressure is high, so not a lot of
asynchronous pageout is done. More testing will be a good thing of
course, isn't this what -mm is for? :)

 > 
 > >  Plus, deferred pageouts will be easier to cluster.
 > 
 > hm.  Why?

Sorry, I meant "it is possible to write the code to do more efficient
pageout clustering from kpgout()": we have a list of pages ready for
pageout, so we can scan the list for the pages from the same mapping,
and build a clusters of them.

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
