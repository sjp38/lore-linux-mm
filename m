Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A90DF6B004F
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 03:40:42 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6L7eiAW019866
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Jul 2009 16:40:44 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D5C845DE56
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 16:40:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B7E7345DE4F
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 16:40:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B74A1DB8037
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 16:40:42 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F495E0800C
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 16:40:41 +0900 (JST)
Date: Tue, 21 Jul 2009 16:38:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] hibernate / memory hotplug: always use
 for_each_populated_zone()
Message-Id: <20090721163846.2a8001c1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090721071508.GB12734@osiris.boeblingen.de.ibm.com>
References: <1248103551.23961.0.camel@localhost.localdomain>
	<4A64E1D6.8090102@crca.org.au>
	<20090721071508.GB12734@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Nigel Cunningham <ncunningham@crca.org.au>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Jul 2009 09:15:08 +0200
Heiko Carstens <heiko.carstens@de.ibm.com> wrote:

> On Tue, Jul 21, 2009 at 07:29:58AM +1000, Nigel Cunningham wrote:
> > Hi.
> > 
> > Gerald Schaefer wrote:
> > > From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> > > 
> > > Use for_each_populated_zone() instead of for_each_zone() in hibernation
> > > code. This fixes a bug on s390, where we allow both config options
> > > HIBERNATION and MEMORY_HOTPLUG, so that we also have a ZONE_MOVABLE
> > > here. We only allow hibernation if no memory hotplug operation was
> > > performed, so in fact both features can only be used exclusively, but
> > > this way we don't need 2 differently configured (distribution) kernels.
> > > 
> > > If we have an unpopulated ZONE_MOVABLE, we allow hibernation but run
> > > into a BUG_ON() in memory_bm_test/set/clear_bit() because hibernation
> > > code iterates through all zones, not only the populated zones, in
> > > several places. For example, swsusp_free() does for_each_zone() and
> > > then checks for pfn_valid(), which is true even if the zone is not
> > > populated, resulting in a BUG_ON() later because the pfn cannot be
> > > found in the memory bitmap.
> > 
> > I agree with your logic and patch, but doesn't this also imply that the
> > s390 implementation pfn_valid should be changed to return false for
> > those pages?
> 
> For CONFIG_SPARSEMEM, which s390 uses, there is no architecture specific
> pfn_valid() implementation.
> Also it looks like the semantics of pfn_valid() aren't clear.
> At least for sparsemem it means nothing but "the memmap for the section
> this page belongs to exists". So it just means the struct page for the
> pfn exists.

Historically, pfn_valid() just means "there is a memmap." no other meanings
in any configs/archs.


> We still have pfn_present() for CONFIG_SPARSEMEM. But that just means
> "some pages in the section this pfn belongs to are present."

It just exists for sparsemem internal purpose IIUC.


> So it looks like checking for pfn_valid() and afterwards checking
> for PG_Reserved (?) might give what one would expect.
I think so, too. If memory is offline, PG_reserved is always set.

In general, it's expected that "page is contiguous in MAX_ORDER range"
and no memory holes in MAX_ORDER. In most case, PG_reserved is checked
for skipping not-existing memory.


> Looks all a bit confusing to me.
> Or maybe it's just me who is confused? :)
> 
IIRC, there are no generic interface to know whether there is a physical page.

pfn_valid() is only for memmap and people have used
	if (pfn_valid(pfn) && !PageReserved(page))
check.
But, hmm, If hibernation have to save PG_reserved memory, general solution is
use copy_user_page() and handle fault.

Alternative is making use of walk_memory_resource() as memory hotplug does.
It checks resource information registered.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
