Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9A30F6B0254
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:44:40 -0400 (EDT)
Received: by lamp12 with SMTP id p12so84882665lam.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 05:44:39 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id c5si1442068laa.134.2015.09.14.05.44.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 05:44:38 -0700 (PDT)
Date: Mon, 14 Sep 2015 15:44:20 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 2/3] memcg: ratify and consolidate over-charge handling
Message-ID: <20150914124420.GE30743@esperanza>
References: <20150913201416.GC25369@htj.duckdns.org>
 <20150913201442.GD25369@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150913201442.GD25369@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Sun, Sep 13, 2015 at 04:14:42PM -0400, Tejun Heo wrote:
> try_charge() is the main charging logic of memcg.  When it hits the
> limit but either can't fail the allocation due to __GFP_NOFAIL or the
> task is likely to free memory very soon, being OOM killed, has SIGKILL
> pending or exiting, it "bypasses" the charge to the root memcg and
> returns -EINTR.  While this is one approach which can be taken for
> these situations, it has several issues.
> 
> * It unnecessarily lies about the reality.  The number itself doesn't
>   go over the limit but the actual usage does.  memcg is either forced
>   to or actively chooses to go over the limit because that is the
>   right behavior under the circumstances, which is completely fine,
>   but, if at all avoidable, it shouldn't be misrepresenting what's
>   happening by sneaking the charges into the root memcg.
> 
> * Despite trying, we already do over-charge.  kmemcg can't deal with
>   switching over to the root memcg by the point try_charge() returns
>   -EINTR, so it open-codes over-charing.
> 
> * It complicates the callers.  Each try_charge() user has to handle
>   the weird -EINTR exception.  memcg_charge_kmem() does the manual
>   over-charging.  mem_cgroup_do_precharge() performs unnecessary
>   uncharging of root memcg, which BTW is inconsistent with what

Hmm, cancel_charge(root_mem_cgroup) is a no-op. Looks like this is a
leftover from the times when we did charge root_mem_cgroup.

Anyway, the rationale makes sense to me, and the patch looks good.

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

>   memcg_charge_kmem() does.  mem_cgroup_try_charge() needs to switch
>   the returned cgroup to the root one.
> 
> The reality is that in memcg there are cases where we are forced
> and/or willing to go over the limit.  Each such case needs to be
> scrutinized and justified but there definitely are situations where
> that is the right thing to do.  We alredy do this but with a
> superficial and inconsistent disguise which leads to unnecessary
> complications.
> 
> This patch updates try_charge() so that it over-charges and returns 0
> when deemed necessary.  -EINTR return is removed along with all
> special case handling in the callers.
> 
> While at it, remove the local variable @ret, which was initialized to
> zero and never changed, along with done: label which just returned the
> always zero @ret.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
