Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1678F280261
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 02:40:51 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fu14so190498629pad.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 23:40:51 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id zk10si6321455pac.45.2016.09.22.23.40.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 23:40:50 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8N6c5d8103696
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 02:40:49 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25mqb72aud-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 02:40:49 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rui.teng@linux.vnet.ibm.com>;
	Fri, 23 Sep 2016 00:40:48 -0600
Subject: Re: [PATCH v2 1/1] mm/hugetlb: fix memory offline with hugepage size
 > memory block size
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
 <20160920155354.54403-2-gerald.schaefer@de.ibm.com>
 <05d701d213d1$7fb70880$7f251980$@alibaba-inc.com>
 <20160921143534.0dd95fe7@thinkpad> <20160922095137.GC11875@dhcp22.suse.cz>
From: Rui Teng <rui.teng@linux.vnet.ibm.com>
Date: Fri, 23 Sep 2016 14:40:33 +0800
MIME-Version: 1.0
In-Reply-To: <20160922095137.GC11875@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Message-Id: <4ef25b67-13bc-57bd-f322-04310e6d6a00@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>

On 9/22/16 5:51 PM, Michal Hocko wrote:
> On Wed 21-09-16 14:35:34, Gerald Schaefer wrote:
>> dissolve_free_huge_pages() will either run into the VM_BUG_ON() or a
>> list corruption and addressing exception when trying to set a memory
>> block offline that is part (but not the first part) of a hugetlb page
>> with a size > memory block size.
>>
>> When no other smaller hugetlb page sizes are present, the VM_BUG_ON()
>> will trigger directly. In the other case we will run into an addressing
>> exception later, because dissolve_free_huge_page() will not work on the
>> head page of the compound hugetlb page which will result in a NULL
>> hstate from page_hstate().
>>
>> To fix this, first remove the VM_BUG_ON() because it is wrong, and then
>> use the compound head page in dissolve_free_huge_page().
>
> OK so dissolve_free_huge_page will work also on tail pages now which
> makes some sense. I would appreciate also few words why do we want to
> sacrifice something as precious as gigantic page rather than fail the
> page block offline. Dave pointed out dim offline usecase for example.
>
>> Also change locking in dissolve_free_huge_page(), so that it only takes
>> the lock when actually removing a hugepage.
>
> From a quick look it seems this has been broken since introduced by
> c8721bbbdd36 ("mm: memory-hotplug: enable memory hotplug to handle
> hugepage"). Do we want to have this backported to stable? In any way
> Fixes: SHA1 would be really nice.
>

If the huge page hot-plug function was introduced by c8721bbbdd36, and
it has already indicated that the gigantic page is not supported:

	"As for larger hugepages (1GB for x86_64), it's not easy to do
	hotremove over them because it's larger than memory block.  So
	we now simply leave it to fail as it is."

Is it possible that the gigantic page hot-plugin has never been
supported?

I made another patch for this problem, and also tried to apply the
first version of this patch on my system too. But they only postpone
the error happened. The HugePages_Free will be changed from 2 to 1, if I 
offline a huge page. I think it does not have a correct roll back.

# cat /proc/meminfo | grep -i huge
AnonHugePages:         0 kB
HugePages_Total:       2
HugePages_Free:        1
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:   16777216 kB

I will make more test on it, but can any one confirm that this function 
has been implemented and tested before?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
