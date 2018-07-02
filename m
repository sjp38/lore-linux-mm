Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id A534A6B026B
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 21:52:18 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id b185-v6so17680691qkg.19
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 18:52:18 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u24-v6si2438545qve.275.2018.07.01.18.52.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 18:52:17 -0700 (PDT)
Date: Mon, 2 Jul 2018 09:52:11 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v2 2/2] mm/sparse: start using sparse_init_nid(), and
 remove old code
Message-ID: <20180702015211.GK3223@MiWiFi-R3L-srv>
References: <20180630030944.9335-1-pasha.tatashin@oracle.com>
 <20180630030944.9335-3-pasha.tatashin@oracle.com>
 <20180702013918.GJ3223@MiWiFi-R3L-srv>
 <CAGM2reYRYNOe0nweMrSxLZ_RRQbu500iSRKWrbO4_CzyWTEtjQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reYRYNOe0nweMrSxLZ_RRQbu500iSRKWrbO4_CzyWTEtjQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

On 07/01/18 at 09:46pm, Pavel Tatashin wrote:
>                          ~~~
> > Here, node id passed to sparse_init_nid() should be 'nid_begin', but not
> > 'nid'. When you found out the current section's 'nid' is diferent than
> > 'nid_begin', handle node 'nid_begin', then start to next node 'nid'.
> 
> Thank you for reviewing this work. Here nid equals to nid_begin:
> 
> See, "if" at 501, and this call is at 505.

Yes, if they are equal at 501, 'continue' to for loop. If nid is not
equal to nid_begin, we execute sparse_init_nid(), here should it be that
nid_begin is the current node, nid is next node?

> 
> 492 void __init sparse_init(void)
> 493 {
> 494         unsigned long pnum_begin = first_present_section_nr();
> 495         int nid_begin = sparse_early_nid(__nr_to_section(pnum_begin));
> 496         unsigned long pnum_end, map_count = 1;
> 497
> 498         for_each_present_section_nr(pnum_begin + 1, pnum_end) {
> 499                 int nid = sparse_early_nid(__nr_to_section(pnum_end));
> 500
> 501                 if (nid == nid_begin) {
> 502                         map_count++;
> 503                         continue;
> 504                 }
> 505                 sparse_init_nid(nid, pnum_begin, pnum_end, map_count);
> 506                 nid_begin = nid;
> 507                 pnum_begin = pnum_end;
> 508                 map_count = 1;
> 509         }
> 510         sparse_init_nid(nid_begin, pnum_begin, pnum_end, map_count);
> 511         vmemmap_populate_print_last();
> 512 }
> 
> Thank you,
> Pavel
