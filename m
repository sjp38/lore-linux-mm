Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 14B3E6B0260
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 11:42:41 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 204so294741194pfx.1
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 08:42:41 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id c69si25455212pfd.14.2017.01.17.08.42.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 08:42:40 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id t6so4316808pgt.1
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 08:42:40 -0800 (PST)
Date: Tue, 17 Jan 2017 08:42:38 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 7/8] slab: remove synchronous synchronize_sched() from
 memcg cache deactivation path
Message-ID: <20170117164238.GA28948@mtj.duckdns.org>
References: <20170114184834.8658-1-tj@kernel.org>
 <20170114184834.8658-8-tj@kernel.org>
 <20170117002611.GC25218@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117002611.GC25218@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Tue, Jan 17, 2017 at 09:26:11AM +0900, Joonsoo Kim wrote:
> > +	INIT_WORK(&s->memcg_params.deact_work, kmemcg_deactivate_workfn);
> > +	schedule_work(&s->memcg_params.deact_work);
> > +}
> 
> Isn't it better to submit one work item for each memcg like as
> Vladimir did? Or, could you submit this work to the ordered workqueue?
> I'm not an expert about workqueue like as you, but, I think
> that there is a chance to create a lot of threads if there is
> the slab_mutex lock contention.

Yeah, good point.  I'll switch it to its own workqueue w/ concurrency
limited to one.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
