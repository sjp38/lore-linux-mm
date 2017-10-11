Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 27A866B025F
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 10:05:23 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r202so2983132wmd.1
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 07:05:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 65si268353edj.513.2017.10.11.07.05.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 07:05:21 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9BDwhYI143649
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 10:05:20 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2dhhqbvkhd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 10:05:17 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 11 Oct 2017 15:05:15 +0100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v9BE5CCP24576214
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 14:05:13 GMT
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v9BE54Ej010525
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 01:05:04 +1100
Subject: Re: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
References: <20170918070834.13083-1-mhocko@kernel.org>
 <20170918070834.13083-2-mhocko@kernel.org>
 <87bmlfw6mj.fsf@concordia.ellerman.id.au>
 <20171010122726.6jrfdzkscwge6gez@dhcp22.suse.cz>
 <87infmz9xd.fsf@concordia.ellerman.id.au>
 <87a80yz2gm.fsf@concordia.ellerman.id.au>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 11 Oct 2017 19:35:04 +0530
MIME-Version: 1.0
In-Reply-To: <87a80yz2gm.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <fa9bd463-bb94-f060-bd57-2a1416a125df@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On 10/11/2017 10:49 AM, Michael Ellerman wrote:
> Michael Ellerman <mpe@ellerman.id.au> writes:
>> Michal Hocko <mhocko@kernel.org> writes:
>>> On Tue 10-10-17 23:05:08, Michael Ellerman wrote:
>>>> Michal Hocko <mhocko@kernel.org> writes:
>>>>> From: Michal Hocko <mhocko@suse.com>
>>>>> Memory offlining can fail just too eagerly under a heavy memory pressure.
>>>>>
>>>>> [ 5410.336792] page:ffffea22a646bd00 count:255 mapcount:252 mapping:ffff88ff926c9f38 index:0x3
>>>>> [ 5410.336809] flags: 0x9855fe40010048(uptodate|active|mappedtodisk)
>>>>> [ 5410.336811] page dumped because: isolation failed
>>>>> [ 5410.336813] page->mem_cgroup:ffff8801cd662000
>>>>> [ 5420.655030] memory offlining [mem 0x18b580000000-0x18b5ffffffff] failed
>>>>>
>>>>> Isolation has failed here because the page is not on LRU. Most probably
>>>>> because it was on the pcp LRU cache or it has been removed from the LRU
>>>>> already but it hasn't been freed yet. In both cases the page doesn't look
>>>>> non-migrable so retrying more makes sense.
>>>> This breaks offline for me.
>>>>
>>>> Prior to this commit:
>>>>   /sys/devices/system/memory/memory0# time echo 0 > online
>>>>   -bash: echo: write error: Device or resource busy
>>>>   
>>>>   real	0m0.001s
>>>>   user	0m0.000s
>>>>   sys	0m0.001s
>>>>
>>>> After:
>>>>   /sys/devices/system/memory/memory0# time echo 0 > online
>>>>   -bash: echo: write error: Device or resource busy
>>>>   
>>>>   real	2m0.009s
>>>>   user	0m0.000s
>>>>   sys	1m25.035s
>>>>
>>>> There's no way that block can be removed, it contains the kernel text,
>>>> so it should instantly fail - which it used to.
>>> OK, that means that start_isolate_page_range should have failed but it
>>> hasn't for some reason. I strongly suspect has_unmovable_pages is doing
>>> something wrong. Is the kernel text marked somehow? E.g. PageReserved?
>> I'm not sure how the text is marked, will have to dig into that.
> Yeah it's reserved:
> 
>   $ grep __init_begin /proc/kallsyms
>   c000000000d70000 T __init_begin
>   $ ./page-types -r -a 0x0,0xd7
>                flags	page-count       MB  symbolic-flags			long-symbolic-flags
>   0x0000000100000000	       215       13  __________________________r_______________	reserved
>                total	       215       13

Hey Michael,

What tool is this 'page-types' ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
