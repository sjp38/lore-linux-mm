Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id F15DA6B0273
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 23:14:23 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v137-v6so17725662qka.6
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 20:14:23 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b8-v6si5884424qvo.203.2018.07.01.20.14.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 20:14:23 -0700 (PDT)
Date: Mon, 2 Jul 2018 11:14:17 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v3 1/2] mm/sparse: add sparse_init_nid()
Message-ID: <20180702031417.GP3223@MiWiFi-R3L-srv>
References: <20180702020417.21281-1-pasha.tatashin@oracle.com>
 <20180702020417.21281-2-pasha.tatashin@oracle.com>
 <20180702021121.GL3223@MiWiFi-R3L-srv>
 <CAGM2rebY1_-3hvp_+kqF==nLawC0FN6Q1J5X5pm5qxHdDJzjiQ@mail.gmail.com>
 <20180702023130.GM3223@MiWiFi-R3L-srv>
 <CAGM2rebUsJ2r-2F38Vv13zbaEPPgTn0w6H3j6fpg0WVa9wB6Uw@mail.gmail.com>
 <20180702025343.GN3223@MiWiFi-R3L-srv>
 <CAGM2reatQzroymAb8kaPKgd8sEehtScH9DAELeWpYCaNNnAU6w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reatQzroymAb8kaPKgd8sEehtScH9DAELeWpYCaNNnAU6w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

On 07/01/18 at 11:03pm, Pavel Tatashin wrote:
> > Ah, yes, I misunderstood it, sorry for that.
> >
> > Then I have only one concern, for vmemmap case, if one section doesn't
> > succeed to populate its memmap, do we need to skip all the remaining
> > sections in that node?
> 
> Yes, in sparse_populate_node() we have the following:
> 
> 294         for (pnum = pnum_begin; map_index < map_count; pnum++) {
> 295                 if (!present_section_nr(pnum))
> 296                         continue;
> 297                 if (!sparse_mem_map_populate(pnum, nid, NULL))
> 298                         break;
> 
> So, on the first failure, we even stop trying to populate other
> sections. No more memory to do so.

This is the thing I worry about. In old sparse_mem_maps_populate_node()
you can see, when not present or failed to populate, just continue. This
is the main difference between yours and the old code. The key logic is
changed here.

void __init sparse_mem_maps_populate_node(struct page **map_map,
                                          unsigned long pnum_begin,
                                          unsigned long pnum_end,
                                          unsigned long map_count, int nodeid)
{
	...
	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
                struct mem_section *ms;

                if (!present_section_nr(pnum))
                        continue;

                map_map[pnum] = sparse_mem_map_populate(pnum, nodeid, NULL);
                if (map_map[pnum])                                                                                                                
                        continue;
                ms = __nr_to_section(pnum);
                pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
                       __func__);
                ms->section_mem_map = 0;
        }
	...
}
