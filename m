Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3F2746B004F
	for <linux-mm@kvack.org>; Tue, 26 May 2009 21:32:16 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4R1WiJF031655
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 27 May 2009 10:32:44 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DFD145DE50
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:32:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D5B745DE4F
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:32:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 738D11DB8038
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:32:44 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 26DD21DB8037
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:32:41 +0900 (JST)
Date: Wed, 27 May 2009 10:31:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/5] (experimental) chase and free cache only swap
Message-Id: <20090527103107.9c04eb55.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090527012658.GA9692@cmpxchg.org>
References: <20090526121259.b91b3e9d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090526121834.dd9a4193.kamezawa.hiroyu@jp.fujitsu.com>
	<20090526181359.GB2843@cmpxchg.org>
	<20090527090813.a0e436f8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090527012658.GA9692@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 27 May 2009 03:26:58 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Wed, May 27, 2009 at 09:08:13AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Tue, 26 May 2009 20:14:00 +0200
> > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> > > On Tue, May 26, 2009 at 12:18:34PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > 
> > > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > 
> > > > Just a trial/example patch.
> > > > I'd like to consider more. Better implementation idea is welcome.
> > > > 
> > > > When the system does swap-in/swap-out repeatedly, there are 
> > > > cache-only swaps in general.
> > > > Typically,
> > > >  - swapped out in past but on memory now while vm_swap_full() returns true
> > > > pages are cache-only swaps. (swap_map has no references.)
> > > > 
> > > > This cache-only swaps can be an obstacles for smooth page reclaiming.
> > > > Current implemantation is very naive, just scan & free.
> > > 
> > > I think we can just remove that vm_swap_full() check in do_swap_page()
> > > and try to remove the page from swap cache unconditionally.
> > > 
> > I'm not sure why reclaim swap entry only at write fault.
> 
> How do you come to that conclusion?  Do you mean the current code does
> that? 
yes.

2474         pte = mk_pte(page, vma->vm_page_prot);
2475         if (write_access && reuse_swap_page(page)) {
2476                 pte = maybe_mkwrite(pte_mkdirty(pte), vma);
2477                 write_access = 0;
2478         }


> Did you understand that I suggested that?
> 

I thought you suggested that swp_entry should be reclaimed in read-fault as
same way as write-fault.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
