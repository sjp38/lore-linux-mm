Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 350458D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 04:54:41 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1B2B43EE0B6
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:54:37 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0107345DE51
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:54:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D274245DE4E
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:54:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C72BE1DB8037
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:54:36 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 87C391DB803B
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:54:36 +0900 (JST)
Date: Mon, 28 Feb 2011 18:48:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC PATCH] page_cgroup: Reduce allocation overhead for
 page_cgroup array for CONFIG_SPARSEMEM v4
Message-Id: <20110228184821.f10dba19.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110228095316.GC4648@tiehlicka.suse.cz>
References: <20110223151047.GA7275@tiehlicka.suse.cz>
	<1298485162.7236.4.camel@nimitz>
	<20110224134045.GA22122@tiehlicka.suse.cz>
	<20110225122522.8c4f1057.kamezawa.hiroyu@jp.fujitsu.com>
	<20110225095357.GA23241@tiehlicka.suse.cz>
	<20110228095347.7510b1d4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110228091256.GA4648@tiehlicka.suse.cz>
	<20110228182322.a34cc1fd.kamezawa.hiroyu@jp.fujitsu.com>
	<20110228095316.GC4648@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 28 Feb 2011 10:53:16 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Mon 28-02-11 18:23:22, KAMEZAWA Hiroyuki wrote:
> [...]
> > > From 84a9555741b59cb2a0a67b023e4bd0f92c670ca1 Mon Sep 17 00:00:00 2001
> > > From: Michal Hocko <mhocko@suse.cz>
> > > Date: Thu, 24 Feb 2011 11:25:44 +0100
> > > Subject: [PATCH] page_cgroup: Reduce allocation overhead for page_cgroup array for CONFIG_SPARSEMEM
> > > 
> > > Currently we are allocating a single page_cgroup array per memory
> > > section (stored in mem_section->base) when CONFIG_SPARSEMEM is selected.
> > > This is correct but memory inefficient solution because the allocated
> > > memory (unless we fall back to vmalloc) is not kmalloc friendly:
> > >         - 32b - 16384 entries (20B per entry) fit into 327680B so the
> > >           524288B slab cache is used
> > >         - 32b with PAE - 131072 entries with 2621440B fit into 4194304B
> > >         - 64b - 32768 entries (40B per entry) fit into 2097152 cache
> > > 
> > > This is ~37% wasted space per memory section and it sumps up for the
> > > whole memory. On a x86_64 machine it is something like 6MB per 1GB of
> > > RAM.
> > > 
> > > We can reduce the internal fragmentation by using alloc_pages_exact
> > > which allocates PAGE_SIZE aligned blocks so we will get down to <4kB
> > > wasted memory per section which is much better.
> > > 
> > > We still need a fallback to vmalloc because we have no guarantees that
> > > we will have a continuous memory of that size (order-10) later on during
> > > the hotplug events.
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > > CC: Dave Hansen <dave@linux.vnet.ibm.com>
> > > CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Thanks. I will repost it with Andrew in the CC.
> 
> > 
> > But...nitpick, it may be from my fault..
> [...]
> > > +static void free_page_cgroup(void *addr)
> > > +{
> > > +	if (is_vmalloc_addr(addr)) {
> > > +		vfree(addr);
> > > +	} else {
> > > +		struct page *page = virt_to_page(addr);
> > > +		if (!PageReserved(page)) { /* Is bootmem ? */
> > 
> > I think we never see PageReserved if we just use alloc_pages_exact()/vmalloc().
> 
> I have checked that and we really do not (unless I am missing some
> subtle side effects). Anyway, I think we still should at least BUG_ON on
> that.
> 
> > Maybe my old patch was not enough and this kind of junks are remaining in
> > the original code.
> 
> Should I incorporate it into the patch. I think that a separate one
> would be better for readability.
> 
> ---
> From e7a897a42b526620eb4afada2d036e1c9ff9e62a Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Mon, 28 Feb 2011 10:43:12 +0100
> Subject: [PATCH] page_cgroup array is never stored on reserved pages
> 
> KAMEZAWA Hiroyuki noted that free_pages_cgroup doesn't have to check for
> PageReserved because we never store the array on reserved pages
> (neither alloc_pages_exact nor vmalloc use those pages).
> 
> So we can replace the check by a BUG_ON.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thank you.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
