Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 97BEB6B2683
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 17:42:30 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id g5-v6so1707285pgq.5
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 14:42:30 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l1-v6si2698829pgo.377.2018.08.22.14.42.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 14:42:29 -0700 (PDT)
Subject: Re: [RFC v8 PATCH 3/5] mm: mmap: zap pages with read mmap_sem in
 munmap
References: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
 <1534358990-85530-4-git-send-email-yang.shi@linux.alibaba.com>
 <e691d054-f807-80ad-9934-a1917d8e2e77@suse.cz>
 <3c62f605-2244-6a05-2dc4-34a3f1c56300@linux.alibaba.com>
 <20180822211053.qg3dlzf6pok2x4yk@kshutemo-mobl1>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <45a5ff36-d53d-9ec3-f869-1b1b7a6de5cb@intel.com>
Date: Wed, 22 Aug 2018 14:42:27 -0700
MIME-Version: 1.0
In-Reply-To: <20180822211053.qg3dlzf6pok2x4yk@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Yang Shi <yang.shi@linux.alibaba.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/22/2018 02:10 PM, Kirill A. Shutemov wrote:
>> For x86, mpx_notify_unmap() looks finally zap the VM_MPX vmas in bound table
>> range with zap_page_range() and doesn't update vm flags, so it sounds ok to
>> me since vmas have been detached, nobody can find those vmas. But, I'm not
>> familiar with the details of mpx, maybe Kirill could help to confirm this?
> I don't see anything obviously dependent on down_write() in
> mpx_notify_unmap(), but Dave should know better.

We need mmap_sem for write in mpx_notify_unmap().

Its job is to clean up bounds tables, but bounds tables are dynamically
allocated and destroyed by the kernel.  When we destroy a table, we also
destroy the VMA for the bounds table *itself*, separate from the VMA
being unmapped.

But, this code is very likely to go away soon.  If it's causing a
problem for you, let me know and I'll see if I can get to removing it
faster.
