Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id D5B7A6B0007
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 21:08:44 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id az8-v6so10892179plb.15
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 18:08:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m12-v6si6813508pgd.334.2018.07.09.18.08.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 18:08:43 -0700 (PDT)
Date: Mon, 9 Jul 2018 18:08:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, vmacache: hash addresses based on pmd
Message-Id: <20180709180841.ebfb6cf70bd8dc08b269c0d9@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.21.1807091749150.114630@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1807091749150.114630@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 9 Jul 2018 17:50:03 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> When perf profiling a wide variety of different workloads, it was found
> that vmacache_find() had higher than expected cost: up to 0.08% of cpu
> utilization in some cases.  This was found to rival other core VM
> functions such as alloc_pages_vma() with thp enabled and default
> mempolicy, and the conditionals in __get_vma_policy().
> 
> VMACACHE_HASH() determines which of the four per-task_struct slots a vma
> is cached for a particular address.  This currently depends on the pfn,
> so pfn 5212 occupies a different vmacache slot than its neighboring
> pfn 5213.
> 
> vmacache_find() iterates through all four of current's vmacache slots
> when looking up an address.  Hashing based on pfn, an address has
> ~1/VMACACHE_SIZE chance of being cached in the first vmacache slot, or
> about 25%, *if* the vma is cached.
> 
> This patch hashes an address by its pmd instead of pte to optimize for
> workloads with good spatial locality.  This results in a higher
> probability of vmas being cached in the first slot that is checked:
> normally ~70% on the same workloads instead of 25%.

Was the improvement quantifiable?

Surprised.  That little array will all be in CPU cache and that loop
should execute pretty quickly?  If it's *that* sensitive then let's zap
the no-longer-needed WARN_ON.  And we could hide all the event counting
behind some developer-only ifdef.

Did you consider LRU-sorting the array instead?
