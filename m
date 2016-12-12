Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CCD46B025E
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 03:48:42 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id xy5so22200681wjc.0
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 00:48:42 -0800 (PST)
Received: from mail-wj0-f195.google.com (mail-wj0-f195.google.com. [209.85.210.195])
        by mx.google.com with ESMTPS id q2si27451690wmg.152.2016.12.12.00.48.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 00:48:41 -0800 (PST)
Received: by mail-wj0-f195.google.com with SMTP id he10so10287656wjc.2
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 00:48:40 -0800 (PST)
Date: Mon, 12 Dec 2016 09:48:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
Message-ID: <20161212084837.GB18163@dhcp22.suse.cz>
References: <20161205141009.GJ30758@dhcp22.suse.cz>
 <201612061938.DDD73970.QFHOFJStFOLVOM@I-love.SAKURA.ne.jp>
 <20161206192242.GA10273@dhcp22.suse.cz>
 <201612082153.BHC81241.VtMFFHOLJOOFSQ@I-love.SAKURA.ne.jp>
 <20161208134718.GC26530@dhcp22.suse.cz>
 <201612112023.HBB57332.QOFFtJLOOMFSVH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612112023.HBB57332.QOFFtJLOOMFSVH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 11-12-16 20:23:47, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 08-12-16 21:53:44, Tetsuo Handa wrote:
[...]
> > > > If you believe that my argumentation is incorrect then you are free to
> > > > nak the patch with your reasoning. But please stop this nit picking on
> > > > nonsense combination of flags.
> > >
> > > Nacked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > >
> > > on patch 2 unless "you explain these patches to __GFP_NOFAIL users and
> > > provide a mean to invoke the OOM killer if someone chose possibility of
> > > panic"
> >
> > I believe that the changelog contains my reasoning and so far I
> > haven't heard any _argument_ from you why they are wrong. You just
> > managed to nitpick on an impossible and pointless gfp_mask combination
> > and some handwaving on possible lockups without any backing arguments.
> > This is not something I would consider as a basis for a serious nack. So
> > if you really hate this patch then do please start being reasonable and
> > put some real arguments into your review without any off topics and/or
> > strawman arguments without any relevance.
> >
> 
> Are you aware that I'm not objecting to "change __GFP_NOFAIL not to invoke
> the OOM killer". What I'm objecting is that you are trying to change
> !__GFP_FS && !__GFP_NOFAIL allocation requests without offering transition
> plan like below.
> 
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -1013,7 +1013,7 @@ bool out_of_memory(struct oom_control *oc)
>       * make sure exclude 0 mask - all other users should have at least
>       * ___GFP_DIRECT_RECLAIM to get here.
>       */
> -    if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_NOFAIL)))
> +    if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_WANT_OOM_KILLER))
>          return true;

I have already asked that but let me ask again. _Who_ would use this
flag and not risk the pre-mature OOM killer invocation?

[...]

>   I believe that __GFP_NOFAIL should not imply invocation of the OOM killer.
>   Therefore, I want to change __GFP_NOFAIL not to invoke the OOM killer.
>   But since currently the OOM killer is not invoked unless either __GFP_FS or
>   __GFP_NOFAIL is specified, changing __GFP_NOFAIL not to invoke the OOM
>   killer introduces e.g. GFP_NOFS | __GFP_NOFAIL users a risk of livelocking
>   by not invoking the OOM killer. Although I can't prove that this change
>   never causes livelock, I don't want to provide an alternative flag like
>   __GFP_WANT_OOM_KILLER. Therefore, all existing __GFP_NOFAIL users must
>   agree with accepting the risk introduced by this change.

I think you are seriously misled here. First of all, I have gone through
GFP_NOFS | GFP_NOFAIL users and _none_ of them have added the nofail
flag to enforce the OOM killer. Those users just want to express that an
allocation failure is simply not acceptable. Most of them were simply
conversions from the open-conded
	do { } while (! (page = page_alloc(GFP_NOFS));
loops. Which _does_ not invoke the OOM killer. And that is the most
importatnt point here. Why the above open coded (and as you say lockup
prone) loop is OK while GFP_NOFAIL varian should behave any differently?

> and confirm that all existing __GFP_NOFAIL users are willing to accept
> the risk of livelocking by not invoking the OOM killer.
> 
> Unless you do this procedure, I continue:
> 
> Nacked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

I was hoping for some actual arguments but I am afraid this is circling
in a loop. You are still handwaving with theoretical lockups without any
actual proof they are real. While I am not saying the risk is not there
I also say that there are other aspects to consider
	- lockups will happen only if there are no other GFP_FS requests
	  which trigger the OOM which is quite unlikely in most
	  situations
	- triggering oom for GFP_NOFS | GFP_NOFAIL has a non negligible
	  risk of pre-mature OOM killer invocation for the same reason
	  we do not trigger oom for GFP_NOFS. Even worse metadata heavy
	  workloads are much harder to contain so this might be used as
	  a DoS vector.
	- one of the primary point of GFP_NOFAIL existence is to prevent
	  from open coding endless loops in the code because the page
	  allocator can handle most situations more gracefully (e.g.
	  grant access to memory reserves). Having a completely
	  different OOM killer behavior is both confusing and encourages
	  abuse. If we have users who definitely need to control the OOM
	  behavior then we should add a gfp flag for them. But this
	  needs a strong use case and consider whether there are other
	  options to go around that.

I can add the above to the changelog if you think this is helpful but I
still maintain my position that your "this might cause lockups
theoretically" is unfounded and not justified to block the patch. I will
of course retract this patch if you can demonstrate the issue is real or
that any of my argumentation in the changelog is not correct.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
