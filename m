Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B2B86600365
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 04:18:30 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6R8IiMR003003
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Jul 2010 17:18:44 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A87545DE51
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:18:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F1E545DE55
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:18:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id F03721DB803C
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:18:43 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C5A41DB805B
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:18:40 +0900 (JST)
Date: Tue, 27 Jul 2010 17:13:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
Message-Id: <20100727171351.98d5fb60.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <pfn.valid.v4.reply.2@mdm.bga.com>
References: <1280159163-23386-1-git-send-email-minchan.kim@gmail.com>
	<alpine.DEB.2.00.1007261136160.5438@router.home>
	<pfn.valid.v4.reply.1@mdm.bga.com>
	<AANLkTimtTVvorrR9pDVTyPKj0HbYOYY3aR7B-QWGhTei@mail.gmail.com>
	<pfn.valid.v4.reply.2@mdm.bga.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Milton Miller <miltonm@bga.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Jul 2010 03:12:38 -0500
Milton Miller <miltonm@bga.com> wrote:

> > > > > +/*
> > > > > + * Fill pg->private on valid mem_map with page itself.
> > > > > + * pfn_valid() will check this later. (see include/linux/mmzone.h)
> > > > > + * Every arch for supporting hole of mem_map should call
> > > > > + * mark_valid_memmap(start, end). please see usage in ARM.
> > > > > + */
> > > > > +void mark_valid_memmap(unsigned long start, unsigned long end)
> > > > > +{
> > > > > +	struct mem_section *ms;
> > > > > +	unsigned long pos, next;
> > > > > +	struct page *pg;
> > > > > +	void *memmap, *mapend;
> > > > > +
> > > > > +	for (pos = start; pos < end; pos = next) {
> > > > > +		next = (pos + PAGES_PER_SECTION) & PAGE_SECTION_MASK;
> > > > > +		ms = __pfn_to_section(pos);
> > > > > +		if (!valid_section(ms))
> > > > > +			continue;
> > > > > +	
> > > > > +		for (memmap = (void*)pfn_to_page(pos),
> > > > > +					/* The last page in section */
> > > > > +					mapend = pfn_to_page(next-1);
> > > > > +				memmap < mapend; memmap += PAGE_SIZE) {
> > > > > +			pg = virt_to_page(memmap);
> > > > > +			set_page_private(pg, (unsigned long)pg);
> > > > > +		}
> > > > > +	}
> > > > > +}
> 
> Hmm, this loop would need to change for sections.   And sizeof(struct
> page) % PAGE_SIZE may not be 0, so we want a global symbol for sparsemem
> too. 
IIUC, sizeof(struct page) % PAGE_SIZE is not a probelm.


> Perhaps the mem_section array.  Using a symbol that is part of
> the model pre-checks can remove a global symbol lookup and has the side
> effect of making sure our pfn_valid is for the right model.
> 

But yes, maybe it's good to make use of a fixed-(magic)-value.


Tanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
