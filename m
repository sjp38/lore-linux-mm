Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE5796B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 10:35:27 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g6-v6so2526255wrp.4
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 07:35:27 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v15-v6si2643005edb.343.2018.06.21.07.35.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Jun 2018 07:35:26 -0700 (PDT)
Date: Thu, 21 Jun 2018 10:37:51 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH] memcg, oom: move out_of_memory back to the charge
 path
Message-ID: <20180621143751.GA11230@cmpxchg.org>
References: <20180620103736.13880-1-mhocko@kernel.org>
 <20180621080927.GE10465@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180621080927.GE10465@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 21, 2018 at 10:09:27AM +0200, Michal Hocko wrote:
> @@ -496,14 +496,14 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
>  
>  static inline void mem_cgroup_oom_enable(void)
>  {
> -	WARN_ON(current->memcg_may_oom);
> -	current->memcg_may_oom = 1;
> +	WARN_ON(current->in_user_fault);
> +	current->in_user_fault = 1;
>  }
>  
>  static inline void mem_cgroup_oom_disable(void)
>  {
> -	WARN_ON(!current->memcg_may_oom);
> -	current->memcg_may_oom = 0;
> +	WARN_ON(!current->in_user_fault);
> +	current->in_user_fault = 0;
>  }

Would it make more sense to rename these to
mem_cgroup_enter_user_fault(), mem_cgroup_exit_user_fault()?

Other than that, this looks great to me.

Thanks
