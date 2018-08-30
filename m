Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE246B4EF2
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 22:27:09 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e15-v6so3919039pfi.5
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 19:27:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u24-v6sor1531284pgh.420.2018.08.29.19.27.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Aug 2018 19:27:07 -0700 (PDT)
Date: Wed, 29 Aug 2018 19:27:04 -0700
From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v4 0/3] KASLR feature to randomize each loadable module
Message-ID: <20180830022703.xxl5eolthinicgwp@ast-mbp>
References: <1535583579-6138-1-git-send-email-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1535583579-6138-1-git-send-email-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, daniel@iogearbox.net, jannh@google.com, keescook@chromium.org, kristen@linux.intel.com, dave.hansen@intel.com, arjan@linux.intel.com, netdev@vger.kernel.org

On Wed, Aug 29, 2018 at 03:59:36PM -0700, Rick Edgecombe wrote:
> Hi,
> 
> This is v4 of the "KASLR feature to randomize each loadable module" patchset.
> The purpose is to increase the randomization and also to make the modules
> randomized in relation to each other instead of just the base, so that if one
> module leaks the location of the others can't be inferred. It is enabled for
> x86_64 for now.
> 
> V4 is a few small fixes. I humbly think this is in pretty good shape at this
> point, unless anyone has any comments. The only other big change I was
> considering was moving the new randomization algorithm into vmalloc so it could
> be re-used for other architectures or possibly other vmalloc usages.
> 
> A few words on how this was tested - As previously mentioned, the entropy
> estimates were done using extracted module text sizes from the in-tree modules.
> These were also used to run 100,000's of simulated module allocations by calling
> module_alloc from a test module, including testing until allocation failure. The
> simulations kept track of every allocation address to make sure there were no
> collisions, and verified memory was actually mapped.
> 
> In addition the __vmalloc_node_try_addr function has a suite of unit tests that
> verify for a bunch of edge cases that it:
>  - Allows for allocations when it should
>  - Reports the right error code if it collides with a lazy-free area or real
>    allocation
>  - Verifies it frees a lazy free area when it should
> 
> These synthetic tests were also how the performance metrics were gathered.
> 
> Changes for V4:
>  - Fix issue caused by KASAN, kmemleak being provided different allocation
>    lengths (padding).
>  - Avoid kmalloc until sure its needed in __vmalloc_node_try_addr.
>  - Fix for debug file hang when the last VA is a lazy purge area
>  - Fixed issues reported by 0-day build system.
> 
> Changes for V3:
>  - Code cleanup based on internal feedback. (thanks to Dave Hansen and Andriy
>    Shevchenko)
>  - Slight refactor of existing algorithm to more cleanly live along side new
>    one.
>  - BPF synthetic benchmark

I don't see this benchmark in this patch set.
Could you prepare it as a test in tools/testing/selftests/bpf/ ?
so we can double check what is being tested and run it regularly
like we do for all other tests in there.
