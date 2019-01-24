Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 650C58E0085
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 11:09:45 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id o199so2934357ybg.18
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 08:09:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l124sor10132376ybb.108.2019.01.24.08.09.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 08:09:37 -0800 (PST)
Date: Thu, 24 Jan 2019 11:09:35 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: Move maxable seq_file logic into a single place
Message-ID: <20190124160935.GB12436@cmpxchg.org>
References: <20190124061718.GA15486@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124061718.GA15486@chrisdown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Thu, Jan 24, 2019 at 01:17:18AM -0500, Chris Down wrote:
> memcg has a significant number of files exposed to kernfs where their
> value is either exposed directly or is "max" in the case of
> PAGE_COUNTER_MAX.
> 
> There's a fair amount of duplicated code here, since each file involves
> turning a seq_file to a css, getting the memcg from the css, safely
> reading the counter value, and then doing the right thing depending on
> whether the value is PAGE_COUNTER_MAX or not.
> 
> This patch adds the macro DEFINE_MEMCG_MAX_OR_VAL, which defines and
> implements a generic way to do this work, avoiding fragmenting logic.
> 
> Signed-off-by: Chris Down <chris@chrisdown.name>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: linux-kernel@vger.kernel.org
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: kernel-team@fb.com
> ---
> mm/memcontrol.c | 78 ++++++++++++-------------------------------------
> 1 file changed, 18 insertions(+), 60 deletions(-)

I think this increases complexity more than it saves LOC,
unfortunately.

The current situation is a bit repetitive, but much more obviously
correct. And we're not planning on adding many more of those memcg
interface files, so I this doesn't seem to be an improvement re:
maintainability and future extensibility of the code.
