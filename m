Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 724256B0038
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 12:19:47 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id j14so871029wre.4
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 09:19:47 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 65si1103857edj.513.2017.10.13.09.19.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Oct 2017 09:19:43 -0700 (PDT)
Subject: Re: [PATCH v8 9/9] sparc64: Add support for ADI (Application Data
 Integrity)
From: Khalid Aziz <khalid.aziz@oracle.com>
References: <cover.1506089472.git.khalid.aziz@oracle.com>
 <cover.1506089472.git.khalid.aziz@oracle.com>
 <9e3a8c90ade57d94d1ab2100c6d9508fc2d0a212.1506089472.git.khalid.aziz@oracle.com>
 <ABC0A87C-2B65-493D-8D7C-998616015FF7@oracle.com>
 <5edaf7dc-6bc7-c365-0b54-b78975c08894@oracle.com>
 <782BD060-74C5-4D9B-B013-731249A72F87@oracle.com>
 <44c3473b-a8fb-197e-7fd3-03613569f339@oracle.com>
Message-ID: <ce3a91db-0fa0-8dda-492d-2ddd281070a7@oracle.com>
Date: Fri, 13 Oct 2017 10:18:34 -0600
MIME-Version: 1.0
In-Reply-To: <44c3473b-a8fb-197e-7fd3-03613569f339@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anthony Yznaga <anthony.yznaga@oracle.com>
Cc: David Miller <davem@davemloft.net>, dave.hansen@linux.intel.com, corbet@lwn.net, Bob Picco <bob.picco@oracle.com>, STEVEN_SISTARE <steven.sistare@oracle.com>, Pasha Tatashin <pasha.tatashin@oracle.com>, Mike Kravetz <mike.kravetz@oracle.com>, Rob Gardner <rob.gardner@oracle.com>, mingo@kernel.org, Nitin Gupta <nitin.m.gupta@oracle.com>, kirill.shutemov@linux.intel.com, Tom Hromatka <tom.hromatka@oracle.com>, Eric Saint Etienne <eric.saint.etienne@oracle.com>, Allen Pais <allen.pais@oracle.com>, cmetcalf@mellanox.com, akpm@linux-foundation.org, geert@linux-m68k.org, pmladek@suse.com, tklauser@distanz.ch, Atish Patra <atish.patra@oracle.com>, Shannon Nelson <shannon.nelson@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, peterz@infradead.org, mhocko@suse.com, jack@suse.cz, lstoakes@gmail.com, punit.agrawal@arm.com, hughd@google.com, thomas.tai@oracle.com, paul.gortmaker@windriver.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, ying.huang@intel.com, zhongjiang@huawei.com, minchan@kernel.org, imbrenda@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

On 10/13/2017 08:14 AM, Khalid Aziz wrote:
> On 10/12/2017 02:27 PM, Anthony Yznaga wrote:
>>
>>> On Oct 12, 2017, at 7:44 AM, Khalid Aziz <khalid.aziz@oracle.com> wrote:
>>>
>>>
>>> On 10/06/2017 04:12 PM, Anthony Yznaga wrote:
>>>>> On Sep 25, 2017, at 9:49 AM, Khalid Aziz <khalid.aziz@oracle.com> 
>>>>> wrote:
>>>>>
>>>>> This patch extends mprotect to enable ADI (TSTATE.mcde), 
>>>>> enable/disable
>>>>> MCD (Memory Corruption Detection) on selected memory ranges, enable
>>>>> TTE.mcd in PTEs, return ADI parameters to userspace and 
>>>>> save/restore ADI
>>>>> version tags on page swap out/in or migration. ADI is not enabled by
>>>> I still don't believe migration is properly supported.A  Your
>>>> implementation is relying on a fault happening on a page while its
>>>> migration is in progress so that do_swap_page() will be called, but
>>>> I don't see how do_swap_page() will be called if a fault does not
>>>> happen until after the migration has completed.
>>>
>>> User pages are on LRU list and for the mapped pages on LRU list, 
>>> migrate_pages() ultimately calls try_to_unmap_one and makes a 
>>> migration swap entry for the page being migrated. This forces a page 
>>> fault upon access on the destination node and the page is swapped 
>>> back in from swap cache. The fault is forced by the migration swap 
>>> entry, rather than fault being an accidental event. If page fault 
>>> happens on the destination node while migration is in progress, 
>>> do_swap_page() waits until migration is done. Please take a look at 
>>> the code in __unmap_and_move().
>>
>> I looked at the code again, and I now believe ADI tags are never 
>> restored for migrated pages.A  Here's why:
>>
> 
> I will take a look at it again. I have run extensive tests migrating 
> pages of a process across multiple NUMA nodes over and over again and 
> ADI tags were never lost, so this does work. I won't rule out the 
> possibility of having missed a code path where tags are not restored and 
> I will look for it.

Anthony,

I just ran my migration test again which:

- malloc's 16 GB of memory
- Assigns a rotating ADI tag every 64 bytes to the malloc'd buffer
- Writes a pattern to the entire buffer
- Verifies the pattern it wrote using ADI tagged addresses.

While this test was running, I had a script migrate test program pages 
across two NUMA nodes every 30 seconds using migratepages command. I did 
not see an ADI tag mismatch over multiple runs of this test. This test 
shows migration is working.

Can you give me a test that shows the failure you think we should see 
and I will debug it.

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
