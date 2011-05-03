Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 024F56B0012
	for <linux-mm@kvack.org>; Tue,  3 May 2011 05:54:06 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: Colin Ian King <colin.king@canonical.com>
In-Reply-To: <20110428171826.GZ4658@suse.de>
References: <1303926637.2583.17.camel@mulgrave.site>
	 <1303934716.2583.22.camel@mulgrave.site> <1303990590.2081.9.camel@lenovo>
	 <20110428135228.GC1696@quack.suse.cz> <20110428140725.GX4658@suse.de>
	 <1304000714.2598.0.camel@mulgrave.site> <20110428150827.GY4658@suse.de>
	 <1304006499.2598.5.camel@mulgrave.site>
	 <1304009438.2598.9.camel@mulgrave.site>
	 <1304009778.2598.10.camel@mulgrave.site>  <20110428171826.GZ4658@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 03 May 2011 10:54:00 +0100
Message-ID: <1304416440.6005.5.camel@lenovo>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: James Bottomley <James.Bottomley@suse.de>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, mgorman@novell.com

On Thu, 2011-04-28 at 18:18 +0100, Mel Gorman wrote:
> On Thu, Apr 28, 2011 at 11:56:17AM -0500, James Bottomley wrote:
> > On Thu, 2011-04-28 at 11:50 -0500, James Bottomley wrote:
> > > This is the output of perf record -g -a -f sleep 5
> > > 
> > > (hopefully the list won't choke)
> > 
> > Um, this one actually shows kswapd
> > 
> > James
> > 
> > ---
> > 
> > # Events: 6K cycles
> > #
> > # Overhead      Command        Shared Object                                   Symbol
> > # ........  ...........  ...................  .......................................
> > #
> >     20.41%      kswapd0  [kernel.kallsyms]    [k] shrink_slab
> >                 |
> >                 --- shrink_slab
> >                    |          
> >                    |--99.91%-- kswapd
> >                    |          kthread
> >                    |          kernel_thread_helper
> >                     --0.09%-- [...]
> > 
> 
> Ok. I can't see how the patch "mm: vmscan: reclaim order-0 and use
> compaction instead of lumpy reclaim" is related unless we are seeing
> two problems that happen to manifest in a similar manner.

That is a distinct possibility.
> 
> However, there were a number of changes made to dcache in particular
> for 2.6.38. Specifically thinks like dentry_kill use trylock and is
> happy to loop around if it fails to acquire anything. See things like
> this for example;
> 
[ text deleted ]

> Way hey, cgroups are also in the mix. How jolly.
> 
> Is systemd a common element of the machines hitting this bug by any
> chance?

Not in my case, using upstart on my machine.
> 
Colin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
