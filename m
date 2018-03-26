Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6D90B6B000A
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 11:44:26 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id g13-v6so3089489otk.5
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 08:44:26 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u1si16032oiv.71.2018.03.26.08.44.25
        for <linux-mm@kvack.org>;
        Mon, 26 Mar 2018 08:44:25 -0700 (PDT)
Date: Mon, 26 Mar 2018 16:44:21 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm: kmemleak: wait for scan completion before disabling
 free
Message-ID: <20180326154421.obk7ikx3h5ko62o5@armageddon.cambridge.arm.com>
References: <1522063429-18992-1-git-send-email-vinmenon@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522063429-18992-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, Mar 26, 2018 at 04:53:49PM +0530, Vinayak Menon wrote:
> A crash is observed when kmemleak_scan accesses the
> object->pointer, likely due to the following race.
> 
> TASK A             TASK B                     TASK C
> kmemleak_write
>  (with "scan" and
>  NOT "scan=on")
> kmemleak_scan()
>                    create_object
>                    kmem_cache_alloc fails
>                    kmemleak_disable
>                    kmemleak_do_cleanup
>                    kmemleak_free_enabled = 0
>                                               kfree
>                                               kmemleak_free bails out
>                                                (kmemleak_free_enabled is 0)
>                                               slub frees object->pointer
> update_checksum
> crash - object->pointer
>  freed (DEBUG_PAGEALLOC)
> 
> kmemleak_do_cleanup waits for the scan thread to complete, but not for
> direct call to kmemleak_scan via kmemleak_write. So add a wait for
> kmemleak_scan completion before disabling kmemleak_free.
> 
> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>

It looks fine to me. Maybe Andrew can pick it up.

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

Thanks.
