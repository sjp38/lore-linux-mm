Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14D338E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 18:48:14 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id w15so5252331ita.1
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 15:48:14 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id k28si8882778jaj.119.2018.12.18.15.48.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 15:48:12 -0800 (PST)
Reply-To: prakash.sangappa@oracle.com
Subject: Re: [PATCH V2 0/6] VA to numa node information
References: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
 <20180913084011.GC20287@dhcp22.suse.cz>
 <375951d0-f103-dec3-34d8-bbeb2f45f666@oracle.com>
 <20180914055637.GH20287@dhcp22.suse.cz>
 <91988f05-2723-3120-5607-40fabe4a170d@oracle.com>
 <20180924171443.GI18685@dhcp22.suse.cz>
 <41af45a9-c428-ccd8-ca10-c355d22c56a7@oracle.com>
 <79d5e991-d9f6-65e2-cb77-0f999fa512fe@oracle.com>
From: "prakash.sangappa" <prakash.sangappa@oracle.com>
Message-ID: <c81d912f-157f-749a-92fb-78f5e836da85@oracle.com>
Date: Tue, 18 Dec 2018 15:46:45 -0800
MIME-Version: 1.0
In-Reply-To: <79d5e991-d9f6-65e2-cb77-0f999fa512fe@oracle.com>
Content-Type: multipart/alternative;
 boundary="------------97E6C0B936CC8F1AC45494F0"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Sistare <steven.sistare@oracle.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com, nao.horiguchi@gmail.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com

This is a multi-part message in MIME format.
--------------97E6C0B936CC8F1AC45494F0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit



On 11/26/2018 11:20 AM, Steven Sistare wrote:
> On 11/9/2018 11:48 PM, Prakash Sangappa wrote:
>>
>> Here is some data from pmap using move_pages() API  with optimization.
>> Following table compares time pmap takes to print address mapping of a
>> large process, with numa node information using move_pages() api vs pmap
>> using /proc numa_vamaps file.
>>
>> Running pmap command on a process with 1.3 TB of address space, with
>> sparse mappings.
>>
>>                         ~1.3 TB sparse      250G dense segment with hugepages.
>> move_pages              8.33s              3.14
>> optimized move_pages    6.29s              0.92
>> /proc numa_vamaps       0.08s              0.04
>>
>>   
>> Second column is pmap time on a 250G address range of this process, which maps
>> hugepages(THP & hugetlb).
> The data look compelling to me.  numa_vmap provides a much smoother user experience
> for the analyst who is casting a wide net looking for the root of a performance issue.
> Almost no waiting to see the data.
>
> - Steve

What do others think? How to proceed on this?

Summarizing the discussion so far:

Usecase for getting VA(Virtual Address) to numa node information is
for performance analysis purpose. Investigating  performance issues
would involve looking at where a process memory is allocated from
(which numa node). For the user analyzing the issue, an efficient way
to get this information will be useful when looking at application
processes having large address space.

The patch proposed  adding /proc/<pid>/numa_vamaps file for providing
VA to Numa node id mapping information of a process. This file provides
address range to numa node id info. Address range not having any pages
mapped will be indicated with '-' for numa node id. Sample file content

00400000-00410000 N1
00410000-0047f000 N0
00480000-00481000 -
00481000-004a0000 N0
..

Dave Hansen asked how would it scale, with respect reading this file from
a large process. Answer is, the file contents are generated using page
table walk, and copied to user buffer. The mmap_sem lock is drop and
re-acquired in the process of walking the page table and copying file
content. The kernel buffer size used determines how long the lock is held.
Which can be further improved to drop the lock and re-acquire after a
fixed number(512) of pages are walked.

Also, with support for seeking to a specific VA of the process from where
the VA to numa node information will be provided, the file offset is not
taken into consideration. This behavior is different and unlike reading a
normal file. Other /proc files(Ex /proc/<pid>/pagemap) also have certain
differences compared to reading a normal file.

Michal Hocko suggested that the currently available 'move_pages' API
could be used to collect the VA to numa node id information. However,
use of numa_vamaps /proc file will be more efficient then move_pages().
Steven Sistare Suggested optimizing move_pages(), for the case when
consecutive 4k page  addresses are passed in. I tried out this optimization
and above mentioned table shows  performance comparison of
move_pages() API vs 'numa_vamaps' /proc file. Specifically, in the case of
sparse mapping the optimization to move_pages() does not help. The
performance benefits seen with the /proc file will make a difference from
an usability point of view.

Andrew Morton had asked about the performance difference between
move_pages() API and use of 'numa_vamaps' /proc file, also the usecase
for getting VA to numa node id information. Hope above description
answers the questions.








--------------97E6C0B936CC8F1AC45494F0
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <p><br>
    </p>
    <br>
    <div class="moz-cite-prefix">On 11/26/2018 11:20 AM, Steven Sistare
      wrote:<br>
    </div>
    <blockquote
      cite="mid:79d5e991-d9f6-65e2-cb77-0f999fa512fe@oracle.com"
      type="cite">
      <pre wrap="">On 11/9/2018 11:48 PM, Prakash Sangappa wrote:
</pre>
      <blockquote type="cite"><br>
        <pre wrap="">Here is some data from pmap using move_pages() API  with optimization.
Following table compares time pmap takes to print address mapping of a
large process, with numa node information using move_pages() api vs pmap
using /proc numa_vamaps file.

Running pmap command on a process with 1.3 TB of address space, with
sparse mappings.

                       ~1.3 TB sparse      250G dense segment with hugepages.
move_pages              8.33s              3.14
optimized move_pages    6.29s              0.92
/proc numa_vamaps       0.08s              0.04

 
Second column is pmap time on a 250G address range of this process, which maps
hugepages(THP &amp; hugetlb).
</pre>
      </blockquote>
      <pre wrap="">
The data look compelling to me.  numa_vmap provides a much smoother user experience
for the analyst who is casting a wide net looking for the root of a performance issue.
Almost no waiting to see the data.

- Steve
</pre>
    </blockquote>
    <br>
    What do others think? How to proceed on this?<br>
    <br>
    Summarizing the discussion so far:<br>
    <br>
    Usecase for getting VA(Virtual Address) to numa node information is
    <br>
    for performance
    analysis purpose. Investigating  performance issues<br>
    would 
    involve looking at where a process memory is allocated from<br>
    (which numa node). For the user analyzing the issue, an efficient
    way <br>
    to get this information will be useful when looking at application <br>
    processes having large address space.<br>
    <br>
    The patch proposed  adding /proc/&lt;pid&gt;/numa_vamaps file for
    providing<br>
    VA to Numa node id mapping information of a process. This file
    provides <br>
    address range to numa node id info. Address range not having any
    pages <br>
    mapped will be indicated with '-' for numa node id. Sample file
    content<br>
    <pre class="content">00400000-00410000 N1
00410000-0047f000 N0
00480000-00481000 -
00481000-004a0000 N0
..
</pre>
    Dave Hansen asked how would it scale, with respect reading this file
    from<br>
    a large process. Answer is, the file contents are generated using
    page<br>
    table walk, and copied to user buffer. The mmap_sem lock is drop and
    <br>
    re-acquired in the process of walking the page table and copying
    file <br>
    content. The kernel buffer size used determines how long the lock is
    held. <br>
    Which can be further improved to drop the lock and re-acquire after
    a <br>
    fixed number(512) of pages are walked.<br>
    <br>
    Also, with support for seeking to a specific VA of the process from
    where<br>
    the VA to numa node information will be provided, the file offset is
    not<br>
    taken into consideration. This behavior is different and unlike
    reading a<br>
    normal file. Other /proc files(Ex /proc/&lt;pid&gt;/pagemap) also
    have certain <br>
    differences compared to reading a normal file.<br>
    <br>
    Michal Hocko suggested that the currently available 'move_pages' API<br>
    could be used to collect the VA to numa node id information.
    However,<br>
    use of numa_vamaps /proc file will be more efficient then
    move_pages().<br>
    Steven Sistare Suggested optimizing move_pages(), for the case when
    <br>
    consecutive 4k page  addresses are passed in. I tried out this
    optimization <br>
    and above mentioned table shows  performance comparison of<br>
    move_pages() API vs 'numa_vamaps' /proc file. Specifically, in the
    case of <br>
    sparse mapping the optimization to move_pages() does not help. The<br>
    performance benefits seen with the /proc file will make a difference
    from <br>
    an usability point of view. <br>
    <br>
    Andrew Morton had asked about the performance difference between <br>
    move_pages() API and use of 'numa_vamaps' /proc file, also the
    usecase <br>
    for getting VA to numa node id information. Hope above description<br>
    answers the questions. <br>
    <br>
    <br>
    <br>
    <br>
    <br>
    <br>
    <br>
  </body>
</html>

--------------97E6C0B936CC8F1AC45494F0--
