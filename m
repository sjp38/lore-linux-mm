Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED5FB8E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 13:03:34 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id p15so37508803pfk.7
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 10:03:34 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f38si23649571pgf.206.2019.01.04.10.03.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 04 Jan 2019 10:03:33 -0800 (PST)
Date: Fri, 4 Jan 2019 10:03:32 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Expose lazy vfree pages to control via sysctl
Message-ID: <20190104180332.GV6310@bombadil.infradead.org>
References: <1546616141-486-1-git-send-email-amhetre@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1546616141-486-1-git-send-email-amhetre@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ashish Mhetre <amhetre@nvidia.com>
Cc: vdumpa@nvidia.com, mcgrof@kernel.org, keescook@chromium.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org, Snikam@nvidia.com

On Fri, Jan 04, 2019 at 09:05:41PM +0530, Ashish Mhetre wrote:
> From: Hiroshi Doyu <hdoyu@nvidia.com>
> 
> The purpose of lazy_max_pages is to gather virtual address space till it
> reaches the lazy_max_pages limit and then purge with a TLB flush and hence
> reduce the number of global TLB flushes.
> The default value of lazy_max_pages with one CPU is 32MB and with 4 CPUs it
> is 96MB i.e. for 4 cores, 96MB of vmalloc space will be gathered before it
> is purged with a TLB flush.
> This feature has shown random latency issues. For example, we have seen
> that the kernel thread for some camera application spent 30ms in
> __purge_vmap_area_lazy() with 4 CPUs.

You're not the first to report something like this.  Looking through the
kernel logs, I see:

commit 763b218ddfaf56761c19923beb7e16656f66ec62
Author: Joel Fernandes <joelaf@google.com>
Date:   Mon Dec 12 16:44:26 2016 -0800

    mm: add preempt points into __purge_vmap_area_lazy()

commit f9e09977671b618aeb25ddc0d4c9a84d5b5cde9d
Author: Christoph Hellwig <hch@lst.de>
Date:   Mon Dec 12 16:44:23 2016 -0800

    mm: turn vmap_purge_lock into a mutex

commit 80c4bd7a5e4368b680e0aeb57050a1b06eb573d8
Author: Chris Wilson <chris@chris-wilson.co.uk>
Date:   Fri May 20 16:57:38 2016 -0700

    mm/vmalloc: keep a separate lazy-free list

So the first thing I want to do is to confirm that you see this problem
on a modern kernel.  We've had trouble with NVidia before reporting
historical problems as if they were new.
