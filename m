Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5C26B56E9
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 08:24:04 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id 40-v6so8309162wrb.23
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 05:24:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y33-v6sor5872727wrd.44.2018.08.31.05.24.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 Aug 2018 05:24:03 -0700 (PDT)
Date: Fri, 31 Aug 2018 14:24:01 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH] mm/page_alloc: Clean up check_for_memory
Message-ID: <20180831122401.GA2123@techadventures.net>
References: <20180828210158.4617-1-osalvador@techadventures.net>
 <332d9ea1-cdd0-6bb6-8e83-28af25096637@microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <332d9ea1-cdd0-6bb6-8e83-28af25096637@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>

On Thu, Aug 30, 2018 at 01:55:29AM +0000, Pasha Tatashin wrote:
> I would re-write the above function like this:
> static void check_for_memory(pg_data_t *pgdat, int nid)
> {
>         enum zone_type zone_type;
> 
>         for (zone_type = 0; zone_type < ZONE_MOVABLE; zone_type++) {
>                 if (populated_zone(&pgdat->node_zones[zone_type])) { 
>                         node_set_state(nid, zone_type <= ZONE_NORMAL ?
>                                        N_NORMAL_MEMORY: N_HIGH_MEMORY);
>                         break;
>                 }
>         }
> }

Hi Pavel,

the above would not work fine.
You set either N_NORMAL_MEMORY or N_HIGH_MEMORY, but a node can have both
types of memory at the same time (on CONFIG_HIGHMEM systems).

N_HIGH_MEMORY stands for regular or high memory
while N_NORMAL_MEMORY stands only for regular memory,
that is why we set it only in case the zone is <= ZONE_NORMAL.

> zone_type <= ZONE_MOVABLE - 1
> is the same as:
> zone_type < ZONE_MOVABLE

This makes sense.

-- 
Oscar Salvador
SUSE L3
