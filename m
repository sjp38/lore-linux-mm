Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8096B0006
	for <linux-mm@kvack.org>; Thu, 24 May 2018 08:14:19 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f21-v6so1042256wmh.5
        for <linux-mm@kvack.org>; Thu, 24 May 2018 05:14:19 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id t9-v6si11132285wri.133.2018.05.24.05.14.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 05:14:18 -0700 (PDT)
Date: Thu, 24 May 2018 13:13:52 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH 0/5] kmalloc-reclaimable caches
Message-ID: <20180524121347.GA10763@castle.DHCP.thefacebook.com>
References: <20180524110011.1940-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180524110011.1940-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Vijayanand Jitta <vjitta@codeaurora.org>

On Thu, May 24, 2018 at 01:00:06PM +0200, Vlastimil Babka wrote:
> Hi,
> 
> as discussed at LSF/MM [1] here's a RFC patchset that introduces
> kmalloc-reclaimable caches (more details in the first patch) and uses them
> for SLAB freelists and dcache external names. The latter allows us to
> repurpose the NR_INDIRECTLY_RECLAIMABLE_BYTES counter later in the series.
> 
> This is how /proc/slabinfo looks like after booting in virtme:
> 
> ...
> kmalloc-reclaimable-4194304      0      0 4194304    1 1024 : tunables    1    1    0 : slabdata      0      0      0
> ...
> kmalloc-reclaimable-96     17     64    128   32    1 : tunables  120   60    8 : slabdata      2      2      0
> kmalloc-reclaimable-64     50    128     64   64    1 : tunables  120   60    8 : slabdata      2      2      6
> kmalloc-reclaimable-32      0      0     32  124    1 : tunables  120   60    8 : slabdata      0      0      0
> kmalloc-4194304        0      0 4194304    1 1024 : tunables    1    1    0 : slabdata      0      0      0
> ...
> kmalloc-64          2888   2944     64   64    1 : tunables  120   60    8 : slabdata     46     46    454
> kmalloc-32          4325   4712     32  124    1 : tunables  120   60    8 : slabdata     38     38    563
> kmalloc-128         1178   1216    128   32    1 : tunables  120   60    8 : slabdata     38     38    114
> ...
> 
> /proc/vmstat with new/renamed nr_reclaimable counter (patch 4):
> 
> ...
> nr_slab_reclaimable 2817
> nr_slab_unreclaimable 1781
> ...
> nr_reclaimable 2817
> ...
> 
> /proc/meminfo with exposed nr_reclaimable counter (patch 5):
> 
> ...
> AnonPages:          8624 kB
> Mapped:             3340 kB
> Shmem:               564 kB
> Reclaimable:       11272 kB
> Slab:              18368 kB
> SReclaimable:      11272 kB
> SUnreclaim:         7096 kB
> KernelStack:        1168 kB
> PageTables:          448 kB
> ...
> 
> Now for the issues a.k.a. why RFC:
> 
> - I haven't find any other obvious users for reclaimable kmalloc (yet)

As I remember, ION memory allocator was discussed related to this theme:
https://lkml.org/lkml/2018/4/24/1288

> I did a superset as IIRC somebody suggested that in the older threads or at LSF.

This looks nice to me!

Thanks!
