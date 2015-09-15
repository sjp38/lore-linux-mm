Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 27DDC6B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 12:18:39 -0400 (EDT)
Received: by lbbvu2 with SMTP id vu2so16088249lbb.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 09:18:38 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ab1si5652264lbc.108.2015.09.15.09.18.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 09:18:37 -0700 (PDT)
Date: Tue, 15 Sep 2015 18:18:26 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 2/3] memcg: ratify and consolidate over-charge handling
Message-ID: <20150915161826.GB12032@cmpxchg.org>
References: <20150913201416.GC25369@htj.duckdns.org>
 <20150913201442.GD25369@htj.duckdns.org>
 <20150914200732.GG25369@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150914200732.GG25369@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

On Mon, Sep 14, 2015 at 04:07:32PM -0400, Tejun Heo wrote:
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
>   memcg_charge_kmem() does but not broken as [un]charging are noops on
>   root memcg.  mem_cgroup_try_charge() needs to switch the returned
>   cgroup to the root one.
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
> v2: Minor update to patch description as per Vladimir.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
