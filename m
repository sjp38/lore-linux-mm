Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4DA1D6B004D
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 21:37:46 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAD2bifH004680
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 13 Nov 2009 11:37:44 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D071345DE79
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 11:37:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D3FF45DE6F
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 11:37:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 52BC2E18006
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 11:37:42 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F03981DB803E
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 11:37:41 +0900 (JST)
Date: Fri, 13 Nov 2009 11:35:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] show per-process swap usage via procfs v3
Message-Id: <20091113113502.9c5a93b7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091113105112.c72cf8f5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262360911050711k47a63896xe4915157664cb822@mail.gmail.com>
	<20091106084806.7503b165.kamezawa.hiroyu@jp.fujitsu.com>
	<20091106134030.a94665d1.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262360911060719y45f4b58ex2f13853f0d142656@mail.gmail.com>
	<20091111112539.71dfac31.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.1.10.0911121017180.28271@V090114053VZO-1>
	<20091113105112.c72cf8f5.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, akpm@linux-foundation.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Nov 2009 10:51:12 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > @@ -597,7 +600,9 @@ copy_one_pte(struct mm_struct *dst_mm, s
> > >  						 &src_mm->mmlist);
> > >  				spin_unlock(&mmlist_lock);
> > >  			}
> > > -			if (is_write_migration_entry(entry) &&
> > > +			if (!non_swap_entry(entry))
> > > +				rss[2]++;
> > > +			else if (is_write_migration_entry(entry) &&
> > >  					is_cow_mapping(vm_flags)) {
> > >  				/*
> > 
> > What are the implications for fork performance?
> 
> This path is executed when page table entry contains a entry of
>   !pte_none() && !pte_present().
> 
> There are not very big chance to reach here.(this path is under unlikely()).
> 

[before]
 text    data     bss     dec     hex filename
6649003 3221828 10232816        20103647        132c1df vmlinux
[after]
   text    data     bss     dec     hex filename
6649243 3221828 10232816        20103887        132c2cf vmlinux

Now, 240 bytes of text size..Hmm.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
