Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 207566B025E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 07:56:44 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id fp4so21155093obb.2
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 04:56:44 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f50si4937521otd.65.2016.03.31.04.56.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Mar 2016 04:56:42 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom: move GFP_NOFS check to out_of_memory
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1459258055-1173-1-git-send-email-mhocko@kernel.org>
	<alpine.DEB.2.10.1603291510560.11705@chino.kir.corp.google.com>
	<20160330094750.GH30729@dhcp22.suse.cz>
	<201603302046.CBJ39064.LFVQOHOOJtFSMF@I-love.SAKURA.ne.jp>
	<20160330121141.GD4324@dhcp22.suse.cz>
In-Reply-To: <20160330121141.GD4324@dhcp22.suse.cz>
Message-Id: <201603312056.BJH95312.HOQFFSVMJOLtOF@I-love.SAKURA.ne.jp>
Date: Thu, 31 Mar 2016 20:56:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, linux-mm@kvack.org, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 30-03-16 20:46:48, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Tue 29-03-16 15:13:54, David Rientjes wrote:
> > > > On Tue, 29 Mar 2016, Michal Hocko wrote:
> > > > 
> > > > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > > > index 86349586eacb..1c2b7a82f0c4 100644
> > > > > --- a/mm/oom_kill.c
> > > > > +++ b/mm/oom_kill.c
> > > > > @@ -876,6 +876,10 @@ bool out_of_memory(struct oom_control *oc)
> > > > >  		return true;
> > > > >  	}
> > > > >  
> > > > > +	/* The OOM killer does not compensate for IO-less reclaim. */
> > > > > +	if (!(oc->gfp_mask & __GFP_FS))
> > > > > +		return true;
> > > > > +
> > 
> > This patch will disable pagefault_out_of_memory() because currently
> > pagefault_out_of_memory() is passing oc->gfp_mask == 0.
> > 
> > Because of current behavior, calling oom notifiers from !__GFP_FS seems
> > to be safe.
> 
> You are right! I have completely missed that and thought we were
> providing GFP_KERNEL there. So we have two choices. Either we do
> use GFP_KERNEL (same as we do for sysrq+f) or we special case
> pagefault_out_of_memory in some way. The second option seems to be safer
> because the gfp_mask has to contain at least ___GFP_DIRECT_RECLAIM to
> trigger the OOM path.

Oops, I missed that this patch also disables out_of_memory() for !__GFP_FS &&
__GFP_NOFAIL allocation requests.

> > I think we are not ready to handle situations where out_of_memory() is called
> > again after current thread got TIF_MEMDIE due to __GFP_NOFAIL allocation
> > request when we ran out of memory reserves. We should not assume that the
> > victim target thread does not have TIF_MEMDIE yet. I think we can handle it
> > by making mark_oom_victim() return a bool and return via shortcut only if
> > mark_oom_victim() successfully set TIF_MEMDIE. Though I don't like the
> > shortcut approach that lacks a guaranteed unlocking mechanism.
> 
> That would lead to premature follow up OOM when TIF_MEMDIE makes some
> progress just not in time.

We can never know whether the OOM killer prematurely killed a victim.
It is possible that get_page_from_freelist() will succeed even if
select_bad_process() did not find a TIF_MEMDIE thread. You said you don't
want to violate the layer
( http://lkml.kernel.org/r/20160129152307.GF32174@dhcp22.suse.cz ).

What we can do is tolerate possible premature OOM killer invocation using
some threshold. You are proposing such change as OOM detection rework that
might possibly cause premature OOM killer invocation.
Waiting forever unconditionally (e.g.
http://lkml.kernel.org/r/201602092349.ACG81273.OSVtMJQHLOFOFF@I-love.SAKURA.ne.jp )
is no good. Suppressing OOM killer invocation forever unconditionally (e.g.
decide based on only !__GFP_FS, decide based on only TIF_MEMDIE) is no good.

Even if we stop returning via shortcut by making mark_oom_victim() return a
bool, select_bad_process() will work as hold off mechanism. By combining with
timeout (or something finite one) for TIF_MEMDIE, we can tolerate possible
premature OOM killer invocation. It is much better than OOM-livelocked forever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
