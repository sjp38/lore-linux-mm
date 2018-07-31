Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id D37BF6B000D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 11:24:43 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id g4-v6so2941758itf.6
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 08:24:43 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id y10-v6si10848477ioy.263.2018.07.31.08.24.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 08:24:42 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6VFNxmU104464
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 15:24:42 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2120.oracle.com with ESMTP id 2kgh4q1g4k-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 15:24:41 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w6VFOff2003111
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 15:24:41 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6VFOfuO009683
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 15:24:41 GMT
Received: by mail-oi0-f46.google.com with SMTP id k12-v6so28661130oiw.8
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 08:24:09 -0700 (PDT)
MIME-Version: 1.0
References: <20180731124504.27582-1-osalvador@techadventures.net>
 <CAGM2rebds=A5m1ZB1LtD7oxMzM9gjVQvm-QibHjEENmXViw5eA@mail.gmail.com>
 <20180731144157.GA1499@techadventures.net> <20180731144545.fh5syvwcecgvqul6@xakep.localdomain>
 <20180731145125.GB1499@techadventures.net> <CAGM2reZSZHdWECr8-7pj6j=CtjWVF2oKC9SwHhMuOsDkigdzgA@mail.gmail.com>
 <20180731150115.GC1499@techadventures.net> <CAGM2reZ+KhsuFhOVvJzRkQO=66TosvxDW0BYAXNf8Gw8zoRQXQ@mail.gmail.com>
In-Reply-To: <CAGM2reZ+KhsuFhOVvJzRkQO=66TosvxDW0BYAXNf8Gw8zoRQXQ@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 31 Jul 2018 11:23:33 -0400
Message-ID: <CAGM2reaniWqEJ1hArMoreyGn5M+eSYge+wYYMxTrRHth-hxzOQ@mail.gmail.com>
Subject: Re: [PATCH] mm: make __paginginit based on CONFIG_MEMORY_HOTPLUG
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, Mel Gorman <mgorman@suse.de>, Souptick Joarder <jrdr.linux@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

Yes we free meminit when no CONFIG_MEMORY_HOTPLUG
See here:
http://src.illumos.org/source/xref/linux-master/include/asm-generic/vmlinux.lds.h#107

Pavel
On Tue, Jul 31, 2018 at 11:06 AM Pavel Tatashin
<pasha.tatashin@oracle.com> wrote:
>
> On Tue, Jul 31, 2018 at 11:01 AM Oscar Salvador
> <osalvador@techadventures.net> wrote:
> >
> > On Tue, Jul 31, 2018 at 10:53:52AM -0400, Pavel Tatashin wrote:
> > > Thats correct on arches where no sparsemem setup_usemap() will not be
> > > freed up. It is a tiny function, just a few instructions. Not a big
> > > deal.
> > >
> > > Pavel
> > > On Tue, Jul 31, 2018 at 10:51 AM Oscar Salvador
> > > <osalvador@techadventures.net> wrote:
> > > >
> > > > On Tue, Jul 31, 2018 at 10:45:45AM -0400, Pavel Tatashin wrote:
> > > > > Here the patch would look like this:
> > > > >
> > > > > From e640b32dbd329bba5a785cc60050d5d7e1ca18ce Mon Sep 17 00:00:00 2001
> > > > > From: Pavel Tatashin <pasha.tatashin@oracle.com>
> > > > > Date: Tue, 31 Jul 2018 10:37:44 -0400
> > > > > Subject: [PATCH] mm: remove __paginginit
> > > > >
> > > > > __paginginit is the same thing as __meminit except for platforms without
> > > > > sparsemem, there it is defined as __init.
> > > > >
> > > > > Remove __paginginit and use __meminit. Use __ref in one single function
> > > > > that merges __meminit and __init sections: setup_usemap().
> > > > >
> > > > > Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> > > >
> > > > Uhm, I am probably missing something, but with this change, the functions will not be freed up
> > > > while freeing init memory, right?
> > > Thats correct on arches where no sparsemem setup_usemap() will not be
> > > freed up. It is a tiny function, just a few instructions. Not a big
> > > deal.
> >
> > I must be missing something.
> >
> > What about:
> >
> > calc_memmap_size
> > free_area_init_node
> > free_area_init_core
> >
> > These functions are marked with __meminit now.
> > If we have CONFIG_PARSEMEM but not CONFIG_MEMORY_HOTPLUG, these functions will
> > be left there.
>
> I hope we free meminit section if no hotplug configured. If not, than
> sure we should have something like what you suggest not only for these
> functions, but for all other meminit functions in kernel.
>
> >
> > I mean, it is not that it is a big amount, but still.
> >
> > Do not we need something like:
> >
> > diff --git a/include/linux/init.h b/include/linux/init.h
> > index 2538d176dd1f..3b3a88ba80ed 100644
> > --- a/include/linux/init.h
> > +++ b/include/linux/init.h
> > @@ -83,8 +83,12 @@
> >  #define __exit          __section(.exit.text) __exitused __cold notrace
> >
> >  /* Used for MEMORY_HOTPLUG */
> > +#ifdef CONFIG_MEMORY_HOTPLUG
> >  #define __meminit        __section(.meminit.text) __cold notrace \
> >                                                   __latent_entropy
> > +#else
> > +#define __meminit       __init
> > +#endif
> >  #define __meminitdata    __section(.meminit.data)
> >  #define __meminitconst   __section(.meminit.rodata)
> >  #define __memexit        __section(.memexit.text) __exitused __cold notrace
> >
> > on top?
> >
> > Thanks
> > --
> > Oscar Salvador
> > SUSE L3
> >
