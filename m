Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C4B5E6B0055
	for <linux-mm@kvack.org>; Wed, 27 May 2009 21:45:45 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4S1kQ8l030610
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 28 May 2009 10:46:26 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E5DF45DD7B
	for <linux-mm@kvack.org>; Thu, 28 May 2009 10:46:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 31CF245DD78
	for <linux-mm@kvack.org>; Thu, 28 May 2009 10:46:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 078271DB803F
	for <linux-mm@kvack.org>; Thu, 28 May 2009 10:46:26 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B1D981DB8037
	for <linux-mm@kvack.org>; Thu, 28 May 2009 10:46:25 +0900 (JST)
Date: Thu, 28 May 2009 10:44:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/5] add SWAP_HAS_CACHE flag to swap_map
Message-Id: <20090528104448.17c4b37c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090528104013.e410235e.nishimura@mxp.nes.nec.co.jp>
References: <20090526121259.b91b3e9d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090526121547.ce866fe4.kamezawa.hiroyu@jp.fujitsu.com>
	<20090528094157.5c39ac57.nishimura@mxp.nes.nec.co.jp>
	<20090528100501.ab26953f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090528104013.e410235e.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 28 May 2009 10:40:13 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > > So I think it should be like:
> > > 
> > > 	read_swap_cache_async()
> > > 		:
> > > 		valid = swapcache_prepare(entry);
> > > 		if (!valid)
> > > 			break;
> > > 		if (valid == -EAGAIN);
> > > 			continue;
> > > 
> > > to let the context that succeeded in swapcache_prepare() do add_to_swap_cache().
> > > 
> > 
> > What you reccomend is code like this ?
> > 
> > ==
> > 	ret = swapcache_prapare(entry);
> > 	if (ret == -ENOENT)
> > 		break;    /* unused swap entry */
> > 	if (ret == -EBUSY)
> > 		continue; /* to call find_get_page() again */
> > ==
> > 
> Yes.
> By current version of your patch, read_swap_cache_async() might return NULL
> if concurrent read_swap_cache_async() exists. It is different from current behavior.
> And this means swapin_readahead() might fail(it calls read_swap_cache_async()
> twice, though) and can cause oom, right ?
> 
Good point. I fixed this in a patch in my box ;)
Thank you fot good review.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
