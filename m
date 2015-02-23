Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id E9A376B0073
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 18:11:23 -0500 (EST)
Received: by pdev10 with SMTP id v10so28840147pde.7
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 15:11:23 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id cr5si11598030pdb.146.2015.02.23.15.11.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Feb 2015 15:11:22 -0800 (PST)
Received: by padhz1 with SMTP id hz1so31110101pad.9
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 15:11:22 -0800 (PST)
Date: Mon, 23 Feb 2015 14:10:39 -0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [RFC] mremap: add MREMAP_NOHOLE flag
Message-ID: <20150223221039.GA8615@kernel.org>
References: <7064772f72049de8a79383105f49b5db84a946e5.1422990665.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7064772f72049de8a79383105f49b5db84a946e5.1422990665.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, danielmicay@gmail.com, Andy Lutomirski <luto@amacapital.net>

On Tue, Feb 03, 2015 at 11:19:12AM -0800, Shaohua Li wrote:
> There was a similar patch posted before, but it doesn't get merged. I'd like
> to try again if there are more discussions.
> http://marc.info/?l=linux-mm&m=141230769431688&w=2
> 
> mremap can be used to accelerate realloc. The problem is mremap will
> punch a hole in original VMA, which makes specific memory allocator
> unable to utilize it. Jemalloc is an example. It manages memory in 4M
> chunks. mremap a range of the chunk will punch a hole, which other
> mmap() syscall can fill into. The 4M chunk is then fragmented, jemalloc
> can't handle it.
> 
> This patch adds a new flag for mremap. With it, mremap will not punch the
> hole. page tables of original vma will be zapped in the same way, but
> vma is still there. That is original vma will look like a vma without
> pagefault. Behavior of new vma isn't changed.
> 
> For private vma, accessing original vma will cause
> page fault and just like the address of the vma has never been accessed.
> So for anonymous, new page/zero page will be fault in. For file mapping,
> new page will be allocated with file reading for cow, or pagefault will
> use existing page cache.
> 
> For shared vma, original and new vma will map to the same file. We can
> optimize this without zaping original vma's page table in this case, but
> this patch doesn't do it yet.
> 
> Since with MREMAP_NOHOLE, original vma still exists. pagefault handler
> for special vma might not able to handle pagefault for mremap'd area.
> The patch doesn't allow vmas with VM_PFNMAP|VM_MIXEDMAP flags do NOHOLE
> mremap.

Any comments on this? There are real requirements on this feature.
jemalloc/tcmalloc are good examples here.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
