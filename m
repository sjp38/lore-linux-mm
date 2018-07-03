Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CB06D6B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 02:09:26 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e19-v6so510680pgv.11
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 23:09:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x5-v6si356659pgx.310.2018.07.02.23.09.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 23:09:25 -0700 (PDT)
Date: Tue, 3 Jul 2018 08:09:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v3 PATCH 4/5] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-ID: <20180703060921.GA16767@dhcp22.suse.cz>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530311985-31251-5-git-send-email-yang.shi@linux.alibaba.com>
 <20180629183501.9e30c26135f11853245c56c7@linux-foundation.org>
 <084aeccb-2c54-2299-8bf0-29a10cc0186e@linux.alibaba.com>
 <20180629201547.5322cfc4b52d19a0443daec2@linux-foundation.org>
 <20180702140502.GZ19043@dhcp22.suse.cz>
 <20180702134845.c4f536dead5374b443e24270@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180702134845.c4f536dead5374b443e24270@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, willy@infradead.org, ldufour@linux.vnet.ibm.com, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Mon 02-07-18 13:48:45, Andrew Morton wrote:
> On Mon, 2 Jul 2018 16:05:02 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Fri 29-06-18 20:15:47, Andrew Morton wrote:
> > [...]
> > > Would one of your earlier designs have addressed all usecases?  I
> > > expect the dumb unmap-a-little-bit-at-a-time approach would have?
> > 
> > It has been already pointed out that this will not work.
> 
> I said "one of".  There were others.

Well, I was aware only about two potential solutions. Either do the
heavy lifting under the shared lock and do the rest with the exlusive
one and this, drop the lock per parts. Maybe I have missed others?

> > You simply
> > cannot drop the mmap_sem during unmap because another thread could
> > change the address space under your feet. So you need some form of
> > VM_DEAD and handle concurrent and conflicting address space operations.
> 
> Unclear that this is a problem.  If a thread does an unmap of a range
> of virtual address space, there's no guarantee that upon return some
> other thread has not already mapped new stuff into that address range. 
> So what's changed?

Well, consider the following scenario:
Thread A = calling mmap(NULL, sizeA)
Thread B = calling munmap(addr, sizeB)

They do not use any external synchronization and rely on the atomic
munmap. Thread B only munmaps range that it knows belongs to it (e.g.
called mmap in the past). It should be clear that ThreadA should not
get an address from the addr, sizeB range, right? In the most simple case
it will not happen. But let's say that the addr, sizeB range has
unmapped holes for what ever reasons. Now anytime munmap drops the
exclusive lock after handling one VMA, Thread A might find its sizeA
range and use it. ThreadB then might remove this new range as soon as it
gets its exclusive lock again.

Is such a code safe? No it is not and I would call it fragile at best
but people tend to do weird things and atomic munmap behavior is
something they can easily depend on.

Another example would be an atomic address range probing by
MAP_FIXED_NOREPLACE. It would simply break for similar reasons.

I remember my attempt to make MAP_LOCKED consistent with mlock (if the
population fails then return -ENOMEM) and that required to drop the
shared mmap_sem and take it in exclusive mode (because we do not
have upgrade_read) and Linus was strongly against [1][2] for very
similar reasons. If you drop the lock you simply do not know what
happened under your feet.

[1] http://lkml.kernel.org/r/CA+55aFydkG-BgZzry5DrTzueVh9VvEcVJdLV8iOyUphQk=0vpw@mail.gmail.com
[2] http://lkml.kernel.org/r/CA+55aFyajquhGhw59qNWKGK4dBV0TPmDD7-1XqPo7DZWvO_hPg@mail.gmail.com
-- 
Michal Hocko
SUSE Labs
