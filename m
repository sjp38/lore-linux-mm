Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D45BE6B0006
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 03:43:48 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id i12-v6so6114786pgt.13
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 00:43:48 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s14-v6si877297pgn.76.2018.06.26.00.43.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Jun 2018 00:43:47 -0700 (PDT)
Date: Tue, 26 Jun 2018 09:43:44 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-ID: <20180626074344.GZ2458@hirez.programming.kicks-ass.net>
References: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
 <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
 <3DDF2672-FCC4-4387-9624-92F33C309CAE@gmail.com>
 <158a4e4c-d290-77c4-a595-71332ede392b@linux.alibaba.com>
 <BFD6A249-B1D7-43D5-8D7C-9FAED4A168A1@gmail.com>
 <20180620071817.GJ13685@dhcp22.suse.cz>
 <263935d9-d07c-ab3e-9e42-89f73f57be1e@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <263935d9-d07c-ab3e-9e42-89f73f57be1e@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Matthew Wilcox <willy@infradead.org>, ldufour@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Mon, Jun 25, 2018 at 05:06:23PM -0700, Yang Shi wrote:
> By looking this deeper, we may not be able to cover all the unmapping range
> for VM_DEAD, for example, if the start addr is in the middle of a vma. We
> can't set VM_DEAD to that vma since that would trigger SIGSEGV for still
> mapped area.
> 
> splitting can't be done with read mmap_sem held, so maybe just set VM_DEAD
> to non-overlapped vmas. Access to overlapped vmas (first and last) will
> still have undefined behavior.

Acquire mmap_sem for writing, split, mark VM_DEAD, drop mmap_sem. Acquire
mmap_sem for reading, madv_free drop mmap_sem. Acquire mmap_sem for
writing, free everything left, drop mmap_sem.

?

Sure, you acquire the lock 3 times, but both write instances should be
'short', and I suppose you can do a demote between 1 and 2 if you care.
