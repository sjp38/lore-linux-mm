Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB46ENed024528
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 4 Dec 2008 15:14:24 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CF1C45DE5B
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 15:14:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D22145DD82
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 15:14:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CCFD1DB8037
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 15:14:22 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B80371DB8048
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 15:14:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 06/11] memcg: make inactive_anon_is_low()
In-Reply-To: <20081203135249.GE17701@balbir.in.ibm.com>
References: <20081201211457.1CDC.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081203135249.GE17701@balbir.in.ibm.com>
Message-Id: <20081204151202.1D75.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  4 Dec 2008 15:14:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > +/*
> > + * The inactive anon list should be small enough that the VM never has to
> > + * do too much work, but large enough that each inactive page has a chance
> > + * to be referenced again before it is swapped out.
> > + *
> > + * this calculation is straightforward porting from
> > + * page_alloc.c::setup_per_zone_inactive_ratio().
> > + * it describe more detail.
> > + */
> > +static void mem_cgroup_set_inactive_ratio(struct mem_cgroup *memcg)
> > +{
> > +	unsigned int gb, ratio;
> > +
> > +	gb = res_counter_read_u64(&memcg->res, RES_LIMIT) >> 30;
> > +	if (gb)
> > +		ratio = int_sqrt(10 * gb);
> 
> I don't understand where the magic number 10 comes from?

the function comment write to

  this calculation is straightforward porting from
  page_alloc.c::setup_per_zone_inactive_ratio().
  it describe more detail.





> > @@ -1400,7 +1412,7 @@ static unsigned long shrink_list(enum lr
> >  	}
> > 
> >  	if (lru == LRU_ACTIVE_ANON &&
> > -	    (!scan_global_lru(sc) || inactive_anon_is_low(zone))) {
> > +	    inactive_anon_is_low(zone, sc)) {
> 
> Can't we merge the line with the "if" statement

Will fix.

thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
