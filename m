Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id F3FB96B025F
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 07:45:23 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id l194so3908985qke.22
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 04:45:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p27si2873570qtb.84.2017.11.02.04.45.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 04:45:23 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vA2BjIES024783
	for <linux-mm@kvack.org>; Thu, 2 Nov 2017 07:45:21 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dyynxj9ph-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 02 Nov 2017 07:45:20 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 2 Nov 2017 11:44:55 -0000
Subject: Re: [PATCH] mm/swap: Use page flags to determine LRU list in
 __activate_page()
References: <20171019145657.11199-1-khandual@linux.vnet.ibm.com>
 <20171019153322.c4uqalws7l7fdzcx@dhcp22.suse.cz>
 <23110557-b2db-9f4a-d072-ad58fd0c1931@suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 2 Nov 2017 17:14:40 +0530
MIME-Version: 1.0
In-Reply-To: <23110557-b2db-9f4a-d072-ad58fd0c1931@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <40de21c5-9f6e-d34a-6db5-445c43a1266b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, shli@kernel.org

On 10/31/2017 06:15 PM, Vlastimil Babka wrote:
> On 10/19/2017 05:33 PM, Michal Hocko wrote:
>> On Thu 19-10-17 20:26:57, Anshuman Khandual wrote:
>>> Its already assumed that the PageActive flag is clear on the input
>>> page, hence page_lru(page) will pick the base LRU for the page. In
>>> the same way page_lru(page) will pick active base LRU, once the
>>> flag PageActive is set on the page. This change of LRU list should
>>> happen implicitly through the page flags instead of being hard
>>> coded.
>>
>> The patch description tells what but it doesn't explain _why_? Does the
>> resulting code is better, more optimized or is this a pure readability
>> thing?
>>
>> All I can see is that page_lru is more complex and a large part of it
>> can be optimized away which has been done manually here. I suspect the
>> compiler can deduce the same thing.
> 
> We shouldn't overestimate the compiler (or the objective conditions it
> has) for optimizing stuff away:
> 
> After applying the patch:
> 
> ./scripts/bloat-o-meter swap_before.o mm/swap.o
> add/remove: 0/0 grow/shrink: 1/0 up/down: 160/0 (160)
> function                                     old     new   delta
> __activate_page                              708     868    +160
> Total: Before=13538, After=13698, chg +1.18%
> 
> I don't think we want that, it's not exactly a cold code...

Yeah, makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
