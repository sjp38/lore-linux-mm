Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7DF166B0169
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 00:13:36 -0400 (EDT)
Date: Tue, 26 Jul 2011 12:13:22 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: Properly reflect task dirty limits in
 dirty_exceeded logic
Message-ID: <20110726041322.GA22180@localhost>
References: <1309458764-9153-1-git-send-email-jack@suse.cz>
 <20110704010618.GA3841@localhost>
 <20110711170605.GF5482@quack.suse.cz>
 <20110713230258.GA17011@localhost>
 <20110714213409.GB16415@quack.suse.cz>
 <20110723074344.GA31975@localhost>
 <20110725160429.GG6107@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110725160429.GG6107@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, Jul 26, 2011 at 12:04:29AM +0800, Jan Kara wrote:
> On Sat 23-07-11 15:43:45, Wu Fengguang wrote:
> > On Fri, Jul 15, 2011 at 05:34:09AM +0800, Jan Kara wrote:
> > > > - tasks dirtying close to 25% pages probably cannot be called light
> > > >   dirtier and there is no need to protect such tasks
> > >   The idea is interesting. The only problem is that we don't want to set
> > > dirty_exceeded too late so that heavy dirtiers won't push light dirtiers
> > > over their limits so easily due to ratelimiting. It did some computations:
> > > We normally ratelimit after 4 MB. Take a low end desktop these days. Say
> > > 1 GB of ram, 4 CPUs. So dirty limit will be ~200 MB and the area for task
> > > differentiation ~25 MB. We enter balance_dirty_pages() after dirtying
> > > num_cpu * ratelimit / 2 pages on average which gives 8 MB. So we should
> > > set dirty_exceeded at latest at bdi_dirty / TASK_LIMIT_FRACTION / 2 or
> > > task differentiation would have no effect because of ratelimiting.
> > > 
> > > So we could change the limit to something like:
> > > bdi_dirty - min(bdi_dirty / TASK_LIMIT_FRACTION, ratelimit_pages *
> > > num_online_cpus / 2 + bdi_dirty / TASK_LIMIT_FRACTION / 16)
> > 
> > Good analyze!
> > 
> > > But I'm not sure setups where this would make difference are common...
> > 
> > I think I'd prefer the original simple patch given that the common
> > 1-dirtier is not impacted.
>   OK, thanks. So will you merge the patch please?

The patch with a minor variable rename has been in writeback.git and
linux-next for two weeks, and two days ago I updated it to your
original patch:

http://git.kernel.org/?p=linux/kernel/git/wfg/writeback.git;a=commit;h=bcff25fc8aa47a13faff8b4b992589813f7b450a

If you have no more problems with the patchset, I'll ask Linus
to pull that branch.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
