Subject: Re: [PATCH] mm: exempt pcp alloc from watermarks
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0609181317520.28726@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	 <20060914220011.2be9100a.akpm@osdl.org>
	 <20060914234926.9b58fd77.pj@sgi.com>
	 <20060915002325.bffe27d1.akpm@osdl.org>
	 <20060915012810.81d9b0e3.akpm@osdl.org>
	 <20060915203816.fd260a0b.pj@sgi.com>
	 <20060915214822.1c15c2cb.akpm@osdl.org>
	 <20060916043036.72d47c90.pj@sgi.com>
	 <20060916081846.e77c0f89.akpm@osdl.org>
	 <20060917022834.9d56468a.pj@sgi.com> <450D1A94.7020100@yahoo.com.au>
	 <20060917041525.4ddbd6fa.pj@sgi.com> <450D434B.4080702@yahoo.com.au>
	 <20060917061922.45695dcb.pj@sgi.com>  <450D5310.50004@yahoo.com.au>
	 <1158583495.23551.53.camel@twins>
	 <Pine.LNX.4.64.0609181317520.28726@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 18 Sep 2006 22:43:26 +0200
Message-Id: <1158612206.3278.5.camel@taijtu>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Paul Jackson <pj@sgi.com>, akpm@osdl.org, linux-mm@kvack.org, rientjes@google.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, 2006-09-18 at 13:20 -0700, Christoph Lameter wrote:
> On Mon, 18 Sep 2006, Peter Zijlstra wrote:
> 
> > On Sun, 2006-09-17 at 23:52 +1000, Nick Piggin wrote:
> > 
> > > What we could do then, is allocate pages in batches (we already do),
> > > but only check watermarks if we have to go to the buddly allocator
> > > (we don't currently do this, but really should anyway, considering
> > > that the watermark checks are based on pages in the buddy allocator
> > > rather than pages in buddy + pcp).
> 
> buffered_rmqueue has never checked watermarks. Seems that this is a 
> fragment of a larger discussion and someone added those checks?

get_page_from_freelist() seems to check the watermarks before calling
buffered_rmqueue(), so if the watermarks fail, we never get to
buffered_rmqueue().

This patch adds a path to the per cpu pagelists before checking the
watermarks, however it will not refill the pcps when empty.

So now we can deplete the pcps even though we fail the watermark; which
is correct since the free_pages count is excluding the pcp pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
