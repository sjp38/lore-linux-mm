Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 23F7D6B026F
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 03:48:41 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id 57-v6so4947963edt.15
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 00:48:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q22-v6si1015722ejj.201.2018.10.04.00.48.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 00:48:39 -0700 (PDT)
Date: Thu, 4 Oct 2018 09:48:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/3] mm: Shuffle initial free memory
Message-ID: <20181004074838.GE22173@dhcp22.suse.cz>
References: <153861931865.2863953.11185006931458762795.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153861932401.2863953.11364943845583542894.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153861932401.2863953.11364943845583542894.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 03-10-18 19:15:24, Dan Williams wrote:
> Some data exfiltration and return-oriented-programming attacks rely on
> the ability to infer the location of sensitive data objects. The kernel
> page allocator, especially early in system boot, has predictable
> first-in-first out behavior for physical pages. Pages are freed in
> physical address order when first onlined.
> 
> Introduce shuffle_free_memory(), and its helper shuffle_zone(), to
> perform a Fisher-Yates shuffle of the page allocator 'free_area' lists
> when they are initially populated with free memory at boot and at
> hotplug time.
> 
> Quoting Kees:
>     "While we already have a base-address randomization
>      (CONFIG_RANDOMIZE_MEMORY), attacks against the same hardware and
>      memory layouts would certainly be using the predictability of
>      allocation ordering (i.e. for attacks where the base address isn't
>      important: only the relative positions between allocated memory).
>      This is common in lots of heap-style attacks. They try to gain
>      control over ordering by spraying allocations, etc.
> 
>      I'd really like to see this because it gives us something similar
>      to CONFIG_SLAB_FREELIST_RANDOM but for the page allocator."
> 
> Another motivation for this change is performance in the presence of a
> memory-side cache. In the future, memory-side-cache technology will be
> available on generally available server platforms. The proposed
> randomization approach has been measured to improve the cache conflict
> rate by a factor of 2.5X on a well-known Java benchmark. It avoids
> performance peaks and valleys to provide more predictable performance.
> 
> While SLAB_FREELIST_RANDOM reduces the predictability of some local slab
> caches it leaves vast bulk of memory to be predictably in order
> allocated. That ordering can be detected by a memory side-cache.
> 
> The shuffling is done in terms of 'shuffle_page_order' sized free pages
> where the default shuffle_page_order is MAX_ORDER-1 i.e. 10, 4MB this
> trades off randomization granularity for time spent shuffling.
> MAX_ORDER-1 was chosen to be minimally invasive to the page allocator
> while still showing memory-side cache behavior improvements.
> 
> The performance impact of the shuffling appears to be in the noise
> compared to other memory initialization work. Also the bulk of the work
> is done in the background as a part of deferred_init_memmap().

This is the biggest portion of the series and I am wondering why do we
need it at all. Why it isn't sufficient to rely on the patch 3 here?
Pages freed from the bootmem allocator go via the same path so they
might be shuffled at that time. Or is there any problem with that?
Not enough entropy at the time when this is called or the final result
is not randomized enough (some numbers would be helpful).
-- 
Michal Hocko
SUSE Labs
