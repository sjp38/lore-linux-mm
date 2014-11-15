Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2826B00B8
	for <linux-mm@kvack.org>; Sat, 15 Nov 2014 11:32:37 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id a1so3509378wgh.7
        for <linux-mm@kvack.org>; Sat, 15 Nov 2014 08:32:36 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id az10si53805654wjb.127.2014.11.15.08.32.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 15 Nov 2014 08:32:36 -0800 (PST)
Message-ID: <54678020.9090402@suse.cz>
Date: Sat, 15 Nov 2014 17:32:32 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
References: <CABYiri-do2YdfBx=r+u1kwXkEwN4v+yeRSHB-ODXo4gMFgW-Fg@mail.gmail.com>
In-Reply-To: <CABYiri-do2YdfBx=r+u1kwXkEwN4v+yeRSHB-ODXo4gMFgW-Fg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Korolyov <andrey@xdel.ru>, "ceph-users@lists.ceph.com" <ceph-users@lists.ceph.com>
Cc: riel@redhat.com, Mark Nelson <mark.nelson@inktank.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 11/15/2014 12:48 PM, Andrey Korolyov wrote:
> Hello,
> 
> I had found recently that the OSD daemons under certain conditions
> (moderate vm pressure, moderate I/O, slightly altered vm settings) can
> go into loop involving isolate_freepages and effectively hit Ceph
> cluster performance. I found this thread

Do you feel it is a regression, compared to some older kernel version or something?

> https://lkml.org/lkml/2012/6/27/545, but looks like that the
> significant decrease of bdi max_ratio did not helped even for a bit.
> Although I have approximately a half of physical memory for cache-like
> stuff, the problem with mm persists, so I would like to try
> suggestions from the other people. In current testing iteration I had
> decreased vfs_cache_pressure to 10 and raised vm_dirty_ratio and
> background ratio to 15 and 10 correspondingly (because default values
> are too spiky for mine workloads). The host kernel is a linux-stable
> 3.10.

Well I'm glad to hear it's not 3.18-rc3 this time. But I would recommend trying
it, or at least 3.17. Lot of patches went to reduce compaction overhead for
(especially for transparent hugepages) since 3.10.

> Non-default VM settings are:
> vm.swappiness = 5
> vm.dirty_ratio=10
> vm.dirty_background_ratio=5
> bdi_max_ratio was 100%, right now 20%, at a glance it looks like the
> situation worsened, because unstable OSD host cause domino-like effect
> on other hosts, which are starting to flap too and only cache flush
> via drop_caches is helping.
> 
> Unfortunately there are no slab info from "exhausted" state due to
> sporadic nature of this bug, will try to catch next time.
> 
> slabtop (normal state):
>  Active / Total Objects (% used)    : 8675843 / 8965833 (96.8%)
>  Active / Total Slabs (% used)      : 224858 / 224858 (100.0%)
>  Active / Total Caches (% used)     : 86 / 132 (65.2%)
>  Active / Total Size (% used)       : 1152171.37K / 1253116.37K (91.9%)
>  Minimum / Average / Maximum Object : 0.01K / 0.14K / 15.75K
> 
>   OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
> 6890130 6889185  99%    0.10K 176670       39    706680K buffer_head
> 751232 721707  96%    0.06K  11738       64     46952K kmalloc-64
> 251636 226228  89%    0.55K   8987       28    143792K radix_tree_node
> 121696  45710  37%    0.25K   3803       32     30424K kmalloc-256
> 113022  80618  71%    0.19K   2691       42     21528K dentry
> 112672  35160  31%    0.50K   3521       32     56336K kmalloc-512
>  73136  72800  99%    0.07K   1306       56      5224K Acpi-ParseExt
>  61696  58644  95%    0.02K    241      256       964K kmalloc-16
>  54348  36649  67%    0.38K   1294       42     20704K ip6_dst_cache
>  53136  51787  97%    0.11K   1476       36      5904K sysfs_dir_cache
>  51200  50724  99%    0.03K    400      128      1600K kmalloc-32
>  49120  46105  93%    1.00K   1535       32     49120K xfs_inode
>  30702  30702 100%    0.04K    301      102      1204K Acpi-Namespace
>  28224  25742  91%    0.12K    882       32      3528K kmalloc-128
>  28028  22691  80%    0.18K    637       44      5096K vm_area_struct
>  28008  28008 100%    0.22K    778       36      6224K xfs_ili
>  18944  18944 100%    0.01K     37      512       148K kmalloc-8
>  16576  15154  91%    0.06K    259       64      1036K anon_vma
>  16475  14200  86%    0.16K    659       25      2636K sigqueue
> 
> zoneinfo (normal state, attached)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
