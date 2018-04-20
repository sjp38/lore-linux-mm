Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 895486B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 16:53:13 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id b10-v6so10133108wrf.3
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 13:53:13 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w53si1697244edc.303.2018.04.20.13.53.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 20 Apr 2018 13:53:12 -0700 (PDT)
Date: Fri, 20 Apr 2018 16:54:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] mm: move the high field from struct mem_cgroup to
 page_counter
Message-ID: <20180420205450.GB24563@cmpxchg.org>
References: <20180420163632.3978-1-guro@fb.com>
 <20180420163632.3978-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180420163632.3978-2-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>

On Fri, Apr 20, 2018 at 05:36:32PM +0100, Roman Gushchin wrote:
> We do store memory.min, memory.low and memory.max actual values
> in struct page_counter fields, while memory.high value is located
> in the struct mem_cgroup directly, which is not very consistent.
> 
> This patch moves the high field from struct mem_cgroup to
> struct page_counter to simplify the code and make handling
> of all limits/boundaries clearer.

I would prefer not doing this.

Yes, it looks a bit neater if all these things are next to each other
in the struct, but on the other hand it separates the high variable
from high_work, and it adds an unnecessary setter function as well.

Plus, nothing in the page_counter code actually uses the value, it
really isn't part of that abstraction layer.
