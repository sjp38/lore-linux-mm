Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1326C6B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 10:51:07 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id b35so60055160qge.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 07:51:07 -0800 (PST)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com. [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id 78si7705101qge.4.2016.01.22.07.51.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 07:51:06 -0800 (PST)
Received: by mail-qg0-x22f.google.com with SMTP id 6so60007029qgy.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 07:51:06 -0800 (PST)
Date: Fri, 22 Jan 2016 10:51:04 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: PROBLEM: BUG when using memory.kmem.limit_in_bytes
Message-ID: <20160122155104.GG32380@htj.duckdns.org>
References: <CAKB58ikDkzc8REt31WBkD99+hxNzjK4+FBmhkgS+NVrC9vjMSg@mail.gmail.com>
 <20160122135042.GF26192@esperanza>
 <20160122144854.GA14432@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160122144854.GA14432@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Brian Christiansen <brian.o.christiansen@gmail.com>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 22, 2016 at 09:48:54AM -0500, Johannes Weiner wrote:
> On Fri, Jan 22, 2016 at 04:50:42PM +0300, Vladimir Davydov wrote:
> > From first glance, it looks like the bug was triggered, because
> > mem_cgroup_css_offline was run for a child cgroup earlier than for its
> > parent. This couldn't happen for sure before the cgroup was switched to
> > percpu_ref, because cgroup_destroy_wq has always had max_active == 1.
> > Now, however, it looks like this is perfectly possible for
> > css_killed_ref_fn is called from an rcu callback - see kill_css ->
> > percpu_ref_kill_and_confirm. This breaks kmemcg assumptions.
> > 
> > I'll take a look what can be done about that.
> 
> It's an acknowledged problem in the cgroup core then, and not an issue
> with kmemcg. Tejun sent a fix to correct the offlining order here:
> 
> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1056544.html

Patche descriptions updated and applied to cgroup/for-4.5-fixes.

 http://lkml.kernel.org/g/20160122154503.GD32380@htj.duckdns.org
 http://lkml.kernel.org/g/20160122154552.GE32380@htj.duckdns.org

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
