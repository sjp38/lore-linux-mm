Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EEA156B0012
	for <linux-mm@kvack.org>; Tue,  3 May 2011 05:13:44 -0400 (EDT)
Date: Tue, 3 May 2011 10:13:20 +0100
From: Mel Gorman <mgorman@novell.com>
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback related.
Message-ID: <20110503091320.GA4542@novell.com>
References: <20110428150827.GY4658@suse.de>
 <1304006499.2598.5.camel@mulgrave.site>
 <1304009438.2598.9.camel@mulgrave.site>
 <1304009778.2598.10.camel@mulgrave.site>
 <20110428171826.GZ4658@suse.de>
 <1304015436.2598.19.camel@mulgrave.site>
 <20110428192104.GA4658@suse.de>
 <1304020767.2598.21.camel@mulgrave.site>
 <1304025145.2598.24.camel@mulgrave.site>
 <1304030629.2598.42.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1304030629.2598.42.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@suse.de>
Cc: Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, Apr 28, 2011 at 05:43:48PM -0500, James Bottomley wrote:
> On Thu, 2011-04-28 at 16:12 -0500, James Bottomley wrote:
> > On Thu, 2011-04-28 at 14:59 -0500, James Bottomley wrote:
> > > Actually, talking to Chris, I think I can get the system up using
> > > init=/bin/bash without systemd, so I can try the no cgroup config.
> > 
> > OK, so a non-PREEMPT non-CGROUP kernel has survived three back to back
> > runs of untar without locking or getting kswapd pegged, so I'm pretty
> > certain this is cgroups related.  The next steps are to turn cgroups
> > back on but try disabling the memory and IO controllers.
> 
> I tried non-PREEMPT CGROUP but disabled GROUP_MEM_RES_CTLR.
> 
> The results are curious:  the tar does complete (I've done three back to
> back).  However, I did get one soft lockup in kswapd (below).  But the
> system recovers instead of halting I/O and hanging like it did
> previously.
> 
> The soft lockup is in shrink_slab, so perhaps it's a combination of slab
> shrinker and cgroup memory controller issues?
> 

So, kswapd is still looping in reclaim and spending a lot of time in
shrink_slab but it must not be the shrinker itself or that debug patch
would have triggered. It's curious that cgroups are involved with
systemd considering that one would expect those groups to be fairly
small. I still don't have a new theory but will get hold of a Fedora 15
install CD and see can I reproduce it locally.

One last thing, what is the value of /proc/sys/vm/zone_reclaim_mode? Two
of the reporting machines could be NUMA and if that proc file reads as
1, I'd be interested in hearing the results of a test with it set to 0.
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
