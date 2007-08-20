Subject: Re: [RFC 2/9] Use NOMEMALLOC reclaim to allow reclaim if
	PF_MEMALLOC is set
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0708201158270.28863@schroedinger.engr.sgi.com>
References: <20070814153021.446917377@sgi.com>
	 <20070814153501.305923060@sgi.com> <20070818071035.GA4667@ucw.cz>
	 <Pine.LNX.4.64.0708201158270.28863@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 20 Aug 2007 22:17:36 +0200
Message-Id: <1187641056.5337.32.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-08-20 at 12:00 -0700, Christoph Lameter wrote:
> On Sat, 18 Aug 2007, Pavel Machek wrote:
> 
> > > The reclaim is of particular important to stacked filesystems that may
> > > do a lot of allocations in the write path. Reclaim will be working
> > > as long as there are clean file backed pages to reclaim.
> > 
> > I don't get it. Lets say that we have stacked filesystem that needs
> > it. That filesystem is broken today.
> > 
> > Now you give it second chance by reclaiming clean pages, but there are
> > no guarantees that we have any.... so that filesystem is still broken
> > with your patch...?
> 
> There is a guarantee that we have some because the user space program is 
> executing. Meaning the executable pages can be retrieved. The amount 
> dirty memory in the system is limited by the dirty_ratio. So the VM can 
> only get into trouble if there is a sufficient amount of anonymous pages 
> and all executables have been reclaimed. That is pretty rare.
> 
> Plus the same issue can happen today. Writes are usually not completed 
> during reclaim. If the writes are sufficiently deferred then you have the 
> same issue now.

Once we have initiated (disk) writeout we do not need more memory to
complete it, all we need to do is wait for the completion interrupt.

Networking is different here in that an unbounded amount of net traffic
needs to be processed in order to find the completion event.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
