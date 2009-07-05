Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 954246B004F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 13:28:33 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id l33so862941rvb.26
        for <linux-mm@kvack.org>; Sun, 05 Jul 2009 03:52:08 -0700 (PDT)
Date: Sun, 5 Jul 2009 18:51:58 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
Subject: Re: Found the commit that causes the OOMs
Message-ID: <20090705105158.GA1804@localhost>
References: <4A4AD07E.2040508@redhat.com> <20090705095520.GA31587@localhost> <20090705193551.090E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090705193551.090E.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, David Woodhouse <dwmw2@infradead.org>, David Howells <dhowells@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 05, 2009 at 07:38:54PM +0900, KOSAKI Motohiro wrote:
> > >> OK. thanks.
> > >> I plan to submit this patch after small more tests. it is useful for OOM analysis.
> > >
> > > It is also useful for throttling page reclaim.
> > >
> > > If more than half of the inactive pages in a zone are
> > > isolated, we are probably beyond the point where adding
> > > additional reclaim processes will do more harm than good.
> > 
> > Maybe we can try limiting the isolation phase of direct reclaims to
> > one per CPU?
> > 
> >         mutex_lock(per_cpu_lock);
> >         isolate_pages();
> >         shrink_page_list();
> >         put_back_pages();
> >         mutex_unlock(per_cpu_lock);
> > 
> > This way the isolated pages as well as major parts of direct reclaims
> > will be bounded by CPU numbers. The added overheads should be trivial
> > comparing to the reclaim costs.
> 
> hm, this idea makes performance degression on few CPU machine, I think.

Yes, this is also my big worry. But one possible workaround is to
allow N direct reclaims per CPU.

> e.g.
> if system have only one cpu and sysmtem makes lumpy reclaim, lumpy reclaim
> makes synchronous pageout and it makes very long waiting time.

We can temporarily drop the lock during the writeback waiting.
0-order reclaims shall not be blocked by ongoing high order reclaims.

> I suspect per-cpu decision is not useful in this area.

Maybe. I'm just proposing one more possible way to choose from :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
