Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C58F6B026B
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 02:24:23 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y39so3471409wrd.17
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 23:24:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l62si530055wmb.209.2017.10.18.23.24.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 23:24:22 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9J6OKRg000812
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 02:24:21 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dpmwed1vx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 02:24:20 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 19 Oct 2017 07:24:15 +0100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v9J6OBnn27787426
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 06:24:12 GMT
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v9J6OFeL020478
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 17:24:15 +1100
Subject: Re: [PATCH] mm: mlock: remove lru_add_drain_all()
References: <20171018231730.42754-1-shakeelb@google.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 19 Oct 2017 11:54:07 +0530
MIME-Version: 1.0
In-Reply-To: <20171018231730.42754-1-shakeelb@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <edbbda21-85ad-2bbe-4e09-298133fd471b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, Ingo Molnar <mingo@kernel.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/19/2017 04:47 AM, Shakeel Butt wrote:
> Recently we have observed high latency in mlock() in our generic
> library and noticed that users have started using tmpfs files even
> without swap and the latency was due to expensive remote LRU cache
> draining.

With and without this I patch I dont see much difference in number
of instructions executed in the kernel for mlock() system call on
POWER8 platform just after reboot (all the pagevecs might not been
filled by then though). There is an improvement but its very less.

Could you share your latency numbers and how this patch is making
them better.

> 
> Is lru_add_drain_all() required by mlock()? The answer is no and the
> reason it is still in mlock() is to rapidly move mlocked pages to
> unevictable LRU. Without lru_add_drain_all() the mlocked pages which
> were on pagevec at mlock() time will be moved to evictable LRUs but
> will eventually be moved back to unevictable LRU by reclaim. So, we

Wont this affect the performance during reclaim ?

> can safely remove lru_add_drain_all() from mlock(). Also there is no
> need for local lru_add_drain() as it will be called deep inside
> __mm_populate() (in follow_page_pte()).

The following commit which originally added lru_add_drain_all()
during mlock() and mlockall() has similar explanation.

8891d6da ("mm: remove lru_add_drain_all() from the munlock path")

"In addition, this patch add lru_add_drain_all() to sys_mlock()
and sys_mlockall().  it isn't must.  but it reduce the failure
of moving to unevictable list.  its failure can rescue in
vmscan later.  but reducing is better."

Which sounds like either we have to handle the active to inactive
LRU movement during reclaim or it can be done here to speed up
reclaim later on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
