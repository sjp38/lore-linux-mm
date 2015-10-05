Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9F31D6B0332
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 10:44:07 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so117892500wic.0
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 07:44:07 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id h6si16825221wib.97.2015.10.05.07.44.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Oct 2015 07:44:06 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so124173595wic.0
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 07:44:06 -0700 (PDT)
Date: Mon, 5 Oct 2015 16:44:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20151005144404.GD7023@dhcp22.suse.cz>
References: <20150922160608.GA2716@redhat.com>
 <20150923205923.GB19054@dhcp22.suse.cz>
 <alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com>
 <20150925093556.GF16497@dhcp22.suse.cz>
 <201509260114.ADI35946.OtHOVFOMJQFLFS@I-love.SAKURA.ne.jp>
 <201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
 <20151002123639.GA13914@dhcp22.suse.cz>
 <CA+55aFw=OLSdh-5Ut2vjy=4Yf1fTXqpzoDHdF7XnT5gDHs6sYA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFw=OLSdh-5Ut2vjy=4Yf1fTXqpzoDHdF7XnT5gDHs6sYA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>

On Fri 02-10-15 15:01:06, Linus Torvalds wrote:
> On Fri, Oct 2, 2015 at 8:36 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >
> > Have they been reported/fixed? All kernel paths doing an allocation are
> > _supposed_ to check and handle ENOMEM. If they are not then they are
> > buggy and should be fixed.
> 
> No. Stop this theoretical idiocy.
> 
> We've tried it. I objected before people tried it, and it turns out
> that it was a horrible idea.
> 
> Small kernel allocations should basically never fail, because we end
> up needing memory for random things, and if a kmalloc() fails it's
> because some application is using too much memory, and the application
> should be killed. Never should the kernel allocation fail. It really
> is that simple. If we are out of memory, that does not mean that we
> should start failing random kernel things.

But you do realize that killing a task as a memory reclaim technique is
not 100% reliable, right?

Any task might be blocked in an uninterruptible context (e.g. a mutex)
waiting for completion which depends on the allocation success. The page
allocator (resp. OOM killer) is not aware of these dependencies and I am
really skeptical it will ever be because dependency tracking is way too
expensive. So killing a task doesn't guarantee a forward progress.

So I can see basically only few ways out of this deadlock situation.
Either we face the reality and allow small allocations (withtout
__GFP_NOFAIL) to fail after all attempts to reclaim memory have failed
(so after even OOM killer hasn't made any progress).
Or we can start killing other tasks but this might end up in the same
state and the time to resolve the problem might be basically unbounded
(it is trivial to construct loads where hundreds of tasks are bashing
against a single i_mutex and all of them depending on an allocation...).
Or we can panic/reboot the system if the OOM situation cannot be solved
within a selected timeout.

There are other ways to micro-optimize the current implementation by
playing with memory reserves but all that is just postponing the final
disaster and there is still a point of no further progress that we have
to deal with somehow.

> So this "people should check for allocation failures" is bullshit.
> It's a computer science myth. It's simply not true in all cases.

Sure it is not true in _all_ cases. If some paths cannot fail they can
use __GFP_NOFAIL for that purpose. The point is that most allocations
_can_ handle the failure. People are taught to check for allocation
failures. We even have scripts/coccinelle/null/kmerr.cocci which helps
to detect slab allocator users to some degree.

> Kernel allocators that know that they do large allocations (ie bigger
> than a few pages) need to be able to handle the failure, but not the
> general case. Also, kernel allocators that know they have a good
> fallback (eg they try a large allocation first but can fall back to a
> smaller one) should use __GFP_NORETRY, but again, that does *not* in
> any way mean that general kernel allocations should randomly fail.
> 
> So no. The answer is ABSOLUTELY NOT "everybody should check allocation
> failure". Get over it. I refuse to go through that circus again. It's
> stupid.
> 
>              Linus

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
