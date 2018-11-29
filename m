Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1186B5024
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 21:08:28 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id l45so378335edb.1
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 18:08:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e19sor344608edq.29.2018.11.28.18.08.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Nov 2018 18:08:26 -0800 (PST)
Date: Thu, 29 Nov 2018 02:08:25 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC PATCH] mm: update highest_memmap_pfn based on exact pfn
Message-ID: <20181129020825.3zezgscg3nilfssy@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181128083634.18515-1-richard.weiyang@gmail.com>
 <20181128150052.6c00403395ca3c9654341a94@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181128150052.6c00403395ca3c9654341a94@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, hughd@google.com, pasha.tatashin@oracle.com, mgorman@suse.de, linux-mm@kvack.org

On Wed, Nov 28, 2018 at 03:00:52PM -0800, Andrew Morton wrote:
>On Wed, 28 Nov 2018 16:36:34 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:
>
>> When DEFERRED_STRUCT_PAGE_INIT is set, page struct will not be
>> initialized all at boot up. Some of them is postponed to defer stage.
>> While the global variable highest_memmap_pfn is still set to the highest
>> pfn at boot up, even some of them are not initialized.
>> 
>> This patch adjust this behavior by update highest_memmap_pfn with the
>> exact pfn during each iteration. Since each node has a defer thread,
>> introduce a spin lock to protect it.
>> 
>
>Does this solve any known problems?  If so then I'm suspecting that
>those problems go deeper than this.

Corrently I don't see any problem.

>
>Why use a spinlock rather than an atomic_long_t?

Sorry for my shortage in knowledge. I am not sure how to compare and
change a value atomicly. cmpxchg just could compare the exact value.

>
>Perhaps this check should instead be built into pfn_valid()?

I think the original commit 22b31eec63e5 ('badpage: vm_normal_page use
print_bad_pte') introduce highest_memmap_pfn to make pfn_valid()
cheaper.

Some definition of pfn_valid() is :

#define pfn_valid(pfn)          ((pfn) < max_pfn)

Which doesn't care about the exact presented or memmap-ed page.

I am not for sure all pfn_valid() could leverage this. One thing for
sure is there are only two users of highest_memmap_pfn

   * vm_normal_page_pmd
   * _vm_normal_page

-- 
Wei Yang
Help you, Help me
