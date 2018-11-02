Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 262216B0003
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 04:04:00 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f22-v6so957775pgv.21
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 01:04:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d32-v6si22436900pgl.585.2018.11.02.01.03.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 01:03:58 -0700 (PDT)
Date: Fri, 2 Nov 2018 09:03:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Will the recent memory leak fixes be backported to longterm
 kernels?
Message-ID: <20181102073009.GP23921@dhcp22.suse.cz>
References: <PU1P153MB0169CB6382E0F047579D111DBFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102005816.GA10297@tower.DHCP.thefacebook.com>
 <PU1P153MB0169FE681EF81BCE81B005A1BFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <PU1P153MB0169FE681EF81BCE81B005A1BFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dexuan Cui <decui@microsoft.com>
Cc: Roman Gushchin <guro@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Shakeel Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>, "Stable@vger.kernel.org" <Stable@vger.kernel.org>

On Fri 02-11-18 02:45:42, Dexuan Cui wrote:
[...]
> I totally agree. I'm now just wondering if there is any temporary workaround,
> even if that means we have to run the kernel with some features disabled or
> with a suboptimal performance?

One way would be to disable kmem accounting (cgroup.memory=nokmem kernel
option). That would reduce the memory isolation because quite a lot of
memory will not be accounted for but the primary source of in-flight and
hard to reclaim memory will be gone.

Another workaround could be to use force_empty knob we have in v1 and
use it when removing a cgroup. We do not have it in cgroup v2 though.
The file hasn't been added to v2 because we didn't really have any
proper usecase. Working around a bug doesn't sound like a _proper_
usecase but I can imagine workloads that bring a lot of metadata objects
that are not really interesting for later use so something like a
targeted drop_caches...
-- 
Michal Hocko
SUSE Labs
