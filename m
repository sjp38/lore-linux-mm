Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B1E2C6B026A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 15:03:52 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c20-v6so2335882eds.21
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 12:03:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u12-v6si4246205edl.395.2018.06.28.12.03.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 12:03:48 -0700 (PDT)
Date: Thu, 28 Jun 2018 13:51:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-ID: <20180628115101.GE32348@dhcp22.suse.cz>
References: <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
 <3DDF2672-FCC4-4387-9624-92F33C309CAE@gmail.com>
 <158a4e4c-d290-77c4-a595-71332ede392b@linux.alibaba.com>
 <BFD6A249-B1D7-43D5-8D7C-9FAED4A168A1@gmail.com>
 <20180620071817.GJ13685@dhcp22.suse.cz>
 <263935d9-d07c-ab3e-9e42-89f73f57be1e@linux.alibaba.com>
 <20180626074344.GZ2458@hirez.programming.kicks-ass.net>
 <e54e298d-ef86-19a7-6f6b-07776f9a43e2@linux.alibaba.com>
 <20180627072432.GC32348@dhcp22.suse.cz>
 <a52f0585-ebec-d098-2775-f55bde3519a4@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a52f0585-ebec-d098-2775-f55bde3519a4@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Nadav Amit <nadav.amit@gmail.com>, Matthew Wilcox <willy@infradead.org>, ldufour@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Wed 27-06-18 10:23:39, Yang Shi wrote:
> 
> 
> On 6/27/18 12:24 AM, Michal Hocko wrote:
> > On Tue 26-06-18 18:03:34, Yang Shi wrote:
> > > 
> > > On 6/26/18 12:43 AM, Peter Zijlstra wrote:
> > > > On Mon, Jun 25, 2018 at 05:06:23PM -0700, Yang Shi wrote:
> > > > > By looking this deeper, we may not be able to cover all the unmapping range
> > > > > for VM_DEAD, for example, if the start addr is in the middle of a vma. We
> > > > > can't set VM_DEAD to that vma since that would trigger SIGSEGV for still
> > > > > mapped area.
> > > > > 
> > > > > splitting can't be done with read mmap_sem held, so maybe just set VM_DEAD
> > > > > to non-overlapped vmas. Access to overlapped vmas (first and last) will
> > > > > still have undefined behavior.
> > > > Acquire mmap_sem for writing, split, mark VM_DEAD, drop mmap_sem. Acquire
> > > > mmap_sem for reading, madv_free drop mmap_sem. Acquire mmap_sem for
> > > > writing, free everything left, drop mmap_sem.
> > > > 
> > > > ?
> > > > 
> > > > Sure, you acquire the lock 3 times, but both write instances should be
> > > > 'short', and I suppose you can do a demote between 1 and 2 if you care.
> > > Thanks, Peter. Yes, by looking the code and trying two different approaches,
> > > it looks this approach is the most straight-forward one.
> > Yes, you just have to be careful about the max vma count limit.
> 
> Yes, we should just need copy what do_munmap does as below:
> 
> if (end < vma->vm_end && mm->map_count >= sysctl_max_map_count)
>             return -ENOMEM;
> 
> If the mas map count limit has been reached, it will return failure before
> zapping mappings.

Yeah, but as soon as you drop the lock and retake it, somebody might
have changed the adddress space and we might get inconsistency.

So I am wondering whether we really need upgrade_read (to promote read
to write lock) and do the
	down_write
	split & set up VM_DEAD
	downgrade_write
	unmap
	upgrade_read
	zap ptes
	up_write

looks terrible, no question about that, but we won't drop the mmap sem
at any time.
-- 
Michal Hocko
SUSE Labs
