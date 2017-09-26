Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id EAE216B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 14:35:33 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id u48so12109988qtc.3
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 11:35:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i51si2328290qte.371.2017.09.26.11.35.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 11:35:32 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8QIYls0043313
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 14:35:31 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2d7u30va9u-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 14:35:31 -0400
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Tue, 26 Sep 2017 14:35:30 -0400
Date: Tue, 26 Sep 2017 13:35:22 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/device-public-memory: Enable move_pages() to stat
 device memory
References: <1506111236-28975-1-git-send-email-arbab@linux.vnet.ibm.com>
 <20170926133707.wquyw3ic5nbmfjuo@dhcp22.suse.cz>
 <20170926144710.zepvnyktqjomnx2n@arbab-laptop.localdomain>
 <20170926163241.5rd4wyzrzoso4uto@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170926163241.5rd4wyzrzoso4uto@dhcp22.suse.cz>
Message-Id: <20170926183522.zeky6yfjdbuistso@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Dave Jiang <dave.jiang@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>, Ingo Molnar <mingo@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, James Morse <james.morse@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 26, 2017 at 04:32:41PM +0000, Michal Hocko wrote:
>On Tue 26-09-17 09:47:10, Reza Arbab wrote:
>> On Tue, Sep 26, 2017 at 01:37:07PM +0000, Michal Hocko wrote:
>> > On Fri 22-09-17 15:13:56, Reza Arbab wrote:
>> > > The move_pages() syscall can be used to find the numa node where a page
>> > > currently resides. This is not working for device public memory pages,
>> > > which erroneously report -EFAULT (unmapped or zero page).
>> > >
>> > > Enable by adding a FOLL_DEVICE flag for follow_page(), which
>> > > move_pages() will use. This could be done unconditionally, but adding a
>> > > flag seems like a safer change.
>> >
>> > I do not understand purpose of this patch. What is the numa node of a
>> > device memory?
>>
>> Well, using hmm_devmem_pages_create() it is added to this node:
>>
>> 	nid = dev_to_node(device);
>> 	if (nid < 0)
>> 		nid = numa_mem_id();
>
>OK, but do all the HMM devices have concept of NUMA affinity? From the
>code you are pasting they do not have to...

I don't know the definitive answer here, but as Jerome said PCIE devices 
should, and we are heading that way with NVLink/CAPI as well. It seems 
the default is just the nearest node.

>> I understand it's minimally useful information to userspace, but the memory
>> does have a nid and move_pages() is supposed to be able to return what that
>> is. I ran into this using a testcase which tries to verify that user
>> addresses were correctly migrated to coherent device memory.
>>
>> That said, I'm okay with dropping this if you don't think it's worthwhile.
>
>I am just worried that we allow information which is not generally
>sensible and I am also not sure what the userspace can actually do with
>that information.

As mentioned, it is minimally useful, e.g. for verifying migration, so 
returning the nid seems sensible to me. Alternatively, we might at least 
change the documentation to say 

-EFAULT
    This is a zero page, a device page, or the memory area is not mapped by the process.
			 ^^^^^^^^^^^^^

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
