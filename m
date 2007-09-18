Date: Tue, 18 Sep 2007 12:45:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 6/14] Reclaim Scalability: "No Reclaim LRU Infrastructure"
In-Reply-To: <20070918095443.GA2035@skynet.ie>
Message-ID: <Pine.LNX.4.64.0709181242240.3714@schroedinger.engr.sgi.com>
References: <20070914205359.6536.98017.sendpatchset@localhost>
 <20070914205438.6536.49500.sendpatchset@localhost>
 <Pine.LNX.4.64.0709141537180.14937@schroedinger.engr.sgi.com>
 <1190042245.5460.81.camel@localhost> <Pine.LNX.4.64.0709171137360.27057@schroedinger.engr.sgi.com>
 <20070918095443.GA2035@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, 18 Sep 2007, Mel Gorman wrote:

> > Also the ramfs/shmem pages. There 
> > may be uses though that require a page to stay put because it is used for 
> > some nefarious I/O purpose by a driver. RDMA comes to mind.
> 
> Yeah :/
> 
> > Maybe we need 
> > some additional option that works like MLOCK but forbids migration.
> 
> The problem with RDMA that I recall is that we don't know at allocation
> time that they may be unmovable sometimes in the future. I didn't think
> of a way around that problem.

The current way that we have around the problem is to increase the page 
count. With that all attempts to unmap the page by migration or otherwise 
fail and the page stays put.

RDMA is probably only temporarily pinning these while I/O is in progress?. 
Our applications (XPMEM) 
may pins them for good.
 
> > Those 
> > would then be unreclaimable and not __GFP_MOVABLE. I know some of our 
> > applications create huge amount of these.
> > 
> 
> Can you think of a way that pages that will be later pinned by something
> like RDMA can be identified in advance?

No. Nor in our XPMEM situation. We could move them at the point when they 
are pinned to another section?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
