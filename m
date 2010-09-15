Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8F37B6B007B
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 23:06:46 -0400 (EDT)
Date: Wed, 15 Sep 2010 11:06:40 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
Message-ID: <20100915030640.GA11141@localhost>
References: <20100915091118.3dbdc961@notabene>
 <4C90139A.1080809@redhat.com>
 <20100915122334.3fa7b35f@notabene>
 <20100915023735.GA9175@localhost>
 <20100915025454.GA10230@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100915025454.GA10230@localhost>
Sender: owner-linux-mm@kvack.org
To: Neil Brown <neilb@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 15, 2010 at 10:54:54AM +0800, Wu Fengguang wrote:
> On Wed, Sep 15, 2010 at 10:37:35AM +0800, Wu Fengguang wrote:
> > On Wed, Sep 15, 2010 at 10:23:34AM +0800, Neil Brown wrote:
> > > On Tue, 14 Sep 2010 20:30:18 -0400
> > > Rik van Riel <riel@redhat.com> wrote:
> > > 
> > > > On 09/14/2010 07:11 PM, Neil Brown wrote:
> > > > 
> > > > > Index: linux-2.6.32-SLE11-SP1/mm/vmscan.c
> > > > > ===================================================================
> > > > > --- linux-2.6.32-SLE11-SP1.orig/mm/vmscan.c	2010-09-15 08:37:32.000000000 +1000
> > > > > +++ linux-2.6.32-SLE11-SP1/mm/vmscan.c	2010-09-15 08:38:57.000000000 +1000
> > > > > @@ -1106,6 +1106,11 @@ static unsigned long shrink_inactive_lis
> > > > >   		/* We are about to die and free our memory. Return now. */
> > > > >   		if (fatal_signal_pending(current))
> > > > >   			return SWAP_CLUSTER_MAX;
> > > > > +		if (!(sc->gfp_mask&  __GFP_IO))
> > > > > +			/* Not allowed to do IO, so mustn't wait
> > > > > +			 * on processes that might try to
> > > > > +			 */
> > > > > +			return SWAP_CLUSTER_MAX;
> > > > >   	}
> > > > >
> > > > >   	/*
> > > > 
> > > > Close.  We must also be sure that processes without __GFP_FS
> > > > set in their gfp_mask do not wait on processes that do have
> > > > __GFP_FS set.
> > > > 
> > > > Considering how many times we've run into a bug like this,
> > > > I'm kicking myself for not having thought of it :(
> > > > 
> > > 
> > > So maybe this?  I've added the test for __GFP_FS, and moved the test before
> > > the congestion_wait on the basis that we really want to get back up the stack
> > > and try the mempool ASAP.
> > 
> > The patch may well fail the !__GFP_IO page allocation and then
> > quickly exhaust the mempool.
> > 
> > Another approach may to let too_many_isolated() use much higher
> > thresholds for !__GFP_IO/FS and lower ones for __GFP_IO/FS. ie. to
> > allow at least nr2 NOIO/FS tasks to be blocked independent of the
> > IO/FS ones.  Since NOIO vmscans typically completes fast, it will then
> > very hard to accumulate enough NOIO processes to be actually blocked.
> > 
> > 
> >                   IO/FS tasks                NOIO/FS tasks           full
> >                   block here                 block here              LRU size
> > |-----------------|--------------------------|-----------------------|
> > |      nr1        |           nr2            |
> 
> How about this fix? We may need very high threshold for NOIO/NOFS to
> prevent possible regressions.

Plus __GFP_WAIT..

---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 225a759..6a896eb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1135,6 +1135,7 @@ static int too_many_isolated(struct zone *zone, int file,
 		struct scan_control *sc)
 {
 	unsigned long inactive, isolated;
+	int ratio;
 
 	if (current_is_kswapd())
 		return 0;
@@ -1150,7 +1151,15 @@ static int too_many_isolated(struct zone *zone, int file,
 		isolated = zone_page_state(zone, NR_ISOLATED_ANON);
 	}
 
-	return isolated > inactive;
+	ratio = 1;
+	if (!(sc->gfp_mask & (__GFP_FS)))
+		ratio <<= 1;
+	if (!(sc->gfp_mask & (__GFP_IO)))
+		ratio <<= 1;
+	if (!(sc->gfp_mask & (__GFP_WAIT)))
+		ratio <<= 1;
+
+	return isolated > inactive * ratio;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
