Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9375A6B0008
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 23:28:41 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id i18-v6so12299727iog.12
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 20:28:41 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id q5-v6si4539900iti.92.2018.07.01.20.28.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 20:28:40 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w623OAjI158145
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 03:28:40 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2120.oracle.com with ESMTP id 2jx1tntp6w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 02 Jul 2018 03:28:40 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w623ScQl015172
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 03:28:39 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w623Sc14025012
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 03:28:38 GMT
Received: by mail-oi0-f50.google.com with SMTP id d189-v6so5026709oib.6
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 20:28:38 -0700 (PDT)
MIME-Version: 1.0
References: <20180702020417.21281-1-pasha.tatashin@oracle.com>
 <20180702020417.21281-2-pasha.tatashin@oracle.com> <20180702021121.GL3223@MiWiFi-R3L-srv>
 <CAGM2rebY1_-3hvp_+kqF==nLawC0FN6Q1J5X5pm5qxHdDJzjiQ@mail.gmail.com>
 <20180702023130.GM3223@MiWiFi-R3L-srv> <CAGM2rebUsJ2r-2F38Vv13zbaEPPgTn0w6H3j6fpg0WVa9wB6Uw@mail.gmail.com>
 <20180702025343.GN3223@MiWiFi-R3L-srv> <CAGM2reatQzroymAb8kaPKgd8sEehtScH9DAELeWpYCaNNnAU6w@mail.gmail.com>
 <20180702031417.GP3223@MiWiFi-R3L-srv>
In-Reply-To: <20180702031417.GP3223@MiWiFi-R3L-srv>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Sun, 1 Jul 2018 23:28:01 -0400
Message-ID: <CAGM2reYBO11oaetHr0C4KgGegh9yUNZD0x4vzDW6bz8URUowcw@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] mm/sparse: add sparse_init_nid()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bhe@redhat.com
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

> > So, on the first failure, we even stop trying to populate other
> > sections. No more memory to do so.
>
> This is the thing I worry about. In old sparse_mem_maps_populate_node()
> you can see, when not present or failed to populate, just continue. This
> is the main difference between yours and the old code. The key logic is
> changed here.
>

I do not see how  we can succeed after the first failure. We still
allocate from the same node:

sparse_mem_map_populate() may fail only if we could not allocate large
enough buffer vmemmap_buf_start earlier.

This means that in:
sparse_mem_map_populate()
  vmemmap_populate()
    vmemmap_populate_hugepages()
      vmemmap_alloc_block_buf() (no buffer, so call allocator)
        vmemmap_alloc_block(size, node);
            __earlyonly_bootmem_alloc(node, size, size, __pa(MAX_DMA_ADDRESS));
              memblock_virt_alloc_try_nid_raw() -> Nothing changes for
this call to succeed. So, all consequent calls to
sparse_mem_map_populate() in this node will fail as well.

> >
> Forgot mentioning it's the vervion in mm/sparse-vmemmap.c

Sorry, I do not understand what is vervion.

Thank you,
Pavel
