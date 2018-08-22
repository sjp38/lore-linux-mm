Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9FCCC6B248C
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 09:25:36 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x20-v6so930621eda.22
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 06:25:36 -0700 (PDT)
Received: from mx1.molgen.mpg.de (mx3.molgen.mpg.de. [141.14.17.11])
        by mx.google.com with ESMTPS id f6-v6si2070049ede.175.2018.08.22.06.25.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 06:25:34 -0700 (PDT)
From: Paul Menzel <pmenzel+linux-mm@molgen.mpg.de>
Subject: Re: How to profile 160 ms spent in
 `add_highpages_with_active_regions()`?
References: <d5a65984-36a7-15d8-b04a-461d0f53d36d@molgen.mpg.de>
 <5e5a39f4-1b91-c877-1368-0946160ef4be@molgen.mpg.de>
Message-ID: <4f8d0de0-e9f1-e3cd-1f94-e95e6fa47ecf@molgen.mpg.de>
Date: Wed, 22 Aug 2018 15:25:33 +0200
MIME-Version: 1.0
In-Reply-To: <5e5a39f4-1b91-c877-1368-0946160ef4be@molgen.mpg.de>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>

Dear Linux folks,


Am 21.08.2018 um 11:37 schrieb Paul Menzel:
> [Removed non-working Pavel Tatashin <pasha.tatashin@oracle.com>]

> On 08/17/18 10:12, Paul Menzel wrote:
> 
>> With the merge of branch 'x86-timers-for-linus'
>> of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip early time
>> stamps are now printed.
>>
>>> Early TSC based time stamping to allow better boot time analysis.
>>>  A A A  This comes with a general cleanup of the TSC calibration code which
>>> grew warts and duct taping over the years and removes 250 lines of
>>> code. Initiated and mostly implemented by Pavel with help from various
>>> folks
>>
>> Looking at those early time stamps, in this case on an ASRock E350M1,
>> there is a 160 ms delay in the code below.
>>
>> Before:
>>
>> ```
>> [A A A  0.000000] Initializing CPU#0
>> [A A A  0.000000] Initializing HighMem for node 0 (000373fe:000c7d3c)
>> [A A A  0.000000] Initializing Movable for node 0 (00000000:00000000)
>> [A A A  0.000000] Memory: 3225668K/3273580K available (8898K kernel code, 747K rwdata, 2808K rodata, 768K init, 628K bss, 47912K reserved, 0K cma-reserved, 2368760K highmem)
>> ```
>>
>> After:
>>
>> ```
>> [A A A  0.063473] Initializing CPU#0
>> [A A A  0.063484] Initializing HighMem for node 0 (00036ffe:000c7d3c)
>> [A A A  0.229442] Initializing Movable for node 0 (00000000:00000000)
>> [A A A  0.236020] Memory: 3225728K/3273580K available (8966K kernel code, 750K rwdata, 2828K rodata, 776K init, 640K bss, 47852K reserved, 0K cma-reserved, 2372856K highmem)
>> ```
>>
>> The code in question is from `arch/x86/mm/highmem_32.c`.
>>
>>> void __init set_highmem_pages_init(void)
>>> {
>>>  A A A A A A A  struct zone *zone;
>>>  A A A A A A A  int nid;
>>>
>>>  A A A A A A A  /*
>>>  A A A A A A A A  * Explicitly reset zone->managed_pages because set_highmem_pages_init()
>>>  A A A A A A A A  * is invoked before free_all_bootmem()
>>>  A A A A A A A A  */
>>>  A A A A A A A  reset_all_zones_managed_pages();
>>>  A A A A A A A  for_each_zone(zone) {
>>>  A A A A A A A A A A A A A A A  unsigned long zone_start_pfn, zone_end_pfn;
>>>
>>>  A A A A A A A A A A A A A A A  if (!is_highmem(zone))
>>>  A A A A A A A A A A A A A A A A A A A A A A A  continue;
>>>
>>>  A A A A A A A A A A A A A A A  zone_start_pfn = zone->zone_start_pfn;
>>>  A A A A A A A A A A A A A A A  zone_end_pfn = zone_start_pfn + zone->spanned_pages;
>>>
>>>  A A A A A A A A A A A A A A A  nid = zone_to_nid(zone);
>>>  A A A A A A A A A A A A A A A  printk(KERN_INFO "Initializing %s for node %d (%08lx:%08lx)\n",
>>>  A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  zone->name, nid, zone_start_pfn, zone_end_pfn);
>>>
>>>  A A A A A A A A A A A A A A A  add_highpages_with_active_regions(nid, zone_start_pfn,
>>>  A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  zone_end_pfn);
>>>  A A A A A A A  }
>>> }
>>
>> And in there, it seems to be the function below.
>>
>>> void __init add_highpages_with_active_regions(int nid,
>>>  A A A A A A A A A A A A A A A A A A A A A A A A  unsigned long start_pfn, unsigned long end_pfn)
>>> {
>>>  A A A A A A A  phys_addr_t start, end;
>>>  A A A A A A A  u64 i;
>>>
>>>  A A A A A A A  for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &start, &end, NULL) {
>>>  A A A A A A A A A A A A A A A  unsigned long pfn = clamp_t(unsigned long, PFN_UP(start),
>>>  A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  start_pfn, end_pfn);
>>>  A A A A A A A A A A A A A A A  unsigned long e_pfn = clamp_t(unsigned long, PFN_DOWN(end),
>>>  A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  start_pfn, end_pfn);
>>>  A A A A A A A A A A A A A A A  for ( ; pfn < e_pfn; pfn++)
>>>  A A A A A A A A A A A A A A A A A A A A A A A  if (pfn_valid(pfn))
>>>  A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  free_highmem_page(pfn_to_page(pfn));
>>
>> Assuming the time stamps are correct, how can a profile that delay
>> without adding print statements all over the place? Using ftrace
>> doesna??t seem to work for me, probably because ita??s that early.
> 
> I added print statements, and got the result below.

[a?|]

> So, the problem is with i = 2.

Here is an even more verbose debug log.

```
[    0.055628] Initializing CPU#0
[    0.055638] Initializing HighMem for node 0 (00036ffe:000c7d3c)
[    0.055641] add_highpages_with_active_regions: start_pfn = 225278, end_pfn = 818492
[    0.055645] add_highpages_with_active_regions: for_each_free_mem_range: i = 8589934592, nid = 0, pfn = 225278, e_pfn = 225278, before for loop
[    0.055646] add_highpages_with_active_regions: after for loop
[    0.055649] add_highpages_with_active_regions: for_each_free_mem_range: i = 12884901889, nid = 0, pfn = 225278, e_pfn = 225278, before for loop
[    0.055650] add_highpages_with_active_regions: after for loop
[    0.055653] add_highpages_with_active_regions: for_each_free_mem_range: i = 17179869185, nid = 0, pfn = 225278, e_pfn = 225278, before for loop
[    0.055654] add_highpages_with_active_regions: after for loop
[    0.055656] add_highpages_with_active_regions: for_each_free_mem_range: i = 21474836481, nid = 0, pfn = 225278, e_pfn = 225278, before for loop
[    0.055658] add_highpages_with_active_regions: after for loop
[    0.055660] add_highpages_with_active_regions: for_each_free_mem_range: i = 25769803777, nid = 0, pfn = 225278, e_pfn = 225278, before for loop
[    0.055661] add_highpages_with_active_regions: after for loop
[    0.055664] add_highpages_with_active_regions: for_each_free_mem_range: i = 30064771073, nid = 0, pfn = 225278, e_pfn = 225278, before for loop
[    0.055665] add_highpages_with_active_regions: after for loop
[    0.055668] add_highpages_with_active_regions: for_each_free_mem_range: i = 34359738369, nid = 0, pfn = 225278, e_pfn = 225278, before for loop
[    0.055669] add_highpages_with_active_regions: after for loop
[    0.055671] add_highpages_with_active_regions: for_each_free_mem_range: i = 38654705665, nid = 0, pfn = 225278, e_pfn = 225278, before for loop
[    0.055672] add_highpages_with_active_regions: after for loop
[    0.055675] add_highpages_with_active_regions: for_each_free_mem_range: i = 42949672961, nid = 0, pfn = 225278, e_pfn = 225278, before for loop
[    0.055676] add_highpages_with_active_regions: after for loop
[    0.055678] add_highpages_with_active_regions: for_each_free_mem_range: i = 47244640257, nid = 0, pfn = 225278, e_pfn = 225278, before for loop
[    0.055679] add_highpages_with_active_regions: after for loop
[    0.055682] add_highpages_with_active_regions: for_each_free_mem_range: i = 51539607553, nid = 0, pfn = 225278, e_pfn = 225278, before for loop
[    0.055683] add_highpages_with_active_regions: after for loop
[    0.055685] add_highpages_with_active_regions: for_each_free_mem_range: i = 55834574849, nid = 0, pfn = 225278, e_pfn = 225278, before for loop
[    0.055686] add_highpages_with_active_regions: after for loop
[    0.055688] add_highpages_with_active_regions: for_each_free_mem_range: i = 60129542145, nid = 0, pfn = 225278, e_pfn = 225278, before for loop
[    0.055690] add_highpages_with_active_regions: after for loop
[    0.055692] add_highpages_with_active_regions: for_each_free_mem_range: i = 64424509441, nid = 0, pfn = 225278, e_pfn = 225278, before for loop
[    0.055693] add_highpages_with_active_regions: after for loop
[    0.055695] add_highpages_with_active_regions: for_each_free_mem_range: i = 68719476737, nid = 0, pfn = 225278, e_pfn = 225278, before for loop
[    0.055697] add_highpages_with_active_regions: after for loop
[    0.055699] add_highpages_with_active_regions: for_each_free_mem_range: i = 73014444033, nid = 0, pfn = 225278, e_pfn = 225278, before for loop
[    0.055700] add_highpages_with_active_regions: after for loop
[    0.055702] add_highpages_with_active_regions: for_each_free_mem_range: i = 77309411329, nid = 0, pfn = 225278, e_pfn = 225278, before for loop
[    0.055704] add_highpages_with_active_regions: after for loop
[    0.055706] add_highpages_with_active_regions: for_each_free_mem_range: i = 77309411330, nid = 0, pfn = 225278, e_pfn = 818492, before for loop
[    0.222395] add_highpages_with_active_regions: after for loop
[    0.222398] Initializing Movable for node 0 (00000000:00000000)
[    0.222401] add_highpages_with_active_regions: start_pfn = 0, end_pfn = 0
[    0.222404] add_highpages_with_active_regions: for_each_free_mem_range: i = 8589934592, nid = 0, pfn = 0, e_pfn = 0, before for loop
[    0.222405] add_highpages_with_active_regions: after for loop
[    0.222408] add_highpages_with_active_regions: for_each_free_mem_range: i = 12884901889, nid = 0, pfn = 0, e_pfn = 0, before for loop
[    0.222409] add_highpages_with_active_regions: after for loop
```

So a??freea??inga?? pfn = 225278 to e_pfn = 818492 in the for loop takes 160 ms.
Is there a way to get rid of the `pfn_valid(pfn)`?


Kind regards,

Paul
