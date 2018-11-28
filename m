Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 009646B4F64
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 18:00:56 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id a2so13007601pgt.11
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 15:00:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 2si8533737pgz.395.2018.11.28.15.00.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 15:00:55 -0800 (PST)
Date: Wed, 28 Nov 2018 15:00:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH] mm: update highest_memmap_pfn based on exact pfn
Message-Id: <20181128150052.6c00403395ca3c9654341a94@linux-foundation.org>
In-Reply-To: <20181128083634.18515-1-richard.weiyang@gmail.com>
References: <20181128083634.18515-1-richard.weiyang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: hughd@google.com, pasha.tatashin@oracle.com, mgorman@suse.de, linux-mm@kvack.org

On Wed, 28 Nov 2018 16:36:34 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:

> When DEFERRED_STRUCT_PAGE_INIT is set, page struct will not be
> initialized all at boot up. Some of them is postponed to defer stage.
> While the global variable highest_memmap_pfn is still set to the highest
> pfn at boot up, even some of them are not initialized.
> 
> This patch adjust this behavior by update highest_memmap_pfn with the
> exact pfn during each iteration. Since each node has a defer thread,
> introduce a spin lock to protect it.
> 

Does this solve any known problems?  If so then I'm suspecting that
those problems go deeper than this.

Why use a spinlock rather than an atomic_long_t?

Perhaps this check should instead be built into pfn_valid()?
