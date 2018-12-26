Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D18698E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 03:35:09 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id l22so17218955pfb.2
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 00:35:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j191si31161946pgd.31.2018.12.26.00.35.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 00:35:08 -0800 (PST)
Date: Wed, 26 Dec 2018 09:35:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/1] mm: add a warning about high order allocations
Message-ID: <20181226083505.GF16738@dhcp22.suse.cz>
References: <20181225153927.2873-1-khorenko@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181225153927.2873-1-khorenko@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khorenko <khorenko@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>

On Tue 25-12-18 18:39:26, Konstantin Khorenko wrote:
> Q: Why do we need to bother at all?
> A: If a node is highly loaded and its memory is significantly fragmented
> (unfortunately almost any node with serious load has highly fragmented memory)
> then any high order memory allocation can trigger massive memory shrink and
> result in quite a big allocation latency. And the node becomes less responsive
> and users don't like it.
> The ultimate solution here is to get rid of large allocations, but we need an
> instrument to detect them.

Can you point to an example of the problem you are referring here? At
least for costly orders we do bail out early and try to not cause
massive reclaim. So what is the order that you are concerned about?

> Q: Why warning? Use tracepoints!
> A: Well, this is a matter of magic defaults.
> Yes, you can use tracepoints to catch large allocations, but you need to do this
> on purpose and regularly and this is to be done by every developer which is
> quite unreal.
> On the other hand if you develop something and get a warning, you'll have to
> think about the reason and either succeed with reworking the code to use
> smaller allocation sizes (and thus decrease allocation latency!) or just use
> kvmalloc() if you don't really need physically continuos chunk or come to the
> conclusion you definitely need physically continuos memory and shut up the
> warning.

Well, not really. For one thing, there are systems to panic on warning
and you really do not want to blow up just because somebody is doing a
large order allocation.

> Q: Why compile time config option?
> A: In order not to decrease the performance even a bit in case someone does not
> want to hunt for large allocations.
> In an ideal life i'd prefer this check/warning is enabled by default and may be
> even without a config option so it works on every node. Once we find and rework
> or mark all large allocations that would be good by default. Until that though
> it will be noisy.

So who is going to enable this option?

> Another option is to rework the patch via static keys (having the warning
> disabled by default surely). That makes it possible to turn on the feature
> without recompiling the kernel - during testing period for example.
> 
> If you prefer this way, i would be happy to rework the patch via static keys.

I would rather go and chase the underlying issue. So can we get an
actual data please?

-- 
Michal Hocko
SUSE Labs
