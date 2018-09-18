Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D722D8E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 06:38:06 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d40-v6so845921pla.14
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 03:38:06 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b19-v6si19288586pfb.89.2018.09.18.03.38.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Sep 2018 03:38:05 -0700 (PDT)
Date: Tue, 18 Sep 2018 03:37:57 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC v10 PATCH 0/3] mm: zap pages with read mmap_sem in munmap
 for large mapping
Message-ID: <20180918103757.GA17108@bombadil.infradead.org>
References: <1536957299-43536-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180915101042.GD31572@bombadil.infradead.org>
 <d00aea15-cf08-1980-dcdf-bf24334e6848@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d00aea15-cf08-1980-dcdf-bf24334e6848@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, kirill@shutemov.name, akpm@linux-foundation.org, dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 17, 2018 at 01:00:58PM -0700, Yang Shi wrote:
> On 9/15/18 3:10 AM, Matthew Wilcox wrote:
> > Something I've been wondering about for a while is whether we should "sort"
> > the readers together.  ie if the acquirers look like this:
> > 
> > A write
> > B read
> > C read
> > D write
> > E read
> > F read
> > G write
> > 
> > then we should grant the lock to A, BCEF, D, G rather than A, BC, D, EF, G.
> 
> I'm not sure how much this can help to the real world workload.
> 
> Typically, there are multi threads to contend for one mmap_sem. So, they are
> trying to read/write the same address space. There might be dependency or
> synchronization among them. Sorting read together might break the
> dependency?

I don't think that's true for the mmap_sem.  If one thread is trying to
get the sem for read then it's a page fault.  Another thread trying to
get the sem for write is trying to modify the address space.  If an
application depends on the ordering of an mmap vs a page fault, it has
to have its own synchronisation.
