Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 05D2C6B0262
	for <linux-mm@kvack.org>; Sat,  5 Nov 2016 08:29:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n85so28168399pfi.4
        for <linux-mm@kvack.org>; Sat, 05 Nov 2016 05:29:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r77si7807666pfb.73.2016.11.05.05.29.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Nov 2016 05:29:26 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA5CSehk125158
	for <linux-mm@kvack.org>; Sat, 5 Nov 2016 08:29:25 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26h9jswk1d-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 05 Nov 2016 08:29:24 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Sat, 5 Nov 2016 22:29:21 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 55DE12CE8056
	for <linux-mm@kvack.org>; Sat,  5 Nov 2016 23:29:18 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA5CTIuo53084238
	for <linux-mm@kvack.org>; Sat, 5 Nov 2016 23:29:18 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA5CTHIX030257
	for <linux-mm@kvack.org>; Sat, 5 Nov 2016 23:29:18 +1100
Subject: Re: [RFC][PATCH] mm: merge as soon as possible when pcp alloc/free
References: <581D9103.1000202@huawei.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Sat, 5 Nov 2016 17:59:11 +0530
MIME-Version: 1.0
In-Reply-To: <581D9103.1000202@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <581DD097.5060400@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/05/2016 01:27 PM, Xishi Qiu wrote:
> Usually the memory of android phones is very small, so after a long
> running, the fragment is very large. Kernel stack which called by
> alloc_thread_stack_node() usually alloc 16K memory, and it failed
> frequently.
> 
> However we have CONFIG_VMAP_STACK now, but it do not support arm64,
> and maybe it has some regression because of vmalloc, it need to
> find an area and create page table dynamically, this will take a short
> time.
> 
> I think we can merge as soon as possible when pcp alloc/free to reduce
> fragment. The pcp page is hot page, so free it will cause cache miss,
> I use perf to test it, but it seems the regression is not so much, maybe
> it need to test more. Any reply is welcome.

The idea of PCP is to have a fast allocation mechanism which does not depend
on an interrupt safe spin lock for every allocation. I am not very familiar
with this part of code but the following documentation from Mel Gorman kind
of explains that the this type of fragmentation problem which you might be
observing as one of the limitations of PCP mechanism.

https://www.kernel.org/doc/gorman/html/understand/understand009.html
"Per CPU page list" sub header.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
