Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 76B346B004D
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 20:53:57 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAD1rs7T018559
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 13 Nov 2009 10:53:54 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D86492AEA81
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 10:53:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B90A91EF082
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 10:53:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A3586E1800F
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 10:53:53 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BF33E1800B
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 10:53:53 +0900 (JST)
Date: Fri, 13 Nov 2009 10:51:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] show per-process swap usage via procfs v3
Message-Id: <20091113105112.c72cf8f5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.1.10.0911121017180.28271@V090114053VZO-1>
References: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262360911050711k47a63896xe4915157664cb822@mail.gmail.com>
	<20091106084806.7503b165.kamezawa.hiroyu@jp.fujitsu.com>
	<20091106134030.a94665d1.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262360911060719y45f4b58ex2f13853f0d142656@mail.gmail.com>
	<20091111112539.71dfac31.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.1.10.0911121017180.28271@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, akpm@linux-foundation.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Nov 2009 10:20:29 -0500 (EST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Wed, 11 Nov 2009, KAMEZAWA Hiroyuki wrote:
> 
> >
> > Index: mm-test-kernel/include/linux/mm_types.h
> > ===================================================================
> > --- mm-test-kernel.orig/include/linux/mm_types.h
> > +++ mm-test-kernel/include/linux/mm_types.h
> > @@ -228,6 +228,7 @@ struct mm_struct {
> >  	 */
> >  	mm_counter_t _file_rss;
> >  	mm_counter_t _anon_rss;
> > +	mm_counter_t _swap_usage;
> 
> This is going to be another hit on vm performance if we get down this
> road.
> 
> At least put
> 
> #ifdef CONFIG_SWAP ?
> 
> around this so that we can switch it off?
> 
Hmm, okay. But I'm not sure I can do it in clean way.
(Or, I'll wait for you updates for mm_counters, or I do by myself.)

> > @@ -597,7 +600,9 @@ copy_one_pte(struct mm_struct *dst_mm, s
> >  						 &src_mm->mmlist);
> >  				spin_unlock(&mmlist_lock);
> >  			}
> > -			if (is_write_migration_entry(entry) &&
> > +			if (!non_swap_entry(entry))
> > +				rss[2]++;
> > +			else if (is_write_migration_entry(entry) &&
> >  					is_cow_mapping(vm_flags)) {
> >  				/*
> 
> What are the implications for fork performance?

This path is executed when page table entry contains a entry of
  !pte_none() && !pte_present().

There are not very big chance to reach here.(this path is under unlikely()).

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
