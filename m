Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 723006B0031
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 11:01:17 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id w5so7039340qac.34
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 08:01:16 -0700 (PDT)
Received: from mail-qc0-x236.google.com (mail-qc0-x236.google.com [2607:f8b0:400d:c01::236])
        by mx.google.com with ESMTPS id u4si9566488qat.12.2014.03.10.08.01.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Mar 2014 08:01:15 -0700 (PDT)
Received: by mail-qc0-f182.google.com with SMTP id e16so7946958qcx.27
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 08:01:15 -0700 (PDT)
Date: Mon, 10 Mar 2014 11:01:06 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: deadlock in lru_add_drain ? (3.14rc5)
Message-ID: <20140310150106.GD25290@htj.dyndns.org>
References: <20140308220024.GA814@redhat.com>
 <CA+55aFzLxY8Xsn90v1OAsmVBWYPZTiJ74YE=HaCPYR2hvRfk+g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzLxY8Xsn90v1OAsmVBWYPZTiJ74YE=HaCPYR2hvRfk+g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, Chris Metcalf <cmetcalf@tilera.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Hello,

On Sat, Mar 08, 2014 at 05:18:34PM -0800, Linus Torvalds wrote:
> Adding more appropriate people to the cc.
> 
> That semaphore was added by commit 5fbc461636c3 ("mm: make
> lru_add_drain_all() selective"), and acked by Tejun. But we've had

It's essentially custom static implementation of
schedule_on_each_cpu() which uses the mutex to protect the static
buffers.  schedule_on_each_cpu() is different in that it uses dynamic
allocation and can be reentered.

> problems before with holding locks and then calling flush_work(),
> since that has had a tendency of deadlocking. I think we have various
> lockdep hacks in place to make "flush_work()" trigger some of the
> problems, but I'm not convinced it necessarily works.

If this were caused by lru_add_drain_all() entering itself, the
offender must be pretty clear in its stack trace.  It probably
involves more elaborate dependency chain.  No idea why wq lockdep
annotation would trigger on it tho.  The flush_work() annotation is
pretty straight-forward.

> On Sat, Mar 8, 2014 at 2:00 PM, Dave Jones <davej@redhat.com> wrote:
> > I left my fuzzing box running for the weekend, and checked in on it this evening,
> > to find that none of the child processes were making any progress.
> > cat'ing /proc/n/stack shows them all stuck in the same place..
> > Some examples:

Dave, any chance you can post full sysrq-t dump?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
