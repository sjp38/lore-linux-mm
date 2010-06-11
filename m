Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 81B646B01AF
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 02:26:10 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5B6Q7AG029788
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 11 Jun 2010 15:26:07 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6549145DE4F
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 15:26:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3487B45DE4E
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 15:26:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 17AF31DB8042
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 15:26:07 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B733F1DB803F
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 15:26:06 +0900 (JST)
Date: Fri, 11 Jun 2010 15:21:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg remove css_get/put per pages v2
Message-Id: <20100611152144.e53d72b3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100611061102.GF5191@balbir.in.ibm.com>
References: <20100608121901.3cab9bdf.kamezawa.hiroyu@jp.fujitsu.com>
	<20100609155940.dd121130.kamezawa.hiroyu@jp.fujitsu.com>
	<20100611061102.GF5191@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jun 2010 11:41:02 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-06-09 15:59:40]:
> 
> > +		if (consume_stock(mem)) {
> > +			/*
> > +			 * It seems dagerous to access memcg without css_get().
> > +			 * But considering how consume_stok works, it's not
> > +			 * necessary. If consume_stock success, some charges
> > +			 * from this memcg are cached on this cpu. So, we
> > +			 * don't need to call css_get()/css_tryget() before
> > +			 * calling consume_stock().
> > +			 */
> > +			rcu_read_unlock();
> > +			goto done;
> > +		}
> > +		if (!css_tryget(&mem->css)) {
> 
> If tryget fails, can one assume that this due to a race and the mem is
> about to be freed?
> 
Yes. it's due to a race and "mem" will be no longer used.
This does the same thing which try_get_mem_cgrou_from_mm() does now.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
