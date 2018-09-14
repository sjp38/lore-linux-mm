Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8617F8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 12:01:33 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id k204-v6so4637633ite.1
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 09:01:33 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id u77-v6si1341257ita.128.2018.09.14.09.01.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 09:01:31 -0700 (PDT)
Subject: Re: [PATCH V2 0/6] VA to numa node information
References: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
 <20180913084011.GC20287@dhcp22.suse.cz>
 <375951d0-f103-dec3-34d8-bbeb2f45f666@oracle.com>
 <20180914055637.GH20287@dhcp22.suse.cz>
From: Steven Sistare <steven.sistare@oracle.com>
Message-ID: <91988f05-2723-3120-5607-40fabe4a170d@oracle.com>
Date: Fri, 14 Sep 2018 12:01:18 -0400
MIME-Version: 1.0
In-Reply-To: <20180914055637.GH20287@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "prakash.sangappa" <prakash.sangappa@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com, nao.horiguchi@gmail.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com

On 9/14/2018 1:56 AM, Michal Hocko wrote:
> On Thu 13-09-18 15:32:25, prakash.sangappa wrote:
>> On 09/13/2018 01:40 AM, Michal Hocko wrote:
>>> On Wed 12-09-18 13:23:58, Prakash Sangappa wrote:
>>>> For analysis purpose it is useful to have numa node information
>>>> corresponding mapped virtual address ranges of a process. Currently,
>>>> the file /proc/<pid>/numa_maps provides list of numa nodes from where pages
>>>> are allocated per VMA of a process. This is not useful if an user needs to
>>>> determine which numa node the mapped pages are allocated from for a
>>>> particular address range. It would have helped if the numa node information
>>>> presented in /proc/<pid>/numa_maps was broken down by VA ranges showing the
>>>> exact numa node from where the pages have been allocated.
>>>>
>>>> The format of /proc/<pid>/numa_maps file content is dependent on
>>>> /proc/<pid>/maps file content as mentioned in the manpage. i.e one line
>>>> entry for every VMA corresponding to entries in /proc/<pids>/maps file.
>>>> Therefore changing the output of /proc/<pid>/numa_maps may not be possible.
>>>>
>>>> This patch set introduces the file /proc/<pid>/numa_vamaps which
>>>> will provide proper break down of VA ranges by numa node id from where the
>>>> mapped pages are allocated. For Address ranges not having any pages mapped,
>>>> a '-' is printed instead of numa node id.
>>>>
>>>> Includes support to lseek, allowing seeking to a specific process Virtual
>>>> address(VA) starting from where the address range to numa node information
>>>> can to be read from this file.
>>>>
>>>> The new file /proc/<pid>/numa_vamaps will be governed by ptrace access
>>>> mode PTRACE_MODE_READ_REALCREDS.
>>>>
>>>> See following for previous discussion about this proposal
>>>>
>>>> https://marc.info/?t=152524073400001&r=1&w=2
>>> It would be really great to give a short summary of the previous
>>> discussion. E.g. why do we need a proc interface in the first place when
>>> we already have an API to query for the information you are proposing to
>>> export [1]
>>>
>>> [1] http://lkml.kernel.org/r/20180503085741.GD4535@dhcp22.suse.cz
>>
>> The proc interface provides an efficient way to export address range
>> to numa node id mapping information compared to using the API.
> 
> Do you have any numbers?
> 
>> For example, for sparsely populated mappings, if a VMA has large portions
>> not have any physical pages mapped, the page walk done thru the /proc file
>> interface can skip over non existent PMDs / ptes. Whereas using the
>> API the application would have to scan the entire VMA in page size units.
> 
> What prevents you from pre-filtering by reading /proc/$pid/maps to get
> ranges of interest?

That works for skipping holes, but not for skipping huge pages.  I did a 
quick experiment to time move_pages on a 3 GHz Xeon and a 4.18 kernel.  
Allocate 128 GB and touch every small page.  Call move_pages with nodes=NULL 
to get the node id for all pages, passing 512 consecutive small pages per 
call to move_nodes. The total move_nodes time is 1.85 secs, and 55 nsec 
per page.  Extrapolating to a 1 TB range, it would take 15 sec to retrieve 
the numa node for every small page in the range.  That is not terrible, but 
it is not interactive, and it becomes terrible for multiple TB.

>> Also, VMAs having THP pages can have a mix of 4k pages and hugepages.
>> The page walks would be efficient in scanning and determining if it is
>> a THP huge page and step over it. Whereas using the API, the application
>> would not know what page size mapping is used for a given VA and so would
>> have to again scan the VMA in units of 4k page size.
> 
> Why does this matter for something that is for analysis purposes.
> Reading the file for the whole address space is far from a free
> operation. Is the page walk optimization really essential for usability?
> Moreover what prevents move_pages implementation to be clever for the
> page walk itself? In other words why would we want to add a new API
> rather than make the existing one faster for everybody.

One could optimize move pages.  If the caller passes a consecutive range
of small pages, and the page walk sees that a VA is mapped by a huge page, 
then it can return the same numa node for each of the following VA's that fall 
into the huge page range. It would be faster than 55 nsec per small page, but 
hard to say how much faster, and the cost is still driven by the number of 
small pages. 
 
>> If this sounds reasonable, I can add it to the commit / patch description.
> 
> This all is absolutely _essential_ for any new API proposed. Remember that
> once we add a new user interface, we have to maintain it for ever. We
> used to be too relaxed when adding new proc files in the past and it
> backfired many times already.

An offhand idea -- we could extend /proc/pid/numa_maps in a backward compatible
way by providing a control interface that is poked via write() or ioctl().
Provide one control "do-not-combine".  If do-not-combine has been set, then
the read() function returns a separate line for each range of memory mapped
on the same numa node, in the existing format.

- Steve
