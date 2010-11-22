Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F2BF16B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 19:19:15 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAM0JAQW015412
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 22 Nov 2010 09:19:10 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 207C645DE55
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 09:19:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D58B145DE65
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 09:19:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 78441E08004
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 09:19:08 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B0FF1DB803C
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 09:19:08 +0900 (JST)
Date: Mon, 22 Nov 2010 09:13:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] alloc_contig_pages() allocate big chunk memory
 using migration
Message-Id: <20101122091334.8ea11a43.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101121152556.GC20947@barrios-desktop>
References: <20101119171033.a8d9dc8f.kamezawa.hiroyu@jp.fujitsu.com>
	<20101119171528.32674ef4.kamezawa.hiroyu@jp.fujitsu.com>
	<20101121152556.GC20947@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Bob Liu <lliubbo@gmail.com>, fujita.tomonori@lab.ntt.co.jp, m.nazarewicz@samsung.com, pawel@osciak.com, andi.kleen@intel.com, felipe.contreras@gmail.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Nov 2010 00:25:56 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Fri, Nov 19, 2010 at 05:15:28PM +0900, KAMEZAWA Hiroyuki wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Add an function to allocate contiguous memory larger than MAX_ORDER.
> > The main difference between usual page allocator is that this uses
> > memory offline technique (Isolate pages and migrate remaining pages.).
> > 
> > I think this is not 100% solution because we can't avoid fragmentation,
> > but we have kernelcore= boot option and can create MOVABLE zone. That
> > helps us to allow allocate a contiguous range on demand.
> > 
> > The new function is
> > 
> >   alloc_contig_pages(base, end, nr_pages, alignment)
> > 
> > This function will allocate contiguous pages of nr_pages from the range
> > [base, end). If [base, end) is bigger than nr_pages, some pfn which
> > meats alignment will be allocated. If alignment is smaller than MAX_ORDER,
> > it will be raised to be MAX_ORDER.
> > 
> > __alloc_contig_pages() has much more arguments.
> > 
> > 
> > Some drivers allocates contig pages by bootmem or hiding some memory
> > from the kernel at boot. But if contig pages are necessary only in some
> > situation, kernelcore= boot option and using page migration is a choice.
> > 
> > Changelog: 2010-11-19
> >  - removed no_search
> >  - removed some drain_ functions because they are heavy.
> >  - check -ENOMEM case
> > 
> > Changelog: 2010-10-26
> >  - support gfp_t
> >  - support zonelist/nodemask
> >  - support [base, end) 
> >  - support alignment
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Minchan Kim <minchan.kim@gmail.com>
> 
> Trivial comment below. 
> 
> > +EXPORT_SYMBOL_GPL(alloc_contig_pages);
> > +
> > +struct page *alloc_contig_pages_host(unsigned long nr_pages, int align_order)
> > +{
> > +	return __alloc_contig_pages(0, max_pfn, nr_pages, align_order, -1,
> > +				GFP_KERNEL | __GFP_MOVABLE, NULL);
> > +}
> 
> We need include #include <linux/bootmem.h> for using max_pfn. 
> 

will add that.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
