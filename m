Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8776B0006
	for <linux-mm@kvack.org>; Wed,  2 May 2018 19:15:44 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 3-v6so7726912wry.0
        for <linux-mm@kvack.org>; Wed, 02 May 2018 16:15:44 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id f27-v6si852012edj.330.2018.05.02.16.15.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 16:15:43 -0700 (PDT)
Reply-To: prakash.sangappa@oracle.com
Subject: Re: [RFC PATCH] Add /proc/<pid>/numa_vamaps for numa node information
References: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com>
 <20180502143323.1c723ccb509c3497050a2e0a@linux-foundation.org>
 <2ce01d91-5fba-b1b7-2956-c8cc1853536d@intel.com>
From: "prakash.sangappa" <prakash.sangappa@oracle.com>
Message-ID: <5d2d820b-4a6e-242d-3927-0d693198602a@oracle.com>
Date: Wed, 2 May 2018 16:17:41 -0700
MIME-Version: 1.0
In-Reply-To: <2ce01d91-5fba-b1b7-2956-c8cc1853536d@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, drepper@gmail.com, rientjes@google.com, Naoya Horiguchi <nao.horiguchi@gmail.com>



On 05/02/2018 03:28 PM, Dave Hansen wrote:
> On 05/02/2018 02:33 PM, Andrew Morton wrote:
>> On Tue,  1 May 2018 22:58:06 -0700 Prakash Sangappa <prakash.sangappa@oracle.com> wrote:
>>> For analysis purpose it is useful to have numa node information
>>> corresponding mapped address ranges of the process. Currently
>>> /proc/<pid>/numa_maps provides list of numa nodes from where pages are
>>> allocated per VMA of the process. This is not useful if an user needs to
>>> determine which numa node the mapped pages are allocated from for a
>>> particular address range. It would have helped if the numa node information
>>> presented in /proc/<pid>/numa_maps was broken down by VA ranges showing the
>>> exact numa node from where the pages have been allocated.
> I'm finding myself a little lost in figuring out what this does.  Today,
> numa_maps might us that a 3-page VMA has 1 page from Node 0 and 2 pages
> from Node 1.  We group *entirely* by VMA:
>
> 1000-4000 N0=1 N1=2

Yes

>
> We don't want that.  We want to tell exactly where each node's memory is
> despite if they are in the same VMA, like this:
>
> 1000-2000 N1=1
> 2000-3000 N0=1
> 3000-4000 N1=1
>
> So that no line of output ever has more than one node's memory.  It

Yes, that is exactly what this patch will provide. It may not have
been clear from the sample output I had included.

Here is another snippet from a process.

..
006dc000-006dd000 N1=1 kernelpagesize_kB=4 anon=1 dirty=1 file=/usr/bin/bash
006dd000-006de000 N0=1 kernelpagesize_kB=4 anon=1 dirty=1 file=/usr/bin/bash
006de000-006e0000 N1=2 kernelpagesize_kB=4 anon=2 dirty=2 file=/usr/bin/bash
006e0000-006e6000 N0=6 kernelpagesize_kB=4 anon=6 dirty=6 file=/usr/bin/bash
006e6000-006eb000 N0=5 kernelpagesize_kB=4 anon=5 dirty=5
006eb000-006ec000 N1=1 kernelpagesize_kB=4 anon=1 dirty=1
007f9000-007fa000 N1=1 kernelpagesize_kB=4 anon=1 dirty=1 heap
007fa000-00965000 N0=363 kernelpagesize_kB=4 anon=363 dirty=363 heap
00965000-0096c000 -  heap
0096c000-0096d000 N0=1 kernelpagesize_kB=4 anon=1 dirty=1 heap
0096d000-00984000 -  heap
..

> *appears* in this new file as if each contiguous range of memory from a
> given node has its own VMA.  Right?

No. It just breaks down each VMA of the process into address ranges
which have pages on a numa node on each line. i.e Each line will
indicate memory from one numa node only.

>
> This sounds interesting, but I've never found myself wanting this
> information a single time that I can recall.  I'd love to hear more.
>
> Is this for debugging?  Are apps actually going to *parse* this file?

Yes, mainly for debugging/performance analysis . User analyzing can look
at this file. Oracle Database team will be using this information.

>
> How hard did you try to share code with numa_maps?  Are you sure we
> can't just replace numa_maps?  VMAs are a kernel-internal thing and we
> never promised to represent them 1:1 in our ABI.

I was inclined to just modify numa_maps. However the man page
documents numa_maps format to correlate with 'maps' file.
Wondering if apps/scripts will break if we change the output
of 'numa_maps'.  So decided to add a new file instead.

I could try to share the code with numa_maps.

>
> Are we going to continue creating new files in /proc every time a tiny
> new niche pops up? :)

Wish we could just enhance the existing files.
