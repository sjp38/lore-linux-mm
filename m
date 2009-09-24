Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 60E9C6B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 19:48:48 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8ONmqBa020041
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 25 Sep 2009 08:48:52 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B4FA45DE51
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 08:48:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D980F45DE4E
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 08:48:51 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id AD5A5E08002
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 08:48:51 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 550CBE08001
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 08:48:51 +0900 (JST)
Date: Fri, 25 Sep 2009 08:46:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] virtual block device driver (ramzswap)
Message-Id: <20090925084630.990a4193.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4ABBA45A.8010305@vflare.org>
References: <1253595414-2855-1-git-send-email-ngupta@vflare.org>
	<1253595414-2855-3-git-send-email-ngupta@vflare.org>
	<20090924141135.833474ad.kamezawa.hiroyu@jp.fujitsu.com>
	<4ABBA45A.8010305@vflare.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, Marcin Slusarz <marcin.slusarz@gmail.com>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>
List-ID: <linux-mm.kvack.org>

On Thu, 24 Sep 2009 22:24:50 +0530
Nitin Gupta <ngupta@vflare.org> wrote:

> 
> On 09/24/2009 10:41 AM, KAMEZAWA Hiroyuki wrote:
> > On Tue, 22 Sep 2009 10:26:53 +0530
> > Nitin Gupta <ngupta@vflare.org> wrote:
> > 
> > <snip>
> >> +	if (unlikely(clen > max_zpage_size)) {
> >> +		if (rzs->backing_swap) {
> >> +			mutex_unlock(&rzs->lock);
> >> +			fwd_write_request = 1;
> >> +			goto out;
> >> +		}
> >> +
> >> +		clen = PAGE_SIZE;
> >> +		page_store = alloc_page(GFP_NOIO | __GFP_HIGHMEM);
> > Here, and...
> > 
> >> +		if (unlikely(!page_store)) {
> >> +			mutex_unlock(&rzs->lock);
> >> +			pr_info("Error allocating memory for incompressible "
> >> +				"page: %u\n", index);
> >> +			stat_inc(rzs->stats.failed_writes);
> >> +			goto out;
> >> +		}
> >> +
> >> +		offset = 0;
> >> +		rzs_set_flag(rzs, index, RZS_UNCOMPRESSED);
> >> +		stat_inc(rzs->stats.pages_expand);
> >> +		rzs->table[index].page = page_store;
> >> +		src = kmap_atomic(page, KM_USER0);
> >> +		goto memstore;
> >> +	}
> >> +
> >> +	if (xv_malloc(rzs->mem_pool, clen + sizeof(*zheader),
> >> +			&rzs->table[index].page, &offset,
> >> +			GFP_NOIO | __GFP_HIGHMEM)) {
> > 
> > Here.
> >     
> > Do we need to wait until here for detecting page-allocation-failure ?
> > Detecting it here means -EIO for end_swap_bio_write()....unhappy
> > ALERT messages etc..
> > 
> > Can't we add a hook to get_swap_page() for preparing this ("do we have
> > enough pool?") and use only GFP_ATOMIC throughout codes ?
> > (memory pool for this swap should be big to some extent.)
> >
> 
> Yes, we do need to wait until this step for detecting alloc failure since
> we don't really know when pool grow will (almost) surely wail.
> What we can probably do is, hook into OOM notify chain (oom_notify_list)
> and whenever we get this callback, we can start sending pages directly
> to backing swap and do not even attempt to do any allocation.
> 
> 
Hmm...then, I never see -EIO ?

>  
> >>From my user support experience for heavy swap customers,  extra memory allocation for swapping out is just bad...in many cases.
> > (*) I know GFP_IO works well to some extent.
> > 
> 
> We cannot use GFP_IO here as it can cause a deadlock:
> ramzswap alloc() --> not enough memory, try to reclaim some --> swap out ...
> ... some pages to ramzswap --> ramzswap alloc()
> 
Ah, sorry. just my mistake. I wanted to write GFP_NOIO.

Thanks,
-Kame



> Thanks,
> Nitin
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
