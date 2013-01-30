Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 4C60E6B0005
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 05:00:52 -0500 (EST)
Received: by mail-da0-f42.google.com with SMTP id z17so703275dal.1
        for <linux-mm@kvack.org>; Wed, 30 Jan 2013 02:00:51 -0800 (PST)
Date: Wed, 30 Jan 2013 17:59:44 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: boot warnings due to swap: make each swap partition have one
 address_space
Message-ID: <20130130095944.GA11457@kernel.org>
References: <5101FFF5.6030503@oracle.com>
 <20130125042512.GA32017@kernel.org>
 <alpine.LNX.2.00.1301261754530.7300@eggly.anvils>
 <20130127141253.GA27019@kernel.org>
 <alpine.LNX.2.00.1301271321500.16981@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1301271321500.16981@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fusionio.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Jan 27, 2013 at 01:40:40PM -0800, Hugh Dickins wrote:
> On Sun, 27 Jan 2013, Shaohua Li wrote:
> > On Sat, Jan 26, 2013 at 06:16:05PM -0800, Hugh Dickins wrote:
> > > On Fri, 25 Jan 2013, Shaohua Li wrote:
> > > > On Thu, Jan 24, 2013 at 10:45:57PM -0500, Sasha Levin wrote:
> > > > 
> > > > Subject: give-each-swapper-space-separate-backing_dev_info
> > > > 
> > > > The backing_dev_info can't be shared by all swapper address space.
> > > 
> > > Whyever not?  It's perfectly normal for different inodes/address_spaces
> > > to share a single backing_dev!  Sasha's trace says that it's wrong to
> > > initialize it MAX_SWAPFILES times: fair enough.  But why should I now
> > > want to spend 32kB (not even counting their __percpu counters) on all
> > > these pseudo-backing_devs?
> > 
> > That's correct, silly me. Updated it.
> 
> Looks much more to my taste, thank you!
> 
> > > 
> > > p.s. a grand little change would be to move page_cluster and swap_setup()
> > > from mm/swap.c to mm/swap_state.c: they have nothing to do with the other
> > > contents of swap.c, and everything to do with the contents of swap_state.c.
> > > Why swap.c is called swap.c is rather a mystery.
> > 
> > Tried, but looks page_cluster is used in sysctl, moving to swap_state.c will
> > make it optional. don't want to add another #ifdef, so give up.
> 
> Good point, thanks for trying, maybe I'll attack it next time it
> irritates me.
> 
> I don't yet know whether I approve of your changes or not, but running
> with them to see (and I'll send another bugfix separately in a moment).
> 
> I was the one who removed the swap_device_lock() which 2.4 used,
> because it almost always ended up having to take both swap_list_lock()
> and swap_device_lock(si).  You seem to have done a much better job of
> separating them usefully, but I need to convince myself that it does
> end up safely.
> 
> My reservations so far would be: how many installations actually have
> more than one swap area, so is it a good tradeoff to add more overhead
> to help those at the (slight) expense of everyone else?  The increasingly
> ugly page_mapping() worries me, and the static array of swapper_spaces
> annoys me a little.
> 
> I'm glad Minchan has now pointed you to Rik's posting of two years ago:
> I think there are more important changes to be made in that direction.

Not sure how others use multiple swaps, but current lock contention forces us
to use multiple swaps. I haven't carefully think about Rik's posting, but looks
it doesn't solve the lock contention problem.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
