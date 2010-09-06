Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3B49B6B0047
	for <linux-mm@kvack.org>; Sun,  5 Sep 2010 21:35:03 -0400 (EDT)
Date: Mon, 6 Sep 2010 09:34:59 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/4] writeback: nr_dirtied and nr_cleaned in
 /proc/vmstat
Message-ID: <20100906013459.GB5466@localhost>
References: <20100831074825.GA19358@localhost>
 <20100905141715.GA9024@localhost>
 <20100906095414.C8BE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100906095414.C8BE.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michael Rubin <mrubin@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "david@fromorbit.com" <david@fromorbit.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 06, 2010 at 09:00:35AM +0800, KOSAKI Motohiro wrote:
> > On Tue, Aug 31, 2010 at 03:48:25PM +0800, Wu Fengguang wrote:
> > > > > The output format is quite different from /proc/vmstat.
> > > > > Do we really need to "Node X", ":" and "times" decorations?
> > > > 
> > > > Node X is based on the meminfo file but I agree it's redundant information.
> > > 
> > > Thanks. In the same directory you can find a different style example
> > > /sys/devices/system/node/node0/numastat :) If ever the file was named
> > > vmstat! In the other hand, shall we put the numbers there? I'm confused..
> > 
> > With wider use of NUMA, I'm expecting more interests to put
> > /proc/vmstat items into /sys/devices/system/node/node0/.
> 
> I prefer to create /sys/devices/system/node/node0/zones/zone-DMA32/vmstat
> because the VM is managing pages as per-zones.
> but /sys/devices/system/node/node0/vmstat is also useful.

Good points.

> > What shall we do then? There are several possible options:
> > - just put the /proc/vmstat items into nodeX/numastat
> > - create nodeX/vmstat and make numastat a symlink to vmstat
> > - create nodeX/vmstat and remove numastat in future
> > 
> > Any suggestions?
> 
> 
> I like 3rd option :)
> In addition, I doubt we really need to remove numastat. It's not
> so harmful.

Yeah 4th option: keep numastat while introducing the above interfaces.
The contents might be duplicated, but not a big issue.

> > 
> > > > > And the "_PAGES" in NR_FILE_PAGES_DIRTIED looks redundant to
> > > > > the "_page" in node_page_state(). It's a bit long to be a pleasant
> > > > > name. NR_FILE_DIRTIED/NR_CLEANED looks nicer.
> > > > 
> > > > Yeah. Will fix.
> > > 
> > > Thanks. This is kind of nitpick, however here is another name by
> > > Jan Kara: BDI_WRITTEN. BDI_WRITTEN may not be a lot better than
> > > BDI_CLEANED, but here is a patch based on Jan's code. I'm cooking
> > > more patches that make use of this per-bdi counter to estimate the
> > > bdi's write bandwidth, and to further decide the optimal (large)
> > > writeback chunk size as well as to do IO-less balance_dirty_pages().
> > > 
> > > Basically BDI_WRITTEN and NR_CLEANED are accounting for the same
> > > thing in different dimensions. So it would be good if we can use
> > > the same naming scheme to avoid confusing users: either to use
> > > BDI_WRITTEN and NR_WRITTEN, or use BDI_CLEANED and NR_CLEANED.
> > > What's your opinion?
> > 
> > I tend to prefer *_WRITTEN now.
> > - *_WRITTEN reminds the users about IO, *_CLEANED is less so obvious.
> > - *_CLEANED seems to be paired with NR_DIRTIED, this could be
> >   misleading to the users. The fact is, dirty pages may either be
> >   written to disk, or dropped (by truncate).
> 
> Umm...
> If my understanding is correct, Michael really need *_CLEANED because
> he want to compare NR_DIRTIED and *_CLEANED. That said, we need to
> change counter implementation itself instead a name?

It's only about naming :) Michael want to do per-zone accounting and I
also need to do per-bdi accounting, for basically the same event. So
I'm proposing to name it consistently.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
