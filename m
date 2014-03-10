Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 37DCF6B006E
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 16:10:02 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id e16so8556778qcx.27
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 13:10:01 -0700 (PDT)
Received: from mail-qa0-x22f.google.com (mail-qa0-x22f.google.com [2607:f8b0:400d:c00::22f])
        by mx.google.com with ESMTPS id g67si5817638qgg.10.2014.03.10.13.10.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Mar 2014 13:10:01 -0700 (PDT)
Received: by mail-qa0-f47.google.com with SMTP id w5so7525043qac.34
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 13:10:01 -0700 (PDT)
Date: Mon, 10 Mar 2014 16:09:57 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: deadlock in lru_add_drain ? (3.14rc5)
Message-ID: <20140310200957.GF25290@htj.dyndns.org>
References: <20140308220024.GA814@redhat.com>
 <CA+55aFzLxY8Xsn90v1OAsmVBWYPZTiJ74YE=HaCPYR2hvRfk+g@mail.gmail.com>
 <20140310150106.GD25290@htj.dyndns.org>
 <20140310155053.GA26188@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140310155053.GA26188@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Chris Metcalf <cmetcalf@tilera.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Lai Jiangshan <laijs@cn.fujitsu.com>

Hello,

On Mon, Mar 10, 2014 at 11:50:53AM -0400, Dave Jones wrote:
> On Mon, Mar 10, 2014 at 11:01:06AM -0400, Tejun Heo wrote:
> 
>  > > On Sat, Mar 8, 2014 at 2:00 PM, Dave Jones <davej@redhat.com> wrote:
>  > > > I left my fuzzing box running for the weekend, and checked in on it this evening,
>  > > > to find that none of the child processes were making any progress.
>  > > > cat'ing /proc/n/stack shows them all stuck in the same place..
>  > > > Some examples:
>  > 
>  > Dave, any chance you can post full sysrq-t dump?
> 
> It's too big to fit in the ring-buffer, so some of it gets lost before
> it hits syslog, but hopefully what made it to disk is enough.
> http://codemonkey.org.uk/junk/sysrq-t

Hmmm... this is puzzling.  At least according to the slightly
truncated (pids < 13) sysrq-t output, there's no kworker running
lru_add_drain_per_cpu() and nothing blocked on lru_add_drain_all::lock
can introduce any complex dependency.  Also, at least from glancing
over, I don't see anything behind lru_add_rain_per_cpu() which can get
involved in a complex dependency chain.

Assuming that the handful lost traces didn't reveal serious ah-has, it
almost looks like workqueue either failed to initiate execution of a
queued work item or flush_work() somehow got confused on a work item
which already finished, both of which are quite unlikely given that we
haven't had any simliar report on any other work items.

I think it'd be wise to extend sysrq-t output to include the states of
workqueue if for nothing else to easily rule out doubts about basic wq
functions.  Dave, is this as much information we're gonna get from the
trinity instance?  I assume trying to reproduce the case isn't likely
to work?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
