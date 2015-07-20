Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5281A9003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 07:49:20 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so23842049wib.1
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 04:49:19 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id he1si12957060wib.34.2015.07.20.04.49.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jul 2015 04:49:19 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so94412059wib.0
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 04:49:16 -0700 (PDT)
Date: Mon, 20 Jul 2015 13:49:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/5] memcg: export struct mem_cgroup
Message-ID: <20150720114913.GG1211@dhcp22.suse.cz>
References: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
 <1436958885-18754-2-git-send-email-mhocko@kernel.org>
 <20150715135711.1778a8c08f2ea9560a7c1f6f@linux-foundation.org>
 <20150716071948.GC3077@dhcp22.suse.cz>
 <20150716143433.e43554a19b1c89a8524020cb@linux-foundation.org>
 <20150716225639.GA11131@cmpxchg.org>
 <20150716160358.de3404c44ba29dc132032bbc@linux-foundation.org>
 <20150717122819.GA14895@cmpxchg.org>
 <20150717151827.GB15934@mtj.duckdns.org>
 <20150717131900.5b0b5d91597d207c474be7a5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150717131900.5b0b5d91597d207c474be7a5@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 17-07-15 13:19:00, Andrew Morton wrote:
> On Fri, 17 Jul 2015 11:18:27 -0400 Tejun Heo <tj@kernel.org> wrote:
> 
> > Maybe there are details to be improved but I think
> > it's about time mem_cgroup definition gets published.
> 
> grumble.

I am open to other cleanups but keeping mem_cgroup private sounds like
we will face more issues long term.

> enum mem_cgroup_events_target can remain private to memcontrol.c.  It's
> only used by mem_cgroup_event_ratelimit() and that function is static.

Except it is needed by mem_cgroup_stat_cpu. More below...

> Why were cg_proto_flags and cg_proto moved from include/net/sock.h?

Because they naturally belong to memcg header file. We can keep it there
if you prefer but I felt like sock.h is quite heavy already.
Now that I am looking into other MEMCG_KMEM related stuff there,
memcg_proto_active sounds like a good one to move to memcontrol.h as well.

> struct mem_cgroup_stat_cpu can remain private to memcontrol.c.  Forward
> declare the struct in memcontrol.h.

And we cannot hide this one because of mem_cgroup_events which
dereferences stat. There are some hot code paths doing statistics and it
would be better if they can inline this trivial code.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
