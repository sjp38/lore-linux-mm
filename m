Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 554256B0010
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 07:34:53 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c2-v6so972717edi.20
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 04:34:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p63-v6si3592051edp.313.2018.06.29.04.34.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 04:34:49 -0700 (PDT)
Date: Fri, 29 Jun 2018 13:34:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-ID: <20180629113447.GA5963@dhcp22.suse.cz>
References: <158a4e4c-d290-77c4-a595-71332ede392b@linux.alibaba.com>
 <BFD6A249-B1D7-43D5-8D7C-9FAED4A168A1@gmail.com>
 <20180620071817.GJ13685@dhcp22.suse.cz>
 <263935d9-d07c-ab3e-9e42-89f73f57be1e@linux.alibaba.com>
 <20180626074344.GZ2458@hirez.programming.kicks-ass.net>
 <e54e298d-ef86-19a7-6f6b-07776f9a43e2@linux.alibaba.com>
 <20180627072432.GC32348@dhcp22.suse.cz>
 <a52f0585-ebec-d098-2775-f55bde3519a4@linux.alibaba.com>
 <20180628115101.GE32348@dhcp22.suse.cz>
 <2ecdb667-f4de-673d-6a5f-ee50df505d0c@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2ecdb667-f4de-673d-6a5f-ee50df505d0c@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Nadav Amit <nadav.amit@gmail.com>, Matthew Wilcox <willy@infradead.org>, ldufour@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Thu 28-06-18 12:10:10, Yang Shi wrote:
> 
> 
> On 6/28/18 4:51 AM, Michal Hocko wrote:
> > On Wed 27-06-18 10:23:39, Yang Shi wrote:
> > > 
> > > On 6/27/18 12:24 AM, Michal Hocko wrote:
> > > > On Tue 26-06-18 18:03:34, Yang Shi wrote:
> > > > > On 6/26/18 12:43 AM, Peter Zijlstra wrote:
> > > > > > On Mon, Jun 25, 2018 at 05:06:23PM -0700, Yang Shi wrote:
> > > > > > > By looking this deeper, we may not be able to cover all the unmapping range
> > > > > > > for VM_DEAD, for example, if the start addr is in the middle of a vma. We
> > > > > > > can't set VM_DEAD to that vma since that would trigger SIGSEGV for still
> > > > > > > mapped area.
> > > > > > > 
> > > > > > > splitting can't be done with read mmap_sem held, so maybe just set VM_DEAD
> > > > > > > to non-overlapped vmas. Access to overlapped vmas (first and last) will
> > > > > > > still have undefined behavior.
> > > > > > Acquire mmap_sem for writing, split, mark VM_DEAD, drop mmap_sem. Acquire
> > > > > > mmap_sem for reading, madv_free drop mmap_sem. Acquire mmap_sem for
> > > > > > writing, free everything left, drop mmap_sem.
> > > > > > 
> > > > > > ?
> > > > > > 
> > > > > > Sure, you acquire the lock 3 times, but both write instances should be
> > > > > > 'short', and I suppose you can do a demote between 1 and 2 if you care.
> > > > > Thanks, Peter. Yes, by looking the code and trying two different approaches,
> > > > > it looks this approach is the most straight-forward one.
> > > > Yes, you just have to be careful about the max vma count limit.
> > > Yes, we should just need copy what do_munmap does as below:
> > > 
> > > if (end < vma->vm_end && mm->map_count >= sysctl_max_map_count)
> > >              return -ENOMEM;
> > > 
> > > If the mas map count limit has been reached, it will return failure before
> > > zapping mappings.
> > Yeah, but as soon as you drop the lock and retake it, somebody might
> > have changed the adddress space and we might get inconsistency.
> > 
> > So I am wondering whether we really need upgrade_read (to promote read
> > to write lock) and do the
> > 	down_write
> > 	split & set up VM_DEAD
> > 	downgrade_write
> > 	unmap
> > 	upgrade_read
> > 	zap ptes
> > 	up_write
> 
> I'm supposed address space changing just can be done by mmap, mremap,
> mprotect. If so, we may utilize the new VM_DEAD flag. If the VM_DEAD flag is
> set for the vma, just return failure since it is being unmapped.

I am sorry I do not follow. How does VM_DEAD flag helps for a completely
unrelated vmas? Or maybe it would be better to post the code to see what
you mean exactly.
-- 
Michal Hocko
SUSE Labs
