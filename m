Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A13D26B0275
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 12:48:18 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y73-v6so13833882pfi.16
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 09:48:18 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m39-v6si4573776plg.335.2018.10.17.09.48.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Oct 2018 09:48:17 -0700 (PDT)
Date: Wed, 17 Oct 2018 09:48:15 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH V2 1/4] mm: mmap: Allow for "high" userspace addresses
Message-ID: <20181017164815.GA7966@bombadil.infradead.org>
References: <20181017163459.20175-1-steve.capper@arm.com>
 <20181017163459.20175-2-steve.capper@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181017163459.20175-2-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@linaro.org, jcm@redhat.com

On Wed, Oct 17, 2018 at 05:34:56PM +0100, Steve Capper wrote:
> This patch adds support for "high" userspace addresses that are
> optionally supported on the system and have to be requested via a hint
> mechanism ("high" addr parameter to mmap).
> 
> Rather than duplicate the arch_get_unmapped_* stock implementations,
> this patch instead introduces two architectural helper macros and
> applies them to arch_get_unmapped_*:
>  arch_get_mmap_end(addr) - get mmap upper limit depending on addr hint
>  arch_get_mmap_base(addr, base) - get mmap_base depending on addr hint
> 
> If these macros are not defined in architectural code then they default
> to (TASK_SIZE) and (base) so should not introduce any behavioural
> changes to architectures that do not define them.

Can you explain (in the changelog) why we need to do this for arm64
when it wasn't needed for the equivalent feature on x86-64?  I think the
answer is that x86-64 already has its own arch_get_unmapped* functions and
rather than duplicating arch_get_unmapped* for arm64, you want to continue
using the generic ones with just this minor hooking.  But I'd like that
spelled out explicitly for the next person who comes along and wonders.
