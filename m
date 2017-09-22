Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D79D6B0038
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 17:01:25 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o3so2391235qte.7
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 14:01:25 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r34si603405qtd.515.2017.09.22.14.01.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Sep 2017 14:01:24 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8ML1C8g040926
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 17:01:23 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2d542yj3vb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 17:01:23 -0400
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Fri, 22 Sep 2017 17:01:22 -0400
Date: Fri, 22 Sep 2017 16:01:13 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/device-public-memory: Enable move_pages() to stat
 device memory
References: <1506111236-28975-1-git-send-email-arbab@linux.vnet.ibm.com>
 <20170922203157.4txavkwmvyh2ufmd@arbab-laptop.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170922203157.4txavkwmvyh2ufmd@arbab-laptop.localdomain>
Message-Id: <20170922210113.c2dn5mjis6zyted7@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Dave Jiang <dave.jiang@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>, Ingo Molnar <mingo@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, James Morse <james.morse@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 22, 2017 at 08:31:57PM +0000, Reza Arbab wrote:
>On Fri, Sep 22, 2017 at 08:13:56PM +0000, Reza Arbab wrote:
>>The move_pages() syscall can be used to find the numa node where a page
>>currently resides. This is not working for device public memory pages,
>>which erroneously report -EFAULT (unmapped or zero page).
>
>Argh. Please disregard this patch.
>
>My test setup has a chunk of system memory carved out as pretend 
>device public memory, to experiment with. Of course the real thing has 
>no numa node!

On third thought, yes it does! 

static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
{
	:
	nid = dev_to_node(device);
	if (nid < 0)
		nid = numa_mem_id();
	:
	if (devmem->pagemap.type == MEMORY_DEVICE_PUBLIC)
		ret = arch_add_memory(nid, align_start, align_size, false);
	:
}

So now I think the patch may be right after all. Please un-disregard it.  
Regard it? Whatever.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
