Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id E508B6B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 21:33:37 -0400 (EDT)
Received: by mail-la0-f51.google.com with SMTP id gl10so8910567lab.10
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 18:33:37 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id g9si6909706lbv.86.2014.09.02.18.33.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Sep 2014 18:33:35 -0700 (PDT)
Date: Tue, 2 Sep 2014 21:33:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
Message-ID: <20140903013317.GA26086@cmpxchg.org>
References: <54061505.8020500@sr71.net>
 <20140902221814.GA18069@cmpxchg.org>
 <5406466D.1020000@sr71.net>
 <20140903001009.GA25970@cmpxchg.org>
 <CA+55aFw6ZkGNVX-CwyG0ybQAPjYAscdM59k_tOLtg4rr-fS-jg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFw6ZkGNVX-CwyG0ybQAPjYAscdM59k_tOLtg4rr-fS-jg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave@sr71.net>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Sep 02, 2014 at 05:20:55PM -0700, Linus Torvalds wrote:
> On Tue, Sep 2, 2014 at 5:10 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> >
> > That looks like a partial profile, where did the page allocator, page
> > zeroing etc. go?  Because the distribution among these listed symbols
> > doesn't seem all that crazy:
> 
> Please argue this *after* the commit has been reverted. You guys can
> try to make the memcontrol batching actually work and scale later.
> It's not appropriate to argue against major regressions when reported
> and bisected by users.

I'll send a clean revert later.

> Showing the spinlock at the top of the profile is very much crazy
> (apparently taking 68% of all cpu time), when it's all useless
> make-believe work. I don't understand why you wouldn't call that
> crazy.

If you limit perf to a subset of symbols, it will show a relative
distribution between them, i.e: perf top --symbols kfree,memset during
some disk access:

   PerfTop:    1292 irqs/sec  kernel:84.4%  exact:  0.0% [4000Hz cycles],  (all, 4 CPUs)
-------------------------------------------------------------------------------

    56.23%  [kernel]      [k] kfree 
    41.86%  [kernel]      [k] memset
     1.91%  libc-2.19.so  [.] memset

kfree isn't eating 56% of "all cpu time" here, and it wasn't clear to
me whether Dave filtered symbols from only memcontrol.o, memory.o, and
mmap.o in a similar way.  I'm not arguing against the regression, I'm
just trying to make sense of the numbers from the *patched* kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
