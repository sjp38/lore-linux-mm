Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 843466B004F
	for <linux-mm@kvack.org>; Sat, 16 May 2009 04:53:51 -0400 (EDT)
Date: Sat, 16 May 2009 16:54:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH -mm] vmscan: protect a fraction of file backed mapped
	pages from reclaim
Message-ID: <20090516085416.GA10221@localhost>
References: <20090512120002.D616.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0905121650090.14226@qirst.com> <20090513084306.5874.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0905141612100.15881@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0905141612100.15881@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Fri, May 15, 2009 at 04:14:31AM +0800, Christoph Lameter wrote:
> On Wed, 13 May 2009, KOSAKI Motohiro wrote:
> 
> > > All these expiration modifications do not take into account that a desktop
> > > may sit idle for hours while some other things run in the background (like
> > > backups at night or updatedb and other maintenance things). This still
> > > means that the desktop will be usuable in the morning.
> >
> > Have you seen this phenomenom?
> > I always use linux desktop for development. but I haven't seen it.
> > perhaps I have no luck. I really want to know reproduce way.
> >
> > Please let me know reproduce way.
> 
> Run a backup (or rsync) over a few hundred GB.

Simple experiments show that rsync is use-once workload:

1) fresh run(full backup): the source file pages in the logo/ dir are cached and
   referenced *once*:

        rsync -a logo localhost:/tmp/

2) second run(incremental backup): only the updated files are read and
   read only once:

        rsync -a logo localhost:/tmp/

> > > The percentage of file backed pages protected is set via
> > > /proc/sys/vm/file_mapped_ratio. This defaults to 20%.
> >
> > Why do you think typical mapped ratio is less than 20% on desktop machine?
> 
> Observation of the typical mapped size of Firefox under KDE.

Since the explicit PROT_EXEC targeted mmap page protection plus Rik's
use-once patch works just OK for rsync - a typical backup scenario,
and it works without an extra sysctl tunable, I tend to continue
pushing the PROT_EXEC approach :-)

Thanks,
Fengguang

> > key point is access-once vs access-many.
> 
> Nothing against it if it works.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
