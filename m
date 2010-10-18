Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A6B166B00B3
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 01:05:05 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9I553Kj011954
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 18 Oct 2010 14:05:03 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1617D45DE51
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 14:05:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E178B45DE50
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 14:05:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C040D1DB803F
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 14:05:02 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 66B1E1DB8038
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 14:05:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
In-Reply-To: <20101018151459.2b443221@notabene>
References: <20100915184434.18e2d933@notabene> <20101018151459.2b443221@notabene>
Message-Id: <20101018140116.3AE8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 18 Oct 2010 14:04:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Neil Brown <neilb@suse.de>, Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

> On Wed, 15 Sep 2010 18:44:34 +1000
> Neil Brown <neilb@suse.de> wrote:
> 
> > On Wed, 15 Sep 2010 16:28:43 +0800
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > Neil,
> > > 
> > > Sorry for the rushed and imaginary ideas this morning..
> > > 
> > > > @@ -1101,6 +1101,12 @@ static unsigned long shrink_inactive_lis
> > > >  	int lumpy_reclaim = 0;
> > > >  
> > > >  	while (unlikely(too_many_isolated(zone, file, sc))) {
> > > > +		if ((sc->gfp_mask & GFP_IOFS) != GFP_IOFS)
> > > > +			/* Not allowed to do IO, so mustn't wait
> > > > +			 * on processes that might try to
> > > > +			 */
> > > > +			return SWAP_CLUSTER_MAX;
> > > > +
> > > 
> > > The above patch should behavior like this: it returns SWAP_CLUSTER_MAX
> > > to cheat all the way up to believe "enough pages have been reclaimed".
> > > So __alloc_pages_direct_reclaim() see non-zero *did_some_progress and
> > > go on to call get_page_from_freelist(). That normally fails because
> > > the task didn't really scanned the LRU lists. However it does have the
> > > possibility to succeed -- when so many processes are doing concurrent
> > > direct reclaims, it may luckily get one free page reclaimed by other
> > > tasks. What's more, if it does fail to get a free page, the upper
> > > layer __alloc_pages_slowpath() will be repeat recalling
> > > __alloc_pages_direct_reclaim(). So, sooner or later it will succeed in
> > > "stealing" a free page reclaimed by other tasks.
> > > 
> > > In summary, the patch behavior for !__GFP_IO/FS is
> > > - won't do any page reclaim
> > > - won't fail the page allocation (unexpected)
> > > - will wait and steal one free page from others (unreasonable)
> > > 
> > > So it will address the problem you encountered, however it sounds
> > > pretty unexpected and illogical behavior, right?
> > > 
> > > I believe this patch will address the problem equally well.
> > > What do you think?
> > 
> > Thank you for the detailed explanation.  Is agree with your reasoning and
> > now understand why your patch is sufficient.
> > 
> > I will get it tested and let you know how that goes.
> 
> (sorry this has taken a month to follow up).
> 
> Testing shows that this patch seems to work.
> The test load (essentially kernbench) doesn't deadlock any more, though it
> does get bogged down thrashing in swap so it doesn't make a lot more
> progress :-)  I guess that is to be expected.
> 
> One observation is that the kernbench generated 10%-20% more context switches
> with the patch than without.  Is that to be expected?
> 
> Do you have plans for sending this patch upstream?

Wow, I had thought this patch has been merged already. Wu, can you please
repost this one? and please add my and Neil's ack tag.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
