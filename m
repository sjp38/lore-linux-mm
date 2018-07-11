Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07B0A6B0003
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 19:10:33 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id m2-v6so15866512plt.14
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 16:10:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f10-v6si18773892pgs.655.2018.07.11.16.10.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 16:10:31 -0700 (PDT)
Date: Wed, 11 Jul 2018 16:10:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, vmacache: hash addresses based on pmd
Message-Id: <20180711161030.b5ae2f5b1210150c13b1a832@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.21.1807091822460.130281@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1807091749150.114630@chino.kir.corp.google.com>
	<20180709180841.ebfb6cf70bd8dc08b269c0d9@linux-foundation.org>
	<alpine.DEB.2.21.1807091822460.130281@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 9 Jul 2018 18:37:37 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> > Did you consider LRU-sorting the array instead?
> > 
> 
> It adds 40 bytes to struct task_struct,

What does?  LRU sort?  It's a 4-entry array, just do it in place, like
bh_lru_install(). Confused.

> but I'm not sure the least 
> recently used is the first preferred check.  If I do 
> madvise(MADV_DONTNEED) from a malloc implementation where I don't control 
> what is free()'d and I'm constantly freeing back to the same hugepages, 
> for example, I may always get first slot cache hits with this patch as 
> opposed to the 25% chance that the current implementation has (and perhaps 
> an lru would as well).
> 
> I'm sure that I could construct a workload where LRU would be better and 
> could show that the added footprint were worthwhile, but I could also 
> construct a workload where the current implementation based on pfn would 
> outperform all of these.  It simply turns out that on the user-controlled 
> workloads that I was profiling that hashing based on pmd was the win.

That leaves us nowhere to go.  Zapping the WARN_ON seems a no-brainer
though?
