Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 54BAE6B000C
	for <linux-mm@kvack.org>; Thu,  3 May 2018 18:25:55 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 88-v6so12970131wrc.21
        for <linux-mm@kvack.org>; Thu, 03 May 2018 15:25:55 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id m10-v6si607014edc.243.2018.05.03.15.25.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 15:25:53 -0700 (PDT)
Reply-To: prakash.sangappa@oracle.com
Subject: Re: [RFC PATCH] Add /proc/<pid>/numa_vamaps for numa node information
References: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com>
 <20180502143323.1c723ccb509c3497050a2e0a@linux-foundation.org>
 <2ce01d91-5fba-b1b7-2956-c8cc1853536d@intel.com>
 <33f96879-351f-674a-ca23-43f233f4eb1d@linux.vnet.ibm.com>
From: "prakash.sangappa" <prakash.sangappa@oracle.com>
Message-ID: <82d2b35c-272a-ad02-692f-2c109aacdfb6@oracle.com>
Date: Thu, 3 May 2018 15:27:57 -0700
MIME-Version: 1.0
In-Reply-To: <33f96879-351f-674a-ca23-43f233f4eb1d@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, drepper@gmail.com, rientjes@google.com, Naoya Horiguchi <nao.horiguchi@gmail.com>



On 05/03/2018 01:46 AM, Anshuman Khandual wrote:
> On 05/03/2018 03:58 AM, Dave Hansen wrote:
>> On 05/02/2018 02:33 PM, Andrew Morton wrote:
>>> On Tue,  1 May 2018 22:58:06 -0700 Prakash Sangappa <prakash.sangappa@oracle.com> wrote:
>>>> For analysis purpose it is useful to have numa node information
>>>> corresponding mapped address ranges of the process. Currently
>>>> /proc/<pid>/numa_maps provides list of numa nodes from where pages are
>>>> allocated per VMA of the process. This is not useful if an user needs to
>>>> determine which numa node the mapped pages are allocated from for a
>>>> particular address range. It would have helped if the numa node information
>>>> presented in /proc/<pid>/numa_maps was broken down by VA ranges showing the
>>>> exact numa node from where the pages have been allocated.
>> I'm finding myself a little lost in figuring out what this does.  Today,
>> numa_maps might us that a 3-page VMA has 1 page from Node 0 and 2 pages
>> from Node 1.  We group *entirely* by VMA:
>>
>> 1000-4000 N0=1 N1=2
>>
>> We don't want that.  We want to tell exactly where each node's memory is
>> despite if they are in the same VMA, like this:
>>
>> 1000-2000 N1=1
>> 2000-3000 N0=1
>> 3000-4000 N1=1
> I am kind of wondering on a big memory system how many lines of output
> we might have for a large (consuming lets say 80 % of system RAM) VMA
> in interleave policy. Is not that a problem ?
>
If each consecutive page comes from different node, yes in
the extreme case is this file will have a lot of lines. All the lines
are generated at the time file is read. The amount of data read will be
limited to the user read buffer size used in the read.

/proc/<pid>/pagemap also has kind of  similar issue. There is 1 64 bit 
value
for each user page.
