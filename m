Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 21B906B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 03:17:14 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id z5-v6so1349144pln.20
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 00:17:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d32-v6si1728543pla.329.2018.06.20.00.17.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jun 2018 00:17:12 -0700 (PDT)
Date: Wed, 20 Jun 2018 09:17:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-ID: <20180620071708.GI13685@dhcp22.suse.cz>
References: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
 <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
 <20180619100218.GN2458@hirez.programming.kicks-ass.net>
 <f78924fc-ea81-9ddd-ebb2-28241d5721c8@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f78924fc-ea81-9ddd-ebb2-28241d5721c8@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Peter Zijlstra <peterz@infradead.org>, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 19-06-18 14:13:05, Yang Shi wrote:
> 
> 
> On 6/19/18 3:02 AM, Peter Zijlstra wrote:
[...]
> > Hold up, two things: you having to copy most of do_munmap() didn't seem
> > to suggest a helper function? And second, since when are we allowed to
> 
> Yes, they will be extracted into a helper function in the next version.
> 
> May bad, I don't think it is allowed. We could reform this to:
> 
> acquire write mmap_sem
> vma lookup (split vmas)
> release write mmap_sem
> 
> acquire read mmap_sem
> zap pages
> release read mmap_sem
> 
> I'm supposed this is safe as what Michal said before.

I didn't get to read your patches carefully yet but I am wondering why
do you need to split in the first place. Why cannot you simply unmap the
range (madvise(DONTNEED)) under the read lock and then take the lock for
write to finish the rest?
-- 
Michal Hocko
SUSE Labs
