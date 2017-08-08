Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1302D6B02B4
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 08:49:47 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i187so4407917wma.15
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 05:49:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 190si1157359wmb.20.2017.08.08.05.49.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Aug 2017 05:49:45 -0700 (PDT)
Date: Tue, 8 Aug 2017 14:49:42 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC v5 05/11] mm: fix lock dependency against
 mapping->i_mmap_rwsem
Message-ID: <20170808124942.GD20321@quack2.suse.cz>
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1497635555-25679-6-git-send-email-ldufour@linux.vnet.ibm.com>
 <564749a2-a729-b927-7707-1cad897c418a@linux.vnet.ibm.com>
 <78d903c4-6e9f-e049-de60-6d1ccb45ff92@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <78d903c4-6e9f-e049-de60-6d1ccb45ff92@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On Tue 08-08-17 14:20:23, Laurent Dufour wrote:
> On 08/08/2017 13:17, Anshuman Khandual wrote:
> > On 06/16/2017 11:22 PM, Laurent Dufour wrote:
> >> kworker/32:1/819 is trying to acquire lock:
> >>  (&vma->vm_sequence){+.+...}, at: [<c0000000002f20e0>]
> >> zap_page_range_single+0xd0/0x1a0
> >>
> >> but task is already holding lock:
> >>  (&mapping->i_mmap_rwsem){++++..}, at: [<c0000000002f229c>]
> >> unmap_mapping_range+0x7c/0x160
> >>
> >> which lock already depends on the new lock.
> >>
> >> the existing dependency chain (in reverse order) is:
> >>
> >> -> #2 (&mapping->i_mmap_rwsem){++++..}:
> >>        down_write+0x84/0x130
> >>        __vma_adjust+0x1f4/0xa80
> >>        __split_vma.isra.2+0x174/0x290
> >>        do_munmap+0x13c/0x4e0
> >>        vm_munmap+0x64/0xb0
> >>        elf_map+0x11c/0x130
> >>        load_elf_binary+0x6f0/0x15f0
> >>        search_binary_handler+0xe0/0x2a0
> >>        do_execveat_common.isra.14+0x7fc/0xbe0
> >>        call_usermodehelper_exec_async+0x14c/0x1d0
> >>        ret_from_kernel_thread+0x5c/0x68
> >>
> >> -> #1 (&vma->vm_sequence/1){+.+...}:
> >>        __vma_adjust+0x124/0xa80
> >>        __split_vma.isra.2+0x174/0x290
> >>        do_munmap+0x13c/0x4e0
> >>        vm_munmap+0x64/0xb0
> >>        elf_map+0x11c/0x130
> >>        load_elf_binary+0x6f0/0x15f0
> >>        search_binary_handler+0xe0/0x2a0
> >>        do_execveat_common.isra.14+0x7fc/0xbe0
> >>        call_usermodehelper_exec_async+0x14c/0x1d0
> >>        ret_from_kernel_thread+0x5c/0x68
> >>
> >> -> #0 (&vma->vm_sequence){+.+...}:
> >>        lock_acquire+0xf4/0x310
> >>        unmap_page_range+0xcc/0xfa0
> >>        zap_page_range_single+0xd0/0x1a0
> >>        unmap_mapping_range+0x138/0x160
> >>        truncate_pagecache+0x50/0xa0
> >>        put_aio_ring_file+0x48/0xb0
> >>        aio_free_ring+0x40/0x1b0
> >>        free_ioctx+0x38/0xc0
> >>        process_one_work+0x2cc/0x8a0
> >>        worker_thread+0xac/0x580
> >>        kthread+0x164/0x1b0
> >>        ret_from_kernel_thread+0x5c/0x68
> >>
> >> other info that might help us debug this:
> >>
> >> Chain exists of:
> >>   &vma->vm_sequence --> &vma->vm_sequence/1 --> &mapping->i_mmap_rwsem
> >>
> >>  Possible unsafe locking scenario:
> >>
> >>        CPU0                    CPU1
> >>        ----                    ----
> >>   lock(&mapping->i_mmap_rwsem);
> >>                                lock(&vma->vm_sequence/1);
> >>                                lock(&mapping->i_mmap_rwsem);
> >>   lock(&vma->vm_sequence);
> >>
> >>  *** DEADLOCK ***
> >>
> >> To fix that we must grab the vm_sequence lock after any mapping one in
> >> __vma_adjust().
> >>
> >> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> > 
> > Should not this be folded back into the previous patch ? It fixes an
> > issue introduced by the previous one.
> 
> This is an option, but the previous one was signed by Peter, and I'd prefer
> to keep his unchanged and add this new one to fix that.
> Again this is to ease the review.

In this particular case I disagree. We should not have buggy patches in the
series. It breaks bisectability and the ease of review is IMO very
questionable because the previous patch is simply buggy and thus is hard to
validate on its own. If the resulting combo would be too complex, you could
think of a different way how to split it up so that intermediate steps are
not buggy...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
