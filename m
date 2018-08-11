Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF67C6B000C
	for <linux-mm@kvack.org>; Sat, 11 Aug 2018 07:33:46 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id a9-v6so9199865wrw.20
        for <linux-mm@kvack.org>; Sat, 11 Aug 2018 04:33:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a21-v6sor852012wmg.77.2018.08.11.04.33.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 11 Aug 2018 04:33:45 -0700 (PDT)
Date: Sat, 11 Aug 2018 13:33:43 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [mmotm:master 208/394] mm/page_alloc.c:6245:26: error: expected
 '=', ',', ';', 'asm' or '__attribute__' before 'zone_init_internals'
Message-ID: <20180811113343.GA25499@techadventures.net>
References: <201808111949.cETBDEqW%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201808111949.cETBDEqW%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Oscar Salvador <osalvador@suse.de>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, Aug 11, 2018 at 07:00:52PM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   b1da01df1aa700864692a49a7007fc96cc1da7d9
> commit: e3dcfdaca81e86f21335a0b6d39162ad574c8574 [208/394] mm/page_alloc: Introduce free_area_init_core_hotplug
> config: x86_64-fedora-25 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> reproduce:
>         git checkout e3dcfdaca81e86f21335a0b6d39162ad574c8574
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> Note: the mmotm/master HEAD b1da01df1aa700864692a49a7007fc96cc1da7d9 builds fine.
>       It only hurts bisectibility.
> 
> All errors (new ones prefixed by >>):
> 
> >> mm/page_alloc.c:6245:26: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'zone_init_internals'
>     static void __paginginit zone_init_internals(struct zone *zone, enum zone_type idx, int nid,
>                              ^~~~~~~~~~~~~~~~~~~
>    mm/page_alloc.c: In function 'free_area_init_core_hotplug':
> >> mm/page_alloc.c:6272:3: error: implicit declaration of function 'zone_init_internals'; did you mean 'pgdat_init_internals'? [-Werror=implicit-function-declaration]
>       zone_init_internals(&pgdat->node_zones[z], z, nid, 0);

It looks like this linux-mmotm's tree is not testing the right version of the patch.
In V6 [1], zone_init_internals is declared as __meminit because the __paginginit macro was just dropped.

I just checked out the last version of the linux-mmotm tree, and it contains the right thing there:

<--
static void __meminit zone_init_internals(struct zone *zone, enum zone_type idx, int nid,
                                                        unsigned long remaining_pages)
{
        zone->managed_pages = remaining_pages;
        zone_set_nid(zone, nid);
        zone->name = zone_names[idx];
        zone->zone_pgdat = NODE_DATA(nid);
-->

So this error looks invalid.


[1] https://patchwork.kernel.org/patch/10552231/
-- 
Oscar Salvador
SUSE L3
