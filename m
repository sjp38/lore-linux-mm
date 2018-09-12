Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id EFD898E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 16:58:44 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id z20-v6so1927986iol.1
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 13:58:44 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id x2-v6si1394657jaj.22.2018.09.12.13.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 13:58:43 -0700 (PDT)
Reply-To: prakash.sangappa@oracle.com
Subject: Re: [RFC PATCH] Add /proc/<pid>/numa_vamaps for numa node information
References: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com>
 <20180502143323.1c723ccb509c3497050a2e0a@linux-foundation.org>
 <2ce01d91-5fba-b1b7-2956-c8cc1853536d@intel.com>
 <33f96879-351f-674a-ca23-43f233f4eb1d@linux.vnet.ibm.com>
 <82d2b35c-272a-ad02-692f-2c109aacdfb6@oracle.com>
 <8569dabb-4930-aa20-6249-72457e2df51e@intel.com>
 <51145ccb-fc0d-0281-9757-fb8a5112ec24@oracle.com>
 <c72fea44-59f3-b106-8311-b5eae2d254e7@intel.com>
 <addeaadc-5ab2-f0c9-2194-dd100ae90f3a@oracle.com>
 <aaca3180-7510-c008-3e12-8bbe92344ef4@intel.com>
 <94ee0b6c-4663-0705-d4a8-c50342f6b483@oracle.com>
From: "prakash.sangappa" <prakash.sangappa@oracle.com>
Message-ID: <261d2ecb-53b4-a696-2216-8bf1bfaf61b8@oracle.com>
Date: Wed, 12 Sep 2018 13:57:49 -0700
MIME-Version: 1.0
In-Reply-To: <94ee0b6c-4663-0705-d4a8-c50342f6b483@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, drepper@gmail.com, rientjes@google.com, Naoya Horiguchi <nao.horiguchi@gmail.com>, Steven Sistare <steven.sistare@oracle.com>



On 09/12/2018 01:42 PM, prakash.sangappa wrote:
>
>
> On 05/09/2018 04:31 PM, Dave Hansen wrote:
>> On 05/07/2018 06:16 PM, prakash.sangappa wrote:
>>> It will be /proc/<pid>/numa_vamaps. Yes, the behavior will be
>>> different with respect to seeking. Output will still be text and
>>> the format will be same.
>>>
>>> I want to get feedback on this approach.
>> I think it would be really great if you can write down a list of the
>> things you actually want to accomplish.  Dare I say: you need a
>> requirements list.
>>
>> The numa_vamaps approach continues down the path of an ever-growing list
>> of highly-specialized /proc/<pid> files.  I don't think that is
>> sustainable, even if it has been our trajectory for many years.
>>
>> Pagemap wasn't exactly a shining example of us getting new ABIs right,
>> but it sounds like something along those is what we need.
>
> Just sent out a V2 patch.  This patch simplifies the file content. It
> only provides VA range to numa node id information.
>
> The requirement is basically observability for performance analysis.
>
> - Need to be able to determine VA range to numa node id information.
>   Which also gives an idea of which range has memory allocated.
>
> - The proc file /proc/<pid>/numa_vamaps is in text so it is easy to
>   directly view.
>
> The V2 patch supports seeking to a particular process VA from where
> the application could read the VA to  numa node id information.
>
> Also added the 'PTRACE_MODE_READ_REALCREDS' check when opening the
> file /proc file as was indicated by Michal Hacko
>
I meant Michal Hocko
Sorry misspelled the name.


> The VA range to numa node information from this file can be used by pmap.
>
> Here is a sample from a prototype change to pmap(procps) showing
> numa node information, gathered from the new 'numa_vamaps' file.
>
> $ ./rpmap -L -A 00000000006f8000,00007f5f730fe000 31423|more
> 31423:   bash
> 00000000006f8000     16K  N1 rw--- bash
> 00000000006fc000      4K  N0 rw--- bash
> 00000000006fd000      4K  N0 rw---   [ anon ]
> 00000000006fe000      8K  N1 rw---   [ anon ]
> 0000000000700000      4K  N0 rw---   [ anon ]
> 0000000000701000      4K  N1 rw---   [ anon ]
> 0000000000702000      4K  N0 rw---   [ anon ]
> 0000000000ce8000     52K  N0 rw---   [ anon ]
> 0000000000cf5000      4K  N1 rw---   [ anon ]
> 0000000000cf6000     28K  N0 rw---   [ anon ]
> 0000000000cfd000      4K  N1 rw---   [ anon ]
> 0000000000cfe000     28K  N0 rw---   [ anon ]
> 0000000000d05000    504K  N1 rw---   [ anon ]
> 0000000000d83000      8K  N0 rw---   [ anon ]
> 0000000000d85000    932K  N1 rw---   [ anon ]
> 0000000000e6e000      4K   - rw---   [ anon ]
> 0000000000e6f000    168K  N1 rw---   [ anon ]
> 00007f5f72ef4000      4K  N2 r-x-- libnss_files-2.23.so
> 00007f5f72ef5000     40K  N0 r-x-- libnss_files-2.23.so
> 00007f5f72eff000   2044K   - ----- libnss_files-2.23.so
> 00007f5f730fe000      4K  N0 r---- libnss_files-2.23.so
>  total             3868K
>
> -Prakash.
