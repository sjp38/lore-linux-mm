Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B9E06B434C
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 14:20:27 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id q8so4377947edd.8
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 11:20:27 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id y1-v6si718766ejh.51.2018.11.26.11.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 11:20:25 -0800 (PST)
Subject: Re: [PATCH V2 0/6] VA to numa node information
References: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
 <20180913084011.GC20287@dhcp22.suse.cz>
 <375951d0-f103-dec3-34d8-bbeb2f45f666@oracle.com>
 <20180914055637.GH20287@dhcp22.suse.cz>
 <91988f05-2723-3120-5607-40fabe4a170d@oracle.com>
 <20180924171443.GI18685@dhcp22.suse.cz>
 <41af45a9-c428-ccd8-ca10-c355d22c56a7@oracle.com>
From: Steven Sistare <steven.sistare@oracle.com>
Message-ID: <79d5e991-d9f6-65e2-cb77-0f999fa512fe@oracle.com>
Date: Mon, 26 Nov 2018 14:20:10 -0500
MIME-Version: 1.0
In-Reply-To: <41af45a9-c428-ccd8-ca10-c355d22c56a7@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com, nao.horiguchi@gmail.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com

On 11/9/2018 11:48 PM, Prakash Sangappa wrote:
> On 9/24/18 10:14 AM, Michal Hocko wrote:
>> On Fri 14-09-18 12:01:18, Steven Sistare wrote:
>>> On 9/14/2018 1:56 AM, Michal Hocko wrote:
>> [...]
>>>> Why does this matter for something that is for analysis purposes.
>>>> Reading the file for the whole address space is far from a free
>>>> operation. Is the page walk optimization really essential for usability?
>>>> Moreover what prevents move_pages implementation to be clever for the
>>>> page walk itself? In other words why would we want to add a new API
>>>> rather than make the existing one faster for everybody.
>>> One could optimize move pages.  If the caller passes a consecutive range
>>> of small pages, and the page walk sees that a VA is mapped by a huge page,
>>> then it can return the same numa node for each of the following VA's that fall
>>> into the huge page range. It would be faster than 55 nsec per small page, but
>>> hard to say how much faster, and the cost is still driven by the number of
>>> small pages.
>> This is exactly what I was arguing for. There is some room for
>> improvements for the existing interface. I yet have to hear the explicit
>> usecase which would required even better performance that cannot be
>> achieved by the existing API.
>>
> 
> Above mentioned optimization to move_pages() API helps when scanning
> mapped huge pages, but does not help if there are large sparse mappings
> with few pages mapped. Otherwise, consider adding page walk support in
> the move_pages() implementation, enhance the API(new flag?) to return
> address range to numa node information. The page walk optimization
> would certainly make a difference for usability.
> 
> We can have applications(Like Oracle DB) having processes with large sparse
> mappings(in TBs)  with only some areas of these mapped address range
> being accessed, basically  large portions not having page tables backing it.
> This can become more prevalent on newer systems with multiple TBs of
> memory.
> 
> Here is some data from pmap using move_pages() API  with optimization.
> Following table compares time pmap takes to print address mapping of a
> large process, with numa node information using move_pages() api vs pmap
> using /proc numa_vamaps file.
> 
> Running pmap command on a process with 1.3 TB of address space, with
> sparse mappings.
> 
>                        ~1.3 TB sparse      250G dense segment with hugepages.
> move_pages              8.33s              3.14
> optimized move_pages    6.29s              0.92
> /proc numa_vamaps       0.08s              0.04
> 
>  
> Second column is pmap time on a 250G address range of this process, which maps
> hugepages(THP & hugetlb).

The data look compelling to me.  numa_vmap provides a much smoother user experience
for the analyst who is casting a wide net looking for the root of a performance issue.
Almost no waiting to see the data.

- Steve
