Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 06DE56B0081
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 16:33:41 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so74079834pdj.0
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 13:33:40 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id d2si12784510pdn.45.2015.06.18.13.33.39
        for <linux-mm@kvack.org>;
        Thu, 18 Jun 2015 13:33:40 -0700 (PDT)
Date: Thu, 18 Jun 2015 13:33:35 -0700
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [RFC PATCH 00/12] mm: mirrored memory support for page buddy
 allocations
Message-ID: <20150618203335.GA3829@agluck-desk.sc.intel.com>
References: <55704A7E.5030507@huawei.com>
 <557FD5F8.10903@suse.cz>
 <557FDB9B.1090105@huawei.com>
 <557FF06A.3020000@suse.cz>
 <55821D85.3070208@huawei.com>
 <55825DF0.9090903@suse.cz>
 <55829149.60807@huawei.com>
 <5582959E.4080402@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5582959E.4080402@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 18, 2015 at 11:55:42AM +0200, Vlastimil Babka wrote:
> >>>If there are many mirror regions in one node, then it will be many holes in the
> >>>normal zone, is this fine?
> >>
> >>Yeah, it doesn't matter how many holes there are.
> >
> >So mirror zone and normal zone will span each other, right?
> >
> >e.g. node 1: 4G-8G(normal), 8-12G(mirror), 12-16G(normal), 16-24G(mirror), 24-28G(normal) ...
> >normal: start=4G, size=28-4=24G,
> >mirror: start=8G, size=24-8=16G,
> 
> Yes, that works. It's somewhat unfortunate wrt performance that the hardware
> does it like this though.

With current Xeon h/w you can have one mirrored range per memory
controller ... and there are two memory controllers on a cpu socket,
so two mirrored ranges per node.  So a map might look like:

SKT0: MC0: 0-2G Mirrored (but we may want to ignore mirror here to keep it for ZONE_DMA)
SKT0: MC0: 2G-4G No memory ... I/O mapping area
SKT0: MC0: 4G-34G Not mirrored
SKT0: MC1: 34G-40G Mirrored
SKT0: MC1: 40G-66G Not mirrored

SKT1: MC0: 66G-70G Mirror
SKT1: MC0: 70G-98G Not Mirrored
SKT1: MC1: 98G-102G Mirror
SKT1: MC1: 102G-130G Not Mirrored

... and so on.

> >I think zone is defined according to the special address range, like 16M(DMA), 4G(DMA32),
> 
> Traditionally yes. But then there is ZONE_MOVABLE, this year's LSF/MM we
> discussed (and didn't outright deny) ZONE_CMA...
> I'm not saying others will favour the new zone approach though, it's just my
> opinion that it might be a better option than a new migratetype.

If we are going to have lots of zones ... then perhaps we will
need a fast way to look at a "struct page" and decide which zone
it belongs to.  Complicated math on the address deosn't sound ideal.
If the complex zone model is just for 64-bit, are there enough bits
available in page->flags (3 bits for 8 options ... which we are close
to filling now ... 4 bits for future breathing room).

> >and is it appropriate to add a new mirror zone with a volatile physical address?
> 
> By "volatile" you mean what, that the example above would change
> dynamically? That would be rather challenging...

If we hot-add another cpu together with on die memory controllers connected
to more memory ... then some of the new memory might be mirrored.  Current
h/w doesn't allow mirrored areas to grow/shrink (though if there are a lot
of errors we may break a mirror so a whole range could lose the mirror attribute).

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
