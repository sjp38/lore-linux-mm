Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF5A0440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 05:45:16 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id v15so432166ote.10
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 02:45:16 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v23si3174579otd.254.2017.11.09.02.45.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 02:45:15 -0800 (PST)
Subject: Re: [PATCH 1/5] mm,page_alloc: Update comment for last second allocation attempt.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1510138908-6265-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171108145039.tdueguedqos4rpk5@dhcp22.suse.cz>
In-Reply-To: <20171108145039.tdueguedqos4rpk5@dhcp22.suse.cz>
Message-Id: <201711091945.IAD64050.MtLFFQOOSOFJHV@I-love.SAKURA.ne.jp>
Date: Thu, 9 Nov 2017 19:45:04 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, hannes@cmpxchg.org

Michal Hocko wrote:
> On Wed 08-11-17 20:01:44, Tetsuo Handa wrote:
> > __alloc_pages_may_oom() is doing last second allocation attempt using
> > ALLOC_WMARK_HIGH before calling out_of_memory(). This had two reasons.
> > 
> > The first reason is explained in the comment that it aims to catch
> > potential parallel OOM killing. But there is no longer parallel OOM
> > killing (in the sense that out_of_memory() is called "concurrently")
> > because we serialize out_of_memory() calls using oom_lock.
> > 
> > The second reason is explained by Andrea Arcangeli (who added that code)
> > that it aims to reduce the likelihood of OOM livelocks and be sure to
> > invoke the OOM killer. There was a risk of livelock or anyway of delayed
> > OOM killer invocation if ALLOC_WMARK_MIN is used, for relying on last
> > few pages which are constantly allocated and freed in the meantime will
> > not improve the situation.

Above part is OK, isn't it?

> 
> > But there is no longer possibility of OOM
> > livelocks or failing to invoke the OOM killer because we need to mask
> > __GFP_DIRECT_RECLAIM for last second allocation attempt because oom_lock
> > prevents __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocations which last
> > second allocation attempt indirectly involve from failing.
> 
> This is an unfounded, misleading and actually even wrong statement that
> has nothing to do with what Andrea had in mind. __GFP_DIRECT_RECLAIM
> doesn't have anything to do with the livelock as I've already mentioned
> several times already.

I know that this part is not what Andrea had in mind when he added this comment.
What I'm saying is that "precondition has changed after Andrea added this comment"
and "these reasons which Andrea had in mind when he added this comment no longer
holds". I'm posting "for the record" purpose in order to describe reasons for
current code.

When we introduced oom_lock (or formerly the per-zone oom lock) for serializing invocation
of the OOM killer, we introduced two bugs at the same time. One bug is that since doing
__GFP_DIRECT_RECLAIM with oom_lock held can make __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
allocations (which __GFP_DIRECT_RECLAIM indirectly involved) lockup, we need to avoid
__GFP_DIRECT_RECLAIM allocations with oom_lock held. This is why commit e746bf730a76fe53
("mm,page_alloc: don't call __node_reclaim() with oom_lock held.") was made. This in turn
forbids using __GFP_DIRECT_RECLAIM for last second allocation attempt which was not
forbidden when Andrea added this comment.

( The other bug is that we assumed that somebody is making progress for us when
mutex_trylock(&oom_lock) in __alloc_pages_may_oom() failed, for we did not take
scheduling priority into account when we introduced oom_lock. But the other bug
is not what I'm writing in this patch. You can forget about the other bug
regarding this patch. )

> 
> > Since the OOM killer does not always kill a process consuming significant
> > amount of memory (the OOM killer kills a process with highest OOM score
> > (or instead one of its children if any)), there will be cases where
> > ALLOC_WMARK_HIGH fails and ALLOC_WMARK_MIN succeeds.
> 
> This is possible but not really interesting case as already explained.
> 
> > Since the gap between ALLOC_WMARK_HIGH and ALLOC_WMARK_MIN can be changed
> > by /proc/sys/vm/min_free_kbytes parameter, using ALLOC_WMARK_MIN for last
> > second allocation attempt might be better for minimizing number of OOM
> > victims. But that change should be done in a separate patch. This patch
> > just clarifies that ALLOC_WMARK_HIGH is an arbitrary choice.
> 
> Again unfounded claim.

Since use of __GFP_DIRECT_RECLAIM for last second allocation attempt is now
forbidden due to oom_lock already held, possibility of failing last allocation
attempt has increased compared to when Andrea added this comment. Andrea said

  The high wmark is used to be sure the failure of reclaim isn't going to be
  ignored. If using the min wmark like you propose there's risk of livelock or
  anyway of delayed OOM killer invocation.

but there is no longer possibility of OOM livelock because __GFP_DIRECT_RECLAIM
is masked. Therefore, while using ALLOC_WMARK_HIGH might made sense before we
introduced oom_lock, using ALLOC_WMARK_HIGH no longer has strong background after
we introduced oom_lock. Therefore, I'm updating the comment in the source code,
with a suggestion in the changelog that ALLOC_WMARK_MIN might be better for
current code, in order to help someone who find this patch 5 or 10 years future
can figure out why we are using ALLOC_WMARK_HIGH (like you did at
http://lkml.kernel.org/r/20160128163802.GA15953@dhcp22.suse.cz ).

> 
> That being said, the comment removing a note about parallel oom killing
> is OK. I am not sure this is something worth a separate patch. The
> changelog is just wrong and so Nack to the patch.

So, I believe that the changelog is not wrong, and I don't want to preserve

  keep very high watermark here, this is only to catch a parallel oom killing,
  we must fail if we're still under heavy pressure

part which lost strong background.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
