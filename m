Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C30596B02F4
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 11:01:33 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y39so8840974wry.10
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 08:01:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u67si1466094wrc.66.2017.06.09.08.01.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Jun 2017 08:01:30 -0700 (PDT)
Date: Fri, 9 Jun 2017 17:01:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v4 00/20] Speculative page faults
Message-ID: <20170609150126.GI21764@dhcp22.suse.cz>
References: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

On Fri 09-06-17 16:20:49, Laurent Dufour wrote:
> This is a port on kernel 4.12 of the work done by Peter Zijlstra to
> handle page fault without holding the mm semaphore.
> 
> http://linux-kernel.2935.n7.nabble.com/RFC-PATCH-0-6-Another-go-at-speculative-page-faults-tt965642.html#none
> 
> Compared to the Peter initial work, this series introduce a try spin
> lock when dealing with speculative page fault. This is required to
> avoid dead lock when handling a page fault while a TLB invalidate is
> requested by an other CPU holding the PTE. Another change due to a
> lock dependency issue with mapping->i_mmap_rwsem.
> 
> This series also protect changes to VMA's data which are read or
> change by the page fault handler. The protections is done through the
> VMA's sequence number.
> 
> This series is functional on x86 and PowerPC.
> 
> It's building on top of v4.12-rc4 and relies on the change done by
> Paul McKenney to the SRCU code allowing better performance by
> maintaining per-CPU callback lists:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=da915ad5cf25b5f5d358dd3670c3378d8ae8c03e
> 
> Tests have been made using a large commercial in-memory database on a
> PowerPC system with 752 CPUs. The results are very encouraging since
> the loading of the 2TB database was faster by 20% with the speculative
> page fault.
> 
> Since tests are encouraging and running test suite didn't raise any
> issue, I'd like this request for comment series to move to a patch
> series soon. So please feel free to comment.

What other testing have you done? Other benchmarks (some numbers)? What
about some standard worklaods like kbench? This is a pretty invasive
change so I would expect much more numbers.

It would also help to describe the highlevel design of the change here
in the cover letter. This would make the review of specifics much
easier.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
