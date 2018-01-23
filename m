Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E19EE800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 13:15:43 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id z37so1809319qtj.15
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 10:15:43 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y76si14644003qky.443.2018.01.23.10.15.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 10:15:42 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0NIEBWf108712
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 13:15:41 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fp8bt5615-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 13:15:40 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 23 Jan 2018 18:15:39 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/2] mm: skip HWPoisoned pages when onlining pages
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493130472-22843-3-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493172615.4828.3.camel@gmail.com>
 <20170426031255.GB11619@hori1.linux.bs1.fc.nec.co.jp>
 <20170428063048.GA9399@dhcp22.suse.cz>
 <20180117150359.655bb93d8f1d663a2cd48c33@linux-foundation.org>
Date: Tue, 23 Jan 2018 19:15:35 +0100
MIME-Version: 1.0
In-Reply-To: <20180117150359.655bb93d8f1d663a2cd48c33@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <75179fb1-eb83-15b8-b7ba-d405745e1566@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Wen Congyang <wency@cn.fujitsu.com>

Hi Andrew,

On 18/01/2018 00:03, Andrew Morton wrote:
> On Fri, 28 Apr 2017 08:30:48 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
>> On Wed 26-04-17 03:13:04, Naoya Horiguchi wrote:
>>> On Wed, Apr 26, 2017 at 12:10:15PM +1000, Balbir Singh wrote:
>>>> On Tue, 2017-04-25 at 16:27 +0200, Laurent Dufour wrote:
>>>>> The commit b023f46813cd ("memory-hotplug: skip HWPoisoned page when
>>>>> offlining pages") skip the HWPoisoned pages when offlining pages, but
>>>>> this should be skipped when onlining the pages too.
>>>>>
>>>>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>>>>> ---
>>>>>  mm/memory_hotplug.c | 4 ++++
>>>>>  1 file changed, 4 insertions(+)
>>>>>
>>>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>>>> index 6fa7208bcd56..741ddb50e7d2 100644
>>>>> --- a/mm/memory_hotplug.c
>>>>> +++ b/mm/memory_hotplug.c
>>>>> @@ -942,6 +942,10 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
>>>>>  	if (PageReserved(pfn_to_page(start_pfn)))
>>>>>  		for (i = 0; i < nr_pages; i++) {
>>>>>  			page = pfn_to_page(start_pfn + i);
>>>>> +			if (PageHWPoison(page)) {
>>>>> +				ClearPageReserved(page);
>>>>
>>>> Why do we clear page reserved? Also if the page is marked PageHWPoison, it
>>>> was never offlined to begin with? Or do you expect this to be set on newly
>>>> hotplugged memory? Also don't we need to skip the entire pageblock?
>>>
>>> If I read correctly, to "skip HWPoiosned page" in commit b023f46813cd means
>>> that we skip the page status check for hwpoisoned pages *not* to prevent
>>> memory offlining for memblocks with hwpoisoned pages. That means that
>>> hwpoisoned pages can be offlined.
>>
>> Is this patch actually correct? I am trying to wrap my head around it
>> but it smells like it tries to avoid the problem rather than fix it
>> properly. I might be wrong here of course but to me it sounds like
>> poisoned page should simply be offlined and keep its poison state all
>> the time. If the memory is hot-removed and added again we have lost the
>> struct page along with the state which is the expected behavior. If it
>> is still broken we will re-poison it.
>>
>> Anyway a patch to skip over poisoned pages during online makes perfect
>> sense to me. The PageReserved fiddling around much less so.
>>
>> Or am I missing something. Let's CC Wen Congyang for the clarification
>> here.
> 
> Wen Congyang appears to have disappeared and this fix isn't yet
> finalized.  Can we all please revisit it and have a think about
> Michal's questions?

I tried to recreate the original issue, but there were a lot of changes
done in this area since the last April.

I was not able to offline a poisoned page because isolate_movable_page() is
failing. I'll investigate that further...

Cheers,
Laurent.


> Thanks.
> 
> 
> From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> Subject: mm: skip HWPoisoned pages when onlining pages
> 
> b023f46813cd ("memory-hotplug: skip HWPoisoned page when offlining pages")
> skipped the HWPoisoned pages when offlining pages, but this should be
> skipped when onlining the pages too.
> 
> n-horiguchi@ah.jp.nec.com said:
> 
> : If I read correctly, to "skip HWPoiosned page" in commit b023f46813cd
> : means that we skip the page status check for hwpoisoned pages *not* to
> : prevent memory offlining for memblocks with hwpoisoned pages.  That
> : means that hwpoisoned pages can be offlined.
> : 
> : And another reason to clear PageReserved is that we could reuse the
> : hwpoisoned page after onlining back with replacing the broken DIMM.  In
> : this usecase, we first do unpoisoning to clear PageHWPoison, but it
> : doesn't work if PageReserved is set.  My simple testing shows the BUG
> : below in unpoisoning (without the ClearPageReserved):
> : 
> :   Unpoison: Software-unpoisoned page 0x18000
> :   BUG: Bad page state in process page-types  pfn:18000
> :   page:ffffda5440600000 count:0 mapcount:0 mapping:          (null) index:0x70006b599
> :   flags: 0x1fffc00004081a(error|uptodate|dirty|reserved|swapbacked)
> :   raw: 001fffc00004081a 0000000000000000 000000070006b599 00000000ffffffff
> :   raw: dead000000000100 dead000000000200 0000000000000000 0000000000000000
> :   page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
> :   bad because of flags: 0x800(reserved)
> 
> Link: http://lkml.kernel.org/r/1493130472-22843-3-git-send-email-ldufour@linux.vnet.ibm.com
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Andrey Vagin <avagin@openvz.org>
> Cc: Glauber Costa <glommer@openvz.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/memory_hotplug.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff -puN mm/memory_hotplug.c~mm-skip-hwpoisoned-pages-when-onlining-pages mm/memory_hotplug.c
> --- a/mm/memory_hotplug.c~mm-skip-hwpoisoned-pages-when-onlining-pages
> +++ a/mm/memory_hotplug.c
> @@ -696,6 +696,10 @@ static int online_pages_range(unsigned l
>  	if (PageReserved(pfn_to_page(start_pfn)))
>  		for (i = 0; i < nr_pages; i++) {
>  			page = pfn_to_page(start_pfn + i);
> +			if (PageHWPoison(page)) {
> +				ClearPageReserved(page);
> +				continue;
> +			}
>  			(*online_page_callback)(page);
>  			onlined_pages++;
>  		}
> _
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
