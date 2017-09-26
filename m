Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7476B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 10:47:22 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u138so12035578wmu.2
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 07:47:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y11si2834489edh.411.2017.09.26.07.47.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 07:47:21 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8QEi8w5042077
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 10:47:19 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2d7q60gxca-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 10:47:19 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Tue, 26 Sep 2017 08:47:18 -0600
Date: Tue, 26 Sep 2017 09:47:10 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/device-public-memory: Enable move_pages() to stat
 device memory
References: <1506111236-28975-1-git-send-email-arbab@linux.vnet.ibm.com>
 <20170926133707.wquyw3ic5nbmfjuo@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170926133707.wquyw3ic5nbmfjuo@dhcp22.suse.cz>
Message-Id: <20170926144710.zepvnyktqjomnx2n@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Dave Jiang <dave.jiang@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>, Ingo Molnar <mingo@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, James Morse <james.morse@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 26, 2017 at 01:37:07PM +0000, Michal Hocko wrote:
>On Fri 22-09-17 15:13:56, Reza Arbab wrote:
>> The move_pages() syscall can be used to find the numa node where a page
>> currently resides. This is not working for device public memory pages,
>> which erroneously report -EFAULT (unmapped or zero page).
>>
>> Enable by adding a FOLL_DEVICE flag for follow_page(), which
>> move_pages() will use. This could be done unconditionally, but adding a
>> flag seems like a safer change.
>
>I do not understand purpose of this patch. What is the numa node of a
>device memory?

Well, using hmm_devmem_pages_create() it is added to this node:

	nid = dev_to_node(device);
	if (nid < 0)
		nid = numa_mem_id();

I understand it's minimally useful information to userspace, but the 
memory does have a nid and move_pages() is supposed to be able to return 
what that is. I ran into this using a testcase which tries to verify 
that user addresses were correctly migrated to coherent device memory.

That said, I'm okay with dropping this if you don't think it's 
worthwhile.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
