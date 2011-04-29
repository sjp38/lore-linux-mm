Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 15F5C900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 11:03:45 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <20110428202701.GB4658@suse.de>
References: <20110428140725.GX4658@suse.de>
	 <1304000714.2598.0.camel@mulgrave.site> <20110428150827.GY4658@suse.de>
	 <1304006499.2598.5.camel@mulgrave.site>
	 <1304009438.2598.9.camel@mulgrave.site>
	 <1304009778.2598.10.camel@mulgrave.site> <20110428171826.GZ4658@suse.de>
	 <1304015436.2598.19.camel@mulgrave.site> <20110428192104.GA4658@suse.de>
	 <1304020767.2598.21.camel@mulgrave.site>  <20110428202701.GB4658@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 29 Apr 2011 10:02:36 -0500
Message-ID: <1304089357.2559.4.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, mgorman@novell.com

On Thu, 2011-04-28 at 21:27 +0100, Mel Gorman wrote:
> On Thu, Apr 28, 2011 at 02:59:27PM -0500, James Bottomley wrote:
> > On Thu, 2011-04-28 at 20:21 +0100, Mel Gorman wrote:
> > > On Thu, Apr 28, 2011 at 01:30:36PM -0500, James Bottomley wrote:
> > > > > Way hey, cgroups are also in the mix. How jolly.
> > > > > 
> > > > > Is systemd a common element of the machines hitting this bug by any
> > > > > chance?
> > > > 
> > > > Well, yes, the bug report is against FC15, which needs cgroups for
> > > > systemd.
> > > > 
> > > 
> > > Ok although we do not have direct evidence that it's the problem yet. A
> > > broken shrinker could just mean we are also trying to aggressively
> > > reclaim in cgroups.
> > > 
> > > > > The remaining traces seem to be follow-on damage related to the three
> > > > > issues of "shrinkers are bust in some manner" causing "we are not
> > > > > getting over the min watermark" and as a side-show "we are spending lots
> > > > > of time doing something unspecified but unhelpful in cgroups".
> > > > 
> > > > Heh, well find a way for me to verify this: I can't turn off cgroups
> > > > because systemd then won't work and the machine won't boot ...
> > > > 
> > > 
> > > Same testcase, same kernel but a distro that is not using systemd to
> > > verify if cgroups are the problem. Not ideal I know. When I'm back
> > > online Tuesday, I'll try reproducing this on a !Fedora distribution. In
> > > the meantime, the following untested hatchet job might spit out
> > > which shrinker we are getting stuck in. It is also breaking out of
> > > the shrink_slab loop so it'd even be interesting to see if the bug
> > > is mitigated in any way.
> > 
> > Actually, talking to Chris, I think I can get the system up using
> > init=/bin/bash without systemd, so I can try the no cgroup config.
> > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index c74a501..ed99104 100644
> > 
> > In the mean time, this patch produces:
> > 
> > (that's nothing ... apparently the trace doesn't activate when kswapd
> > goes mad).
> > 
> 
> Or is looping there for shorter than we expect. HZ/10?

Still doesn't print anything, even with HZ/10.

James



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
