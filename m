Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 288FA8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 14:05:07 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id 188-v6so6809097ybv.9
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 11:05:07 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id b7-v6si1994484ywd.290.2018.09.14.11.05.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 11:05:05 -0700 (PDT)
Subject: Re: [PATCH V2 0/6] VA to numa node information
References: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
 <20180913084011.GC20287@dhcp22.suse.cz>
 <375951d0-f103-dec3-34d8-bbeb2f45f666@oracle.com>
 <20180914055637.GH20287@dhcp22.suse.cz>
 <91988f05-2723-3120-5607-40fabe4a170d@oracle.com>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <a26a71cb-101b-e7a2-9a2f-78995538dbca@oracle.com>
Date: Fri, 14 Sep 2018 11:04:54 -0700
MIME-Version: 1.0
In-Reply-To: <91988f05-2723-3120-5607-40fabe4a170d@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Sistare <steven.sistare@oracle.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com, nao.horiguchi@gmail.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com



On 9/14/18 9:01 AM, Steven Sistare wrote:
> On 9/14/2018 1:56 AM, Michal Hocko wrote:
>> On Thu 13-09-18 15:32:25, prakash.sangappa wrote:
>>>
>>> The proc interface provides an efficient way to export address range
>>> to numa node id mapping information compared to using the API.
>> Do you have any numbers?
>>
>>> For example, for sparsely populated mappings, if a VMA has large portions
>>> not have any physical pages mapped, the page walk done thru the /proc file
>>> interface can skip over non existent PMDs / ptes. Whereas using the
>>> API the application would have to scan the entire VMA in page size units.
>> What prevents you from pre-filtering by reading /proc/$pid/maps to get
>> ranges of interest?
> That works for skipping holes, but not for skipping huge pages.  I did a
> quick experiment to time move_pages on a 3 GHz Xeon and a 4.18 kernel.
> Allocate 128 GB and touch every small page.  Call move_pages with nodes=NULL
> to get the node id for all pages, passing 512 consecutive small pages per
> call to move_nodes. The total move_nodes time is 1.85 secs, and 55 nsec
> per page.  Extrapolating to a 1 TB range, it would take 15 sec to retrieve
> the numa node for every small page in the range.  That is not terrible, but
> it is not interactive, and it becomes terrible for multiple TB.
>

Also, for valid VMAs inA  'maps' file, if the VMA is sparsely populated 
withA  physical pages,
the page walk can skip over non existing page table entires (PMDs) and 
so can be faster.

For exampleA  reading va range of a 400GB VMA which has few pages mapped
in beginning and few pages at the end and the rest of VMA does not have 
any pages, it
takes 0.001s using the /proc interface. Whereas with move_page() api 
passing 1024
consecutive small pages address, it takes about 2.4secs. This is on a 
similar system
running 4.19 kernel.
