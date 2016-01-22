Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 56D056B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 09:49:07 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l65so263997475wmf.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 06:49:07 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p1si8809632wjx.81.2016.01.22.06.49.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 06:49:06 -0800 (PST)
Date: Fri, 22 Jan 2016 09:48:54 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: PROBLEM: BUG when using memory.kmem.limit_in_bytes
Message-ID: <20160122144854.GA14432@cmpxchg.org>
References: <CAKB58ikDkzc8REt31WBkD99+hxNzjK4+FBmhkgS+NVrC9vjMSg@mail.gmail.com>
 <20160122135042.GF26192@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160122135042.GF26192@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Brian Christiansen <brian.o.christiansen@gmail.com>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 22, 2016 at 04:50:42PM +0300, Vladimir Davydov wrote:
> From first glance, it looks like the bug was triggered, because
> mem_cgroup_css_offline was run for a child cgroup earlier than for its
> parent. This couldn't happen for sure before the cgroup was switched to
> percpu_ref, because cgroup_destroy_wq has always had max_active == 1.
> Now, however, it looks like this is perfectly possible for
> css_killed_ref_fn is called from an rcu callback - see kill_css ->
> percpu_ref_kill_and_confirm. This breaks kmemcg assumptions.
> 
> I'll take a look what can be done about that.

It's an acknowledged problem in the cgroup core then, and not an issue
with kmemcg. Tejun sent a fix to correct the offlining order here:

https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1056544.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
