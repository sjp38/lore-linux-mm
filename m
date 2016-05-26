Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 92F6D6B0253
	for <linux-mm@kvack.org>; Thu, 26 May 2016 17:02:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b124so162989623pfb.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 14:02:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f191si8975359pfc.101.2016.05.26.14.02.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 14:02:03 -0700 (PDT)
Date: Thu, 26 May 2016 14:02:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: add RCU locking around
 css_for_each_descendant_pre() in memcg_offline_kmem()
Message-Id: <20160526140202.077d611dbe0926ce290b4e53@linux-foundation.org>
In-Reply-To: <20160526203018.GG23194@mtj.duckdns.org>
References: <20160526203018.GG23194@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Thu, 26 May 2016 16:30:18 -0400 Tejun Heo <tj@kernel.org> wrote:

> memcg_offline_kmem() may be called from memcg_free_kmem() after a css
> init failure.  memcg_free_kmem() is a ->css_free callback which is
> called without cgroup_mutex and memcg_offline_kmem() ends up using
> css_for_each_descendant_pre() without any locking.  Fix it by adding
> rcu read locking around it.
> 
>  mkdir: cannot create directory ___65530___: No space left on device
>  [  527.241361] ===============================
>  [  527.241845] [ INFO: suspicious RCU usage. ]
>  [  527.242367] 4.6.0-work+ #321 Not tainted
>  [  527.242730] -------------------------------
>  [  527.243220] kernel/cgroup.c:4008 cgroup_mutex or RCU read lock required!

cc:stable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
