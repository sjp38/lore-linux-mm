Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 91AF26B0007
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 03:24:35 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g16-v6so1048637edq.10
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 00:24:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v8-v6si1706831edi.315.2018.06.27.00.24.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jun 2018 00:24:34 -0700 (PDT)
Date: Wed, 27 Jun 2018 09:24:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-ID: <20180627072432.GC32348@dhcp22.suse.cz>
References: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
 <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
 <3DDF2672-FCC4-4387-9624-92F33C309CAE@gmail.com>
 <158a4e4c-d290-77c4-a595-71332ede392b@linux.alibaba.com>
 <BFD6A249-B1D7-43D5-8D7C-9FAED4A168A1@gmail.com>
 <20180620071817.GJ13685@dhcp22.suse.cz>
 <263935d9-d07c-ab3e-9e42-89f73f57be1e@linux.alibaba.com>
 <20180626074344.GZ2458@hirez.programming.kicks-ass.net>
 <e54e298d-ef86-19a7-6f6b-07776f9a43e2@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e54e298d-ef86-19a7-6f6b-07776f9a43e2@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Nadav Amit <nadav.amit@gmail.com>, Matthew Wilcox <willy@infradead.org>, ldufour@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Tue 26-06-18 18:03:34, Yang Shi wrote:
> 
> 
> On 6/26/18 12:43 AM, Peter Zijlstra wrote:
> > On Mon, Jun 25, 2018 at 05:06:23PM -0700, Yang Shi wrote:
> > > By looking this deeper, we may not be able to cover all the unmapping range
> > > for VM_DEAD, for example, if the start addr is in the middle of a vma. We
> > > can't set VM_DEAD to that vma since that would trigger SIGSEGV for still
> > > mapped area.
> > > 
> > > splitting can't be done with read mmap_sem held, so maybe just set VM_DEAD
> > > to non-overlapped vmas. Access to overlapped vmas (first and last) will
> > > still have undefined behavior.
> > Acquire mmap_sem for writing, split, mark VM_DEAD, drop mmap_sem. Acquire
> > mmap_sem for reading, madv_free drop mmap_sem. Acquire mmap_sem for
> > writing, free everything left, drop mmap_sem.
> > 
> > ?
> > 
> > Sure, you acquire the lock 3 times, but both write instances should be
> > 'short', and I suppose you can do a demote between 1 and 2 if you care.
> 
> Thanks, Peter. Yes, by looking the code and trying two different approaches,
> it looks this approach is the most straight-forward one.

Yes, you just have to be careful about the max vma count limit.
-- 
Michal Hocko
SUSE Labs
