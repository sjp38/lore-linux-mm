Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8078C6B0008
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 10:30:21 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id q29-v6so1400310edd.0
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 07:30:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c3si662251edv.143.2018.10.02.07.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 07:30:20 -0700 (PDT)
Date: Tue, 2 Oct 2018 16:30:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] mm: Randomize free memory
Message-ID: <20181002143015.GX18290@dhcp22.suse.cz>
References: <153702858249.1603922.12913911825267831671.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153702858249.1603922.12913911825267831671.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Dave Hansen <dave.hansen@linux.intel.com>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 15-09-18 09:23:02, Dan Williams wrote:
> Data exfiltration attacks via speculative execution and
> return-oriented-programming attacks rely on the ability to infer the
> location of sensitive data objects. The kernel page allocator, has
> predictable first-in-first-out behavior for physical pages. Pages are
> freed in physical address order when first onlined. There are also
> mechanisms like CMA that can free large contiguous areas at once
> increasing the predictability of allocations in physical memory.
> 
> In addition to the security implications this randomization also
> stabilizes the average performance of direct-mapped memory-side caches.
> This includes memory-side caches like the one on the Knights Landing
> processor and those generally described by the ACPI HMAT (Heterogeneous
> Memory Attributes Table [1]). Cache conflicts are spread over a random
> distribution rather than localized.
> 
> Given the performance sensitivity of the page allocator this
> randomization is only performed for MAX_ORDER (4MB by default) pages. A
> kernel parameter, page_alloc.shuffle_page_order, is included to change
> the page size where randomization occurs.

I have only glanced through the implementation. The boot allocator part
seems unexpectedly too large but I haven't tried to actually think about
simplification.

It is the more general idea that I am not really sure about. First of
all. Does it make _any_ sense to randomize 4MB blocks by default? Why
cannot we simply have it disabled? Then and more concerning question is,
does it even make sense to have this randomization applied to higher
orders than 0? Attacker might fragment the memory and keep recycling the
lowest order and get the predictable behavior that we have right now.
-- 
Michal Hocko
SUSE Labs
