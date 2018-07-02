Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C52456B0003
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 16:12:53 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id n15-v6so14162740ioc.17
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 13:12:53 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id w187-v6si5869052itg.1.2018.07.02.13.12.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 13:12:52 -0700 (PDT)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w62K9btD065275
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 20:12:52 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2jx19snyaq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 02 Jul 2018 20:12:51 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w62KCorl016330
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 20:12:50 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w62KCnpW026531
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 20:12:49 GMT
Received: by mail-oi0-f43.google.com with SMTP id y207-v6so18730328oie.13
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 13:12:49 -0700 (PDT)
MIME-Version: 1.0
References: <20180702020417.21281-1-pasha.tatashin@oracle.com>
 <20180702020417.21281-3-pasha.tatashin@oracle.com> <552d5a9b-0ca9-cc30-d8c2-33dc1cde917f@intel.com>
 <b227cf00-a1dd-5371-aafd-9feb332e9d02@oracle.com> <38a2629d-689c-4592-9bd7-a77ab1b2045c@intel.com>
In-Reply-To: <38a2629d-689c-4592-9bd7-a77ab1b2045c@intel.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 2 Jul 2018 16:12:12 -0400
Message-ID: <CAGM2reb5KG1k1A9NRk8XZ6GyJ3AejvE0WN0CNr9WH4UvSEGLZg@mail.gmail.com>
Subject: Re: [PATCH v3 2/2] mm/sparse: start using sparse_init_nid(), and
 remove old code
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

On Mon, Jul 2, 2018 at 4:00 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 07/02/2018 12:54 PM, Pavel Tatashin wrote:
> >
> >
> > On 07/02/2018 03:47 PM, Dave Hansen wrote:
> >> On 07/01/2018 07:04 PM, Pavel Tatashin wrote:
> >>> +   for_each_present_section_nr(pnum_begin + 1, pnum_end) {
> >>> +           int nid = sparse_early_nid(__nr_to_section(pnum_end));
> >>>
> >>> +           if (nid == nid_begin) {
> >>> +                   map_count++;
> >>>                     continue;
> >>>             }
> >>
> >>> +           sparse_init_nid(nid_begin, pnum_begin, pnum_end, map_count);
> >>> +           nid_begin = nid;
> >>> +           pnum_begin = pnum_end;
> >>> +           map_count = 1;
> >>>     }
> >>
> >> Ugh, this is really hard to read.  Especially because the pnum "counter"
> >> is called "pnum_end".
> >
> > I called it pnum_end, because that is what is passed to
> > sparse_init_nid(), but I see your point, and I can rename pnum_end to
> > simply pnum if that will make things look better.
>
> Could you just make it a helper that takes a beginning pnum and returns
> the number of consecutive sections?

But sections do not have to be consequent. Some nodes may have
sections that are not present. So we are looking for two values:
map_count -> which is number of present sections and node_end for the
current node i.e. the first section of the next node. So the helper
would need to return two things, and would basically repeat the same
code that is done in this function.

>
> >> So, this is basically a loop that collects all of the adjacent sections
> >> in a given single nid and then calls sparse_init_nid().  pnum_end in
> >> this case is non-inclusive, so the sparse_init_nid() call is actually
> >> for the *previous* nid that pnum_end is pointing _past_.
> >>
> >> This *really* needs commenting.
> >
> > There is a comment before sparse_init_nid() about inclusiveness:
> >
> > 434 /*
> > 435  * Initialize sparse on a specific node. The node spans [pnum_begin, pnum_end)
> > 436  * And number of present sections in this node is map_count.
> > 437  */
> > 438 static void __init sparse_init_nid(int nid, unsigned long pnum_begin,
> > 439                                    unsigned long pnum_end,
> > 440                                    unsigned long map_count)
>
> Which I totally missed.  Could you comment the code, please?

Sure, I will add a comment into sparse_init() as well.
