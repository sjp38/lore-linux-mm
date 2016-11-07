Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 61CD26B0069
	for <linux-mm@kvack.org>; Sun,  6 Nov 2016 23:51:00 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id i88so43533018pfk.3
        for <linux-mm@kvack.org>; Sun, 06 Nov 2016 20:51:00 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id az5si15716761pab.35.2016.11.06.20.50.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Nov 2016 20:50:59 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA74mksN063720
	for <linux-mm@kvack.org>; Sun, 6 Nov 2016 23:50:58 -0500
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26jb2hetp3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 06 Nov 2016 23:50:58 -0500
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 7 Nov 2016 14:50:56 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id ECB9B2CE8054
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 15:50:53 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA74orN465536034
	for <linux-mm@kvack.org>; Mon, 7 Nov 2016 15:50:53 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA74or9v030160
	for <linux-mm@kvack.org>; Mon, 7 Nov 2016 15:50:53 +1100
Subject: Re: [RFC][PATCH] mm: merge as soon as possible when pcp alloc/free
References: <581D9103.1000202@huawei.com>
 <581DD097.5060400@linux.vnet.ibm.com> <581FDD53.20804@huawei.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 7 Nov 2016 10:20:50 +0530
MIME-Version: 1.0
In-Reply-To: <581FDD53.20804@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <5820082A.9080906@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Yisheng Xie <xieyisheng1@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/07/2016 07:18 AM, Xishi Qiu wrote:
> On 2016/11/5 20:29, Anshuman Khandual wrote:
> 
>> On 11/05/2016 01:27 PM, Xishi Qiu wrote:
>>> Usually the memory of android phones is very small, so after a long
>>> running, the fragment is very large. Kernel stack which called by
>>> alloc_thread_stack_node() usually alloc 16K memory, and it failed
>>> frequently.
>>>
>>> However we have CONFIG_VMAP_STACK now, but it do not support arm64,
>>> and maybe it has some regression because of vmalloc, it need to
>>> find an area and create page table dynamically, this will take a short
>>> time.
>>>
>>> I think we can merge as soon as possible when pcp alloc/free to reduce
>>> fragment. The pcp page is hot page, so free it will cause cache miss,
>>> I use perf to test it, but it seems the regression is not so much, maybe
>>> it need to test more. Any reply is welcome.
>>
>> The idea of PCP is to have a fast allocation mechanism which does not depend
>> on an interrupt safe spin lock for every allocation. I am not very familiar
>> with this part of code but the following documentation from Mel Gorman kind
>> of explains that the this type of fragmentation problem which you might be
>> observing as one of the limitations of PCP mechanism.
>>
>> https://www.kernel.org/doc/gorman/html/understand/understand009.html
>> "Per CPU page list" sub header.
>>
> 
> "The last potential problem is that buddies of newly freed pages could exist
> in other pagesets leading to possible fragmentation problems."
> So we should not change it, and this is a known issue, right?

Seems like that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
