Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 92EDD6B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 11:33:35 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id cy9so44103480pac.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 08:33:35 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id t72si10510085pfi.38.2016.01.22.08.33.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 08:33:34 -0800 (PST)
Date: Fri, 22 Jan 2016 19:33:24 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: PROBLEM: BUG when using memory.kmem.limit_in_bytes
Message-ID: <20160122163324.GH26192@esperanza>
References: <CAKB58ikDkzc8REt31WBkD99+hxNzjK4+FBmhkgS+NVrC9vjMSg@mail.gmail.com>
 <20160122135042.GF26192@esperanza>
 <20160122144854.GA14432@cmpxchg.org>
 <20160122155104.GG32380@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160122155104.GG32380@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Brian Christiansen <brian.o.christiansen@gmail.com>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 22, 2016 at 10:51:04AM -0500, Tejun Heo wrote:
> On Fri, Jan 22, 2016 at 09:48:54AM -0500, Johannes Weiner wrote:
> > On Fri, Jan 22, 2016 at 04:50:42PM +0300, Vladimir Davydov wrote:
> > > From first glance, it looks like the bug was triggered, because
> > > mem_cgroup_css_offline was run for a child cgroup earlier than for its
> > > parent. This couldn't happen for sure before the cgroup was switched to
> > > percpu_ref, because cgroup_destroy_wq has always had max_active == 1.
> > > Now, however, it looks like this is perfectly possible for
> > > css_killed_ref_fn is called from an rcu callback - see kill_css ->
> > > percpu_ref_kill_and_confirm. This breaks kmemcg assumptions.
> > > 
> > > I'll take a look what can be done about that.
> > 
> > It's an acknowledged problem in the cgroup core then, and not an issue
> > with kmemcg. Tejun sent a fix to correct the offlining order here:
> > 
> > https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1056544.html
> 
> Patche descriptions updated and applied to cgroup/for-4.5-fixes.
> 
>  http://lkml.kernel.org/g/20160122154503.GD32380@htj.duckdns.org
>  http://lkml.kernel.org/g/20160122154552.GE32380@htj.duckdns.org

I couldn't reproduce the issue with the two patches applied. Looks like
they fix it.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
