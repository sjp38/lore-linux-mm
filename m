Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A57A6B02FD
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 07:06:17 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id n7so22208227wrb.0
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 04:06:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y123si7384233wmd.16.2017.06.12.04.06.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Jun 2017 04:06:15 -0700 (PDT)
Date: Mon, 12 Jun 2017 13:06:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] mm, oom: do not trigger out_of_memory from the
 #PF
Message-ID: <20170612110612.GG7476@dhcp22.suse.cz>
References: <20170609140853.GA14760@cmpxchg.org>
 <20170609144642.GH21764@dhcp22.suse.cz>
 <20170610084901.GB12347@dhcp22.suse.cz>
 <201706102057.GGG13003.OtFMJSQOVLFOHF@I-love.SAKURA.ne.jp>
 <20170612073922.GA7476@dhcp22.suse.cz>
 <201706121948.CEC81794.OFMLFSJOtHOQFV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706121948.CEC81794.OFMLFSJOtHOQFV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, guro@fb.com, vdavydov.dev@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 12-06-17 19:48:03, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> >                                                       Without this patch
> > this would be impossible.
> 
> What I wanted to say is that, with this patch, you are introducing possibility
> of lockup. "Retrying the whole page fault path when page fault allocations
> failed but the OOM killer does not trigger" helps nothing. It will just spin
> wasting CPU time until somebody else invokes the OOM killer.

But this is very same with what we do in the page allocator already. We
keep retrying relying on somebody else making a forward progress on our
behalf for those requests which in a weaker reclaim context. So what
would be a _new_ lockup that didn't exist with the current code?
As I've already said (and I haven't heard a counter argument yet)
unwinding to the PF has a nice advantage that the whole locking context
will be gone as well. So unlike in the page allocator we can allow
others to make a forward progress. This sounds like an advantage to me.

The only possibility for a new lockup I can see is that some PF callpath
returned VM_FAULT_OOM without doing an actual allocation (aka leaked
VM_FAULT_OOM) and in that case it is a bug in that call path. Why should
we trigger a _global_ disruption action when the bug is specific to a
particular process? Moreover the global OOM killer will only stop this
path to refault by killing it which can happen after quite some other
processes being killed.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
