Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id F37C56B000D
	for <linux-mm@kvack.org>; Mon,  7 May 2018 19:20:06 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id h195-v6so2573491ybg.12
        for <linux-mm@kvack.org>; Mon, 07 May 2018 16:20:06 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id a62-v6si6021623ywb.642.2018.05.07.16.20.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 May 2018 16:20:05 -0700 (PDT)
Reply-To: prakash.sangappa@oracle.com
Subject: Re: [RFC PATCH] Add /proc/<pid>/numa_vamaps for numa node information
References: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com>
 <20180502143323.1c723ccb509c3497050a2e0a@linux-foundation.org>
 <2ce01d91-5fba-b1b7-2956-c8cc1853536d@intel.com>
 <33f96879-351f-674a-ca23-43f233f4eb1d@linux.vnet.ibm.com>
 <82d2b35c-272a-ad02-692f-2c109aacdfb6@oracle.com>
 <8569dabb-4930-aa20-6249-72457e2df51e@intel.com>
From: "prakash.sangappa" <prakash.sangappa@oracle.com>
Message-ID: <51145ccb-fc0d-0281-9757-fb8a5112ec24@oracle.com>
Date: Mon, 7 May 2018 16:22:15 -0700
MIME-Version: 1.0
In-Reply-To: <8569dabb-4930-aa20-6249-72457e2df51e@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, drepper@gmail.com, rientjes@google.com, Naoya Horiguchi <nao.horiguchi@gmail.com>



On 05/03/2018 03:26 PM, Dave Hansen wrote:
> On 05/03/2018 03:27 PM, prakash.sangappa wrote:
>> If each consecutive page comes from different node, yes in
>> the extreme case is this file will have a lot of lines. All the lines
>> are generated at the time file is read. The amount of data read will be
>> limited to the user read buffer size used in the read.
>>
>> /proc/<pid>/pagemap also has kind of  similar issue. There is 1 64
>> bit value for each user page.
> But nobody reads it sequentially.  Everybody lseek()s because it has a
> fixed block size.  You can't do that in text.

The current text based files  on /proc does allow seeking, but it will not
help to seek to a specific VA(vma) to start from, as the seek offset 
will be the
offset in the text. This is the case with using 'seq_file' interface in the
kernel to generate the /proc file content.

However, with the proposed new file, we could allow seeking to specified
virtual address. The lseek offset in this case would represent the 
virtual address
of the process. Subsequent read from the file would provide VA range to 
numa node
information starting from that VA. In case the VA seek'ed to is invalid, 
it will start
from the next valid mapped VA of the process. The implementation would
not be based on seq_file.

For example.
Getting numa node information for a process having the following VMAs 
mapped,
starting from '006dc000'

00400000-004dd000
006dc000-006dd000
006dd000-006e6000

Can  seek to VA 006dc000 and start reading, it would get following

006dc000-006dd000 N1=1 kernelpagesize_kB=4 anon=1 dirty=1 
file=/usr/bin/bash
006dd000-006de000 N0=1 kernelpagesize_kB=4 anon=1 dirty=1 
file=/usr/bin/bash
006de000-006e0000 N1=2 kernelpagesize_kB=4 anon=2 dirty=2 
file=/usr/bin/bash
006e0000-006e6000 N0=6 kernelpagesize_kB=4 anon=6 dirty=6 
file=/usr/bin/bash
..


One advantage with getting numa node information from this /proc file vs 
say
using 'move_pages()' API, will be that the /proc file will be able to 
provide address
range to numa node information, not one page at a time.
