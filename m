Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id m496jDvw228148
	for <linux-mm@kvack.org>; Fri, 9 May 2008 06:45:13 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m496jDEY2125898
	for <linux-mm@kvack.org>; Fri, 9 May 2008 08:45:13 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m496jCbQ018597
	for <linux-mm@kvack.org>; Fri, 9 May 2008 08:45:12 +0200
Date: Fri, 9 May 2008 08:45:12 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] memory_hotplug: always initialize pageblock bitmap.
Message-ID: <20080509064512.GD9840@osiris.boeblingen.de.ibm.com>
References: <20080509060609.GB9840@osiris.boeblingen.de.ibm.com> <20080509153910.6b074a30.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080509153910.6b074a30.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 09, 2008 at 03:39:10PM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 9 May 2008 08:06:09 +0200
> Heiko Carstens <heiko.carstens@de.ibm.com> wrote:
> 
> > From: Heiko Carstens <heiko.carstens@de.ibm.com>
> > 
> > Trying to online a new memory section that was added via memory hotplug
> > sometimes results in crashes when the new pages are added via
> > __free_page. Reason for that is that the pageblock bitmap isn't
> > initialized and hence contains random stuff.
> 
> Hmm, curious. In my understanding, memmap_init_zone() initializes it.
> 
>  __add_pages()
> 	-> __add_section()
> 		-> sparse-add_one_section() // allocate usemap
> 		-> __add_zone()
> 			-> memmap_init_zone() // reset pageblock's bitmap 
> 
> Can't memmap_init_zone() does proper initialization ?

Well, it just _sets_ some bits. But nobody has initialized the bitmap
before to zero. It doesn't reset the pageblock's bitmap as your
comment would indicate.

> ........................
> Ah, ok. I see. grow_zone_span() is not called at __add_zone(), then,
> memmap_init_zone() doesn't initialize usemap because memmap is not in zone's
> range.
> 
> Recently, I added a check "zone's start_pfn < pfn < zone's end"
> to memmap_init_zone()'s usemap initialization for !SPARSEMEM case bug FIX.
> (and I think the fix itself is sane.)
> 
> How about calling grow_pgdat_span()/grow_zone_span() from __add_zone() ?

Dunno.. just fixed a few bugs to get it working.. somehow.. ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
