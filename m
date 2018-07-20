Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id AB6BC6B0005
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 17:05:54 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id s3-v6so8263898plp.21
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 14:05:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r3-v6sor842784pfi.109.2018.07.20.14.05.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 14:05:53 -0700 (PDT)
Date: Fri, 20 Jul 2018 14:05:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: thp: remove use_zero_page sysfs knob
In-Reply-To: <3238b5d2-fd89-a6be-0382-027a24a4d3ad@linux.alibaba.com>
Message-ID: <alpine.DEB.2.21.1807201401390.231119@chino.kir.corp.google.com>
References: <1532110430-115278-1-git-send-email-yang.shi@linux.alibaba.com> <20180720123243.6dfc95ba061cd06e05c0262e@linux-foundation.org> <alpine.DEB.2.21.1807201300290.224013@chino.kir.corp.google.com>
 <3238b5d2-fd89-a6be-0382-027a24a4d3ad@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kirill@shutemov.name, hughd@google.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 20 Jul 2018, Yang Shi wrote:

> > We disable the huge zero page through this interface, there were issues
> > related to the huge zero page shrinker (probably best to never free a
> > per-node huge zero page after allocated) and CVE-2017-1000405 for huge
> > dirty COW.
> 
> Thanks for the information. It looks the CVE has been resolved by commit
> a8f97366452ed491d13cf1e44241bc0b5740b1f0 ("mm, thp: Do not make page table
> dirty unconditionally in touch_p[mu]d()"), which is in 4.15 already.
> 

For users who run kernels earlier than 4.15 they may choose to mitigate 
the CVE by using this tunable.  It's not something we permanently need to 
have, but it may likely be too early.

> What was the shrinker related issue? I'm supposed it has been resolved, right?
> 

The huge zero page can be reclaimed under memory pressure and, if it is, 
it is attempted to be allocted again with gfp flags that attempt memory 
compaction that can become expensive.  If we are constantly under memory 
pressure, it gets freed and reallocated millions of times always trying to 
compact memory both directly and by kicking kcompactd in the background.

It likely should also be per node.
