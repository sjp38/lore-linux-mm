Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id D26246B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 13:32:38 -0400 (EDT)
Received: by qcej9 with SMTP id j9so53093236qce.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 10:32:38 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h4si3136638qge.80.2015.06.08.10.32.37
        for <linux-mm@kvack.org>;
        Mon, 08 Jun 2015 10:32:38 -0700 (PDT)
Date: Mon, 8 Jun 2015 18:32:34 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC PATCH] mm: kmemleak: Optimise kmemleak_lock acquiring
 during kmemleak_scan
Message-ID: <20150608173233.GD31349@e104818-lin.cambridge.arm.com>
References: <1433783219-14453-1-git-send-email-catalin.marinas@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433783219-14453-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jun 08, 2015 at 06:06:59PM +0100, Catalin Marinas wrote:
> The kmemleak memory scanning uses finer grained object->lock spinlocks
> primarily to avoid races with the memory block freeing. However, the
> pointer lookup in the rb tree requires the kmemleak_lock to be held.
> This is currently done in the find_and_get_object() function for each
> pointer-like location read during scanning. While this allows a low
> latency on kmemleak_*() callbacks on other CPUs, the memory scanning is
> slower.
> 
> This patch moves the kmemleak_lock outside the core scan_block()
> function allowing the spinlock to be acquired/released only once per
> scanned memory block rather than individual pointer-like values. The
> memory scanning performance is significantly improved (by an order of
> magnitude on an arm64 system).
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
> Andrew,
> 
> While sorting out some of the kmemleak disabling races, I realised that
> kmemleak scanning performance can be improved. On an arm64 system I
> tested (albeit not a fast one but with 6 CPUs and 8GB of RAM),
> immediately after boot an "time echo scan > /sys/kernel/debug/kmemleak"
> takes on average 70 sec. With this patch applied, I get on average 4.7
> sec.

I need to make a correction here as I forgot lock proving enabled in my
.config when running the tests. With all the spinlock debugging
disabled, I get 9.5 sec vs 3.5 sec. Still an improvement but no longer
by an order of magnitude.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
