Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id AC1896B00B2
	for <linux-mm@kvack.org>; Sat, 15 Nov 2014 12:10:23 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id c9so3618671qcz.38
        for <linux-mm@kvack.org>; Sat, 15 Nov 2014 09:10:23 -0800 (PST)
Received: from mail-qc0-x229.google.com (mail-qc0-x229.google.com. [2607:f8b0:400d:c01::229])
        by mx.google.com with ESMTPS id f4si19779qgf.125.2014.11.15.09.10.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 15 Nov 2014 09:10:21 -0800 (PST)
Received: by mail-qc0-f169.google.com with SMTP id w7so1031217qcr.28
        for <linux-mm@kvack.org>; Sat, 15 Nov 2014 09:10:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54678020.9090402@suse.cz>
References: <CABYiri-do2YdfBx=r+u1kwXkEwN4v+yeRSHB-ODXo4gMFgW-Fg@mail.gmail.com>
 <54678020.9090402@suse.cz>
From: Andrey Korolyov <andrey@xdel.ru>
Date: Sat, 15 Nov 2014 21:10:00 +0400
Message-ID: <CABYiri-bT=uN9msTGinMKqUaoqhx0B6+FROdOLMTsoBWCz6vWg@mail.gmail.com>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "ceph-users@lists.ceph.com" <ceph-users@lists.ceph.com>, riel@redhat.com, Mark Nelson <mark.nelson@inktank.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Sat, Nov 15, 2014 at 7:32 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 11/15/2014 12:48 PM, Andrey Korolyov wrote:
>> Hello,
>>
>> I had found recently that the OSD daemons under certain conditions
>> (moderate vm pressure, moderate I/O, slightly altered vm settings) can
>> go into loop involving isolate_freepages and effectively hit Ceph
>> cluster performance. I found this thread
>
> Do you feel it is a regression, compared to some older kernel version or something?

No, it`s just a rare but very concerning stuff. The higher pressure
is, the more chance to hit this particular issue, although absolute
numbers are still very large (e.g. room for cache memory). Some
googling also found simular question on sf:
http://serverfault.com/questions/642883/cause-of-page-fragmentation-on-large-server-with-xfs-20-disks-and-ceph
but there are no perf info unfortunately so I cannot say if the issue
is the same or not.

>
>> https://lkml.org/lkml/2012/6/27/545, but looks like that the
>> significant decrease of bdi max_ratio did not helped even for a bit.
>> Although I have approximately a half of physical memory for cache-like
>> stuff, the problem with mm persists, so I would like to try
>> suggestions from the other people. In current testing iteration I had
>> decreased vfs_cache_pressure to 10 and raised vm_dirty_ratio and
>> background ratio to 15 and 10 correspondingly (because default values
>> are too spiky for mine workloads). The host kernel is a linux-stable
>> 3.10.
>
> Well I'm glad to hear it's not 3.18-rc3 this time. But I would recommend trying
> it, or at least 3.17. Lot of patches went to reduce compaction overhead for
> (especially for transparent hugepages) since 3.10.

Heh, I may say that I limited to pushing knobs in 3.10, because it has
a well-known set of problems and any major version switch will lead to
months-long QA procedures, but I may try that if none of mine knob
selection will help. I am not THP user, the problem is happening with
regular 4k pages and almost default VM settings. Also it worth to mean
that kernel messages are not complaining about allocation failures, as
in case in URL from above, compaction just tightens up to some limit
and (after it 'locked' system for a couple of minutes, reducing actual
I/O and derived amount of memory operations) it goes back to normal.
Cache flush fixing this just in a moment, so should large room for
min_free_kbytes. Over couple of days, depends on which nodes with
certain settings issue will reappear, I may judge if my ideas was
wrong.

>
>> Non-default VM settings are:
>> vm.swappiness = 5
>> vm.dirty_ratio=10
>> vm.dirty_background_ratio=5
>> bdi_max_ratio was 100%, right now 20%, at a glance it looks like the
>> situation worsened, because unstable OSD host cause domino-like effect
>> on other hosts, which are starting to flap too and only cache flush
>> via drop_caches is helping.
>>
>> Unfortunately there are no slab info from "exhausted" state due to
>> sporadic nature of this bug, will try to catch next time.
>>
>> slabtop (normal state):
>>  Active / Total Objects (% used)    : 8675843 / 8965833 (96.8%)
>>  Active / Total Slabs (% used)      : 224858 / 224858 (100.0%)
>>  Active / Total Caches (% used)     : 86 / 132 (65.2%)
>>  Active / Total Size (% used)       : 1152171.37K / 1253116.37K (91.9%)
>>  Minimum / Average / Maximum Object : 0.01K / 0.14K / 15.75K
>>
>>   OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
>> 6890130 6889185  99%    0.10K 176670       39    706680K buffer_head
>> 751232 721707  96%    0.06K  11738       64     46952K kmalloc-64
>> 251636 226228  89%    0.55K   8987       28    143792K radix_tree_node
>> 121696  45710  37%    0.25K   3803       32     30424K kmalloc-256
>> 113022  80618  71%    0.19K   2691       42     21528K dentry
>> 112672  35160  31%    0.50K   3521       32     56336K kmalloc-512
>>  73136  72800  99%    0.07K   1306       56      5224K Acpi-ParseExt
>>  61696  58644  95%    0.02K    241      256       964K kmalloc-16
>>  54348  36649  67%    0.38K   1294       42     20704K ip6_dst_cache
>>  53136  51787  97%    0.11K   1476       36      5904K sysfs_dir_cache
>>  51200  50724  99%    0.03K    400      128      1600K kmalloc-32
>>  49120  46105  93%    1.00K   1535       32     49120K xfs_inode
>>  30702  30702 100%    0.04K    301      102      1204K Acpi-Namespace
>>  28224  25742  91%    0.12K    882       32      3528K kmalloc-128
>>  28028  22691  80%    0.18K    637       44      5096K vm_area_struct
>>  28008  28008 100%    0.22K    778       36      6224K xfs_ili
>>  18944  18944 100%    0.01K     37      512       148K kmalloc-8
>>  16576  15154  91%    0.06K    259       64      1036K anon_vma
>>  16475  14200  86%    0.16K    659       25      2636K sigqueue
>>
>> zoneinfo (normal state, attached)
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
