Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4230E6B02AE
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 09:33:14 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id j18-v6so5013651iog.7
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 06:33:14 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id d13-v6si8786229ioc.151.2018.07.25.06.33.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 06:33:12 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6PDSkmM104748
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 13:33:11 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2120.oracle.com with ESMTP id 2kbvsnwd1t-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 13:33:10 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6PDX8nv000999
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 13:33:08 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w6PDX8os006556
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 13:33:08 GMT
Received: by mail-oi0-f46.google.com with SMTP id w126-v6so13880106oie.7
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 06:33:07 -0700 (PDT)
MIME-Version: 1.0
References: <20180724235520.10200-1-pasha.tatashin@oracle.com>
 <20180724235520.10200-3-pasha.tatashin@oracle.com> <20180725121459.GA16987@techadventures.net>
In-Reply-To: <20180725121459.GA16987@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 25 Jul 2018 09:32:31 -0400
Message-ID: <CAGM2reZJHc4NYFnQPxJ3wwYXAnicVSqZzndHHpZFeeKHAmzY2Q@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: calculate deferred pages after skipping mirrored memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Wed, Jul 25, 2018 at 8:15 AM Oscar Salvador
<osalvador@techadventures.net> wrote:
>
> On Tue, Jul 24, 2018 at 07:55:19PM -0400, Pavel Tatashin wrote:
> > update_defer_init() should be called only when struct page is about to be
> > initialized. Because it counts number of initialized struct pages, but
> > there we may skip struct pages if there is some mirrored memory.
> >
> > So move, update_defer_init() after checking for mirrored memory.
> >
> > Also, rename update_defer_init() to defer_init() and reverse the return
> > boolean to emphasize that this is a boolean function, that tells that the
> > reset of memmap initialization should be deferred.
> >
> > Make this function self-contained: do not pass number of already
> > initialized pages in this zone by using static counters.
> >
> > Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> > ---
> >  mm/page_alloc.c | 40 ++++++++++++++++++++--------------------
> >  1 file changed, 20 insertions(+), 20 deletions(-)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index cea749b26394..86c678cec6bd 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -306,24 +306,28 @@ static inline bool __meminit early_page_uninitialised(unsigned long pfn)
> >  }
> >
> >  /*
> > - * Returns false when the remaining initialisation should be deferred until
> > + * Returns true when the remaining initialisation should be deferred until
> >   * later in the boot cycle when it can be parallelised.
> >   */
> > -static inline bool update_defer_init(pg_data_t *pgdat,
> > -                             unsigned long pfn, unsigned long zone_end,
> > -                             unsigned long *nr_initialised)
> > +static inline bool defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
> >  {
> > +     static unsigned long prev_end_pfn, nr_initialised;
> > +
> > +     if (prev_end_pfn != end_pfn) {
> > +             prev_end_pfn = end_pfn;
> > +             nr_initialised = 0;
> > +     }
> Hi Pavel,
>
> What about a comment explaining that "if".
> I am not the brightest one, so it took me a bit to figure out that we got that "if" there
> because now that the variables are static, we need to somehow track whenever we change to
> another zone.

Hi Oscar,

Hm, yeah a comment would be appropriate here. I will send an updated
patch. I will also change the functions from inline to normal
functions as Andrew pointed out: it is not a good idea to use statics
in inline functions.

Thank you,
Pavel
