Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 889368E003A
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 19:12:48 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x85-v6so17955pfe.13
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 16:12:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o33-v6si16055695plb.489.2018.09.17.16.12.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 16:12:47 -0700 (PDT)
Date: Mon, 17 Sep 2018 16:12:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] mm: Randomize free memory
Message-Id: <20180917161245.c4bb8546d2c6069b0506c5dd@linux-foundation.org>
In-Reply-To: <153702858249.1603922.12913911825267831671.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153702858249.1603922.12913911825267831671.stgit@dwillia2-desk3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 15 Sep 2018 09:23:02 -0700 Dan Williams <dan.j.williams@intel.com> wrote:

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
> 
> [1]: See ACPI 6.2 Section 5.2.27.5 Memory Side Cache Information Structure 

I'm struggling to understand the justification of all of this.  Are
such attacks known to exist?  Or reasonably expected to exist in the
future?  What is the likelihood and what is their cost?  Or is this all
academic and speculative and possibly pointless?

ie, something must have motivated you to do this work rather than
<something-else>.  Please spell out that motivation.


The new module parameter should be documented, please.  Let's try to
help people understand why they might ever want to alter the default
and if so, what settings they should be trying.


How come we aren't also shuffling at memory hot-add time?
