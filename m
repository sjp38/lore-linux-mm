Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 32F148E0084
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 11:56:38 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id o200so3048500ybc.1
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 08:56:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z7sor3971130ywe.8.2019.01.24.08.56.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 08:56:36 -0800 (PST)
Date: Thu, 24 Jan 2019 11:56:34 -0500
From: Chris Down <chris@chrisdown.name>
Subject: Re: [PATCH] mm: Move maxable seq_file logic into a single place
Message-ID: <20190124165634.GA13549@chrisdown.name>
References: <20190124061718.GA15486@chrisdown.name>
 <20190124160935.GB12436@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190124160935.GB12436@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

Johannes Weiner writes:
>I think this increases complexity more than it saves LOC,
>unfortunately.
>
>The current situation is a bit repetitive, but much more obviously
>correct. And we're not planning on adding many more of those memcg
>interface files, so I this doesn't seem to be an improvement re:
>maintainability and future extensibility of the code.

Hmm, my main goal in the patch was not really reduction of LOC, but more around 
centralising logic so that it's clear where these functions are unique and 
where they are completely the same. My initial reaction upon reading these was 
mostly to feel like I'm missing something due to the large amount of similarity 
between them, wondering if the change in mem_cgroup/page_counter access is 
really the only thing to look at, so my goal was primarily to reduce confusion 
(although of course this is subjective, I can also see your point about how 
having "memory.low" and the like without context can also be confusing).

I think using a macro is not ideal, but unfortunately without it a lot of the 
complexity can't really be abstracted easily.

If not this, what would you think about a patch that adds two new functions:

1. mem_cgroup_from_seq
2. mem_cgroup_write_max_or_val

This won't be able to reduce as much of the overlap as the macro, but it still 
will centralise a lot of the logic.
