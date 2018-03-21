Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BDCEC6B0006
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 18:15:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q65so3050284pga.15
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:15:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 1-v6si4749465plk.52.2018.03.21.15.15.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Mar 2018 15:15:05 -0700 (PDT)
Date: Wed, 21 Mar 2018 15:15:02 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 1/8] mm: mmap: unmap large mapping by section
Message-ID: <20180321221502.GA3969@bombadil.infradead.org>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
 <1521581486-99134-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180321130833.GM23100@dhcp22.suse.cz>
 <f88deb20-bcce-939f-53a6-1061c39a9f6c@linux.alibaba.com>
 <20180321172932.GE4780@bombadil.infradead.org>
 <f057a634-7e0a-1b51-eede-dcb6f128b18e@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f057a634-7e0a-1b51-eede-dcb6f128b18e@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 21, 2018 at 02:45:44PM -0700, Yang Shi wrote:
> On 3/21/18 10:29 AM, Matthew Wilcox wrote:
> > On Wed, Mar 21, 2018 at 09:31:22AM -0700, Yang Shi wrote:
> > > On 3/21/18 6:08 AM, Michal Hocko wrote:
> > > > Yes, this definitely sucks. One way to work that around is to split the
> > > > unmap to two phases. One to drop all the pages. That would only need
> > > > mmap_sem for read and then tear down the mapping with the mmap_sem for
> > > > write. This wouldn't help for parallel mmap_sem writers but those really
> > > > need a different approach (e.g. the range locking).
> > > page fault might sneak in to map a page which has been unmapped before?
> > > 
> > > range locking should help a lot on manipulating small sections of a large
> > > mapping in parallel or multiple small mappings. It may not achieve too much
> > > for single large mapping.
> > I don't think we need range locking.  What if we do munmap this way:
> > 
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
> 
> Marking vma as deleted sounds good. The problem for my current approach is
> the concurrent page fault may succeed if it access the not yet unmapped
> section. Marking deleted vma could tell page fault the vma is not valid
> anymore, then return SIGSEGV.
> 
> > does not care; munmap will need to wait for the existing munmap operation
> 
> Why mmap doesn't care? How about MAP_FIXED? It may fail unexpectedly, right?

Oh, I forgot about MAP_FIXED.  Yes, MAP_FIXED should wait for the munmap
to finish.  But a regular mmap can just pretend that it happened before
the munmap call and avoid the deleted VMAs.
