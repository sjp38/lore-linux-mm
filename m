Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25C198E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 14:50:44 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id r9so11069615pfb.13
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 11:50:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 88sor4492058plb.63.2019.01.11.11.50.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 11:50:42 -0800 (PST)
Date: Fri, 11 Jan 2019 12:50:37 -0700
From: Tycho Andersen <tycho@tycho.ws>
Subject: Re: [RFC PATCH v7 07/16] arm64/mm, xpfo: temporarily map dcache
 regions
Message-ID: <20190111195037.GH4102@cisco>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
 <eba179acbfdea5a646c5548cb82138c1c3b74aa2.1547153058.git.khalid.aziz@oracle.com>
 <20190111145445.GA4102@cisco>
 <19e61a22-bbae-d0ae-8d41-158d4b46bf01@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <19e61a22-bbae-d0ae-8d41-158d4b46bf01@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: juergh@gmail.com, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com, Juerg Haefliger <juerg.haefliger@canonical.com>, deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Fri, Jan 11, 2019 at 11:28:19AM -0700, Khalid Aziz wrote:
> On 1/11/19 7:54 AM, Tycho Andersen wrote:
> > On Thu, Jan 10, 2019 at 02:09:39PM -0700, Khalid Aziz wrote:
> >> From: Juerg Haefliger <juerg.haefliger@canonical.com>
> >>
> >> If the page is unmapped by XPFO, a data cache flush results in a fatal
> >> page fault, so let's temporarily map the region, flush the cache, and then
> >> unmap it.
> >>
> >> v6: actually flush in the face of xpfo, and temporarily map the underlying
> >>     memory so it can be flushed correctly
> >>
> >> CC: linux-arm-kernel@lists.infradead.org
> >> Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
> >> Signed-off-by: Tycho Andersen <tycho@docker.com>
> >> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
> >> ---
> >>  arch/arm64/mm/flush.c | 7 +++++++
> >>  1 file changed, 7 insertions(+)
> >>
> >> diff --git a/arch/arm64/mm/flush.c b/arch/arm64/mm/flush.c
> >> index 30695a868107..f12f26b60319 100644
> >> --- a/arch/arm64/mm/flush.c
> >> +++ b/arch/arm64/mm/flush.c
> >> @@ -20,6 +20,7 @@
> >>  #include <linux/export.h>
> >>  #include <linux/mm.h>
> >>  #include <linux/pagemap.h>
> >> +#include <linux/xpfo.h>
> >>  
> >>  #include <asm/cacheflush.h>
> >>  #include <asm/cache.h>
> >> @@ -28,9 +29,15 @@
> >>  void sync_icache_aliases(void *kaddr, unsigned long len)
> >>  {
> >>  	unsigned long addr = (unsigned long)kaddr;
> >> +	unsigned long num_pages = XPFO_NUM_PAGES(addr, len);
> >> +	void *mapping[num_pages];
> > 
> > Does this still compile with -Wvla? It was a bad hack on my part, and
> > we should probably just drop it and come up with something else :)
> 
> I will make a note of it. I hope someone with better knowledge of arm64
> than me can come up with a better solution ;)

It's not just arm64, IIRC everywhere I used xpfo_temp_map() has a VLA.
I think this is in part because some of these paths don't allow
allocation failures, so we can't do a dynamic allocation. Perhaps we
need to reserve some memory for each call site?

Tycho
