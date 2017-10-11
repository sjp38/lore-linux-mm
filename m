Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F8F56B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 01:19:11 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j64so2314964pfj.6
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 22:19:11 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id h68si9324908pgc.508.2017.10.10.22.19.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Oct 2017 22:19:09 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
In-Reply-To: <87infmz9xd.fsf@concordia.ellerman.id.au>
References: <20170918070834.13083-1-mhocko@kernel.org> <20170918070834.13083-2-mhocko@kernel.org> <87bmlfw6mj.fsf@concordia.ellerman.id.au> <20171010122726.6jrfdzkscwge6gez@dhcp22.suse.cz> <87infmz9xd.fsf@concordia.ellerman.id.au>
Date: Wed, 11 Oct 2017 16:19:05 +1100
Message-ID: <87a80yz2gm.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>

Michael Ellerman <mpe@ellerman.id.au> writes:
> Michal Hocko <mhocko@kernel.org> writes:
>> On Tue 10-10-17 23:05:08, Michael Ellerman wrote:
>>> Michal Hocko <mhocko@kernel.org> writes:
>>> > From: Michal Hocko <mhocko@suse.com>
>>> > Memory offlining can fail just too eagerly under a heavy memory pressure.
>>> >
>>> > [ 5410.336792] page:ffffea22a646bd00 count:255 mapcount:252 mapping:ffff88ff926c9f38 index:0x3
>>> > [ 5410.336809] flags: 0x9855fe40010048(uptodate|active|mappedtodisk)
>>> > [ 5410.336811] page dumped because: isolation failed
>>> > [ 5410.336813] page->mem_cgroup:ffff8801cd662000
>>> > [ 5420.655030] memory offlining [mem 0x18b580000000-0x18b5ffffffff] failed
>>> >
>>> > Isolation has failed here because the page is not on LRU. Most probably
>>> > because it was on the pcp LRU cache or it has been removed from the LRU
>>> > already but it hasn't been freed yet. In both cases the page doesn't look
>>> > non-migrable so retrying more makes sense.
>>> 
>>> This breaks offline for me.
>>> 
>>> Prior to this commit:
>>>   /sys/devices/system/memory/memory0# time echo 0 > online
>>>   -bash: echo: write error: Device or resource busy
>>>   
>>>   real	0m0.001s
>>>   user	0m0.000s
>>>   sys	0m0.001s
>>> 
>>> After:
>>>   /sys/devices/system/memory/memory0# time echo 0 > online
>>>   -bash: echo: write error: Device or resource busy
>>>   
>>>   real	2m0.009s
>>>   user	0m0.000s
>>>   sys	1m25.035s
>>> 
>>> There's no way that block can be removed, it contains the kernel text,
>>> so it should instantly fail - which it used to.
>>
>> OK, that means that start_isolate_page_range should have failed but it
>> hasn't for some reason. I strongly suspect has_unmovable_pages is doing
>> something wrong. Is the kernel text marked somehow? E.g. PageReserved?
>
> I'm not sure how the text is marked, will have to dig into that.

Yeah it's reserved:

  $ grep __init_begin /proc/kallsyms
  c000000000d70000 T __init_begin
  $ ./page-types -r -a 0x0,0xd7
               flags	page-count       MB  symbolic-flags			long-symbolic-flags
  0x0000000100000000	       215       13  __________________________r_______________	reserved
               total	       215       13


I added some printks, we're getting EBUSY from do_migrate_range(pfn, end_pfn).

So we seem to just have an infinite loop:

  repeat:
  	/* start memory hot removal */
  	ret = -EINTR;
  	if (signal_pending(current))
  		goto failed_removal;
  
  	cond_resched();
  	lru_add_drain_all_cpuslocked();
  	drain_all_pages(zone);
  
  	pfn = scan_movable_pages(start_pfn, end_pfn);
  	if (pfn) { /* We have movable pages */
  		ret = do_migrate_range(pfn, end_pfn);
  		printk_ratelimited("memory-hotplug: migrate range returned %ld\n", ret);
  		goto repeat;
  	}


eg:

  memory-hotplug: migrate range returned -16
  memory-hotplug: migrate range returned -16
  memory-hotplug: migrate range returned -16
  memory-hotplug: migrate range returned -16
  memory-hotplug: migrate range returned -16
  memory-hotplug: migrate range returned -16
  memory-hotplug: migrate range returned -16
  memory-hotplug: migrate range returned -16
  memory-hotplug: migrate range returned -16
  memory-hotplug: migrate range returned -16
  __offline_pages: 354031 callbacks suppressed
  memory-hotplug: migrate range returned -16
  memory-hotplug: migrate range returned -16
  memory-hotplug: migrate range returned -16
  memory-hotplug: migrate range returned -16
  memory-hotplug: migrate range returned -16
  memory-hotplug: migrate range returned -16
  memory-hotplug: migrate range returned -16
  memory-hotplug: migrate range returned -16
  memory-hotplug: migrate range returned -16
  memory-hotplug: migrate range returned -16
  __offline_pages: 355794 callbacks suppressed


cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
