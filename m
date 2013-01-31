Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id E8F426B000D
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 00:21:23 -0500 (EST)
Date: Thu, 31 Jan 2013 14:21:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv2 1/9] staging: zsmalloc: add gfp flags to zs_create_pool
Message-ID: <20130131052121.GC23548@blaptop>
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1357590280-31535-2-git-send-email-sjenning@linux.vnet.ibm.com>
 <CAEwNFnDWpyvmN-fU=MczXKtcay6vMMCOOHUM2M09+wx7zOVxDQ@mail.gmail.com>
 <51029FC3.4060402@linux.vnet.ibm.com>
 <b3ab2d2f-a0a1-44ff-ac8f-bb0ed73d8978@default>
 <20130128025917.GA3321@blaptop>
 <20130130161146.GB1722@konrad-lan.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130130161146.GB1722@konrad-lan.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Wed, Jan 30, 2013 at 11:11:47AM -0500, Konrad Rzeszutek Wilk wrote:
> On Mon, Jan 28, 2013 at 11:59:17AM +0900, Minchan Kim wrote:
> > On Fri, Jan 25, 2013 at 07:56:29AM -0800, Dan Magenheimer wrote:
> > > > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > > > Subject: Re: [PATCHv2 1/9] staging: zsmalloc: add gfp flags to zs_create_pool
> > > > 
> > > > On 01/24/2013 07:33 PM, Minchan Kim wrote:
> > > > > Hi Seth, frontswap guys
> > > > >
> > > > > On Tue, Jan 8, 2013 at 5:24 AM, Seth Jennings
> > > > > <sjenning@linux.vnet.ibm.com> wrote:
> > > > >> zs_create_pool() currently takes a gfp flags argument
> > > > >> that is used when growing the memory pool.  However
> > > > >> it is not used in allocating the metadata for the pool
> > > > >> itself.  That is currently hardcoded to GFP_KERNEL.
> > > > >>
> > > > >> zswap calls zs_create_pool() at swapon time which is done
> > > > >> in atomic context, resulting in a "might sleep" warning.
> > > > >
> > > > > I didn't review this all series, really sorry but totday I saw Nitin
> > > > > added Acked-by so I'm afraid Greg might get it under my radar. I'm not
> > > > > strong against but I would like know why we should call frontswap_init
> > > > > under swap_lock? Is there special reason?
> > > > 
> > > > The call stack is:
> > > > 
> > > > SYSCALL_DEFINE2(swapon.. <-- swapon_mutex taken here
> > > > enable_swap_info() <-- swap_lock taken here
> > > > frontswap_init()
> > > > __frontswap_init()
> > > > zswap_frontswap_init()
> > > > zs_create_pool()
> > > > 
> > > > It isn't entirely clear to me why frontswap_init() is called under
> > > > lock.  Then again, I'm not entirely sure what the swap_lock protects.
> > > >  There are no comments near the swap_lock definition to tell me.
> > > > 
> > > > I would guess that the intent is to block any writes to the swap
> > > > device until frontswap_init() has completed.
> > > > 
> > > > Dan care to weigh in?
> > > 
> > > I think frontswap's first appearance needs to be atomic, i.e.
> > > the transition from (a) frontswap is not present and will fail
> > > all calls, to (b) frontswap is fully functional... that transition
> > > must be atomic.  And, once Konrad's module patches are in, the
> 
> To be fair it can be "delayed". Say the swap disk is in heavy usage and
> the backend is registered. The time between the backend going online and
> the frontswap_store functions calling in the backend can be delayed (so
> we can use a racy unsigned long to check when the backend is on).
> 
> Obviously the opposite is not acceptable (so unsigned long says
> backend is enabled, but in reality the backend has not yet been
> initialized).
> 
> > > opposite transition must be atomic also.  But there are most
> > > likely other ways to do those transitions atomically that
> > > don't need to hold swap_lock.
> 
> Right. The opposite transition would be when a backend is unloaded.
> Which is something we don't do yet. For that to work we would need
> to make the "gatekeeper" (this unsigned long I've been referring to)
> be atomic. Or at least in some fashion - either via spinlocks or perhaps
> using static_key to patch the branching of the code. Naturally to
> unload a module extra things such as flushing all the pages the backend
> has to the disk is required.
> > 
> > It could be raced once swap_info is registered.
> > But what's the problem if we call frontswap_init before calling
> > _enable_swap_info out of lock?
> 
> So, we have two locks - the mutex and the spin_lock. I think we are
> fine without the spinlock (swap_lock). 
> 
> > Swap subsystem never do I/O before it register new swap_info_struct.
> > 
> > And IMHO, if frontswap is to be atomic, it would be better to have
> > own scheme without dependency of swap_lock if it's possible.
> 
> I think that can be independent of that lock. We are still under
> the mutex (swapon_mutex) which protects us against two threads doing
> swapon/swapoff and messing things up.
> > > 
> > > Honestly, I never really focused on the initialization code
> > > so I am very open to improvements as long as they work for
> > > all the various frontswap backends.
> > 
> > How about this?
> > 
> > From 157a3edf49feb93be0595574beb153b322ddf7d2 Mon Sep 17 00:00:00 2001
> > From: Minchan Kim <minchan@kernel.org>
> > Date: Mon, 28 Jan 2013 11:34:00 +0900
> > Subject: [PATCH] frontswap: Get rid of swap_lock dependency
> > 
> > Frontswap initialization routine depends on swap_lock, which want
> > to be atomic about frontswap's first appearance.
> > IOW, frontswap is not present and will fail all calls OR frontswap is
> > fully functional but if new swap_info_struct isn't registered
> > by enable_swap_info, swap subsystem doesn't start I/O so there is no race
> > between init procedure and page I/O working on frontswap.
> > 
> > So let's remove unncessary swap_lock dependency.
> 
> This looks good. I hadn't yet had a chance to test it out though.

I hope you pick up if it pass your test.
Thanks, Konrad!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
