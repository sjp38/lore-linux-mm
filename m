Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8656F6B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 05:15:57 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id v14-v6so4707741ybq.20
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 02:15:57 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k16si5754549qtm.54.2018.04.13.02.15.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 02:15:55 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3D9FPao033791
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 05:15:54 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2harpdb4x1-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 05:15:53 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 13 Apr 2018 10:15:51 +0100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: Re: Requesting to share current work items
References: <CADYJ94f8ObREJu7pW9zWqtTCuiT2TygjWA7n1Uv-8YC7aehDAw@mail.gmail.com>
 <20180406205828.GA9618@bombadil.infradead.org>
Date: Fri, 13 Apr 2018 14:45:46 +0530
MIME-Version: 1.0
In-Reply-To: <20180406205828.GA9618@bombadil.infradead.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <6b35abac-1939-96af-4fc9-639525eaa311@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Chandan Vn <vn.chandan@gmail.com>
Cc: linux-mm@kvack.org

On 04/07/2018 02:28 AM, Matthew Wilcox wrote:
> On Fri, Apr 06, 2018 at 07:20:47AM +0000, Chandan Vn wrote:
>> Hi,
>>
>> I would like to start contributing to linux-mm community.
>> Could you please let me know the current work items which I can start
>> working on.
>>
>> Please note that I have been working on linux-mm from past 4 years but
>> mostly proprietary or not yet mainlined vendor codebase.
> 
> We had a report of a problem a few weeks ago that I don't know if anybody
> is looking at yet.  Perhaps you'd like to try fixing it.

Do you have any reference or link to the bug report some where ?

> 
> The report says that, under some unidentified workload, calling vmalloc

Why should allocating vmap_area should depend on user space workload.
Was the workload some how causing severely fragmented vmalloc() space
making it harder for future vmalloc() requests. I am wondering.

> can take many hundreds of milliseconds, and the problem is in
> alloc_vmap_area().

Hmm, I did experiment around with a test driver on a guest with 16GB
memory. Never saw vmalloc() cost going beyond single digit milliseconds.
How many number of independent vmap_area node we are looking at in the
RB tree if we would like to hit hundreds of milliseconds in cost.

> 
> So a good plan of work would be to devise a kernel module which can
> produce a highly-fragmented vmap area, and demonstrate the problem.

I tried linear fragmentation (releasing nodes after certain distance)
and random fragmentation (releasing nodes after random distance) inside
a contiguously allocated series of vmalloc space.

> Once you've got a reliable reproducer, you can look at how to fix this
> problem.  We probably need a better data structure; either enhance
> the existing rbtree of free areas, or change the data structure.
> 

Starting node of the RB tree to search is determined with the help of
vmap_area_cache (if its applicable) followed by search in the RB tree
followed by search in the list. Wondering if in-order ascending search
inside RB tree itself will give better performance instead ? Will keep
looking into this.
