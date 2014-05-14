Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3E2856B0036
	for <linux-mm@kvack.org>; Tue, 13 May 2014 23:25:35 -0400 (EDT)
Received: by mail-ie0-f176.google.com with SMTP id ar20so1270563iec.7
        for <linux-mm@kvack.org>; Tue, 13 May 2014 20:25:35 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id oy2si303202icc.66.2014.05.13.20.25.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 13 May 2014 20:25:33 -0700 (PDT)
Message-ID: <5372E20A.1020707@oracle.com>
Date: Tue, 13 May 2014 23:24:58 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: shmem: NULL ptr deref in shmem_fault
References: <5370DA09.7020801@oracle.com> <20140512141238.3a0673b3f1a2ee5d47498719@linux-foundation.org> <53713A01.3050502@oracle.com> <alpine.LSU.2.11.1405131442260.22181@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1405131442260.22181@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On 05/13/2014 06:20 PM, Hugh Dickins wrote:
> I haven't delved into the perf_even_mmap d_path (fs/dcache.c:2947) one,
> but the Sys_mremap one on file->f_op->f_unmapped_area sounds like what
> we have here: struct file has been freed.
> 
> I believe Al is innocent: I point a quivering finger at... Kirill.
> 
> Just guessing, but we know how fond trinity is of remap_file_pages(),
> and comparing old and new emulations shows that interesting
> 
> 	struct file *file = get_file(vma->vm_file);
>         addr = mmap_region(...);
> 	fput(file);
> 
> in mm/fremap.c's old emulation, but no get_file() and fput() around 
> the do_mmap_pgoff() in mm/mmap.c's new emulation.
> 
> Before it puts in the new, do_mmap_pgoff() might unmap the last reference
> to vma->vm_file, so emulation needs to take its own reference.  I'm not
> sure how that plays out nowadays with Al's deferred fput, but it does
> look suspicious to me.

I've tested it by reverting the remap_file_pages() patch, and the problem
seems to have disappeared.

Then, I've added it back again, wrapping the do_mmap_pgoff() call with
get_file() and fput(), and the problem is still gone.

Seems like that was the issue all along. I'll send a patch...


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
