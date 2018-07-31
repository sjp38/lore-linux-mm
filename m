Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 082B26B0271
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 11:01:18 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g25-v6so1708545wmh.6
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 08:01:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u4-v6sor6006514wrt.37.2018.07.31.08.01.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 08:01:16 -0700 (PDT)
Date: Tue, 31 Jul 2018 17:01:15 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH] mm: make __paginginit based on CONFIG_MEMORY_HOTPLUG
Message-ID: <20180731150115.GC1499@techadventures.net>
References: <20180731124504.27582-1-osalvador@techadventures.net>
 <CAGM2rebds=A5m1ZB1LtD7oxMzM9gjVQvm-QibHjEENmXViw5eA@mail.gmail.com>
 <20180731144157.GA1499@techadventures.net>
 <20180731144545.fh5syvwcecgvqul6@xakep.localdomain>
 <20180731145125.GB1499@techadventures.net>
 <CAGM2reZSZHdWECr8-7pj6j=CtjWVF2oKC9SwHhMuOsDkigdzgA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reZSZHdWECr8-7pj6j=CtjWVF2oKC9SwHhMuOsDkigdzgA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, Mel Gorman <mgorman@suse.de>, Souptick Joarder <jrdr.linux@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

On Tue, Jul 31, 2018 at 10:53:52AM -0400, Pavel Tatashin wrote:
> Thats correct on arches where no sparsemem setup_usemap() will not be
> freed up. It is a tiny function, just a few instructions. Not a big
> deal.
> 
> Pavel
> On Tue, Jul 31, 2018 at 10:51 AM Oscar Salvador
> <osalvador@techadventures.net> wrote:
> >
> > On Tue, Jul 31, 2018 at 10:45:45AM -0400, Pavel Tatashin wrote:
> > > Here the patch would look like this:
> > >
> > > From e640b32dbd329bba5a785cc60050d5d7e1ca18ce Mon Sep 17 00:00:00 2001
> > > From: Pavel Tatashin <pasha.tatashin@oracle.com>
> > > Date: Tue, 31 Jul 2018 10:37:44 -0400
> > > Subject: [PATCH] mm: remove __paginginit
> > >
> > > __paginginit is the same thing as __meminit except for platforms without
> > > sparsemem, there it is defined as __init.
> > >
> > > Remove __paginginit and use __meminit. Use __ref in one single function
> > > that merges __meminit and __init sections: setup_usemap().
> > >
> > > Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> >
> > Uhm, I am probably missing something, but with this change, the functions will not be freed up
> > while freeing init memory, right?
> Thats correct on arches where no sparsemem setup_usemap() will not be
> freed up. It is a tiny function, just a few instructions. Not a big
> deal.

I must be missing something.

What about:

calc_memmap_size
free_area_init_node
free_area_init_core
 
These functions are marked with __meminit now.
If we have CONFIG_PARSEMEM but not CONFIG_MEMORY_HOTPLUG, these functions will
be left there.

I mean, it is not that it is a big amount, but still.

Do not we need something like:

diff --git a/include/linux/init.h b/include/linux/init.h
index 2538d176dd1f..3b3a88ba80ed 100644
--- a/include/linux/init.h
+++ b/include/linux/init.h
@@ -83,8 +83,12 @@
 #define __exit          __section(.exit.text) __exitused __cold notrace
 
 /* Used for MEMORY_HOTPLUG */
+#ifdef CONFIG_MEMORY_HOTPLUG
 #define __meminit        __section(.meminit.text) __cold notrace \
 						  __latent_entropy
+#else
+#define __meminit	 __init
+#endif
 #define __meminitdata    __section(.meminit.data)
 #define __meminitconst   __section(.meminit.rodata)
 #define __memexit        __section(.memexit.text) __exitused __cold notrace

on top?

Thanks
-- 
Oscar Salvador
SUSE L3
