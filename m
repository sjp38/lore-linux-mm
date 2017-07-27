Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9C96B0493
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 10:36:25 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p43so30951287wrb.6
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 07:36:25 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b29si12622097edc.95.2017.07.27.07.36.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Jul 2017 07:36:24 -0700 (PDT)
Date: Thu, 27 Jul 2017 10:36:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] cgroup: revert fa06235b8eb0 ("cgroup: reset css on
 destruction")
Message-ID: <20170727143617.GC19738@cmpxchg.org>
References: <20170726083017.3yzeucmi7lcj46qd@esperanza>
 <20170727130428.28856-1-guro@fb.com>
 <20170727130428.28856-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727130428.28856-2-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jul 27, 2017 at 02:04:28PM +0100, Roman Gushchin wrote:
> Commit fa06235b8eb0 ("cgroup: reset css on destruction") caused
> css_reset callback to be called from the offlining path. Although
> it solves the problem mentioned in the commit description
> ("For instance, memory cgroup needs to reset memory.low, otherwise
> pages charged to a dead cgroup might never get reclaimed."),
> generally speaking, it's not correct.
> 
> An offline cgroup can still be a resource domain, and we shouldn't
> grant it more resources than it had before deletion.
> 
> For instance, if an offline memory cgroup has dirty pages, we should
> still imply i/o limits during writeback.
> 
> The css_reset callback is designed to return the cgroup state
> into the original state, that means reset all limits and counters.
> It's spomething different from the offlining, and we shouldn't use
> it from the offlining path. Instead, we should adjust necessary
> settings from the per-controller css_offline callbacks (e.g. reset
> memory.low).
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: kernel-team@fb.com
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
