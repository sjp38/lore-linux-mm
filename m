Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3CE8E8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:24:57 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id h10so3796537plk.12
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 05:24:57 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 69si6389300pla.75.2019.01.16.05.24.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 16 Jan 2019 05:24:55 -0800 (PST)
Date: Wed, 16 Jan 2019 14:24:46 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 5/5] psi: introduce psi monitor
Message-ID: <20190116132446.GF10803@hirez.programming.kicks-ass.net>
References: <20190110220718.261134-1-surenb@google.com>
 <20190110220718.261134-6-surenb@google.com>
 <20190114102137.GB14054@worktop.programming.kicks-ass.net>
 <CAJuCfpGUWs0E9oPUjPTNm=WhPJcE_DBjZCtCiaVu5WXabKRW6A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpGUWs0E9oPUjPTNm=WhPJcE_DBjZCtCiaVu5WXabKRW6A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk, dennis@kernel.org, Dennis Zhou <dennisszhou@gmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, cgroups@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-team@android.com

On Mon, Jan 14, 2019 at 11:30:12AM -0800, Suren Baghdasaryan wrote:
> For memory ordering (which Johannes also pointed out) the critical point is:
> 
> times[cpu] += delta           | if g->polling:
> smp_wmb()                     |   g->polling = polling = 0
> cmpxchg(g->polling, 0, 1)     |   smp_rmb()
>                               |   delta = times[*] (through goto SLOWPATH)
> 
> So that hotpath writes to times[] then g->polling and slowpath reads
> g->polling then times[]. cmpxchg() implies a full barrier, so we can
> drop smp_wmb(). Something like this:
> 
> times[cpu] += delta           | if g->polling:
> cmpxchg(g->polling, 0, 1)     |   g->polling = polling = 0
>                               |   smp_rmb()
>                               |   delta = times[*] (through goto SLOWPATH)
> 
> Would that address your concern about ordering?

cmpxchg() implies smp_mb() before and after, so the smp_wmb() on the
left column is superfluous.

The right hand column is actively wrong; because that reads like it
wants to order a store (g->polling = 0) and a load (d = times[]), and
therefore requires smp_mb().

Also, you probably want to use atomic_t for g->polling, because we
(sadly) have architectures where regular stores and atomic ops don't
work 'right'.
