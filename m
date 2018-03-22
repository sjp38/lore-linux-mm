Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8FE376B000D
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 14:48:09 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id z13so873212pgu.5
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 11:48:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y3-v6si7276167plk.11.2018.03.22.11.48.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 11:48:08 -0700 (PDT)
Date: Thu, 22 Mar 2018 11:48:05 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 1/8] mm: mmap: unmap large mapping by section
Message-ID: <20180322184805.GJ28468@bombadil.infradead.org>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
 <1521581486-99134-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180321130833.GM23100@dhcp22.suse.cz>
 <f88deb20-bcce-939f-53a6-1061c39a9f6c@linux.alibaba.com>
 <20180321172932.GE4780@bombadil.infradead.org>
 <af814bbe-b6b5-12f8-72e5-7935e767bd87@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <af814bbe-b6b5-12f8-72e5-7935e767bd87@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 22, 2018 at 10:34:08AM -0700, Yang Shi wrote:
> On 3/21/18 10:29 AM, Matthew Wilcox wrote:
> > Take the mmap_sem for write
> > Find the VMA
> >    If the VMA is large(*)
> >      Mark the VMA as deleted
> >      Drop the mmap_sem
> >      zap all of the entries
> >      Take the mmap_sem
> >    Else
> >      zap all of the entries
> > Continue finding VMAs
> > Drop the mmap_sem
> > 
> > Now we need to change everywhere which looks up a VMA to see if it needs
> > to care the the VMA is deleted (page faults, eg will need to SIGBUS; mmap
> > does not care; munmap will need to wait for the existing munmap operation
> 
> The other question is why munmap need wait? If the other parallel munmap
> finds the vma has been marked as "deleted", it just need return 0 as it
> doesn't find vma.
> 
> Currently do_munmap() does the below logic:
>     vma = find_vma(mm, start);
>     if (!vma)
>         return 0;

At the point a munmap() returns, the area should be available for reuse.
If another thread is still unmapping, it won't actually be available yet.
We should wait for the other thread to finish before returning.

There may be some other corner cases; like what to do if there's a partial
unmap of a VMA, or a MAP_FIXED over part of an existing VMA.  It's going
to be safer to just wait for any conflicts to die down.  It's not like
real programs call munmap() on conflicting areas at the same time.
