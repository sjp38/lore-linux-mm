Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id BB5468E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 18:33:16 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id i14-v6so5522087ybg.14
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 15:33:16 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id u63-v6si334601ybb.555.2018.09.13.15.33.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 15:33:15 -0700 (PDT)
Reply-To: prakash.sangappa@oracle.com
Subject: Re: [PATCH V2 0/6] VA to numa node information
References: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
 <20180913084011.GC20287@dhcp22.suse.cz>
From: "prakash.sangappa" <prakash.sangappa@oracle.com>
Message-ID: <375951d0-f103-dec3-34d8-bbeb2f45f666@oracle.com>
Date: Thu, 13 Sep 2018 15:32:25 -0700
MIME-Version: 1.0
In-Reply-To: <20180913084011.GC20287@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com, nao.horiguchi@gmail.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com, steven.sistare@oracle.com



On 09/13/2018 01:40 AM, Michal Hocko wrote:
> On Wed 12-09-18 13:23:58, Prakash Sangappa wrote:
>> For analysis purpose it is useful to have numa node information
>> corresponding mapped virtual address ranges of a process. Currently,
>> the file /proc/<pid>/numa_maps provides list of numa nodes from where pages
>> are allocated per VMA of a process. This is not useful if an user needs to
>> determine which numa node the mapped pages are allocated from for a
>> particular address range. It would have helped if the numa node information
>> presented in /proc/<pid>/numa_maps was broken down by VA ranges showing the
>> exact numa node from where the pages have been allocated.
>>
>> The format of /proc/<pid>/numa_maps file content is dependent on
>> /proc/<pid>/maps file content as mentioned in the manpage. i.e one line
>> entry for every VMA corresponding to entries in /proc/<pids>/maps file.
>> Therefore changing the output of /proc/<pid>/numa_maps may not be possible.
>>
>> This patch set introduces the file /proc/<pid>/numa_vamaps which
>> will provide proper break down of VA ranges by numa node id from where the
>> mapped pages are allocated. For Address ranges not having any pages mapped,
>> a '-' is printed instead of numa node id.
>>
>> Includes support to lseek, allowing seeking to a specific process Virtual
>> address(VA) starting from where the address range to numa node information
>> can to be read from this file.
>>
>> The new file /proc/<pid>/numa_vamaps will be governed by ptrace access
>> mode PTRACE_MODE_READ_REALCREDS.
>>
>> See following for previous discussion about this proposal
>>
>> https://marc.info/?t=152524073400001&r=1&w=2
> It would be really great to give a short summary of the previous
> discussion. E.g. why do we need a proc interface in the first place when
> we already have an API to query for the information you are proposing to
> export [1]
>
> [1] http://lkml.kernel.org/r/20180503085741.GD4535@dhcp22.suse.cz

The proc interface provides an efficient way to export address range
to numa node id mapping information compared to using the API.
For example, for sparsely populated mappings, if a VMA has large portions
not have any physical pages mapped, the page walk done thru the /proc file
interface can skip over non existent PMDs / ptes. Whereas using the
API the application would have to scan the entire VMA in page size units.

Also, VMAs having THP pages can have a mix of 4k pages and hugepages.
The page walks would be efficient in scanning and determining if it is
a THP huge page and step over it. Whereas using the API, the application
would not know what page size mapping is used for a given VA and so would
have to again scan the VMA in units of 4k page size.

If this sounds reasonable, I can add it to the commit / patch description.

-Prakash.
