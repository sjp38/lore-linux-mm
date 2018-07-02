Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0CDC86B0003
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 23:42:36 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c3-v6so17899749qkb.2
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 20:42:36 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q1-v6si14766174qki.179.2018.07.01.20.42.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 20:42:35 -0700 (PDT)
Date: Mon, 2 Jul 2018 11:42:21 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v3 1/2] mm/sparse: add sparse_init_nid()
Message-ID: <20180702034221.GR3223@MiWiFi-R3L-srv>
References: <20180702020417.21281-1-pasha.tatashin@oracle.com>
 <20180702020417.21281-2-pasha.tatashin@oracle.com>
 <20180702021121.GL3223@MiWiFi-R3L-srv>
 <CAGM2rebY1_-3hvp_+kqF==nLawC0FN6Q1J5X5pm5qxHdDJzjiQ@mail.gmail.com>
 <20180702023130.GM3223@MiWiFi-R3L-srv>
 <CAGM2rebUsJ2r-2F38Vv13zbaEPPgTn0w6H3j6fpg0WVa9wB6Uw@mail.gmail.com>
 <20180702025343.GN3223@MiWiFi-R3L-srv>
 <CAGM2reatQzroymAb8kaPKgd8sEehtScH9DAELeWpYCaNNnAU6w@mail.gmail.com>
 <20180702031417.GP3223@MiWiFi-R3L-srv>
 <CAGM2reYBO11oaetHr0C4KgGegh9yUNZD0x4vzDW6bz8URUowcw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reYBO11oaetHr0C4KgGegh9yUNZD0x4vzDW6bz8URUowcw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

On 07/01/18 at 11:28pm, Pavel Tatashin wrote:
> > > So, on the first failure, we even stop trying to populate other
> > > sections. No more memory to do so.
> >
> > This is the thing I worry about. In old sparse_mem_maps_populate_node()
> > you can see, when not present or failed to populate, just continue. This
> > is the main difference between yours and the old code. The key logic is
> > changed here.
> >
> 
> I do not see how  we can succeed after the first failure. We still
> allocate from the same node:
> 
> sparse_mem_map_populate() may fail only if we could not allocate large
> enough buffer vmemmap_buf_start earlier.
> 
> This means that in:
> sparse_mem_map_populate()
>   vmemmap_populate()
>     vmemmap_populate_hugepages()
>       vmemmap_alloc_block_buf() (no buffer, so call allocator)
>         vmemmap_alloc_block(size, node);
>             __earlyonly_bootmem_alloc(node, size, size, __pa(MAX_DMA_ADDRESS));
>               memblock_virt_alloc_try_nid_raw() -> Nothing changes for
> this call to succeed. So, all consequent calls to
> sparse_mem_map_populate() in this node will fail as well.

Yes, you are right, it's improvement. Thanks.

> 
> > >
> > Forgot mentioning it's the vervion in mm/sparse-vmemmap.c
> 
> Sorry, I do not understand what is vervion.

Typo, 'version', should be. Sorry for that.
