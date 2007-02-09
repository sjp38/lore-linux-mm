Date: Thu, 8 Feb 2007 17:18:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Drop PageReclaim()
Message-Id: <20070208171847.e7902ca7.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0702081700360.15866@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702070612010.14171@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0702071428590.30412@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0702081319530.12048@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0702081331290.12167@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0702081340380.13255@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0702081351270.14036@schroedinger.engr.sgi.com>
	<20070208140338.971b3f53.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702081411030.14424@schroedinger.engr.sgi.com>
	<20070208142431.eb81ae70.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702081425000.14424@schroedinger.engr.sgi.com>
	<20070208143746.79c000f5.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702081438510.15063@schroedinger.engr.sgi.com>
	<20070208151341.7e27ca59.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702081613300.15669@schroedinger.engr.sgi.com>
	<20070208163953.ab2bd694.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702081700360.15866@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Feb 2007 17:06:33 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 8 Feb 2007, Andrew Morton wrote:
> 
> > I doubt it.  One would need to troll five-year-old changelogs and mailing
> > list discussion, but iirc that rotation was a large win in certain
> > workloads, preventing scanning meltdowns and general memory stress.
> 
> I'd expect trouble here because of the taking of a LRU lock per page.

PG_reclaim is there to prevent that problem (amongst other things).

If the proportion of written-back pages due to the page scanner is large,
things already suck.  The VM tries to minimise that IO and to maximise the
inode-based writeback.

> For 
> large amounts of concurrent I/O this could be an issue.
> 
> > > One additional issue that is raised by the writeback pages remaining on 
> > > the LRU lists is that we can get into the same livelock situation as with 
> > > mlocked pages if we keep on skipping over writeback pages.
> > 
> > That's why we rotate the reclaimable pages back to the head-of-queue.
> 
> I think the reclaim writeout is one minor contributor here.

To what?

> If there are 
> large amounts of writeback pages from f.e. streaming general I/O then we 
> may run still into bad situations because we need to scan over them.

If the inactive list is small relative to the number of under-writeback
pages in the zone then there could be problems there.  But we just throttle
and wait for some pages to come clean, which seems to work OK.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
